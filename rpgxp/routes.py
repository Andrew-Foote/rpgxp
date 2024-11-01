from functools import cache

@dataclass
class Route:
	url_pattern: str
	template_path: str

	# Maps template argument names to SQL query paths. Each value is
	# interpreted as a file system path relative to the `query` subdirectory of
	# the project root. It is expected that there will be a file at this path,
	# and its content will be used as the source code for the query.
	arg_queries: dict[str, str]

	# Path to an SQL query which will return the set of all possible pattern
	# variable values for the URL. Each column in the query result should have
	# the same name as one of the pattern variables. One copy of the template
	# will be generated for each row in the result, with the pattern variables
	# replaced by the corresponding row values in the generated URL. The row
	# values will also be passed as parameters to the SQL queries used to
	# generate the template argument values.
	#
	# Should be set to None when the URL contains no pattern variables.
	var_query: str | None=None

@ft.cache
def routes() -> list[Route]:
	return [
		Route('site/gen/switches.html', 'switches.j2', {
			'switches': 'view_switches'
		}),
		Route(
			'site/gen/switch/{id}.html', 'switch.j2', 
			{'switch': 'view_switch'}, 'switch_ids',
		),
	]