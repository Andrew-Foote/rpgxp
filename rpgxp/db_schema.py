from dataclasses import dataclass, field, Field, fields, is_dataclass
from enum import Enum
import re
from typing import Annotated, get_origin, get_args
import numpy as np
from rpgxp import schema

def camel_case_to_snake(s: str) -> str:
	return re.sub(r'(?<=.)(?=[A-Z])', '_', s).lower()

def foreign_key_decls(
	col_name: str, foreign_table_name: str, foreign_column_name: str, nullable: bool
) -> str:

	col_decl = f'"{column_name} INTEGER'

	if not nullable:
		col_decl += ' NOT NULL'

	fk_decl = f'FOREIGN KEY ("{column_name}")'
	fk_decl += f' REFERENCES "{foreign_table_name}" ("{foreign_column_name}")'
	return col_decl, fk_decl

@dataclass
class DBSchema:
	tables: dict[str, list[str]]=field(default_factory=lambda: {})
	seeders: list[str]=field(default_factory=lambda: [])

	def __str__(self) -> str:
		statements: list[str] = []

		for table_name, table_schema in self.tables.items():
			statement = f'create table "{table_name}" (\n    {",\n    ".join(table_schema)}\n);'
			statements.append(statement)

		for seeder in self.seeders:
			statements.append(seeder)

		return '\n\n'.join(statements)

	def ensure_file_table_exists(self, row_type: type[schema.RPG], index_col_name: str, index_col_decl: str) -> None:
		table_name = camel_case_to_snake(row_type.__name__)

		if table_name in self.tables:
			return

		if row_type.id_0_is_null:
			index_col_decl += f' CHECK ("{index_col_name} > 0")'

		table_schema = [index_col_decl]
		self.tables[table_name] = table_schema

		for col_field in fields(row_type):
			self.process_field(row_type, col_field, col_field.name)

	def ensure_enum_table_exists(self, enum_type: type[Enum]) -> None:
		table_name = camel_case_to_snake(enum_type.__name__)

		if table_name in self.tables:
			return

		self.tables[table_name] = [
			'"id" INTEGER PRIMARY KEY',
			'"desc" TEXT NOT NULL UNIQUE'
		]

		values = [
			f"({member.value}, '{member.name}')" for member in enum_type
		]

		self.seeders.append(f'''INSERT INTO "{table_name}" ("id", "desc") VALUES
{",\n".join(values)};''')

	def create_item_table(
		self, fld: Field, parent_type: type, key_col_name: str
	) -> None:
	
		table_name = fld.metadata['table_name']

		if table_name in self.tables:
			raise schema.SchemaError(
				f'table name "{table_name}" is used for two different tables'
			)

		parent_table_name = camel_case_to_snake(parent_type.__name__)

		table_schema = [
			f'"{parent_table_name}_id" INTEGER',
			f'"{key_col_name}" INTEGER CHECK ("index" >= 0)',
			f'PRIMARY KEY ("{parent_table_name}_id", "index")',
			f'FOREIGN KEY ("{parent_table_name}_id") REFERENCES "{parent_table_name}" ("id")',
		]

		self.tables[table_name] = table_schema

		item_type = get_args(fld.type)[0]
		origin = get_origin(item_type)
		args = get_args(item_type)

		if (
			origin is None and isinstance(item_type, type)
			and is_dataclass(item_type)
		):
			for subfield in fields(item_type):
				self.process_field(item_type, subfield, subfield.name)
		elif (
			origin is Annotated and args[0] is int
			and isinstance(args[1], schema.RPGBase)
		):
			foreign_type = args[1]
			foreign_name = camel_case_to_snake(foreign_type.__name__)

			table_schema.extend(foreign_key_decls(
				column_name=f'{foreign_name}_id',
				foreign_table_name=f'{foreign_name}',
				foreign_column_name='id',
				nullable=foreign_type.id_0_is_null
			))

	def process_field(
		self, row_type: type, col_field: Field, field_name: str
	) -> None:

		table_name = camel_case_to_snake(row_type.__name__)
		field_name = field_name.rstrip('_')
		field_type = col_field.type
		origin = get_origin(field_type)
		args = get_args(field_type)
		table_schema = self.tables[table_name]

		if field_type is bool:
			table_schema.append(f'"{field_name}" INTEGER NOT NULL CHECK ("{field_name}" in (0, 1))')
		elif field_type is int:
			table_schema.append(f'"{field_name}" INTEGER NOT NULL')
		elif field_type is str:
			table_schema.append(f'"{field_name}" TEXT NOT NULL')
		elif isinstance(field_type, type) and issubclass(field_type, Enum):
			self.ensure_enum_table_exists(field_type)
			table_schema.append(f'"{field_name}_id INTEGER NOT NULL')
			table_schema.append(f'FOREIGN KEY {field_name}_id REFERENCES {field_name} ("id")')
		elif isinstance(field_type, type) and issubclass(field_type, schema.RPG):
			for subfield in fields(field_type):
				combined_name = f'{field_name}_{subfield.name}'
				self.process_field(row_type, subfield, combined_name)
		elif origin is list:
			item_type, = args
			self.create_item_table(col_field, row_type, 'index')
		elif (
			origin is dict and is_dataclass(args[1])
			and get_origin(args[0]) is Annotated and get_args(args[0])[0] is int
			and get_args(args[0])[1] == args[1]
		):
			_, item_type = args
			self.create_item_table(col_field, row_type, 'key')
		elif (
			origin is set and get_origin(args[0]) is Annotated
			and get_args(args[0])[0] is int and is_dataclass(get_args(args[0])[1])
		):
			_, item_type = get_args(args[0])
			foreign_name = camel_case_to_snake(item_type.__name__)
			set_table_name = f'{table_name}_{field_name.removesuffix("_set")}'

			self.tables[set_table_name] = [
				f'"{table_name}_id" INTEGER',
				f'"{foreign_name}_id" INTEGER',
				f'PRIMARY KEY ("{table_name}_id", "{foreign_name}_id")',
				f'FOREIGN KEY ("{table_name}_id") REFERENCES "{table_name}" ("id")',
				f'FOREIGN KEY ("{foreign_name}_id") REFERENCES "{foreign_name}" ("id")',
			]
		elif origin is Annotated:
			base_type = args[0]
			args = args[1:]

			if base_type is int:
				print(args)
				if len(args) == 1 and isinstance(args[0], range):
					lb = args[0].start
					ub = args[0].stop - 1
					table_schema.append(f'{field_name} INTEGER NOT NULL CHECK ("{field_name}" BETWEEN {lb} AND {ub})')
				elif len(args) == 1 and isinstance(args[0], type):
					foreign_type, = args
					foreign_name = camel_case_to_snake(foreign_type.__name__)
					col_decl = f'"{field_name}" INTEGER'

					if not foreign_type.id_0_is_null:
						col_decl += ' NOT NULL'

					table_schema.append(col_decl)
					table_schema.append(f'FOREIGN KEY ("{field_name}") REFERENCES "{foreign_name}" ("id")')
				else:
					breakpoint()
					raise schema.SchemaError(f"invalid field type {field_type}")
			elif base_type is str and isinstance(args[0], schema.ZlibCompressed):
				table_schema.append(f'"{field_name}" TEXT NOT NULL')
			elif base_type is np.ndarray:
				table_schema.append(f'"{field_name}" BLOB NOT NULL')
		else:
			raise schema.SchemaError(f'invalid field type {field_type}')

def generate() -> DBSchema:
	result = DBSchema()

	for filename, type_ in schema.FILES.items():
		# first, determine the table name
		# we want it to be singular, so we use the type name rather than the
		# file name

		origin = get_origin(type_)
		args = get_args(type_)
		row_type: type
		index_col_decl: str

		if (
			isinstance(filename, re.Pattern) and filename.groups == 1
			and is_dataclass(type_) and isinstance(type_, type)
		):
			row_type = type_
			index_col_name = 'number'
			index_col_decl = '"number" INTEGER NOT NULL UNIQUE'
		elif isinstance(filename, str) and isinstance(type_, type) and issubclass(type_, schema.RPG):
			row_type = type_
			index_col_name = 'id'
			index_col_decl = '"id" INTEGER PRIMARY KEY CHECK ("id" = 0) DEFAULT 0'
			assert not row_type.id_0_is_null
		elif (
			isinstance(filename, str) and origin is schema.ListWithFirstItemNull
			and isinstance(args[0], type) and issubclass(args[0], schema.RPG)
		):
			row_type = args[0]
			index_col_name = 'index'
			index_col_decl = f'"index" INTEGER NOT NULL UNIQUE'
			assert row_type.id_0_is_null
		elif isinstance(filename, str) and origin is list and is_dataclass(args[0]):
			row_type, = args
			index_col_name = 'index'
			index_col_decl = '"index" INTEGER NOT NULL UNIQUE'
		elif (
			isinstance(filename, str) and origin is dict
			and get_origin(args[0]) is Annotated
			and get_args(args[0]) == (int, args[1])
			and is_dataclass(args[1])
		):
			_, row_type = args
			index_col_name = 'key'
			index_col_decl = '"key" INTEGER NOT NULL UNIQUE'
		else:
			raise schema.SchemaError(
				"Got a file pattern / type combination that we can't handle: "
				f'{filename}, {type_}'
			)

		result.ensure_file_table_exists(row_type, index_col_name, index_col_decl)

	return result