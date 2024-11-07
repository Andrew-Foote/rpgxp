SELECT
	t.id,
	t.name,
	t.tileset_name file_name,
	tm.extension,
	(
		SELECT json_group_array(json_object(
			'index', a."index",
			'file_name', a.file_name,
			'extension', a.extension
		))
		FROM (
			SELECT a."index", a.autotile_name as file_name, am.extension
			FROM tileset_autotile a
			JOIN material_best_file am ON am.type = 'Graphics'
			AND am.subtype = 'Autotiles' AND am.name = a.autotile_name
			WHERE a.tileset_id = t.id
			ORDER BY a."index"
		) a
	) autotiles,
	json_object(
		'file_name', t.panorama_name,
		'extension', pm.extension,
		'hue', t.panorama_hue
	) panorama,
	json_object(
		'file_name', t.fog_name,
		'extension', fm.extension,
		'hue', t.fog_hue,
		'opacity', t.fog_opacity,
		'blend_type', t.fog_blend_type,
		'zoom', t.fog_zoom,
		'sx', t.fog_sx,
		'sy', t.fog_sy
	) fog,
	JSON_OBJECT(
		'file_name', t.battleback_name,
		'extension', bm.extension
	) battleback
FROM tileset t
LEFT JOIN material_best_file tm ON tm.type = 'Graphics' AND tm.subtype = 'Tilesets'
	AND tm.name = t.tileset_name
LEFT JOIN material_best_file pm on pm.type = 'Graphics'
AND pm.subtype = 'Panoramas' AND pm.name = t.panorama_name
LEFT JOIN material_best_file fm on fm.type = 'Graphics'
AND fm.subtype = 'Fogs' AND fm.name = t.fog_name
LEFT JOIN material_best_file bm on bm.type = 'Graphics'
AND bm.subtype = 'Battlebacks' AND bm.name = t.battleback_name
WHERE t.id = :id
