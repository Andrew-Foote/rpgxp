from pathlib import Path
from rpgxp import db

def run(db_dir: Path):
	connection = db.connect(db.get_path(db_dir))
	print(db.foreign_key_report(connection))
