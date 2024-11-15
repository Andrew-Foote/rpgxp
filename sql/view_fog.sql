SELECT
    fog_source source,
    'Graphics' type,
    'Fogs' subtype,
    fog_filename name,
    fog_hue hue
FROM tileset_v WHERE id = :id