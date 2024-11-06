from collections.abc import Mapping
from contextlib import contextmanager
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

def itertiles(tileset: Image) -> Iterator[Image]:
    w = tileset.width
    h = tileset.height

    for y in range(0, h, TILE_SIZE):
        for x in range(0, w, TILE_SIZE):
            yield tileset.crop((x, y, x + TILE_SIZE, y + TILE_SIZE))

def map_image_from_data(
    map_data: np.ndarray, tileset: Image, autotiles: Mapping[int, Image]
) -> Image:

    assert all(key in range(1, 8) for key in autotiles)
    
    assert all(
        autotile_image.mode == tileset.mode
        for autotile_image in autotiles.values()
    )

    width, height, depth = map_data.shape
    result = image.new(tileset.mode, (width * TILE_SIZE, height * TILE_SIZE))
    regular_tiles = list(itertiles(tileset))

    # note that it's important that we iterate over z in ascending order, so
    # that we get the correct layering
    for x, y, z in it.product(range(width), range(height), range(depth)):
        tile_id = map_data[x, y, z]
        tile_type = tile_type_from_id(tile_id)
        tile: Image

        match tile_type:
            case TileType.BLANK:
                continue
            case TileType.AUTO:
                image_key, adjusted_tile_id = divmod(tile_id, 48)
    
                try:
                    autotile_image = autotiles[image_key]
                except KeyError:
                    continue

                if autotile_image.height <= TILE_SIZE:
                    # Autotile file is just one row of tiles (corresponding
                    # to stages of an animation), with no variants based on
                    # adjacent tiles. So just take the first tile in the row.
                    tile = autotile_image.crop((0, 0, TILE_SIZE, TILE_SIZE))
                else:
                    tile = autotile.tile_from_tile_id(
                        autotile_image, adjusted_tile_id
                    )
            case TileType.REGULAR:
                try:
                    tile = regular_tiles[tile_id - 384]
                except IndexError:
                    warn(f"unrecognized tile ID {tile_id}")
                    continue
            case _:
                assert_never(tile_type)

        result.paste(tile, (x * TILE_SIZE, y * TILE_SIZE), tile)
            
    return result

# This isn't actually used any more, but may be useful in future if we add tile
# editing functionality
def get_autotile_configuration(
    map_data: np.ndarray, coords: tuple[int, int, int]
) -> int:

    coords_array = np.array(coords)

    offsets = [np.array((*offset, 0)) for offset in (
        (-1, -1), (0, -1), (1, -1),
        (-1,  0),          (1,  0),
        (-1,  1), (0,  1), (1,  1)
    )]

    adjacents = [coords_array + offset for offset in offsets]
    shape_array = np.array(map_data.shape)

    return int_from_digits([
        (
            not np.all((0 <= adj) & (adj < shape_array))
            or tile_type_from_id(map_data[tuple(adj)]) == TileType.AUTO
        )
        for adj in adjacents
    ], 2)

def map_data_from_id(map_id: int) -> np.ndarray:
    data = db.fetch_value('SELECT data FROM map WHERE id = ?', [map_id])
    assert isinstance(data, bytes)
    return np.load(io.BytesIO(data))

@contextmanager
def tileset_from_map_id(map_id: int) -> Iterator[Image]:
    source, name = db.fetch_row('''
        SELECT f.source, f.full_name FROM material_best_file f
        JOIN tileset t ON f.type = 'Graphics' AND f.subtype = 'Tilesets'
            AND f.name = t.tileset_name
        JOIN map m ON t.id = m.tileset_id AND m.id = ?
    ''', [map_id])

    assert isinstance(source, str)
    assert isinstance(name, str)

    root = material.root_for_source(source)
    path = root / 'Graphics' / 'Tilesets' / name
    result =  image.open(path).convert('RGBA')

    try:
        yield result
    finally:
        result.close()

@contextmanager
def autotiles_from_map_id(map_id: int) -> Iterator[dict[int, Image]]:
    result: dict[int, Image] = {}

    for source, name, index in db.fetch_rows('''
        SELECT f.source, f.full_name, a."index" FROM material_best_file f
        JOIN tileset_autotile a ON f.type = 'Graphics'
            AND f.subtype = 'Autotiles' AND f.name = a.autotile_name
        JOIN tileset t ON a.tileset_id = t.id
        JOIN map m ON t.id = m.tileset_id AND m.id = ?
    ''', [map_id]):

        assert isinstance(source, str)
        assert isinstance(name, str)
        assert isinstance(index, int)

        root = material.root_for_source(source)
        path = root / 'Graphics' / 'Autotiles' / name
        result[index + 1] = image.open(path).convert('RGBA')

    try:
        yield result
    finally:
        for autotile_image in result.values():
            autotile_image.close()

@contextmanager
def map_image_from_id(map_id: int) -> Iterator[Image]:
    map_data = map_data_from_id(map_id)

    with tileset_from_map_id(map_id) as tileset:
        with autotiles_from_map_id(map_id) as autotiles:
            yield map_image_from_data(map_data, tileset, autotiles)

def save_test_case(
    name: str, map_data: np.ndarray, tileset: Image,
    autotiles: Mapping[int, Image]
) -> None:

    from golden import golden_path

    case_root = (
        golden_path() / 'test_map_image_from_data' / test_case / 'input'
    )

    case_root.mkdir(parents=True, exist_ok=True)
    print(case_root)
    np.save(case_root / 'map_data.npy', map_data)
    tileset.save(case_root / 'tileset.png')
    autotile_root = case_root / 'autotiles'
    autotile_root.mkdir(exist_ok=True)

    for autotile_index, autotile_image in autotiles.items():
        autotile_image.save(autotile_root / f'{autotile_index}.png')

if __name__ == '__main__':
    import argparse

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('map_id', type=int)
    arg_parser.add_argument('--test_case', type=str, default='')
    parsed_args = arg_parser.parse_args()

    map_id = parsed_args.map_id
    test_case = parsed_args.test_case

    map_data = map_data_from_id(map_id)

    with tileset_from_map_id(map_id) as tileset:
        with autotiles_from_map_id(map_id) as autotiles:
            if test_case:
                print(test_case)
                save_test_case(test_case, map_data, tileset, autotiles)

            map_image = map_image_from_data(map_data, tileset, autotiles)
            map_image.show()
