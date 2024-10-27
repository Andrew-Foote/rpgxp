CREATE TABLE "actor" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "class_id" INTEGER NOT NULL REFERENCES "class" ("index"),
    "initial_level" INTEGER NOT NULL,
    "final_level" INTEGER NOT NULL,
    "exp_basis" INTEGER NOT NULL CHECK ("exp_basis" BETWEEN 10 AND 50),
    "exp_inflation" INTEGER NOT NULL CHECK ("exp_inflation" BETWEEN 10 AND 50),
    "character_name" TEXT NOT NULL,
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "battler_name" TEXT NOT NULL,
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "parameters" BLOB NOT NULL,
    "weapon_id" INTEGER REFERENCES "weapon" ("index"),
    "armor1_id" INTEGER REFERENCES "armor" ("index"),
    "armor2_id" INTEGER REFERENCES "armor" ("index"),
    "armor3_id" INTEGER REFERENCES "armor" ("index"),
    "armor4_id" INTEGER REFERENCES "armor" ("index"),
    "weapon_fix" INTEGER NOT NULL CHECK ("weapon_fix" in (0, 1)),
    "armor1_fix" INTEGER NOT NULL CHECK ("armor1_fix" in (0, 1)),
    "armor2_fix" INTEGER NOT NULL CHECK ("armor2_fix" in (0, 1)),
    "armor3_fix" INTEGER NOT NULL CHECK ("armor3_fix" in (0, 1)),
    "armor4_fix" INTEGER NOT NULL CHECK ("armor4_fix" in (0, 1))
) WITHOUT ROWID, STRICT;

CREATE TABLE "animation" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "animation_name" TEXT NOT NULL,
    "animation_hue" INTEGER NOT NULL CHECK ("animation_hue" BETWEEN 0 AND 360),
    "position" INTEGER NOT NULL REFERENCES "animation_position" ("id"),
    "frame_max" INTEGER NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "animation_position" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "animation_position" ("id", "name") VALUES
(0, 'TOP'),
(1, 'MIDDLE'),
(2, 'BOTTOM'),
(3, 'SCREEN');

CREATE TABLE "animation_frame" (
    "animation_index" INTEGER NOT NULL REFERENCES "animation" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "cell_max" INTEGER NOT NULL,
    "cell_data" BLOB NOT NULL,
    PRIMARY KEY ("animation_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "animation_timing" (
    "animation_index" INTEGER NOT NULL REFERENCES "animation" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "frame" INTEGER NOT NULL,
    "se_name" TEXT NOT NULL,
    "se_volume" INTEGER NOT NULL,
    "se_pitch" INTEGER NOT NULL,
    "flash_scope" INTEGER NOT NULL REFERENCES "animation_timing_flash_scope" ("id"),
    "flash_color_red" INTEGER NOT NULL CHECK ("flash_color_red" BETWEEN 0 AND 255),
    "flash_color_green" INTEGER NOT NULL CHECK ("flash_color_green" BETWEEN 0 AND 255),
    "flash_color_blue" INTEGER NOT NULL CHECK ("flash_color_blue" BETWEEN 0 AND 255),
    "flash_color_alpha" INTEGER NOT NULL CHECK ("flash_color_alpha" BETWEEN 0 AND 255),
    "flash_duration" INTEGER NOT NULL,
    "condition" INTEGER NOT NULL REFERENCES "animation_timing_condition" ("id"),
    PRIMARY KEY ("animation_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "animation_timing_flash_scope" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "animation_timing_flash_scope" ("id", "name") VALUES
(0, 'NONE'),
(1, 'TARGET'),
(2, 'SCREEN'),
(3, 'DELETE_TARGET');

CREATE TABLE "animation_timing_condition" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "animation_timing_condition" ("id", "name") VALUES
(0, 'NONE'),
(1, 'HIT'),
(2, 'MISS');

CREATE TABLE "armor" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "kind" INTEGER NOT NULL REFERENCES "armor_kind" ("id"),
    "auto_state_id" INTEGER REFERENCES "state" ("index"),
    "price" INTEGER NOT NULL,
    "pdef" INTEGER NOT NULL,
    "mdef" INTEGER NOT NULL,
    "eva" INTEGER NOT NULL,
    "str_plus" INTEGER NOT NULL,
    "dex_plus" INTEGER NOT NULL,
    "agi_plus" INTEGER NOT NULL,
    "int_plus" INTEGER NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "armor_kind" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "armor_kind" ("id", "name") VALUES
(0, 'SHIELD'),
(1, 'HELMET'),
(2, 'BODY_ARMOR'),
(3, 'ACCESSORY');

CREATE TABLE "armor_guard_element" (
    "armor_index" INTEGER NOT NULL REFERENCES "armor" ("index"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("armor_index", "element_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "armor_guard_state" (
    "armor_index" INTEGER NOT NULL REFERENCES "armor" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("armor_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "class" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "position" INTEGER NOT NULL REFERENCES "class_position" ("id"),
    "element_ranks" BLOB NOT NULL,
    "state_ranks" BLOB NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "class_position" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "class_position" ("id", "name") VALUES
(0, 'FRONT'),
(1, 'MIDDLE'),
(2, 'REAR');

CREATE TABLE "class_weapon" (
    "class_index" INTEGER NOT NULL REFERENCES "class" ("index"),
    "weapon_id" INTEGER REFERENCES "weapon" ("index"),
    PRIMARY KEY ("class_index", "weapon_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "class_armor" (
    "class_index" INTEGER NOT NULL REFERENCES "class" ("index"),
    "armor_id" INTEGER REFERENCES "armor" ("index"),
    PRIMARY KEY ("class_index", "armor_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "class_learning" (
    "class_index" INTEGER NOT NULL REFERENCES "class" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "level" INTEGER NOT NULL,
    "skill_id" INTEGER REFERENCES "skill" ("index"),
    PRIMARY KEY ("class_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "common_event" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "trigger" INTEGER NOT NULL REFERENCES "common_event_trigger" ("id"),
    "switch_id" INTEGER NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "common_event_trigger" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "common_event_trigger" ("id", "name") VALUES
(0, 'NONE'),
(1, 'AUTORUN'),
(2, 'PARALLEL');

CREATE TABLE "enemy" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;

CREATE TABLE "item" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;

CREATE TABLE "encounter" (
    "map_number" TEXT NOT NULL REFERENCES "map" ("number"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "content" INTEGER NOT NULL REFERENCES "troop" ("index"),
    PRIMARY KEY ("map_number", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "event" (
    "map_number" TEXT NOT NULL REFERENCES "map" ("number"),
    "key" INTEGER NOT NULL,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("map_number", "key")
) WITHOUT ROWID, STRICT;

CREATE TABLE "event_page" (
    "map_number" TEXT NOT NULL,
    "event_key" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_number", "event_key", "index"),
    FOREIGN KEY ("map_number", "event_key")  REFERENCES "event" ("map_number", "key")
) WITHOUT ROWID, STRICT;

CREATE TABLE "map" (
    "number" TEXT NOT NULL PRIMARY KEY,
    "tileset_id" INTEGER NOT NULL REFERENCES "tilese" ("index"),
    "width" INTEGER NOT NULL,
    "height" INTEGER NOT NULL,
    "autoplay_bgm" INTEGER NOT NULL CHECK ("autoplay_bgm" in (0, 1)),
    "bgm_name" TEXT NOT NULL,
    "bgm_volume" INTEGER NOT NULL,
    "bgm_pitch" INTEGER NOT NULL,
    "autoplay_bgs" INTEGER NOT NULL CHECK ("autoplay_bgs" in (0, 1)),
    "bgs_name" TEXT NOT NULL,
    "bgs_volume" INTEGER NOT NULL,
    "bgs_pitch" INTEGER NOT NULL,
    "encounter_step" INTEGER NOT NULL,
    "data" BLOB NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "map_info" (
    "id_" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "parent_id" INTEGER REFERENCES "map_info" ("id_"),
    "order" INTEGER NOT NULL,
    "expanded" INTEGER NOT NULL CHECK ("expanded" in (0, 1)),
    "scroll_x" INTEGER NOT NULL,
    "scroll_y" INTEGER NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "script" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "content" BLOB NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "skill" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;

CREATE TABLE "state" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;

CREATE TABLE "system" (
    "id" INTEGER NOT NULL DEFAULT 0 CHECK ("id" = 0) PRIMARY KEY,
    "magic_number" INTEGER NOT NULL,
    "windowskin_name" TEXT NOT NULL,
    "title_name" TEXT NOT NULL,
    "gameover_name" TEXT NOT NULL,
    "battle_transition" TEXT NOT NULL,
    "title_bgm_name" TEXT NOT NULL,
    "title_bgm_volume" INTEGER NOT NULL,
    "title_bgm_pitch" INTEGER NOT NULL,
    "battle_bgm_name" TEXT NOT NULL,
    "battle_bgm_volume" INTEGER NOT NULL,
    "battle_bgm_pitch" INTEGER NOT NULL,
    "battle_end_me_name" TEXT NOT NULL,
    "battle_end_me_volume" INTEGER NOT NULL,
    "battle_end_me_pitch" INTEGER NOT NULL,
    "gameover_me_name" TEXT NOT NULL,
    "gameover_me_volume" INTEGER NOT NULL,
    "gameover_me_pitch" INTEGER NOT NULL,
    "decision_se_name" TEXT NOT NULL,
    "decision_se_volume" INTEGER NOT NULL,
    "decision_se_pitch" INTEGER NOT NULL,
    "cancel_se_name" TEXT NOT NULL,
    "cancel_se_volume" INTEGER NOT NULL,
    "cancel_se_pitch" INTEGER NOT NULL,
    "buzzer_se_name" TEXT NOT NULL,
    "buzzer_se_volume" INTEGER NOT NULL,
    "buzzer_se_pitch" INTEGER NOT NULL,
    "equip_se_name" TEXT NOT NULL,
    "equip_se_volume" INTEGER NOT NULL,
    "equip_se_pitch" INTEGER NOT NULL,
    "shop_se_name" TEXT NOT NULL,
    "shop_se_volume" INTEGER NOT NULL,
    "shop_se_pitch" INTEGER NOT NULL,
    "save_se_name" TEXT NOT NULL,
    "save_se_volume" INTEGER NOT NULL,
    "save_se_pitch" INTEGER NOT NULL,
    "load_se_name" TEXT NOT NULL,
    "load_se_volume" INTEGER NOT NULL,
    "load_se_pitch" INTEGER NOT NULL,
    "battle_start_se_name" TEXT NOT NULL,
    "battle_start_se_volume" INTEGER NOT NULL,
    "battle_start_se_pitch" INTEGER NOT NULL,
    "escape_se_name" TEXT NOT NULL,
    "escape_se_volume" INTEGER NOT NULL,
    "escape_se_pitch" INTEGER NOT NULL,
    "actor_collapse_se_name" TEXT NOT NULL,
    "actor_collapse_se_volume" INTEGER NOT NULL,
    "actor_collapse_se_pitch" INTEGER NOT NULL,
    "enemy_collapse_se_name" TEXT NOT NULL,
    "enemy_collapse_se_volume" INTEGER NOT NULL,
    "enemy_collapse_se_pitch" INTEGER NOT NULL,
    "words_gold" TEXT NOT NULL,
    "words_hp" TEXT NOT NULL,
    "words_sp" TEXT NOT NULL,
    "words_str_" TEXT NOT NULL,
    "words_dex" TEXT NOT NULL,
    "words_agi" TEXT NOT NULL,
    "words_int_" TEXT NOT NULL,
    "words_atk" TEXT NOT NULL,
    "words_pdef" TEXT NOT NULL,
    "words_mdef" TEXT NOT NULL,
    "words_weapon" TEXT NOT NULL,
    "words_armor1" TEXT NOT NULL,
    "words_armor2" TEXT NOT NULL,
    "words_armor3" TEXT NOT NULL,
    "words_armor4" TEXT NOT NULL,
    "words_attack" TEXT NOT NULL,
    "words_skill" TEXT NOT NULL,
    "words_guard" TEXT NOT NULL,
    "words_item" TEXT NOT NULL,
    "words_equip" TEXT NOT NULL,
    "start_map_id" TEXT REFERENCES "map" ("number"),
    "start_x" INTEGER NOT NULL,
    "start_y" INTEGER NOT NULL,
    "test_troop_id" INTEGER REFERENCES "troop" ("index"),
    "battleback_name" TEXT NOT NULL,
    "battler_name" TEXT NOT NULL,
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "edit_map_id" TEXT REFERENCES "map" ("number")
) WITHOUT ROWID, STRICT;

CREATE TABLE "party_member" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "content" INTEGER NOT NULL REFERENCES "actor" ("index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "element" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "content" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "switch" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "content" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "variable" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "content" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "test_battler" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "actor_id" INTEGER NOT NULL REFERENCES "actor" ("index"),
    "level" INTEGER NOT NULL,
    "weapon_id" INTEGER REFERENCES "weapon" ("index"),
    "armor1_id" INTEGER REFERENCES "armor" ("index"),
    "armor2_id" INTEGER REFERENCES "armor" ("index"),
    "armor3_id" INTEGER REFERENCES "armor" ("index"),
    "armor4_id" INTEGER REFERENCES "armor" ("index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "tilese" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;

CREATE TABLE "troop" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;

CREATE TABLE "weapon" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY
) WITHOUT ROWID, STRICT;
