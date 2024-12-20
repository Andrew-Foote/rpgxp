from abc import ABC, abstractmethod
from dataclasses import dataclass, field
import importlib.resources
import io
from pathlib import Path
import random
import re
from typing import Any, Iterator, Self
import numpy as np
from rpgxp import db, material, parse, settings, sql
from rpgxp.generate_db_schema import DBSchema, generate_schema
from rpgxp.schema import rpgxp_schema, Schema
from rpgxp.util import camel_case_to_snake

def process_field(
    field_value: Any, col_name: str,
    field_schema: Schema.DataSchema,
    parent_refs: dict[str, Any],
    table_schema: sql.TableSchema,
    db_schema: DBSchema,
    skip_field_name: str | None=None,
) -> tuple[dict[str, Any], sql.Script]:

    row_result: dict[str, Any] = {}
    script_result = sql.Script([])

    if col_name == '':
        col_name = 'content'
        col_prefix = ''
    else:
        col_prefix = col_name + '_'

    match field_schema:
        case (
            Schema.BoolSchema() | Schema.IntBoolSchema() | Schema.IntSchema()
            | Schema.FloatSchema() | Schema.StrSchema() | Schema.ZlibSchema()
        ):
            row_result = {col_name: field_value}
        case Schema.NDArraySchema():
            stream = io.BytesIO()
            np.save(stream, field_value)
            row_result = {col_name: stream.getvalue()}
        case Schema.EnumSchema(enum_class):
            row_result = {col_name: field_value.value}
        case Schema.MaterialRefSchema():
            if field_value == '':
                field_value = None

            row_result = {col_name: field_value}
        case Schema.FKSchema(foreign_schema_thunk, nullable):
            foreign_schema = foreign_schema_thunk()
            foreign_pk_schema = foreign_schema.pk_schema()

            if nullable:
                # could add something to configure what values stand for null
                # but cba
                match foreign_pk_schema:
                    case Schema.IntSchema():
                        if field_value == 0:
                            field_value = None
                    case Schema.StrSchema():
                        if field_value == '':
                            field_value = None

            row_result, script_result = process_field(
                field_value, col_name, foreign_pk_schema,
                parent_refs, table_schema, db_schema
            )

        case Schema.ObjSchema():
            for subfield in field_schema.fields:
                if (
                    skip_field_name is not None
                    and subfield.name == skip_field_name
                ):
                    continue

                combined_name = col_prefix + subfield.db_name

                subfield_value = getattr(field_value, subfield.name) 

                field_row_result, field_script_result = process_field(
                    subfield_value, combined_name, subfield.schema,
                    parent_refs, table_schema, db_schema
                )

                row_result |= field_row_result
                script_result += field_script_result

            if isinstance(field_schema, Schema.RPGVariantObjSchema):
                vscript_result = process_variant(
                    field_value, field_schema.discriminant,
                    field_schema.variants,
                    parent_refs, table_schema, db_schema
                )

                script_result += vscript_result
        case Schema.TableSchema():
            # suppose this is the ListSchema for map events
            # in this case the field value is a list of events
            # the relevant parent refs are { map_id : <mapid> }
            # which'll have to be passeed in from above

            script_result = process_table_schema(
                field_schema, field_value,
                db_schema, parent_refs, parent_table=table_schema
            )
        case _:
            assert False

    return row_result, script_result

def process_variant(
    obj: Any,
    discriminant: Schema.Field,
    variants: list[Schema.Variant],
    parent_refs: dict[str, Any],
    table_schema: sql.TableSchema,
    db_schema: DBSchema,
) -> sql.Script:

    discriminant_value = getattr(obj, discriminant.name)

    for poss_variant in variants:
        if poss_variant.discriminant_value == discriminant_value:
            variant = poss_variant
            break
    else:
        assert False

    variant_db_name = camel_case_to_snake(variant.name)
    subtable_name = f'{table_schema.name}_{variant_db_name}'
    subtable_schema = db_schema.get_table(subtable_name)
    columns = tuple(subtable_schema.non_generated_columns())
    column_names = tuple(col.name for col in columns)
    column_types = tuple(col.type_ for col in columns)

    new_parent_refs = parent_refs.copy()
    parent_refs_key_to_adjust = list(new_parent_refs)[-1]
    parent_refs_kta_value = new_parent_refs.pop(parent_refs_key_to_adjust)
    parent_refs_key_adjusted = parent_refs_key_to_adjust.removeprefix(f'{table_schema.name}_')
    new_parent_refs[parent_refs_key_adjusted] = parent_refs_kta_value

    parent_refs2 = new_parent_refs.copy()
    pr2val = parent_refs2.pop(parent_refs_key_adjusted)
    parent_refs2[f'{subtable_name}_{parent_refs_key_adjusted}'] = parent_refs_kta_value
    
    row_result: dict[str, Any] = new_parent_refs.copy()
    # hacky_k = list(row_result)[-1]
    # hacky_v = row_result.pop(hacky_k)
    # row_result[hacky_k.removeprefix(f'{table_schema.name}_')] = hacky_v
    # hacky_row_result = row_result.copy()
    # print(row_result)
    script_result = sql.Script([])

    for field in variant.fields:
        combined_name = field.db_name
        #combined_name = col_prefix + field.db_name
        subfield_value = getattr(obj, field.name)

        field_row_result, field_script_result = process_field(
            subfield_value, combined_name, field.schema,
            parent_refs2, subtable_schema, db_schema
        )

        row_result |= field_row_result
        script_result += field_script_result

    if isinstance(variant, Schema.ComplexVariant):
        vscript_result = process_variant(
            obj, variant.subdiscriminant, variant.variants,
            new_parent_refs, subtable_schema, db_schema
        )

        script_result += vscript_result

    array_row = []

    for column in column_names:
        if column not in row_result:
            raise RuntimeError(f'{column} not in {row_result} [{variant}, {subtable_schema}]')

        array_row.append(row_result[column])

    insert = sql.InsertStatement(
        subtable_name, column_names, column_types, [tuple(array_row)]
    )

    return sql.Script([insert]) + script_result

def process_table_schema(
    table_schema: Schema.TableSchema, data: Any,
    db_schema: DBSchema, parent_refs: dict[str, Any],
    parent_table: sql.TableSchema | None=None
) -> sql.Script:

    result = sql.Script([])

    parent_table_name = '' if parent_table is None else parent_table.name

    table_name = table_schema.table_name.substitute({
        'prefix': parent_table_name + '_'
    })

    db_table_schema = db_schema.get_table(table_name)
    columns = tuple(db_table_schema.non_generated_columns())
    column_names = tuple(col.name for col in columns)
    column_types = tuple(col.type_ for col in columns)
    rows: list[dict[str, Any]] = []

    match table_schema:
        case Schema.ListSchema(
            _, item_schema, item_name=item_name,
            first_item=first_item,
            index=index_behavior
        ):
            assert isinstance(data, list)

            for raw_index, item in enumerate(data):
                row: dict[str, Any] = {}
                row |= parent_refs

                min_index = 0 if first_item is Schema.FirstItem.REGULAR else 1
                index = raw_index + min_index

                match index_behavior:
                    case Schema.AddIndexColumn(index_col_name):
                        row_result, script_result = process_field(
                            index, index_col_name, Schema.IntSchema(),
                            parent_refs, db_table_schema, db_schema
                        )

                        row |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{index_col_name}': index}
                    case Schema.MatchIndexToField(pk_field_name):
                        assert isinstance(item_schema, Schema.ObjSchema)
                        pk_field = item_schema.get_field(pk_field_name)
                        pk_field_name = pk_field.name
                        pk_col_name = pk_field.db_name

                        row_result, script_result = process_field(
                            index, pk_col_name, pk_field.schema, parent_refs,
                            db_table_schema, db_schema
                        )

                        row |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{pk_col_name}': index}
                    case _:
                        assert False

                row_result, script_result = process_field(
                    item, item_name, item_schema, parent_refs_for_row,
                    db_table_schema, db_schema
                )

                row |= row_result
                result += script_result
                rows.append(row)

        case Schema.SetSchema(_, item_schema, item_name):
            assert isinstance(data, set)

            for item in data:
                row2: dict[str, Any] = {}
                row2 |= parent_refs

                row_result, script_result = process_field(
                    item, item_name, item_schema, parent_refs,
                    db_table_schema, db_schema
                )

                row2 |= row_result
                result += script_result

                rows.append(row2)

        case Schema.DictSchema(_, key_behavior, value_schema, value_name):
            assert isinstance(data, dict)
            pk_field_name2: str | None=None

            for key, value in data.items():
                row3: dict[str, Any] = {}
                row3 |= parent_refs

                match key_behavior:
                    case Schema.AddKeyColumn(key_col_name, key_schema):
                        row_result, script_result = process_field(
                            key, key_col_name, key_schema, parent_refs,
                            db_table_schema, db_schema
                        )

                        row3 |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{key_col_name}': key}
                    case Schema.MatchKeyToField(pk_field_name):
                        pk_field = value_schema.get_field(pk_field_name)
                        pk_field_name2 = pk_field.name
                        pk_col_name2 = pk_field.db_name

                        row_result, script_result = process_field(
                            key, pk_col_name2, pk_field.schema, parent_refs,
                            db_table_schema, db_schema
                        )

                        row3 |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{pk_col_name2}': key}
                    case _:
                        assert False

                row_result, script_result = process_field(
                    value, value_name, value_schema, parent_refs_for_row,
                    db_table_schema, db_schema
                )

                row3 |= row_result
                result += script_result

                rows.append(row3)

        case Schema.RPGSingletonObjSchema(_, _, _, fields):
            assert not parent_refs
            row4: dict[str, Any] = {}
            row4 |= {'id': 0}

            for field in fields:
                field_value = getattr(data, field.name)
                row_result, script_result = process_field(
                    field_value, field.db_name, field.schema, parent_refs,
                    db_table_schema, db_schema
                )

                row4 |= row_result
                result += script_result

            rows.append(row4)

        case _:
            assert False

    if rows:
        array_rows: list[tuple] = []

        for row in rows:
            array_row = []

            for column in column_names:
                if column not in row:
                    raise RuntimeError(f'{column} not in {row}')

                array_row.append(row[column])

            array_rows.append(tuple(array_row))

        result.statements.append(sql.InsertStatement(
            table_name, column_names, column_types, array_rows
        ))

    return result

def process_file_schema(
    file_schema: Schema.FileSchema, *, data_root: Path, db_schema: DBSchema,
    quick: bool=False
) -> sql.Script:

    match file_schema:
        case Schema.SingleFileSchema(filename, content_schema):
            print(f'processing {filename}')
            parsed_content = parse.parse_filename(filename, data_root)

            return process_table_schema(
                content_schema, parsed_content, db_schema, {}
            )
        case Schema.MultipleFilesSchema(pattern, table_name, keys, content_schema):
            db_table_schema = db_schema.get_table(table_name)

            result = sql.Script()
            rows: list[dict[str, Any]] = []
            files: list[tuple[tuple, str]] = []

            for path in sorted(data_root.iterdir(), key=lambda p: p.name):
                filename = path.name
                m = re.match(pattern, filename)

                if m is not None:
                    files.append((m.groups(), filename))

            if quick:
                files = random.sample(files, 25)

            for key_values, filename in files:
                # if filename != 'Map593.rxdata':
                #     continue

                print(f'processing {filename}')

                row: dict[str, Any] = {}

                assert len(keys) == len(key_values)

                for key, key_value in zip(keys, key_values):
                    match key.schema:
                        case Schema.BoolSchema():
                            key_value = bool(key_value)
                        case Schema.IntSchema():
                            key_value = int(key_value)
                        case Schema.FloatSchema():
                            key_value = float(key_value)
                        case _:
                            raise RuntimeError('bad')

                    row_result, script_result = process_field(
                        key_value, key.db_name, key.schema, {},
                        db_table_schema, db_schema
                    )

                    row |= row_result
                    result += script_result

                data = parse.parse_filename(filename, data_root)

                parent_refs = {
                    f'{table_name}_{key_name}': key_value
                    for key_name, key_value in row.items()
                }

                row_result, script_result = process_field(
                    data, '', content_schema, parent_refs,
                    db_table_schema, db_schema
                )

                row |= row_result
                result += script_result
                rows.append(row)

            if rows:
                columns = tuple(db_schema.get_table(table_name).non_generated_columns())
                column_names = tuple(col.name for col in columns)
                column_types = tuple(col.type_ for col in columns)

                array_rows: list[tuple] = []

                for row in rows:
                    array_row = []

                    for column in column_names:
                        if column not in row:
                            raise RuntimeError(f'{column} not in {row}')

                        array_row.append(row[column])

                    array_rows.append(tuple(array_row))

                result.statements.append(sql.InsertStatement(
                    table_name, column_names, column_types, array_rows
                ))

            return result
        case _:
            assert False, file_schema

def generate_script(*, db_schema: DBSchema, quick: bool=False) -> str:
    data_root = settings.game_data_root
    result = sql.Script()

    for file_schema in rpgxp_schema.FILES:
        result += process_file_schema(
            file_schema, data_root=data_root, db_schema=db_schema, quick=quick
        )

    return str(result.with_truncation())

def run(*, quick: bool=False) -> None:
    material.generate_db_data()

    db_schema = generate_schema()
    script = generate_script(db_schema=db_schema, quick=quick)

    with open(settings.db_root / 'db_data.sql', 'w') as f:
        f.write(script)

    connection = db.connect()
    connection.pragma('foreign_keys', False)

    with connection:
        connection.execute(script)
