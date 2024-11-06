select
	m.id,
	mi.name,
	case when parent.id is not null then json_object(
		'id', parent.id,
		'name', parent.name
	) end parent,
	(
		select json_group_array(json_object(
			'id', child.id,
			'name', child.name
		))
		from (
			select child.id, child.name
			from map_info child
			where child.parent_id = mi.id
			order by child."order", child.id
		) child
	) children,
	json_object(
		'id', tileset.id,
		'name', tileset.name
	) as tileset,
	case when m.autoplay_bgm then (
		select json_object(
			'name', m.bgm_name,
			'extension', mat.extension,
			'volume', m.bgm_volume,
			'pitch', m.bgm_pitch
		) from material_best_file mat
		where mat.type = 'Audio' and mat.subtype = 'BGM' and mat.name = m.bgm_name
	) end bgm,
	case when m.autoplay_bgs then json_object(
		'name', m.bgs_name,
		'extension', (
			select mat.extension from material_best_file mat
			where mat.type = 'Audio' and mat.subtype = 'BGS'
			and mat.name = m.bgs_name
		),
		'volume', m.bgs_volume,
		'pitch', m.bgs_pitch
	) end bgs,
	m.encounter_step,
	(
		select json_group_array(json_object(
			'troop_id', troop.id,
			'troop_name', troop.name
		))
		from (
			select troop.id, troop.name from encounter
			join troop on troop.id = encounter.troop_id
			where encounter.map_id = m.id
			order by encounter."index"
		) troop
	) encounters
from map m
join map_info mi on mi.id = m.id
left join map_info parent on parent.id = mi.parent_id
join tileset on tileset.id = m.tileset_id
where m.id = :id
