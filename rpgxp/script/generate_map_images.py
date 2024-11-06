from rpgxp import db, settings, tile

def run() -> None:
    dbh = db.connect()

    for map_id, in dbh.execute('select id from map'):
        print(f'Saving image of map {map_id}')
        dst_path = settings.site_root / 'map' / f'{map_id}.png'
        
        with tile.map_image_from_id(map_id) as image:
            image.save(dst_path, 'png')