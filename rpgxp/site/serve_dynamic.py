from dataclasses import dataclass
import functools as ft
import mimetypes
import re
import traceback
from typing import Iterator
from wsgiref.types import WSGIEnvironment, StartResponse
from wsgiref.simple_server import make_server

from rpgxp import settings
from rpgxp.route.Route import Route
from rpgxp.route.routes import routes
from rpgxp.site import common as site

@ft.cache
def static_file_paths() -> frozenset[str]:
    static_root = site.static_root()

    return frozenset((
        str(path.relative_to(static_root)) for path in static_root.rglob('*')
    ))

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

    fs_path = site.static_root() / path.lstrip('/')
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

def match_route(path: str) -> tuple[Route, dict[str, str]]:
    print(f'Path: {path}')

    for route in routes():
        if path == '' and route.url_pattern == 'index.html':
            return route, {}

        pattern = re.sub(r'\{(.*?)\}', r'(?P<\1>.*)', route.url_pattern)    
        #print('Trying match against ', route.url_pattern)
        #print('Pattern as regex: ', pattern)

        try:
            m = re.match(pattern, path)
        except Exception as e:
            e.add_note(f'URL pattern: {route.url_pattern}')
            e.add_note(f'Pattern as regex: {pattern}')
            raise

        if m is not None:
            return route, m.groupdict()

    raise NoMatchingRouteError

def respond_dynamic(path: str, *, head_only: bool=False) -> Response:
    try:
        route, url_args = match_route(path.lstrip('/'))
    except NoMatchingRouteError:
        status = '404 Not Found'
        headers = [('Content-Type', 'text/html; charset=utf-8')]
        template = 'not_found.j2'
        template_args = {'url': path}
        binary = False
    else:
        content_type = route.content_type

        status = '200 OK'
        headers = [*content_type.headers(path)]
        template = route.template

        try:
            template_args = route.get_template_args(url_args)
        except Exception as e:
            e.add_note(
                f'Occured when determing template arguments for "{template}"'
            )
            
            e.add_note(f'URL arguments: {url_args}')

            status = '500 Internal Server Error'
            headers = [('Content-Type', 'text/html; charset=utf-8')]
            template = 'error.j2'
            
            template_args = {
                'url': path,
                'traceback': "\n".join(traceback.format_exception(e))
            }
            
            binary = False
        else:
            binary = content_type.binary

    try:
        content = site.render_template(template, template_args)
    except Exception as e:
        e.add_note(f'Occured when rendering template "{template}"')
        e.add_note(f'Template arguments: {template_args}')
        e.add_note(f'URL arguments: {url_args}')

        status = '500 Internal Server Error'
        headers = [('Content-Type', 'text/html; charset=utf-8')]
        template = 'error.j2'
        
        template_args = {
            'url': path,
            'traceback': "\n".join(traceback.format_exception(e))
        }
        
        binary = False

        content = site.render_template(template, template_args)

    encoding = ('utf-8', 'surrogateescape') if binary else ('utf-8',)
    encoded_content = content.encode(*encoding)

    headers.append(('Content-Length', str(len(encoded_content))))

    if head_only:
        content = ''

    return Response(status, headers, encoded_content)

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