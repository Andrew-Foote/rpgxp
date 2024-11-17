from dataclasses import dataclass, field
from enum import Enum
import mimetypes
import json
from typing import Any, assert_never, Iterator, Self
import apsw
from rpgxp import db
from rpgxp.util import expect1

class RouteError(Exception):
	pass

class UrlPatternSyntaxError(RouteError):
	pass

class UrlPatternValueError(RouteError, ValueError):
	pass

class UnidentifiableMimeTypeError(RouteError):
    pass

class ContentType(Enum):
	HTML = 1
	PNG = 2
	RUBY = 3
	ZIP = 4
	VARIABLE_BINARY = 5

	@property
	def binary(self) -> bool:
		match self:
			case (
				ContentType.PNG | ContentType.ZIP | ContentType.VARIABLE_BINARY
			):
				return True
			case ContentType.HTML | ContentType.RUBY:
				return False
			case _:
				assert_never(self)

	def headers(self, path: str) -> Iterator[tuple[str, str]]:
		match self:
			case ContentType.HTML:
				yield ('Content-Type', 'text/html; charset=utf-8')
			case ContentType.PNG:
				yield ('Content-Type', 'image/png')
			case ContentType.RUBY:
				yield ('Content-Type', 'application/x-ruby; charset=utf-8')
			case ContentType.ZIP:
				yield ('Content-Type', 'application/zip')
			case ContentType.VARIABLE_BINARY:
				type_, encoding = mimetypes.guess_type(path)

				if type_ is None:
					raise UnidentifiableMimeTypeError

				yield ('Content-Type', type_)

				if encoding is not None:
					yield ('Content-Encoding', encoding)
			case _:
				assert_never(self)

class BasicParamType(Enum):
	NONE = 0
	BOOL = 1
	INT = 2
	FLOAT = 3
	BYTES = 4
	STR = 5
	JSON = 6

@dataclass
class ParamType:
	members: set[BasicParamType]

	def __or__(self, other: Self) -> Self:
		return self.__class__(self.members | other.members)

	def parse_arg(self, raw_arg: apsw.SQLiteValue) -> Any:
		for member in self.members:
			match member:
				case BasicParamType.NONE:
					if raw_arg is None:
						return None
				case BasicParamType.BOOL:
					if isinstance(raw_arg, int):
						return bool(raw_arg)
				case BasicParamType.INT:
					if isinstance(raw_arg, int):
						return raw_arg
				case BasicParamType.FLOAT:
					if isinstance(raw_arg, float):
						return raw_arg
				case BasicParamType.BYTES:
					if isinstance(raw_arg, bytes):
						return raw_arg
				case BasicParamType.STR:
					if isinstance(raw_arg, str):
						return raw_arg
				case BasicParamType.JSON:
					if isinstance(raw_arg, str):
						return json.loads(raw_arg)
				case _:
					assert_never(member)

		raise UrlPatternValueError(
			f'{raw_arg!r} cannot be parsed as any of {self.members}'
		)

def bool_param() -> ParamType:
	return ParamType({BasicParamType.BOOL})

def int_param(*, optional: bool=False) -> ParamType:
	return ParamType({BasicParamType.INT} | (
		{BasicParamType.NONE} if optional else set()
	))

def float_param(*, optional: bool=False) -> ParamType:
	return ParamType({BasicParamType.FLOAT} | (
		{BasicParamType.NONE} if optional else set()
	))

def bytes_param(*, optional: bool=False) -> ParamType:
	return ParamType({BasicParamType.BYTES} | (
		{BasicParamType.NONE} if optional else set()
	))

def str_param(*, optional: bool=False) -> ParamType:
	return ParamType({BasicParamType.STR} | (
		{BasicParamType.NONE} if optional else set()
	))

def json_param(*, optional: bool=False) -> ParamType:
	return ParamType({BasicParamType.JSON} | (
		{BasicParamType.NONE} if optional else set()
	))

class PatternParserState(Enum):
	START = 0
	VAR = 1

@dataclass
class Route:
	url_pattern: str
	"""The URL pattern for the route. All URLs matching this pattern will be
	handled by this route. The pattern format is (currently) very simple.
	Anything within curly brackets is a pattern variable. The part within the
	brackets is the variable name. Any string can be substituted in place of a
	pattern variable. When matching a URL against a pattern, the pattern is
	treated as a regex where each pattern variable is replaced with a named
	capture group of the form (?P<name>.*?)."""
	
	template: str
	"""The path to the template which will be used to render the route, relative
	to the /templates directory."""

	template_query: str | None = None
	"""The path to the SQL query which is used to fetch the template arguments.
	This query will have the URL arguments passed to it as parameters, and it
	should return a set of columns with the same names as the template
	arguments; the values of these columns, after being parsed according to
	their type as indicated by the `param_types` field, will be used as the
	template arguments.
	
	If set to None, the template will receive no arguments."""

	param_types: dict[str, ParamType]=field(default_factory=lambda: {})
	"""A dictionary indicating the type of each template argument. Each type is
	associated with a parser which will be applied to the raw value returned
	from the SQL query in order to produce the template argument."""

	url_query: str | None = None
	"""The path to the SQL query which is used to fetch the URL arguments. This
	is used only when generating the site statically. The query will be run
	without any parameter bindings, and is expected to return a set of columns
	whose names match those of the variables in the URL pattern. For each row
	in the result, a page will be generated at the location obtained by
	substituting the column values into the URL pattern. The column values will
	also be passed as parameters to the template query for each page.
	
	This should be set to `None` if, and only if, the URL pattern contains no
	variables, in which case only one page will be generated, and the template
	query will be executed without any paramter bindings."""

	content_type: ContentType = ContentType.HTML
	"""The content type of the pages that will be generated from this route.
	Used for determining the appropriate values of the Content-Type and
	Content-Encoding headers, and for determining how to handle character
	encoding (based on whether the content is text or binary; UTF-8 is used
	for all text content)."""

	def url(self, **args: str) -> str:
		"""Substitute URL parameter values into the URL pattern to return a
		specific page's URL."""

		result_chars: list[str] = []
		var_chars: list[str] = []
		parser_state: PatternParserState = PatternParserState.START

		for i, char in enumerate(self.url_pattern):
			match parser_state:
				case PatternParserState.START:
					if char == '{':
						parser_state = PatternParserState.VAR
					elif char == '}':
						raise UrlPatternSyntaxError(
							f"unmatched closing '}}' character at index {i}"
						)
					else:
						result_chars.append(char)
				case PatternParserState.VAR:
					if char == '{':
						raise UrlPatternSyntaxError(
							f"'{{' character at index {i} is not allowed since"
							" it is within a variable"
						)
					elif char == '}':
						parser_state = PatternParserState.START
						var_name = ''.join(var_chars)

						try:
							var_value = args[var_name]
						except KeyError:
							raise UrlPatternValueError(
								f'no binding given for pattern variable '
								f'{var_name}'
							)

						result_chars.extend(var_value)
						var_chars.clear()
					else:
						var_chars.append(char)
				case _:
					assert_never(parser_state)

		return ''.join(result_chars)

	def format_template_args(
		self, args: dict[str, apsw.SQLiteValue]
	) -> dict[str, Any]:

		result: dict[str, Any] = {}

		for param, param_type in self.param_types.items():
			try:
				raw_arg = args[param]
			except KeyError as e:
				e.add_note(
					f'Expected a column in the template query result named '#
					f'{param}'
				)
				e.add_note(f'Only got these columns: {", ".join(args.keys())}')
				e.add_note(f'Query name is {self.template_query}')
				raise

			try:
				result[param] = param_type.parse_arg(raw_arg)
			except UrlPatternValueError as e:
				e.add_note(f'Parameter: {param}')
				e.add_note(f'Query name is {self.template_query}')
				e.add_note(f'Raw arguments: {args}')
				raise

		return result

	def get_template_args(self, url_args: dict[str, str]) -> dict[str, Any]:
		template_query = self.template_query
		url_query = self.url_query

		if template_query is None:
			return {}

		try:
			query_result = db.run_named_query(template_query, url_args)
		except Exception as e:
			if isinstance(e, KeyError):
				e.add_note(f'No argument given for URL parameter "{e.args[0]}"')

			e.add_note(f'URL query name: {url_query}')
			e.add_note(f'Template query name: {template_query}')
			e.add_note(f'URL arguments: {url_args}')
			raise

		try:
			query_desc = query_result.get_description()
		except apsw.ExecutionCompleteError as e:
			if isinstance(e, apsw.ExecutionCompleteError):
				e.add_note(
					'This means the template query has returned no rows'
				)

			e.add_note(f'Template query name: {template_query}')
			e.add_note(f'URL arguments: {str(url_args)}')
			raise

		template_params, _ = zip(*query_desc)
		template_arg_values = expect1(query_result)
		
		return self.format_template_args(
			dict(zip(template_params, template_arg_values))
		)