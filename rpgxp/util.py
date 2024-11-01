import importlib.resources
from pathlib import Path
import re

def camel_case_to_snake(s: str) -> str:
	return re.sub(r'(?<=[^A-Z])(?=[A-Z])', '_', s).lower()

def project_root() -> Path:
	with importlib.resources.path('rpgxp') as pkg_base_path:
		return pkg_base_path.parent
