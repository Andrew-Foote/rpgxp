from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
import functools as ft
import re
from typing import Callable, Iterator, Literal, Sequence
from rpgxp.common import *

class SchemaError(Exception):
	pass

@dataclass
class DataSchema(ABC):
	pass

@dataclass
class RowSchema(DataSchema, ABC):
	"""A schema for an object which corresponds to an individual database row
	(as opposed to a whole table)."""

@dataclass
class TableSchema(DataSchema, ABC):
	"""A schema for an object which corresponds to a whole database table (as
	opposed to an individual row)."""

	@property
	@abstractmethod
	def table_name(self) -> str:
		"""The name of the database table corresponding to the object."""

@dataclass
class BoolSchema(RowSchema):
	"""A schema for a Boolean value (true or false)."""

@dataclass
class IntSchema(RowSchema):
	"""A schema for an integer value.

	Attributes:
	  lb
	    A lower bound on the integer. Can be None for no lower bound.
	  ub
	    An upper bound on the integer. Can be None for no upper bound.
	"""

	lb: int | None=None
	ub: int | None=None

@dataclass
class StrSchema(RowSchema):
	"""A schema for a string value."""

@dataclass
class ZlibSchema(RowSchema):
	"""Schema for a value consisting of bytes obtained by compressing a
	string using zlib.

	Attributes:
	  encoding
	    The encoding of the original string."""

	encoding: str

@dataclass
class NDArraySchema(RowSchema):
	"""Schema for a value which is a multi-dimensional array.

	Attributes:
	  dims
	    The number of dimensions; can only be 1, 2, or 3.
	"""

	dims: Literal[1] | Literal[2] | Literal[3]

@dataclass
class EnumSchema(RowSchema):
	enum_class: type[Enum]

@dataclass
class FKSchema(RowSchema):
	foreign_schema_thunk: Callable[[], TableSchema] 
	nullable: bool=True

@dataclass
class ObjSchema(RowSchema, ABC):
	@property
	@abstractmethod
	def class_name(self) -> str:
		"""The name of the Python class corresponding to this schema."""

	@property
	@abstractmethod
	def fields(self) -> Sequence[FieldBase]:
		...

@dataclass
class FieldBase(ABC):
	@property
	@abstractmethod
	def name(self) -> str:
		...

	@property
	@abstractmethod
	def schema(self) -> DataSchema:
		...

	@property
	@abstractmethod
	def db_name(self) -> str:
		...

@dataclass
class Field(FieldBase):
	_name: str
	_schema: DataSchema
	_db_name: str=''

	@property
	def name(self) -> str:
		return self._name

	@property
	def schema(self) -> DataSchema:
		return self._schema

	@property
	def db_name(self) -> str:
		return self._db_name or self.name

@dataclass
class ArrayObjSchema(ObjSchema, RowSchema):
	_class_name: str
	_fields: list[Field]

	@property
	def class_name(self) -> str:
		return self._class_name

	@property
	def fields(self) -> list[Field]:
		return self._fields

@dataclass
class RPGField(FieldBase):
	_name: str
	_schema: DataSchema
	_db_name: str=''
	rpg_name: str=''

	def __post_init__(self) -> None:
		if not self.rpg_name:
			self.rpg_name = self.name

	@property
	def name(self) -> str:
		return self._name

	@property
	def schema(self) -> DataSchema:
		return self._schema

	@property
	def db_name(self) -> str:
		return self._db_name or self.name

@dataclass
class RPGObjSchema(ObjSchema):
	_class_name: str
	rpg_class_name: str
	_fields: list[RPGField]

	@property
	def class_name(self) -> str:
		return self._class_name

	@property
	def fields(self) -> list[RPGField]:
		return self._fields

@dataclass
class RPGSingletonObjSchema(ObjSchema, TableSchema):
	_class_name: str
	_table_name: str
	rpg_class_name: str
	_fields: list[RPGField]

	@property
	def class_name(self) -> str:
		return self._class_name

	@property
	def table_name(self) -> str:
		return self._table_name

	@property
	def fields(self) -> list[RPGField]:
		return self._fields

class FirstItem(Enum):
	REGULAR = 0
	NULL = 1
	BLANK = 2

@dataclass
class ListSchema(TableSchema):
	_table_name: str
	item_schema: RowSchema
	first_item: FirstItem=FirstItem.REGULAR
	item_name: str=''
	maxlen: int | None=None

	@property
	def table_name(self) -> str:
		return self._table_name

@dataclass
class SetSchema(TableSchema):
	_table_name: str
	item_schema: RowSchema
	item_name: str=''

	@property
	def table_name(self) -> str:
		return self._table_name

@dataclass
class DBName:
	app_name: str
	db_name: str

@dataclass
class DictSchema(TableSchema):
	"""The schema for a Marshal hash whose values are objects.

	Attributes:
	  key_name
	    The name of the field that will be added to each object to represent
	    the value of its key.
	  key_schema
	    The schema for the aforementioned key field.
	  value_schema
	    The schema for the values.
	"""

	# should have key_name, key_db_name
	# or, we should have this as an enum where one of the options is MatchesField
	_table_name: str
	key_name: DBName
	key_schema: RowSchema
	value_schema: ObjSchema
	value_name: str=''

	@property
	def table_name(self) -> str:
		return self._table_name

@dataclass
class FileSchema(ABC):
	pass

@dataclass
class SingleFileSchema(FileSchema):
	"""The schema for one of the .rxdata files in the game's Data directory.

	Attributes:
	  filename
	    The name of the file to parse, not including the parent directories.
	  schema
	    The file's schema. It must be a TableSchema, so that we know what to
	    call the database table corresponding to the file.
	"""

	filename: str
	schema: TableSchema

@dataclass
class MultipleFilesSchema(FileSchema, TableSchema):
	"""The schema for a set of .rxdata files in the game's Data directory which
	all match a certain regex pattern.

	Attributes:
	  pattern
	    The regex pattern, which will be matched against the file names (not
	    including the parent directories).
	  table_name
	    The name of the database table representing this set of files.
	  keys
	    A list of strings corresponding to capture groups in the pattern (its
	    length must be the same as the number of capture groups). The value of
	    each group will be added as a field to the objects representing the
	    individual names, with the string from here as its name.
	  schema
	    The schema for the content of an individual file. This must be an
	    ObjSchema, so that the key fields can be added to it."""

	pattern: re.Pattern
	_table_name: str
	keys: list[DBName]
	schema: ObjSchema

	@property
	def table_name(self) -> str:
		return self._table_name

###############################################################################

# utility functions for quicker typing

def id_field() -> RPGField:
	return RPGField('id_', IntSchema(), _db_name='id', rpg_name='id')

def bool_field(name: str) -> RPGField:
	return RPGField(name, BoolSchema())

def int_field(name: str) -> RPGField:
	return RPGField(name, IntSchema())

def str_field(name: str) -> RPGField:
	return RPGField(name, StrSchema())

def audio_field(name: str) -> RPGField:
	return RPGField(name, AUDIO_FILE_SCHEMA)

def many_fields(
	names: str, maker: Callable[[str], RPGField]
) -> Iterator[RPGField]:

	for name in names.split():
		yield maker(name)

bool_fields = ft.partial(many_fields, maker=bool_field)
int_fields = ft.partial(many_fields, maker=int_field)
str_fields = ft.partial(many_fields, maker=str_field)
audio_fields = ft.partial(many_fields, maker=audio_field)

def enum_field(name: str, cls: type[Enum]) -> RPGField:
	return RPGField(name, EnumSchema(cls))

def fk_field(
	name: str, schema_thunk: Callable[[], TableSchema], nullable: bool
) -> RPGField:

	return RPGField(name, FKSchema(schema_thunk, nullable=nullable))

###############################################################################

HUE_SCHEMA = IntSchema(0, 360)

def hue_field(name: str) -> RPGField:
	return RPGField(name, HUE_SCHEMA)

COLOR_SCHEMA = RPGObjSchema('Color', 'Color', [
	RPGField('red', IntSchema(0, 255)),
	RPGField('green', IntSchema(0, 255)),
	RPGField('blue', IntSchema(0, 255)),
	RPGField('alpha', IntSchema(0, 255)),
])

AUDIO_FILE_SCHEMA = RPGObjSchema('AudioFile', 'RPG::AudioFile', [
	str_field('name'), *int_fields('volume pitch')
])

ACTOR_SCHEMA = RPGObjSchema('Actor', 'RPG::Actor', [
	id_field(),
	str_field('name'),
	fk_field('class_id', lambda: CLASSES_SCHEMA, False),
	*int_fields('initial_level final_level'),
	RPGField('exp_basis', IntSchema(10, 50)),
	RPGField('exp_inflation', IntSchema(10, 50)),
	str_field('character_name'),
	hue_field('character_hue'),
	str_field('battler_name'),
	hue_field('battler_hue'),
	RPGField('parameters', NDArraySchema(2)),
	fk_field('weapon_id', lambda: WEAPONS_SCHEMA, True),
	fk_field('armor1_id', lambda: ARMORS_SCHEMA, True),
	fk_field('armor2_id', lambda: ARMORS_SCHEMA, True),
	fk_field('armor3_id', lambda: ARMORS_SCHEMA, True),
	fk_field('armor4_id', lambda: ARMORS_SCHEMA, True),
	*bool_fields('weapon_fix armor1_fix armor2_fix armor3_fix armor4_fix'),
])

ANIMATION_FRAME_SCHEMA = RPGObjSchema(
	'AnimationFrame',
	'RPG::Animation::Frame',
	[
		int_field('cell_max'),
		RPGField('cell_data', NDArraySchema(2)),
	])

ANIMATION_TIMING_SCHEMA = RPGObjSchema(
	'AnimationTiming',
	'RPG::Animation::Timing',
	[
		int_field('frame'),
		audio_field('se'),
		enum_field('flash_scope', AnimationTimingFlashScope),
		RPGField('flash_color', COLOR_SCHEMA),
		int_field('flash_duration'),
		enum_field('condition', AnimationTimingCondition),
	]
)

ANIMATION_SCHEMA = RPGObjSchema('Animation', 'RPG::Animation', [
	id_field(),
	*str_fields('name animation_name'),
	hue_field('animation_hue'),
	enum_field('position', AnimationPosition),
	int_field('frame_max'),
	RPGField('frames', ListSchema('animation_frame', ANIMATION_FRAME_SCHEMA)),
	RPGField('timings', ListSchema(
		'animation_timing', ANIMATION_TIMING_SCHEMA
	)),
])

ARMOR_SCHEMA = RPGObjSchema('Armor', 'RPG::Armor', [
	id_field(),
	*str_fields('name icon_name description'),
	enum_field('kind', ArmorKind),
	fk_field('auto_state_id', lambda: STATES_SCHEMA, True),
	*int_fields('price pdef mdef eva str_plus dex_plus agi_plus int_plus'),
	RPGField('guard_element_set', SetSchema(
		'armor_guard_element', IntSchema(), 'element_id'
	)),
	RPGField('guard_state_set', SetSchema(
		'armor_guard_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
])

CLASS_LEARNING_SCHEMA = RPGObjSchema('ClassLearning', 'RPG::Class::Learning', [
	int_field('level'),
	fk_field('skill_id', lambda: SKILLS_SCHEMA, False),
])

CLASS_SCHEMA = RPGObjSchema('Class', 'RPG::Class', [
	id_field(),
	str_field('name'),
	enum_field('position', ClassPosition),
	RPGField('weapon_set', SetSchema(
		'class_weapon', FKSchema(lambda: WEAPONS_SCHEMA), 'weapon_id'
	)),
	RPGField('armor_set', SetSchema(
		'class_armor', FKSchema(lambda: ARMORS_SCHEMA), 'armor_id'
	)),
	RPGField('element_ranks', NDArraySchema(1)),
	RPGField('state_ranks', NDArraySchema(1)),
	RPGField('learnings', ListSchema('class_learning', CLASS_LEARNING_SCHEMA)),
])

COMMON_EVENT_SCHEMA = RPGObjSchema('CommonEvent', 'RPG::CommonEvent', [
	id_field(),
	str_field('name'),
	enum_field('trigger', CommonEventTrigger),
	int_field('switch_id'),
])

ENEMY_ACTION_SCHEMA = RPGObjSchema('EnemyAction', 'RPG::Enemy::Action', [
	enum_field('kind', EnemyActionKind),
	enum_field('basic', EnemyBasicAction),
	fk_field('skill_id', lambda: SKILLS_SCHEMA, True),
	*int_fields('''
		condition_turn_a condition_turn_b condition_hp condition_level
		condition_switch_id
	'''),
	RPGField('rating', IntSchema(1, 10)),
])

ENEMY_SCHEMA = RPGObjSchema('Enemy', 'RPG::Enemy', [
	id_field(),
	*str_fields('name battler_name'),
	hue_field('battler_hue'),
	*int_fields('maxhp maxsp'),
	RPGField('str_', IntSchema(), _db_name='str'),
	*int_fields('dex agi'),
	RPGField('int_', IntSchema(), _db_name='int'),
	*int_fields('atk pdef mdef eva'),
	fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
	fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
	RPGField('element_ranks', NDArraySchema(1)),
	RPGField('state_ranks', NDArraySchema(1)),
	RPGField('actions', ListSchema('enemy_action', ENEMY_ACTION_SCHEMA)),
	*int_fields('exp gold'),
	fk_field('item_id', lambda: ITEMS_SCHEMA, True),
	fk_field('weapon_id', lambda: WEAPONS_SCHEMA, True),
	fk_field('armor_id', lambda: ARMORS_SCHEMA, True),
	int_field('treasure_prob'),
])

ITEM_SCHEMA = RPGObjSchema('Item', 'RPG::Item', [
	id_field(),
	*str_fields('name icon_name description'),
	enum_field('scope', Scope),
	enum_field('occasion', Occasion),
	fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
	fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
	audio_field('menu_se'),
	fk_field('common_event_id', lambda: COMMON_EVENTS_SCHEMA, True),
	int_field('price'),
	bool_field('consumable'),
	enum_field('parameter_type', ParameterType),
	*int_fields('''
		parameter_points recover_hp_rate recover_hp recover_sp_rate recover_sp
		hit pdef_f mdef_f variance
	'''),
	RPGField('element_set', SetSchema(
		'item_element', IntSchema(), 'element_id'
	)),
	RPGField('plus_state_set', SetSchema(
		'item_plus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
	RPGField('minus_state_set', SetSchema(
		'item_minus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
])

EVENT_PAGE_CONDITION_SCHEMA = RPGObjSchema(
	'EventPageCondition',
	'RPG::Event::Page::Condition',
	[
		*bool_fields('''
			switch1_valid switch2_valid variable_valid self_switch_valid
		'''),
		*int_fields('switch1_id switch2_id variable_id variable_value'),
		str_field('self_switch_ch'),
	]
)

EVENT_PAGE_GRAPHIC_SCHEMA = RPGObjSchema(
	'EventPageGraphic',
	'RPG::Event::Page::Graphic',
	[
		int_field('tile_id'),
		str_field('character_name'),
		hue_field('character_hue'),
		enum_field('direction', Direction),
		RPGField('pattern', IntSchema(0, 3)),
		*int_fields('opacity blend_type'),
	]
)

MOVE_ROUTE_SCHEMA = RPGObjSchema('MoveRoute', 'RPG::MoveRoute', [
	*bool_fields('repeat skippable'),
])

EVENT_PAGE_SCHEMA = RPGObjSchema('EventPage', 'RPG::Event::Page', [
	RPGField('condition', EVENT_PAGE_CONDITION_SCHEMA),
	RPGField('graphic', EVENT_PAGE_GRAPHIC_SCHEMA),
	enum_field('move_type', MoveType),
	enum_field('move_frequency', MoveFrequency),
	enum_field('move_speed', MoveSpeed),
	RPGField('move_route', MOVE_ROUTE_SCHEMA),
	*bool_fields('walk_anime step_anime direction_fix through always_on_top'),
	enum_field('trigger', EventPageTrigger),
])

EVENT_SCHEMA = RPGObjSchema('Event', 'RPG::Event', [
	id_field(),
	RPGField('name', StrSchema()),
	RPGField('x', IntSchema()),
	RPGField('y', IntSchema()),
	RPGField('pages', ListSchema('event_page', EVENT_PAGE_SCHEMA))
])

MAP_SCHEMA = RPGObjSchema('Map', 'RPG::Map', [
	RPGField('tileset_id', FKSchema(lambda: TILESETS_SCHEMA, nullable=False)),
	RPGField('width', IntSchema()),
	RPGField('height', IntSchema()),
	RPGField('autoplay_bgm', BoolSchema()),
	RPGField('bgm', AUDIO_FILE_SCHEMA),
	RPGField('autoplay_bgs', BoolSchema()),
	RPGField('bgs', AUDIO_FILE_SCHEMA),
	RPGField('encounter_list', ListSchema(
		'encounter', FKSchema(lambda: TROOPS_SCHEMA, nullable=False)
	)),
	RPGField('encounter_step', IntSchema()),
	RPGField('data', NDArraySchema(3)),
	RPGField('events', DictSchema(
		'event', DBName('key_', 'key'), IntSchema(), EVENT_SCHEMA
	)),
])

MAP_INFO_SCHEMA = RPGObjSchema('MapInfo', 'RPG::MapInfo', [
	RPGField('name', StrSchema()),
	RPGField('parent_id', FKSchema(lambda: MAP_INFOS_SCHEMA)),
	RPGField('order', IntSchema()),
	RPGField('expanded', BoolSchema()),
	RPGField('scroll_x', IntSchema()),
	RPGField('scroll_y', IntSchema()),
])

SCRIPT_SCHEMA = ArrayObjSchema('Script', [
	Field('id_', IntSchema(), _db_name='id'),
	Field('name', StrSchema()),
	Field('content', ZlibSchema('utf-8'))
])

SKILL_SCHEMA = RPGObjSchema('Skill', 'RPG::Skill', [
	id_field(),
	*str_fields('name icon_name description'),
	enum_field('scope', Scope),
	enum_field('occasion', Occasion),
	fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
	fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
	audio_field('menu_se'),
	fk_field('common_event_id', lambda: COMMON_EVENTS_SCHEMA, True),
	*int_fields('''
		sp_cost power atk_f eva_f str_f dex_f agi_f int_f hit pdef_f mdef_f
		variance
	'''),
	RPGField('element_set', SetSchema(
		'skill_element', IntSchema(), 'element_id'
	)),
	RPGField('plus_state_set', SetSchema(
		'skill_plus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
	RPGField('minus_state_set', SetSchema(
		'skill_minus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
])

STATE_SCHEMA = RPGObjSchema('State', 'RPG::State', [
	id_field(),
	str_field('name'),
	fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
	fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
	enum_field('restriction', StateRestriction),
	*bool_fields('nonresistance zero_hp cant_get_exp cant_evade slip_damage'),
	RPGField('rating', IntSchema(0, 10)),
	*int_fields('''
		hit_rate maxhp_rate maxsp_rate str_rate dex_rate agi_rate int_rate
		atk_rate pdef_rate mdef_rate eva
	'''),
	bool_field('battle_only'),
	*int_fields('hold_turn auto_release_prob shock_release_prob'),
	RPGField('guard_element_set', SetSchema(
		'state_guard_element', IntSchema(), 'element_id'
	)),
	RPGField('plus_state_set', SetSchema(
		'state_plus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
	RPGField('minus_state_set', SetSchema(
		'state_minus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
])

SYSTEM_WORDS_SCHEMA = RPGObjSchema('SystemWords', 'RPG::System::Words', [
	RPGField('gold', StrSchema()),
	RPGField('hp', StrSchema()),
	RPGField('sp', StrSchema()),
	RPGField('str_', StrSchema(), rpg_name='str'),
	RPGField('dex', StrSchema()),
	RPGField('agi', StrSchema()),
	RPGField('int_', StrSchema(), rpg_name='int'),
	RPGField('atk', StrSchema()),
	RPGField('pdef', StrSchema()),
	RPGField('mdef', StrSchema()),
	RPGField('weapon', StrSchema()),
	RPGField('armor1', StrSchema()),
	RPGField('armor2', StrSchema()),
	RPGField('armor3', StrSchema()),
	RPGField('armor4', StrSchema()),
	RPGField('attack', StrSchema()),
	RPGField('skill', StrSchema()),
	RPGField('guard', StrSchema()),
	RPGField('item', StrSchema()),
	RPGField('equip', StrSchema()),
])

SYSTEM_TEST_BATTLER_SCHEMA = RPGObjSchema(
	'SystemTestBattler',
	'RPG::System::TestBattler',
	[
		RPGField('actor_id', FKSchema(lambda: ACTORS_SCHEMA, nullable=False)),
		RPGField('level', IntSchema()),
		RPGField('weapon_id', FKSchema(lambda: WEAPONS_SCHEMA)),
		RPGField('armor1_id', FKSchema(lambda: ARMORS_SCHEMA)),
		RPGField('armor2_id', FKSchema(lambda: ARMORS_SCHEMA)),
		RPGField('armor3_id', FKSchema(lambda: ARMORS_SCHEMA)),
		RPGField('armor4_id', FKSchema(lambda: ARMORS_SCHEMA)),
	]
)

SYSTEM_SCHEMA = RPGSingletonObjSchema('System', 'system', 'RPG::System', [
	RPGField('magic_number', IntSchema()),
	RPGField('party_members', ListSchema(
		'party_member', FKSchema(lambda: ACTORS_SCHEMA, nullable=False)
	)),
	RPGField('elements', ListSchema(
		'element', StrSchema(), FirstItem.BLANK
	)),
	RPGField('switches', ListSchema(
		'switch', StrSchema(), FirstItem.NULL
	)),
	RPGField('variables', ListSchema(
		'variable', StrSchema(), FirstItem.NULL
	)),
	RPGField('windowskin_name', StrSchema()),
	RPGField('title_name', StrSchema()),
	RPGField('gameover_name', StrSchema()),
	RPGField('battle_transition', StrSchema()),
	RPGField('title_bgm', AUDIO_FILE_SCHEMA),
	RPGField('battle_bgm', AUDIO_FILE_SCHEMA),
	RPGField('battle_end_me', AUDIO_FILE_SCHEMA),
	RPGField('gameover_me', AUDIO_FILE_SCHEMA),
	RPGField('decision_se', AUDIO_FILE_SCHEMA),
	RPGField('cancel_se', AUDIO_FILE_SCHEMA),
	RPGField('buzzer_se', AUDIO_FILE_SCHEMA),
	RPGField('equip_se', AUDIO_FILE_SCHEMA),
	RPGField('shop_se', AUDIO_FILE_SCHEMA),
	RPGField('save_se', AUDIO_FILE_SCHEMA),
	RPGField('load_se', AUDIO_FILE_SCHEMA),
	RPGField('battle_start_se', AUDIO_FILE_SCHEMA),
	RPGField('escape_se', AUDIO_FILE_SCHEMA),
	RPGField('actor_collapse_se', AUDIO_FILE_SCHEMA),
	RPGField('enemy_collapse_se', AUDIO_FILE_SCHEMA),
	RPGField('words', SYSTEM_WORDS_SCHEMA),
	RPGField('start_map_id', FKSchema(lambda: MAPS_SCHEMA)),
	RPGField('start_x', IntSchema()),
	RPGField('start_y', IntSchema()),
	RPGField('test_battlers', ListSchema(
		'test_battler', SYSTEM_TEST_BATTLER_SCHEMA
	)),
	RPGField('test_troop_id', FKSchema(lambda: TROOPS_SCHEMA)),
	RPGField('battleback_name', StrSchema()),
	RPGField('battler_name', StrSchema()),
	RPGField('battler_hue', HUE_SCHEMA),
	RPGField('edit_map_id', FKSchema(lambda: MAPS_SCHEMA))
])

TILESET_SCHEMA = RPGObjSchema('Tileset', 'RPG::Tileset', [
	id_field(),
	*str_fields('name tileset_name'),
	RPGField('autotile_names', ListSchema(
		'tileset_autotile', StrSchema(), maxlen=7
	)),
	str_field('panorama_name'),
	hue_field('panorama_hue'),
	str_field('fog_name'),
	hue_field('fog_hue'),
	*int_fields('fog_opacity fog_blend_type fog_zoom fog_sx fog_sy'),
	str_field('battleback_name'),
	RPGField('passages', NDArraySchema(1)),
	RPGField('priorities', NDArraySchema(1)),
	RPGField('terrain_tags', NDArraySchema(1)),
])

TROOP_MEMBER_SCHEMA = RPGObjSchema('TroopMember', 'RPG::Troop::Member', [
	fk_field('enemy_id', lambda: ENEMIES_SCHEMA, False),
	*int_fields('x y'),
	*bool_fields('hidden immortal'),
])

TROOP_PAGE_CONDITION_SCHEMA = RPGObjSchema(
	'TroopPageCondition',
	'RPG::Troop::Page::Condition',
	[
		*bool_fields('turn_valid enemy_valid actor_valid switch_valid'),
		*int_fields('turn_a turn_b'),
		RPGField('enemy_index', IntSchema(0, 7)),
		int_field('enemy_hp'),
		fk_field('actor_id', lambda: ACTORS_SCHEMA, True),
		*int_fields('actor_hp switch_id'),
	]
)

TROOP_PAGE_SCHEMA = RPGObjSchema('TroopPage', 'RPG::Troop::Page', [
	RPGField('condition', TROOP_PAGE_CONDITION_SCHEMA),
	enum_field('span', TroopPageSpan),
])

TROOP_SCHEMA = RPGObjSchema('Troop', 'RPG::Troop', [
	id_field(),
	str_field('name'),
	RPGField('members', ListSchema('troop_member', TROOP_MEMBER_SCHEMA)),
	RPGField('pages', ListSchema('troop_page', TROOP_PAGE_SCHEMA)),
])

WEAPON_SCHEMA = RPGObjSchema('Weapon', 'RPG::Weapon', [
	id_field(),
	*str_fields('name icon_name description'),
	fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
	fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
	*int_fields('price atk pdef mdef str_plus dex_plus agi_plus int_plus'),
	RPGField('element_set', SetSchema(
		'weapon_element', IntSchema(), 'element_id'
	)),
	RPGField('plus_state_set', SetSchema(
		'weapon_plus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
	RPGField('minus_state_set', SetSchema(
		'weapon_minus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
	)),
])

ACTORS_SCHEMA: ListSchema = ListSchema('actor', ACTOR_SCHEMA, FirstItem.NULL)
ANIMATIONS_SCHEMA: ListSchema = ListSchema('animation', ANIMATION_SCHEMA, FirstItem.NULL)
ARMORS_SCHEMA: ListSchema = ListSchema('armor', ARMOR_SCHEMA, FirstItem.NULL)
CLASSES_SCHEMA: ListSchema = ListSchema('class', CLASS_SCHEMA, FirstItem.NULL)

COMMON_EVENTS_SCHEMA: ListSchema = ListSchema(
	'common_event', COMMON_EVENT_SCHEMA, FirstItem.NULL
)

ENEMIES_SCHEMA: ListSchema = ListSchema('enemy', ENEMY_SCHEMA, FirstItem.NULL)
ITEMS_SCHEMA: ListSchema = ListSchema('item', ITEM_SCHEMA, FirstItem.NULL)

MAPS_SCHEMA: MultipleFilesSchema = MultipleFilesSchema(
	re.compile(r'Map(\d{3}).rxdata'),
	'map',
	[DBName('id_', 'id')],
	MAP_SCHEMA
)

MAP_INFOS_SCHEMA: DictSchema = DictSchema(
	'map_info', DBName('id_', 'id'), IntSchema(), MAP_INFO_SCHEMA
)

SCRIPTS_SCHEMA: ListSchema = ListSchema('script', SCRIPT_SCHEMA)
SKILLS_SCHEMA: ListSchema = ListSchema('skill', SKILL_SCHEMA, FirstItem.NULL)
STATES_SCHEMA: ListSchema = ListSchema('state', STATE_SCHEMA, FirstItem.NULL)
TILESETS_SCHEMA: ListSchema = ListSchema('tileset', TILESET_SCHEMA, FirstItem.NULL)
TROOPS_SCHEMA: ListSchema = ListSchema('troop', TROOP_SCHEMA, FirstItem.NULL)
WEAPONS_SCHEMA: ListSchema = ListSchema('weapon', WEAPON_SCHEMA, FirstItem.NULL)

FILES: list[FileSchema] = [
	SingleFileSchema('Actors.rxdata', ACTORS_SCHEMA),
	SingleFileSchema('Animations.rxdata', ANIMATIONS_SCHEMA),
	SingleFileSchema('Armors.rxdata', ARMORS_SCHEMA),
	SingleFileSchema('Classes.rxdata', CLASSES_SCHEMA),
	SingleFileSchema('CommonEvents.rxdata', COMMON_EVENTS_SCHEMA),
	SingleFileSchema('Enemies.rxdata', ENEMIES_SCHEMA),
	SingleFileSchema('Items.rxdata', ITEMS_SCHEMA),
	MAPS_SCHEMA,
	SingleFileSchema('MapInfos.rxdata', MAP_INFOS_SCHEMA),
	SingleFileSchema('Scripts.rxdata', SCRIPTS_SCHEMA),
	SingleFileSchema('Skills.rxdata', SKILLS_SCHEMA),
	SingleFileSchema('States.rxdata', STATES_SCHEMA),
	SingleFileSchema('System.rxdata', SYSTEM_SCHEMA),
	SingleFileSchema('Tilesets.rxdata', TILESETS_SCHEMA),
	SingleFileSchema('Troops.rxdata', TROOPS_SCHEMA),
	SingleFileSchema('Weapons.rxdata', WEAPONS_SCHEMA),
]