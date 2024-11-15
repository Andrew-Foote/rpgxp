SELECT
    panorama_source source,
    'Graphics' type,
    'Panoramas' subtype,
    panorama_filename name,
    panorama_hue hue
FROM tileset_v WHERE id = :id