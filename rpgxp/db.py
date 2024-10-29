import apsw
import apsw.bestpractice
import importlib.resources
from pathlib import Path

def connect() -> apsw.Connection:	
    with importlib.resources.path('rpgxp') as base_path:
	    apsw.bestpractice.apply(apsw.bestpractice.recommended)
	    return apsw.Connection(str(base_path / 'generated/rpgxp.sqlite'))

def foreign_key_report(connection: apsw.Connection) -> str:
	raw_check = connection.execute('pragma foreign_key_check').fetchall()
	reports = []

	for table, rowid, parent, fkid in raw_check:
		assert isinstance(table, str)
		assert isinstance(rowid, int)
		assert isinstance(parent, str)
		assert isinstance(fkid, int)

		fk = connection.execute('\n'.join([
			f"SELECT * FROM pragma_foreign_key_list('{table}')",
			f'WHERE "id" = {fkid}',
			f'ORDER BY "seq"',
		])).fetchall()

		assert len(fk) > 0
		fk_cols = []
		ref_cols = []

		for _, _, table_, from_, to, _, _, _ in fk:
			assert isinstance(table, str)
			assert isinstance(from_, str)
			assert isinstance(to, str)
			assert table_ == parent
			fk_cols.append(from_)
			ref_cols.append(to)

		fk_cols_csv = ', '.join([f'"{col}"' for col in fk_cols])
		ref_cols_csv = ', '.join([f'"{col}"' for col in ref_cols])

		fk_string = ' '.join([
			f'FOREIGN KEY ({fk_cols_csv}) ',
			f'REFERENCES "{parent}" ({ref_cols_csv})',
		])

		violator_resultset = connection.execute(
			f'SELECT {fk_cols_csv} FROM "{table}" WHERE "rowid" = {rowid}'
		).fetchall()

		assert len(violator_resultset) == 1
		violator, = violator_resultset

		pk_cols_resultset = connection.execute(
			f'SELECT "name" from pragma_table_info(\'{table}\') WHERE "pk" = 1'
		).fetchall()

		pk_cols = []

		for col, in pk_cols_resultset:
			assert isinstance(col, str)
			pk_cols.append(col)

		pk_cols_csv = ', '.join([f'"{col}"' for col in pk_cols])

		pk_vals_resultset = connection.execute(
			f'SELECT {pk_cols_csv} from "{table}" WHERE "rowid" = {rowid}'
		).fetchall()

		assert len(pk_vals_resultset) == 1
		pk_vals, = pk_vals_resultset

		reports.append('\n'.join([
			f'Foreign key violation in table "{table}"',
			f'  At row with primary key values {pk_vals}',
			f'  FK declaration: {fk_string}',
			f'  FK column values in violating row: {violator}',
		]))

	if not reports:
		return "No foreign key constraint violations found."

	return '\n\n'.join(reports)