from pathlib import Path
import subprocess

from rpgxp import (
	generate_classes,
	generate_db_schema,
	generate_db_data
)

from rpgxp.script import foreign_key_report

def run(data_root: Path, *, quick: bool=False):
	print("Generating classes...")
	generate_classes.run()

	print("Typechecking the codebase...")
	subprocess.run(['mypy'])

	print("Generating the database schema...")
	generate_db_schema.run()

	print("Generating the database data...")
	generate_db_data.run(data_root, quick=quick)

	print("Checking foreign keys...")
	foreign_key_report.run()

if __name__ == '__main__':
    import argparse

    arg_parser = argparse.ArgumentParser(
        prog='RPG Maker XP Database',
        description=(
        	'Creates an SQLite database for the data of a game made using RPG '
        	'Maker XP'
        )
    )

    arg_parser.add_argument('data_root', type=Path)
    
    arg_parser.add_argument('-q', '--quick', action='store_true', help=(
    	"avoid processing everything so that the database is generated more "
    	"quickly (but is incomplete); useful for quick iteration when "
    	"developing"
    ))

    parsed_args = arg_parser.parse_args()
    run(parsed_args.data_root, quick=parsed_args.quick)
