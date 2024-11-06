select
	m.id,
	mi.name,
	m.autoplay_bgm,
	m.bgm_name
from map m
join map_info mi on mi.id = m.id
left join material mat on
	mat.type = 'Audio' and mat.subtype = 'BGM'
	and mat.name = m.bgm_name
where m.autoplay_bgm and m.bgm_name != ''
and mat.name is null;