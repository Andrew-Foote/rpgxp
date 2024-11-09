SELECT f.source, f.type, f.subtype, f.full_name as name
FROM material_best_file f WHERE f.type = 'Graphics'
AND f.subtype = upper(substr(:subtype, 1, 1)) || substr(:subtype, 2)
AND f.full_name = :name