from functools import cache
import importlib.resources
import jinja2
from pathlib import Path
from rpgxp import db

def project_root() -> Path:
	with importlib.resources.path('rpgxp') as pkg_base_path:
		return pkg_base_path.parent

jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader('site/templates'))

jinja_env.globals |= {
	'game_name': 'Pokémon Rejuvenation',
    'url_base': '',
}

def render_template(src_path: str, dst_path: str, **args) -> None:
	src_path_obj = project_root() / dst_path 
	src_path_obj.parent.mkdir(parents=True, exist_ok=True)
	template = jinja_env.get_template(src_path)
	content = template.render(**args)

	with src_path_obj.open('w', encoding='utf-8') as f:
		f.write(content)

def run(db_dir: Path):
	render_template('index.j2', 'index.html')
	connection = db.connect(db.get_path(db_dir))
	
	switches = [
		{'id': id_, 'name': name}
		for id_, name in connection.execute('select id, name from switch')
	]
	
	render_template('switches.j2', 'site/switches.html', switches=switches)