from enum import Enum
import io
import itertools as it
from pathlib import Path
from typing import assert_never, Iterator
from warnings import warn
import numpy as np
from PIL import Image as image
from PIL.Image import Image
from rpgxp import db, material, settings
from rpgxp.autotile import format as autotile
from rpgxp.util import int_from_digits

TILE_SIZE = 32
IMAGE_MODE = 'RGBA'

MAP_QUERY = '''SELECT
    t.id, tm.name || tm.extension, tm.source,
    m.width, m.height, m.data
FROM map m
JOIN tileset t on t.id = m.tileset_id
JOIN material_best_file tm on tm.type = 'Graphics' and tm.subtype = 'Tilesets'
    and tm.name = t.tileset_name
WHERE m.id = ?'''

AUTOTILE_QUERY = '''SELECT am.name || am.extension, am.source, a."index"
FROM tileset_autotile a
JOIN material_best_file am on am.type = 'Graphics' and am.subtype = 'Autotiles'
    and am.name = a.autotile_name
WHERE a.tileset_id = ?
ORDER BY a."index"
'''

def itertiles(tileset_path: Path) -> Iterator[Image]:
    with image.open(tileset_path).convert(IMAGE_MODE) as tileset:
        w = tileset.width
        h = tileset.height

        for y in range(0, h, TILE_SIZE):
            for x in range(0, w, TILE_SIZE):
                yield tileset.crop((x, y, x + TILE_SIZE, y + TILE_SIZE))

class TileType(Enum):
    BLANK = 0
    AUTO = 1
    REGULAR = 2

def tile_type_from_id(tile_id: int) -> TileType:
    if tile_id < 48:
        return TileType.BLANK
    elif tile_id < 384:
        # TODO: If less than 7 autotiles are assigned to the tileset, should
        # tile IDs corresponding to the missing autotiles be treated as blanks?
        return TileType.AUTO
    else:
        return TileType.REGULAR

def get_autotile_configuration(
    array: np.ndarray, point: tuple[int, int, int]
) -> int:

    # It looks like the autotile configuration only depends on the adjacent
    # tiles in the same layer

    point_array = np.array(point)

    offsets = [np.array((*offset, 0)) for offset in (
        (-1, -1), (0, -1), (1, -1),
        (-1,  0),          (1,  0),
        (-1,  1), (0,  1), (1,  1)
    )]

    adjacents = [point_array + offset for offset in offsets]
    shape_array = np.array(array.shape)

    return int_from_digits([
        (
            not np.all((0 <= adj) & (adj < shape_array))
            or tile_type_from_id(array[tuple(adj)]) == TileType.AUTO
        )
        for adj in adjacents
    ], 2)

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

    # regular tiles

    tileset_root = material.root_for_source(tileset_source)
    tileset_path = tileset_root / 'Graphics' / 'Tilesets' / tileset_name
    regular_tiles = list(itertiles(tileset_path))
    assert regular_tiles

    autotile_rows = dbh.execute(AUTOTILE_QUERY, (tileset_id,)).fetchall()
    autotile_count = len(autotile_rows)
    assert autotile_count <= 7, autotile_count

    autotile_images: list[Image | None] = [None for _ in range(8)]

    for autotile_name, autotile_source, index in autotile_rows:
        assert isinstance(autotile_name, str)
        assert isinstance(autotile_source, str)
        assert isinstance(index, int)
        autotile_root = material.root_for_source(autotile_source)
        autotile_path = autotile_root / 'Graphics' / 'Autotiles' / autotile_name
        autotile_images[index + 1] = image.open(autotile_path).convert(IMAGE_MODE)

    result = image.new(IMAGE_MODE, (width * TILE_SIZE, height * TILE_SIZE))

    # note that it's important that we iterate over z in ascending order, so
    # that we get the correct layering
    for x, y, z in it.product(range(width), range(height), range(depth)):
        tile_id = data_array[x, y, z]
        tile_type = tile_type_from_id(tile_id)

        match tile_type:
            case TileType.BLANK:
                continue
            case TileType.AUTO:
                image_index, tile_index = divmod(tile_id, 48)
                autotile_image = autotile_images[image_index]

                if autotile_image is None:
                    continue
                elif autotile_image.height <= TILE_SIZE:
                    # Autotile file is just one row of tiles (corresponding
                    # to stages of an animation), with no variants based on
                    # adjacent tiles. So just take the first tile in the row.
                    tile = autotile_image.crop((0, 0, TILE_SIZE, TILE_SIZE))
                else:
                    tile = autotile.tile_from_tile_id(
                        autotile_image, tile_index
                    )
            case TileType.REGULAR:
                try:
                    tile = regular_tiles[tile_id - 384]
                except IndexError:
                    warn(
                        f"can't find tile for tile ID {tile_id} in map ID "
                        f"{map_id} at coords ({x}, {y}, {z})"
                    )

                    continue
            case _:
                assert_never(tile_type)

        result.paste(tile, (x * TILE_SIZE, y * TILE_SIZE), tile)
            
    return result

if __name__ == '__main__':
    import argparse
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('map_id', type=int)
    parsed_args = arg_parser.parse_args()
    img = map_image(parsed_args.map_id)
    img.show()
