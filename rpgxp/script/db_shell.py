import apsw.shell
from rpgxp import db

connection = db.connect()
apsw.shell.Shell(db=connection).cmdloop()