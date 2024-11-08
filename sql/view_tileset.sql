SELECT
	t.id,
	t.name,
	t.filename,
	t.file_ext,
	(
		SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
			'index', a."index",
			'filename', a.autotile_name,
			'file_ext', a.extension
		))
		FROM (
			SELECT a."index", a.autotile_name, amat.extension
			FROM tileset_autotile a
			JOIN material_best_file amat ON amat.type = 'Graphics'
			AND amat.subtype = 'Autotiles' AND amat.name = a.autotile_name
			WHERE a.tileset_id = t.id
			ORDER BY a."index"
		) a
	) autotiles,
	JSON_OBJECT(
		'filename', t.panorama_name,
		'file_ext', t.panorama_ext,
		'hue', t.panorama_hue
	) panorama,
	JSON_OBJECT(
		'filename', t.fog_name,
		'file_ext', t.fog_ext,
		'hue', t.fog_hue,
		'opacity', t.fog_opacity,
		'blend_type', t.fog_blend_type,
		'zoom', t.fog_zoom,
		'sx', t.fog_sx,
		'sy', t.fog_sy
	) fog,
	JSON_OBJECT(
		'filename', t.battleback_name,
		'file_ext', t.battleback_ext
	) battleback,
	(
		SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
			'id', m.id,
			'name', m.name
		)) FROM (
			SELECT m.id, mi.name
			FROM map m JOIN map_info mi ON mi.id = m.id
			WHERE m.tileset_id = t.id
			ORDER BY mi."order", m.id
		) m
	) maps
FROM tileset_v t WHERE t.id = :id
