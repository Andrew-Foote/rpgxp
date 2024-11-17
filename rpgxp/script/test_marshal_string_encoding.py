from rpgxp import parse, settings
from rpgxp.schema import rpgxp_schema as schema

tilesets_schema = schema.FILES[-3]
tilesets = parse.parse_file(tilesets_schema, settings.game_data_root)