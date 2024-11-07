from dataclasses import dataclass
import io
from pathlib import Path
import shutil
from typing import Any, Iterable, TypedDict
import zipfile
import apsw
import jinja2
from rpgxp import db, material, settings
from rpgxp.routes import routes

NamedStr = TypedDict('NamedStr', {
    'name': str,
    'content': str,
})

def zip_archive(members: Iterable[NamedStr]) -> str:
    stream = io.BytesIO()

    with zipfile.ZipFile(stream, 'w') as archive:
        for member in members:
            archive.writestr(member['name'], member['content'])

    stream.seek(0)
    return stream.read().decode('utf-8', 'surrogateescape')

jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader(
    str(settings.project_root / 'site/templates')
), undefined=jinja2.StrictUndefined)

jinja_env.globals |= {
    'game_name': settings.game_name,
    'url_base': '',
    'zip_archive': zip_archive,
}

def render_template(
    src_path: str, dst_path: str, template_args: dict[str, Any], 
    *, binary: bool=False
) -> None:
    src_path_obj = settings.project_root / dst_path 
    src_path_obj.parent.mkdir(parents=True, exist_ok=True)
    template = jinja_env.get_template(src_path)
    content = template.render(**template_args)

    if binary:
        with src_path_obj.open('wb') as f:
            f.write(content.encode('utf-8', 'surrogateescape'))
    else:
        with src_path_obj.open('w', encoding='utf-8') as f:
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
            url_query_result = db.run_named_query(connection, route.url_query)
            url_params, _ = zip(*url_query_result.get_description())
            possible_url_args = url_query_result.fetchall()

        for url_args in possible_url_args:
            url = route.url(**dict(zip(url_params, url_args)))
            filesystem_url = settings.site_root / url
            template_args: dict[str, Any] = {}

            if route.template_query is not None:
                template_query_result = db.run_named_query(
                    connection, route.template_query, url_args
                )

                try:
                    query_desc = template_query_result.get_description()
                except apsw.ExecutionCompleteError as e:
                    e.add_note(
                        'This means the template query has returned 0 rows')
                    e.add_note(f'Template query name: {route.template_query}')
                    e.add_note(f'URL arguments: {str(url_args)}')
                    raise

                template_params, _ = zip(*query_desc)
                template_arg_values = db.row(template_query_result)
                
                template_args = route.format_template_args(
                    dict(zip(template_params, template_arg_values))
                )

            #print(f'Generating {filesystem_url}... (args={template_args})')

            try:
                render_template(
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