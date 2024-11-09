import importlib
import subprocess
from rpgxp import db, material, settings
from rpgxp.script import foreign_key_report

RECOGNIZED_MODULES = {
    'class', 'type', 'schema', 'material.schema', 'data', 'material.data',
    'fk', 'views', 'site', 'static', 'material.static', 'maps', 'serve',
    'dserve'
}

def run(*, modules_list: list[str], quick: bool):
	modules = set(modules_list)
	unrecognized_modules = modules - RECOGNIZED_MODULES

	if unrecognized_modules:
		raise ValueError(
			f'unrecognized modules: {", ".join(unrecognized_modules)}'
		)

	game_data_root = settings.game_data_root
	db_root = settings.db_root
	site_root = settings.site_root

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
		module.run()
	elif 'material.schema' in modules:
		print("Generating the database schema for materials...")
		material.generate_db_schema()

	if 'data' in modules:
		print("Generating the database data...")
		module = importlib.import_module('rpgxp.generate_db_data')
		module.run(quick=quick)
	elif 'material.data' in modules:
		print("Generating material data...")
		material.generate_db_data()

	if 'fk' in modules:
		print("Checking foreign keys...")
		module = importlib.import_module('rpgxp.script.foreign_key_report')
		module.run()

	if 'views' in modules:
		print("Creating database views...")
		db.run_named_query('views')

	if 'site' in modules:
		print("Generating web UI...")
		module = importlib.import_module('rpgxp.generate_site')
		module.run()
	elif 'static' in modules:
		print("Copying static files for web UI...")
		module = importlib.import_module('rpgxp.generate_site')
		module.copy_static_files()
	elif 'material.static' in modules:
		print("Copying static files for materials...")
		material.copy_static_files()

	if 'maps' in modules:
		print('Generating map images...')
		module = importlib.import_module('rpgxp.script.generate_map_images')
		module.run()

	if 'serve' in modules:
		print('Serving web UI...')
		module = importlib.import_module('rpgxp.serve')
		module.run()

	if 'dserve' in modules:
		print('Serving web UI (dynamically)...')
		module = importlib.import_module('rpgxp.dserve')
		module.run()

if __name__ == '__main__':
    import argparse

    arg_parser = argparse.ArgumentParser(
        prog='RPG Maker XP Database',
        description=(
        	'Creates an SQLite database for the data of a game made using RPG '
        	'Maker XP'
        )
    )

    arg_parser.add_argument('-m', '--modules', nargs='*', help=(
    	'Modules to run'
    ), default='class type schema data fk views site maps serve'.split()
    )
    
    arg_parser.add_argument('-q', '--quick', action='store_true', help=(
    	"avoid processing everything so that the database is generated more "
    	"quickly (but is incomplete); useful for quick iteration when "
    	"developing"
    ))

    parsed_args = arg_parser.parse_args()
    
    run(
   		modules_list=parsed_args.modules,
    	quick=parsed_args.quick
    )


