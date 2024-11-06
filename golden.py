import functools as ft
import importlib.resources
from pathlib import Path
from typing import Callable
import pytest
from _pytest.fixtures import FixtureRequest, Parser

class BadTestError(Exception):
	pass

@ft.cache
def golden_path() -> Path:
	with importlib.resources.path('golden') as base_path:
		return base_path.parent / 'golden-data'

@pytest.fixture
def update_golden(request: FixtureRequest) -> bool:
	return request.config.getoption('--update-golden')

def add_options(parser: Parser):
	parser.addoption('--update-golden', action='store_true')

def golden_test[T](f: Callablle[[], T]) -> Callable[[bool], None]:
	root = golden_path() / f.__name__

	def decorated(update_golden: bool) -> None:
		input_root = root / 'input'
		output_root = root / 'output'
		input_root.mkdir(parents=True, exist_ok=True)
		output_root.mkdir(parents=True, exist_ok=True)

		inputs_tested = set()

		input_paths = list(input_root.iterdir())

		if not input_paths:
			raise BadTestError(f'no inputs for {f.__name__}')

		for input_path in input_paths:
			with input_path.open('rb') as input_file:
				input_content = input_file.read()

			output = f(input_content)			
			output_path = output_root / input_path.name

			if output_path.exists() and not update_golden:
				with output_path.open('rb') as output_file:
					output_content = output_file.read()

				assert output == output_content
			else:
				with output_path.open('wb') as output_file:
					output_path.write(output)

			inputs_tested.add(input_path.name)

		for output_path in output_root.iterdir():
			if output_path.name not in inputs_tested:
				output_path.unlink()

	return decorated
