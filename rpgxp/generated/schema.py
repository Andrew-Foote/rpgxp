from abc import ABC
from dataclasses import dataclass
from typing import ClassVar, Optional
import numpy as np
from rpgxp.common import *

@dataclass(frozen=True)
class Actor:
    id_: int
    name: str
    class_id: int
    initial_level: int
    final_level: int
    exp_basis: int
    exp_inflation: int
    character_name: str
    character_hue: int
    battler_name: str
    battler_hue: int
    parameters: np.ndarray
    weapon_id: Optional[int]
    armor1_id: Optional[int]
    armor2_id: Optional[int]
    armor3_id: Optional[int]
    armor4_id: Optional[int]
    weapon_fix: bool
    armor1_fix: bool
    armor2_fix: bool
    armor3_fix: bool
    armor4_fix: bool

@dataclass(frozen=True)
class Animation:
    id_: int
    name: str
    animation_name: str
    animation_hue: int
    position: AnimationPosition
    frame_max: int
    frames: list[AnimationFrame]
    timings: list[AnimationTiming]

@dataclass(frozen=True)
class AnimationFrame:
    cell_max: int
    cell_data: np.ndarray

@dataclass(frozen=True)
class AnimationTiming:
    frame: int
    se: AudioFile
    flash_scope: AnimationTimingFlashScope
    flash_color: Color
    flash_duration: int
    condition: AnimationTimingCondition

@dataclass(frozen=True)
class AudioFile:
    name: str
    volume: int
    pitch: int

@dataclass(frozen=True)
class Color:
    red: float
    green: float
    blue: float
    alpha: float

@dataclass(frozen=True)
class Armor:
    id_: int
    name: str
    icon_name: str
    description: str
    kind: ArmorKind
    auto_state_id: Optional[int]
    price: int
    pdef: int
    mdef: int
    eva: int
    str_plus: int
    dex_plus: int
    agi_plus: int
    int_plus: int
    guard_element_set: set[Optional[int]]
    guard_state_set: set[Optional[int]]

@dataclass(frozen=True)
class Class:
    id_: int
    name: str
    position: ClassPosition
    weapon_set: set[Optional[int]]
    armor_set: set[Optional[int]]
    element_ranks: np.ndarray
    state_ranks: np.ndarray
    learnings: list[ClassLearning]

@dataclass(frozen=True)
class ClassLearning:
    level: int
    skill_id: int

@dataclass(frozen=True)
class CommonEvent:
    id_: int
    name: str
    trigger: CommonEventTrigger
    switch_id: Optional[int]
    list_: list[EventCommand]

@dataclass(frozen=True)
class EventCommand(ABC):
    code: ClassVar[int]
    indent: int

@dataclass(frozen=True)
class EventCommand_Blank(EventCommand):
    code = 0

@dataclass(frozen=True)
class EventCommand_ShowText(EventCommand):
    code = 101
    text: str

@dataclass(frozen=True)
class EventCommand_ShowChoices(EventCommand):
    code = 102
    choices: list[str]
    cancel_type: ChoicesCancelType

@dataclass(frozen=True)
class EventCommand_InputNumber(EventCommand):
    code = 103
    variable_id: Optional[int]
    max_digits: int

@dataclass(frozen=True)
class EventCommand_ChangeTextOptions(EventCommand):
    code = 104
    position: TextPosition
    no_frame: bool

@dataclass(frozen=True)
class EventCommand_ButtonInputProcessing(EventCommand):
    code = 105
    variable_id: Optional[int]

@dataclass(frozen=True)
class EventCommand_Wait(EventCommand):
    code = 106
    duration: int

@dataclass(frozen=True)
class EventCommand_Comment(EventCommand):
    code = 108
    text: str

@dataclass(frozen=True)
class EventCommand_ConditionalBranch(EventCommand, ABC):
    code = 111
    subcode: ClassVar[int]

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Switch(EventCommand_ConditionalBranch):
    code = 111
    subcode = 0
    switch_id: Optional[int]
    state: SwitchState

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Variable(EventCommand_ConditionalBranch):
    code = 111
    subcode = 1
    variable_id: int
    value_is_variable: bool
    value: int
    comparison: Comparison

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_SelfSwitch(EventCommand_ConditionalBranch):
    code = 111
    subcode = 2
    self_switch_ch: SelfSwitch
    state: SwitchState

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Timer(EventCommand_ConditionalBranch):
    code = 111
    subcode = 3
    value: int
    bound_type: BoundType

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Actor(EventCommand_ConditionalBranch):
    code = 111
    subcode = 4

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Enemy(EventCommand_ConditionalBranch):
    code = 111
    subcode = 5

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Character(EventCommand_ConditionalBranch):
    code = 111
    subcode = 6
    character_reference: int
    direction: Direction

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Gold(EventCommand_ConditionalBranch):
    code = 111
    subcode = 7
    amount: int
    bound_type: BoundType

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Item(EventCommand_ConditionalBranch):
    code = 111
    subcode = 8

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Weapon(EventCommand_ConditionalBranch):
    code = 111
    subcode = 9

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Armor(EventCommand_ConditionalBranch):
    code = 111
    subcode = 10

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Button(EventCommand_ConditionalBranch):
    code = 111
    subcode = 11
    button: int

@dataclass(frozen=True)
class EventCommand_ConditionalBranch_Script(EventCommand_ConditionalBranch):
    code = 111
    subcode = 12
    expr: str

@dataclass(frozen=True)
class EventCommand_Loop(EventCommand):
    code = 112

@dataclass(frozen=True)
class EventCommand_BreakLoop(EventCommand):
    code = 113

@dataclass(frozen=True)
class EventCommand_ExitEventProcessing(EventCommand):
    code = 115

@dataclass(frozen=True)
class EventCommand_EraseEvent(EventCommand):
    code = 116

@dataclass(frozen=True)
class EventCommand_CallCommonEvent(EventCommand):
    code = 117
    called_event_id: Optional[int]

@dataclass(frozen=True)
class EventCommand_Label(EventCommand):
    code = 118
    id: str

@dataclass(frozen=True)
class EventCommand_JumpToLabel(EventCommand):
    code = 119
    id: str

@dataclass(frozen=True)
class EventCommand_ControlSwitches(EventCommand):
    code = 121
    switch_id_lo: int
    switch_id_hi: int
    state: SwitchState

@dataclass(frozen=True)
class EventCommand_ControlVariables(EventCommand, ABC):
    code = 122
    variable_id_hi: int
    variable_id_lo: int
    assign_type: AssignType
    operand_type: ClassVar[int]

@dataclass(frozen=True)
class EventCommand_ControlVariables_Invariant(EventCommand_ControlVariables):
    code = 122
    operand_type = 0
    value: int

@dataclass(frozen=True)
class EventCommand_ControlVariables_Variable(EventCommand_ControlVariables):
    code = 122
    operand_type = 1
    variable_id: Optional[int]

@dataclass(frozen=True)
class EventCommand_ControlVariables_RandomNumber(EventCommand_ControlVariables):
    code = 122
    operand_type = 2
    lb: int
    ub: int

@dataclass(frozen=True)
class EventCommand_ControlVariables_Character(EventCommand_ControlVariables):
    code = 122
    operand_type = 6
    attr_value: int
    attr_code: int

@dataclass(frozen=True)
class EventCommand_ControlVariables_Other(EventCommand_ControlVariables):
    code = 122
    operand_type = 7
    other_operand_type: OtherOperandType

@dataclass(frozen=True)
class EventCommand_ControlSelfSwitch(EventCommand):
    code = 123
    self_switch_ch: SelfSwitch
    state: SwitchState

@dataclass(frozen=True)
class EventCommand_ControlTimer(EventCommand, ABC):
    code = 124
    subcode: ClassVar[int]

@dataclass(frozen=True)
class EventCommand_ControlTimer_Start(EventCommand_ControlTimer):
    code = 124
    subcode = 0
    initial_value: int

@dataclass(frozen=True)
class EventCommand_ControlTimer_Stop(EventCommand_ControlTimer):
    code = 124
    subcode = 1

@dataclass(frozen=True)
class EventCommand_ChangeGold(EventCommand):
    code = 125
    diff_type: DiffType
    with_variable: bool
    amount: int

@dataclass(frozen=True)
class EventCommand_ChangeBattleBGM(EventCommand):
    code = 132
    audio: AudioFile

@dataclass(frozen=True)
class EventCommand_ChangeMenuAccess(EventCommand):
    code = 135
    enabled: bool

@dataclass(frozen=True)
class EventCommand_TransferPlayer(EventCommand):
    code = 201
    with_variables: bool
    target_map_id: int
    x: int
    y: int
    direction: Direction
    no_fade: bool

@dataclass(frozen=True)
class EventCommand_SetEventLocation(EventCommand):
    code = 202
    event_reference: int
    appoint_type: AppointType
    x: int
    y: int
    direction: Direction

@dataclass(frozen=True)
class EventCommand_ScrollMap(EventCommand):
    code = 203
    direction: Direction
    distance: int
    speed: int

@dataclass(frozen=True)
class EventCommand_ChangeMapSettings(EventCommand, ABC):
    code = 204
    subcode: ClassVar[int]

@dataclass(frozen=True)
class EventCommand_ChangeMapSettings_Panorama(EventCommand_ChangeMapSettings):
    code = 204
    subcode = 0
    name: str
    hue: int

@dataclass(frozen=True)
class EventCommand_ChangeMapSettings_Fog(EventCommand_ChangeMapSettings):
    code = 204
    subcode = 1
    name: str
    hue: int
    opacity: int
    blend_type: int
    zoom: int
    sx: int
    sy: int

@dataclass(frozen=True)
class EventCommand_ChangeMapSettings_BattleBack(EventCommand_ChangeMapSettings):
    code = 204
    subcode = 2
    name: str

@dataclass(frozen=True)
class EventCommand_ChangeFogColorTone(EventCommand):
    code = 205
    tone: Tone
    duration: int

@dataclass(frozen=True)
class EventCommand_ChangeFogOpacity(EventCommand):
    code = 206
    opacity: int
    duration: int

@dataclass(frozen=True)
class EventCommand_ShowAnimation(EventCommand):
    code = 207
    event_reference: int
    animation_id: int

@dataclass(frozen=True)
class EventCommand_ChangeTransparentFlag(EventCommand):
    code = 208
    is_normal: bool

@dataclass(frozen=True)
class EventCommand_SetMoveRoute(EventCommand):
    code = 209
    event_reference: int
    move_route: MoveRoute

@dataclass(frozen=True)
class EventCommand_WaitForMoveCompletion(EventCommand):
    code = 210

@dataclass(frozen=True)
class EventCommand_PrepareForTransition(EventCommand):
    code = 221

@dataclass(frozen=True)
class EventCommand_ExecuteTransition(EventCommand):
    code = 222
    name: str

@dataclass(frozen=True)
class EventCommand_ChangeScreenColorTone(EventCommand):
    code = 223
    tone: Tone
    duration: int

@dataclass(frozen=True)
class EventCommand_ScreenFlash(EventCommand):
    code = 224
    color: Color
    duration: int

@dataclass(frozen=True)
class EventCommand_ScreenShake(EventCommand):
    code = 225
    power: int
    speed: int
    duration: int

@dataclass(frozen=True)
class EventCommand_ShowPicture(EventCommand):
    code = 231
    number: int
    name: str
    origin: int
    appoint_with_vars: bool
    x: int
    y: int
    zoom_x: int
    zoom_y: int
    opacity: int
    blend_type: int

@dataclass(frozen=True)
class EventCommand_MovePicture(EventCommand):
    code = 232
    number: int
    duration: int
    origin: int
    appoint_with_vars: bool
    x: int
    y: int
    zoom_x: int
    zoom_y: int
    opacity: int
    blend_type: int

@dataclass(frozen=True)
class EventCommand_RotatePicture(EventCommand):
    code = 233
    number: int
    speed: int

@dataclass(frozen=True)
class EventCommand_ChangePictureColorTone(EventCommand):
    code = 234
    number: int
    tone: Tone
    duration: int

@dataclass(frozen=True)
class EventCommand_ErasePicture(EventCommand):
    code = 235
    number: int

@dataclass(frozen=True)
class EventCommand_SetWeatherEffects(EventCommand):
    code = 236
    type: Weather
    power: int
    duration: int

@dataclass(frozen=True)
class EventCommand_PlayBGM(EventCommand):
    code = 241
    audio: AudioFile

@dataclass(frozen=True)
class EventCommand_FadeOutBGM(EventCommand):
    code = 242
    seconds: int

@dataclass(frozen=True)
class EventCommand_PlayBGS(EventCommand):
    code = 245
    audio: AudioFile

@dataclass(frozen=True)
class EventCommand_FadeOutBGS(EventCommand):
    code = 246
    seconds: int

@dataclass(frozen=True)
class EventCommand_MemorizeBGAudio(EventCommand):
    code = 247

@dataclass(frozen=True)
class EventCommand_RestoreBGAudio(EventCommand):
    code = 248

@dataclass(frozen=True)
class EventCommand_PlayME(EventCommand):
    code = 249
    audio: AudioFile

@dataclass(frozen=True)
class EventCommand_PlaySE(EventCommand):
    code = 250
    audio: AudioFile

@dataclass(frozen=True)
class EventCommand_StopSE(EventCommand):
    code = 251

@dataclass(frozen=True)
class EventCommand_BattleProcessing(EventCommand):
    code = 301
    opponent_troop_id: Optional[int]
    can_escape: bool
    can_continue_when_loser: bool

@dataclass(frozen=True)
class EventCommand_RecoverAll(EventCommand):
    code = 314
    actor_id: Optional[int]

@dataclass(frozen=True)
class EventCommand_AbortBattle(EventCommand):
    code = 340

@dataclass(frozen=True)
class EventCommand_CallMenuScreen(EventCommand):
    code = 351

@dataclass(frozen=True)
class EventCommand_CallSaveScreen(EventCommand):
    code = 352

@dataclass(frozen=True)
class EventCommand_GameOver(EventCommand):
    code = 353

@dataclass(frozen=True)
class EventCommand_ReturnToTitleScreen(EventCommand):
    code = 354

@dataclass(frozen=True)
class EventCommand_Script(EventCommand):
    code = 355
    line: str

@dataclass(frozen=True)
class EventCommand_ContinueShowText(EventCommand):
    code = 401
    text: str

@dataclass(frozen=True)
class EventCommand_ShowChoicesWhenChoice(EventCommand):
    code = 402
    choice_index: int
    choice_text: str

@dataclass(frozen=True)
class EventCommand_ShowChoicesWhenCancel(EventCommand):
    code = 403

@dataclass(frozen=True)
class EventCommand_ShowChoicesBranchEnd(EventCommand):
    code = 404

@dataclass(frozen=True)
class EventCommand_ContinueComment(EventCommand):
    code = 408
    text: str

@dataclass(frozen=True)
class EventCommand_Else(EventCommand):
    code = 411

@dataclass(frozen=True)
class EventCommand_ConditionalBranchEnd(EventCommand):
    code = 412

@dataclass(frozen=True)
class EventCommand_RepeatAbove(EventCommand):
    code = 413

@dataclass(frozen=True)
class EventCommand_ContinueSetMoveRoute(EventCommand):
    code = 509
    command: MoveCommand

@dataclass(frozen=True)
class EventCommand_IfWin(EventCommand):
    code = 601

@dataclass(frozen=True)
class EventCommand_IfEscape(EventCommand):
    code = 602

@dataclass(frozen=True)
class EventCommand_IfLose(EventCommand):
    code = 603

@dataclass(frozen=True)
class EventCommand_BattleProcessingEnd(EventCommand):
    code = 604

@dataclass(frozen=True)
class EventCommand_ContinueScript(EventCommand):
    code = 655
    line: str

@dataclass(frozen=True)
class Tone:
    red: float
    green: float
    blue: float
    grey: float

@dataclass(frozen=True)
class MoveRoute:
    repeat: bool
    skippable: bool
    list_: list[MoveCommand]

@dataclass(frozen=True)
class MoveCommand(ABC):
    code: ClassVar[int]

@dataclass(frozen=True)
class MoveCommand_Blank(MoveCommand):
    code = 0

@dataclass(frozen=True)
class MoveCommand_MoveDown(MoveCommand):
    code = 1

@dataclass(frozen=True)
class MoveCommand_MoveLeft(MoveCommand):
    code = 2

@dataclass(frozen=True)
class MoveCommand_MoveRight(MoveCommand):
    code = 3

@dataclass(frozen=True)
class MoveCommand_MoveUp(MoveCommand):
    code = 4

@dataclass(frozen=True)
class MoveCommand_MoveLowerLeft(MoveCommand):
    code = 5

@dataclass(frozen=True)
class MoveCommand_MoveLowerRight(MoveCommand):
    code = 6

@dataclass(frozen=True)
class MoveCommand_MoveUpperLeft(MoveCommand):
    code = 7

@dataclass(frozen=True)
class MoveCommand_MoveUpperRight(MoveCommand):
    code = 8

@dataclass(frozen=True)
class MoveCommand_MoveAtRandom(MoveCommand):
    code = 9

@dataclass(frozen=True)
class MoveCommand_MoveTowardPlayer(MoveCommand):
    code = 10

@dataclass(frozen=True)
class MoveCommand_MoveAwayFromPlayer(MoveCommand):
    code = 11

@dataclass(frozen=True)
class MoveCommand_StepForward(MoveCommand):
    code = 12

@dataclass(frozen=True)
class MoveCommand_StepBackward(MoveCommand):
    code = 13

@dataclass(frozen=True)
class MoveCommand_Jump(MoveCommand):
    code = 14
    x: int
    y: int

@dataclass(frozen=True)
class MoveCommand_Wait(MoveCommand):
    code = 15
    duration: int

@dataclass(frozen=True)
class MoveCommand_TurnDown(MoveCommand):
    code = 16

@dataclass(frozen=True)
class MoveCommand_TurnLeft(MoveCommand):
    code = 17

@dataclass(frozen=True)
class MoveCommand_TurnRight(MoveCommand):
    code = 18

@dataclass(frozen=True)
class MoveCommand_TurnUp(MoveCommand):
    code = 19

@dataclass(frozen=True)
class MoveCommand_Turn90Right(MoveCommand):
    code = 20

@dataclass(frozen=True)
class MoveCommand_Turn90Left(MoveCommand):
    code = 21

@dataclass(frozen=True)
class MoveCommand_Turn180(MoveCommand):
    code = 22

@dataclass(frozen=True)
class MoveCommand_Turn90RightOrLeft(MoveCommand):
    code = 23

@dataclass(frozen=True)
class MoveCommand_TurnAtRandom(MoveCommand):
    code = 24

@dataclass(frozen=True)
class MoveCommand_TurnTowardPlayer(MoveCommand):
    code = 25

@dataclass(frozen=True)
class MoveCommand_TurnAwayFromPlayer(MoveCommand):
    code = 26

@dataclass(frozen=True)
class MoveCommand_SwitchOn(MoveCommand):
    code = 27
    switch_id: Optional[int]

@dataclass(frozen=True)
class MoveCommand_SwitchOff(MoveCommand):
    code = 28
    switch_id: Optional[int]

@dataclass(frozen=True)
class MoveCommand_ChangeSpeed(MoveCommand):
    code = 29
    speed: MoveSpeed

@dataclass(frozen=True)
class MoveCommand_ChangeFreq(MoveCommand):
    code = 30
    freq: MoveFrequency

@dataclass(frozen=True)
class MoveCommand_MoveAnimationOn(MoveCommand):
    code = 31

@dataclass(frozen=True)
class MoveCommand_MoveAnimationOff(MoveCommand):
    code = 32

@dataclass(frozen=True)
class MoveCommand_StopAnimationOn(MoveCommand):
    code = 33

@dataclass(frozen=True)
class MoveCommand_StopAnimationOff(MoveCommand):
    code = 34

@dataclass(frozen=True)
class MoveCommand_DirectionFixOn(MoveCommand):
    code = 35

@dataclass(frozen=True)
class MoveCommand_DirectionFixOff(MoveCommand):
    code = 36

@dataclass(frozen=True)
class MoveCommand_ThroughOn(MoveCommand):
    code = 37

@dataclass(frozen=True)
class MoveCommand_ThroughOff(MoveCommand):
    code = 38

@dataclass(frozen=True)
class MoveCommand_AlwaysOnTopOn(MoveCommand):
    code = 39

@dataclass(frozen=True)
class MoveCommand_AlwaysOnTopOff(MoveCommand):
    code = 40

@dataclass(frozen=True)
class MoveCommand_Graphic(MoveCommand):
    code = 41
    character_name: str
    character_hue: int
    direction: Direction
    pattern: int

@dataclass(frozen=True)
class MoveCommand_ChangeOpacity(MoveCommand):
    code = 42
    opacity: int

@dataclass(frozen=True)
class MoveCommand_ChangeBlending(MoveCommand):
    code = 43
    blend_type: int

@dataclass(frozen=True)
class MoveCommand_PlaySE(MoveCommand):
    code = 44
    audio: AudioFile

@dataclass(frozen=True)
class MoveCommand_Script(MoveCommand):
    code = 45
    line: str

@dataclass(frozen=True)
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
    animation1_id: Optional[int]
    animation2_id: Optional[int]
    element_ranks: np.ndarray
    state_ranks: np.ndarray
    actions: list[EnemyAction]
    exp: int
    gold: int
    item_id: Optional[int]
    weapon_id: Optional[int]
    armor_id: Optional[int]
    treasure_prob: int

@dataclass(frozen=True)
class EnemyAction:
    kind: EnemyActionKind
    basic: EnemyBasicAction
    skill_id: Optional[int]
    condition_turn_a: int
    condition_turn_b: int
    condition_hp: int
    condition_level: int
    condition_switch_id: Optional[int]
    rating: int

@dataclass(frozen=True)
class Item:
    id_: int
    name: str
    icon_name: str
    description: str
    scope: Scope
    occasion: Occasion
    animation1_id: Optional[int]
    animation2_id: Optional[int]
    menu_se: AudioFile
    common_event_id: Optional[int]
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
    element_set: set[Optional[int]]
    plus_state_set: set[Optional[int]]
    minus_state_set: set[Optional[int]]

@dataclass(frozen=True)
class Map:
    tileset_id: int
    width: int
    height: int
    autoplay_bgm: bool
    bgm: AudioFile
    autoplay_bgs: bool
    bgs: AudioFile
    encounter_list: list[int]
    encounter_step: int
    data: np.ndarray
    events: dict[int, Event]

@dataclass(frozen=True)
class Event:
    id_: int
    name: str
    x: int
    y: int
    pages: list[EventPage]

@dataclass(frozen=True)
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
    list_: list[EventCommand]

@dataclass(frozen=True)
class EventPageCondition:
    switch1_valid: bool
    switch2_valid: bool
    variable_valid: bool
    self_switch_valid: bool
    switch1_id: Optional[int]
    switch2_id: Optional[int]
    variable_id: Optional[int]
    variable_value: int
    self_switch_ch: SelfSwitch

@dataclass(frozen=True)
class EventPageGraphic:
    tile_id: int
    character_name: str
    character_hue: int
    direction: Direction
    pattern: int
    opacity: int
    blend_type: int

@dataclass(frozen=True)
class MapInfo:
    name: str
    parent_id: Optional[int]
    order: int
    expanded: bool
    scroll_x: int
    scroll_y: int

@dataclass(frozen=True)
class Script:
    id_: int
    name: str
    content: str

@dataclass(frozen=True)
class Skill:
    id_: int
    name: str
    icon_name: str
    description: str
    scope: Scope
    occasion: Occasion
    animation1_id: Optional[int]
    animation2_id: Optional[int]
    menu_se: AudioFile
    common_event_id: Optional[int]
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
    element_set: set[Optional[int]]
    plus_state_set: set[Optional[int]]
    minus_state_set: set[Optional[int]]

@dataclass(frozen=True)
class State:
    id_: int
    name: str
    animation_id: Optional[int]
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
    guard_element_set: set[Optional[int]]
    plus_state_set: set[Optional[int]]
    minus_state_set: set[Optional[int]]

@dataclass(frozen=True)
class System:
    magic_number: int
    party_members: list[int]
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
    start_map_id: Optional[int]
    start_x: int
    start_y: int
    test_battlers: list[SystemTestBattler]
    test_troop_id: Optional[int]
    battleback_name: str
    battler_name: str
    battler_hue: int
    edit_map_id: Optional[int]
    _: int

@dataclass(frozen=True)
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

@dataclass(frozen=True)
class SystemTestBattler:
    actor_id: int
    level: int
    weapon_id: Optional[int]
    armor1_id: Optional[int]
    armor2_id: Optional[int]
    armor3_id: Optional[int]
    armor4_id: Optional[int]

@dataclass(frozen=True)
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

@dataclass(frozen=True)
class Troop:
    id_: int
    name: str
    members: list[TroopMember]
    pages: list[TroopPage]

@dataclass(frozen=True)
class TroopMember:
    enemy_id: int
    x: int
    y: int
    hidden: bool
    immortal: bool

@dataclass(frozen=True)
class TroopPage:
    condition: TroopPageCondition
    span: TroopPageSpan
    list_: list[EventCommand]

@dataclass(frozen=True)
class TroopPageCondition:
    turn_valid: bool
    enemy_valid: bool
    actor_valid: bool
    switch_valid: bool
    turn_a: int
    turn_b: int
    enemy_index: int
    enemy_hp: int
    actor_id: Optional[int]
    actor_hp: int
    switch_id: Optional[int]

@dataclass(frozen=True)
class Weapon:
    id_: int
    name: str
    icon_name: str
    description: str
    animation1_id: Optional[int]
    animation2_id: Optional[int]
    price: int
    atk: int
    pdef: int
    mdef: int
    str_plus: int
    dex_plus: int
    agi_plus: int
    int_plus: int
    element_set: set[Optional[int]]
    plus_state_set: set[Optional[int]]
    minus_state_set: set[Optional[int]]