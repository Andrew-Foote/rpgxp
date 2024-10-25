"""
This file contains class declarations for RPG Maker XP objects. As well as
defining representations of these objects as Python objects, these declarations
are also used to auto-generate "parsers" and "dumpers" for these objects.
Parsers are functions which turn parsed Marshal data into one of the Python
objects defined in this file. Dumpers are functions which turn the Python
objects into database rows.

To aid in the generation of parsers and dumpers, many of the attributes on
classes in this file have additional annotations (besides their type),
specified using typing.Annotated. The following kinds of additional annotations
are used:

  - An attribute of type `int` may be annotated with a `range`, indicating that
    the value must fall within this range.

  - An attribute of type `int` may be annotated with a subclass of `RPG` or
    `RPGListItem`, indicating the value must be the ID of an instance of the
    subclass.

  - An attribute of type `list` may be annotated with an `int`, indicating that
    the list must have the specified length.

  - An attribute of type `list` may be annotated with a tuple of types, and a
    type, indicating that the list's first items must match those in the tuple,
    and the rest must match those in the other type. For example,

      Annotated[int | None, (None,), int]

    indicates that the first item of the list must be None, and the remaining
    items must be ints.

  - An attribute of type `np.ndarray` may be annotated with an `int`,
    indicating that the array must have the specified number of dimensions.
"""

from abc import ABC
from dataclasses import dataclass
from enum import Enum
import numpy as np
from typing import Annotated, Self

Hue = Annotated[int, range(361)]

class RPGListItem:
    pass

class RPG:
    pass

class EventCommand(RPG):
    code: int
    indent: int
    parameters: list

class MoveCommand(RPG):
    code: int
    parameters: list

class Element(RPGListItem):
    id_: int
    name: str

class Switch(RPGListItem):
    id_: int
    name: str

class Variable(RPGListItem):
    id_: int
    name: str

class Color(RPG):
    red: Annotated[int, range(256)]
    green: Annotated[int, range(256)]
    blue: Annotated[int, range(256)]
    alpha: Annotated[int, range(256)]

class AudioFile(RPG):
    name: str
    volume: int
    pitch: int

@dataclass
class Tileset(RPG):
    id_: int
    name: str
    tileset_name: str
    autotile_names: Annotated[list[str], 7]
    panorama_name: str
    panorama_hue: Hue
    fog_name: str
    fog_hue: Hue
    fog_opacity: int
    fog_blend_type: int
    fog_zoom: int
    fog_sx: int
    fog_sy: int
    battleback_name: str
    passages: Annotated[np.ndarray, 1]
    priorities: Annotated[np.ndarray, 1]
    terrain_tags: Annotated[np.ndarray, 1]

class AnimationPosition(Enum):
    TOP = 0
    MIDDLE = 1
    BOTTOM = 2
    SCREEN = 3

class AnimationFrame(RPG):
    cell_max: int
    cell_data: Annotated[np.ndarray, 2]

class AnimationTimingFlashScope:
    NONE = 0
    TARGET = 1
    SCREEN = 2
    DELETE_TARGET = 3

class AnimationTimingCondition(Enum):
    NONE = 0
    HIT = 1
    MISS = 2

class AnimationTiming(RPG):
    frame: int
    se: AudioFile
    flash_scope: AnimationTimingFlashScope
    flash_color: Color
    flash_duration: int
    condition: AnimationTimingCondition

class Animation(RPG):
    id_: int
    name: str
    animation_name: str
    animation_hue: Hue
    position: AnimationPosition
    frame_max: int
    frames: list[AnimationFrame]
    timings: list[AnimationTiming]

class CommonEventTrigger(Enum):
    NONE = 0
    AUTORUN = 1
    PARALLEL = 2

class CommonEvent(RPG):
    id_: int
    name: str
    trigger: CommonEventTrigger
    switch_id: Annotated[int, Switch]
    list_: list[EventCommand]

class StateRestriction(Enum):
    NONE = 0
    CANT_USE_MAGIC = 1
    ALWAYS_ATTACK_ENEMIES = 2
    ALWAYS_ATTACK_ALLIES = 3
    CANT_MOVE = 4

class State(RPG):
    id_: int
    name: str
    animation1_id: Annotated[int, Animation]
    animation2_id: Annotated[int, Animation]
    restriction: StateRestriction
    nonresistance: bool
    zero_hp: bool
    cant_get_exp: bool
    cant_evade: bool
    slip_damage: bool
    rating: Annotated[int, range(11)]
    hit_rate: int
    maxhp_rate: int
    maxsp_rate: int
    str_rate: int
    dex_rate: int
    agi_rate: int
    int_rate: int
    atk_rate: int
    pdef_rate: int
    mdef_rate: int
    eva: int
    battle_only: bool
    hold_turn: int
    auto_release_prob: int
    shock_release_prob: int
    guard_element_set: set[Annotated[int, Element]]
    plus_state_set: set[Annotated[int, 'State']]
    minus_state_set: set[Annotated[int, 'State']]

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

class Skill(RPG):
    id_: int
    name: str
    icon_name: str
    description: str
    scope: Scope
    occasion: Occasion
    animation1_id: Annotated[int, Animation]
    animation2_id: Annotated[int, Animation]
    menu_se: AudioFile
    common_event_id: Annotated[int, CommonEvent]
    sp_cost: int
    power: int
    atk_f: int
    eva_f: int
    str_f: int
    dex_f: int
    agi_f: int
    int_f: int
    hit: int
    pdef_f: int
    mdef_f: int
    variance: int
    element_set: set[Annotated[int, Element]]
    plus_state_set: set[Annotated[int, State]]
    minus_state_set: set[Annotated[int, State]]

class ClassPosition(Enum):
    FRONT = 0
    MIDDLE = 1
    REAR = 2

class Weapon(RPG):
    id_: int
    name: str
    icon_name: str
    description: str
    animation1_id: Annotated[int, Animation]
    animation2_id: Annotated[int, Animation]
    price: int
    atk: int
    pdef: int
    mdef: int
    str_plus: int
    dex_plus: int
    agi_plus: int
    int_plus: int
    element_set: set[Annotated[int, Element]]
    plus_state_set: set[Annotated[int, Element]]
    minus_state_set: set[Annotated[int, Element]]

class ArmorKind(Enum):
    SHIELD = 0
    HELMET = 1
    BODY_ARMOR = 2
    ACCESSORY = 3

class Armor(RPG):
    id_: int
    name: str
    icon_name: str
    description: str
    kind: ArmorKind
    auto_state: Annotated[int, State]
    price: int
    pdef: int
    mdef: int
    eva: int
    str_plus: int
    dex_plus: int
    agi_plus: int
    int_plus: int
    guard_element_set: set[Annotated[int, Element]]
    guard_state_set: set[Annotated[int, State]]

class ClassLearning(RPG):
    level: int
    skill_id: Annotated[int, Skill]

class Class(RPG):
    id: int
    name: str
    position: ClassPosition
    weapon_set: set[Weapon]
    armor_set: set[Armor]
    element_ranks: Annotated[np.ndarray, 1]
    state_ranks: Annotated[np.ndarray, 1]
    learnings: list[ClassLearning]

class Actor(RPG):
    id_: int
    name: str
    class_id: Annotated[int, Class]
    initial_level: int
    final_level: int
    exp_basis: Annotated[int, range(10, 51)]
    exp_inflation: Annotated[int, range(10, 51)]
    character_name: str
    character_hue: Hue
    battler_name: str
    battler_hue: Hue
    parameters: Annotated[np.ndarray, 2]
    weapon_id: Annotated[int, Weapon]
    armor1_id: Annotated[int, Armor]
    armor2_id: Annotated[int, Armor]
    armor3_id: Annotated[int, Armor]
    armor4_id: Annotated[int, Armor]
    weapon_fix: bool
    armor1_fix: bool
    armor2_fix: bool
    armor3_fix: bool
    armor4_fix: bool

class ParameterType(Enum):
    NONE = 0
    MAX_HP = 1
    MAX_SP = 2
    STRENGTH = 3
    DEXTERITY = 4
    AGILITY = 5
    INTELLIGENCE = 6

class Item(RPG):
    id_: int
    name: str
    icon_name: str
    description: str
    scope: Scope
    occasion: Occasion
    animation1_id: Annotated[int, Animation]
    animation2_id: Annotated[int, Animation]
    menu_se: AudioFile
    common_event_id: Annotated[int, CommonEvent]
    price: int
    consumable: bool
    parameter_type: ParameterType
    parameter_points: int
    recover_hp_rate: int
    recover_hp: int
    recover_sp_rate: int
    recover_sp: int
    hit: int
    pdef_f: int
    mdef_f: int
    variance: int
    element_set: set[Annotated[int, Element]]
    plus_state_set: set[Annotated[int, State]]
    minus_state_set: set[Annotated[int, State]]

class EnemyActionKind(Enum):
    BASIC = 0
    SKILL = 1

class EnemyBasicAction(Enum):
    ATTACK = 0
    DEFEND = 1
    ESCAPE = 2
    DO_NOTHING = 3

class EnemyAction(RPG):
    kind: EnemyActionKind
    basic: EnemyBasicAction
    skill_id: Annotated[int, Skill]
    condition_turn_a: int
    condition_turn_b: int
    condition_hp: int
    condition_level: int
    condition_switch_id: Annotated[int, Switch]
    rating: Annotated[int, range(1, 11)]

class Enemy(RPG):
    id_: int
    name: str
    battler_name: str
    battler_hue: Hue
    maxhp: int
    maxsp: int
    str_: int
    dex: int
    agi: int
    int_: int
    atk: int
    pdef: int
    mdef: int
    eva: int
    animation1_id: Annotated[int, Animation]
    animation2_id: Annotated[int, Animation]
    element_ranks: Annotated[np.ndarray, 1]
    state_ranks: Annotated[np.ndarray, 1]
    actions: list[EnemyAction]
    exp: int
    gold: int
    item_id: Annotated[int, Item]
    weapon_id: Annotated[int, Weapon]
    armor_id: Annotated[int, Armor]
    treasure_prob: int

class TroopMember(RPG):
    enemy_id: Annotated[int, Enemy]
    x: int
    y: int
    hidden: bool
    immortal: bool

class TroopPageCondition(RPG):
    turn_valid: bool
    enemy_valid: bool
    actor_valid: bool
    switch_valid: bool
    turn_a: int
    turn_b: int
    enemy_index: Annotated[int, range(8)]
    enemy_hp: int
    actor_id: Annotated[int, Actor]
    actor_hp: int
    switch_id: Annotated[int, Switch]

class TroopPageSpan(Enum):
    BATTLE = 0
    TURN = 1
    MOMENT = 2

class TroopPage(RPG):
    condition: TroopPageCondition
    span: TroopPageSpan
    list_: list[EventCommand]

class Troop(RPG):
    id_: int
    name: str
    members: list[TroopMember]
    pages: list[TroopPage]

class EventPageCondition(RPG):
    switch1_valid: bool
    switch2_valid: bool
    variable_valid: bool
    self_switch_valid: bool
    switch1_id: int
    switch2_id: int
    variable_id: int
    variable_value: int
    self_switch_ch: str

class Direction(Enum):
    DOWN = 2
    LEFT = 4
    RIGHT = 6
    UP = 8

class EventPageGraphic(RPG):
    tile_id: int
    character_name: str
    character_hue: Hue
    direction: Direction
    pattern: Annotated[int, range(4)]
    opacity: int
    blend_type: int

class EventPageMoveType(Enum):
    FIXED = 0
    RANDOM = 1
    APPROACH = 2
    CUSTOM = 3

class EventPageMoveSpeed(Enum):
    SLOWEST = 1
    SLOWER = 2
    SLOW = 3
    FAST = 4
    FASTER = 5
    FASTEST = 6

class EventPageMoveFrequency(Enum):
    LOWEST = 1
    LOWER = 2
    LOW = 3
    HIGH = 4
    HIGHER = 5
    HIGHEST = 6

class MoveRoute(RPG):
    repeat: bool
    skippable: bool
    list_: list[MoveCommand]

class EventPageTrigger(Enum):
    ACTION_BUTTON = 0
    CONTACT_WITH_PLAYER = 1
    CONTACT_WITH_EVENT = 2
    AUTORUN = 3
    PARALLEL_PROCESSING = 4

class EventPage(RPG):
    condition: EventPageCondition
    graphic: EventPageGraphic
    move_type: EventPageMoveType
    move_speed: EventPageMoveSpeed
    move_frequency: EventPageMoveFrequency
    move_route: MoveRoute
    walk_anime: bool
    step_anime: bool
    direction_fix: bool
    through: bool
    always_on_top: bool
    trigger: EventPageTrigger
    list_: list[EventCommand]

class Event(RPG):
    id: int
    name: str
    x: int
    y: int
    pages: list[EventPage]

class Map(RPG):
    tileset_id: Annotated[int, Tileset]
    width: int
    height: int
    autoplay_bgm: bool
    bgm: AudioFile
    autoplay_bgs: bool
    bgs: AudioFile
    encounter_list: list[Annotated[int, Troop]]
    encounter_step: int
    data: Annotated[np.ndarray, 3]
    events: dict[Annotated[int, Event], Event]

@dataclass
class MapInfo(RPG):
    name: str
    parent_id: Annotated[int, Map]
    order: int
    expanded: bool
    scroll_x: int
    scroll_y: int

class SystemWords(RPG):
    gold: str
    hp: str
    sp: str
    str_: str
    dex: str
    agi: str
    int_: str
    atk: str
    pdef: str
    mdef: str
    weapon: str
    armor1: str 
    armor2: str
    armor3: str
    armor4: str
    attack: str
    skill: str
    guard: str
    item: str
    equip: str

class SystemTestBattler(RPG):
    actor_id: Annotated[int, Actor]
    level: int
    weapon_id: Annotated[int, Weapon]
    armor1_id: Annotated[int, Armor]
    armor2_id: Annotated[int, Armor]
    armor3_id: Annotated[int, Armor]
    armor4_id: Annotated[int, Armor]

class System(RPG):
    magic_number: int
    party_members: list[Annotated[int, Actor]]
    elements: list[Annotated[int, Element]]
    switches: list[Annotated[int, Switch]]
    variables: list[Annotated[int, Variable]]
    windowskin_name: str
    title_name: str
    gameover_name: str
    battle_transition: str
    title_bgm: AudioFile
    battle_bgm: AudioFile
    battle_end_me: AudioFile
    gameover_me: AudioFile
    cursor_se: AudioFile
    decision_se: AudioFile
    cancel_se: AudioFile
    buzzer_se: AudioFile
    equip_se: AudioFile
    shop_se: AudioFile
    save_se: AudioFile
    load_se: AudioFile
    battle_start_se: AudioFile
    escape_se: AudioFile
    actor_collapse_se: AudioFile
    enemy_collapse_se: AudioFile
    words: SystemWords
    start_map_id: Annotated[int, Map]
    start_x: int
    start_y: int
    test_battlers: list[SystemTestBattler]
    test_troop_id: Annotated[int, Troop]
    battleback_name: str
    battler_name: str
    battler_hue: Hue
    edit_map_id: Annotated[int, Map]

type ListWithFirstItemNull[T] = Annotated[list[T | None], (None,), T]

FILES = {
    'Actors.rxdata': ListWithFirstItemNull[Actor],
    'Animations.rxdata': ListWithFirstItemNull[Animation],
    'Armors.rxdata': ListWithFirstItemNull[Armor],
    'Classes.rxdata': ListWithFirstItemNull[Class],
    'CommonEvents.rxdata': ListWithFirstItemNull[CommonEvent],
    'Enemies.rxdata': ListWithFirstItemNull[Enemy],
    'Items.rxdata': ListWithFirstItemNull[Item],
    re.compile(r'Map(\d\d\d).rxdata'): Map,
    'MapInfos.rxdata': dict[Annotated[int, MapInfo], MapInfo],
    'Scripts.rxdata': list[tuple[int, str, str]],
    'Skills.rxdata': ListWithFirstItemNull[Skill],
    'States.rxdata': ListWithFirstItemNull[State],
    'System.rxdata': System,
    'Tilesets.rxdata': ListWithFirstItemNull[Tileset],
    'Troops.rxdata': ListWithFirstItemNull[Tropp],
    'Weapons.rxdata': ListWithFirstItemNull[Weapon],
}