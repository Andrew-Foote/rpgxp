select json_object(
	'id', s.id,
	'name', s.name,
	'common_events', (
		select json_group_array(json_object(
			'id', e.id,
			'name', e.name
		)) from common_event e where e.switch_id = s.id
	)
) as switch
from switch s
where s.id = :id