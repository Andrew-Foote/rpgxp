SELECT t.id FROM tileset t
JOIN material_best_file f ON f.type = 'Graphics' AND f.subtype = 'Panoramas'
AND f.name = t.panorama_name