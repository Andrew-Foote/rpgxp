import io
from pathlib import Path
import zipfile
from typing import Any, Iterable, TypedDict

import apsw
import jinja2
from PIL import Image as pil
from PIL.Image import Image

from rpgxp import db, material, settings, tile
from rpgxp import image as imgmanip
from rpgxp.routes import Route

NamedStr = TypedDict('NamedStr', {
    'name': str,
    'content': str,
})

def ordinal(n: int) -> str:
    digits = str(n)

    if digits[-2:] in ('11', '12', '13'):
        suffix = 'th'
    else:
        suffix = {'1': 'st', '2': 'nd', '3': 'rd'}.get(digits[-1], 'th')

    return digits + suffix

def load_binary_file(path: Path) -> str:
    with path.open('rb') as f:
        return f.read().decode('utf-8', 'surrogateescape')

def image_content(image: Image) -> str:
    stream = io.BytesIO()
    image.save(stream, 'png')
    return stream.getvalue().decode('utf-8', 'surrogateescape')

def zip_archive(members: Iterable[NamedStr]) -> str:
    stream = io.BytesIO()

    with zipfile.ZipFile(stream, 'w') as archive:
        for member in members:
            archive.writestr(member['name'], member['content'])

    return stream.getvalue().decode('utf-8', 'surrogateescape')

def load_material(
    source: str, type: str, subtype: str, name: str, hue: int=0
) -> str:

    root = material.root_for_source(source)
    path = root / type.capitalize() / subtype.capitalize() / name
    
    with pil.open(path) as img:
        adjusted = imgmanip.adjust_hue(img.convert('RGBA'), hue)
    
    stream = io.BytesIO()
    adjusted.save(stream, 'png')
    return stream.getvalue().decode('utf-8', 'surrogateescape')

jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader(
    str(settings.project_root / 'site/templates')
), undefined=jinja2.StrictUndefined)

jinja_env.globals |= {
    'game_name': settings.game_name,
    'url_base': '',
    'game_root': settings.game_root,
    'load_binary_file': load_binary_file,
    'zip_archive': zip_archive,
    'map_image_from_id': tile.map_image_from_id,
    'image_content': image_content,
    'root_for_source': material.root_for_source,
    'material': load_material,
}

jinja_env.filters |= {
    'ordinal': ordinal
}

def render_template(template_path: str, template_args: dict[str, Any]) -> str:
    template = jinja_env.get_template(template_path)
    return template.render(**template_args)

def get_template_args(route: Route, url_args: dict[str, str]) -> dict[str, Any]:
    if route.template_query is None:
        return {}

    try:
        query_result = db.run_named_query(route.template_query, url_args)
    except apsw.BindingsError as e:
        e.add_note("URL parameters don't match the template query parameters")
        e.add_note(f'URL query name: {route.url_query}')
        e.add_note(f'URL parameter values: {url_args}')
        e.add_note(f'Template query name: {route.template_query}')
        raise
    except KeyError as e:
        param = e.args[0]
        e.add_note(f'URL parameter "{param}" is missing')
        e.add_note(f'URL query name: {route.url_query}')
        e.add_note(f'URL parameter values: {url_args}')
        e.add_note(f'Template query name: {route.template_query}')
        raise

    try:
        query_desc = query_result.get_description()
    except apsw.ExecutionCompleteError as e:
        e.add_note(
            'This means the template query has returned 0 rows')
        e.add_note(f'Template query name: {route.template_query}')
        e.add_note(f'URL arguments: {str(url_args)}')
        raise        

    template_params, _ = zip(*query_desc)
    template_arg_values = db.row(query_result)
    
    return route.format_template_args(
        dict(zip(template_params, template_arg_values))
    )