from abc import ABC
from dataclasses import dataclass, field
from typing import Iterable, Iterator, Self, Sequence
from rpgxp import settings
from rpgxp.schema import Schema, rpgxp_schema

def obj_subschemas(s: Schema.DataSchema | Schema.FileSchema) -> Iterator[Schema.ObjSchema]:
	match s:
		case (
			Schema.BoolSchema() | Schema.IntBoolSchema() | Schema.IntSchema()
			| Schema.FloatSchema() | Schema.StrSchema() | Schema.ZlibSchema()
			| Schema.NDArraySchema() | Schema.EnumSchema()
			| Schema.MaterialRefSchema() | Schema.FKSchema()
		):
			pass
		case Schema.RPGVariantObjSchema():
			yield s

			for vfield in s.fields:
				yield from obj_subschemas(vfield.schema)

			for variant in s.variants:
				yield from variant_subschemas(variant)
		case Schema.ObjSchema():
			yield s

			for field in s.fields:
				yield from obj_subschemas(field.schema)
		case Schema.ListSchema(_, item_schema) | Schema.SetSchema(_, item_schema):
			yield from obj_subschemas(item_schema)
		case Schema.DictSchema():
			yield from obj_subschemas(s.key_schema)
			yield from obj_subschemas(s.value_schema)
		case Schema.SingleFileSchema(_, content_schema):
			yield from obj_subschemas(content_schema)
		case Schema.MultipleFilesSchema(_, _, _, content_schema):
			yield from obj_subschemas(content_schema)
		case _:
			assert False, type(s)

def variant_subschemas(variant: Schema.Variant) -> Iterator[Schema.ObjSchema]:
	match variant:
		case Schema.SimpleVariant():
			for field in variant.fields:
				yield from obj_subschemas(field.schema)
		case Schema.ComplexVariant():
			for subvariant in variant.variants:
				yield from variant_subschemas(subvariant)

def schema_to_type(s: Schema.DataSchema) -> str:
	match s:
		case Schema.BoolSchema() | Schema.IntBoolSchema():
			return 'bool'
		case Schema.IntSchema():
			return 'int'
		case Schema.FloatSchema():
			return 'float'
		case (
			Schema.StrSchema() | Schema.ZlibSchema()
			| Schema.MaterialRefSchema()
		):
			return 'str'
		case Schema.NDArraySchema():
			return 'np.ndarray'
		case Schema.EnumSchema(enum_class):
			return enum_class.__name__
		case Schema.FKSchema(foreign_schema_thunk, nullable):
			result = schema_to_type(foreign_schema_thunk().pk_schema())

			if nullable:
				result = f'Optional[{result}]'

			return result
		case Schema.ObjSchema():
			return s.class_name
		case Schema.ListSchema(_, item_schema):
			return f'list[{schema_to_type(item_schema)}]'
		case Schema.SetSchema(_, item_schema):
			return f'set[{schema_to_type(item_schema)}]'
		case Schema.DictSchema():
			key_type = schema_to_type(s.key_schema)
			value_type = schema_to_type(s.value_schema)
			return f'dict[{key_type}, {value_type}]'
		case Schema.SingleFileSchema(_, content_schema):
			return schema_to_type(content_schema)
		case Schema.MultipleFilesSchema(_, _, keys, content_schema):
			key_type_args = ', '.join('str' for _ in keys)
			key_type = f'tuple[{key_type_args}]'
			value_type = schema_to_type(content_schema)
			return f'dict[{key_type}, {value_type}]'
		case _:
			assert False

@dataclass
class ClassMember(ABC):
	pass

@dataclass
class AttrDecl(ClassMember):
	name: str
	type_: str

	def __str__(self) -> str:
		return f'{self.name}: {self.type_}'

@dataclass
class VarAssignment(ClassMember):
	name: str
	value: str

	def __str__(self) -> str:
		return f'{self.name} = {self.value}'

@dataclass
class ClassDecl:
	name: str
	members: Sequence[ClassMember]=field(default_factory=lambda: [])
	bases: Sequence[str]=field(default_factory=lambda: [])

	def __str__(self) -> str:
		bases_csv = ', '.join(self.bases)
		bases_string = f'({bases_csv})' if self.bases else ''

		return '\n'.join([
			'@dataclass(frozen=True)',
			f'class {self.name}{bases_string}:',
			*(f'    {decl}' for decl in self.members),
		])

	@classmethod
	def from_schema(cls, obj_schema: Schema.ObjSchema) -> Iterator[ClassDecl]:
		if isinstance(obj_schema, Schema.RPGVariantObjSchema):
			fields = [
				Schema.Field(field.name, field.schema)
				for field in obj_schema.fields
			]

			yield from class_decls_from_variant_schema(
				obj_schema.class_name, fields,
				obj_schema.discriminant_name, obj_schema.variants
			)
		else:
			members = []

			for field in obj_schema.fields:
				type_ = schema_to_type(field.schema)
				members.append(AttrDecl(field.name, type_))

			yield ClassDecl(obj_schema.class_name, members)

def class_decls_from_variant_schema(
	class_name: str,
	fields: list[Schema.Field],
	discriminant_name: str,
	variants: Iterable[Schema.Variant],
	var_assignments: list[ClassMember] | None=None,
	parent_name: str | None=None
) -> Iterator[ClassDecl]:

	if var_assignments is None:
		var_assignments = []

	for field in fields:
		if field.name == discriminant_name:
			discriminant = field
			break
	else:
		raise ValueError(f"field '{discriminant_name}' doesn't exist")

	discriminant_type = schema_to_type(discriminant.schema)

	class_members = [*var_assignments]

	for field in fields:
		field_type = schema_to_type(field.schema)

		if field.name == discriminant_name:
			field_type = f'ClassVar[{field_type}]'

		class_members.append(AttrDecl(field.name, field_type))

	bases = ['ABC']

	if parent_name is not None:
		bases.insert(0, parent_name)

	yield ClassDecl(class_name, class_members, bases)

	for variant in variants:
		subclass_name = f'{class_name}_{variant.name}'

		new_var_assignments = [
			*var_assignments,
			VarAssignment(discriminant_name, variant.discriminant_value)
		]

		match variant:
			case Schema.SimpleVariant(_, _, fields):
				class_members = [*new_var_assignments]

				for field in fields:
					type_ = schema_to_type(field.schema)
					class_members.append(AttrDecl(field.name, type_))

				yield ClassDecl(subclass_name, class_members, [class_name])
			case Schema.ComplexVariant(
				_, _, subfields, subdiscriminant_name, subvariants
			):
				yield from class_decls_from_variant_schema(
					subclass_name, subfields, subdiscriminant_name,
					subvariants, new_var_assignments, class_name
				)
			case _:
				assert False

@dataclass
class Module:
	members: list[ClassDecl] = field(default_factory=lambda: [])

	def __str__(self) -> str:
		return '\n\n'.join(map(str, self.members))

def generate_module() -> str:
	result = Module()
	classes_declared = set()

	for file_schema in rpgxp_schema.FILES:
		for obj_schema in obj_subschemas(file_schema):
			class_name = obj_schema.class_name

			if class_name in classes_declared:
				continue

			classes_declared.add(class_name)
			result.members.extend(ClassDecl.from_schema(obj_schema))

	return '\n'.join([
		'from abc import ABC',
		'from dataclasses import dataclass',
		'from typing import ClassVar, Optional',
		'import numpy as np',
		'from rpgxp.common import *',
		'',
		str(result),
	])

def run() -> None:
	module = generate_module()
	module_path = settings.package_root / 'generated/schema.py'

	with module_path.open('w') as module_file:
		module_file.write(module)

if __name__ == '__main__':
	run()
