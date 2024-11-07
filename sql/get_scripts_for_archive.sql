SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
	'name', s.name || '.rb',
	'content', s.content
)) scripts FROM script s