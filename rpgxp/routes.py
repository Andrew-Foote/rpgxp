from dataclasses import dataclass, field
from enum import Enum
import functools as ft
import json
from typing import Any, assert_never, Self
import apsw

class RouteError(Exception):
	pass

class RoutePatternSyntaxError(RouteError):
	pass

class RoutePatternValueError(RouteError, ValueError):
	pass

class PatternParserState(Enum):
	START = 0
	VAR = 1

class BasicParamType(Enum):
	NONE = 0
	INT = 1
	FLOAT = 2
	BYTES = 3
	STR = 4
	JSON = 5

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

		raise RoutePatternValueError(
			f'{raw_arg!r} cannot be parsed as any of {self.members}'
		)

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

@dataclass
class Route:
	url_pattern: str
	template: str

	# Maps template argument names to SQL query paths. Each value is
	# interpreted as a file system path relative to the `query` subdirectory of
	# the project root. It is expected that there will be a file at this path,
	# and its content will be used as the source code for the query.
	template_query: str | None=None

	param_types: dict[str, ParamType]=field(default_factory=lambda: {})

	# Path to an SQL query which will return the set of all possible pattern
	# variable values for the URL. Each column in the query result should have
	# the same name as one of the pattern variables. One copy of the template
	# will be generated for each row in the result, with the pattern variables
	# replaced by the corresponding row values in the generated URL. The row
	# values will also be passed as parameters to the SQL queries used to
	# generate the template argument values.
	#
	# Should be set to None when the URL contains no pattern variables.
	url_query: str | None=None

	def url(self, **args: apsw.SQLiteValue) -> str:
		result_chars: list[str] = []
		var_chars: list[str] = []
		parser_state: PatternParserState = PatternParserState.START

		for i, char in enumerate(self.url_pattern):
			match parser_state:
				case PatternParserState.START:
					if char == '{':
						parser_state = PatternParserState.VAR
					elif char == '}':
						raise RoutePatternSyntaxError(
							f"unmatched closing '}}' character at index {i}"
						)
					else:
						result_chars.append(char)
				case PatternParserState.VAR:
					if char == '{':
						raise RoutePatternSyntaxError(
							f"'{{' character at index {i} is not allowed since"
							" it is within a variable"
						)
					elif char == '}':
						parser_state = PatternParserState.START
						var_name = ''.join(var_chars)

						try:
							var_value = args[var_name]
						except KeyError:
							raise RoutePatternValueError(
								f'no binding given for pattern variable '
								f'{var_name}'
							)

						result_chars.extend(str(var_value))
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
				e.add_note(f'Expected a column in the template query result named {param}')
				e.add_note(f'Only got these columns: {", ".join(args.keys())}')
				e.add_note(f'Query name is {self.template_query}')
				raise

			try:
				result[param] = param_type.parse_arg(raw_arg)
			except RoutePatternValueError as e:
				e.add_note(f'Parameter: {param}')
				raise

		return result

@ft.cache
def routes() -> list[Route]:
	return [
		Route('index.html', 'index.j2'),
		Route('maps.html', 'maps.j2', 'view_maps', {'maps': json_param()}),
		Route('map/{id}.html', 'map.j2', 'view_map', {
			'id': int_param(),
			'name': str_param(),
			'parent': json_param(optional=True),
			'children': json_param(),
			'tileset': json_param(),
			'bgm': json_param(optional=True),
			'bgs': json_param(optional=True),
			'encounter_step': int_param(),
			'encounters': json_param(),
		}, 'map_ids'),
		Route('tilesets.html', 'tilesets.j2', 'view_tilesets', {
			'tilesets': json_param()
		}),
		Route('tileset/{id}.html', 'tileset.j2', 'view_tileset', {
			'id': int_param(),
			'name': str_param(),
			'file_name': str_param(),
			'extension': str_param(optional=True),
			'autotiles': json_param(),
			'panorama': json_param(optional=True),
			'fog': json_param(optional=True),
			'battleback': json_param(optional=True),
		}, 'tileset_ids'),
		Route('common_events.html', 'common_events.j2', 'view_common_events', {
			'common_events': json_param(),
		}),
		Route('common_event/{id}.html', 'common_event.j2', 'view_common_event', {
			'id': int_param(),
			'name': str_param(),
			'trigger': json_param(optional=True),
		}, 'common_event_ids'),
		Route('switches.html', 'switches.j2', 'view_switches', {
			'switches': json_param(),
		}),
		Route('switch/{id}.html', 'switch.j2', 'view_switch', {
			'switch': json_param(),
		}, 'switch_ids'),
	]