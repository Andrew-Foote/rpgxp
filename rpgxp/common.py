from enum import Enum
import struct
from typing import Self

class AnimationPosition(Enum):
    TOP = 0
    MIDDLE = 1
    BOTTOM = 2
    SCREEN = 3

class AnimationTimingFlashScope(Enum):
    NONE = 0
    TARGET = 1
    SCREEN = 2
    DELETE_TARGET = 3

class AnimationTimingCondition(Enum):
    NONE = 0
    HIT = 1
    MISS = 2

class ArmorKind(Enum):
    SHIELD = 0
    HELMET = 1
    BODY_ARMOR = 2
    ACCESSORY = 3

class ClassPosition(Enum):
    FRONT = 0
    MIDDLE = 1
    REAR = 2

class CommonEventTrigger(Enum):
    NONE = 0
    AUTORUN = 1
    PARALLEL = 2

class EnemyActionKind(Enum):
    BASIC = 0
    SKILL = 1

class EnemyBasicAction(Enum):
    ATTACK = 0
    DEFEND = 1
    ESCAPE = 2
    DO_NOTHING = 3

class Scope(Enum):
    NONE = 0
    ONE_ENEMY = 1
    ALL_ENEMIES = 2
    ONE_ALLY = 3
    ALL_ALLIES = 4
    ONE_ALLY_HP_0 = 5
    ALL_ALLIES_HP_0 = 6
    USER = 7

class Occasion(Enum):
    ALWAYS = 0
    ONLY_IN_BATTLE = 1
    ONLY_FROM_THE_MENU = 2
    NEVER = 3

class ParameterType(Enum):
    NONE = 0
    MAX_HP = 1
    MAX_SP = 2
    STRENGTH = 3
    DEXTERITY = 4
    AGILITY = 5
    INTELLIGENCE = 6

class Direction(Enum):
    DOWN = 2
    LEFT = 4
    RIGHT = 6
    UP = 8

class MoveType(Enum):
    FIXED = 0
    RANDOM = 1
    APPROACH = 2
    CUSTOM = 3

class MoveSpeed(Enum):
    SLOWEST = 1
    SLOWER = 2
    SLOW = 3
    FAST = 4
    FASTER = 5
    FASTEST = 6

class MoveFrequency(Enum):
    LOWEST = 1
    LOWER = 2
    LOW = 3
    HIGH = 4
    HIGHER = 5
    HIGHEST = 6

class EventPageTrigger(Enum):
    ACTION_BUTTON = 0
    CONTACT_WITH_PLAYER = 1
    CONTACT_WITH_EVENT = 2
    AUTORUN = 3
    PARALLEL_PROCESSING = 4

class StateRestriction(Enum):
    NONE = 0
    CANT_USE_MAGIC = 1
    ALWAYS_ATTACK_ENEMIES = 2
    ALWAYS_ATTACK_ALLIES = 3
    CANT_MOVE = 4

class TroopPageSpan(Enum):
    BATTLE = 0
    TURN = 1
    MOMENT = 2
