import pickle
from typing import Iterator
from rpgxp import settings
from rpgxp.autotile.variant import Variant
from rpgxp.util import int_from_digits

def parse_config_pics(pics: str) -> Iterator[int]:
	lines = [line.strip() for line in pics.splitlines()]
	assert len(lines) == 3
	split_lines = [line.split() for line in lines]
	split_line_lengths = {len(split_line) for split_line in split_lines}
	assert len(split_line_lengths) == 1
	pic_count = split_line_lengths.pop()

	for pic_number in range(pic_count):
		pic_lines = [
			split_lines[line_number][pic_number] for line_number in range(3)
		]

		assert all(len(line) == 3 for line in pic_lines)
		assert pic_lines[1][1] == '#'
		
		relevant_chars = [
			*pic_lines[0],
			pic_lines[1][0], pic_lines[1][2],
			*pic_lines[2]
		]

		assert all(c in '.#' for c in relevant_chars)
		bits = [c == '#' for c in relevant_chars]
		yield int_from_digits(bits, 2)

def parse_variant(tile_id: int, pic: str) -> Variant:
	lines = [line.strip() for line in pic.splitlines()]
	assert len(lines) == 8
	line_lengths = {len(line) for line in lines}
	assert all(len(line) == 17 for line in lines)
	pic = ''.join(line + ' ' for line in lines)

	tl_y, tl_x = divmod(pic.find('tl') // 3, 6)
	tr_y, tr_x = divmod(pic.find('tr') // 3, 6)
	bl_y, bl_x = divmod(pic.find('bl') // 3, 6)
	br_y, br_x = divmod(pic.find('br') // 3, 6)

	return Variant(
		tile_id, (tl_x, tl_y), (tr_x, tr_y), (bl_x, bl_y), (br_x, br_y)
	)

def parse_schema(schema: str) -> tuple[dict[int, int], dict[int, Variant]]:
	tile_id_for_config: dict[int, int] = {}
	variant_for_tile_id: dict[int, Variant] = {}

	blocks = schema.split('===')

	for block in blocks:
		block = block.strip()

		if not block:
			continue

		parts = block.split('\n\n')
		assert len(parts) == 3

		tile_id = int(parts[0].strip())
		config_pics = parts[1].strip()
		variant_pic = parts[2].strip()

		variant = parse_variant(tile_id, variant_pic)

		assert tile_id not in variant_for_tile_id, tile_id
		variant_for_tile_id[tile_id] = variant

		configs = list(parse_config_pics(config_pics))
		
		for config in configs:
			assert config not in tile_id_for_config, config
			tile_id_for_config[config] = tile_id

		# print(block)
		# print(variant, configs)
		# input()

	return tile_id_for_config, variant_for_tile_id

def run() -> None:
	schema_path = settings.package_root / 'autotile' / 'schema.txt'

	with schema_path.open() as schema_file:
		schema = schema_file.read()

	tile_id_for_config, variant_for_tile_id = parse_schema(schema)

	output_path1 = settings.package_root / 'autotile' / 'tile_id_for_config.pickle'

	with output_path1.open('wb') as output_file:
		pickle.dump(tile_id_for_config, output_file)

	output_path2 = settings.package_root / 'autotile' / 'variant_for_tile_id.pickle'

	with output_path2.open('wb') as output_file:
		pickle.dump(variant_for_tile_id, output_file)

if __name__ == '__main__':
	run()