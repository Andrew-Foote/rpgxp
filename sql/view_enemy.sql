SELECT 
    'id', e.id,
    'name', e.name,
    JSON_OBJECT(
        'file_stem', m.name,        
        'filename', m.full_name
    ) battler,
    JSON_OBJECT(
        'maxhp', e.maxhp, 'maxsp', e.maxsp, 'str', e.str, 'dex', e.dex,
        'agi', e.agi, 'int', e.int, 'atk', e.atk,
        'pdef', e.pdef, 'mdef', e.mdef, 'eva', e.eva
    ) stats,
    JSON_OBJECT(
        'id', a1.id, 'name', a1.name
    ) battle_animation,
    JSON_OBJECT(
        'id', a2.id, 'name', a2.name
    ) target_animation,
    JSON_OBJECT() element_effects,
    JSON_OBJECT() state_effects,
    e.exp,
    e.gold,
    e.treasure_prob,
    CASE
        WHEN e.item_id IS NOT NULL THEN (SELECT JSON_OBJECT(
            'type', 'item', 'id', i.id, 'name', i.name
        ) FROM item i WHERE i.id = e.item_id)
        WHEN e.weapon_id IS NOT NULL THEN (SELECT JSON_OBJECT(
            'type', 'weapon', 'id', w.id, 'name', w.name
        ) FROM weapon w WHERE w.id = e.weapon_id)
        WHEN e.armor_id IS NOT NULL THEN (SELECT JSON_OBJECT(
            'type', 'armor', 'id', a.id, 'name', a.name
        ) FROM armor a WHERE a.id = e.armor_id)
    END treasure,
    (
        SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
            'id', t.id, 'name', t.name
        )) FROM (
            SELECT t.id, t.name FROM troop_member m
            JOIN troop t ON t.id = m.troop_id
            WHERE m.enemy_id = e.id
            GROUP BY t.id ORDER BY t.id
        ) t
    ) troops,
    (
        SELECT JSON_GROUP_ARRAY(JSON_OBJECT(
            'kind', a.kind,
            'skill_name', a.skill_name, 'skill_id', a.skill_id,
            'conditions', (
                SELECT JSON_GROUP_ARRAY(JSON(condition))
                FROM (
                    SELECT 1 AS "order", JSON_OBJECT(
                        'type', 'turn',
                        'a', a.condition_turn_a, 'b', a.condition_turn_b
                    ) AS condition WHERE a.condition_turn_a != 0 OR a.condition_turn_b != 1
                    UNION ALL SELECT 2 AS "order", JSON_OBJECT(
                        'type', 'hp', 'hp', a.condition_hp
                    ) AS condition WHERE a.condition_hp < 100
                    UNION ALL SELECT 3 AS "order", JSON_OBJECT(
                        'type', 'level', 'level', a.condition_level
                    ) AS condition WHERE a.condition_level > 1
                    UNION ALL SELECT 4 AS "order", JSON_OBJECT(
                        'type', 'switch',
                        'id', a.condition_switch_id,
                        'name', a.condition_switch_name
                    ) AS condition WHERE a.condition_switch_id IS NOT NULL
                    ORDER BY "order"
                ) c
            ),
            'rating', a.rating
        )) FROM (
            SELECT
                k.name as kind,
                CASE
                    WHEN k.name = 'BASIC' THEN b.name
                    WHEN k.name = 'SKILL' THEN skill.name
                END skill_name, a.skill_id,
                a.condition_turn_a, a.condition_turn_b, a.condition_hp,
                a.condition_level, a.condition_switch_id,
                switch.name condition_switch_name, a.rating
            FROM enemy_action a
            JOIN enemy_action_kind k ON k.id = a.kind
            LEFT JOIN enemy_basic_action b ON b.id = a.basic
            LEFT JOIN skill ON skill.id = a.skill_id
            LEFT JOIN switch ON switch.id = a.condition_switch_id
            WHERE a.enemy_id = e.id
            ORDER BY a."index"
        ) a
    ) actions
FROM enemy e
LEFT JOIN material_best_file m ON m.type = 'Graphics' AND m.subtype = 'Battlers'
    AND m.name = e.battler_name
LEFT JOIN animation a1 ON a1.id = e.animation1_id
LEFT JOIN animation a2 ON a2.id = e.animation2_id
WHERE e.id = :id