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
def variant_for_config_mapping() -> dict[int, Variant]:
    schema_path = settings.package_root / 'autotile' / 'schema.pickle'

    with schema_path.open('rb') as schema_file:
        return pickle.load(schema_file)

def configure(autotile_image: Image, config: int) -> Image:
    variant = variant_for_config_mapping()[config]
    result = image.new(autotile_image.mode, (TILE_SIZE, TILE_SIZE))

    for corner in Corner:
        crop_tl = np.array(variant.pos(corner)) * SUBTILE_SIZE
        crop_br = crop_tl + SUBTILE_SIZE
        subtile = autotile_image.crop((*crop_tl, *crop_br))
        corner_coords = tuple(np.array(corner.value) * SUBTILE_SIZE)
        result.paste(subtile, corner_coords)

    return result