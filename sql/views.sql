DROP VIEW IF EXISTS tileset_v;
CREATE VIEW tileset_v (
	id, name,
	filename, file_source, file_ext,
	panorama_name, panorama_source, panorama_ext, panorama_hue,
	fog_name, fog_source, fog_ext, fog_hue,
	fog_opacity, fog_blend_type, fog_zoom, fog_sx, fog_sy,
	battleback_name, battleback_source, battleback_ext
) AS SELECT
	t.id, t.name,
	t.tileset_name, tmat.source, tmat.extension,
	t.panorama_name, pmat.source, pmat.extension, t.panorama_hue,
	t.fog_name, fmat.source, fmat.extension, t.fog_hue,
	t.fog_opacity, t.fog_blend_type, t.fog_zoom, t.fog_sx, t.fog_sy,
	t.battleback_name, bmat.source, bmat.extension
FROM tileset t
LEFT JOIN material_best_file tmat ON tmat.type = 'Graphics'
	AND tmat.subtype = 'Tilesets' AND tmat.name = t.tileset_name
LEFT JOIN material_best_file pmat ON pmat.type = 'Graphics'
	AND pmat.subtype = 'Panoramas' AND pmat.name = t.panorama_name
LEFT JOIN material_best_file fmat ON fmat.type = 'Graphics'
	AND fmat.subtype = 'Fogs' AND fmat.name = t.fog_name
LEFT JOIN material_best_file bmat ON bmat.type = 'Graphics'
	AND bmat.subtype = 'Battlebacks' AND bmat.name = t.battleback_name
WHERE t.name != '';