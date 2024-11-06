import io
from pathlib import Path
import numpy as np
from golden import golden_test, update_golden
from rpgxp.tile import map_image_from_data
from PIL import Image as image

@golden_test('.png')
def test_map_image_from_data(input_root: Path) -> bytes:
	map_data = np.load(input_root / 'map_data.npy')
	tileset = image.open(input_root / 'tileset.png')
	
	autotiles = {
		int(p.stem): image.open(p)
		for p in (input_root / 'autotiles').iterdir()
	}

	map_image = map_image_from_data(map_data, tileset, autotiles)

	output = io.BytesIO()
	map_image.save(output, 'png')
	output.seek(0)
	result = output.read()

	tileset.close()

	for autotile_image in autotiles.values():
		autotile_image.close()

	return result