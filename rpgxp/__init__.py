from dataclasses import dataclass
import functools as ft
import importlib.resources
from pathlib import Path
from typing import TypedDict, Self

class ConfigError(Exception):
	pass

@ft.cache
def _package_root() -> Path:
	with importlib.resources.path('rpgxp') as result:
		return result

@ft.cache
def _project_root() -> Path:
	return _package_root().parent

@ft.cache
def _settings_path() -> Path:
	return _project_root() / 'settings.ini'

_SettingsDict = TypedDict('_SettingsDict', {
	'game_name': str,
	'game_root': Path,
	'rtp_root': Path,
	'db_root': Path,
	'site_root': Path,
})

@ft.cache
def _settings_dict() -> _SettingsDict:
	game_name: str
	game_root: Path
	db_root: Path
	site_root: Path

	with _settings_path().open() as settings_file:
		for line in settings_file:
			line = line.strip()
			line = line.split('#', maxsplit=1)[0]
			line = line.strip()
			parts = line.split('=', maxsplit=1)

			if not line:
				continue
			
			if len(parts) != 2:
				raise ConfigError(
					f"invalid config line {line}, expected an '=' somewhere in "
					"the line"
				)

			key, value = parts
			key = key.strip()
			value = value.strip()

			match key:
				case 'game_name':
					game_name = value
				case 'game_root':
					game_root = Path(value)
				case 'rtp_root':
					rtp_root = Path(value)
				case 'db_root':
					db_root = Path(value)
				case 'site_root':
					site_root = Path(value)
				case _:
					raise ConfigError(f"unrecognized config key '{key}'")

	return {
		'game_name': game_name,
		'game_root': game_root,
		'rtp_root': rtp_root,
		'db_root': db_root,
		'site_root': site_root,
	}

@dataclass
class _Settings:
	@property
	def package_root(self) -> Path:
		return _package_root()

	@property
	def project_root(self) -> Path:
		return _project_root()

	@property
	def settings_path(self) -> Path:
		return _settings_path()

	@property
	def game_name(self) -> str:
		return _settings_dict()['game_name']

	@property
	def game_root(self) -> Path:
		return _settings_dict()['game_root']

	@property
	def rtp_root(self) -> Path:
		return _settings_dict()['rtp_root']

	@property
	def db_root(self) -> Path:
		return _settings_dict()['db_root']

	@property
	def site_root(self) -> Path:
		return _settings_dict()['site_root']

	@property
	def game_data_root(self) -> Path:
		return self.game_root / 'Data'

	@property
	def game_graphics_root(self) -> Path:
		return self.game_root / 'Graphics'

settings = _Settings()