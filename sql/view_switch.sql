select json_object(
	'id', s.id,
	'name', s.name,
	'common_events', (
		select json_group_array(json_object(
			'id', e.id,
			'name', e.name
		)) from common_event e
		join common_event_trigger t on t.id = e.trigger
		where t.name in ('AUTORUN', 'PARALLEL') and e.switch_id = s.id
	),
	'event_pages', (
		select json_group_array(json_object(
			'map', json_object(
				'id', m.id,
				'name', m.name
			),
			'event', json_object(
				'id', e.id,
				'name', e.name
			),
			'number', p."index" + 1
		)) from event_page p
		join event e on e.map_id = p.map_id and e.id = p.event_id
		join map_info m on m.id = e.map_id
		where (p.condition_switch1_valid and p.condition_switch1_id = s.id)
		or (p.condition_switch2_valid and p.condition_switch2_id = s.id)
	)
) as switch
from switch s
where s.id = :id