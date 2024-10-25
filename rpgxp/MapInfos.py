from dataclasses import dataclass
from pathlib import Path
from typing import Self
import apsw
import apsw.bestpractice
import ruby_marshal_parser as marshal
from rpgxp.parse import parse
from rpgxp.schema import MapInfo

SCHEMA = '''
drop table if exists map_info;

create table map_info (
	 id integer primary key
	,name text not null
	,parent_id integer
	,"order" integer not null
	,expanded integer not null check (expanded in (0, 1))
	,scroll_x integer not null
	,scroll_y integer not null
	,foreign key (parent_id) references map_info (id)
);
'''

class ParseError(Exception):
	pass

def load(project_root: Path) -> dict[int, MapInfo]:
	path = project_root / 'Data/MapInfos.rxdata'
	data = marshal.parse_file(path)
	result: dict[int, MapInfo] = {}
	root = data.content.body_content

	if not isinstance(root, marshal.Hash):
		raise ParseError(f'expected node of type Hash, got {type(root).__name__}')

	for map_id_node, map_info_node in root.items:
		if not isinstance(map_id_node.body_content, marshal.Fixnum):
			raise ParseError('expected a hash with fixnum keys')

		map_id = map_id_node.body_content.value
		map_info = parse(MapInfo, map_info_node)
		result[map_id] = map_info

	return result

def dump_to_db(data: dict[int, MapInfo]) -> None:
	apsw.bestpractice.apply(apsw.bestpractice.recommended)
	connection = apsw.Connection('rpgxp.sqlite')
	connection.pragma('defer_foreign_keys', True)

	with connection:
		connection.execute(SCHEMA)

		for id_, map_info in data.items():
			parent_id: int | None = map_info.parent_id

			# main reason we do this is for the FK constraint
			if not parent_id:
				parent_id = None

			connection.execute('''
				insert into map_info (
					id, name, parent_id, "order", expanded, scroll_x, scroll_y
				) values
				(?, ?, ?, ?, ?, ?, ?)
			''', (
				id_, map_info.name, parent_id, map_info.order,
				map_info.expanded, map_info.scroll_x, map_info.scroll_y
			))

if __name__ == '__main__':
	import argparse

	arg_parser = argparse.ArgumentParser(
	    prog='MapInfos',
	    description='Parses MapInfos.rxdata files'
	)

	arg_parser.add_argument('project_root', type=Path)
	parsed_args = arg_parser.parse_args()
	project_root = parsed_args.project_root
	data = load(project_root)
	dump_to_db(data)

