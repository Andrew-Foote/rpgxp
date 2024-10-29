from rpgxp import db

def run():
	connection = db.connect()
	print(db.foreign_key_report(connection))#

if __name__ == '__main__':
	run()