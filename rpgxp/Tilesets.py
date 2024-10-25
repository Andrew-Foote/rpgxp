from dataclasses import dataclass
import io
from pathlib import Path
from typing import Self
import numpy as np
import apsw
import apsw.bestpractice
import ruby_marshal_parser as marshal
from rpgxp.parse import parse
from rpgxp.schema import Tileset

SCHEMA = '''
drop table if exists tileset;
drop table if exists tileset_autotile;

create table tileset (
	 id integer primary key
	,name text not null
	,tileset_name text not null
	,panorama_name text -- "" > null
	,panorama_hue integer not null check (panorama_hue between 0 and 360)
	,fog_name text
	,fog_hue integer not null check (fog_hue between 0 and 360)
	,fog_opacity integer not null
	,fog_blend_type integer not null
	,fog_zoom integer not null
	,fog_sx integer not null
	,fog_sy integer not null
	,battleback_name text
	,passages blob not null
	,priorities blob not null
	,terrain_tags blob not null
);

create table tileset_autotile (
	 tileset_id integer
	,"index" integer not null check ("index" between 0 and 6)
	,autotile_name text not null
	,primary key (tileset_id, "index")
	,foreign key (tileset_id) references tileset (id)
) without rowid;

'''

class ParseError(Exception):
	pass

def load(project_root: Path) -> list[Tileset]:
	path = project_root / 'Data/Tilesets.rxdata'
	data = marshal.parse_file(path)
	result: list[Tileset] = []
	root = data.content.body_content

	if not isinstance(root, marshal.Array):
		raise ParseError(f'expected node of type Array, got {type(root).__name__}')

	first_item = root.items[0].body_content

	if not isinstance(first_item, marshal.Nil):
		raise ParseError(f'expected first item of array to be nil, got {type(first_item).__name__}')

	for tileset_id, tileset_node in enumerate(root.items[1:], start=1):
		tileset = parse(Tileset, tileset_node)

		if not tileset.id_ == tileset_id:
			raise ParseError(f'expected tileset ID to be {tileset_id}, got {tileset.id_}')

		result.append(tileset)

	return result

def dump_to_db(data: list[Tileset]) -> None:
	apsw.bestpractice.apply(apsw.bestpractice.recommended)
	connection = apsw.Connection('rpgxp.sqlite')
	connection.pragma('defer_foreign_keys', True)

	with connection:
		connection.execute(SCHEMA)

		for tileset in data:
			arrayblobs = []

			for field in ('passages', 'priorities', 'terrain_tags'):
				stream = io.BytesIO()
				np.save(stream, getattr(tileset, field))
				arrayblobs.append(stream.getvalue())

			connection.execute('''
				insert into tileset (
					id, name, tileset_name, panorama_name, panorama_hue,
					fog_name, fog_hue, fog_opacity, fog_blend_type, fog_zoom,
					fog_sx, fog_sy, battleback_name, passages, priorities,
					terrain_tags
				) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
			''', (
				tileset.id_, tileset.name, tileset.tileset_name,
				tileset.panorama_name, tileset.panorama_hue, tileset.fog_name,
				tileset.fog_hue, tileset.fog_opacity, tileset.fog_blend_type,
				tileset.fog_zoom, tileset.fog_sx, tileset.fog_sy,
				tileset.battleback_name, *arrayblobs
			))

			for i, autotile_name in enumerate(tileset.autotile_names):
				connection.execute('''
					insert into tileset_autotile (
						tileset_id, "index", autotile_name
					) values (?, ?, ?)
				''', (tileset.id_, i, autotile_name))

if __name__ == '__main__':
	import argparse

	arg_parser = argparse.ArgumentParser(
	    prog='Tilesets',
	    description='Parses Tilesets.rxdata files'
	)

	arg_parser.add_argument('project_root', type=Path)
	parsed_args = arg_parser.parse_args()
	project_root = parsed_args.project_root
	data = load(project_root)
	dump_to_db(data)
