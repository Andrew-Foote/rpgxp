from PIL import Image as pil
import numpy as np 

def adjust_hue(image: pil.Image, value: int) -> pil.Image:
    assert image.mode == 'RGBA'

    # RPG Maker XP hue values range from 0 to 360
    # Pillow hue values range from 0 to 256
    scaled_value = np.uint8(((value / 360) * 256) % 256)

    # HSV conversion doesn't preserve the alpha channel
    alpha = image.getchannel('A')

    hsv = image.convert('HSV')
    array = np.array(hsv)
    h = array[:, :, 0]

    with np.errstate(over='ignore'):
        h += scaled_value
    
    hsv_adjusted = pil.fromarray(array, 'HSV')

    adjusted = hsv_adjusted.convert('RGBA')
    adjusted.putalpha(alpha)
    return adjusted

if __name__ == '__main__':
    from rpgxp import settings
    
    img = pil.open(settings.game_root / 'Graphics' / 'Battlers' / 'E_Mage.png')
    
    imga = adjust_hue(img, 300)
    imga.show()