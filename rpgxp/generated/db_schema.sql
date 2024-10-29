DROP TABLE IF EXISTS "actor";
CREATE TABLE "actor" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "class_id" INTEGER NOT NULL REFERENCES "class" ("id"),
    "initial_level" INTEGER NOT NULL,
    "final_level" INTEGER NOT NULL,
    "exp_basis" INTEGER NOT NULL CHECK ("exp_basis" BETWEEN 10 AND 50),
    "exp_inflation" INTEGER NOT NULL CHECK ("exp_inflation" BETWEEN 10 AND 50),
    "character_name" TEXT NOT NULL,
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "battler_name" TEXT NOT NULL,
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "parameters" BLOB NOT NULL,
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    "armor1_id" INTEGER REFERENCES "armor" ("id"),
    "armor2_id" INTEGER REFERENCES "armor" ("id"),
    "armor3_id" INTEGER REFERENCES "armor" ("id"),
    "armor4_id" INTEGER REFERENCES "armor" ("id"),
    "weapon_fix" INTEGER NOT NULL CHECK ("weapon_fix" in (0, 1)),
    "armor1_fix" INTEGER NOT NULL CHECK ("armor1_fix" in (0, 1)),
    "armor2_fix" INTEGER NOT NULL CHECK ("armor2_fix" in (0, 1)),
    "armor3_fix" INTEGER NOT NULL CHECK ("armor3_fix" in (0, 1)),
    "armor4_fix" INTEGER NOT NULL CHECK ("armor4_fix" in (0, 1))
) STRICT;

DROP TABLE IF EXISTS "animation";
CREATE TABLE "animation" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "animation_name" TEXT NOT NULL,
    "animation_hue" INTEGER NOT NULL CHECK ("animation_hue" BETWEEN 0 AND 360),
    "position" INTEGER NOT NULL REFERENCES "animation_position" ("id"),
    "frame_max" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "animation_position";
CREATE TABLE "animation_position" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "animation_position" ("id", "name") VALUES
    (0, 'TOP'),
    (1, 'MIDDLE'),
    (2, 'BOTTOM'),
    (3, 'SCREEN');

DROP TABLE IF EXISTS "animation_frame";
CREATE TABLE "animation_frame" (
    "animation_id" INTEGER NOT NULL REFERENCES "animation" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "cell_max" INTEGER NOT NULL,
    "cell_data" BLOB NOT NULL,
    PRIMARY KEY ("animation_id", "index")
) STRICT;

DROP TABLE IF EXISTS "animation_timing";
CREATE TABLE "animation_timing" (
    "animation_id" INTEGER NOT NULL REFERENCES "animation" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "frame" INTEGER NOT NULL,
    "se_name" TEXT NOT NULL,
    "se_volume" INTEGER NOT NULL,
    "se_pitch" INTEGER NOT NULL,
    "flash_scope" INTEGER NOT NULL REFERENCES "animation_timing_flash_scope" ("id"),
    "flash_color_red" REAL NOT NULL CHECK ("flash_color_red" BETWEEN 0 AND 255),
    "flash_color_green" REAL NOT NULL CHECK ("flash_color_green" BETWEEN 0 AND 255),
    "flash_color_blue" REAL NOT NULL CHECK ("flash_color_blue" BETWEEN 0 AND 255),
    "flash_color_alpha" REAL NOT NULL CHECK ("flash_color_alpha" BETWEEN 0 AND 255),
    "flash_duration" INTEGER NOT NULL,
    "condition" INTEGER NOT NULL REFERENCES "animation_timing_condition" ("id"),
    PRIMARY KEY ("animation_id", "index")
) STRICT;

DROP TABLE IF EXISTS "animation_timing_flash_scope";
CREATE TABLE "animation_timing_flash_scope" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "animation_timing_flash_scope" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'TARGET'),
    (2, 'SCREEN'),
    (3, 'DELETE_TARGET');

DROP TABLE IF EXISTS "animation_timing_condition";
CREATE TABLE "animation_timing_condition" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "animation_timing_condition" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'HIT'),
    (2, 'MISS');

DROP TABLE IF EXISTS "armor";
CREATE TABLE "armor" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "kind" INTEGER NOT NULL REFERENCES "armor_kind" ("id"),
    "auto_state_id" INTEGER REFERENCES "state" ("id"),
    "price" INTEGER NOT NULL,
    "pdef" INTEGER NOT NULL,
    "mdef" INTEGER NOT NULL,
    "eva" INTEGER NOT NULL,
    "str_plus" INTEGER NOT NULL,
    "dex_plus" INTEGER NOT NULL,
    "agi_plus" INTEGER NOT NULL,
    "int_plus" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "armor_kind";
CREATE TABLE "armor_kind" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "armor_kind" ("id", "name") VALUES
    (0, 'SHIELD'),
    (1, 'HELMET'),
    (2, 'BODY_ARMOR'),
    (3, 'ACCESSORY');

DROP TABLE IF EXISTS "armor_guard_element";
CREATE TABLE "armor_guard_element" (
    "armor_id" INTEGER NOT NULL REFERENCES "armor" ("id"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("armor_id", "element_id")
) STRICT;

DROP TABLE IF EXISTS "armor_guard_state";
CREATE TABLE "armor_guard_state" (
    "armor_id" INTEGER NOT NULL REFERENCES "armor" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("armor_id", "state_id")
) STRICT;

DROP TABLE IF EXISTS "class";
CREATE TABLE "class" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "position" INTEGER NOT NULL REFERENCES "class_position" ("id"),
    "element_ranks" BLOB NOT NULL,
    "state_ranks" BLOB NOT NULL
) STRICT;

DROP TABLE IF EXISTS "class_position";
CREATE TABLE "class_position" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "class_position" ("id", "name") VALUES
    (0, 'FRONT'),
    (1, 'MIDDLE'),
    (2, 'REAR');

DROP TABLE IF EXISTS "class_weapon";
CREATE TABLE "class_weapon" (
    "class_id" INTEGER NOT NULL REFERENCES "class" ("id"),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("class_id", "weapon_id")
) STRICT;

DROP TABLE IF EXISTS "class_armor";
CREATE TABLE "class_armor" (
    "class_id" INTEGER NOT NULL REFERENCES "class" ("id"),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("class_id", "armor_id")
) STRICT;

DROP TABLE IF EXISTS "class_learning";
CREATE TABLE "class_learning" (
    "class_id" INTEGER NOT NULL REFERENCES "class" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "level" INTEGER NOT NULL,
    "skill_id" INTEGER NOT NULL REFERENCES "skill" ("id"),
    PRIMARY KEY ("class_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event";
CREATE TABLE "common_event" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "trigger" INTEGER NOT NULL REFERENCES "common_event_trigger" ("id"),
    "switch_id" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "common_event_trigger";
CREATE TABLE "common_event_trigger" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "common_event_trigger" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'AUTORUN'),
    (2, 'PARALLEL');

DROP TABLE IF EXISTS "enemy";
CREATE TABLE "enemy" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "battler_name" TEXT NOT NULL,
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "maxhp" INTEGER NOT NULL,
    "maxsp" INTEGER NOT NULL,
    "str" INTEGER NOT NULL,
    "dex" INTEGER NOT NULL,
    "agi" INTEGER NOT NULL,
    "int" INTEGER NOT NULL,
    "atk" INTEGER NOT NULL,
    "pdef" INTEGER NOT NULL,
    "mdef" INTEGER NOT NULL,
    "eva" INTEGER NOT NULL,
    "animation1_id" INTEGER REFERENCES "animation" ("id"),
    "animation2_id" INTEGER REFERENCES "animation" ("id"),
    "element_ranks" BLOB NOT NULL,
    "state_ranks" BLOB NOT NULL,
    "exp" INTEGER NOT NULL,
    "gold" INTEGER NOT NULL,
    "item_id" INTEGER REFERENCES "item" ("id"),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    "treasure_prob" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "enemy_action";
CREATE TABLE "enemy_action" (
    "enemy_id" INTEGER NOT NULL REFERENCES "enemy" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "kind" INTEGER NOT NULL REFERENCES "enemy_action_kind" ("id"),
    "basic" INTEGER NOT NULL REFERENCES "enemy_basic_action" ("id"),
    "skill_id" INTEGER REFERENCES "skill" ("id"),
    "condition_turn_a" INTEGER NOT NULL,
    "condition_turn_b" INTEGER NOT NULL,
    "condition_hp" INTEGER NOT NULL,
    "condition_level" INTEGER NOT NULL,
    "condition_switch_id" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL CHECK ("rating" BETWEEN 1 AND 10),
    PRIMARY KEY ("enemy_id", "index")
) STRICT;

DROP TABLE IF EXISTS "enemy_action_kind";
CREATE TABLE "enemy_action_kind" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "enemy_action_kind" ("id", "name") VALUES
    (0, 'BASIC'),
    (1, 'SKILL');

DROP TABLE IF EXISTS "enemy_basic_action";
CREATE TABLE "enemy_basic_action" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "enemy_basic_action" ("id", "name") VALUES
    (0, 'ATTACK'),
    (1, 'DEFEND'),
    (2, 'ESCAPE'),
    (3, 'DO_NOTHING');

DROP TABLE IF EXISTS "item";
CREATE TABLE "item" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scope" INTEGER NOT NULL REFERENCES "scope" ("id"),
    "occasion" INTEGER NOT NULL REFERENCES "occasion" ("id"),
    "animation1_id" INTEGER REFERENCES "animation" ("id"),
    "animation2_id" INTEGER REFERENCES "animation" ("id"),
    "menu_se_name" TEXT NOT NULL,
    "menu_se_volume" INTEGER NOT NULL,
    "menu_se_pitch" INTEGER NOT NULL,
    "common_event_id" INTEGER REFERENCES "common_event" ("id"),
    "price" INTEGER NOT NULL,
    "consumable" INTEGER NOT NULL CHECK ("consumable" in (0, 1)),
    "parameter_type" INTEGER NOT NULL REFERENCES "parameter_type" ("id"),
    "parameter_points" INTEGER NOT NULL,
    "recover_hp_rate" INTEGER NOT NULL,
    "recover_hp" INTEGER NOT NULL,
    "recover_sp_rate" INTEGER NOT NULL,
    "recover_sp" INTEGER NOT NULL,
    "hit" INTEGER NOT NULL,
    "pdef_f" INTEGER NOT NULL,
    "mdef_f" INTEGER NOT NULL,
    "variance" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "scope";
CREATE TABLE "scope" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "scope" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'ONE_ENEMY'),
    (2, 'ALL_ENEMIES'),
    (3, 'ONE_ALLY'),
    (4, 'ALL_ALLIES'),
    (5, 'ONE_ALLY_HP_0'),
    (6, 'ALL_ALLIES_HP_0'),
    (7, 'USER');

DROP TABLE IF EXISTS "occasion";
CREATE TABLE "occasion" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "occasion" ("id", "name") VALUES
    (0, 'ALWAYS'),
    (1, 'ONLY_IN_BATTLE'),
    (2, 'ONLY_FROM_THE_MENU'),
    (3, 'NEVER');

DROP TABLE IF EXISTS "parameter_type";
CREATE TABLE "parameter_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "parameter_type" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'MAX_HP'),
    (2, 'MAX_SP'),
    (3, 'STRENGTH'),
    (4, 'DEXTERITY'),
    (5, 'AGILITY'),
    (6, 'INTELLIGENCE');

DROP TABLE IF EXISTS "item_element";
CREATE TABLE "item_element" (
    "item_id" INTEGER NOT NULL REFERENCES "item" ("id"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("item_id", "element_id")
) STRICT;

DROP TABLE IF EXISTS "item_plus_state";
CREATE TABLE "item_plus_state" (
    "item_id" INTEGER NOT NULL REFERENCES "item" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("item_id", "state_id")
) STRICT;

DROP TABLE IF EXISTS "item_minus_state";
CREATE TABLE "item_minus_state" (
    "item_id" INTEGER NOT NULL REFERENCES "item" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("item_id", "state_id")
) STRICT;

DROP TABLE IF EXISTS "encounter";
CREATE TABLE "encounter" (
    "map_id" INTEGER NOT NULL REFERENCES "map" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "troop_id" INTEGER NOT NULL REFERENCES "troop" ("id"),
    PRIMARY KEY ("map_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event";
CREATE TABLE "event" (
    "map_id" INTEGER NOT NULL REFERENCES "map" ("id"),
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "id")
) STRICT;

DROP TABLE IF EXISTS "event_page";
CREATE TABLE "event_page" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "condition_switch1_valid" INTEGER NOT NULL CHECK ("condition_switch1_valid" in (0, 1)),
    "condition_switch2_valid" INTEGER NOT NULL CHECK ("condition_switch2_valid" in (0, 1)),
    "condition_variable_valid" INTEGER NOT NULL CHECK ("condition_variable_valid" in (0, 1)),
    "condition_self_switch_valid" INTEGER NOT NULL CHECK ("condition_self_switch_valid" in (0, 1)),
    "condition_switch1_id" INTEGER NOT NULL,
    "condition_switch2_id" INTEGER NOT NULL,
    "condition_variable_id" INTEGER NOT NULL,
    "condition_variable_value" INTEGER NOT NULL,
    "condition_self_switch_ch" TEXT NOT NULL,
    "graphic_tile_id" INTEGER NOT NULL,
    "graphic_character_name" TEXT NOT NULL,
    "graphic_character_hue" INTEGER NOT NULL CHECK ("graphic_character_hue" BETWEEN 0 AND 360),
    "graphic_direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "graphic_pattern" INTEGER NOT NULL CHECK ("graphic_pattern" BETWEEN 0 AND 3),
    "graphic_opacity" INTEGER NOT NULL,
    "graphic_blend_type" INTEGER NOT NULL,
    "move_type" INTEGER NOT NULL REFERENCES "move_type" ("id"),
    "move_frequency" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    "move_speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    "move_route_repeat" INTEGER NOT NULL CHECK ("move_route_repeat" in (0, 1)),
    "move_route_skippable" INTEGER NOT NULL CHECK ("move_route_skippable" in (0, 1)),
    "walk_anime" INTEGER NOT NULL CHECK ("walk_anime" in (0, 1)),
    "step_anime" INTEGER NOT NULL CHECK ("step_anime" in (0, 1)),
    "direction_fix" INTEGER NOT NULL CHECK ("direction_fix" in (0, 1)),
    "through" INTEGER NOT NULL CHECK ("through" in (0, 1)),
    "always_on_top" INTEGER NOT NULL CHECK ("always_on_top" in (0, 1)),
    "trigger" INTEGER NOT NULL REFERENCES "event_page_trigger" ("id"),
    PRIMARY KEY ("map_id", "event_id", "index"),
    FOREIGN KEY ("map_id", "event_id")  REFERENCES "event" ("map_id", "id")
) STRICT;

DROP TABLE IF EXISTS "direction";
CREATE TABLE "direction" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "direction" ("id", "name") VALUES
    (2, 'DOWN'),
    (4, 'LEFT'),
    (6, 'RIGHT'),
    (8, 'UP');

DROP TABLE IF EXISTS "move_type";
CREATE TABLE "move_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "move_type" ("id", "name") VALUES
    (0, 'FIXED'),
    (1, 'RANDOM'),
    (2, 'APPROACH'),
    (3, 'CUSTOM');

DROP TABLE IF EXISTS "move_frequency";
CREATE TABLE "move_frequency" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "move_frequency" ("id", "name") VALUES
    (1, 'LOWEST'),
    (2, 'LOWER'),
    (3, 'LOW'),
    (4, 'HIGH'),
    (5, 'HIGHER'),
    (6, 'HIGHEST');

DROP TABLE IF EXISTS "move_speed";
CREATE TABLE "move_speed" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "move_speed" ("id", "name") VALUES
    (1, 'SLOWEST'),
    (2, 'SLOWER'),
    (3, 'SLOW'),
    (4, 'FAST'),
    (5, 'FASTER'),
    (6, 'FASTEST');

DROP TABLE IF EXISTS "event_page_trigger";
CREATE TABLE "event_page_trigger" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "event_page_trigger" ("id", "name") VALUES
    (0, 'ACTION_BUTTON'),
    (1, 'CONTACT_WITH_PLAYER'),
    (2, 'CONTACT_WITH_EVENT'),
    (3, 'AUTORUN'),
    (4, 'PARALLEL_PROCESSING');

DROP TABLE IF EXISTS "map";
CREATE TABLE "map" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "tileset_id" INTEGER NOT NULL REFERENCES "tileset" ("id"),
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
) STRICT;

DROP TABLE IF EXISTS "map_info";
CREATE TABLE "map_info" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "parent_id" INTEGER REFERENCES "map_info" ("id"),
    "order" INTEGER NOT NULL,
    "expanded" INTEGER NOT NULL CHECK ("expanded" in (0, 1)),
    "scroll_x" INTEGER NOT NULL,
    "scroll_y" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "script";
CREATE TABLE "script" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "content" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "skill";
CREATE TABLE "skill" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scope" INTEGER NOT NULL REFERENCES "scope" ("id"),
    "occasion" INTEGER NOT NULL REFERENCES "occasion" ("id"),
    "animation1_id" INTEGER REFERENCES "animation" ("id"),
    "animation2_id" INTEGER REFERENCES "animation" ("id"),
    "menu_se_name" TEXT NOT NULL,
    "menu_se_volume" INTEGER NOT NULL,
    "menu_se_pitch" INTEGER NOT NULL,
    "common_event_id" INTEGER REFERENCES "common_event" ("id"),
    "sp_cost" INTEGER NOT NULL,
    "power" INTEGER NOT NULL,
    "atk_f" INTEGER NOT NULL,
    "eva_f" INTEGER NOT NULL,
    "str_f" INTEGER NOT NULL,
    "dex_f" INTEGER NOT NULL,
    "agi_f" INTEGER NOT NULL,
    "int_f" INTEGER NOT NULL,
    "hit" INTEGER NOT NULL,
    "pdef_f" INTEGER NOT NULL,
    "mdef_f" INTEGER NOT NULL,
    "variance" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "skill_element";
CREATE TABLE "skill_element" (
    "skill_id" INTEGER NOT NULL REFERENCES "skill" ("id"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("skill_id", "element_id")
) STRICT;

DROP TABLE IF EXISTS "skill_plus_state";
CREATE TABLE "skill_plus_state" (
    "skill_id" INTEGER NOT NULL REFERENCES "skill" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("skill_id", "state_id")
) STRICT;

DROP TABLE IF EXISTS "skill_minus_state";
CREATE TABLE "skill_minus_state" (
    "skill_id" INTEGER NOT NULL REFERENCES "skill" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("skill_id", "state_id")
) STRICT;

DROP TABLE IF EXISTS "state";
CREATE TABLE "state" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "animation_id" INTEGER REFERENCES "animation" ("id"),
    "restriction" INTEGER NOT NULL REFERENCES "state_restriction" ("id"),
    "nonresistance" INTEGER NOT NULL CHECK ("nonresistance" in (0, 1)),
    "zero_hp" INTEGER NOT NULL CHECK ("zero_hp" in (0, 1)),
    "cant_get_exp" INTEGER NOT NULL CHECK ("cant_get_exp" in (0, 1)),
    "cant_evade" INTEGER NOT NULL CHECK ("cant_evade" in (0, 1)),
    "slip_damage" INTEGER NOT NULL CHECK ("slip_damage" in (0, 1)),
    "rating" INTEGER NOT NULL CHECK ("rating" BETWEEN 0 AND 10),
    "hit_rate" INTEGER NOT NULL,
    "maxhp_rate" INTEGER NOT NULL,
    "maxsp_rate" INTEGER NOT NULL,
    "str_rate" INTEGER NOT NULL,
    "dex_rate" INTEGER NOT NULL,
    "agi_rate" INTEGER NOT NULL,
    "int_rate" INTEGER NOT NULL,
    "atk_rate" INTEGER NOT NULL,
    "pdef_rate" INTEGER NOT NULL,
    "mdef_rate" INTEGER NOT NULL,
    "eva" INTEGER NOT NULL,
    "battle_only" INTEGER NOT NULL CHECK ("battle_only" in (0, 1)),
    "hold_turn" INTEGER NOT NULL,
    "auto_release_prob" INTEGER NOT NULL,
    "shock_release_prob" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "state_restriction";
CREATE TABLE "state_restriction" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "state_restriction" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'CANT_USE_MAGIC'),
    (2, 'ALWAYS_ATTACK_ENEMIES'),
    (3, 'ALWAYS_ATTACK_ALLIES'),
    (4, 'CANT_MOVE');

DROP TABLE IF EXISTS "state_guard_element";
CREATE TABLE "state_guard_element" (
    "state_id" INTEGER NOT NULL REFERENCES "state" ("id"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("state_id", "element_id")
) STRICT;

DROP TABLE IF EXISTS "state_plus_state";
CREATE TABLE "state_plus_state" (
    "state_id" INTEGER NOT NULL REFERENCES "state" ("id"),
    "plus_state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("state_id", "plus_state_id")
) STRICT;

DROP TABLE IF EXISTS "state_minus_state";
CREATE TABLE "state_minus_state" (
    "state_id" INTEGER NOT NULL REFERENCES "state" ("id"),
    "minus_state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("state_id", "minus_state_id")
) STRICT;

DROP TABLE IF EXISTS "system";
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
    "cursor_se_name" TEXT NOT NULL,
    "cursor_se_volume" INTEGER NOT NULL,
    "cursor_se_pitch" INTEGER NOT NULL,
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
    "start_map_id" INTEGER REFERENCES "map" ("id"),
    "start_x" INTEGER NOT NULL,
    "start_y" INTEGER NOT NULL,
    "test_troop_id" INTEGER REFERENCES "troop" ("id"),
    "battleback_name" TEXT NOT NULL,
    "battler_name" TEXT NOT NULL,
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "edit_map_id" INTEGER REFERENCES "map" ("id"),
    "_" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "party_member";
CREATE TABLE "party_member" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "actor_id" INTEGER NOT NULL REFERENCES "actor" ("id")
) STRICT;

DROP TABLE IF EXISTS "element";
CREATE TABLE "element" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "switch";
CREATE TABLE "switch" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "variable";
CREATE TABLE "variable" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "test_battler";
CREATE TABLE "test_battler" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "actor_id" INTEGER NOT NULL REFERENCES "actor" ("id"),
    "level" INTEGER NOT NULL,
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    "armor1_id" INTEGER REFERENCES "armor" ("id"),
    "armor2_id" INTEGER REFERENCES "armor" ("id"),
    "armor3_id" INTEGER REFERENCES "armor" ("id"),
    "armor4_id" INTEGER REFERENCES "armor" ("id")
) STRICT;

DROP TABLE IF EXISTS "tileset";
CREATE TABLE "tileset" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "tileset_name" TEXT NOT NULL,
    "panorama_name" TEXT NOT NULL,
    "panorama_hue" INTEGER NOT NULL CHECK ("panorama_hue" BETWEEN 0 AND 360),
    "fog_name" TEXT NOT NULL,
    "fog_hue" INTEGER NOT NULL CHECK ("fog_hue" BETWEEN 0 AND 360),
    "fog_opacity" INTEGER NOT NULL,
    "fog_blend_type" INTEGER NOT NULL,
    "fog_zoom" INTEGER NOT NULL,
    "fog_sx" INTEGER NOT NULL,
    "fog_sy" INTEGER NOT NULL,
    "battleback_name" TEXT NOT NULL,
    "passages" BLOB NOT NULL,
    "priorities" BLOB NOT NULL,
    "terrain_tags" BLOB NOT NULL
) STRICT;

DROP TABLE IF EXISTS "tileset_autotile";
CREATE TABLE "tileset_autotile" (
    "tileset_id" INTEGER NOT NULL REFERENCES "tileset" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "autotile_name" TEXT NOT NULL,
    PRIMARY KEY ("tileset_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop";
CREATE TABLE "troop" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "troop_member";
CREATE TABLE "troop_member" (
    "troop_id" INTEGER NOT NULL REFERENCES "troop" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_id" INTEGER NOT NULL REFERENCES "enemy" ("id"),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "hidden" INTEGER NOT NULL CHECK ("hidden" in (0, 1)),
    "immortal" INTEGER NOT NULL CHECK ("immortal" in (0, 1)),
    PRIMARY KEY ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page";
CREATE TABLE "troop_page" (
    "troop_id" INTEGER NOT NULL REFERENCES "troop" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "condition_turn_valid" INTEGER NOT NULL CHECK ("condition_turn_valid" in (0, 1)),
    "condition_enemy_valid" INTEGER NOT NULL CHECK ("condition_enemy_valid" in (0, 1)),
    "condition_actor_valid" INTEGER NOT NULL CHECK ("condition_actor_valid" in (0, 1)),
    "condition_switch_valid" INTEGER NOT NULL CHECK ("condition_switch_valid" in (0, 1)),
    "condition_turn_a" INTEGER NOT NULL,
    "condition_turn_b" INTEGER NOT NULL,
    "condition_enemy_index" INTEGER NOT NULL CHECK ("condition_enemy_index" BETWEEN 0 AND 7),
    "condition_enemy_hp" INTEGER NOT NULL,
    "condition_actor_id" INTEGER REFERENCES "actor" ("id"),
    "condition_actor_hp" INTEGER NOT NULL,
    "condition_switch_id" INTEGER NOT NULL,
    "span" INTEGER NOT NULL REFERENCES "troop_page_span" ("id"),
    PRIMARY KEY ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_span";
CREATE TABLE "troop_page_span" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "troop_page_span" ("id", "name") VALUES
    (0, 'BATTLE'),
    (1, 'TURN'),
    (2, 'MOMENT');

DROP TABLE IF EXISTS "weapon";
CREATE TABLE "weapon" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "animation1_id" INTEGER REFERENCES "animation" ("id"),
    "animation2_id" INTEGER REFERENCES "animation" ("id"),
    "price" INTEGER NOT NULL,
    "atk" INTEGER NOT NULL,
    "pdef" INTEGER NOT NULL,
    "mdef" INTEGER NOT NULL,
    "str_plus" INTEGER NOT NULL,
    "dex_plus" INTEGER NOT NULL,
    "agi_plus" INTEGER NOT NULL,
    "int_plus" INTEGER NOT NULL
) STRICT;

DROP TABLE IF EXISTS "weapon_element";
CREATE TABLE "weapon_element" (
    "weapon_id" INTEGER NOT NULL REFERENCES "weapon" ("id"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("weapon_id", "element_id")
) STRICT;

DROP TABLE IF EXISTS "weapon_plus_state";
CREATE TABLE "weapon_plus_state" (
    "weapon_id" INTEGER NOT NULL REFERENCES "weapon" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("weapon_id", "state_id")
) STRICT;

DROP TABLE IF EXISTS "weapon_minus_state";
CREATE TABLE "weapon_minus_state" (
    "weapon_id" INTEGER NOT NULL REFERENCES "weapon" ("id"),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("weapon_id", "state_id")
) STRICT;