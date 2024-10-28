from abc import ABC, abstractmethod
from dataclasses import dataclass, field
import importlib.resources
from typing import Iterator, Self
import apsw
import apsw.bestpractice
from rpgxp import schema
from rpgxp import sql
from rpgxp.util import *

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

	def process_file_schema(self, file_schema: schema.FileSchema) -> None:
		match file_schema:
			case schema.SingleFileSchema(_, content_schema):
				self.process_table_schema(content_schema)
			case schema.MultipleFilesSchema(
				_, table_name, keys, content_schema
			):
				if self.has_table(table_name):
					raise schema.SchemaError(f'{table_name} used twice')

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
		table_schema: schema.TableSchema,
		parent_table: sql.TableSchema | None=None
	) -> None:
		table_name = table_schema.table_name

		if self.has_table(table_name):
			raise schema.SchemaError(f'{table_name} used twice')

		db_table_schema = sql.TableSchema(table_name)
		self.add_table(db_table_schema)

		if parent_table is not None and parent_table.singleton:
			parent_table = None

		if parent_table is not None:
			parent_pk = parent_table.pk()
			cols = []
			referenced_names = []

			for col in parent_pk:
				assert isinstance(col, sql.ColumnSchema)

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
			case schema.ListSchema(
				_, item_schema, first_item=first_item, item_name=item_name,
				index=index_behavior
			):
				pk_field_name: str | None=None

				match index_behavior:
					case schema.AddIndexColumn(index_col_name):
						min_index = (
							0 if first_item is schema.FirstItem.REGULAR
							else 1
						)

						db_table_schema.members.extend([
							sql.ColumnSchema(index_col_name, 'INTEGER', pk=True),
							sql.CheckConstraint(
								f'"{index_col_name}" >= {min_index}'
							),
						])

						pk_col_name = index_col_name
					case schema.MatchIndexToField(pk_field_name):
						assert isinstance(item_schema, schema.ObjSchema)
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

			case schema.SetSchema(_, item_schema, item_name):
				db_member_schema = self.process_field(
					db_table_schema, item_name, item_schema
				)

				db_member_schema.make_all_pks()
				db_table_schema += db_member_schema

			case schema.DictSchema(_, key_behavior, value_schema, value_name):
				pk_field_name2: str | None=None

				match key_behavior:
					case schema.AddKeyColumn(key_col_name, key_schema):
						db_key_schema = self.process_field(
							db_table_schema, key_col_name, key_schema
						)
					case schema.MatchKeyToField(pk_field_name):
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

			case schema.RPGSingletonObjSchema(_, _, _, fields):
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

	def process_row_schema(
		self, table_schema: sql.TableSchema, row_schema: schema.RowSchema
	) -> None:
	
		table_schema += self.process_field(table_schema, '', row_schema)

	# process_field

	# takes in:
	#   an sql table schema
	#   a field name
	#   a field schema
	#   a field name to skip
	#
	# returns a table schema
	# also adds a table schema and an insert, for enums

	# so the output is basically:
	# - a set of declarations for the current table
	# - plus possible additional tables to add

	def process_field(
		self,
		table_schema: sql.TableSchema,
		field_name: str,
		field_schema: schema.DataSchema,
		skip_field_name: str | None=None
	) -> sql.TableSchema:

		result: sql.TableSchema = sql.TableSchema(table_schema.name)

		if field_name == '':
			field_name = 'content'
			field_prefix = ''
		else:
			field_prefix = field_name + '_'

		match field_schema:
			case schema.BoolSchema():
				result.members.extend([
					sql.ColumnSchema(field_name, 'INTEGER'),
					sql.CheckConstraint(f'"{field_name}" in (0, 1)'),
				])
			case schema.IntSchema(lb, ub):
				result.members.append(sql.ColumnSchema(field_name, 'INTEGER'))

				if lb is not None and ub is not None:
					result.members.append(sql.CheckConstraint(
						f'"{field_name}" BETWEEN {lb} AND {ub}'
					))
				elif lb is not None:
					result.members.append(sql.CheckConstraint(
						f'"{field_name} >= {lb}'
					))
				elif ub is not None:
					result.members.append(sql.CheckConstraint(
						f'"{field_name} <= {ub}'
					))
			case schema.FloatSchema(lb, ub):
				result.members.append(sql.ColumnSchema(field_name, 'REAL'))

				if lb is not None and ub is not None:
					result.members.append(sql.CheckConstraint(
						f'"{field_name}" BETWEEN {lb} AND {ub}'
					))
				elif lb is not None:
					result.members.append(sql.CheckConstraint(
						f'"{field_name} >= {lb}'
					))
				elif ub is not None:
					result.members.append(sql.CheckConstraint(
						f'"{field_name} <= {ub}'
					))
			case schema.StrSchema():
				result.members.append(sql.ColumnSchema(field_name, 'TEXT'))
			case schema.ZlibSchema() | schema.NDArraySchema():
				result.members.append(sql.ColumnSchema(field_name, 'BLOB'))
			case schema.EnumSchema(enum_class):
				enum_table_name = camel_case_to_snake(enum_class.__name__)
				result.members.append(sql.ColumnSchema(field_name, 'INTEGER'))

				if not self.has_table(enum_table_name):
					self.add_table(sql.TableSchema(enum_table_name, [
						sql.ColumnSchema('id', 'INTEGER', pk=True),
						sql.ColumnSchema('name', 'TEXT')
					]))

					self.add_insert(sql.InsertStatement(
						enum_table_name,
						('id', 'name'),
						('INTEGER', 'TEXT'),
						[(member.value, member.name) for member in enum_class]
					))

				result.members.append(sql.ForeignKeyConstraint(
					[field_name], enum_table_name, ['id']
				))
			case schema.FKSchema():
				result.members.append(sql.PendingFK(field_name, field_schema))
			case schema.ObjSchema():
				for subfield in field_schema.fields:
					if skip_field_name is not None and subfield.name == skip_field_name:
						# should eb alreay added
						continue

					combined_name = field_prefix + subfield.db_name
						
					field_result = self.process_field(
						table_schema, combined_name, subfield.schema,
						#skip_field_name=skip_field_name
					)

					result += field_result
			case schema.TableSchema():
				self.process_table_schema(field_schema, table_schema)

		return result

	def resolve_fks(self) -> None:
		for table in self.tables():
			for i, member in enumerate(table.members):
				if not isinstance(member, sql.PendingFK):
					continue
				
				field_name = member.field_name
				schema = member.schema
				foreign_schema = schema.foreign_schema_thunk()
				nullable = schema.nullable
				foreign_table_name = foreign_schema.table_name
				foreign_table = self.get_table(foreign_table_name)
				foreign_pk = foreign_table.pk()
				assert len(foreign_pk) == 1
				pk_col = foreign_pk[0]
				assert isinstance(pk_col, sql.ColumnSchema)

				table.members[i:i + 1] = [
					sql.ColumnSchema(
						field_name, pk_col.type_, collate=pk_col.collate,
						nullable=nullable, pk=member.pk
					),
					sql.ForeignKeyConstraint(
						[field_name], foreign_table_name, [pk_col.name]
					)
				]

def generate_script() -> str:
	result = DBSchema()

	for file_schema in schema.FILES:
		result.process_file_schema(file_schema)

	result.resolve_fks()
	return str(result.script)

def run() -> None:
	script = generate_script()

	with importlib.resources.path('rpgxp') as base_path:
		with open(base_path / 'generated/db_schema.sql', 'w') as f:
			f.write(script)

		apsw.bestpractice.apply(apsw.bestpractice.recommended)
		connection = apsw.Connection(str(base_path / 'generated/rpgxp.sqlite'))

		with connection:
			connection.execute(script)

if __name__ == '__main__':
	run()
