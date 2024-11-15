import functools as ft

from rpgxp.route.Route import (
    Route, ContentType, bool_param, int_param, str_param, json_param
)

@ft.cache
def routes() -> list[Route]:
	return [
		Route('index.html', 'index.j2'),

		# maps
		Route('maps.html', 'maps.j2', 'view_maps', {'maps': json_param()}),
		Route('map/{id}.html', 'map.j2', 'view_map', {
			'id': int_param(),
			'name': str_param(),
			'parent': json_param(optional=True),
			'children': json_param(),
			'tileset': json_param(),
			'has_tiles': bool_param(),
			'bgm': json_param(optional=True),
			'bgs': json_param(optional=True),
			'encounter_step': int_param(),
			'encounters': json_param(),
		}, 'map_ids'),
		Route('map/{id}.png', 'map_image.j2', 'view_map_image', {
			'id': int_param(),
		}, 'map_ids_with_images', content_type=ContentType.PNG),

		# tilesets
		Route('tilesets.html', 'tilesets.j2', 'view_tilesets', {
			'tilesets': json_param()
		}),
		Route('tileset/{id}.html', 'tileset.j2', 'view_tileset', {
			'id': int_param(),
			'name': str_param(),
			'filename': str_param(optional=True),
			'file_stem': str_param(optional=True),
			'autotiles': json_param(),
			'panorama': json_param(optional=True),
			'fog': json_param(optional=True),
			'battleback': json_param(optional=True),
			'maps': json_param(),
		}, 'tileset_ids'),
		Route(
			'tileset/{id}/panorama.png', 'material_with_hue.j2',
			'view_panorama',
			{
				'source': str_param(),
				'type': str_param(),
				'subtype': str_param(),
				'name': str_param(),
				'hue': int_param()
			},
			'tileset_ids_with_panoramas', content_type=ContentType.PNG
		),
		Route(
			'tileset/{id}/fog.png', 'material_with_hue.j2',
			'view_fog',
			{
				'source': str_param(),
				'type': str_param(),
				'subtype': str_param(),
				'name': str_param(),
				'hue': int_param()
			},
			'tileset_ids_with_fogs', content_type=ContentType.PNG
		),

		# common events
		Route('common_events.html', 'common_events.j2', 'view_common_events', {
			'common_events': json_param(),
		}),
		Route('common_event/{id}.html', 'common_event.j2', 'view_common_event', {
			'id': int_param(),
			'name': str_param(),
			'trigger': json_param(optional=True),
		}, 'common_event_ids'),

		# switches
		Route('switches.html', 'switches.j2', 'view_switches', {
			'switches': json_param(),
		}),
		Route('switch/{id}.html', 'switch.j2', 'view_switch', {
			'switch': json_param(),
		}, 'switch_ids'),

		# scripts
		Route('scripts.html', 'scripts.j2', 'view_scripts', {
			'scripts': json_param(),
		}),
		Route('script/{name}.html', 'script.j2', 'view_script', {
			'id': int_param(),
			'name': str_param(),
			'content': str_param(),
		}, 'script_names'),
		Route('script/raw/{name}.rb', 'raw_script.j2', 'view_raw_script', {
			'content': str_param(),
		}, 'script_names', content_type=ContentType.RUBY),
		Route('scripts.zip', 'scripts_zip.j2', 'get_scripts_for_archive', {
			'scripts': json_param()
		}, content_type=ContentType.ZIP),

		# graphics
		Route('graphics/{subtype}/{name}', 'material.j2', 'view_graphic', {
			'source': str_param(),
			'type': str_param(),
			'subtype': str_param(),
			'name': str_param()
		},
		'graphics', content_type=ContentType.VARIABLE_BINARY),

		# troops
		Route('troops.html', 'troops.j2', 'view_troops', {
			'troops': json_param(),
		}),
		Route('troop/{id}.html', 'troop.j2', 'view_troop', {
			'id': int_param(),
			'name': str_param(),
			'members': json_param(),
			'maps': json_param(),
		}, 'troop_ids'),

		# enemies
		Route('enemies.html', 'enemies.j2', 'view_enemies', {
			'enemies': json_param(),
		}),
		Route('enemy/{id}.html', 'enemy.j2', 'view_enemy', {
			'id': int_param(),
			'name': str_param(),
			'battler': json_param(optional=True),
			'stats': json_param(),
			'battle_animation': json_param(optional=True),
			'target_animation': json_param(optional=True),
			'element_effects': json_param(),
			'state_effects': json_param(), 
			'exp': int_param(),
			'gold': int_param(),
			'treasure_prob': int_param(),
			'treasure': json_param(optional=True),
			'troops': json_param(),
			'actions': json_param(),
		}, 'enemy_ids'),
		Route('enemy/{id}.png', 'material_with_hue.j2', 'view_enemy_image', {
			'source': str_param(), 
			'type': str_param(), 
			'subtype': str_param(),
			'name': str_param(),
			'hue': int_param(),
		}, 'enemy_ids_with_images', content_type=ContentType.PNG),
	]
