import importlib.resources
from pathlib import Path
import subprocess
from rpgxp.script import foreign_key_report

def run(
	data_root: Path | None, output_dir: Path, *,
	modules_list: list[str], quick: bool
):
	modules = set(modules_list)

	if 'class' in modules:
		print("Generating classes...")
		module = importlib.import_module('rpgxp.generate_classes')
		module.run()

	if 'type' in modules:
		print("Typechecking the codebase...")
		mypy_result = subprocess.run(['sh', 'typecheck'])

		if mypy_result.returncode:
			print("Typechecking failed.")
			return

	if 'schema' in modules:
		print("Generating the database schema...")
		module = importlib.import_module('rpgxp.generate_db_schema')
		module.run(output_dir)

	if 'data' in modules:
		if data_root is None:
			raise ValueError('data_root must be set')

		print("Generating the database data...")
		module = importlib.import_module('rpgxp.generate_db_data')
		module.run(data_root, output_dir, quick=quick)

	if 'fk' in modules:
		print("Checking foreign keys...")
		module = importlib.import_module('rpgxp.script.foreign_key_report')
		module.run(output_dir)

if __name__ == '__main__':
    import argparse

    arg_parser = argparse.ArgumentParser(
        prog='RPG Maker XP Database',
        description=(
        	'Creates an SQLite database for the data of a game made using RPG '
        	'Maker XP'
        )
    )

    arg_parser.add_argument(
    	'-d', '--data_root', type=Path, default=None,
    	help="The path to the game's Data directory"
    )

    with importlib.resources.path('rpgxp') as base_path:
        arg_parser.add_argument(
            '-o', '--output_dir', type=Path, default=base_path / 'generated',
           	help='The directory where the SQLite database will be stored'
        )

    arg_parser.add_argument('-m', '--modules', nargs='*', help=(
    	'Modules to run'
    ), default='class type schema data fk'.split())
    
    arg_parser.add_argument('-q', '--quick', action='store_true', help=(
    	"avoid processing everything so that the database is generated more "
    	"quickly (but is incomplete); useful for quick iteration when "
    	"developing"
    ))

    parsed_args = arg_parser.parse_args()
    
    run(
    	parsed_args.data_root, parsed_args.output_dir,
    	modules_list=parsed_args.modules,
    	quick=parsed_args.quick
    )


