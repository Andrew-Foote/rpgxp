import functools as ft
import io
from pathlib import Path
import zipfile
from typing import Any, Iterable, TypedDict

import jinja2
from PIL import Image as pil
from PIL.Image import Image

from rpgxp import material, settings, tile
from rpgxp import image as imgmanip

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

NamedStr = TypedDict('NamedStr', {
    'name': str,
    'content': str,
})

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
    'image_content': image_content,
    'zip_archive': zip_archive,
    'root_for_source': material.root_for_source,
    'material': load_material,
    'map_image_from_id': tile.map_image_from_id,
}

jinja_env.filters |= {
    'ordinal': ordinal
}

def render_template(template_path: str, template_args: dict[str, Any]) -> str:
    template = jinja_env.get_template(template_path)
    return template.render(**template_args)

@ft.cache
def static_root() -> Path:
    return settings.project_root / 'site' / 'static'
