SELECT f.source, f.type, f.subtype, f.full_name as name
FROM material_best_file f WHERE f.type = 'Graphics' AND f.subtype = :subtype
AND f.full_name = :name