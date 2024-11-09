SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
    'id', e.id,
    'name', e.name,
    'battler', json_object(
        'filename', e.battler_filename,
        'hue', e.battler_hue
    )
)) enemies
FROM (
    SELECT e.name, e.id, m.full_name as battler_filename, e.battler_hue
    FROM enemy e JOIN material_best_file m
    ON m.type = 'Graphics' AND m.subtype = 'Battlers'
        AND m.name = e.battler_name
    ORDER BY e.id
) e