from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import StrEnum
import functools as ft
import importlib.resources
from pathlib import Path
from typing import Iterator, Self
from rpgxp import db, material, settings, sql
from rpgxp.schema import Schema, rpgxp_schema
from rpgxp.util import camel_case_to_snake

@dataclass
class DBSchema:
    script: sql.Script=field(default_factory=lambda: sql.Script())

    def tables(self) -> Iterator[sql.TableSchema]:
        for s in self.script.statements:
            if isinstance(s, sql.TableSchema):
                yield s

    def inserts(self) -> Iterator[sql.InsertStatement]:
        for s in self.script.statements:
            if isinstance(s, sql.InsertStatement):
                yield s


    def add_table(self, table_schema: sql.TableSchema) -> None:
        self.script.statements.append(table_schema)

    def add_insert(self, insert: sql.InsertStatement) -> None:
        self.script.statements.append(insert)

    def has_table(self, name: str) -> bool:
        return any(table.name == name for table in self.tables())

    def get_table(self, name: str) -> sql.TableSchema:
        for table in self.tables():
            if table.name == name:
                return table

        raise ValueError(f'table {name} not found')

    def process_file_schema(self, file_schema: Schema.FileSchema) -> None:
        match file_schema:
            case Schema.SingleFileSchema(_, content_schema):
                self.process_table_schema(content_schema)
            case Schema.MultipleFilesSchema(
                _, table_name, keys, content_schema
            ):
                if self.has_table(table_name):
                    raise Schema.SchemaError(f'{table_name} used twice')

                table_schema = sql.TableSchema(table_name)

                for key in keys:
                    table_schema += self.process_field(
                        table_schema, key.db_name, key.schema
                    )

                table_schema.make_all_pks()
                self.process_row_schema(table_schema, content_schema)
                self.add_table(table_schema)
            case _:
                assert False

    def process_table_schema(
        self,
        table_schema: Schema.TableSchema,
        parent_table: sql.TableSchema | None=None
    ) -> None:
        parent_table_name = '' if parent_table is None else parent_table.name

        table_name = table_schema.table_name.substitute({
            'prefix': parent_table_name + '_'
        })

        if self.has_table(table_name):
            raise Schema.SchemaError(f'{table_name} used twice')

        db_table_schema = sql.TableSchema(table_name)
        self.add_table(db_table_schema)

        if parent_table is not None and parent_table.singleton:
            parent_table = None

        if parent_table is not None:
            parent_pk = parent_table.pk()
            cols = []
            referenced_names = []

            for col in parent_pk:
                cols.append(sql.ColumnSchema(
                    col.name, col.type_, collate=col.collate, pk=True
                ))

                referenced_names.append(col.name) 
                        
            cols[-1].name = f'{parent_table.name}_{cols[-1].name}'

            db_table_schema.members.extend(cols)

            db_table_schema.members.append(sql.ForeignKeyConstraint(
                [col.name for col in cols],
                parent_table.name,
                referenced_names
            ))

        match table_schema:
            case Schema.ListSchema(
                _, item_schema, first_item=first_item, item_name=item_name,
                index=index_behavior
            ):
                pk_field_name: str | None=None

                match index_behavior:
                    case Schema.AddIndexColumn(index_col_name):
                        min_index = (
                            0 if first_item is Schema.FirstItem.REGULAR
                            else 1
                        )

                        db_table_schema.members.extend([
                            sql.ColumnSchema(index_col_name, 'INTEGER', pk=True),
                            sql.CheckConstraint(
                                f'"{index_col_name}" >= {min_index}'
                            ),
                        ])

                        pk_col_name = index_col_name
                    case Schema.MatchIndexToField(pk_field_name):
                        assert isinstance(item_schema, Schema.ObjSchema)
                        pk_field = item_schema.get_field(pk_field_name)
                        pk_field_name = pk_field.name

                        db_index_schema = self.process_field(
                            db_table_schema, pk_field.db_name, pk_field.schema
                        )

                        db_index_schema.make_all_pks()
                        db_table_schema += db_index_schema

                db_table_schema += self.process_field(
                    db_table_schema, item_name, item_schema,
                    skip_field_name=pk_field_name
                )

            case Schema.SetSchema(_, item_schema, item_name):
                db_member_schema = self.process_field(
                    db_table_schema, item_name, item_schema
                )

                db_member_schema.make_all_pks()
                db_table_schema += db_member_schema

            case Schema.DictSchema(_, key_behavior, value_schema, value_name):
                pk_field_name2: str | None=None

                match key_behavior:
                    case Schema.AddKeyColumn(key_col_name, key_schema):
                        db_key_schema = self.process_field(
                            db_table_schema, key_col_name, key_schema
                        )
                    case Schema.MatchKeyToField(pk_field_name):
                        pk_field = value_schema.get_field(pk_field_name)
                        pk_field_name2 = pk_field.name

                        db_key_schema = self.process_field(
                            db_table_schema, pk_field.db_name, pk_field.schema
                        )
                    case _:
                        assert False

                db_key_schema.make_all_pks()
                db_table_schema += db_key_schema

                db_table_schema += self.process_field(
                    db_table_schema, value_name, value_schema, pk_field_name2
                )

            case Schema.RPGSingletonObjSchema(_, _, _, fields):
                assert parent_table is None
                db_table_schema.singleton = True

                db_table_schema.members.extend([
                    sql.ColumnSchema('id', 'INTEGER', default='0', pk=True),
                    sql.CheckConstraint('"id" = 0'),
                ])

                for field in fields:
                    db_table_schema += self.process_field(
                        db_table_schema, field.db_name, field.schema
                    )

            case _:
                assert False

    def process_row_schema(
        self, table_schema: sql.TableSchema, row_schema: Schema.RowSchema
    ) -> None:
    
        table_schema += self.process_field(table_schema, '', row_schema)

    def process_field(
        self,
        table_schema: sql.TableSchema,
        field_name: str,
        field_schema: Schema.DataSchema,
        skip_field_name: str | None=None
    ) -> sql.TableSchema:

        result: sql.TableSchema = sql.TableSchema(table_schema.name)

        if field_name == '':
            field_name = 'content'
            field_prefix = ''
        else:
            field_prefix = field_name + '_'

        match field_schema:
            case Schema.BoolSchema() | Schema.IntBoolSchema():
                result.members.extend([
                    sql.ColumnSchema(field_name, 'INTEGER'),
                    sql.CheckConstraint(f'"{field_name}" in (0, 1)'),
                ])
            case Schema.IntSchema(lb, ub):
                result.members.append(sql.ColumnSchema(field_name, 'INTEGER'))

                if lb is not None and ub is not None:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" BETWEEN {lb} AND {ub}'
                    ))
                elif lb is not None:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" >= {lb}'
                    ))
                elif ub is not None:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" <= {ub}'
                    ))
            case Schema.FloatSchema(lb, ub):
                result.members.append(sql.ColumnSchema(field_name, 'REAL'))

                if lb is not None and ub is not None:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" BETWEEN {lb} AND {ub}'
                    ))
                elif lb is not None:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" >= {lb}'
                    ))
                elif ub is not None:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" <= {ub}'
                    ))
            case Schema.StrSchema() | Schema.ZlibSchema():
                result.members.append(sql.ColumnSchema(field_name, 'TEXT'))
            case Schema.NDArraySchema():
                result.members.append(sql.ColumnSchema(field_name, 'BLOB'))
            case Schema.EnumSchema(enum_class):
                coltype = 'TEXT' if issubclass(enum_class, StrEnum) else 'INTEGER'
                enum_table_name = camel_case_to_snake(enum_class.__name__)
                result.members.append(sql.ColumnSchema(field_name, coltype))

                if not self.has_table(enum_table_name):
                    self.add_table(sql.TableSchema(enum_table_name, [
                        sql.ColumnSchema('id', coltype, pk=True),
                        sql.ColumnSchema('name', 'TEXT')
                    ]))

                    self.add_insert(sql.InsertStatement(
                        enum_table_name,
                        ('id', 'name'),
                        (coltype, 'TEXT'),
                        [(member.value, member.name) for member in enum_class]
                    ))

                result.members.append(sql.ForeignKeyConstraint(
                    [field_name], enum_table_name, ['id']
                ))
            case Schema.MaterialRefSchema(
                material_type, material_subtype, nullable, enforce
            ):
                type_column_name = f'_{field_name}__type'
                subtype_column_name = f'_{field_name}__subtype'

                result.members.append(
                    sql.ColumnSchema(field_name, 'TEXT', nullable=True)
                )

                if enforce:
                    result.members.extend([
                        sql.ColumnSchema(
                            type_column_name, 'TEXT',
                            generated_as=f"'{material_type}'"
                        ),
                        sql.ColumnSchema(
                            subtype_column_name, 'TEXT',
                            generated_as=f"'{material_subtype}'"
                        ),
                        sql.ForeignKeyConstraint(
                            [
                                field_name, type_column_name,
                                subtype_column_name
                            ],
                            'material',
                            ['name', 'type', 'subtype']
                        )
                    ])

                if not nullable:
                    result.members.append(sql.CheckConstraint(
                        f'"{field_name}" != \'\''
                    ))
            case Schema.FKSchema(foreign_schema_thunk, nullable):
                foreign_schema = foreign_schema_thunk()
                foreign_table_name_template = foreign_schema.table_name

                if foreign_table_name_template.get_identifiers():
                    raise ValueError(f'bad FK schema: {foreign_table_name_template}')

                foreign_table_name = foreign_table_name_template.template

                pk_db_name = foreign_schema.pk_db_name()
                pk_schema = foreign_schema.pk_schema()

                # ok we don't need to process the whole pk schema,
                # just the column part (constraints apply to the pk not the refing column)
                result += self.process_field(
                    table_schema, field_name, pk_schema
                ).only_columns()

                if nullable:
                    result.make_all_nullable()

                result.members.append(
                    sql.ForeignKeyConstraint(
                        [field_name], foreign_table_name, [pk_db_name]
                    )
                )
            case Schema.ObjSchema():
                for subfield2 in field_schema.fields:
                    if skip_field_name is not None and subfield2.name == skip_field_name:
                        continue

                    combined_name = field_prefix + subfield2.db_name
                        
                    field_result = self.process_field(
                        table_schema, combined_name, subfield2.schema,
                    )

                    result += field_result

                if isinstance(field_schema, Schema.RPGVariantObjSchema):
                    for variant in field_schema.variants:
                        self.process_variant(
                            table_schema, table_schema, variant, field_schema.discriminant
                        )
            case Schema.TableSchema():
                self.process_table_schema(field_schema, table_schema)
            case _:
                assert False

        return result

    def process_variant(
        self, base_table: sql.TableSchema, parent_table: sql.TableSchema, variant: Schema.Variant,
        discriminant: Schema.Field
    ) -> None:

        variant_db_name = camel_case_to_snake(variant.name)
        table_name = f'{parent_table.name}_{variant_db_name}'
        
        table_schema = sql.TableSchema(
            table_name, base_table.members.copy()
        )

        for field in variant.fields:
            table_schema += self.process_field(
                table_schema, field.db_name, field.schema,
            )

        if isinstance(variant, Schema.ComplexVariant):
            for subvariant in variant.variants:
                self.process_variant(
                    base_table, table_schema, subvariant, variant.subdiscriminant
                )
        
        self.add_table(table_schema)

def generate_schema() -> DBSchema:
    result = DBSchema()

    for file_schema in rpgxp_schema.FILES:
        result.process_file_schema(file_schema)

    return result

def generate_script() -> str:
    return str(generate_schema().script)

def run() -> None:
    material.generate_db_schema()
    script = generate_script()
    schema_path = settings.project_root / 'sql/schema.sql'

    with schema_path.open('w') as f:
        f.write(script)

    connection = db.connect()
    connection.pragma('foreign_keys', False)

    with connection:
        connection.execute(script)
