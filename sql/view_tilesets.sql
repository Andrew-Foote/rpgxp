SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
	'id', id, 
	'name', name
)) AS tilesets
FROM tileset
ORDER BY id;