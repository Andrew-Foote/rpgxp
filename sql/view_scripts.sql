SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
	'id', s.id,
	'name', s.name
)) scripts FROM (
	SELECT s.id, s.name FROM script s ORDER BY s."index"
) s