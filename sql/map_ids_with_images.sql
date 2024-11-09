SELECT m.id FROM map m JOIN tileset t ON t.id = m.tileset_id
WHERE t.tileset_name IS NOT NULL