from dataclasses import dataclass
from pathlib import Path
import re
from typing import Iterable, Protocol, Self

def expect1[T](iterable: Iterable[T]) -> T:
	iterator = iter(iterable)
	result = next(iterator)

	try:
		extra = next(iterator)
	except StopIteration:
		return result
	else:
		raise ValueError(f'expected only one value, but got another: {extra}')

class Comparable(Protocol):
    def __lt__(self, other: Self) -> bool:
    	...

@dataclass
class Just[T]:
    value: T 

type Maybe[T] = None | Just[T]

JsonDumpable = (
	None | bool | int | float | str | list['JsonDumpable']
	| dict[str, 'JsonDumpable']
)

def camel_case_to_snake(s: str) -> str:
	return re.sub(r'(?<=[^A-Z])(?=[A-Z])', '_', s).lower()

def int_from_digits(digits: list[int], base: int=10) -> int:
	result = 0

	for digit in digits:
		result = result * base + digit

	return result