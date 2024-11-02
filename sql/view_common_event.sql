select
	e.id,
	e.name,
	case when t.name = 'NONE' then null else json_object(
		'type', t.name,
		'switch', json_object(
			'id', s.id,
			'name', s.name
		)
	) end trigger
from common_event e
join common_event_trigger t on t.id = e.trigger
left join switch s on t.name in ('AUTORUN', 'PARALLEL') and s.id = e.switch_id
where e.id = :id