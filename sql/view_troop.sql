SELECT
    t.id,
    t.name,
    (
        SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
            'enemy_id', m.id,
            'enemy_name', m.name,
            'x', m.x,
            'y', m.y,
            'hidden', m.hidden,
            'immortal', m.immortal
        )) FROM (
            SELECT e.id, e.name, m.x, m.y, m.hidden, m.immortal
            FROM troop_member m
            JOIN enemy e ON e.id = m.enemy_id
            WHERE m.troop_id = t.id
            ORDER BY m."index"
        ) m
    ) members,
    (
        SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
            'id', m.id,
            'name', m.name
        )) FROM (
            SELECT m.id, m.name FROM encounter e
            JOIN map_info m ON m.id = e.map_id
            WHERE e.troop_id = t.id
            ORDER BY m."order", m.id
        ) m
    ) maps
FROM troop t WHERE t.id = :id