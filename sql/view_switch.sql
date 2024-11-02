select
	s.id,
	s.name,
	(
		select json_group_array(json_object(
			'id', e.id,
			'name', e.name
		)) from common_event e where e.switch_id = s.id
	) as common_events
from switch s
where s.id = :id