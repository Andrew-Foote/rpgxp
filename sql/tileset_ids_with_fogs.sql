SELECT t.id FROM tileset t
JOIN material_best_file f ON f.type = 'Graphics' AND f.subtype = 'Fogs'
AND f.name = t.fog_name