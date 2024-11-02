from pathlib import Path
import shutil
from typing import Any
import jinja2
import apsw
from rpgxp import db
from rpgxp.util import project_root
from rpgxp.routes import routes
from rpgxp import settings

jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader(
    str(settings.project_root / 'site/templates')
))

jinja_env.globals |= {
    'game_name': settings.game_name,
    'url_base': '/',
}

def render_template(src_path: str, dst_path: str, **args: Any) -> None:
    src_path_obj = project_root() / dst_path 
    src_path_obj.parent.mkdir(parents=True, exist_ok=True)
    template = jinja_env.get_template(src_path)
    content = template.render(**args)

    with src_path_obj.open('w', encoding='utf-8') as f:
        f.write(content)

def run(db_root: Path):
    connection = db.connect(db_root)
    static_root = settings.site_root / 'static'
    project_root = settings.project_root

    for static_path in static_root.rglob('*'):
        dst_path = settings.site_root / static_path.relative_to(static_root)
        print(f'Copying {static_path} to {dst_path}')
        input()
        shutil.copyfile(static_path, dst_path)

    for route in routes():
        url_params: tuple[str, ...]
        possible_url_args: list[tuple[apsw.SQLiteValue, ...]]

        if route.url_query is None:
            url_params = ()
            possible_url_args = [()]
        else:
            url_query_path = project_root / 'sql' / route.url_query
            url_query_result = db.run_script(connection, url_query_path)
            url_params, _ = zip(*url_query_result.get_description())
            possible_url_args = url_query_result.fetchall()

        for url_args in possible_url_args:
            url = route.url(**dict(zip(url_params, url_args)))
            filesystem_url = settings.site_root / url
            template_args: dict[str, Any]

            if route.template_query is None:
                template_args = {}
            else:
                template_query_path = (
                    project_root / 'sql' / route.template_query
                )

                template_query_result = db.run_script(
                    connection, template_query_path
                )

                template_params, _ = zip(
                    *template_query_result.get_description()
                )

                template_arg_values = db.row(template_query_result)
                template_args = dict(zip(template_params, template_arg_values))

            render_template(
                route.template,
                str(filesystem_url),
                **template_args
            )
