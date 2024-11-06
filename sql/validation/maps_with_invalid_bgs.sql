select
	m.id,
	mi.name,
	m.autoplay_bgs,
	m.bgs_name
from map m
join map_info mi on mi.id = m.id
left join material mat on
	mat.type = 'Audio' and mat.subtype = 'BGS'
	and mat.name = m.bgs_name
where m.autoplay_bgs and m.bgs_name != ''
and mat.name is null;