from pathlib import Path
import shutil
import apsw
from rpgxp import db, settings

SCHEMA = '''DROP TABLE IF EXISTS material_type;
CREATE TABLE material_type (name TEXT PRIMARY KEY) STRICT;
INSERT INTO material_type (name) VALUES ('Audio'), ('Graphics');

DROP TABLE IF EXISTS material_subtype;
CREATE TABLE IF NOT EXISTS material_subtype (
    type TEXT REFERENCES material_type (name),
    name TEXT,
    PRIMARY KEY (type, name)
) STRICT;

INSERT INTO material_subtype (type, name) VALUES
('Audio', 'BGM'),
('Audio', 'BGS'),
('Audio', 'ME'),
('Audio', 'SE'),
('Graphics', 'Animations'),
('Graphics', 'Autotiles'),
('Graphics', 'Battlebacks'),
('Graphics', 'Battlers'),
('Graphics', 'Characters'),
('Graphics', 'Fogs'),
('Graphics', 'Gameovers'),
('Graphics', 'Icons'),
('Graphics', 'Panoramas'),
('Graphics', 'Pictures'),
('Graphics', 'Tilesets'),
('Graphics', 'Titles'),
('Graphics', 'Transitions'),
('Graphics', 'Windowskins');

DROP TABLE IF EXISTS material;
CREATE TABLE material (
    type TEXT REFERENCES material_type (name),
    subtype TEXT,
    name TEXT,
    PRIMARY KEY (type, subtype, name),
    FOREIGN KEY (type, subtype) REFERENCES material_subtype (type, name)
) STRICT;

DROP TABLE IF EXISTS material_source;
CREATE TABLE material_source (
    name TEXT PRIMARY KEY,
    priority INTEGER NOT NULL UNIQUE
) STRICT;

INSERT INTO material_source (name, priority) VALUES
('game', 0),
('rtp', -1);

DROP TABLE IF EXISTS material_file;
CREATE TABLE material_file (
    type TEXT references material_type (name),
    subtype TEXT,
    name TEXT,
    source TEXT REFERENCES material_source (name),
    extension TEXT,
    PRIMARY KEY (type, subtype, name, source, extension),
    FOREIGN KEY (type, subtype) references material_subtype (type, name),
    FOREIGN KEY (type, subtype, name)
        REFERENCES material (type, subtype, name)
) STRICT;

-- Assigns a "best" file to each material to use in the website, in case there
-- are multiple files with the same name. Game files will be preferred over RTP
-- files, and for files from the same source, those whose file extensions come
-- first alphabetically will be preferred. This is not intended to reflect how
-- RPG Maker chooses the file to play (I don't know how exactly that works).
DROP VIEW IF EXISTS material_best_file;
CREATE VIEW material_best_file (type, subtype, name, source, extension) AS
SELECT
    m.type, m.subtype, m.name, m.source, m.extension
FROM material_file m
JOIN material_source s on s.name = m.source
WHERE NOT EXISTS (
    SELECT * FROM material_file m2
    JOIN material_source s2 on s2.name = m2.source
    WHERE m2.type = m.type AND m2.subtype = m.subtype AND m2.name = m.name
    AND (
        s2.priority > s.priority
        OR (s2.priority = s.priority AND m2.extension < m.extension)
    )
);
'''

def insert_material(dbh: apsw.Connection, root: Path, source: str) -> None:
    for type_, subtype in dbh.execute(
        'SELECT type, name FROM material_subtype'
    ):
        subtype_root = root / type_ / subtype

        for path in subtype_root.rglob('*'):
            if path.is_dir():
                continue

            name = str(path.relative_to(subtype_root).parent / path.stem)

            dbh.execute(
                'INSERT OR IGNORE INTO material (type, subtype, name) '
                'VALUES (?, ?, ?)',
                (type_, subtype, name)
            )

            dbh.execute(
                'INSERT INTO material_file '
                '(type, subtype, name, source, extension) '
                'VALUES (?, ?, ?, ?, ?)',
                (type_, subtype, name, source, path.suffix)
            )

def root_for_source(source: str) -> Path:
    match source:
        case 'game':
            return settings.game_root
        case 'rtp':
            return settings.rtp_root
        case _:
            raise ValueError(f"unrecognized source '{source}'")

def generate_db_schema():
    dbh = db.connect()
    dbh.pragma('foreign_keys', False)

    with dbh:
        dbh.execute(SCHEMA)

def generate_db_data():
    rtp_root = settings.rtp_root
    dbh = db.connect()
    dbh.pragma('foreign_keys', False)

    with dbh:
        if rtp_root.exists():
            insert_material(dbh, rtp_root, 'rtp')

        insert_material(dbh, settings.game_root, 'game')

def copy_static_files():
    rtp_root = settings.rtp_root
    dbh = db.connect()

    for type_, subtype, name, source, extension in dbh.execute(
        'select type, subtype, name, source, extension from material_best_file'
    ):
        src_root = root_for_source(source)
        full_name = name + extension
        src_path = src_root / type_ / subtype / full_name
        
        dst_path = (
            settings.site_root / type_.lower() / subtype.lower() / full_name
        )

        #print(f'Copying {src_path} to {dst_path}')
        dst_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src_path, dst_path)
