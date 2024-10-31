from enum import Enum, StrEnum
import struct
from typing import Self

class SelfSwitch(StrEnum):
    A = 'A'
    B = 'B'
    C = 'C'
    D = 'D'

class ChoicesCancelType(Enum):
    DISALLOW = 0
    CHOICE1 = 1
    CHOICE2 = 2
    CHOICE3 = 3
    CHOICE4 = 4
    BRANCH = 5

class TextPosition(Enum):
    TOP = 0
    MIDDLE = 1
    BOTTOM = 2

class SwitchState(Enum):
    ON = 0
    OFF = 1

class Comparison(Enum):
    EQ = 0
    GE = 1
    LE = 2
    GT = 3
    LT = 4
    NE = 5

class Direction(Enum):
    NONE = 0
    DOWN = 2
    LEFT = 4
    RIGHT = 6
    UP = 8

class BoundType(Enum):
    LOWER = 0
    UPPER = 1

class Button(Enum):
    # values are a guess based on the order in the RMXP UI
    DOWN = 0
    LEFT = 1
    RIGHT = 2
    UP = 3
    A = 4
    B = 5
    C = 6
    X = 7
    Y = 8
    Z = 9
    L = 10
    R = 11

class ConditionType(Enum):
    SWITCH = 0 # [switch id, 0=on/1=off]
    VARIABLE = 1 # [variable1id, 0forconstant?, variable2id, operator]
    SELF_SWITCH = 2
    TIMER = 3
    ACTOR = 4
    ENEMY = 5
    CHARACTER = 6
    GOLD = 7
    ITEM = 8
    WEAPON = 9
    ARMOR = 10
    BUTTON = 11
    SCRIPT = 12

class AssignType(Enum):
    SUBSTITUTE = 0
    ADD = 1
    SUBTRACT = 2
    MULTIPLY = 3
    DIVIDE = 4
    REMAINDER = 5
    
class OperandType(Enum):
    INVARIANT = 0
    FROM_VARIABLE = 1
    RANDOM_NUMBER = 2
    ITEM = 3
    ACTOR = 4
    ENEMY = 5
    CHARACTER = 6
    OTHER = 7
    
class OtherOperandType(Enum):
    MAP_ID = 0
    PARTY_SIZE = 1
    GOLD = 2
    STEP_COUNT = 3
    PLAY_TIME = 4
    TIMER = 5
    SAVE_COUNT = 6

class AppointType(Enum):
    DIRECT = 0
    VARIABLE = 1
    EXCHANGE = 2

class Weather(Enum):
    NONE = 0 
    RAIN = 1
    STORM = 2
    SNOW = 3

class DiffType(Enum):
    INCREASE = 0
    DECREASE = 1

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
