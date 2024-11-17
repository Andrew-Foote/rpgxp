from pathlib import Path
from golden import golden_test, update_golden
from rpgxp.generate_classes import generate_module

@golden_test('.py', nullary=True)
def test_generate_classes(input_root: Path) -> bytes:
	return generate_module().encode('utf-8')