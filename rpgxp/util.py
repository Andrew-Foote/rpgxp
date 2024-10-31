import re

def camel_case_to_snake(s: str) -> str:
	return re.sub(r'(?<=[^A-Z])(?=[A-Z])', '_', s).lower()
