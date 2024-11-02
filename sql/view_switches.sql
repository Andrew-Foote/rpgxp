select json_group_array(json_object(
	'id', id,
	'name', name
)) as switches
from switch;