from abc import ABC
from dataclasses import dataclass
from enum import Enum
import re
from typing import Callable, Literal

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
	table_name: str

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
	class_name: str

@dataclass
class Field:
	name: str
	schema: DataSchema
	db_name: str=''

	def __post_init__(self) -> None:
		if not self.db_name:
			self.db_name = self.name

@dataclass
class ArrayObjSchema(ObjSchema, RowSchema):
	fields: list[Field]

@dataclass
class RPGField:
	name: str
	schema: DataSchema
	db_name: str=''
	rpg_name: str=''

	def __post_init__(self) -> None:
		if not self.db_name:
			self.db_name = self.name

		if not self.rpg_name:
			self.rpg_name = self.name

@dataclass
class RPGObjSchema(ObjSchema):
	rpg_class_name: str
	fields: list[RPGField]

@dataclass
class RPGSingletonObjSchema(ObjSchema, TableSchema):
	rpg_class_name: str
	fields: list[RPGField]

class FirstItem(Enum):
	REGULAR = 0
	NULL = 1
	BLANK = 2

@dataclass
class ListSchema(TableSchema):
	item_schema: RowSchema
	first_item: FirstItem=FirstItem.REGULAR

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

	key_name: str
	key_schema: RowSchema
	value_schema: ObjSchema

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
class MultipleFilesSchema(FileSchema):
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
	table_name: str
	keys: list[str]
	schema: ObjSchema

HUE_SCHEMA = IntSchema(0, 360)

COLOR_SCHEMA = RPGObjSchema('Color', 'Color', [
	RPGField('red', IntSchema(0, 255)),
	RPGField('green', IntSchema(0, 255)),
	RPGField('blue', IntSchema(0, 255)),
	RPGField('alpha', IntSchema(0, 255)),
])

AUDIO_FILE_SCHEMA = RPGObjSchema('AudioFile', 'RPG::AudioFile', [
	RPGField('name', StrSchema()),
	RPGField('volume', IntSchema()),
	RPGField('pitch', IntSchema())
])

ACTOR_SCHEMA = RPGObjSchema('Actor', 'RPG::Actor', [
	RPGField('id_', IntSchema(), db_name='id', rpg_name='id'),
	RPGField('name', StrSchema()),
	RPGField('class_id', FKSchema(lambda: CLASSES_SCHEMA, nullable=False)),
	RPGField('initial_level', IntSchema()),
	RPGField('final_level', IntSchema()),
	RPGField('exp_basis', IntSchema(10, 50)),
	RPGField('exp_inflation', IntSchema(10, 50)),
	RPGField('character_name', StrSchema()),
	RPGField('character_hue', HUE_SCHEMA),
	RPGField('battler_name', StrSchema()),
	RPGField('battler_hue', HUE_SCHEMA),
	RPGField('parameters', NDArraySchema(2)),
	RPGField('weapon_id', FKSchema(lambda: WEAPONS_SCHEMA)),
	RPGField('armor1_id', FKSchema(lambda: ARMORS_SCHEMA)),
	RPGField('armor2_id', FKSchema(lambda: ARMORS_SCHEMA)),
	RPGField('armor3_id', FKSchema(lambda: ARMORS_SCHEMA)),
	RPGField('armor4_id', FKSchema(lambda: ARMORS_SCHEMA)),
	RPGField('weapon_fix', BoolSchema()),
	RPGField('armor1_fix', BoolSchema()),
	RPGField('armor2_fix', BoolSchema()),
	RPGField('armor3_fix', BoolSchema()),
	RPGField('armor4_fix', BoolSchema()),
])

class AnimationPosition(Enum):
    TOP = 0
    MIDDLE = 1
    BOTTOM = 2
    SCREEN = 3

ANIMATION_FRAME_SCHEMA = RPGObjSchema(
	'AnimationFrame',
	'RPG::Animation::Frame',
	[
		RPGField('cell_max', IntSchema()),
		RPGField('cell_data', NDArraySchema(2)),
	])

class AnimationTimingFlashScope(Enum):
    NONE = 0
    TARGET = 1
    SCREEN = 2
    DELETE_TARGET = 3

class AnimationTimingCondition(Enum):
    NONE = 0
    HIT = 1
    MISS = 2

ANIMATION_TIMING_SCHEMA = RPGObjSchema(
	'AnimationTiming',
	'RPG::Animation::Timing',
	[
		RPGField('frame', IntSchema()),
		RPGField('se', AUDIO_FILE_SCHEMA),
		RPGField('flash_scope', EnumSchema(AnimationTimingFlashScope)),
		RPGField('flash_color', COLOR_SCHEMA),
		RPGField('flash_duration', IntSchema()),
		RPGField('condition', EnumSchema(AnimationTimingCondition))
	]
)

ANIMATION_SCHEMA = RPGObjSchema('Animation', 'RPG::Animation', [
	RPGField('id_', IntSchema(), db_name='id', rpg_name='id'),
	RPGField('name', StrSchema()),
	RPGField('animation_name', StrSchema()),
	RPGField('animation_hue', HUE_SCHEMA),
	RPGField('position', EnumSchema(AnimationPosition)),
	RPGField('frame_max', IntSchema()),
	RPGField('frames', ListSchema('animation_frame', ANIMATION_FRAME_SCHEMA)),
	RPGField('timings', ListSchema(
		'animation_timing', ANIMATION_TIMING_SCHEMA
	)),
])

ARMOR_SCHEMA = RPGObjSchema('Armor', 'RPG::Armor', [

])

CLASS_SCHEMA = RPGObjSchema('Class', 'RPG::Class', [

])

COMMON_EVENT_SCHEMA = RPGObjSchema('CommonEvent', 'RPG::CommonEvent', [

])

ENEMY_SCHEMA = RPGObjSchema('Enemy', 'RPG::Enemy', [

])

ITEM_SCHEMA = RPGObjSchema('Item', 'RPG::Item', [

])

EVENT_PAGE_SCHEMA = RPGObjSchema('EventPage', 'RPG::Event::Page', [

])

EVENT_SCHEMA = RPGObjSchema('Event', 'RPG::Event', [
	RPGField('id_', IntSchema(), db_name='id', rpg_name='id'),
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
		'event', 'key', IntSchema(), EVENT_SCHEMA
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
	Field('id_', IntSchema(), db_name='id'),
	Field('name', StrSchema()),
	Field('content', ZlibSchema('utf-8'))
])

SKILL_SCHEMA = RPGObjSchema('Skill', 'RPG::Skill', [

])

STATE_SCHEMA = RPGObjSchema('State', 'RPG::State', [

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

SYSTEM_SCHEMA = RPGSingletonObjSchema('system', 'System', 'RPG::System', [
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

])

TROOP_SCHEMA = RPGObjSchema('Troop', 'RPG::Troop', [

])

WEAPON_SCHEMA = RPGObjSchema('Weapon', 'RPG::Weapon', [

])

ACTORS_SCHEMA = ListSchema('actor', ACTOR_SCHEMA, FirstItem.NULL)
ANIMATIONS_SCHEMA = ListSchema('animation', ANIMATION_SCHEMA, FirstItem.NULL)
ARMORS_SCHEMA = ListSchema('armor', ARMOR_SCHEMA, FirstItem.NULL)
CLASSES_SCHEMA = ListSchema('class', CLASS_SCHEMA, FirstItem.NULL)
COMMON_EVENTS_SCHEMA = ListSchema(
	'common_event', COMMON_EVENT_SCHEMA, FirstItem.NULL
)
ENEMIES_SCHEMA = ListSchema('enemy', ENEMY_SCHEMA, FirstItem.NULL)
ITEMS_SCHEMA = ListSchema('item', ITEM_SCHEMA, FirstItem.NULL)
MAPS_SCHEMA = MultipleFilesSchema(
	re.compile(r'Map(\d{3}).rxdata'), 'map', ['number'], MAP_SCHEMA
)
MAP_INFOS_SCHEMA = DictSchema('map_info', 'id_', IntSchema(), MAP_INFO_SCHEMA)
SCRIPTS_SCHEMA = ListSchema('script', SCRIPT_SCHEMA)
SKILLS_SCHEMA = ListSchema('skill', SKILL_SCHEMA, FirstItem.NULL)
STATES_SCHEMA = ListSchema('state', STATE_SCHEMA, FirstItem.NULL)
TILESETS_SCHEMA = ListSchema('tilese', TILESET_SCHEMA, FirstItem.NULL)
TROOPS_SCHEMA = ListSchema('troop', TROOP_SCHEMA, FirstItem.NULL)
WEAPONS_SCHEMA = ListSchema('weapon', WEAPON_SCHEMA, FirstItem.NULL)

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