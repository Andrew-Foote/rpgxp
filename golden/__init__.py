import functools as ft
import importlib.resources
from pathlib import Path
import subprocess
from typing import Callable
from warnings import warn
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

def add_options(parser: Parser) -> None:
	parser.addoption('--update-golden', action='store_true')

def _diff_using_imagemagick(
	output_path: Path, new_output_path: Path, diff_path: Path
) -> None:
	
	subprocess.run([
		'compare', str(output_path), str(new_output_path), str(diff_path)
	])

_DIFFERS = {
	'.png': _diff_using_imagemagick
}

type _Decoratable = Callable[[Path], bytes]
type _Decorated = Callable[[bool], None]
type _Decorator = Callable[[_Decoratable], _Decorated]

def golden_test(output_suffix: str='', *, nullary: bool=False) -> _Decorator:
	def decorator(decoratable: _Decoratable) -> _Decorated:
		test_name = decoratable.__name__
		root = golden_path() / test_name

		def decorated(update_golden: bool) -> None:
			root.mkdir(parents=True, exist_ok=True)

			if nullary:
				(root / '_').mkdir(exist_ok=True)
			
			case_paths = list(root.iterdir())

			if not case_paths:
				raise BadTestError(f'no test cases for {test_name}')

			for case_path in case_paths:
				input_path = case_path / 'input'
				output = decoratable(input_path)
				output_path = case_path / f'output{output_suffix}'

				if output_path.exists() and not update_golden:
					with output_path.open('rb') as output_file:
						output_content = output_file.read()

					new_output_path = case_path / f'new-output{output_suffix}'
					diff_path = case_path / f'diff{output_suffix}'

					if output == output_content:
						new_output_path.unlink(missing_ok=True)
						diff_path.unlink(missing_ok=True)
					else:
						with new_output_path.open('wb') as output_file:
							output_file.write(output)

						try:
							differ = _DIFFERS[output_suffix]
						except KeyError:
							# have pytest do the diff
							assert output == output_content
						else:
							differ(output_path, new_output_path, diff_path)
							assert False, f'output changed, diff at {diff_path}'
				else:
					with output_path.open('wb') as output_file:
						output_file.write(output)

		return decorated

	return decorator
