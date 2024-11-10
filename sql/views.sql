DROP VIEW IF EXISTS tileset_v;
CREATE VIEW tileset_v (
	id, name,
	file_source, filename, file_stem, 
	panorama_source, panorama_filename, panorama_stem, panorama_hue,
	fog_source, fog_filename, fog_stem, fog_hue,
	fog_opacity, fog_blend_type, fog_zoom, fog_sx, fog_sy,
	battleback_name, battleback_source, battleback_ext
) AS SELECT
	t.id, t.name,
	tmat.source, tmat.full_name, t.tileset_name,
	pmat.source, pmat.full_name, t.panorama_name, t.panorama_hue,
	fmat.source, fmat.full_name, t.fog_name, t.fog_hue,
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
	AND bmat.subtype = 'Battlebacks' AND bmat.name = t.battleback_name;