from dataclasses import dataclass
from enum import Enum
import functools as ft
from typing import Any, assert_never
import apsw

class PatternSyntaxError(Exception):
	pass

class PatternParserState(Enum):
	START = 0
	VAR = 1

@dataclass
class Route:
	url_pattern: str
	template: str

	# Maps template argument names to SQL query paths. Each value is
	# interpreted as a file system path relative to the `query` subdirectory of
	# the project root. It is expected that there will be a file at this path,
	# and its content will be used as the source code for the query.
	template_query: str | None=None

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
						raise PatternSyntaxError(
							f"unmatched closing '}}' character at index {i}"
						)
					else:
						result_chars.append(char)
				case PatternParserState.VAR:
					if char == '{':
						raise PatternSyntaxError(
							f"'{{' character at index {i} is not allowed since"
							" it is within a variable"
						)
					elif char == '}':
						parser_state = PatternParserState.START
						var_name = ''.join(var_chars)

						try:
							var_value = args[var_name]
						except KeyError:
							raise ValueError(
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

@ft.cache
def routes() -> list[Route]:
	return [
		Route('index.html', 'index.j2'),
		Route('switches.html', 'switches.j2', 'view_switches'),
		Route('switch/{id}.html', 'switch.j2', 'view_switch', 'switch-ids'),
	]