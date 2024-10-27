from abc import ABC, abstractmethod
from dataclasses import dataclass, field
import re
from typing import Iterator, Self
import rpgxp.schema_v2 as schema

def camel_case_to_snake(s: str) -> str:
	return re.sub(r'(?<=.)(?=[A-Z])', '_', s).lower()

@dataclass
class ColumnSchema:
	name: str
	type_: str
	nullable: bool=False
	default: str=''
	collate: str=''
	pk: bool=False

	def __str__(self) -> str:		
		result = f'"{self.name}" {self.type_}'

		if not self.nullable:
			result += ' NOT NULL'

		if self.default:
			result += f' DEFAULT {self.default}'

		if self.collate:
			result += f' COLLATE {self.collate}'

		return result

@dataclass
class TableConstraint(ABC):
	@abstractmethod
	def __str__(self) -> str:
		...

@dataclass
class UniqueConstraint(TableConstraint):
	columns: list[str]

	def __str__(self) -> str:
		columns_csv = ', '.join(f'"{column}"' for column in self.columns)
		return f'UNIQUE ({columns_csv})'

@dataclass
class CheckConstraint(TableConstraint):
	expr: str

	def __str__(self) -> str:
		return f'CHECK ({self.expr})'

@dataclass
class ForeignKeyConstraint(TableConstraint):
	columns: list[str]
	referenced_table: str
	referenced_columns: list[str]

	def inline_string(self) -> str:
		referenced_columns_csv = ', '.join(f'"{column}"' for column in self.referenced_columns)
		return f'REFERENCES "{self.referenced_table}" ({referenced_columns_csv})'

	def __str__(self) -> str:
		columns_csv = ', '.join(f'"{column}"' for column in self.columns)
		referenced_columns_csv = ', '.join(f'"{column}"' for column in self.referenced_columns)
		
		return ' '.join([
			f'FOREIGN KEY ({columns_csv}) ',
			f'REFERENCES "{self.referenced_table}"',
			f'({referenced_columns_csv})'
		])

@dataclass
class PendingFK:
	field_name: str
	schema: FKSchema

@dataclass
class TableSchema:
	name: str
	
	members: list[
		ColumnSchema | TableConstraint | PendingFK
	] = field(default_factory=lambda: [])
	
	# columns: list[ColumnSchema] = field(default_factory=lambda: [])
	# constraints: list[TableConstraint] = field(default_factory=lambda: [])
	singleton: bool=False
	# pending_fks: list[tuple[str, schema.FKSchema]]=field(default_factory=lambda: [])

	def columns(self) -> Iterator[ColumnSchema]:
		for member in self.members:
			if isinstance(member, ColumnSchema):
				yield member

	def constraints(self) -> Iterator[TableConstraint]:
		for member in self.members:
			if isinstance(member, TableConstraint):
				yield member

	def pending_fks(self) -> Iterator[PendingFK]:
		for member in self.members:
			if isinstance(member, PendingFK):
				yield member

	def pk(self) -> list[ColumnSchema]:
		return [col for col in self.columns() if col.pk]

	def __str__(self) -> str:
		column_decls: list[str] = []
		constraint_decls: list[str] = []
		pk_columns: list[tuple[int, str]] = []

		# sqlite forces us to put all constraints after all columns

		for i, member in enumerate(self.members):
			if isinstance(member, ColumnSchema):
				column_decls.append(str(member))

				if member.pk:
					pk_columns.append((len(column_decls) - 1, member.name))
			elif isinstance(member, UniqueConstraint):
				if len(member.columns) == 1:
					uniq_column = member.columns[0]
					column_index = [c.name for c in self.columns()].index(uniq_column)
					column_decls[column_index] += ' UNIQUE'
				else:
					constraint_decls.append(str(member))
			elif isinstance(member, CheckConstraint):
				column_decls[-1] += ' ' + str(member)
			elif isinstance(member, ForeignKeyConstraint):
				if len(member.columns) == 1:
					fk_column = member.columns[0]
					column_index = [c.name for c in self.columns()].index(fk_column)
					column_decls[column_index] += ' ' + member.inline_string()
				else:
					constraint_decls.append(str(member))

		if not pk_columns:
			raise SchemaError(f'table {self.name} has no primary key')
		elif len(pk_columns) == 1:
			pk_column_index = pk_columns[0][0]
			column_decls[pk_column_index] += ' PRIMARY KEY'
		else:
			pk_columns_csv = ', '.join(f'"{name}"' for _, name in pk_columns)
			constraint_decls.insert(0, f'PRIMARY KEY ({pk_columns_csv})')

		decls_csv = ',\n    '.join(column_decls + constraint_decls)

		return '\n'.join([
			f'CREATE TABLE "{self.name}" (',
		    f'    {decls_csv}',
		    ') WITHOUT ROWID, STRICT;'
		])

	def __add__(self, other: Self) -> Self:
		if other.name != self.name:
			raise ValueError('cannot concatenate table schemas with different names')

		return self.__class__(
			self.name,
			self.members + other.members,
			self.singleton, # self will override other!
		)

	def __iadd__(self, other: Self) -> Self:
		combined = self + other
		self.members = combined.members
		return self

@dataclass
class DBSchema:
	tables: list[TableSchema]=field(default_factory=lambda: [])

	def __str__(self) -> str:
		return '\n\n'.join(map(str, self.tables))

	def has_table(self, name: str) -> bool:
		return any(table.name == name for table in self.tables)

	def get_table(self, name: str) -> TableSchema:
		for table in self.tables:
			if table.name == name:
				return table

		raise ValueError(f'table {name} not found')

	def process_file_schema(self, file_schema: schema.FileSchema) -> None:
		match file_schema:
			case schema.SingleFileSchema(_, content_schema):
				self.process_table_schema(content_schema)
			case schema.MultipleFilesSchema(
				_, table_name, key_column_names, content_schema
			):
				if self.has_table(table_name):
					raise schema.SchemaError(f'{table_name} used twice')

				table_schema = TableSchema(table_name, [
					ColumnSchema(name, 'TEXT', pk=True)
					for name in key_column_names
				])

				self.process_row_schema(table_schema, content_schema)
				self.tables.append(table_schema)
			case _:
				assert False

	def process_row_schema(
		self, table_schema: TableSchema, row_schema: schema.RowSchema
	) -> None:
	
		table_schema += self.process_field(table_schema, '', row_schema)

	def process_table_schema(
		self,
		table_schema: schema.TableSchema,
		parent_table: TableSchema | None=None
	) -> None:
		table_name = table_schema.table_name

		if self.has_table(table_name):
			raise schema.SchemaError(f'{table_name} used twice')

		db_table_schema = TableSchema(table_name)

		if parent_table is not None and parent_table.singleton:
			parent_table = None

		if parent_table is not None:
			parent_pk = parent_table.pk()
			
			cols = [
				ColumnSchema(
					col.name, col.type_, collate=col.collate, pk=True
				)
				for col in parent_pk
			]
			
			cols[-1].name = f'{parent_table.name}_{cols[-1].name}'

			db_table_schema.members.extend(cols)

			db_table_schema.members.append(ForeignKeyConstraint(
				[col.name for col in cols],
				parent_table.name,
				[col.name for col in parent_pk]
			))

		match table_schema:
			case schema.ListSchema(_, item_schema, first_item):
				min_index = 0 if first_item is schema.FirstItem.REGULAR else 1

				db_table_schema.members.extend([
					ColumnSchema('index', 'INTEGER', pk=True),
					CheckConstraint(f'"index" >= {min_index}'),
				])

				self.tables.append(db_table_schema)
				self.process_row_schema(db_table_schema, item_schema)

			case schema.DictSchema(_, key_name, key_schema, value_schema):
				db_key_schema = self.process_field(
					db_table_schema, key_name, key_schema
				)

				for col in db_key_schema.columns():
					col.pk = True

				db_table_schema += db_key_schema
				self.tables.append(db_table_schema)
				self.process_row_schema(db_table_schema, value_schema)

			case schema.RPGSingletonObjSchema(_, class_name, _, fields):
				assert parent_table is None
				db_table_schema.singleton = True

				db_table_schema.members.extend([
					ColumnSchema('id', 'INTEGER', default='0', pk=True),
					CheckConstraint('"id" = 0'),
				])

				for field in fields:
					db_table_schema += self.process_field(
						db_table_schema, field.db_name, field.schema
					)

				self.tables.append(db_table_schema)

	def process_field(
		self,
		table_schema: TableSchema,
		field_name: str,
		field_schema: schema.DataSchema
	) -> TableSchema:

		result: TableSchema = TableSchema(table_schema.name)

		if field_name == '':
			field_name = 'content'
			field_prefix = ''
		else:
			field_prefix = field_name + '_'

		match field_schema:
			case schema.BoolSchema():
				result.members.extend([
					ColumnSchema(field_name, 'INTEGER'),
					CheckConstraint(f'"{field_name}" in (0, 1)'),
				])
			case schema.IntSchema(lb, ub):
				result.members.append(ColumnSchema(field_name, 'INTEGER'))

				if lb is not None and ub is not None:
					result.members.append(CheckConstraint(
						f'"{field_name}" BETWEEN {lb} AND {ub}'
					))
				elif lb is not None:
					result.members.append(CheckConstraint(
						f'"{field_name} >= {lb}'
					))
				elif ub is not None:
					result.members.append(CheckConstraint(
						f'"{field_name} <= {ub}'
					))
			case schema.StrSchema():
				result.members.append(ColumnSchema(field_name, 'TEXT'))
			case schema.ZlibSchema() | schema.NDArraySchema():
				result.members.append(ColumnSchema(field_name, 'BLOB'))
			case schema.EnumSchema(enum_class):
				enum_table_name = camel_case_to_snake(enum_class.__name__)
				result.members.append(ColumnSchema(field_name, 'INTEGER'))

				if not self.has_table(enum_table_name):
					self.tables.append(TableSchema(enum_table_name, [
						ColumnSchema('id', 'INTEGER', pk=True),
						ColumnSchema('name', 'TEXT')
					]))

				result.members.append(ForeignKeyConstraint(
					[field_name], enum_table_name, ['id']
				))
			case schema.FKSchema():
				result.members.append(PendingFK(field_name, field_schema))
			case (
				schema.ArrayObjSchema(_, fields)
				| schema.RPGObjSchema(_, _, fields)
				| schema.RPGSingletonObjSchema(_, _, _, fields)
			):
				for subfield in fields:
					combined_name = field_prefix + subfield.db_name
					
					result += self.process_field(
						table_schema, combined_name, subfield.schema
					)
			case schema.TableSchema():
				self.process_table_schema(field_schema, table_schema)

		return result

	def resolve_fks(self) -> None:
		for table in self.tables:
			for i, member in enumerate(table.members):
				if isinstance(member, PendingFK):
					field_name = member.field_name
					schema = member.schema
					foreign_schema = schema.foreign_schema_thunk()
					nullable = schema.nullable
					foreign_table_name = foreign_schema.table_name
					foreign_table = self.get_table(foreign_table_name)
					foreign_pk = foreign_table.pk()
					assert len(foreign_pk) == 1
					pk_col = foreign_pk[0]

					table.members[i:i + 1] = [
						ColumnSchema(
							field_name, pk_col.type_, collate=pk_col.collate,
							nullable=nullable
						),
						ForeignKeyConstraint(
							[field_name], foreign_table_name, [pk_col.name]
						)
					]

def generate():
	result = DBSchema()

	for s in schema.FILES:
		result.process_file_schema(s)

	result.resolve_fks()

	return str(result)

if __name__ == '__main__':
	print(generate())

# we just need to defer the foreign key resolving