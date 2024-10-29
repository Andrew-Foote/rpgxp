from rpgxp import db

connection = db.connect()
print(db.foreign_key_report(connection))