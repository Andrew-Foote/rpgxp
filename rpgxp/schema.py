from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
import functools as ft
import re
from string import Template
from typing import Any, Callable, Iterator, Literal, Sequence
from rpgxp.common import *

class SchemaError(Exception):
    """An error indicating that the schema built in this file is invalid."""

###############################################################################

# Classes used to build the schema

@dataclass(frozen=True)
class DataSchema(ABC):
    """A schema for a part of the RPG Maker XP data structure."""

@dataclass(frozen=True)
class RowSchema(DataSchema, ABC):
    """A schema for an object which corresponds to an individual database row
    (as opposed to a whole table)."""

@dataclass(frozen=True)
class TableSchema(DataSchema, ABC):
    """A schema for an object which corresponds to a whole database table (as
    opposed to an individual row)."""

    @property
    @abstractmethod
    def table_name(self) -> Template:
        """The name of the database table corresponding to the object."""

@dataclass(frozen=True)
class BoolSchema(RowSchema):
    """A schema for a Boolean value (true or false)."""

@dataclass(frozen=True)
class IntBoolSchema(RowSchema):
    """A schema for a Boolean value (true or false) which is represented in the
    RPG Maker XP data structure by an integer, either 0 (for false) or 1 (for
    true)."""

@dataclass(frozen=True)
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

    def matches(self, value: int) -> bool:
        lb = self.lb

        if lb is not None and value < lb:
            return False

        ub = self.ub

        if ub is not None and value > ub:
            return False

        return True

@dataclass(frozen=True)
class FloatSchema(RowSchema):
    """A schema for a floating-point value.

    Attributes:
      lb
        A lower bound on the value. Can be None for no lower bound.
      ub
        An upper bound on the value. Can be None for no upper bound.
    """

    lb: float | None=None
    ub: float | None=None

    def matches(self, value: float) -> bool:
        lb = self.lb

        if lb is not None and value < lb:
            return False

        ub = self.ub

        if ub is not None and value > ub:
            return False

        return True

@dataclass(frozen=True)
class StrSchema(RowSchema):
    """A schema for a string value."""

@dataclass(frozen=True)
class ZlibSchema(RowSchema):
    """Schema for a value consisting of bytes obtained by compressing a
    string using zlib.

    Attributes:
      encoding
        The encoding of the original string."""

    encoding: str

@dataclass(frozen=True)
class NDArraySchema(RowSchema):
    """Schema for a value which is a multi-dimensional array.

    Attributes:
      dims
        The number of dimensions; can only be 1, 2, or 3.
    """

    dims: Literal[1] | Literal[2] | Literal[3]

@dataclass(frozen=True)
class EnumSchema(RowSchema):
    enum_class: type[Enum]

@dataclass(frozen=True)
class MaterialRefSchema(RowSchema):
    material_type: str
    material_subtype: str
    nullable: bool=True
    enforce_fk: bool=True

@dataclass(frozen=True)
class RefableSchema(TableSchema):
    @abstractmethod
    def pk_db_name(self) -> str:
        ...

    @abstractmethod
    def pk_schema(self) -> DataSchema:
        ...

@dataclass(frozen=True)
class FKSchema(RowSchema):
    foreign_schema_thunk: Callable[[], RefableSchema] 
    nullable: bool=True

@dataclass(frozen=True)
class ObjSchema(RowSchema, ABC):
    @property
    @abstractmethod
    def class_name(self) -> str:
        """The name of the Python class corresponding to this schema."""

    @property
    @abstractmethod
    def fields(self) -> Sequence[FieldBase]:
        ...

    def has_field(self, field_name: str) -> bool:
        for f in self.fields:
            if f.name == field_name:
                return True

        return False

    def get_field(self, field_name: str) -> FieldBase:
        for f in self.fields:
            if f.name == field_name:
                return f

        raise ValueError(f'field not found: {field_name}')

@dataclass(frozen=True)
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

@dataclass(frozen=True)
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

@dataclass(frozen=True)
class ArrayObjSchema(ObjSchema, RowSchema):
    _class_name: str
    _fields: list[Field]

    @property
    def class_name(self) -> str:
        return self._class_name

    @property
    def fields(self) -> list[Field]:
        return self._fields

@dataclass(frozen=True)
class RPGField(FieldBase):
    _name: str
    _schema: DataSchema
    _db_name: str=''
    rpg_name: str=''

    def __post_init__(self) -> None:
        if not self.rpg_name:
            object.__setattr__(self, 'rpg_name', self.name)

    @property
    def name(self) -> str:
        return self._name

    @property
    def schema(self) -> DataSchema:
        return self._schema

    @property
    def db_name(self) -> str:
        return self._db_name or self.name

@dataclass(frozen=True)
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

@dataclass(frozen=True)
class RPGSingletonObjSchema(ObjSchema, TableSchema):
    _class_name: str
    _table_name: str
    rpg_class_name: str
    _fields: list[RPGField]

    @property
    def class_name(self) -> str:
        return self._class_name

    @property
    def table_name(self) -> Template:
        return Template(self._table_name)

    @property
    def fields(self) -> list[RPGField]:
        return self._fields

@dataclass(frozen=True)
class ColorSchema(ObjSchema):
    """A schema for an RGSS 'Color' object."""

    @property
    def class_name(self) -> str:
        return 'Color'

    @property
    def fields(self) -> list[FieldBase]:
        return [
            RPGField('red', FloatSchema(0, 255)),
            RPGField('green', FloatSchema(0, 255)),
            RPGField('blue', FloatSchema(0, 255)),
            RPGField('alpha', FloatSchema(0, 255)),
        ]

@dataclass(frozen=True)
class ToneSchema(ObjSchema):
    """A schema for an RGSS 'Tone' object."""

    @property
    def class_name(self) -> str:
        return 'Tone'

    @property
    def fields(self) -> list[FieldBase]:
        return [
            RPGField('red', FloatSchema(-255, 255)),
            RPGField('green', FloatSchema(-255, 255)),
            RPGField('blue', FloatSchema(-255, 255)),
            RPGField('grey', FloatSchema(0, 255)),
        ]

@dataclass(frozen=True)
class Variant(ABC):
    @property
    @abstractmethod
    def discriminant_value(self) -> Any:
        ...

    @property
    @abstractmethod
    def name(self) -> Any:
        ...

    @property
    @abstractmethod
    def fields(self) -> list[Field]:
        ...

@dataclass(frozen=True)
class SimpleVariant(Variant):
    _discriminant_value: Any
    _name: str
    _fields: list[Field]

    @property
    def discriminant_value(self) -> Any:
        return self._discriminant_value

    @property
    def name(self) -> Any:
        return self._name

    @property
    def fields(self) -> list[Field]:
        return self._fields

@dataclass(frozen=True)
class ComplexVariant(Variant):
    _discriminant_value: Any
    _name: str
    _fields: list[Field]
    subdiscriminant_name: str
    variants: list[Variant]

    @property
    def discriminant_value(self) -> Any:
        return self._discriminant_value

    @property
    def name(self) -> Any:
        return self._name

    @property
    def fields(self) -> list[Field]:
        return self._fields

    @property
    def subdiscriminant(self) -> Field:
        for field in self.fields:
            if field.name == self.subdiscriminant_name:
                return field

        raise RuntimeError(
            f"no field named '{self.subdiscriminant_name}'"
        )


@dataclass(frozen=True)
class RPGVariantObjSchema(ObjSchema):
    _class_name: str
    rpg_class_name: str
    _fields: list[RPGField]
    discriminant_name: str
    variants: list[Variant]

    @property
    def class_name(self) -> str:
        return self._class_name

    @property
    def fields(self) -> list[RPGField]:
        return self._fields   

    @property
    def discriminant(self) -> Field:
        for field in self.fields:
            if field.name == self.discriminant_name:
                return Field(
                    field.name, field.schema, field.db_name
                )

        raise RuntimeError(f"no field named '{self.discriminant_name}'")

class FirstItem(Enum):
    REGULAR = 0
    NULL = 1
    BLANK = 2

@dataclass(frozen=True)
class IndexBehavior(ABC):
    pass

@dataclass(frozen=True)
class AddIndexColumn(IndexBehavior):
    col_name: str

@dataclass(frozen=True)
class MatchIndexToField(IndexBehavior):
    match_to: str

@dataclass(frozen=True)
class ListSchema(RefableSchema):
    """The schema for a Marshal array.

    Attributes:
      table_name
        Name of the database table corresponding to this array.
      item_schema
        Schema for the array items.
      first_item
        If set to FirstItem.NULL or FirstItem.BLANK (rather than
        FirstItem.REGULAR, the default value), indicates that the first item
        of the array will not match the given schema, and instead will either
        be null, or an empty string, respectively.
      item_name
        Name of the database column corresponding to the content of each array
        item. If the items will be represented by values spread across multiple
        columns, or the item schema already provides a name for the column,
        this name will be used as a prefix on all those columns. If item_name
        is left blank, there will be no prefix in the latter case, and a
        default name of 'content' will be used in the former case.
      length_schema
        Schema for the array length, which can be used to set upper and lower
        bounds on its length.
      index
        This should be set to an IndexBehavior object which indicates how to
        handle the storing of the index at which each array item is located.
        If set to an AddIndexField object, then the database table
        corresponding to to this array will have an extra column added to store
        this index, with the name specified on the object. The default name is
        'index'. If set to a MatchIndexToField object, it is expected that the
        item_schema will also be a subclass of ObjSchema, and that the index
        for each item will always be the same as one of its fields (so that the
        index doesn't need to be stored separately in the database).
    """

    _table_name: str
    item_schema: RowSchema
    first_item: FirstItem=FirstItem.REGULAR
    item_name: str=''
    length_schema: IntSchema=IntSchema()
    index: IndexBehavior=AddIndexColumn('index')

    @property
    def table_name(self) -> Template:
        return Template(self._table_name)

    def __post_init__(self) -> None:
        if isinstance(self.index, MatchIndexToField):
            assert isinstance(self.item_schema, ObjSchema)
            assert self.item_schema.has_field(self.index.match_to)

    def pk_db_name(self) -> str:
        match self.index:
            case AddIndexColumn(col_name):
                return col_name
            case MatchIndexToField(field_name):
                assert isinstance(self.item_schema, ObjSchema)
                return self.item_schema.get_field(field_name).db_name
            case _:
                assert False

    def pk_schema(self) -> DataSchema:
        match self.index:
            case AddIndexColumn(_):
                return IntSchema(lb=0)
            case MatchIndexToField(field_name):
                assert isinstance(self.item_schema, ObjSchema)
                return self.item_schema.get_field(field_name).schema
            case _:
                assert False

@dataclass(frozen=True)
class SetSchema(TableSchema):
    _table_name: str
    item_schema: RowSchema
    item_name: str=''

    @property
    def table_name(self) -> Template:
        return Template(self._table_name)

@dataclass(frozen=True)
class KeyBehavior(ABC):
    pass

@dataclass(frozen=True)
class AddKeyColumn(KeyBehavior):
    col_name: str
    key_schema: RowSchema

@dataclass(frozen=True)
class MatchKeyToField(KeyBehavior):
    match_to: str

@dataclass(frozen=True)
class DictSchema(RefableSchema):
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

    _table_name: str
    key: KeyBehavior
    value_schema: ObjSchema
    value_name: str=''

    @property
    def table_name(self) -> Template:
        return Template(self._table_name)

    @property
    def key_schema(self) -> DataSchema:
        match self.key:
            case AddKeyColumn(_, key_schema):
                return key_schema
            case MatchKeyToField(field_name):
                return self.value_schema.get_field(field_name).schema
            case _:
                assert False

    def __post_init__(self) -> None:
        if isinstance(self.key, MatchKeyToField):
            assert self.value_schema.has_field(self.key.match_to)

    def pk_db_name(self) -> str:
        match self.key:
            case AddKeyColumn(col_name, _):
                return col_name
            case MatchKeyToField(field_name):
                return self.value_schema.get_field(field_name).db_name
            case _:
                assert False

    def pk_schema(self) -> DataSchema:
        match self.key:
            case AddKeyColumn(_, key_schema):
                return key_schema
            case MatchKeyToField(field_name):
                return self.value_schema.get_field(field_name).schema
            case _:
                assert False

@dataclass(frozen=True)
class FileSchema(ABC):
    pass

@dataclass(frozen=True)
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

@dataclass(frozen=True)
class FileKey:
    schema: DataSchema
    app_name: str
    db_name: str=''

    def __post_init__(self) -> None:
        if not self.db_name:
            object.__setattr__(self, 'db_name', self.app_name)

@dataclass(frozen=True)
class MultipleFilesSchema(FileSchema, RefableSchema):
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
    keys: list[FileKey]
    schema: ObjSchema

    @property
    def table_name(self) -> Template:
        return Template(self._table_name)

    def pk_db_name(self) -> str:
        assert len(self.keys) == 1
        key, = self.keys
        return key.db_name

    def pk_schema(self) -> DataSchema:
        assert len(self.keys) == 1
        key, = self.keys
        return key.schema

###############################################################################

# Utility functions to help with building the schema

def id_field() -> RPGField:
    return RPGField('id_', IntSchema(), _db_name='id', rpg_name='id')

def bool_field(name: str) -> RPGField:
    return RPGField(name, BoolSchema())

def int_field(name: str) -> RPGField:
    return RPGField(name, IntSchema())

def str_field(name: str) -> RPGField:
    return RPGField(name, StrSchema())

def many_fields(
    names: str, maker: Callable[[str], RPGField]
) -> Iterator[RPGField]:

    for name in names.split():
        yield maker(name)

bool_fields = ft.partial(many_fields, maker=bool_field)
int_fields = ft.partial(many_fields, maker=int_field)
str_fields = ft.partial(many_fields, maker=str_field)

def enum_field(name: str, cls: type[Enum]) -> RPGField:
    return RPGField(name, EnumSchema(cls))

def fk_field(
    name: str, schema_thunk: Callable[[], RefableSchema], nullable: bool
) -> RPGField:

    return RPGField(name, FKSchema(schema_thunk, nullable=nullable))

###############################################################################

# The actual schema

HUE_SCHEMA = IntSchema(0, 360)

def hue_field(name: str) -> RPGField:
    return RPGField(name, HUE_SCHEMA)

def audio_schema(subtype: str, *, enforce_fk: bool=True) -> RPGObjSchema:
    return RPGObjSchema('AudioFile', 'RPG::AudioFile', [
        RPGField('name', MaterialRefSchema(
            'Audio', subtype, enforce_fk=enforce_fk
        )),
        *int_fields('volume pitch')
    ])

def audio_field(
    name: str, subtype: str, *, enforce_fk: bool=True
) -> RPGField:
    
    return RPGField(name, audio_schema(subtype, enforce_fk=enforce_fk))

def audio_fields(names: str, subtype: str) -> Iterator[RPGField]:
    return many_fields(names, maker=ft.partial(
        audio_field, subtype=subtype
    ))

ELEMENT_SCHEMA = FKSchema(lambda: ELEMENTS_SCHEMA)
SWITCH_SCHEMA = FKSchema(lambda: SWITCHES_SCHEMA)
VARIABLE_SCHEMA = FKSchema(lambda: VARIABLES_SCHEMA)

ACTOR_SCHEMA = RPGObjSchema('Actor', 'RPG::Actor', [
    id_field(),
    str_field('name'),
    fk_field('class_id', lambda: CLASSES_SCHEMA, False),
    *int_fields('initial_level final_level'),
    RPGField('exp_basis', IntSchema(10, 50)),
    RPGField('exp_inflation', IntSchema(10, 50)),
    RPGField('character_name', MaterialRefSchema('Graphics', 'Characters')),
    hue_field('character_hue'),
    RPGField('battler_name', MaterialRefSchema('Graphics', 'Battlers')),
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
        audio_field('se', 'SE'),
        enum_field('flash_scope', AnimationTimingFlashScope),
        RPGField('flash_color', ColorSchema()),
        int_field('flash_duration'),
        enum_field('condition', AnimationTimingCondition),
    ]
)

ANIMATION_SCHEMA = RPGObjSchema('Animation', 'RPG::Animation', [
    id_field(),
    str_field('name'),
    RPGField('animation_name', MaterialRefSchema('Graphics', 'Animations')),
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
    str_field('name'),
    RPGField('icon_name', MaterialRefSchema('Graphics', 'Icons')),
    str_field('description'),
    enum_field('kind', ArmorKind),
    fk_field('auto_state_id', lambda: STATES_SCHEMA, True),
    *int_fields('price pdef mdef eva str_plus dex_plus agi_plus int_plus'),
    RPGField('guard_element_set', SetSchema(
        'armor_guard_element', FKSchema(lambda: ELEMENTS_SCHEMA), 'element_id'
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

MOVE_COMMAND_SCHEMA = RPGVariantObjSchema('MoveCommand', 'RPG::MoveCommand', [
    RPGField('code', IntSchema())
], 'code', [
    SimpleVariant(0, 'Blank', []),
    SimpleVariant(1, 'MoveDown', []),
    SimpleVariant(2, 'MoveLeft', []),
    SimpleVariant(3, 'MoveRight', []),
    SimpleVariant(4, 'MoveUp', []),
    SimpleVariant(5, 'MoveLowerLeft', []),
    SimpleVariant(6, 'MoveLowerRight', []),
    SimpleVariant(7, 'MoveUpperLeft', []),
    SimpleVariant(8, 'MoveUpperRight', []),
    SimpleVariant(9, 'MoveAtRandom', []),
    SimpleVariant(10, 'MoveTowardPlayer', []),
    SimpleVariant(11, 'MoveAwayFromPlayer', []),
    SimpleVariant(12, 'StepForward', []),
    SimpleVariant(13, 'StepBackward', []),
    SimpleVariant(14, 'Jump', [
        Field('x', IntSchema()),
        Field('y', IntSchema())
    ]),
    SimpleVariant(15, 'Wait', [Field('duration', IntSchema())]),
    SimpleVariant(16, 'TurnDown', []),
    SimpleVariant(17, 'TurnLeft', []),
    SimpleVariant(18, 'TurnRight', []),
    SimpleVariant(19, 'TurnUp', []),
    SimpleVariant(20, 'Turn90Right', []),
    SimpleVariant(21, 'Turn90Left', []),
    SimpleVariant(22, 'Turn180', []),
    SimpleVariant(23, 'Turn90RightOrLeft', []),
    SimpleVariant(24, 'TurnAtRandom', []),
    SimpleVariant(25, 'TurnTowardPlayer', []),
    SimpleVariant(26, 'TurnAwayFromPlayer', []),
    SimpleVariant(27, 'SwitchOn', [Field('switch_id', SWITCH_SCHEMA)]),
    SimpleVariant(28, 'SwitchOff', [Field('switch_id', SWITCH_SCHEMA)]),
    SimpleVariant(29, 'ChangeSpeed', [Field('speed', EnumSchema(MoveSpeed))]),
    SimpleVariant(30, 'ChangeFreq', [
        Field('freq', EnumSchema(MoveFrequency))
    ]),
    SimpleVariant(31, 'MoveAnimationOn', []),
    SimpleVariant(32, 'MoveAnimationOff', []),
    SimpleVariant(33, 'StopAnimationOn', []),
    SimpleVariant(34, 'StopAnimationOff', []),
    SimpleVariant(35, 'DirectionFixOn', []),
    SimpleVariant(36, 'DirectionFixOff', []),
    SimpleVariant(37, 'ThroughOn', []),
    SimpleVariant(38, 'ThroughOff', []),
    SimpleVariant(39, 'AlwaysOnTopOn', []),
    SimpleVariant(40, 'AlwaysOnTopOff', []),
    SimpleVariant(41, 'Graphic', [
        Field('character_name', MaterialRefSchema('Graphics', 'Characters')),
        Field('character_hue', HUE_SCHEMA),
        Field('direction', EnumSchema(Direction)),
        Field('pattern', IntSchema())
    ]),
    SimpleVariant(42, 'ChangeOpacity', [Field('opacity', IntSchema())]),
    SimpleVariant(43, 'ChangeBlending', [Field('blend_type', IntSchema())]),
    SimpleVariant(44, 'PlaySE', [Field('audio', audio_schema('SE'))]),
    SimpleVariant(45, 'Script', [Field('line', StrSchema())]),
])

MOVE_ROUTE_SCHEMA = RPGObjSchema('MoveRoute', 'RPG::MoveRoute', [
    *bool_fields('repeat skippable'),
    RPGField(
        'list_', ListSchema(
            '${prefix}move_command', MOVE_COMMAND_SCHEMA
        ),
        rpg_name='list', _db_name='list'
    )
])

EVENT_COMMAND_SCHEMA = RPGVariantObjSchema(
    'EventCommand', 'RPG::EventCommand',
    [
        RPGField('code', IntSchema()),
        RPGField('indent', IntSchema(lb=0)),
    ], 'code', [
        SimpleVariant(0, 'Blank', []),
        SimpleVariant(101, 'ShowText', [Field('text', StrSchema())]),
        SimpleVariant(102, 'ShowChoices', [
            Field('choices', ListSchema(
                # nah, instead of doing this templating,
                # we should make EVENT_COMMAND_SCHEMA a function
                # that takes a prefix as argument
                # ... or we can just not allow fks to point to 
                # ones where the templat ehas params
                '${prefix}choice', StrSchema(),
                item_name='choice'
            )),
            Field('cancel_type', EnumSchema(ChoicesCancelType)),
        ]),
        SimpleVariant(103, 'InputNumber', [
            Field('variable_id', VARIABLE_SCHEMA),
            Field('max_digits', IntSchema())
        ]),
        SimpleVariant(104, 'ChangeTextOptions', [
            Field('position', EnumSchema(TextPosition)),
            Field('no_frame', IntBoolSchema()),
        ]),
        SimpleVariant(105, 'ButtonInputProcessing', [
            Field('variable_id', VARIABLE_SCHEMA),
        ]),

        # units = frames / 2,
        SimpleVariant(106, 'Wait', [Field('duration', IntSchema())]),

        SimpleVariant(108, 'Comment', [Field('text', StrSchema())]),
        ComplexVariant(111, 'ConditionalBranch', [
            Field('subcode', IntSchema()),
        ], 'subcode', [
            SimpleVariant(0, 'Switch', [
                Field('switch_id', SWITCH_SCHEMA),
                Field('state', EnumSchema(SwitchState)),
            ]),
            SimpleVariant(1, 'Variable', [
                Field('variable_id', IntSchema()),
                Field('value_is_variable', IntBoolSchema()),
                Field('value', IntSchema()),
                Field('comparison', EnumSchema(Comparison))
            ]),
            SimpleVariant(2, 'SelfSwitch', [
                Field('self_switch_ch', EnumSchema(SelfSwitch)), 
                Field('state', EnumSchema(SwitchState)),
            ]),
            SimpleVariant(3, 'Timer', [
                Field('value', IntSchema()),
                Field('bound_type', EnumSchema(BoundType))
            ]),
            # don't know field layouts for these two
            ComplexVariant(4, 'Actor', [
                Field('actor_id', FKSchema(lambda: ACTORS_SCHEMA)),
                Field('infracode', IntSchema()),
            ], 'infracode', [
                SimpleVariant(0, 'InParty', []),
                SimpleVariant(1, 'Name', [Field('value', StrSchema())]),
                SimpleVariant(2, 'Skill', [
                    Field('skill_id', FKSchema(lambda: SKILLS_SCHEMA))
                ]),
                SimpleVariant(3, 'Weapon', [
                    Field('weapon_id', FKSchema(lambda: WEAPONS_SCHEMA)),
                ]),
                SimpleVariant(4, 'Armor', [
                    Field('armor_id', FKSchema(lambda: ARMORS_SCHEMA)),
                ]),
                SimpleVariant(5, 'State', [
                    Field('state_id', FKSchema(lambda: STATES_SCHEMA)),
                ])
            ]),
            ComplexVariant(5, 'Enemy', [
                Field('enemy_id', FKSchema(lambda: ENEMIES_SCHEMA)),
                Field('infracode', IntSchema()),
            ], 'infracode', [
                SimpleVariant(0, 'Appear', []),
                SimpleVariant(1, 'State', [
                    Field('state_id', FKSchema(lambda: STATES_SCHEMA)),
                ])
            ]),
            # branch based on a character sprite's direction
            SimpleVariant(6, 'Character', [
                # -1 = player, 0 = current event, otherwise an event id
                Field('character_reference', IntSchema()),
                Field('direction', EnumSchema(Direction))
            ]),
            SimpleVariant(7, 'Gold', [
                Field('amount', IntSchema()),
                Field('bound_type', EnumSchema(BoundType)),
            ]),
            SimpleVariant(8, 'Item', [
                Field('item_id', FKSchema(lambda: ITEMS_SCHEMA)),
            ]),
            SimpleVariant(9, 'Weapon', [
                Field('weapon_id', FKSchema(lambda: WEAPONS_SCHEMA)),
            ]),
            SimpleVariant(10, 'Armor', [
                Field('armor_id', FKSchema(lambda: ARMORS_SCHEMA)),
            ]),
            SimpleVariant(11, 'Button', [Field('button', IntSchema())]),
            SimpleVariant(12, 'Script', [Field('expr', StrSchema())]),
        ]),
        SimpleVariant(112, 'Loop', []),
        SimpleVariant(113, 'BreakLoop', []),
        SimpleVariant(115, 'ExitEventProcessing', []),
        SimpleVariant(116, 'EraseEvent', []),
        SimpleVariant(117, 'CallCommonEvent', [
            Field('called_event_id', FKSchema(lambda: COMMON_EVENTS_SCHEMA))
        ]),
        SimpleVariant(118, 'Label', [Field('id', StrSchema())]),
        SimpleVariant(119, 'JumpToLabel', [Field('id', StrSchema())]),
        SimpleVariant(121, 'ControlSwitches', [
            # this is an inclusive range of switch IDs to set at once
            Field('switch_id_lo', IntSchema()),
            Field('switch_id_hi', IntSchema()),
            Field('state', EnumSchema(SwitchState))
        ]),
        ComplexVariant(122, 'ControlVariables', [
            Field('variable_id_hi', IntSchema()),
            Field('variable_id_lo', IntSchema()),
            Field('assign_type', EnumSchema(AssignType)),
            Field('operand_type', IntSchema()),
        ], 'operand_type', [
            SimpleVariant(0, 'Invariant', [
                Field('value', IntSchema())
            ]),
            SimpleVariant(1, 'Variable', [
                Field('variable_id', VARIABLE_SCHEMA)
            ]),
            SimpleVariant(2, 'RandomNumber', [
                Field('lb', IntSchema()),
                Field('ub', IntSchema()),
            ]),
            SimpleVariant(6, 'Character', [
                Field('attr_value', IntSchema()),
                Field('attr_code', IntSchema()),
            ]),
            SimpleVariant(7, 'Other', [
                Field('other_operand_type', EnumSchema(OtherOperandType)),
            ]),
        ]),
        SimpleVariant(123, 'ControlSelfSwitch', [
            Field('self_switch_ch', EnumSchema(SelfSwitch)),
            Field('state', EnumSchema(SwitchState)),
        ]),
        ComplexVariant(124, 'ControlTimer', [
            Field('subcode', IntSchema()),
        ], 'subcode', [
            SimpleVariant(0, 'Start', [
                Field('initial_value', IntSchema()),
            ]),
            SimpleVariant(1, 'Stop', []),
        ]),
        SimpleVariant(125, 'ChangeGold', [
            Field('diff_type', EnumSchema(DiffType)),
            Field('with_variable', IntBoolSchema()),
            Field('amount', IntSchema()),
        ]),
        SimpleVariant(126, 'ChangeItems', [
            Field('item_id', FKSchema(lambda: ITEMS_SCHEMA)),
            Field('operation', EnumSchema(DiffType)),
            Field('operand_type', EnumSchema(ConstOrVar)),
            Field('operand', IntSchema()),
        ]),
        SimpleVariant(127, 'ChangeWeapons', [
            Field('weapon_id', FKSchema(lambda: WEAPONS_SCHEMA)),
            Field('operation', EnumSchema(DiffType)),
            Field('operand_type', EnumSchema(ConstOrVar)),
            Field('operand', IntSchema()),
        ]),
        SimpleVariant(128, 'ChangeArmor', [
            Field('armor_id', FKSchema(lambda: ARMORS_SCHEMA)),
            Field('operation', EnumSchema(DiffType)),
            Field('operand_type', EnumSchema(ConstOrVar)),
            Field('operand', IntSchema()),
        ]),
        SimpleVariant(129, 'ChangePartyMember', [
            Field('actor_id', FKSchema(lambda: ACTORS_SCHEMA)),
            Field('add_or_remove', EnumSchema(AddOrRemove)),
            Field('initialize', IntBoolSchema()),
        ]),
        SimpleVariant(132, 'ChangeBattleBGM', [
            Field('audio', audio_schema('BGM')),
        ]),
        SimpleVariant(133, 'ChangeBattleEndME', [
            Field('audio', audio_schema('ME')),
        ]),
        SimpleVariant(134, 'ChangeSaveAccess', [
            Field('enabled', IntBoolSchema()),
        ]),
        SimpleVariant(135, 'ChangeMenuAccess', [
            Field('enabled', IntBoolSchema()),
        ]),
        SimpleVariant(136, 'ChangeEncounter', [
            Field('enabled', IntBoolSchema()),
        ]),
        SimpleVariant(201, 'TransferPlayer', [
            Field('with_variables', IntBoolSchema()),
            Field('target_map_id', IntSchema()),
            Field('x', IntSchema()), Field('y', IntSchema()),
            Field('direction', EnumSchema(Direction)),
            Field('no_fade', IntBoolSchema()),
        ]),
        SimpleVariant(202, 'SetEventLocation', [
            Field('event_reference', IntSchema()), # 0 for this event
            Field('appoint_type', EnumSchema(AppointType)),
            Field('x', IntSchema()), Field('y', IntSchema()),
            Field('direction', EnumSchema(Direction)),
        ]),
        SimpleVariant(203, 'ScrollMap', [
            Field('direction', EnumSchema(Direction)),
            Field('distance', IntSchema()),
            Field('speed', IntSchema()),
        ]),
        ComplexVariant(204, 'ChangeMapSettings', [
            Field('subcode', IntSchema())
        ], 'subcode', [
            SimpleVariant(0, 'Panorama', [
                Field('name', MaterialRefSchema('Graphics', 'Panoramas')),
                Field('hue', HUE_SCHEMA),
            ]),
            SimpleVariant(1, 'Fog', [
                Field('name', MaterialRefSchema('Graphics', 'Fogs')),
                Field('hue', IntSchema()),
                Field('opacity', IntSchema()),
                Field('blend_type', IntSchema()),
                Field('zoom', IntSchema()),
                Field('sx', IntSchema()),
                Field('sy', IntSchema()),
            ]),
            SimpleVariant(2, 'BattleBack', [
                Field('name', MaterialRefSchema('Graphics', 'Battlebacks')),
            ]),
        ]),
        SimpleVariant(205, 'ChangeFogColorTone', [
            Field('tone', ToneSchema()),
            Field('duration', IntSchema()),
        ]),
        SimpleVariant(206, 'ChangeFogOpacity', [
            Field('opacity', IntSchema()),
            Field('duration', IntSchema())
        ]),
        SimpleVariant(207, 'ShowAnimation', [
            # -1 for player, 0 for this event
            Field('event_reference', IntSchema()),
            Field('animation_id', IntSchema())
        ]),
        SimpleVariant(208, 'ChangeTransparentFlag', [
            Field('is_normal', IntBoolSchema())
        ]),
        SimpleVariant(209, 'SetMoveRoute', [
            # can be -1 for player
            Field('event_reference', IntSchema()),
            Field('move_route', MOVE_ROUTE_SCHEMA),
        ]),
        SimpleVariant(210, 'WaitForMoveCompletion', []),
        SimpleVariant(221, 'PrepareForTransition', []),
        SimpleVariant(222, 'ExecuteTransition', [
            Field('name', StrSchema())
        ]),
        SimpleVariant(223, 'ChangeScreenColorTone', [
            Field('tone', ToneSchema()),
            Field('duration', IntSchema()) # units = frames / 2
        ]),
        SimpleVariant(224, 'ScreenFlash', [
            Field('color', ColorSchema()),
            Field('duration', IntSchema()), # units = frames / 2
        ]),
        SimpleVariant(225, 'ScreenShake', [
            Field('power', IntSchema()),
            Field('speed', IntSchema()),
            Field('duration', IntSchema()),
        ]),
        SimpleVariant(231, 'ShowPicture', [
            Field('number', IntSchema()),
            Field('name', MaterialRefSchema('Graphics', 'Pictures')),
            Field('origin', IntSchema()),
            Field('appoint_with_vars', IntBoolSchema()),
            Field('x', IntSchema()), Field('y', IntSchema()),
            Field('zoom_x', IntSchema()), Field('zoom_y', IntSchema()),
            Field('opacity', IntSchema()), Field('blend_type', IntSchema())
        ]),
        SimpleVariant(232, 'MovePicture', [
            Field('number', IntSchema()), Field('duration', IntSchema()),
            Field('origin', IntSchema()),
            Field('appoint_with_vars', IntBoolSchema()),
            Field('x', IntSchema()), Field('y', IntSchema()),
            Field('zoom_x', IntSchema()), Field('zoom_y', IntSchema()),
            Field('opacity', IntSchema()), Field('blend_type', IntSchema()),
        ]),
        SimpleVariant(233, 'RotatePicture', [
            Field('number', IntSchema()),
            Field('speed', IntSchema()),
        ]),
        SimpleVariant(234, 'ChangePictureColorTone', [
            Field('number', IntSchema()),
            Field('tone', ToneSchema()),
            Field('duration', IntSchema()),
        ]),
        SimpleVariant(235, 'ErasePicture', [Field('number', IntSchema())]),
        SimpleVariant(236, 'SetWeatherEffects', [
            Field('type', EnumSchema(Weather)),
            Field('power', IntSchema()),
            Field('duration', IntSchema())
        ]),
        SimpleVariant(241, 'PlayBGM', [Field('audio', audio_schema('BGM'))]),
        SimpleVariant(242, 'FadeOutBGM', [Field('seconds', IntSchema())]),
        SimpleVariant(245, 'PlayBGS', [Field('audio', audio_schema('BGS'))]),
        SimpleVariant(246, 'FadeOutBGS', [Field('seconds', IntSchema())]),
        SimpleVariant(247, 'MemorizeBGAudio', []),
        SimpleVariant(248, 'RestoreBGAudio', []),
        SimpleVariant(249, 'PlayME', [Field('audio', audio_schema('ME'))]),
        SimpleVariant(250, 'PlaySE', [Field('audio', audio_schema('SE'))]),
        SimpleVariant(251, 'StopSE', []),
        SimpleVariant(301, 'BattleProcessing', [
            Field('opponent_troop_id', FKSchema(lambda: TROOPS_SCHEMA)),
            Field('can_escape', BoolSchema()),
            Field('can_continue_when_loser', BoolSchema()),
        ]),
        SimpleVariant(302, 'ShopProcessing', [
            Field('goods', IntSchema()),
            Field('price', IntSchema()),
        ]),
        SimpleVariant(303, 'NameInputProcessing', [
            Field('actor_id', FKSchema(lambda: ACTORS_SCHEMA)),
            Field('maxlen', IntSchema()),
        ]),
        SimpleVariant(314, 'RecoverAll', [
            # 0 for all party
            Field('actor_id', FKSchema(lambda: ACTORS_SCHEMA)),
        ]),
        SimpleVariant(335, 'EnemyAppearance', [
            Field('enemy_index', IntSchema()),
        ]),
        SimpleVariant(336, 'EnemyTransform', [
            Field('enemy_index', IntSchema()),
            Field('new_enemy_id', FKSchema(lambda: ENEMIES_SCHEMA)),
        ]),
        SimpleVariant(340, 'AbortBattle', []),
        SimpleVariant(351, 'CallMenuScreen', []),
        SimpleVariant(352, 'CallSaveScreen', []),
        SimpleVariant(353, 'GameOver', []),
        SimpleVariant(354, 'ReturnToTitleScreen', []),
        SimpleVariant(355, 'Script', [Field('line', StrSchema())]),
        SimpleVariant(401, 'ContinueShowText', [
            Field('text', StrSchema()),
        ]),
        SimpleVariant(402, 'ShowChoicesWhenChoice', [
            Field('choice_index', IntSchema()),
            Field('choice_text', StrSchema()),
        ]),
        SimpleVariant(403, 'ShowChoicesWhenCancel', []),
        SimpleVariant(404, 'ShowChoicesBranchEnd', []),
        SimpleVariant(408, 'ContinueComment', [
            Field('text', StrSchema()),
        ]),
        SimpleVariant(411, 'Else', []),
        SimpleVariant(412, 'ConditionalBranchEnd', []),
        SimpleVariant(413, 'RepeatAbove', []),
        SimpleVariant(509, 'ContinueSetMoveRoute', [
            Field('command', MOVE_COMMAND_SCHEMA),
        ]),
        SimpleVariant(601, 'IfWin', []),
        SimpleVariant(602, 'IfEscape', []),
        SimpleVariant(603, 'IfLose', []),
        SimpleVariant(604, 'BattleProcessingEnd', []),
        SimpleVariant(605, 'ContinueShopProcessing', [
            Field('goods', IntSchema()),
            Field('price', IntSchema()),
        ]),
        SimpleVariant(655, 'ContinueScript', [
            Field('line', StrSchema()),
        ]),
    ]
)

COMMON_EVENT_SCHEMA = RPGObjSchema('CommonEvent', 'RPG::CommonEvent', [
    id_field(),
    str_field('name'),
    enum_field('trigger', CommonEventTrigger),
    RPGField('switch_id', SWITCH_SCHEMA),
    RPGField('list_', ListSchema(
        'common_event_command', EVENT_COMMAND_SCHEMA
    ), rpg_name='list', _db_name='list'),
])

ENEMY_ACTION_SCHEMA = RPGObjSchema('EnemyAction', 'RPG::Enemy::Action', [
    enum_field('kind', EnemyActionKind),
    enum_field('basic', EnemyBasicAction),
    fk_field('skill_id', lambda: SKILLS_SCHEMA, True),
    *int_fields('''
        condition_turn_a condition_turn_b condition_hp condition_level
    '''),
    RPGField('condition_switch_id', SWITCH_SCHEMA),
    RPGField('rating', IntSchema(1, 10)),
])

ENEMY_SCHEMA = RPGObjSchema('Enemy', 'RPG::Enemy', [
    id_field(),
    str_field('name'),
    RPGField('battler_name', MaterialRefSchema('Graphics', 'Battlers')),
    hue_field('battler_hue'),
    *int_fields('maxhp maxsp'),
    RPGField('str_', IntSchema(), rpg_name='str', _db_name='str'),
    *int_fields('dex agi'),
    RPGField('int_', IntSchema(), rpg_name='int', _db_name='int'),
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
    str_field('name'),
    RPGField('icon_name', MaterialRefSchema('Graphics', 'Icons')),
    str_field('description'),
    enum_field('scope', Scope),
    enum_field('occasion', Occasion),
    fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
    fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
    audio_field('menu_se', 'SE'),
    fk_field('common_event_id', lambda: COMMON_EVENTS_SCHEMA, True),
    int_field('price'),
    bool_field('consumable'),
    enum_field('parameter_type', ParameterType),
    *int_fields('''
        parameter_points recover_hp_rate recover_hp recover_sp_rate recover_sp
        hit pdef_f mdef_f variance
    '''),
    RPGField('element_set', SetSchema(
        'item_element', ELEMENT_SCHEMA, 'element_id'
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
        RPGField('switch1_id', SWITCH_SCHEMA),
        RPGField('switch2_id', SWITCH_SCHEMA),
        RPGField('variable_id', VARIABLE_SCHEMA),
        int_field('variable_value'),
        enum_field('self_switch_ch', SelfSwitch),
    ]
)

EVENT_PAGE_GRAPHIC_SCHEMA = RPGObjSchema(
    'EventPageGraphic',
    'RPG::Event::Page::Graphic',
    [
        int_field('tile_id'),
        RPGField('character_name', MaterialRefSchema('Graphics', 'Characters')),
        hue_field('character_hue'),
        enum_field('direction', Direction),
        RPGField('pattern', IntSchema(0, 3)),
        *int_fields('opacity blend_type'),
    ]
)

EVENT_PAGE_SCHEMA = RPGObjSchema('EventPage', 'RPG::Event::Page', [
    RPGField('condition', EVENT_PAGE_CONDITION_SCHEMA),
    RPGField('graphic', EVENT_PAGE_GRAPHIC_SCHEMA),
    enum_field('move_type', MoveType),
    enum_field('move_frequency', MoveFrequency),
    enum_field('move_speed', MoveSpeed),
    RPGField('move_route', MOVE_ROUTE_SCHEMA),
    *bool_fields('walk_anime step_anime direction_fix through always_on_top'),
    enum_field('trigger', EventPageTrigger),
    RPGField('list_', ListSchema(
        'event_page_command', EVENT_COMMAND_SCHEMA
    ), rpg_name='list', _db_name='list'),
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
    # the audio field FKs should only be enforced if the autoplay fields are
    # on, but there's no good way to do that AFAIK
    RPGField('autoplay_bgm', BoolSchema()),
    audio_field('bgm', 'BGM', enforce_fk=False),
    RPGField('autoplay_bgs', BoolSchema()),
    audio_field('bgs', 'BGS', enforce_fk=False),
    RPGField('encounter_list', ListSchema(
        'encounter', FKSchema(lambda: TROOPS_SCHEMA, nullable=False),
        item_name='troop_id'
    )),
    RPGField('encounter_step', IntSchema()),
    RPGField('data', NDArraySchema(3)),
    RPGField('events', DictSchema(
        'event', MatchKeyToField('id_'), EVENT_SCHEMA
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
    str_field('name'),
    RPGField('icon_name', MaterialRefSchema('Graphics', 'Icons')),
    str_field('description'),
    enum_field('scope', Scope),
    enum_field('occasion', Occasion),
    fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
    fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
    audio_field('menu_se', 'SE'),
    fk_field('common_event_id', lambda: COMMON_EVENTS_SCHEMA, True),
    *int_fields('''
        sp_cost power atk_f eva_f str_f dex_f agi_f int_f hit pdef_f mdef_f
        variance
    '''),
    RPGField('element_set', SetSchema(
        'skill_element', ELEMENT_SCHEMA, 'element_id'
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
    fk_field('animation_id', lambda: ANIMATIONS_SCHEMA, True),
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
        'state_guard_element', ELEMENT_SCHEMA, 'element_id'
    )),
    RPGField('plus_state_set', SetSchema(
        'state_plus_state', FKSchema(lambda: STATES_SCHEMA), 'plus_state_id'
    )),
    RPGField('minus_state_set', SetSchema(
        'state_minus_state', FKSchema(lambda: STATES_SCHEMA), 'minus_state_id'
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

ELEMENTS_SCHEMA: ListSchema = ListSchema(
    'element', StrSchema(), FirstItem.BLANK, item_name='name',
    index=AddIndexColumn('id')
)

SWITCHES_SCHEMA: ListSchema = ListSchema(
    'switch', StrSchema(), FirstItem.NULL, item_name='name',
    index=AddIndexColumn('id')
)

VARIABLES_SCHEMA: ListSchema = ListSchema(
    'variable', StrSchema(), FirstItem.NULL, item_name='name',
    index=AddIndexColumn('id')
)

SYSTEM_SCHEMA = RPGSingletonObjSchema('System', 'system', 'RPG::System', [
    RPGField('magic_number', IntSchema()),
    RPGField('party_members', ListSchema(
        'party_member', FKSchema(lambda: ACTORS_SCHEMA, nullable=False),
        item_name='actor_id'
    )),
    RPGField('elements', ELEMENTS_SCHEMA),
    RPGField('switches', SWITCHES_SCHEMA),
    RPGField('variables', VARIABLES_SCHEMA),
    RPGField('windowskin_name', MaterialRefSchema('Graphics', 'Windowskins')),
    RPGField('title_name', MaterialRefSchema('Graphics', 'Titles')),
    RPGField('gameover_name', MaterialRefSchema('Graphics', 'Gameovers')),
    RPGField('battle_transition', MaterialRefSchema('Graphics', 'Transitions')),
    *audio_fields('title_bgm battle_bgm', 'BGM'),
    *audio_fields('battle_end_me gameover_me', 'ME'),
    *audio_fields('''
        cursor_se decision_se cancel_se buzzer_se equip_se shop_se save_se
        load_se battle_start_se escape_se actor_collapse_se enemy_collapse_se
    ''', 'SE'),
    RPGField('words', SYSTEM_WORDS_SCHEMA),
    RPGField('start_map_id', FKSchema(lambda: MAPS_SCHEMA)),
    RPGField('start_x', IntSchema()),
    RPGField('start_y', IntSchema()),
    RPGField('test_battlers', ListSchema(
        'test_battler', SYSTEM_TEST_BATTLER_SCHEMA
    )),
    RPGField('test_troop_id', FKSchema(lambda: TROOPS_SCHEMA)),
    RPGField('battleback_name', MaterialRefSchema('Graphics', 'Battlebacks')),
    RPGField('battler_name', MaterialRefSchema('Graphics', 'Battlers')),
    RPGField('battler_hue', HUE_SCHEMA),
    RPGField('edit_map_id', FKSchema(lambda: MAPS_SCHEMA)),
    RPGField('_', IntSchema()),
])

TILESET_SCHEMA = RPGObjSchema('Tileset', 'RPG::Tileset', [
    id_field(),
    str_field('name'),
    RPGField('tileset_name', MaterialRefSchema('Graphics', 'Tilesets')),
    RPGField('autotile_names', ListSchema(
        'tileset_autotile', MaterialRefSchema('Graphics', 'Autotiles'),
        item_name='autotile_name', length_schema=IntSchema(7, 7)
    )),
    RPGField('panorama_name', MaterialRefSchema('Graphics', 'Panoramas')),
    hue_field('panorama_hue'),
    RPGField('fog_name', MaterialRefSchema('Graphics', 'Fogs')),
hue_field('fog_hue'),
    *int_fields('fog_opacity fog_blend_type fog_zoom fog_sx fog_sy'),
    RPGField('battleback_name', MaterialRefSchema('Graphics', 'Battlebacks')),
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
        int_field('actor_hp'),
        RPGField('switch_id', SWITCH_SCHEMA),
    ]
)

TROOP_PAGE_SCHEMA = RPGObjSchema('TroopPage', 'RPG::Troop::Page', [
    RPGField('condition', TROOP_PAGE_CONDITION_SCHEMA),
    enum_field('span', TroopPageSpan),
    RPGField('list_', ListSchema(
        'troop_page_command', EVENT_COMMAND_SCHEMA
    ), rpg_name='list', _db_name='list'),
])

TROOP_SCHEMA = RPGObjSchema('Troop', 'RPG::Troop', [
    id_field(),
    str_field('name'),
    RPGField('members', ListSchema('troop_member', TROOP_MEMBER_SCHEMA)),
    RPGField('pages', ListSchema('troop_page', TROOP_PAGE_SCHEMA)),
])

WEAPON_SCHEMA = RPGObjSchema('Weapon', 'RPG::Weapon', [
    id_field(),
    str_field('name'),
    RPGField('icon_name', MaterialRefSchema('Graphics', 'Icons')),
    str_field('description'),
    fk_field('animation1_id', lambda: ANIMATIONS_SCHEMA, True),
    fk_field('animation2_id', lambda: ANIMATIONS_SCHEMA, True),
    *int_fields('price atk pdef mdef str_plus dex_plus agi_plus int_plus'),
    RPGField('element_set', SetSchema(
        'weapon_element', ELEMENT_SCHEMA, 'element_id'
    )),
    RPGField('plus_state_set', SetSchema(
        'weapon_plus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
    )),
    RPGField('minus_state_set', SetSchema(
        'weapon_minus_state', FKSchema(lambda: STATES_SCHEMA), 'state_id'
    )),
])

ACTORS_SCHEMA: ListSchema = ListSchema(
    'actor', ACTOR_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

ANIMATIONS_SCHEMA: ListSchema = ListSchema(
    'animation', ANIMATION_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)
ARMORS_SCHEMA: ListSchema = ListSchema(
    'armor', ARMOR_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

CLASSES_SCHEMA: ListSchema = ListSchema(
    'class', CLASS_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

COMMON_EVENTS_SCHEMA: ListSchema = ListSchema(
    'common_event', COMMON_EVENT_SCHEMA,
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

ENEMIES_SCHEMA: ListSchema = ListSchema(
    'enemy', ENEMY_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

ITEMS_SCHEMA: ListSchema = ListSchema(
    'item', ITEM_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

MAPS_SCHEMA: MultipleFilesSchema = MultipleFilesSchema(
    re.compile(r'Map(\d{3}).rxdata'),
    'map',
    [FileKey(IntSchema(), 'id_', 'id')],
    MAP_SCHEMA
)

MAP_INFOS_SCHEMA: DictSchema = DictSchema(
    'map_info', AddKeyColumn('id', IntSchema()), MAP_INFO_SCHEMA
)

SCRIPTS_SCHEMA: ListSchema = ListSchema('script', SCRIPT_SCHEMA)

SKILLS_SCHEMA: ListSchema = ListSchema(
    'skill', SKILL_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

STATES_SCHEMA: ListSchema = ListSchema(
    'state', STATE_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

TILESETS_SCHEMA: ListSchema = ListSchema(
    'tileset', TILESET_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_'),
)

TROOPS_SCHEMA: ListSchema = ListSchema(
    'troop', TROOP_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

WEAPONS_SCHEMA: ListSchema = ListSchema(
    'weapon', WEAPON_SCHEMA, 
    first_item=FirstItem.NULL, index=MatchIndexToField('id_')
)

FILES: list[FileSchema] = [
    SingleFileSchema('Troops.rxdata', TROOPS_SCHEMA),
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
    SingleFileSchema('Weapons.rxdata', WEAPONS_SCHEMA),
]