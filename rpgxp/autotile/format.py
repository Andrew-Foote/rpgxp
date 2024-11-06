import functools as ft
import pickle
import numpy as np
from PIL import Image as image
from PIL.Image import Image
from rpgxp import settings
from rpgxp.autotile.variant import Corner, Variant

TILE_SIZE = 32
SUBTILE_SIZE = TILE_SIZE // 2

@ft.cache
def tile_id_for_config_mapping() -> dict[int, int]:
    schema_path = settings.package_root / 'autotile' / 'tile_id_for_config.pickle'

    with schema_path.open('rb') as schema_file:
        return pickle.load(schema_file)

@ft.cache
def variant_for_tile_id_mapping() -> dict[int, Variant]:
    schema_path = settings.package_root / 'autotile' / 'variant_for_tile_id.pickle'

    with schema_path.open('rb') as schema_file:
        return pickle.load(schema_file)

def tile_from_tile_id(autotile_image: Image, tile_id: int) -> Image:
    variant = variant_for_tile_id_mapping()[tile_id]
    return tile_from_variant(autotile_image, variant)

def tile_from_config(autotile_image: Image, config: int) -> Image:
    tile_id = tile_id_for_config_mapping()[config]
    variant = variant_for_tile_id_mapping()[tile_id]
    return tile_from_variant(autotile_image, variant)

def tile_from_variant(autotile_image: Image, variant: Variant) -> Image:
    result = image.new(autotile_image.mode, (TILE_SIZE, TILE_SIZE))

    for corner in Corner:
        crop_tl = np.array(variant.pos(corner)) * SUBTILE_SIZE
        crop_br = crop_tl + SUBTILE_SIZE
        subtile = autotile_image.crop((*crop_tl, *crop_br))
        corner_coords = tuple(np.array(corner.value) * SUBTILE_SIZE)
        result.paste(subtile, corner_coords)

    return result
