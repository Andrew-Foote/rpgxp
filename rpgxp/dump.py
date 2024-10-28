# the dumper should just create .sql scripts
# 

from enum import Enum
from pathlib import Path
import re
import struct
from typing import Any
import zlib
import numpy as np
import ruby_marshal_parser as marshal
from rpgxp import schema
from rpgxp.generated import schema as gschema

class ParseError(Exception):
	pass

def parse_bool(node: marshal.Node) -> bool:
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

	return result

def parse_int(int_schema: schema.IntSchema, node: marshal.Node) -> int:
	if not isinstance(node.body_content, marshal.Fixnum):
		raise ParseError(f'expected a fixnum')

	result = node.body_content.value

	if not int_schema.matches(result):
		raise ParseError(f"fixnum doesn't match schema")

	return result

def parse_str(node: marshal.Node) -> str:
	if not isinstance(node.body_content, marshal.String):
		raise ParseError(f'expected a string')

	return node.decoded_text

def parse_zlib(node: marshal.Node, encoding: str) -> str:
	if not isinstance(node.body_content, marshal.String):
		raise ParseError(f'expected a string')

	compressed = node.body_content.text
	decompressed = zlib.decompress(compressed)
	decoded = decompressed.decode(encoding)
	return decoded

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

def parse_ndarray(dimcount: int, node: marshal.Node) -> np.ndarray:
	node_content = node.body_content

	if not (
		isinstance(node_content, marshal.UserData)
		and node_content.class_name == 'Table'
	):
		raise ParseError(f"expected a user data object of type 'Table'")

	return parse_array_from_table_data(node_content.data, dimcount)

def parse_enum[T: Enum](enum_class: type[T], node: marshal.Node) -> T:
	return enum_class(parse_int(schema.IntSchema(), node))

def parse_array_obj[T](
	klass: type[T], fields: list[schema.Field], node: marshal.Node
) -> T:

	content = node.body_content

	if not isinstance(content, marshal.Array):
		raise ParseError(f'expected an array')

	if len(content.items) != len(fields):
		raise ParseError(
			f'expected an array of length {len(fields)}, got '
			f'{len(content.items)}'
		)

	attr_values = {}

	for attr, item in zip(fields, content.items):
		attr_values[attr.name] = parse(attr.schema, item)

	return klass(**attr_values)

def as_ivar_name(attr_name: str) -> str:
	return '@' + attr_name

def parse_rpg_obj[T](
	cls: type[T], rpg_class_name: str, fields: list[schema.RPGField],
	node: marshal.Node
) -> T:

	content = node.body_content

	if not isinstance(content, marshal.Object):
		raise ParseError(
			f"expected '{rpg_class_name}' object, got node of type "
			f"'{type(content).__name__}'"
		)

	class_name = node.body_content.class_name

	if class_name != rpg_class_name:
		raise ParseError(
			f"expected '{rpg_class_name}' object, got '{class_name}'"
		)

	expected_ivars = {as_ivar_name(field.rpg_name) for field in fields}
	actual_ivars = set(node.inst_vars.keys())

	if (
		expected_ivars != actual_ivars and

		# temp exemption for event command lists
		actual_ivars - expected_ivars != {'@list'}
	):
		raise ParseError(
			f'expected set of instance variables different from actual; '
			f'expected - actual = {expected_ivars - actual_ivars}; '
			f'actual - expected = {actual_ivars - expected_ivars}'
		)

	attr_values = {}

	for field in fields:
		attr_name = field.name
		ivar_name = as_ivar_name(field.rpg_name)
		ivar_value = node.inst_vars[ivar_name]
		attr_value = parse(field.schema, ivar_value)
		attr_values[attr_name] = attr_value 

	return cls(**attr_values)

def parse_color_from_data(data: bytes) -> Color:
	r, g, b, a = struct.unpack('<dddd', data)
	return gschema.Color(r, g, b, a)

def parse_color(node: marshal.Node) -> Color:
	node_content = node.body_content

	if not (
		isinstance(node_content, marshal.UserData)
		and node_content.class_name == 'Color'
	):
		raise ParseError(f"expected a user data object of type 'Color'")

	return parse_color_from_data(node_content.data)

def parse_list(
	item_schema: schema.DataSchema, node: marshal.Node, *,
	first_item_behavior: schema.FirstItem,
	length_schema: schema.IntSchema,
	index_behavior: schema.IndexBehavior
) -> list:

	if not isinstance(node.body_content, marshal.Array):
		raise ParseError(f'expected an array')

	items = iter(node.body_content.items)

	match first_item_behavior:
		case schema.FirstItem.REGULAR:
			start = 0
		case schema.FirstItem.NULL:
			first_item = next(items)
			start = 1

			if not isinstance(first_item.body_content, marshal.Nil):
				raise ParseError(f'expected nil as first item of array')
		case schema.FirstItem.BLANK:
			first_item = next(items)
			start = 1

			if (
				not isinstance(first_item.body_content, marshal.String)
				or first_item.body_content.text
			):
				raise ParseError(f'expected empty string as first item of array')
		case _:
			assert False

	result = []

	if isinstance(index_behavior, schema.MatchIndexToField):
		assert isinstance(item_schema, schema.ObjSchema)
		match_to = index_behavior.match_to
	else:
		match_to = ''

	for i, item in enumerate(items, start=start):
		parsed_item = parse(item_schema, item)

		if match_to:
			match_field_value = getattr(parsed_item, match_to)

			if i != match_field_value:
				raise ParseError(
					f"expected '{match_to}' value to be the same as the array "
					f"index which is {i}, but instead it's {match_field_value}"
				)

		result.append(parsed_item)

	if not length_schema.matches(len(result)):
		raise ParseError(
			f"array length {len(result)} doesn't match schema {length_schema}"
		)

	return result

def parse_set(item_schema: schema.DataSchema, node: marshal.Node) -> set:
	if not isinstance(node.body_content, marshal.Array):
		raise ParseError(f'expected an array')

	return {parse(item_schema, item) for item in node.body_content.items}

def parse_dict(dict_schema: schema.DictSchema, node: marshal.Node) -> dict:
	if not isinstance(node.body_content, (marshal.Hash, marshal.DefaultHash)):
		raise ParseError(f'expected a hash')

	result = {}

	key_behavior = dict_schema.key

	if isinstance(key_behavior, schema.MatchKeyToField):
		assert isinstance(dict_schema.value_schema, schema.ObjSchema)
		match_to = key_behavior.match_to
	else:
		match_to = ''

	for key_node, value_node in node.body_content.items:
		parsed_key = parse(dict_schema.key_schema, key_node)
		parsed_value = parse(dict_schema.value_schema, value_node)

		if match_to:
			match_field_value = getattr(parsed_value, match_to)

			if parsed_key != match_field_value:
				raise ParseError(
					f"expected '{match_to}' value to be the same as the hash "
					f"key which is {parsed_key}, but instead it's "
					f"{match_field_value}"
				)

		result[parsed_key] = parsed_value

	return result

def parse(data_schema: schema.DataSchema, node: marshal.Node) -> Any:
	match data_schema:
		case schema.BoolSchema():
			return parse_bool(node)
		case schema.IntSchema(lb, ub):
			return parse_int(data_schema, node)
		case schema.StrSchema():
			return parse_str(node)
		case schema.ZlibSchema(encoding):
			return parse_zlib(node, encoding)
		case schema.NDArraySchema(dimcount):
			return parse_ndarray(dimcount, node)
		case schema.EnumSchema(enum_class):
			return parse_enum(enum_class, node)
		case schema.FKSchema(foreign_schema_thunk, nullable):
			foreign_schema = foreign_schema_thunk()
			foreign_pk_schema: schema.DataSchema

			match foreign_schema:
				case schema.ListSchema():
					foreign_pk_schema = schema.IntSchema(lb=0)
				case schema.DictSchema():
					foreign_pk_schema = foreign_schema.key_schema
				case schema.MultipleFilesSchema():
					assert len(foreign_schema.keys) == 1
					foreign_pk_schema = schema.IntSchema()
				case _:
					raise ParseError(
						f"unexpected schema type "
						f"'{type(foreign_schema).__name__}' for foreign schema"
					)

			return parse(foreign_pk_schema, node)
		case schema.ArrayObjSchema(class_name, fields):
			klass = getattr(gschema, class_name)
			return parse_array_obj(klass, fields, node)
		case schema.RPGObjSchema(class_name, rpg_class_name, fields):
			klass = getattr(gschema, class_name)
			return parse_rpg_obj(klass, rpg_class_name, fields, node)
		case schema.RPGSingletonObjSchema(class_name, _, rpg_class_name, fields):
			klass = getattr(gschema, class_name)
			return parse_rpg_obj(klass, rpg_class_name, fields, node)
		case schema.ColorSchema():
			return parse_color(node)
		case schema.ListSchema(
			_, item_schema,
			first_item=first_item,
			length_schema=length_schema,
			index=index_behavior
		):
			return parse_list(
				item_schema, node,
				first_item_behavior=first_item,
				length_schema=length_schema,
				index_behavior=index_behavior
			)
		case schema.SetSchema(_, item_schema):
			return parse_set(item_schema, node)
		case schema.DictSchema(_, key_behavior, value_schema, _):
			return parse_dict(data_schema, node)
		case _:
			assert False

def parse_file(file_schema: schema.FileSchema, data_root: Path) -> Any:
	match file_schema:
		case schema.SingleFileSchema(filename, content_schema):
			print(f'parsing {filename}')
			path = data_root / file_schema.filename
			data = marshal.parse_file(path)
			assert data.content is not None
			return parse(content_schema, data.content)
		case schema.MultipleFilesSchema(pattern, _, _, content_schema):
			result: dict[tuple[str, ...], Any] = {}

			for path in sorted(data_root.iterdir(), key=lambda p: p.name):
				m = re.match(pattern, path.name)

				if m is None:
					continue

				print(f'parsing {path.name}')

				keys = m.groups()
				data = marshal.parse_file(path)
				assert data.content is not None
				result[keys] = parse(content_schema, data.content)

			return result
		case _:
			assert False

def parse_filename(target_filename: str, data_root: Path) -> Any:
	for file_schema in schema.FILES:
		match file_schema:
			case schema.SingleFileSchema(filename, content_schema):
				if filename != target_filename:
					continue

				path = data_root / file_schema.filename
				data = marshal.parse_file(path)
				assert data.content is not None
				return parse(content_schema, data.content)
			case schema.MultipleFilesSchema(pattern, _, _, content_schema):
				m = re.match(pattern, filename):

				if m is None:
					continue

				keys = m.groups()

				data = marshal.parse_file(path)
				assert data.content is not None
				return parse(content_schema, data.content)
			case _:
				assert False

def dump_table(table_schema: schema.TableSchema, node: marshal.Node) -> Any:
	match table_schema:
		case schema.ListSchema(
			table_name, item_schema,
			first_item=first_item,
			item_name=item_name,
			index=index
		):


def dump_file(file_schema: schema.FileSchema, data_root: Path) -> Any:
	match file_schema:
		case schema.SingleFileSchema(filename, content_schema):
			print(f'dumping {filename}')
			parsed_content = parse.parse_filename(filename, data_root)
			dump_table(content_schema, parsed_content)
		case schema.MultipleFilesSchema(pattern, _, _, content_schema):
			result: dict[tuple[str, ...], Any] = {}

			for path in sorted(data_root.iterdir(), key=lambda p: p.name):
				m = re.match(pattern, path.name)

				if m is None:
					continue

				print(f'dumping {path.name}')
				keys = m.groups()
				parsed_content = parse.parse_filename(path.name, data_root)
				dump_rows(content_schema, keys + parsed_content)
		case _:
			assert False

if __name__ == '__main__':
	import argparse

	arg_parser = argparse.ArgumentParser(
	    prog='RPG Maker XP Data Parser',
	    description='Dumps RPG Maker XP data files to an SQLite database'
	)

	arg_parser.add_argument('data_root', type=Path)
	parsed_args = arg_parser.parse_args()
	data_root = parsed_args.data_root

	for file_schema in schema.FILES:
		dump_file(file_schema, data_root)