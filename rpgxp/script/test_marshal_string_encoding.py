from rpgxp import parse, schema, settings

tilesets_schema = schema.FILES[-3]
tilesets = parse.parse_file(tilesets_schema, settings.game_data_root)