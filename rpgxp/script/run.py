import importlib.resources
from pathlib import Path
import subprocess

from rpgxp import (
	generate_classes,
	generate_db_schema,
	generate_db_data
)

from rpgxp.script import foreign_key_report

def run(data_root: Path, output_dir: Path, *, quick: bool=False):
	print("Generating classes...")
	generate_classes.run()

	print("Typechecking the codebase...")
	mypy_result = subprocess.run(['mypy'])

	if mypy_result.returncode:
		print("Typechecking failed.")
		return

	print("Generating the database schema...")
	generate_db_schema.run(output_dir)

	print("Generating the database data...")
	generate_db_data.run(data_root, output_dir, quick=quick)

	print("Checking foreign keys...")
	foreign_key_report.run(output_dir)

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

    with importlib.resources.path('rpgxp') as base_path:
        arg_parser.add_argument(
            'output_dir', type=Path, default=base_path / 'generated'
        )
    
    arg_parser.add_argument('-q', '--quick', action='store_true', help=(
    	"avoid processing everything so that the database is generated more "
    	"quickly (but is incomplete); useful for quick iteration when "
    	"developing"
    ))

    parsed_args = arg_parser.parse_args()
    run(parsed_args.data_root, parsed_args.output_dir, quick=parsed_args.quick)


