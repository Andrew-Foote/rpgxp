SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
	'id', id, 
	'name', name
)) AS tilesets
FROM tileset_v ORDER BY id