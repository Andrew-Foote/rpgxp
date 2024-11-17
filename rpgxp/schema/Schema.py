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

# @dataclass(frozen=True)
# class NDArrayListSchema(RefableSchema):
#     _table_name: str
#     dim_names: tuple[str] | tuple[str, str] | tuple[str, str, str]
#     item_name: str=''

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
class SingleFileSchema:
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
class MultipleFilesSchema(RefableSchema):
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

FileSchema = SingleFileSchema | MultipleFilesSchema

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

