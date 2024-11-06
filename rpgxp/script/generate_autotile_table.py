"""
This is more of a one-off script that I used to figure out how the autotiles in
RPG Maker XP work. Specifically, this script was used to figure out
association between an autotile "configuration" and its tile ID. 
 
When you place an autotile on a map, its appearance changes depending on the
surrounding tiles. More precisely, as far as I can tell, the appearance of the
autotile is determined entirely by the 8 immediately surrounding tiles and
whether they are instances of the same autotile or not. Given an autotile
placed on a map, its "configuration" is what I call the array of 8 Boolean
indicating which of the surrounding tiles are instances of the same autotile.
(1 = instance of same, 0 = not that). Since each element of the array has 2
possible values there are 2^8 = 256 possible configurations.

Now, the base appearance of each map is determined from its 'data' field, whose
value is a 3-dimensional array of "tile IDs", each referencing a tile. I was
able to figure out already that the tile IDs from 0 to 383 are used for
autotiles, and the tiles from 384 up are used for the regular tiles in the
tileset. The regular tile IDs are assigned in a fairly straightforward way. If
you look at the tileset graphic, and split it up into rows of 8 tiles, each 32
pixels wide and 32 pixels tall, then the first row contains the autotiles,
while the remaining rows contain the regular tiles. So, starting on the second
row, and reading from left to right, top to bottom, you obtain a sequence of
regular tiles, and the tile IDs are simply their indices within that sequence
plus 384.

For autotiles it's more complicated, since each autotile is associated with a
range of possible appearances. So although there are only 8 autotiles as in
distinct choices of autotile to place on the map, there are, potentially, 256
possible appearances for each autotile once it's placed. Of course they don't
all have to be distinct, and the fact that 384 / 8 = 48 suggests each autotile
has 48 distinct appearances, each with its own tile ID. But I had no idea what
the mapping from tile IDs to appearances would look like.

So that's where this script comes in. I made a map, saved in this directory as
'AutotileMap.rxdata', consisting of 256 "cells" (arranged in 32 rows of 8 cells
each), one for each possible autotile configuration. The cells were each 3
tiles wide and 3 tiles tall, and were separated by borders consisting of
regular tiles. I chose a particular autotile (namely "001-G_Water01" from the
RGSS RTP library), made every central tile within each cell an instance of this
autotile, and placed other instances of the autotile around it in such a way
that across all the cells, each autotile would occur exactly once. For example,
in the bottom right tile of the cell I put an autotile once every 2 cells. In
the bottom middle tile, I put an autotile once every 4 cells. In the bottom
left tile, I put an autotile once every 4 cells, and so on. Then, I used this
script to extract the tile IDs of each of the central tiles in each cell.
"""

from collections import defaultdict
import itertools as it
from typing import Final
from rpgxp import settings

map_path = settings.project_root / 'rpgxp' / 'script' / 'AutotileMap.rxdata'

with map_path.open('rb') as f:
	data = f.read()

# offset (in bytes) of the 2-byte sequence corresponding to the central tile
# in the first cell
ROW_OFFSET: Final = 0x132

# the span (in number of bytes) between the starts of the 2-byte sequences
# corresponding to the central tiles in the first cells of adjacent rows
ROW_SIZE: Final = 264

# the span (in number of bytes) between the starts of the 2-byte sequences
# corresponding to the central tiles in adjacent cells within the same row
TILE_SIZE: Final = 8

result_array: list[int] = []

for row_number in range(32):
	row_offset = ROW_OFFSET + ROW_SIZE * row_number

	for col_number in range(8):
		tile_offset = row_offset + TILE_SIZE * col_number
		result_array.append(data[tile_offset] - 48)

print(result_array)
input()

# So how do we interpret this array? Well, each index in it corresponds to a
# configuration and the associated value is the tile ID. How do we get the
# configuration from the index? Well, due to the way I arranged the
# configurations across the cells, we can interpret the index as an 8-bit
# sequence where each bit corresponds to one of the 8 cells in the
# configuration, like so (I'm ordering the bits here by significance,
# ascending, so the 8th one is the most significant):
#
#   8th bit  7th bit  6th bit
#   5th bit           4th bit
#   3rd bit  2nd bit  1st bit
#
# When constructing a picture of a map, we'll actually need to map from the
# tile ID to the configuration (well, set of configurations), so we should
# actually turn the array "inside out" and build a hash of tile IDs
# -> configurations.

result_hash = defaultdict(lambda: [])

for configuration, tile_id in enumerate(result_array):
	result_hash[tile_id].append(configuration)

# Let's format the hash so it looks a bit nicer as a constant.

print('{')

for tile_id, configurations in sorted(result_hash.items()):
	configuration_strings = [
		f'0b{bin(configuration)[2:]:>08}'
		for configuration in configurations
	]

	line = ' ' * 4 + f'{tile_id}: [{", ".join(configuration_strings)}],'
	lines = [line]

	if len(line) <= 80:
		lines = [line]
	else:
		confcount = len(configurations)

		for divisor in range(2, confcount):
			if confcount % divisor:
				continue

			batched = it.batched(
				configuration_strings, confcount // divisor
			)

			lines = [
				f'    {tile_id}: [',
				*(
					f' ' * 8 + ', '.join(batch) + ','
					for batch in batched
				),
				' ' * 4 + '],'
			]

			if all(len(line) <= 80 for line in lines):
				break
		else:
			raise Exception('Failed to wrap')

	for line in lines:
		print(line)

print('}')
