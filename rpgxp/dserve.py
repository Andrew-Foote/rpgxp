from dataclasses import dataclass
import functools as ft
import mimetypes
from pathlib import Path
import re
from typing import Iterator

from wsgiref.types import WSGIEnvironment, StartResponse
from wsgiref.simple_server import make_server

from rpgxp import settings, site
from rpgxp.routes import Route, routes

@ft.cache
def static_root() -> Path:
    return settings.project_root / 'site' / 'static'

@ft.cache
def static_file_paths() -> frozenset[str]:
    return frozenset(
        str(path.relative_to(static_root()))
        for path in static_root().rglob('*')
    )

@dataclass
class Response:
    status: str
    headers: list[tuple[str, str]]
    content: bytes

class UnidentifiableMimeTypeError(Exception):
    pass

def guess_type_headers(path: str) -> Iterator[tuple[str, str]]:
    type_, encoding = mimetypes.guess_type(path)

    if type_ is None:
        raise UnidentifiableMimeTypeError
    else:
        yield ('Content-Type', type_)

    if encoding is not None:
        yield ('Content-Encoding', encoding)

def respond_static(path: str, *, head_only: bool) -> Response:
    print(f'Responding to static file request for {path}')
    headers: list[tuple[str, str]] = [*guess_type_headers(path)]

    fs_path = static_root() / path.lstrip('/')
    size = fs_path.stat().st_size
    headers.append(('Content-Length', str(size)))

    if head_only:
        content = b''
    else:
        with fs_path.open('rb') as f:
            content = f.read()

    return Response('200 OK', headers, content)    

class NoMatchingRouteError(Exception):
    pass

def match_route(path: str) -> tuple[Route, tuple[str, ...]]:
    print(f'Path: {path}')

    for route in routes():
        if path == '' and route.url_pattern == 'index.html':
            return route, ()

        print('Trying match against ', route.url_pattern)
        pattern = re.sub(r'\{.*?\}', '(.*?)', route.url_pattern)
        print('Pattern as regex: ', pattern)
        m = re.match(pattern, path)

        if m is not None:
            return route, m.groups()

    raise NoMatchingRouteError

def respond_dynamic(path: str, *, head_only: bool=False) -> Response:
    try:
        route, url_args = match_route(path.lstrip('/'))
    except NoMatchingRouteError:
        status = '404 Not Found'
        headers = [('Content-Type', 'text/html; charset=utf-8')]
        template = 'not_found.j2'
        template_args = {'url': path}
    else:
        status = '200 OK'

        # maybe we should specify the content type in the route rather than
        # guessing it

        content_type = route.content_type
        content_type_header_value = content_type.mime_type

        if not content_type.binary:
            content_type_header_value += '; charset=utf-8'

        headers = [('Content-Type', content_type_header_value)]
        template = route.template
        template_args = site.get_template_args(route, url_args)

    content = site.render_template(template, template_args).encode('utf-8')
    headers.append(('Content-Length', str(len(content))))

    if head_only:
        content = b''

    return Response(status, headers, content)

ACCEPTED_METHODS = ('GET', 'HEAD')

def wsgi_app(
    environ: WSGIEnvironment, start_response: StartResponse
) -> list[bytes]:
    method = environ['REQUEST_METHOD']

    if method not in ACCEPTED_METHODS:
        response = Response(
            '405 Method Not Allowed',
            [('Allow', ', '.join(ACCEPTED_METHODS))],
            b''
        )
    else:
        head_only = method == 'HEAD'
        path = environ['PATH_INFO']
        query_string = environ['QUERY_STRING']

        if path.lstrip('/') in static_file_paths():
            response = respond_static(path, head_only=head_only)
        else:
            response = respond_dynamic(path, head_only=head_only)

    start_response(response.status, response.headers)
    return [response.content]

def run() -> None:
    with make_server('', 8000, wsgi_app) as httpd:
        httpd.serve_forever()

if __name__ == '__main__':
    run()