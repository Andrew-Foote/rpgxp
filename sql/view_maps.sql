select tree(
	m.id,
	m.parent_id,
	json(json_object('id', m.id, 'name', m.name))
) maps
from map_info m
-- NB: Generally, I'd expect each map to have a unique "order" value, but for
-- Rejuvenation, somehow all the maps have "order" set to 0, which is why we
-- also order by "id" as well. The resulting ordering doesn't seem to match the
-- order in RGP Maker XP's editor; I don't know how the editor does it when the
-- "order" values are all the same.
order by m."order", m.id
