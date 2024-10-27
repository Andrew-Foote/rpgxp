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
    "skill_id" INTEGER NOT NULL REFERENCES "skill" ("index"),
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
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
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
    "animation1_id" INTEGER REFERENCES "animation" ("index"),
    "animation2_id" INTEGER REFERENCES "animation" ("index"),
    "element_ranks" BLOB NOT NULL,
    "state_ranks" BLOB NOT NULL,
    "exp" INTEGER NOT NULL,
    "gold" INTEGER NOT NULL,
    "item_id" INTEGER REFERENCES "item" ("index"),
    "weapon_id" INTEGER REFERENCES "weapon" ("index"),
    "armor_id" INTEGER REFERENCES "armor" ("index"),
    "treasure_prob" INTEGER NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "enemy_action" (
    "enemy_index" INTEGER NOT NULL REFERENCES "enemy" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "kind" INTEGER NOT NULL REFERENCES "enemy_action_kind" ("id"),
    "basic" INTEGER NOT NULL REFERENCES "enemy_basic_action" ("id"),
    "skill_id" INTEGER REFERENCES "skill" ("index"),
    "condition_turn_a" INTEGER NOT NULL,
    "condition_turn_b" INTEGER NOT NULL,
    "condition_hp" INTEGER NOT NULL,
    "condition_level" INTEGER NOT NULL,
    "condition_switch_id" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL CHECK ("rating" BETWEEN 1 AND 10),
    PRIMARY KEY ("enemy_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "enemy_action_kind" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "enemy_action_kind" ("id", "name") VALUES
    (0, 'BASIC'),
    (1, 'SKILL');

CREATE TABLE "enemy_basic_action" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "enemy_basic_action" ("id", "name") VALUES
    (0, 'ATTACK'),
    (1, 'DEFEND'),
    (2, 'ESCAPE'),
    (3, 'DO_NOTHING');

CREATE TABLE "item" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scope" INTEGER NOT NULL REFERENCES "scope" ("id"),
    "occasion" INTEGER NOT NULL REFERENCES "occasion" ("id"),
    "animation1_id" INTEGER REFERENCES "animation" ("index"),
    "animation2_id" INTEGER REFERENCES "animation" ("index"),
    "menu_se_name" TEXT NOT NULL,
    "menu_se_volume" INTEGER NOT NULL,
    "menu_se_pitch" INTEGER NOT NULL,
    "common_event_id" INTEGER REFERENCES "common_event" ("index"),
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
) WITHOUT ROWID, STRICT;

CREATE TABLE "scope" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "scope" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'ONE_ENEMY'),
    (2, 'ALL_ENEMIES'),
    (3, 'ONE_ALLY'),
    (4, 'ALL_ALLIES'),
    (5, 'ONE_ALLY_HP_0'),
    (6, 'ALL_ALLIES_HP_0'),
    (7, 'USER');

CREATE TABLE "occasion" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "occasion" ("id", "name") VALUES
    (0, 'ALWAYS'),
    (1, 'ONLY_IN_BATTLE'),
    (2, 'ONLY_FROM_THE_MENU'),
    (3, 'NEVER');

CREATE TABLE "parameter_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "parameter_type" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'MAX_HP'),
    (2, 'MAX_SP'),
    (3, 'STRENGTH'),
    (4, 'DEXTERITY'),
    (5, 'AGILITY'),
    (6, 'INTELLIGENCE');

CREATE TABLE "item_element" (
    "item_index" INTEGER NOT NULL REFERENCES "item" ("index"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("item_index", "element_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "item_plus_state" (
    "item_index" INTEGER NOT NULL REFERENCES "item" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("item_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "item_minus_state" (
    "item_index" INTEGER NOT NULL REFERENCES "item" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("item_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "encounter" (
    "map_id" TEXT NOT NULL REFERENCES "map" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "content" INTEGER NOT NULL REFERENCES "troop" ("index"),
    PRIMARY KEY ("map_id", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "event" (
    "map_id" TEXT NOT NULL REFERENCES "map" ("id"),
    "key" INTEGER NOT NULL,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "key")
) WITHOUT ROWID, STRICT;

CREATE TABLE "event_page" (
    "map_id" TEXT NOT NULL,
    "event_key" INTEGER NOT NULL,
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
    PRIMARY KEY ("map_id", "event_key", "index"),
    FOREIGN KEY ("map_id", "event_key")  REFERENCES "event" ("map_id", "key")
) WITHOUT ROWID, STRICT;

CREATE TABLE "direction" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "direction" ("id", "name") VALUES
    (2, 'DOWN'),
    (4, 'LEFT'),
    (6, 'RIGHT'),
    (8, 'UP');

CREATE TABLE "move_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "move_type" ("id", "name") VALUES
    (0, 'FIXED'),
    (1, 'RANDOM'),
    (2, 'APPROACH'),
    (3, 'CUSTOM');

CREATE TABLE "move_frequency" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "move_frequency" ("id", "name") VALUES
    (1, 'LOWEST'),
    (2, 'LOWER'),
    (3, 'LOW'),
    (4, 'HIGH'),
    (5, 'HIGHER'),
    (6, 'HIGHEST');

CREATE TABLE "move_speed" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "move_speed" ("id", "name") VALUES
    (1, 'SLOWEST'),
    (2, 'SLOWER'),
    (3, 'SLOW'),
    (4, 'FAST'),
    (5, 'FASTER'),
    (6, 'FASTEST');

CREATE TABLE "event_page_trigger" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "event_page_trigger" ("id", "name") VALUES
    (0, 'ACTION_BUTTON'),
    (1, 'CONTACT_WITH_PLAYER'),
    (2, 'CONTACT_WITH_EVENT'),
    (3, 'AUTORUN'),
    (4, 'PARALLEL_PROCESSING');

CREATE TABLE "map" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "tileset_id" INTEGER NOT NULL REFERENCES "tileset" ("index"),
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
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "parent_id" INTEGER REFERENCES "map_info" ("id"),
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
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "scope" INTEGER NOT NULL REFERENCES "scope" ("id"),
    "occasion" INTEGER NOT NULL REFERENCES "occasion" ("id"),
    "animation1_id" INTEGER REFERENCES "animation" ("index"),
    "animation2_id" INTEGER REFERENCES "animation" ("index"),
    "menu_se_name" TEXT NOT NULL,
    "menu_se_volume" INTEGER NOT NULL,
    "menu_se_pitch" INTEGER NOT NULL,
    "common_event_id" INTEGER REFERENCES "common_event" ("index"),
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
) WITHOUT ROWID, STRICT;

CREATE TABLE "skill_element" (
    "skill_index" INTEGER NOT NULL REFERENCES "skill" ("index"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("skill_index", "element_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "skill_plus_state" (
    "skill_index" INTEGER NOT NULL REFERENCES "skill" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("skill_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "skill_minus_state" (
    "skill_index" INTEGER NOT NULL REFERENCES "skill" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("skill_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "state" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "animation1_id" INTEGER REFERENCES "animation" ("index"),
    "animation2_id" INTEGER REFERENCES "animation" ("index"),
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
) WITHOUT ROWID, STRICT;

CREATE TABLE "state_restriction" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "state_restriction" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'CANT_USE_MAGIC'),
    (2, 'ALWAYS_ATTACK_ENEMIES'),
    (3, 'ALWAYS_ATTACK_ALLIES'),
    (4, 'CANT_MOVE');

CREATE TABLE "state_guard_element" (
    "state_index" INTEGER NOT NULL REFERENCES "state" ("index"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("state_index", "element_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "state_plus_state" (
    "state_index" INTEGER NOT NULL REFERENCES "state" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("state_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "state_minus_state" (
    "state_index" INTEGER NOT NULL REFERENCES "state" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("state_index", "state_id")
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
    "start_map_id" TEXT REFERENCES "map" ("id"),
    "start_x" INTEGER NOT NULL,
    "start_y" INTEGER NOT NULL,
    "test_troop_id" INTEGER REFERENCES "troop" ("index"),
    "battleback_name" TEXT NOT NULL,
    "battler_name" TEXT NOT NULL,
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "edit_map_id" TEXT REFERENCES "map" ("id")
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

CREATE TABLE "tileset" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
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
) WITHOUT ROWID, STRICT;

CREATE TABLE "tileset_autotile" (
    "tileset_index" INTEGER NOT NULL REFERENCES "tileset" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "content" TEXT NOT NULL,
    PRIMARY KEY ("tileset_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "troop" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "troop_member" (
    "troop_index" INTEGER NOT NULL REFERENCES "troop" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_id" INTEGER NOT NULL REFERENCES "enemy" ("index"),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "hidden" INTEGER NOT NULL CHECK ("hidden" in (0, 1)),
    "immortal" INTEGER NOT NULL CHECK ("immortal" in (0, 1)),
    PRIMARY KEY ("troop_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "troop_page" (
    "troop_index" INTEGER NOT NULL REFERENCES "troop" ("index"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "condition_turn_valid" INTEGER NOT NULL CHECK ("condition_turn_valid" in (0, 1)),
    "condition_enemy_valid" INTEGER NOT NULL CHECK ("condition_enemy_valid" in (0, 1)),
    "condition_actor_valid" INTEGER NOT NULL CHECK ("condition_actor_valid" in (0, 1)),
    "condition_switch_valid" INTEGER NOT NULL CHECK ("condition_switch_valid" in (0, 1)),
    "condition_turn_a" INTEGER NOT NULL,
    "condition_turn_b" INTEGER NOT NULL,
    "condition_enemy_index" INTEGER NOT NULL CHECK ("condition_enemy_index" BETWEEN 0 AND 7),
    "condition_enemy_hp" INTEGER NOT NULL,
    "condition_actor_id" INTEGER REFERENCES "actor" ("index"),
    "condition_actor_hp" INTEGER NOT NULL,
    "condition_switch_id" INTEGER NOT NULL,
    "span" INTEGER NOT NULL REFERENCES "troop_page_span" ("id"),
    PRIMARY KEY ("troop_index", "index")
) WITHOUT ROWID, STRICT;

CREATE TABLE "troop_page_span" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) WITHOUT ROWID, STRICT;

INSERT INTO "troop_page_span" ("id", "name") VALUES
    (0, 'BATTLE'),
    (1, 'TURN'),
    (2, 'MOMENT');

CREATE TABLE "weapon" (
    "index" INTEGER NOT NULL CHECK ("index" >= 1) PRIMARY KEY,
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "icon_name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "animation1_id" INTEGER REFERENCES "animation" ("index"),
    "animation2_id" INTEGER REFERENCES "animation" ("index"),
    "price" INTEGER NOT NULL,
    "atk" INTEGER NOT NULL,
    "pdef" INTEGER NOT NULL,
    "mdef" INTEGER NOT NULL,
    "str_plus" INTEGER NOT NULL,
    "dex_plus" INTEGER NOT NULL,
    "agi_plus" INTEGER NOT NULL,
    "int_plus" INTEGER NOT NULL
) WITHOUT ROWID, STRICT;

CREATE TABLE "weapon_element" (
    "weapon_index" INTEGER NOT NULL REFERENCES "weapon" ("index"),
    "element_id" INTEGER NOT NULL,
    PRIMARY KEY ("weapon_index", "element_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "weapon_plus_state" (
    "weapon_index" INTEGER NOT NULL REFERENCES "weapon" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("weapon_index", "state_id")
) WITHOUT ROWID, STRICT;

CREATE TABLE "weapon_minus_state" (
    "weapon_index" INTEGER NOT NULL REFERENCES "weapon" ("index"),
    "state_id" INTEGER REFERENCES "state" ("index"),
    PRIMARY KEY ("weapon_index", "state_id")
) WITHOUT ROWID, STRICT;