from dataclasses import dataclass, field
from typing import Iterator, Self
from rpgxp import schema

def obj_subschemas(s: schema.DataSchema | schema.FileSchema) -> Iterator[schema.ObjSchema]:
	match s:
		case (
			schema.BoolSchema() | schema.IntSchema() | schema.FloatSchema()
			| schema.StrSchema() | schema.ZlibSchema() | schema.NDArraySchema()
			| schema.EnumSchema() | schema.FKSchema()
		):
			pass
		case schema.ObjSchema():
			yield s

			for field in s.fields:
				yield from obj_subschemas(field.schema)
		case schema.ListSchema(_, item_schema) | schema.SetSchema(_, item_schema):
			yield from obj_subschemas(item_schema)
		case schema.DictSchema():
			yield from obj_subschemas(s.key_schema)
			yield from obj_subschemas(s.value_schema)
		case schema.SingleFileSchema(_, content_schema):
			yield from obj_subschemas(content_schema)
		case schema.MultipleFilesSchema(_, _, _, content_schema):
			yield from obj_subschemas(content_schema)
		case _:
			assert False, type(s)

def schema_to_type(s: schema.DataSchema) -> str:
	match s:
		case schema.BoolSchema():
			return 'bool'
		case schema.IntSchema():
			return 'int'
		case schema.FloatSchema():
			return 'float'
		case schema.StrSchema() | schema.ZlibSchema():
			return 'str'
		case schema.NDArraySchema():
			return 'np.ndarray'
		case schema.EnumSchema(enum_class):
			return enum_class.__name__
		case schema.FKSchema(foreign_schema_thunk, nullable):
			result = schema_to_type(foreign_schema_thunk().pk_schema())

			if nullable:
				result = f'Optional[{result}]'

			return result
		case schema.ObjSchema():
			return s.class_name
		case schema.ListSchema(_, item_schema):
			return f'list[{schema_to_type(item_schema)}]'
		case schema.SetSchema(_, item_schema):
			return f'set[{schema_to_type(item_schema)}]'
		case schema.DictSchema():
			key_type = schema_to_type(s.key_schema)
			value_type = schema_to_type(s.value_schema)
			return f'dict[{key_type}, {value_type}]'
		case schema.SingleFileSchema(_, content_schema):
			return schema_to_type(content_schema)
		case schema.MultipleFilesSchema(_, _, keys, content_schema):
			key_type_args = ', '.join('str' for _ in keys)
			key_type = f'tuple[{key_type_args}]'
			value_type = schema_to_type(content_schema)
			return f'dict[{key_type}, {value_type}]'
		case _:
			assert False

@dataclass
class AttrDecl:
	name: str
	type_: str

	def __str__(self) -> str:
		return f'{self.name}: {self.type_}'

@dataclass
class ClassDecl:
	name: str
	members: list[AttrDecl] = field(default_factory=lambda: [])

	def __str__(self) -> str:
		return '\n'.join([
			'@dataclass',
			f'class {self.name}:',
			*(f'    {decl}' for decl in self.members),
		])

	@classmethod
	def from_schema(cls, obj_schema: schema.ObjSchema) -> Self:
		members = []

		for field in obj_schema.fields:
			type_ = schema_to_type(field.schema)
			members.append(AttrDecl(field.name, type_))

		return cls(obj_schema.class_name, members)

@dataclass
class Module:
	members: list[ClassDecl] = field(default_factory=lambda: [])

	def __str__(self) -> str:
		return '\n\n'.join(map(str, self.members))

def generate_module() -> str:
	result = Module()
	classes_declared = set()

	for file_schema in schema.FILES:
		for obj_schema in obj_subschemas(file_schema):
			class_name = obj_schema.class_name

			if class_name in classes_declared:
				continue

			classes_declared.add(class_name)
			result.members.append(ClassDecl.from_schema(obj_schema))

	return '\n'.join([
		'from dataclasses import dataclass',
		'from typing import Optional',
		'import numpy as np',
		'from rpgxp.common import *',
		'',
		str(result),
	])

def run() -> None:
	import importlib.resources
	import subprocess

	module = generate_module()

	with importlib.resources.path('rpgxp') as base_path:
		path = base_path / 'generated/schema.py'

		with open(path, 'w') as f:
			f.write(module)

		subprocess.run(['mypy', str(path)])

if __name__ == '__main__':
	run()
