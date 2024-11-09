SELECT
    f.source, f.type, f.subtype, f.full_name as name, e.battler_hue as hue
FROM enemy e
JOIN material_best_file f ON f.type = 'Graphics' AND f.subtype = 'Battlers'
    AND f.name = e.battler_name
WHERE e.id = :id