from enum import Enum
from dataclasses import dataclass
from typing import assert_never
import numpy as np

class Corner(Enum):
    TL = (0, 0)
    """Top left"""
    TR = (1, 0)
    """Top right"""
    BL = (0, 1)
    """Bottom left"""
    BR = (1, 1)
    """Bottom right"""

@dataclass
class Variant:
    """A possible appearance of an abstract autotile (divorced from any
    particular autotile file).

    An autotile variant consists of an assignment of a "subtile position" to
    each of the autotile's corners. Each subtile position is used to cut out a
    "subtile" from the autotile file. I call them "subtiles" because they are a
    quarter of the size of an ordinary file. The subtiles are placed together
    at each corner to make up the complete tile.

    The positions are measured in units of subtiles (e.g. a position of (1, 2)
    corresponds to the subtile in the second row and third column within the
    autotile file, if it's divided evenly into subtiles).
    """

    tile_id: int
    """You can use this to determine the tile ID that RPG Maker will assign the
    autotile when it is placed on a map with this appearance. The tile ID will
    be this number plus 48 times the index of the autotile within the tileset's
    autotile list."""

    tl_pos: tuple[int, int]
    """The position of the top left subtile."""

    tr_pos: tuple[int, int]
    """The position of the top right subtitle."""

    bl_pos: tuple[int, int]
    """The position of the bottom left subtitle."""

    br_pos: tuple[int, int]
    """The position of the bottom right subtitle."""

    def pos(self, corner: Corner) -> tuple[int, int]:
        """Map a corner to the position of the subtile in that corner."""
        match corner:
            case Corner.TL:
                return self.tl_pos
            case Corner.TR:
                return self.tr_pos
            case Corner.BL:
                return self.bl_pos
            case Corner.BR:
                return self.br_pos
            case _:
                assert_never(corner)
