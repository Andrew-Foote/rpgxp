from dataclasses import dataclass
from enum import Enum
import io
import math
from pathlib import Path
from typing import Iterator
import numpy as np
from PIL import Image as image
from PIL.Image import Image
from rpgxp import db, material, settings
from rpgxp.autotile import format as autotile
from rpgxp.util import int_from_digits

TILE_SIZE = 32

@dataclass
class Autotile:
    id_: int

@dataclass
class RegularTile:
    id_: int

Tile = Autotile | RegularTile

def itertiles(tileset_path: Path) -> Iterator[Image]:
    with image.open(tileset_path).convert('RGBA') as tileset:
        w = tileset.width
        h = tileset.height

        # # first row - autotiles
        # for x in range(0, w, TILE_SIDE_LENGTH):
        #     for _ in range(48):
        #         yield tileset.crop((
        #             x, 0, x + TILE_SIDE_LENGTH, TILE_SIDE_LENGTH
        #         ))

        for y in range(0, h, TILE_SIZE):
            for x in range(0, w, TILE_SIZE):
                yield tileset.crop((x, y, x + TILE_SIZE, y + TILE_SIZE))

MAP_QUERY = '''SELECT
    t.id, tm.name || tm.extension, tm.source,
    m.width, m.height, m.data
FROM map m
JOIN tileset t on t.id = m.tileset_id
JOIN material_best_file tm on tm.type = 'Graphics' and tm.subtype = 'Tilesets'
    and tm.name = t.tileset_name
WHERE m.id = ?'''

AUTOTILE_QUERY = '''SELECT am.name || am.extension, am.source
FROM tileset_autotile a
JOIN material_best_file am on am.type = 'Graphics' and am.subtype = 'Autotiles'
    and am.name = a.autotile_name
WHERE a.tileset_id = ?
ORDER BY a."index"
'''

def map_image(map_id: int) -> Image:
    dbh = db.connect()

    tileset_id, tileset_name, tileset_source, width, height, data = db.row(
        dbh.execute(MAP_QUERY, (map_id,))
    )

    assert isinstance(tileset_id, int)
    assert isinstance(tileset_name, str)
    assert isinstance(tileset_source, str)
    assert isinstance(width, int)
    assert isinstance(height, int)
    assert isinstance(data, bytes)

    data_array = np.load(io.BytesIO(data))
    real_width, real_height, depth = data_array.shape
    assert real_width == width
    assert real_height == height

    autotile_cells: set[tuple[int, int, int]] = set()

    # regular tiles

    tileset_root = material.root_for_source(tileset_source)
    tileset_path = tileset_root / 'Graphics' / 'Tilesets' / tileset_name
    regular_tiles = list(itertiles(tileset_path))
    assert regular_tiles
    mode = regular_tiles[0].mode
    result = image.new(mode, (width * TILE_SIZE, height * TILE_SIZE))

    for z in (0,):#range(depth):
        for x in range(width):
            for y in range(height):
                tile_id = data_array[x, y, z]

                if tile_id < 48:
                    pass
                elif tile_id < 384:
                    autotile_cells.add((x, y, z))
                else:
                    tile = regular_tiles[tile_id - 384]
                    result.paste(tile, (x * TILE_SIZE, y * TILE_SIZE), tile)

    # autotiles

    autotile_rows = dbh.execute(AUTOTILE_QUERY, (tileset_id,)).fetchall()
    autotile_count = len(autotile_rows)
    assert autotile_count == 7, autotile_count

    autotile_images: list[Image] = []

    for autotile_name, autotile_source in autotile_rows:
        assert isinstance(autotile_name, str)
        assert isinstance(autotile_source, str)
        autotile_root = material.root_for_source(autotile_source)
        autotile_path = autotile_root / 'Graphics' / 'Autotiles' / autotile_name
        
        autotile_images.append(image.open(autotile_path).convert('RGBA'))

    for x0, y0, z0 in autotile_cells:
        tile_id = data_array[x0, y0, z0]

        configuration = int_from_digits([
            (
                not (0 <= x < width and 0 <= y < height and 0 <= z < depth)
                or (x, y, z) in autotile_cells
            )
            for x, y, z in [
                (x0 - 1, y0 - 1, z0), (x0, y0 - 1, z0), (x0 + 1, y0 - 1, z0),
                (x0 - 1, y0, z0),                       (x0 + 1, y0, z0),
                (x0 - 1, y0 + 1, z0), (x0, y0 + 1, z0), (x0 + 1, y0 + 1, z0)
            ]
        ], 2)

        autotile_index = tile_id // 48
        autotile_image = autotile_images[autotile_index - 1]
        tile = autotile.configure(autotile_image, configuration)
        result.paste(tile, (x0 * TILE_SIZE, y0 * TILE_SIZE), tile)
            
    return result

if __name__ == '__main__':
    import argparse
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('map_id', type=int)
    parsed_args = arg_parser.parse_args()
    img = map_image(parsed_args.map_id)
    img.show()
