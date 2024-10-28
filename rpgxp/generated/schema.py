from dataclasses import dataclass
from typing import Optional
import numpy as np
from rpgxp.common import *

@dataclass
class Actor:
    id_: int
    name: str
    class_id: list[Class]
    initial_level: int
    final_level: int
    exp_basis: int
    exp_inflation: int
    character_name: str
    character_hue: int
    battler_name: str
    battler_hue: int
    parameters: np.ndarray
    weapon_id: Optional[list[Weapon]]
    armor1_id: Optional[list[Armor]]
    armor2_id: Optional[list[Armor]]
    armor3_id: Optional[list[Armor]]
    armor4_id: Optional[list[Armor]]
    weapon_fix: bool
    armor1_fix: bool
    armor2_fix: bool
    armor3_fix: bool
    armor4_fix: bool

@dataclass
class Animation:
    id_: int
    name: str
    animation_name: str
    animation_hue: int
    position: AnimationPosition
    frame_max: int
    frames: list[AnimationFrame]
    timings: list[AnimationTiming]

@dataclass
class AnimationFrame:
    cell_max: int
    cell_data: np.ndarray

@dataclass
class AnimationTiming:
    frame: int
    se: AudioFile
    flash_scope: AnimationTimingFlashScope
    flash_color: Color
    flash_duration: int
    condition: AnimationTimingCondition

@dataclass
class AudioFile:
    name: str
    volume: int
    pitch: int

@dataclass
class Color:
    red: float
    green: float
    blue: float
    alpha: float

@dataclass
class Armor:
    id_: int
    name: str
    icon_name: str
    description: str
    kind: ArmorKind
    auto_state_id: Optional[list[State]]
    price: int
    pdef: int
    mdef: int
    eva: int
    str_plus: int
    dex_plus: int
    agi_plus: int
    int_plus: int
    guard_element_set: set[int]
    guard_state_set: set[Optional[list[State]]]

@dataclass
class Class:
    id_: int
    name: str
    position: ClassPosition
    weapon_set: set[Optional[list[Weapon]]]
    armor_set: set[Optional[list[Armor]]]
    element_ranks: np.ndarray
    state_ranks: np.ndarray
    learnings: list[ClassLearning]

@dataclass
class ClassLearning:
    level: int
    skill_id: list[Skill]

@dataclass
class CommonEvent:
    id_: int
    name: str
    trigger: CommonEventTrigger
    switch_id: int

@dataclass
class Enemy:
    id_: int
    name: str
    battler_name: str
    battler_hue: int
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
    animation1_id: Optional[list[Animation]]
    animation2_id: Optional[list[Animation]]
    element_ranks: np.ndarray
    state_ranks: np.ndarray
    actions: list[EnemyAction]
    exp: int
    gold: int
    item_id: Optional[list[Item]]
    weapon_id: Optional[list[Weapon]]
    armor_id: Optional[list[Armor]]
    treasure_prob: int

@dataclass
class EnemyAction:
    kind: EnemyActionKind
    basic: EnemyBasicAction
    skill_id: Optional[list[Skill]]
    condition_turn_a: int
    condition_turn_b: int
    condition_hp: int
    condition_level: int
    condition_switch_id: int
    rating: int

@dataclass
class Item:
    id_: int
    name: str
    icon_name: str
    description: str
    scope: Scope
    occasion: Occasion
    animation1_id: Optional[list[Animation]]
    animation2_id: Optional[list[Animation]]
    menu_se: AudioFile
    common_event_id: Optional[list[CommonEvent]]
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
    element_set: set[int]
    plus_state_set: set[Optional[list[State]]]
    minus_state_set: set[Optional[list[State]]]

@dataclass
class Map:
    tileset_id: list[Tileset]
    width: int
    height: int
    autoplay_bgm: bool
    bgm: AudioFile
    autoplay_bgs: bool
    bgs: AudioFile
    encounter_list: list[list[Troop]]
    encounter_step: int
    data: np.ndarray
    events: dict[int, Event]

@dataclass
class Event:
    id_: int
    name: str
    x: int
    y: int
    pages: list[EventPage]

@dataclass
class EventPage:
    condition: EventPageCondition
    graphic: EventPageGraphic
    move_type: MoveType
    move_frequency: MoveFrequency
    move_speed: MoveSpeed
    move_route: MoveRoute
    walk_anime: bool
    step_anime: bool
    direction_fix: bool
    through: bool
    always_on_top: bool
    trigger: EventPageTrigger

@dataclass
class EventPageCondition:
    switch1_valid: bool
    switch2_valid: bool
    variable_valid: bool
    self_switch_valid: bool
    switch1_id: int
    switch2_id: int
    variable_id: int
    variable_value: int
    self_switch_ch: str

@dataclass
class EventPageGraphic:
    tile_id: int
    character_name: str
    character_hue: int
    direction: Direction
    pattern: int
    opacity: int
    blend_type: int

@dataclass
class MoveRoute:
    repeat: bool
    skippable: bool

@dataclass
class MapInfo:
    name: str
    parent_id: Optional[dict[int, MapInfo]]
    order: int
    expanded: bool
    scroll_x: int
    scroll_y: int

@dataclass
class Script:
    id_: int
    name: str
    content: str

@dataclass
class Skill:
    id_: int
    name: str
    icon_name: str
    description: str
    scope: Scope
    occasion: Occasion
    animation1_id: Optional[list[Animation]]
    animation2_id: Optional[list[Animation]]
    menu_se: AudioFile
    common_event_id: Optional[list[CommonEvent]]
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
    element_set: set[int]
    plus_state_set: set[Optional[list[State]]]
    minus_state_set: set[Optional[list[State]]]

@dataclass
class State:
    id_: int
    name: str
    animation_id: Optional[list[Animation]]
    restriction: StateRestriction
    nonresistance: bool
    zero_hp: bool
    cant_get_exp: bool
    cant_evade: bool
    slip_damage: bool
    rating: int
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
    guard_element_set: set[int]
    plus_state_set: set[Optional[list[State]]]
    minus_state_set: set[Optional[list[State]]]

@dataclass
class System:
    magic_number: int
    party_members: list[list[Actor]]
    elements: list[str]
    switches: list[str]
    variables: list[str]
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
    start_map_id: Optional[dict[tuple[str], Map]]
    start_x: int
    start_y: int
    test_battlers: list[SystemTestBattler]
    test_troop_id: Optional[list[Troop]]
    battleback_name: str
    battler_name: str
    battler_hue: int
    edit_map_id: Optional[dict[tuple[str], Map]]
    _: int

@dataclass
class SystemWords:
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

@dataclass
class SystemTestBattler:
    actor_id: list[Actor]
    level: int
    weapon_id: Optional[list[Weapon]]
    armor1_id: Optional[list[Armor]]
    armor2_id: Optional[list[Armor]]
    armor3_id: Optional[list[Armor]]
    armor4_id: Optional[list[Armor]]

@dataclass
class Tileset:
    id_: int
    name: str
    tileset_name: str
    autotile_names: list[str]
    panorama_name: str
    panorama_hue: int
    fog_name: str
    fog_hue: int
    fog_opacity: int
    fog_blend_type: int
    fog_zoom: int
    fog_sx: int
    fog_sy: int
    battleback_name: str
    passages: np.ndarray
    priorities: np.ndarray
    terrain_tags: np.ndarray

@dataclass
class Troop:
    id_: int
    name: str
    members: list[TroopMember]
    pages: list[TroopPage]

@dataclass
class TroopMember:
    enemy_id: list[Enemy]
    x: int
    y: int
    hidden: bool
    immortal: bool

@dataclass
class TroopPage:
    condition: TroopPageCondition
    span: TroopPageSpan

@dataclass
class TroopPageCondition:
    turn_valid: bool
    enemy_valid: bool
    actor_valid: bool
    switch_valid: bool
    turn_a: int
    turn_b: int
    enemy_index: int
    enemy_hp: int
    actor_id: Optional[list[Actor]]
    actor_hp: int
    switch_id: int

@dataclass
class Weapon:
    id_: int
    name: str
    icon_name: str
    description: str
    animation1_id: Optional[list[Animation]]
    animation2_id: Optional[list[Animation]]
    price: int
    atk: int
    pdef: int
    mdef: int
    str_plus: int
    dex_plus: int
    agi_plus: int
    int_plus: int
    element_set: set[int]
    plus_state_set: set[Optional[list[State]]]
    minus_state_set: set[Optional[list[State]]]