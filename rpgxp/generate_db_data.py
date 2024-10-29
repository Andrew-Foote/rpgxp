from abc import ABC, abstractmethod
from dataclasses import dataclass, field
import importlib.resources
import io
from pathlib import Path
import random
import re
from typing import Any, Iterator, Self
import numpy as np
from rpgxp import db, parse, schema, sql
from rpgxp.generate_db_schema import DBSchema, generate_schema

def process_field(
    field_value: Any, col_name: str,
    field_schema: schema.DataSchema,
    parent_refs: dict[str, Any],
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
            schema.BoolSchema() | schema.IntSchema() | schema.FloatSchema()
            | schema.StrSchema() | schema.ZlibSchema()
        ):
            row_result = {col_name: field_value}
        case schema.NDArraySchema():
            stream = io.BytesIO()
            np.save(stream, field_value)
            row_result = {col_name: stream.getvalue()}
        case schema.EnumSchema(enum_class):
            row_result = {col_name: field_value.value}
        case schema.FKSchema(foreign_schema_thunk, nullable):
            foreign_schema = foreign_schema_thunk()
            foreign_pk_schema = foreign_schema.pk_schema()

            if nullable:
                # could add something to configure what values stand for null
                # but cba
                match foreign_pk_schema:
                    case schema.IntSchema():
                        if field_value == 0:
                            field_value = None
                    case schema.StrSchema():
                        if field_value == '':
                            field_value = None

            row_result, script_result = process_field(
                field_value, col_name, foreign_pk_schema,
                parent_refs, db_schema
            )

        case schema.ObjSchema():
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
                    parent_refs, db_schema
                )

                row_result |= field_row_result
                script_result += field_script_result
        case schema.TableSchema():
            # suppose this is the ListSchema for map events
            # in this case the field value is a list of events
            # the relevant parent refs are { map_id : <mapid> }
            # which'll have to be passeed in from above

            script_result = process_table_schema(
                field_schema, field_value,
                db_schema, parent_refs
            )
        case _:
            assert False

    return row_result, script_result

def process_table_schema(
    table_schema: schema.TableSchema, data: Any,
    db_schema: DBSchema, parent_refs: dict[str, Any]
) -> sql.Script:

    result = sql.Script([])

    table_name = table_schema.table_name
    columns = tuple(db_schema.get_table(table_name).columns())
    column_names = tuple(col.name for col in columns)
    column_types = tuple(col.type_ for col in columns)
    rows: list[dict[str, Any]] = []

    match table_schema:
        case schema.ListSchema(
            _, item_schema, item_name=item_name,
            first_item=first_item,
            index=index_behavior
        ):
            assert isinstance(data, list)

            for raw_index, item in enumerate(data):
                row: dict[str, Any] = {}
                row |= parent_refs

                min_index = 0 if first_item is schema.FirstItem.REGULAR else 1
                index = raw_index + min_index

                match index_behavior:
                    case schema.AddIndexColumn(index_col_name):
                        row_result, script_result = process_field(
                            index, index_col_name,
                            schema.IntSchema(), parent_refs, db_schema
                        )

                        row |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{index_col_name}': index}
                    case schema.MatchIndexToField(pk_field_name):
                        assert isinstance(item_schema, schema.ObjSchema)
                        pk_field = item_schema.get_field(pk_field_name)
                        pk_field_name = pk_field.name
                        pk_col_name = pk_field.db_name

                        row_result, script_result = process_field(
                            index, pk_col_name,
                            pk_field.schema, parent_refs,
                            db_schema
                        )

                        row |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{pk_col_name}': index}
                    case _:
                        assert False

                row_result, script_result = process_field(
                    item, item_name, item_schema, parent_refs_for_row, db_schema
                )

                row |= row_result
                result += script_result
                rows.append(row)

        case schema.SetSchema(_, item_schema, item_name):
            assert isinstance(data, set)

            for item in data:
                row2: dict[str, Any] = {}
                row2 |= parent_refs

                row_result, script_result = process_field(
                    item, item_name, item_schema, parent_refs, db_schema
                )

                row2 |= row_result
                result += script_result

                rows.append(row2)

        case schema.DictSchema(_, key_behavior, value_schema, value_name):
            assert isinstance(data, dict)
            pk_field_name2: str | None=None

            for key, value in data.items():
                row3: dict[str, Any] = {}
                row3 |= parent_refs

                match key_behavior:
                    case schema.AddKeyColumn(key_col_name, key_schema):
                        row_result, script_result = process_field(
                            key, key_col_name, key_schema, parent_refs,
                            db_schema
                        )

                        row3 |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{key_col_name}': key}
                    case schema.MatchKeyToField(pk_field_name):
                        pk_field = value_schema.get_field(pk_field_name)
                        pk_field_name2 = pk_field.name
                        pk_col_name2 = pk_field.db_name

                        row_result, script_result = process_field(
                            key, pk_col_name2, pk_field.schema, parent_refs,
                            db_schema
                        )

                        row3 |= row_result
                        result += script_result

                        parent_refs_for_row = parent_refs | {f'{table_name}_{pk_col_name2}': key}
                    case _:
                        assert False

                row_result, script_result = process_field(
                    value, value_name, value_schema, parent_refs_for_row,
                    db_schema
                )

                row3 |= row_result
                result += script_result

                rows.append(row3)

        case schema.RPGSingletonObjSchema(_, _, _, fields):
            assert not parent_refs
            row4: dict[str, Any] = {}
            row4 |= {'id': 0}

            for field in fields:
                field_value = getattr(data, field.name)
                row_result, script_result = process_field(
                    field_value, field.db_name, field.schema, parent_refs,
                    db_schema
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
    file_schema: schema.FileSchema, *, data_root: Path, db_schema: DBSchema,
    quick: bool=False
) -> sql.Script:

    match file_schema:
        case schema.SingleFileSchema(filename, content_schema):
            print(f'processing {filename}')
            parsed_content = parse.parse_filename(filename, data_root)

            return process_table_schema(
                content_schema, parsed_content, db_schema, {}
            )
        case schema.MultipleFilesSchema(pattern, table_name, keys, content_schema):
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
                print(f'processing {filename}')

                row: dict[str, Any] = {}

                assert len(keys) == len(key_values)

                for key, key_value in zip(keys, key_values):
                    match key.schema:
                        case schema.BoolSchema():
                            key_value = bool(key_value)
                        case schema.IntSchema():
                            key_value = int(key_value)
                        case schema.FloatSchema():
                            key_value = float(key_value)
                        case _:
                            raise RuntimeError('bad')

                    row_result, script_result = process_field(
                        key_value, key.db_name, key.schema, {}, db_schema
                    )

                    row |= row_result
                    result += script_result

                data = parse.parse_filename(filename, data_root)

                parent_refs = {
                    f'{table_name}_{key_name}': key_value
                    for key_name, key_value in row.items()
                }

                row_result, script_result = process_field(
                    data, '', content_schema, parent_refs, db_schema
                )

                row |= row_result
                result += script_result
                rows.append(row)

            if rows:
                columns = tuple(db_schema.get_table(table_name).columns())
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
            assert False

def generate_script(
    data_root: Path, *, db_schema: DBSchema, quick: bool=False
) -> str:
    result = sql.Script()

    for file_schema in schema.FILES:
        
        result += process_file_schema(
            file_schema, data_root=data_root, db_schema=db_schema, quick=quick
        )

    return str(result.with_truncation())

def run(data_root: Path, *, quick: bool=False) -> None:
    db_schema = generate_schema()
    script = generate_script(data_root, db_schema=db_schema, quick=quick)

    with importlib.resources.path('rpgxp') as base_path:
        with open(base_path / 'generated/db_data.sql', 'w') as f:
            f.write(script)

    connection = db.connect()
    connection.pragma('foreign_keys', False)

    with connection:
        connection.execute(script)

if __name__ == '__main__':
    import argparse

    arg_parser = argparse.ArgumentParser(
        prog='RPG Maker XP Data Parser',
        description='Dumps RPG Maker XP data files to an SQLite database'
    )

    arg_parser.add_argument('data_root', type=Path)
    parsed_args = arg_parser.parse_args()
    data_root = parsed_args.data_root
    run(data_root)
