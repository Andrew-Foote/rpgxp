SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
    'id', t.id,
    'name', t.name,
    'members', (
        SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
            'enemy_id', m.id,
            'enemy_name', m.name
        )) FROM (
            SELECT e.id, e.name
            FROM troop_member m
            JOIN enemy e ON e.id = m.enemy_id
            WHERE m.troop_id = t.id
            ORDER BY m."index"
        ) m
    )
)) troops
FROM troop t