from dataclasses import dataclass
import functools as ft
import json
from pathlib import Path
import apsw
import apsw.bestpractice
from rpgxp import forest, settings
from rpgxp.util import Just

class TreeAgg:
    """Defines the "tree" aggregate function for the database.

    This function can be used to turn an SQL query result into a JSON tree
    structure. It takes three parameters, 'id', 'parent_id', and 'label'. The
    first two parameters determine the structure of the tree by associating
    each row with a parent. The 'parent_id' value may be NULL, in which case
    that means the row has no parent; there can be multiple such rows. The
    returned JSON will have a structure like

        [{"label": <label>, "children": ...}]

    where the labels come from the 'label' parameter. The ordering of adjacent
    nodes will be carried over from the order in which the rows are processed.
    """

    rows: list[forest.Row]

    def __init__(self):
        self.rows = []

    def step(self, *args: apsw.SQLiteValue) -> None:
        assert len(args) == 3
        id_, parent_id, label = args
        maybe_parent_id = None if parent_id is None else Just(parent_id)
        index = len(self.rows)
        self.rows.append(forest.Row(id_, maybe_parent_id, json.loads(str(label))))

    def final(self) -> str:
        return forest.to_json(forest.from_rows(self.rows))

def connect(db_path: Path | None=None) -> apsw.Connection:
    if db_path is None:
        db_path = settings.db_root / 'db.sqlite'

    db_path.parent.mkdir(parents=True, exist_ok=True)
    apsw.bestpractice.apply(apsw.bestpractice.recommended)
    connection = apsw.Connection(str(db_path))
    connection.create_aggregate_function('tree', TreeAgg, numargs=3)
    return connection

def row(cursor: apsw.Cursor) -> tuple[apsw.SQLiteValue, ...]:
    results = cursor.fetchall()
    row_count = len(results)

    if row_count != 1:
        raise RuntimeError(f'got {row_count} rows from query, expected 1')

    return results[0]

def fetch_rows(
    query: str, bindings: apsw.Bindings | None=None,
    *, dbh: apsw.Connection | None=None
) -> list[tuple[apsw.SQLiteValue, ...]]:

    if dbh is None:
        dbh = connect()

    return dbh.execute(query, bindings).fetchall()

def fetch_row(
    query: str, bindings: apsw.Bindings | None=None,
    *, dbh: apsw.Connection | None=None
) -> tuple[apsw.SQLiteValue, ...]:

    rows = fetch_rows(query, bindings, dbh=dbh)
    assert len(rows) == 1
    return rows[0]

def fetch_value(
    query: str, bindings: apsw.Bindings | None=None,
    *, dbh: apsw.Connection | None=None
) -> apsw.SQLiteValue:

    row = fetch_row(query, bindings, dbh=dbh)
    assert len(row) == 1
    return row[0]

def run_script(
    dbh: apsw.Connection,
    script_path: Path,
    bindings: apsw.Bindings | None=None
) -> apsw.Cursor:

    with script_path.open() as script_file:
        script = script_file.read()

    return dbh.execute(script, bindings)

def run_named_query(
    dbh: apsw.Connection,
    query_name: str,
    bindings: apsw.Bindings | None=None
) -> apsw.Cursor:
    
    script_path = settings.project_root / f'sql/{query_name}.sql'
    return run_script(dbh, script_path, bindings)

def foreign_key_report(dbh: apsw.Connection) -> str:
    raw_check = dbh.execute('pragma foreign_key_check').fetchall()
    reports = []

    for table, rowid, parent, fkid in raw_check:
        assert isinstance(table, str)
        assert isinstance(rowid, int)
        assert isinstance(parent, str)
        assert isinstance(fkid, int)

        fk = dbh.execute('\n'.join([
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

        violator_resultset = dbh.execute(
            f'SELECT {fk_cols_csv} FROM "{table}" WHERE "rowid" = {rowid}'
        ).fetchall()

        assert len(violator_resultset) == 1
        violator, = violator_resultset

        pk_cols_resultset = dbh.execute(
            f'SELECT "name" from pragma_table_info(\'{table}\') WHERE "pk" = 1'
        ).fetchall()

        pk_cols = []

        for col, in pk_cols_resultset:
            assert isinstance(col, str)
            pk_cols.append(col)

        pk_cols_csv = ', '.join([f'"{col}"' for col in pk_cols])

        pk_vals_resultset = dbh.execute(
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