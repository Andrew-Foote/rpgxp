SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
	'name', name || '.rb',
	'content', content
)) scripts FROM script