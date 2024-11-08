import io
import zipfile
from typing import Any, Iterable, TypedDict

import apsw
import jinja2

from rpgxp import db, settings
from rpgxp.routes import Route

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

def render_template(template_path: str, template_args: dict[str, Any]) -> str:
    template = jinja_env.get_template(template_path)
    return template.render(**template_args)

def get_template_args(
	route: Route, url_args: tuple[str, ...]
) -> dict[str, Any]:

    if route.template_query is None:
    	return {}

    template_query_result = db.run_named_query(route.template_query, url_args)

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
    
    return route.format_template_args(
        dict(zip(template_params, template_arg_values))
    )