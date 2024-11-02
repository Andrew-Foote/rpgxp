from pathlib import Path
from rpgxp import db

def run(db_dir: Path):
	dbh = db.connect(db_dir)
	print(db.foreign_key_report(dbh))
