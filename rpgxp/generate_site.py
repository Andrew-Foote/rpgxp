from functools import cache
import importlib.resources
import jinja2
from pathlib import Path
from rpgxp import db
from rpgxp.util import project_root
from routes import routes

jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader('site/templates'))

jinja_env.globals |= {
    'game_name': 'Pokémon Rejuvenation',
    'url_base': '/site',
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

    for route in routes():
        var_query = db.execscript(route.query_path)

        query_path = project_root() / 'query' / route.query_path

        with query_path.open() as query_file:
            query = query_file.read()

        query_result = connection.execute(query, params)
    
    switches = [
        {'id': id_, 'name': name}
        for id_, name in connection.execute('select id, name from switch')
    ]
    
    render_template('switches.j2', 'site/gen/switches.html', switches=switches)
    serve()

def serve() -> None:
    import runpy
    import sys

    sys.argv[1:] = ('--directory', str(project_root()), '--bind', '127.0.0.1')
    runpy.run_module('http.server', {'sys': sys}, '__main__')