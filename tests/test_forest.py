import json
from sortedcontainers import SortedList
from rpgxp.forest import from_rows, Just, Row, to_json, Tree

def test_from_rows() -> None:
	rows = [
		Row(1, Just(112), 'Department Store 5F'),
		Row(2, Just(112), 'Department Store 6F'),
		Row(24, None, 'Reborn'),
		Row(28, Just(24), 'Reborn City'),
		Row(36, Just(28), 'Obsidia Ward'),
		Row(51, None, 'Intro'),
		Row(112, Just(36), 'Department Store'),
		Row(667, Just(689), 'Intro Train'),
		Row(689, Just(51), 'Tourmaline Desert'),
	]

	assert from_rows(rows) == [
		Tree('Reborn', [
			Tree('Reborn City', [
				Tree('Obsidia Ward', [
					Tree('Department Store', [
						Tree('Department Store 5F', []),
						Tree('Department Store 6F', []),
					])
				])
			])
		]),
		Tree('Intro', [
			Tree('Tourmaline Desert', [
				Tree('Intro Train', [])
			])
		]),
	]

def test_to_json() -> None:
	forest = [
		Tree('Intro', [
			Tree('Tourmaline Desert', [
				Tree('Intro Train', [])
			])
		]),
		Tree('Reborn', [
			Tree('Reborn City', [
				Tree('Obsidia Ward', [
					Tree('Department Store', [
						Tree('Department Store 5F', []),
						Tree('Department Store 6F', []),
					])
				])
			])
		])
	]

	assert to_json(forest) == json.dumps([
		{'label': 'Intro', 'children': [
			{'label': 'Tourmaline Desert', 'children': [
				{'label': 'Intro Train', 'children': []}
			]}
		]},
		{'label': 'Reborn', 'children': [
			{'label': 'Reborn City', 'children': [
				{'label': 'Obsidia Ward', 'children': [
					{'label': 'Department Store', 'children': [
						{'label': 'Department Store 5F', 'children': []},
						{'label': 'Department Store 6F', 'children': []},
					]}
				]}
			]}
		]},
	])