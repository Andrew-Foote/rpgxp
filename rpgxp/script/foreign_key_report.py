from rpgxp import db

def run():
	dbh = db.connect()
	print(db.foreign_key_report(dbh))
