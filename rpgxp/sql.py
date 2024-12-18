from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Iterator, Self

class SQLType(Enum):
	NULL = 0
	INTEGER = 1
	REAL = 2
	TEXT = 3
	BLOB = 4

def python_type_to_sql(t: type) -> SQLType:
	if issubclass(t, type(None)):
		return SQLType.NULL
	elif issubclass(t, int):
		return SQLType.INTEGER
	elif issubclass(t, float):
		return SQLType.REAL
	elif issubclass(t, str):
		return SQLType.TEXT
	elif issubclass(t, bytes):
		return SQLType.BLOB
	else:
		raise ValueError(f'cannot convert Python type {t} to SQL')

@dataclass
class ColumnSchema:
	name: str
	type_: str
	nullable: bool=False
	default: str=''
	collate: str=''
	pk: bool=False
	generated_as: str=''

	def __str__(self) -> str:		
		result = f'"{self.name}" {self.type_}'

		if not self.nullable:
			result += ' NOT NULL'

		if self.default:
			result += f' DEFAULT {self.default}'

		if self.collate:
			result += f' COLLATE {self.collate}'

		if self.generated_as:
			result += f' GENERATED ALWAYS AS ({self.generated_as})'

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
		referenced_columns_csv = ', '.join(
			f'"{column}"' for column in self.referenced_columns
		)

		return ' '.join([
			f'REFERENCES "{self.referenced_table}"',
			f'({referenced_columns_csv})',
		])

	def __str__(self) -> str:
		columns_csv = ', '.join(f'"{column}"' for column in self.columns)
		
		referenced_columns_csv = ', '.join(
			f'"{column}"' for column in self.referenced_columns
		)
		
		return ' '.join([
			f'FOREIGN KEY ({columns_csv})',
			f'REFERENCES "{self.referenced_table}"',
			f'({referenced_columns_csv})'
		])

@dataclass
class TableSchema:
	name: str
	
	members: list[
		ColumnSchema | TableConstraint
	] = field(default_factory=lambda: [])
	
	singleton: bool=False

	def columns(self) -> Iterator[ColumnSchema]:
		for member in self.members:
			if isinstance(member, ColumnSchema):
				yield member

	def non_generated_columns(self) -> Iterator[ColumnSchema]:
		for column in self.columns():
			if not column.generated_as:
				yield column

	def only_columns(self) -> Self:
		return self.__class__(
			self.name,
			list(self.columns()),
			self.singleton
		)

	def constraints(self) -> Iterator[TableConstraint]:
		for member in self.members:
			if isinstance(member, TableConstraint):
				yield member

	def pk(self) -> list[ColumnSchema]:
		result = [
			m for m in self.members
			if isinstance(m, ColumnSchema) and m.pk
		]

		if not result:
			print(self.members)
			raise ValueError(f'table {self.name} has no PK')

		return result

	def make_all_pks(self) -> None:
		for member in self.members:
			if isinstance(member, ColumnSchema):
				member.pk = True

	def make_all_nullable(self) -> None:
		for member in self.members:
			if isinstance(member, ColumnSchema):
				member.nullable = True

	def set_pk(self, pk_col_names: set[str]) -> None:
		found_names = set()

		for member in self.members:
			if isinstance(member, ColumnSchema):
				if member.name in pk_col_names:
					member.pk = True
					found_names.add(member.name)
				else:
					member.pk = False

		if found_names != pk_col_names:
			raise ValueError(
				"can't set primary key to include "
				f"{', '.join(pk_col_names - found_names)} because these "
				"columns don't exist"
			)

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
					
					column_index = [
						c.name for c in self.columns()
					].index(uniq_column)
					
					column_decls[column_index] += ' UNIQUE'
				else:
					constraint_decls.append(str(member))
			elif isinstance(member, CheckConstraint):
				column_decls[-1] += ' ' + str(member)
			elif isinstance(member, ForeignKeyConstraint):
				if len(member.columns) == 1:
					fk_column = member.columns[0]
					
					column_index = [
						c.name for c in self.columns()
					].index(fk_column)
					
					column_decls[column_index] += ' ' + member.inline_string()
				else:
					constraint_decls.append(str(member))

		if not pk_columns:
			pass#raise schema.SchemaError(f'table {self.name} has no primary key')
		elif len(pk_columns) == 1:
			pk_column_index = pk_columns[0][0]
			column_decls[pk_column_index] += ' PRIMARY KEY'
		else:
			pk_columns_csv = ', '.join(f'"{name}"' for _, name in pk_columns)
			constraint_decls.insert(0, f'PRIMARY KEY ({pk_columns_csv})')

		decls_csv = ',\n    '.join(column_decls + constraint_decls)

		return '\n'.join([
			f'DROP TABLE IF EXISTS "{self.name}";',
			f'CREATE TABLE "{self.name}" (',
		    f'    {decls_csv}',
		    ') STRICT;'
		])
		
		# one reason to not do WITHOUT ROWID here is that the foreign_key_check
		# pragma doesn't identify the rows that failed the check by any means
		# other than their rowids

	def __add__(self, other: Self) -> Self:
		if other.name != self.name:
			raise ValueError(
				'cannot concatenate table schemas with different names'
			)

		return self.__class__(
			self.name,
			self.members + other.members,
			self.singleton, # self will override other!
		)

	def __iadd__(self, other: Self) -> Self:
		combined = self + other
		self.members = combined.members
		return self

def format_sql_value(value: Any, type_: str) -> str:
	if value is None:
		return 'NULL'

	match type_:
		case 'TEXT':
			assert isinstance(value, str)
			value = value.replace("'", "''")
			return f"'{value}'"
		case 'BLOB':
			assert isinstance(value, bytes)
			hexbytes = ''.join(hex(byte)[2:].zfill(2) for byte in value)
			return f"x'{hexbytes}'"
		case _:
			return str(value)

@dataclass
class InsertStatement:
	table_name: str
	columns: tuple[str, ...]
	column_types: tuple[str, ...]
	rows: list[tuple]

	def __str__(self) -> str:
		columns_csv = ', '.join(f'"{col}"' for col in self.columns)

		formatted_rows = []

		for row in self.rows:
			formatted_cells = []

			for type_, cell in zip(self.column_types, row):
				formatted_cell = format_sql_value(cell, type_)
				formatted_cells.append(formatted_cell)

			cells_csv = ', '.join(formatted_cells)
			formatted_rows.append(f'({cells_csv})')

		rows_csv = ',\n    '.join(formatted_rows)

		return '\n'.join([
			f'INSERT INTO "{self.table_name}" ({columns_csv}) VALUES',
			f'    {rows_csv};'
		])

@dataclass
class DeleteStatement:
	table_name: str

	def __str__(self) -> str:
		return f'DELETE FROM "{self.table_name}";'

@dataclass
class Script:
	statements: list[TableSchema | InsertStatement | DeleteStatement]=field(default_factory=lambda: [])

	def __str__(self) -> str:
		return '\n\n'.join(map(str, self.statements))

	def __add__(self, other: Self) -> Self:
		return self.__class__(self.statements + other.statements)

	def __iadd__(self, other: Self) -> Self:
		combined = self + other
		self.statements = combined.statements
		return self

	def with_truncation(self) -> Self:
		tables_with_inserts = []
		seen = set()

		for s in self.statements:
			if isinstance(s, InsertStatement):
				table = s.table_name

				if table not in seen:
					tables_with_inserts.append(table)
					seen.add(table)

		deletes = self.__class__([])

		for table in tables_with_inserts:
			deletes.statements.append(DeleteStatement(table))

		return deletes + self