from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Iterator, Self
from rpgxp import schema

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
			f'FOREIGN KEY ({columns_csv}) ',
			f'REFERENCES "{self.referenced_table}"',
			f'({referenced_columns_csv})'
		])

@dataclass
class PendingFK:
	field_name: str
	schema: schema.FKSchema
	pk: bool=False

@dataclass
class TableSchema:
	name: str
	
	members: list[
		ColumnSchema | TableConstraint | PendingFK
	] = field(default_factory=lambda: [])
	
	singleton: bool=False

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

	def pk(self) -> list[ColumnSchema | PendingFK]:
		result = [
			m for m in self.members
			if isinstance(m, (ColumnSchema, PendingFK)) and m.pk
		]

		if not result:
			print(self.members)
			raise schema.SchemaError(f'table {self.name} has no PK')

		return result

	def make_all_pks(self) -> None:
		for member in self.members:
			if isinstance(member, (ColumnSchema, PendingFK)):
				member.pk = True

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
			elif isinstance(member, PendingFK):
				raise ValueError(
					"can't stringify table schema with unresolved FKs"
				)

		if not pk_columns:
			raise schema.SchemaError(f'table {self.name} has no primary key')
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
		    ') WITHOUT ROWID, STRICT;'
		])

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

def format_sql_value(value, type_) -> str:
	match type_:
		case 'TEXT':
			value.replace("'", "''")
			return f"'{value}'"
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
class Script:
	statements: list[TableSchema | InsertStatement]=field(default_factory=lambda: [])

	def __str__(self) -> str:
		return '\n\n'.join(map(str, self.statements))
