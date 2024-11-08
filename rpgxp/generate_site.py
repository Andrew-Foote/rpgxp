from dataclasses import dataclass
import io
from pathlib import Path
import shutil
from typing import Any, Iterable, TypedDict
import zipfile
import apsw
import jinja2
from rpgxp import db, material, settings, site
from rpgxp.routes import routes

def render_template_to_file(
    src_path: str, dst_path: str, template_args: dict[str, Any], 
    *, binary: bool=False
) -> None:

    content = site.render_template(src_path, template_args)

    dst_path_obj = settings.project_root / dst_path 
    dst_path_obj.parent.mkdir(parents=True, exist_ok=True)

    if binary:
        with dst_path_obj.open('wb') as f:
            f.write(content.encode('utf-8', 'surrogateescape'))
    else:
        with dst_path_obj.open('w', encoding='utf-8') as f:
            f.write(content)

def copy_static_files() -> None:
    static_root = settings.project_root / 'site/static'

    for static_path in static_root.rglob('*'):
        dst_path = settings.site_root / static_path.relative_to(static_root)
        dst_path.parent.mkdir(parents=True, exist_ok=True)
        print(f'Copying {static_path} to {dst_path}')
        shutil.copyfile(static_path, dst_path)

    material.copy_static_files()

def run() -> None:
    copy_static_files()

    connection = db.connect()
    project_root = settings.project_root

    for route in routes():
        print(f'Generating route {route.url_pattern}...')
        url_params: tuple[str, ...]
        possible_url_args: list[tuple[apsw.SQLiteValue, ...]]

        if route.url_query is None:
            url_params = ()
            possible_url_args = [()]
        else:
            url_query_result = db.run_named_query(route.url_query)
            url_params, _ = zip(*url_query_result.get_description())
            possible_url_args = url_query_result.fetchall()

        for url_args in possible_url_args:
            coerced_url_args = tuple(map(str, url_args))
            template_args = site.get_template_args(route, coerced_url_args)

            url = route.url(**dict(zip(url_params, coerced_url_args)))
            filesystem_url = settings.site_root / url

            try:
                render_template_to_file(
                    route.template,
                    str(filesystem_url),
                    template_args,
                    binary=route.binary
                )
            except jinja2.TemplateError as e:
                e.add_note(route.template)
                e.add_note(str(template_args))
                raise

if __name__ == '__main__':
    run()