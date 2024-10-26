import dataclasses
from enum import Enum
import inspect
import itertools as it
from typing import Annotated, Any, cast, get_args, get_origin
import zlib
import numpy as np
import ruby_marshal_parser as marshal
from rpgxp.schema import RPG, RPGListItem, SchemaError, TupleLike, ZlibCompressed


class ParseError(Exception):
	pass


def parse_bool(node: marshal.Node, constraints: tuple=()) -> bool:
	content = node.body_content

	match content:
		case marshal.True_():
			result = True
		case marshal.False_():
			result = False
		case _:
			raise ParseError(
				'expected node of type True_ or False_, got '
				f'{type(content).__name__}'
			)

	match constraints:
		case []:
			return result
		case _:
			raise ParseError(
				f"invalid constraint {constraints} for type 'bool'"
			)


def parse_int(node: marshal.Node, constraints: tuple=()) -> int:
	if not isinstance(node.body_content, marshal.Fixnum):
		raise ParseError(f'expected a fixnum')

	result = node.body_content.value

	match constraints:
		case []:
			pass
		case [v] if isinstance(v, type) and issubclass(v, (RPG, RPGListItem)):
			pass
		case [v] if isinstance(v, range):
			if not result in v:
				raise ParseError(f'expected fixnum in range {v}, got {result}')
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'int'"
			)

	return result		


def parse_str(node: marshal.Node, constraints: tuple=()) -> str:
	if not isinstance(node.body_content, marshal.String):
		raise ParseError(f'expected a string')

	match constraints:
		case []:
			return node.decoded_text
		case [ZlibCompressed(encoding)]:
			return zlib.decompress(node.body_content.text).decode(encoding)
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'str'"
			)


def parse_list[T](
	item_type: type[T], node: marshal.Node, constraints: tuple=()
) -> list[T]:

	if not isinstance(node.body_content, marshal.Array):
		raise ParseError(f'expected an array')

	items = node.body_content.items
	result = [parse(item_type, item) for item in items]

	match constraints:
		case []:
			pass
		case [v] if isinstance(v, int):
			length = len(result)

			if length != v:
				raise ParseError(
					f'expected array of length {v}, got {length} items'
				)
		case [first, rest] if (
			isinstance(first, tuple)
			and all(isinstance(v, type) for v in first)
			and isinstance(rest, type)
		):
			min_length = len(first)
			length = len(result)

			if length < min_length:
				raise ParseError(
					f'expected array of length at least {min_length}, got '
					f'{length} items'
				)

			for i, item, expected_type in zip(it.count(), result, first):
				if not isinstance(item, expected_type):
					raise ParseError(
						f'expected {i}th item of array to be a '
						f'{expected_type.__name__}, got {type(item).__name__}'
					)

			i = len(first)

			for j, item in enumerate(result[i:], start=i):
				if not isinstance(item, rest):
					raise ParseError(
						f'expected {j}th item of array to be a '
						f'{rest.__name__}, got {type(item).__name__}'
					)
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'list'"
			)

	return result


def parse_array_from_table_data(
	data: bytes, expected_dimcount: int | None=None
) -> np.ndarray:

    # The data begins with a 32-bit signed integer giving the number of
	# dimensions in the array, which is either 1, 2, or 3.
    dimcount = int.from_bytes(data[:4], 'little', signed=True)
    assert 1 <= dimcount <= 3

    if expected_dimcount is not None and dimcount != expected_dimcount:
    	raise ParseError(
    		f'expected {expected_dimcount} dimensions, got {dimcount}'
    	)
 
    # Next come three more 32-bit signed integers giving the size of each
    # dimension, measured in words, i.e. pairs of bytes. If the number of
    # dimensions is less than 3, the remaining dimensions will be 1.
    dimensions = []

    for i in range(3):
        size = int.from_bytes(
        	data[4 * (i + 1):4 * (i + 2)],
        	'little',
        	signed=True
        )

        if i >= dimcount:
        	assert size == 1

        dimensions.append(size)

   	# If the table represents tiles on a map, these dimensions are width,
   	# height and depth, in that order. That is, the first 32-bit integer is
   	# the width, the second 32-bit integer is the height, the third 32-bit
   	# integer is the depth.
    width, height, depth = dimensions

    # Next comes a final 32-bit signed integer which is simply equal to the
	# product of the dimensions, giving us no new information.
    datalen = int.from_bytes(data[16:20], 'little', signed=True)
    assert datalen == width * height * depth

    # After this comes the actual content of the table. This consists of 16-bit
    # integers, occupying two bytes each, so its size in bytes will be twice
    # the product of the dimensions.
    tiledata = data[20:]
    assert len(tiledata) == datalen * 2

    # The content is laid out in "Fortran order", relative to the order of the
    # 32-bit integers giving the size of each dimension. So if we refer to the
    # dimensions as width, height and depth, then any elements which are on the
    # same row and column, but have different depths, are next to each other;
    # likewise any of the resulting "cells" which are on the same column are
    # next to each other.
    return np.ndarray(shape=dimensions, dtype='h', buffer=tiledata, order='F')

def parse_array(node: marshal.Node, constraints: tuple=()) -> np.ndarray:
	node_content = node.body_content

	if not (
		isinstance(node_content, marshal.UserData)
		and node_content.class_name == 'Table'
	):
		raise ParseError(f"expected a user data object of type 'Table'")

	match constraints:
		case []:
			expected_dimcount = None
		case [v] if isinstance(v, int):
			expected_dimcount = v
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'np.ndarray'"
			)

	result = parse_array_from_table_data(node_content.data, expected_dimcount)
	return result		


def parse_enum[T: Enum](
	enum_type: type[T], node: marshal.Node, constraints: tuple=()
) -> T:

	result = enum_type(parse_int(node))

	match constraints:
		case []:
			return result
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'Enum'"
			)


def as_ivar_name(attr_name: str) -> str:
	return '@' + attr_name.rstrip('_')

def parse_rpg_object[T: RPG](
	cls: type[T], node: marshal.Node, constraints: tuple=()
) -> T:

	if not isinstance(node.body_content, marshal.Object):
		raise ParseError(f'expected an object')

	rpg_class_name = f'RPG::{cls.__name__}'

	if node.body_content.class_name != rpg_class_name:
		raise ParseError(f'expected an {rpg_class_name} object')

	attrs = inspect.get_annotations(cls)
	expected_ivars = {as_ivar_name(attr_name) for attr_name in attrs.keys()}
	actual_ivars = set(node.inst_vars.keys())

	if expected_ivars != actual_ivars:
		raise ParseError(
			f'expected set of instance variables ({expected_ivars}) different '
			f'from actual ({actual_ivars})'
		)

	attr_values = {}

	for attr_name, attr_type in attrs.items():
		ivar_name = as_ivar_name(attr_name)
		ivar_value = node.inst_vars[ivar_name]
		attr_value = parse(attr_type, ivar_value)
		attr_values[attr_name] = attr_value 

	result = cls(**attr_values)

	match constraints:
		case []:
			return result
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'RPG'"
			)


def parse_tuple_like[T: TupleLike](
	cls: type[T], node: marshal.Node, constraints: tuple=()
) -> T:

	content = node.body_content

	if not isinstance(content, marshal.Array):
		raise ParseError(f'expected an array')

	attrs = dataclasses.fields(cls)

	if len(attrs) != len(content.items):
		raise ParseError(
			f'expected an array of length {len(attrs)}, got '
			f'{len(content.items)}'
		)

	attr_values = {}

	for attr, item in zip(attrs, content.items):
		attr_values[attr.name] = parse(attr.type, item)

	result = cls(**attr_values)

	match constraints:
		case []:
			return result
		case _:
			raise SchemaError(
				f"invalid constraint {constraints} for type 'TupleLike'"
			)


# mypy can't handle this function unfortunately
def parse[T](type_: type[T], node: marshal.Node) -> T: 
	if get_origin(type_) is Annotated: 
		constraints = type_.__metadata__ # type: ignore
		type_ = type_.__origin__ # type: ignore
	else:
		constraints = ()

	if type_ is bool:
		return parse_bool(node, constraints) # type: ignore
	elif type_ is int:
		return parse_int(node, constraints) # type: ignore
	elif type_ is str:
		return parse_str(node, constraints) # type: ignore
	elif get_origin(type_) in (list, set):
		item_type, = get_args(type_)
		return parse_list(item_type, node, constraints) # type: ignore
	elif type_ is np.ndarray:
		return parse_array(node, constraints) # type: ignore
	elif issubclass(type_, Enum):
		return parse_enum(type_, node, constraints) # type: ignore
	elif issubclass(type_, RPG):
		return parse_rpg_object(type_, node, constraints) # type: ignore
	elif issubclass(type_, TupleLike):
		return parse_tuple_like(type_, node, constraints) # type: ignore
	else:
		raise SchemaError(f'invalid type {type_}')