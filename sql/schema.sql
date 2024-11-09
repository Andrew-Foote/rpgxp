DROP TABLE IF EXISTS "actor";
CREATE TABLE "actor" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "class_id" INTEGER NOT NULL REFERENCES "class" ("id"),
    "initial_level" INTEGER NOT NULL,
    "final_level" INTEGER NOT NULL,
    "exp_basis" INTEGER NOT NULL CHECK ("exp_basis" BETWEEN 10 AND 50),
    "exp_inflation" INTEGER NOT NULL CHECK ("exp_inflation" BETWEEN 10 AND 50),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "battler_name" TEXT,
    "_battler_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_battler_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlers'),
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
    "armor4_fix" INTEGER NOT NULL CHECK ("armor4_fix" in (0, 1)),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battler_name", "_battler_name__type", "_battler_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "animation";
CREATE TABLE "animation" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "animation_name" TEXT,
    "_animation_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_animation_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Animations'),
    "animation_hue" INTEGER NOT NULL CHECK ("animation_hue" BETWEEN 0 AND 360),
    "position" INTEGER NOT NULL REFERENCES "animation_position" ("id"),
    "frame_max" INTEGER NOT NULL,
    FOREIGN KEY ("animation_name", "_animation_name__type", "_animation_name__subtype") REFERENCES "material" ("name", "type", "subtype")
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
    "se_name" TEXT,
    "_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "se_volume" INTEGER NOT NULL,
    "se_pitch" INTEGER NOT NULL,
    "flash_scope" INTEGER NOT NULL REFERENCES "animation_timing_flash_scope" ("id"),
    "flash_color_red" REAL NOT NULL CHECK ("flash_color_red" BETWEEN 0 AND 255),
    "flash_color_green" REAL NOT NULL CHECK ("flash_color_green" BETWEEN 0 AND 255),
    "flash_color_blue" REAL NOT NULL CHECK ("flash_color_blue" BETWEEN 0 AND 255),
    "flash_color_alpha" REAL NOT NULL CHECK ("flash_color_alpha" BETWEEN 0 AND 255),
    "flash_duration" INTEGER NOT NULL,
    "condition" INTEGER NOT NULL REFERENCES "animation_timing_condition" ("id"),
    PRIMARY KEY ("animation_id", "index"),
    FOREIGN KEY ("se_name", "_se_name__type", "_se_name__subtype") REFERENCES "material" ("name", "type", "subtype")
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
    "icon_name" TEXT,
    "_icon_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_icon_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Icons'),
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
    "int_plus" INTEGER NOT NULL,
    FOREIGN KEY ("icon_name", "_icon_name__type", "_icon_name__subtype") REFERENCES "material" ("name", "type", "subtype")
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
    "element_id" INTEGER REFERENCES "element" ("id"),
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
    "switch_id" INTEGER REFERENCES "switch" ("id")
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

DROP TABLE IF EXISTS "common_event_command";
CREATE TABLE "common_event_command" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    "indent" INTEGER NOT NULL CHECK ("indent" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_blank";
CREATE TABLE "common_event_command_blank" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_text";
CREATE TABLE "common_event_command_show_text" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_choices_choice";
CREATE TABLE "common_event_command_show_choices_choice" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_show_choices_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "choice" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_show_choices_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_show_choices_index") REFERENCES "common_event_command_show_choices" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "choices_cancel_type";
CREATE TABLE "choices_cancel_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "choices_cancel_type" ("id", "name") VALUES
    (0, 'DISALLOW'),
    (1, 'CHOICE1'),
    (2, 'CHOICE2'),
    (3, 'CHOICE3'),
    (4, 'CHOICE4'),
    (5, 'BRANCH');

DROP TABLE IF EXISTS "common_event_command_show_choices";
CREATE TABLE "common_event_command_show_choices" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "cancel_type" INTEGER NOT NULL REFERENCES "choices_cancel_type" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_input_number";
CREATE TABLE "common_event_command_input_number" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    "max_digits" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "text_position";
CREATE TABLE "text_position" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "text_position" ("id", "name") VALUES
    (0, 'TOP'),
    (1, 'MIDDLE'),
    (2, 'BOTTOM');

DROP TABLE IF EXISTS "common_event_command_change_text_options";
CREATE TABLE "common_event_command_change_text_options" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "position" INTEGER NOT NULL REFERENCES "text_position" ("id"),
    "no_frame" INTEGER NOT NULL CHECK ("no_frame" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_button_input_processing";
CREATE TABLE "common_event_command_button_input_processing" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_wait";
CREATE TABLE "common_event_command_wait" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_comment";
CREATE TABLE "common_event_command_comment" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "switch_state";
CREATE TABLE "switch_state" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "switch_state" ("id", "name") VALUES
    (0, 'ON'),
    (1, 'OFF');

DROP TABLE IF EXISTS "common_event_command_conditional_branch_switch";
CREATE TABLE "common_event_command_conditional_branch_switch" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "comparison";
CREATE TABLE "comparison" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "comparison" ("id", "name") VALUES
    (0, 'EQ'),
    (1, 'GE'),
    (2, 'LE'),
    (3, 'GT'),
    (4, 'LT'),
    (5, 'NE');

DROP TABLE IF EXISTS "common_event_command_conditional_branch_variable";
CREATE TABLE "common_event_command_conditional_branch_variable" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER NOT NULL,
    "value_is_variable" INTEGER NOT NULL CHECK ("value_is_variable" in (0, 1)),
    "value" INTEGER NOT NULL,
    "comparison" INTEGER NOT NULL REFERENCES "comparison" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "self_switch";
CREATE TABLE "self_switch" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "self_switch" ("id", "name") VALUES
    ('A', 'A'),
    ('B', 'B'),
    ('C', 'C'),
    ('D', 'D');

DROP TABLE IF EXISTS "common_event_command_conditional_branch_self_switch";
CREATE TABLE "common_event_command_conditional_branch_self_switch" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "bound_type";
CREATE TABLE "bound_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "bound_type" ("id", "name") VALUES
    (0, 'LOWER'),
    (1, 'UPPER');

DROP TABLE IF EXISTS "common_event_command_conditional_branch_timer";
CREATE TABLE "common_event_command_conditional_branch_timer" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" INTEGER NOT NULL,
    "bound_type" INTEGER NOT NULL REFERENCES "bound_type" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor_in_party";
CREATE TABLE "common_event_command_conditional_branch_actor_in_party" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor_name";
CREATE TABLE "common_event_command_conditional_branch_actor_name" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor_skill";
CREATE TABLE "common_event_command_conditional_branch_actor_skill" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "skill_id" INTEGER REFERENCES "skill" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor_weapon";
CREATE TABLE "common_event_command_conditional_branch_actor_weapon" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor_armor";
CREATE TABLE "common_event_command_conditional_branch_actor_armor" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor_state";
CREATE TABLE "common_event_command_conditional_branch_actor_state" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_actor";
CREATE TABLE "common_event_command_conditional_branch_actor" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "infracode" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_enemy_appear";
CREATE TABLE "common_event_command_conditional_branch_enemy_appear" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_enemy_state";
CREATE TABLE "common_event_command_conditional_branch_enemy_state" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_enemy";
CREATE TABLE "common_event_command_conditional_branch_enemy" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_id" INTEGER REFERENCES "enemy" ("id"),
    "infracode" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "direction";
CREATE TABLE "direction" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "direction" ("id", "name") VALUES
    (0, 'NONE'),
    (2, 'DOWN'),
    (4, 'LEFT'),
    (6, 'RIGHT'),
    (8, 'UP');

DROP TABLE IF EXISTS "common_event_command_conditional_branch_character";
CREATE TABLE "common_event_command_conditional_branch_character" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_reference" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_gold";
CREATE TABLE "common_event_command_conditional_branch_gold" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "amount" INTEGER NOT NULL,
    "bound_type" INTEGER NOT NULL REFERENCES "bound_type" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_item";
CREATE TABLE "common_event_command_conditional_branch_item" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "item_id" INTEGER REFERENCES "item" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_weapon";
CREATE TABLE "common_event_command_conditional_branch_weapon" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_armor";
CREATE TABLE "common_event_command_conditional_branch_armor" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_button";
CREATE TABLE "common_event_command_conditional_branch_button" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "button" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_script";
CREATE TABLE "common_event_command_conditional_branch_script" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "expr" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch";
CREATE TABLE "common_event_command_conditional_branch" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_loop";
CREATE TABLE "common_event_command_loop" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_break_loop";
CREATE TABLE "common_event_command_break_loop" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_exit_event_processing";
CREATE TABLE "common_event_command_exit_event_processing" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_erase_event";
CREATE TABLE "common_event_command_erase_event" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_call_common_event";
CREATE TABLE "common_event_command_call_common_event" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "called_event_id" INTEGER REFERENCES "common_event" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_label";
CREATE TABLE "common_event_command_label" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "id" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_jump_to_label";
CREATE TABLE "common_event_command_jump_to_label" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "id" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_switches";
CREATE TABLE "common_event_command_control_switches" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id_lo" INTEGER NOT NULL,
    "switch_id_hi" INTEGER NOT NULL,
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "assign_type";
CREATE TABLE "assign_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "assign_type" ("id", "name") VALUES
    (0, 'SUBSTITUTE'),
    (1, 'ADD'),
    (2, 'SUBTRACT'),
    (3, 'MULTIPLY'),
    (4, 'DIVIDE'),
    (5, 'REMAINDER');

DROP TABLE IF EXISTS "common_event_command_control_variables_invariant";
CREATE TABLE "common_event_command_control_variables_invariant" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_variables_variable";
CREATE TABLE "common_event_command_control_variables_variable" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_variables_random_number";
CREATE TABLE "common_event_command_control_variables_random_number" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "lb" INTEGER NOT NULL,
    "ub" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_variables_character";
CREATE TABLE "common_event_command_control_variables_character" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "attr_value" INTEGER NOT NULL,
    "attr_code" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "other_operand_type";
CREATE TABLE "other_operand_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "other_operand_type" ("id", "name") VALUES
    (0, 'MAP_ID'),
    (1, 'PARTY_SIZE'),
    (2, 'GOLD'),
    (3, 'STEP_COUNT'),
    (4, 'PLAY_TIME'),
    (5, 'TIMER'),
    (6, 'SAVE_COUNT');

DROP TABLE IF EXISTS "common_event_command_control_variables_other";
CREATE TABLE "common_event_command_control_variables_other" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "other_operand_type" INTEGER NOT NULL REFERENCES "other_operand_type" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_variables";
CREATE TABLE "common_event_command_control_variables" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id_hi" INTEGER NOT NULL,
    "variable_id_lo" INTEGER NOT NULL,
    "assign_type" INTEGER NOT NULL REFERENCES "assign_type" ("id"),
    "operand_type" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_self_switch";
CREATE TABLE "common_event_command_control_self_switch" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_timer_start";
CREATE TABLE "common_event_command_control_timer_start" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "initial_value" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_timer_stop";
CREATE TABLE "common_event_command_control_timer_stop" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_control_timer";
CREATE TABLE "common_event_command_control_timer" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "diff_type";
CREATE TABLE "diff_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "diff_type" ("id", "name") VALUES
    (0, 'INCREASE'),
    (1, 'DECREASE');

DROP TABLE IF EXISTS "common_event_command_change_gold";
CREATE TABLE "common_event_command_change_gold" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "diff_type" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "with_variable" INTEGER NOT NULL CHECK ("with_variable" in (0, 1)),
    "amount" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "const_or_var";
CREATE TABLE "const_or_var" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "const_or_var" ("id", "name") VALUES
    (0, 'CONST'),
    (1, 'VAR');

DROP TABLE IF EXISTS "common_event_command_change_items";
CREATE TABLE "common_event_command_change_items" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "item_id" INTEGER REFERENCES "item" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_weapons";
CREATE TABLE "common_event_command_change_weapons" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_armor";
CREATE TABLE "common_event_command_change_armor" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "add_or_remove";
CREATE TABLE "add_or_remove" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "add_or_remove" ("id", "name") VALUES
    (0, 'ADD'),
    (1, 'REMOVE');

DROP TABLE IF EXISTS "common_event_command_change_party_member";
CREATE TABLE "common_event_command_change_party_member" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "add_or_remove" INTEGER NOT NULL REFERENCES "add_or_remove" ("id"),
    "initialize" INTEGER NOT NULL CHECK ("initialize" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_battle_bgm";
CREATE TABLE "common_event_command_change_battle_bgm" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_battle_end_me";
CREATE TABLE "common_event_command_change_battle_end_me" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_save_access";
CREATE TABLE "common_event_command_change_save_access" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_menu_access";
CREATE TABLE "common_event_command_change_menu_access" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_encounter";
CREATE TABLE "common_event_command_change_encounter" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_transfer_player";
CREATE TABLE "common_event_command_transfer_player" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "with_variables" INTEGER NOT NULL CHECK ("with_variables" in (0, 1)),
    "target_map_id" INTEGER NOT NULL,
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "no_fade" INTEGER NOT NULL CHECK ("no_fade" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "appoint_type";
CREATE TABLE "appoint_type" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "appoint_type" ("id", "name") VALUES
    (0, 'DIRECT'),
    (1, 'VARIABLE'),
    (2, 'EXCHANGE');

DROP TABLE IF EXISTS "common_event_command_set_event_location";
CREATE TABLE "common_event_command_set_event_location" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "appoint_type" INTEGER NOT NULL REFERENCES "appoint_type" ("id"),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_scroll_map";
CREATE TABLE "common_event_command_scroll_map" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "distance" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_map_settings_panorama";
CREATE TABLE "common_event_command_change_map_settings_panorama" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Panoramas'),
    "hue" INTEGER NOT NULL CHECK ("hue" BETWEEN 0 AND 360),
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_map_settings_fog";
CREATE TABLE "common_event_command_change_map_settings_fog" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Fogs'),
    "hue" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    "zoom" INTEGER NOT NULL,
    "sx" INTEGER NOT NULL,
    "sy" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_map_settings_battle_back";
CREATE TABLE "common_event_command_change_map_settings_battle_back" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlebacks'),
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_map_settings";
CREATE TABLE "common_event_command_change_map_settings" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_fog_color_tone";
CREATE TABLE "common_event_command_change_fog_color_tone" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_fog_opacity";
CREATE TABLE "common_event_command_change_fog_opacity" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_animation";
CREATE TABLE "common_event_command_show_animation" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "animation_id" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_transparent_flag";
CREATE TABLE "common_event_command_change_transparent_flag" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "is_normal" INTEGER NOT NULL CHECK ("is_normal" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command";
CREATE TABLE "common_event_command_set_move_route_move_command" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_blank";
CREATE TABLE "common_event_command_set_move_route_move_command_blank" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_down";
CREATE TABLE "common_event_command_set_move_route_move_command_move_down" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_left";
CREATE TABLE "common_event_command_set_move_route_move_command_move_left" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_right";
CREATE TABLE "common_event_command_set_move_route_move_command_move_right" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_up";
CREATE TABLE "common_event_command_set_move_route_move_command_move_up" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_lower_left";
CREATE TABLE "common_event_command_set_move_route_move_command_move_lower_left" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_lower_right";
CREATE TABLE "common_event_command_set_move_route_move_command_move_lower_right" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_upper_left";
CREATE TABLE "common_event_command_set_move_route_move_command_move_upper_left" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_upper_right";
CREATE TABLE "common_event_command_set_move_route_move_command_move_upper_right" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_at_random";
CREATE TABLE "common_event_command_set_move_route_move_command_move_at_random" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_toward_player";
CREATE TABLE "common_event_command_set_move_route_move_command_move_toward_player" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_away_from_player";
CREATE TABLE "common_event_command_set_move_route_move_command_move_away_from_player" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_step_forward";
CREATE TABLE "common_event_command_set_move_route_move_command_step_forward" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_step_backward";
CREATE TABLE "common_event_command_set_move_route_move_command_step_backward" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_jump";
CREATE TABLE "common_event_command_set_move_route_move_command_jump" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_wait";
CREATE TABLE "common_event_command_set_move_route_move_command_wait" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_down";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_down" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_left";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_left" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_right";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_right" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_up";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_up" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn90_right";
CREATE TABLE "common_event_command_set_move_route_move_command_turn90_right" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn90_left";
CREATE TABLE "common_event_command_set_move_route_move_command_turn90_left" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn180";
CREATE TABLE "common_event_command_set_move_route_move_command_turn180" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn90_right_or_left";
CREATE TABLE "common_event_command_set_move_route_move_command_turn90_right_or_left" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_at_random";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_at_random" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_toward_player";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_toward_player" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_turn_away_from_player";
CREATE TABLE "common_event_command_set_move_route_move_command_turn_away_from_player" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_switch_on";
CREATE TABLE "common_event_command_set_move_route_move_command_switch_on" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_switch_off";
CREATE TABLE "common_event_command_set_move_route_move_command_switch_off" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

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

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_change_speed";
CREATE TABLE "common_event_command_set_move_route_move_command_change_speed" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

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

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_change_freq";
CREATE TABLE "common_event_command_set_move_route_move_command_change_freq" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_animation_on";
CREATE TABLE "common_event_command_set_move_route_move_command_move_animation_on" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_move_animation_off";
CREATE TABLE "common_event_command_set_move_route_move_command_move_animation_off" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_stop_animation_on";
CREATE TABLE "common_event_command_set_move_route_move_command_stop_animation_on" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_stop_animation_off";
CREATE TABLE "common_event_command_set_move_route_move_command_stop_animation_off" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_direction_fix_on";
CREATE TABLE "common_event_command_set_move_route_move_command_direction_fix_on" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_direction_fix_off";
CREATE TABLE "common_event_command_set_move_route_move_command_direction_fix_off" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_through_on";
CREATE TABLE "common_event_command_set_move_route_move_command_through_on" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_through_off";
CREATE TABLE "common_event_command_set_move_route_move_command_through_off" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_always_on_top_on";
CREATE TABLE "common_event_command_set_move_route_move_command_always_on_top_on" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_always_on_top_off";
CREATE TABLE "common_event_command_set_move_route_move_command_always_on_top_off" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_graphic";
CREATE TABLE "common_event_command_set_move_route_move_command_graphic" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_change_opacity";
CREATE TABLE "common_event_command_set_move_route_move_command_change_opacity" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_change_blending";
CREATE TABLE "common_event_command_set_move_route_move_command_change_blending" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_play_se";
CREATE TABLE "common_event_command_set_move_route_move_command_play_se" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route_move_command_script";
CREATE TABLE "common_event_command_set_move_route_move_command_script" (
    "common_event_id" INTEGER NOT NULL,
    "common_event_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "common_event_command_set_move_route_index", "index"),
    FOREIGN KEY ("common_event_id", "common_event_command_set_move_route_index") REFERENCES "common_event_command_set_move_route" ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_set_move_route";
CREATE TABLE "common_event_command_set_move_route" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "move_route_repeat" INTEGER NOT NULL CHECK ("move_route_repeat" in (0, 1)),
    "move_route_skippable" INTEGER NOT NULL CHECK ("move_route_skippable" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_wait_for_move_completion";
CREATE TABLE "common_event_command_wait_for_move_completion" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_prepare_for_transition";
CREATE TABLE "common_event_command_prepare_for_transition" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_execute_transition";
CREATE TABLE "common_event_command_execute_transition" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_screen_color_tone";
CREATE TABLE "common_event_command_change_screen_color_tone" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_screen_flash";
CREATE TABLE "common_event_command_screen_flash" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "color_red" REAL NOT NULL CHECK ("color_red" BETWEEN 0 AND 255),
    "color_green" REAL NOT NULL CHECK ("color_green" BETWEEN 0 AND 255),
    "color_blue" REAL NOT NULL CHECK ("color_blue" BETWEEN 0 AND 255),
    "color_alpha" REAL NOT NULL CHECK ("color_alpha" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_screen_shake";
CREATE TABLE "common_event_command_screen_shake" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "power" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_picture";
CREATE TABLE "common_event_command_show_picture" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Pictures'),
    "origin" INTEGER NOT NULL,
    "appoint_with_vars" INTEGER NOT NULL CHECK ("appoint_with_vars" in (0, 1)),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "zoom_x" INTEGER NOT NULL,
    "zoom_y" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_move_picture";
CREATE TABLE "common_event_command_move_picture" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    "origin" INTEGER NOT NULL,
    "appoint_with_vars" INTEGER NOT NULL CHECK ("appoint_with_vars" in (0, 1)),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "zoom_x" INTEGER NOT NULL,
    "zoom_y" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_rotate_picture";
CREATE TABLE "common_event_command_rotate_picture" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_change_picture_color_tone";
CREATE TABLE "common_event_command_change_picture_color_tone" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_erase_picture";
CREATE TABLE "common_event_command_erase_picture" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "weather";
CREATE TABLE "weather" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

INSERT INTO "weather" ("id", "name") VALUES
    (0, 'NONE'),
    (1, 'RAIN'),
    (2, 'STORM'),
    (3, 'SNOW');

DROP TABLE IF EXISTS "common_event_command_set_weather_effects";
CREATE TABLE "common_event_command_set_weather_effects" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "type" INTEGER NOT NULL REFERENCES "weather" ("id"),
    "power" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_play_bgm";
CREATE TABLE "common_event_command_play_bgm" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_fade_out_bgm";
CREATE TABLE "common_event_command_fade_out_bgm" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "seconds" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_play_bgs";
CREATE TABLE "common_event_command_play_bgs" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGS'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_fade_out_bgs";
CREATE TABLE "common_event_command_fade_out_bgs" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "seconds" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_memorize_bgaudio";
CREATE TABLE "common_event_command_memorize_bgaudio" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_restore_bgaudio";
CREATE TABLE "common_event_command_restore_bgaudio" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_play_me";
CREATE TABLE "common_event_command_play_me" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_play_se";
CREATE TABLE "common_event_command_play_se" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_stop_se";
CREATE TABLE "common_event_command_stop_se" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_battle_processing";
CREATE TABLE "common_event_command_battle_processing" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opponent_troop_id" INTEGER REFERENCES "troop" ("id"),
    "can_escape" INTEGER NOT NULL CHECK ("can_escape" in (0, 1)),
    "can_continue_when_loser" INTEGER NOT NULL CHECK ("can_continue_when_loser" in (0, 1)),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_shop_processing";
CREATE TABLE "common_event_command_shop_processing" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "goods" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_name_input_processing";
CREATE TABLE "common_event_command_name_input_processing" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "maxlen" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_recover_all";
CREATE TABLE "common_event_command_recover_all" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_enemy_appearance";
CREATE TABLE "common_event_command_enemy_appearance" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_index" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_enemy_transform";
CREATE TABLE "common_event_command_enemy_transform" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_index" INTEGER NOT NULL,
    "new_enemy_id" INTEGER REFERENCES "enemy" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_abort_battle";
CREATE TABLE "common_event_command_abort_battle" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_call_menu_screen";
CREATE TABLE "common_event_command_call_menu_screen" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_call_save_screen";
CREATE TABLE "common_event_command_call_save_screen" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_game_over";
CREATE TABLE "common_event_command_game_over" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_return_to_title_screen";
CREATE TABLE "common_event_command_return_to_title_screen" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_script";
CREATE TABLE "common_event_command_script" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_show_text";
CREATE TABLE "common_event_command_continue_show_text" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_choices_when_choice";
CREATE TABLE "common_event_command_show_choices_when_choice" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "choice_index" INTEGER NOT NULL,
    "choice_text" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_choices_when_cancel";
CREATE TABLE "common_event_command_show_choices_when_cancel" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_show_choices_branch_end";
CREATE TABLE "common_event_command_show_choices_branch_end" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_comment";
CREATE TABLE "common_event_command_continue_comment" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_else";
CREATE TABLE "common_event_command_else" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_conditional_branch_end";
CREATE TABLE "common_event_command_conditional_branch_end" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_repeat_above";
CREATE TABLE "common_event_command_repeat_above" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_blank";
CREATE TABLE "common_event_command_continue_set_move_route_blank" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_down";
CREATE TABLE "common_event_command_continue_set_move_route_move_down" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_left";
CREATE TABLE "common_event_command_continue_set_move_route_move_left" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_right";
CREATE TABLE "common_event_command_continue_set_move_route_move_right" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_up";
CREATE TABLE "common_event_command_continue_set_move_route_move_up" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_lower_left";
CREATE TABLE "common_event_command_continue_set_move_route_move_lower_left" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_lower_right";
CREATE TABLE "common_event_command_continue_set_move_route_move_lower_right" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_upper_left";
CREATE TABLE "common_event_command_continue_set_move_route_move_upper_left" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_upper_right";
CREATE TABLE "common_event_command_continue_set_move_route_move_upper_right" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_at_random";
CREATE TABLE "common_event_command_continue_set_move_route_move_at_random" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_toward_player";
CREATE TABLE "common_event_command_continue_set_move_route_move_toward_player" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_away_from_player";
CREATE TABLE "common_event_command_continue_set_move_route_move_away_from_player" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_step_forward";
CREATE TABLE "common_event_command_continue_set_move_route_step_forward" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_step_backward";
CREATE TABLE "common_event_command_continue_set_move_route_step_backward" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_jump";
CREATE TABLE "common_event_command_continue_set_move_route_jump" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_wait";
CREATE TABLE "common_event_command_continue_set_move_route_wait" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_down";
CREATE TABLE "common_event_command_continue_set_move_route_turn_down" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_left";
CREATE TABLE "common_event_command_continue_set_move_route_turn_left" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_right";
CREATE TABLE "common_event_command_continue_set_move_route_turn_right" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_up";
CREATE TABLE "common_event_command_continue_set_move_route_turn_up" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn90_right";
CREATE TABLE "common_event_command_continue_set_move_route_turn90_right" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn90_left";
CREATE TABLE "common_event_command_continue_set_move_route_turn90_left" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn180";
CREATE TABLE "common_event_command_continue_set_move_route_turn180" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn90_right_or_left";
CREATE TABLE "common_event_command_continue_set_move_route_turn90_right_or_left" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_at_random";
CREATE TABLE "common_event_command_continue_set_move_route_turn_at_random" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_toward_player";
CREATE TABLE "common_event_command_continue_set_move_route_turn_toward_player" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_turn_away_from_player";
CREATE TABLE "common_event_command_continue_set_move_route_turn_away_from_player" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_switch_on";
CREATE TABLE "common_event_command_continue_set_move_route_switch_on" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_switch_off";
CREATE TABLE "common_event_command_continue_set_move_route_switch_off" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_change_speed";
CREATE TABLE "common_event_command_continue_set_move_route_change_speed" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_change_freq";
CREATE TABLE "common_event_command_continue_set_move_route_change_freq" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_animation_on";
CREATE TABLE "common_event_command_continue_set_move_route_move_animation_on" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_move_animation_off";
CREATE TABLE "common_event_command_continue_set_move_route_move_animation_off" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_stop_animation_on";
CREATE TABLE "common_event_command_continue_set_move_route_stop_animation_on" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_stop_animation_off";
CREATE TABLE "common_event_command_continue_set_move_route_stop_animation_off" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_direction_fix_on";
CREATE TABLE "common_event_command_continue_set_move_route_direction_fix_on" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_direction_fix_off";
CREATE TABLE "common_event_command_continue_set_move_route_direction_fix_off" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_through_on";
CREATE TABLE "common_event_command_continue_set_move_route_through_on" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_through_off";
CREATE TABLE "common_event_command_continue_set_move_route_through_off" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_always_on_top_on";
CREATE TABLE "common_event_command_continue_set_move_route_always_on_top_on" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_always_on_top_off";
CREATE TABLE "common_event_command_continue_set_move_route_always_on_top_off" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_graphic";
CREATE TABLE "common_event_command_continue_set_move_route_graphic" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_change_opacity";
CREATE TABLE "common_event_command_continue_set_move_route_change_opacity" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_change_blending";
CREATE TABLE "common_event_command_continue_set_move_route_change_blending" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_play_se";
CREATE TABLE "common_event_command_continue_set_move_route_play_se" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route_script";
CREATE TABLE "common_event_command_continue_set_move_route_script" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_set_move_route";
CREATE TABLE "common_event_command_continue_set_move_route" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "command_code" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_if_win";
CREATE TABLE "common_event_command_if_win" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_if_escape";
CREATE TABLE "common_event_command_if_escape" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_if_lose";
CREATE TABLE "common_event_command_if_lose" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_battle_processing_end";
CREATE TABLE "common_event_command_battle_processing_end" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_shop_processing";
CREATE TABLE "common_event_command_continue_shop_processing" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "goods" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "common_event_command_continue_script";
CREATE TABLE "common_event_command_continue_script" (
    "common_event_id" INTEGER NOT NULL REFERENCES "common_event" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("common_event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "enemy";
CREATE TABLE "enemy" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "battler_name" TEXT,
    "_battler_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_battler_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlers'),
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
    "treasure_prob" INTEGER NOT NULL,
    FOREIGN KEY ("battler_name", "_battler_name__type", "_battler_name__subtype") REFERENCES "material" ("name", "type", "subtype")
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
    "condition_switch_id" INTEGER REFERENCES "switch" ("id"),
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
    "icon_name" TEXT,
    "_icon_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_icon_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Icons'),
    "description" TEXT NOT NULL,
    "scope" INTEGER NOT NULL REFERENCES "scope" ("id"),
    "occasion" INTEGER NOT NULL REFERENCES "occasion" ("id"),
    "animation1_id" INTEGER REFERENCES "animation" ("id"),
    "animation2_id" INTEGER REFERENCES "animation" ("id"),
    "menu_se_name" TEXT,
    "_menu_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_menu_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
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
    "variance" INTEGER NOT NULL,
    FOREIGN KEY ("icon_name", "_icon_name__type", "_icon_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("menu_se_name", "_menu_se_name__type", "_menu_se_name__subtype") REFERENCES "material" ("name", "type", "subtype")
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
    "element_id" INTEGER REFERENCES "element" ("id"),
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
    "condition_switch1_id" INTEGER REFERENCES "switch" ("id"),
    "condition_switch2_id" INTEGER REFERENCES "switch" ("id"),
    "condition_variable_id" INTEGER REFERENCES "variable" ("id"),
    "condition_variable_value" INTEGER NOT NULL,
    "condition_self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "graphic_tile_id" INTEGER NOT NULL,
    "graphic_character_name" TEXT,
    "_graphic_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_graphic_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
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
    FOREIGN KEY ("map_id", "event_id") REFERENCES "event" ("map_id", "id"),
    FOREIGN KEY ("graphic_character_name", "_graphic_character_name__type", "_graphic_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

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

DROP TABLE IF EXISTS "event_page_move_command";
CREATE TABLE "event_page_move_command" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_blank";
CREATE TABLE "event_page_move_command_blank" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_down";
CREATE TABLE "event_page_move_command_move_down" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_left";
CREATE TABLE "event_page_move_command_move_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_right";
CREATE TABLE "event_page_move_command_move_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_up";
CREATE TABLE "event_page_move_command_move_up" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_lower_left";
CREATE TABLE "event_page_move_command_move_lower_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_lower_right";
CREATE TABLE "event_page_move_command_move_lower_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_upper_left";
CREATE TABLE "event_page_move_command_move_upper_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_upper_right";
CREATE TABLE "event_page_move_command_move_upper_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_at_random";
CREATE TABLE "event_page_move_command_move_at_random" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_toward_player";
CREATE TABLE "event_page_move_command_move_toward_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_away_from_player";
CREATE TABLE "event_page_move_command_move_away_from_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_step_forward";
CREATE TABLE "event_page_move_command_step_forward" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_step_backward";
CREATE TABLE "event_page_move_command_step_backward" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_jump";
CREATE TABLE "event_page_move_command_jump" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_wait";
CREATE TABLE "event_page_move_command_wait" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_down";
CREATE TABLE "event_page_move_command_turn_down" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_left";
CREATE TABLE "event_page_move_command_turn_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_right";
CREATE TABLE "event_page_move_command_turn_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_up";
CREATE TABLE "event_page_move_command_turn_up" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn90_right";
CREATE TABLE "event_page_move_command_turn90_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn90_left";
CREATE TABLE "event_page_move_command_turn90_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn180";
CREATE TABLE "event_page_move_command_turn180" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn90_right_or_left";
CREATE TABLE "event_page_move_command_turn90_right_or_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_at_random";
CREATE TABLE "event_page_move_command_turn_at_random" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_toward_player";
CREATE TABLE "event_page_move_command_turn_toward_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_turn_away_from_player";
CREATE TABLE "event_page_move_command_turn_away_from_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_switch_on";
CREATE TABLE "event_page_move_command_switch_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_switch_off";
CREATE TABLE "event_page_move_command_switch_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_change_speed";
CREATE TABLE "event_page_move_command_change_speed" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_change_freq";
CREATE TABLE "event_page_move_command_change_freq" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_animation_on";
CREATE TABLE "event_page_move_command_move_animation_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_move_animation_off";
CREATE TABLE "event_page_move_command_move_animation_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_stop_animation_on";
CREATE TABLE "event_page_move_command_stop_animation_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_stop_animation_off";
CREATE TABLE "event_page_move_command_stop_animation_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_direction_fix_on";
CREATE TABLE "event_page_move_command_direction_fix_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_direction_fix_off";
CREATE TABLE "event_page_move_command_direction_fix_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_through_on";
CREATE TABLE "event_page_move_command_through_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_through_off";
CREATE TABLE "event_page_move_command_through_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_always_on_top_on";
CREATE TABLE "event_page_move_command_always_on_top_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_always_on_top_off";
CREATE TABLE "event_page_move_command_always_on_top_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_graphic";
CREATE TABLE "event_page_move_command_graphic" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_change_opacity";
CREATE TABLE "event_page_move_command_change_opacity" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_change_blending";
CREATE TABLE "event_page_move_command_change_blending" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_play_se";
CREATE TABLE "event_page_move_command_play_se" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_move_command_script";
CREATE TABLE "event_page_move_command_script" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

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

DROP TABLE IF EXISTS "event_page_command";
CREATE TABLE "event_page_command" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    "indent" INTEGER NOT NULL CHECK ("indent" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_blank";
CREATE TABLE "event_page_command_blank" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_text";
CREATE TABLE "event_page_command_show_text" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_choices_choice";
CREATE TABLE "event_page_command_show_choices_choice" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_show_choices_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "choice" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_show_choices_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_show_choices_index") REFERENCES "event_page_command_show_choices" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_choices";
CREATE TABLE "event_page_command_show_choices" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "cancel_type" INTEGER NOT NULL REFERENCES "choices_cancel_type" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_input_number";
CREATE TABLE "event_page_command_input_number" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    "max_digits" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_text_options";
CREATE TABLE "event_page_command_change_text_options" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "position" INTEGER NOT NULL REFERENCES "text_position" ("id"),
    "no_frame" INTEGER NOT NULL CHECK ("no_frame" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_button_input_processing";
CREATE TABLE "event_page_command_button_input_processing" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_wait";
CREATE TABLE "event_page_command_wait" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_comment";
CREATE TABLE "event_page_command_comment" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_switch";
CREATE TABLE "event_page_command_conditional_branch_switch" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_variable";
CREATE TABLE "event_page_command_conditional_branch_variable" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER NOT NULL,
    "value_is_variable" INTEGER NOT NULL CHECK ("value_is_variable" in (0, 1)),
    "value" INTEGER NOT NULL,
    "comparison" INTEGER NOT NULL REFERENCES "comparison" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_self_switch";
CREATE TABLE "event_page_command_conditional_branch_self_switch" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_timer";
CREATE TABLE "event_page_command_conditional_branch_timer" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" INTEGER NOT NULL,
    "bound_type" INTEGER NOT NULL REFERENCES "bound_type" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor_in_party";
CREATE TABLE "event_page_command_conditional_branch_actor_in_party" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor_name";
CREATE TABLE "event_page_command_conditional_branch_actor_name" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor_skill";
CREATE TABLE "event_page_command_conditional_branch_actor_skill" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "skill_id" INTEGER REFERENCES "skill" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor_weapon";
CREATE TABLE "event_page_command_conditional_branch_actor_weapon" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor_armor";
CREATE TABLE "event_page_command_conditional_branch_actor_armor" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor_state";
CREATE TABLE "event_page_command_conditional_branch_actor_state" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_actor";
CREATE TABLE "event_page_command_conditional_branch_actor" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "infracode" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_enemy_appear";
CREATE TABLE "event_page_command_conditional_branch_enemy_appear" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_enemy_state";
CREATE TABLE "event_page_command_conditional_branch_enemy_state" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_enemy";
CREATE TABLE "event_page_command_conditional_branch_enemy" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_id" INTEGER REFERENCES "enemy" ("id"),
    "infracode" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_character";
CREATE TABLE "event_page_command_conditional_branch_character" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_reference" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_gold";
CREATE TABLE "event_page_command_conditional_branch_gold" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "amount" INTEGER NOT NULL,
    "bound_type" INTEGER NOT NULL REFERENCES "bound_type" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_item";
CREATE TABLE "event_page_command_conditional_branch_item" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "item_id" INTEGER REFERENCES "item" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_weapon";
CREATE TABLE "event_page_command_conditional_branch_weapon" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_armor";
CREATE TABLE "event_page_command_conditional_branch_armor" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_button";
CREATE TABLE "event_page_command_conditional_branch_button" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "button" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_script";
CREATE TABLE "event_page_command_conditional_branch_script" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "expr" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch";
CREATE TABLE "event_page_command_conditional_branch" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_loop";
CREATE TABLE "event_page_command_loop" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_break_loop";
CREATE TABLE "event_page_command_break_loop" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_exit_event_processing";
CREATE TABLE "event_page_command_exit_event_processing" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_erase_event";
CREATE TABLE "event_page_command_erase_event" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_call_common_event";
CREATE TABLE "event_page_command_call_common_event" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "called_event_id" INTEGER REFERENCES "common_event" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_label";
CREATE TABLE "event_page_command_label" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "id" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_jump_to_label";
CREATE TABLE "event_page_command_jump_to_label" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "id" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_switches";
CREATE TABLE "event_page_command_control_switches" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id_lo" INTEGER NOT NULL,
    "switch_id_hi" INTEGER NOT NULL,
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_variables_invariant";
CREATE TABLE "event_page_command_control_variables_invariant" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_variables_variable";
CREATE TABLE "event_page_command_control_variables_variable" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_variables_random_number";
CREATE TABLE "event_page_command_control_variables_random_number" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "lb" INTEGER NOT NULL,
    "ub" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_variables_character";
CREATE TABLE "event_page_command_control_variables_character" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "attr_value" INTEGER NOT NULL,
    "attr_code" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_variables_other";
CREATE TABLE "event_page_command_control_variables_other" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "other_operand_type" INTEGER NOT NULL REFERENCES "other_operand_type" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_variables";
CREATE TABLE "event_page_command_control_variables" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id_hi" INTEGER NOT NULL,
    "variable_id_lo" INTEGER NOT NULL,
    "assign_type" INTEGER NOT NULL REFERENCES "assign_type" ("id"),
    "operand_type" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_self_switch";
CREATE TABLE "event_page_command_control_self_switch" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_timer_start";
CREATE TABLE "event_page_command_control_timer_start" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "initial_value" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_timer_stop";
CREATE TABLE "event_page_command_control_timer_stop" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_control_timer";
CREATE TABLE "event_page_command_control_timer" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_gold";
CREATE TABLE "event_page_command_change_gold" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "diff_type" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "with_variable" INTEGER NOT NULL CHECK ("with_variable" in (0, 1)),
    "amount" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_items";
CREATE TABLE "event_page_command_change_items" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "item_id" INTEGER REFERENCES "item" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_weapons";
CREATE TABLE "event_page_command_change_weapons" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_armor";
CREATE TABLE "event_page_command_change_armor" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_party_member";
CREATE TABLE "event_page_command_change_party_member" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "add_or_remove" INTEGER NOT NULL REFERENCES "add_or_remove" ("id"),
    "initialize" INTEGER NOT NULL CHECK ("initialize" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_battle_bgm";
CREATE TABLE "event_page_command_change_battle_bgm" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_battle_end_me";
CREATE TABLE "event_page_command_change_battle_end_me" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_save_access";
CREATE TABLE "event_page_command_change_save_access" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_menu_access";
CREATE TABLE "event_page_command_change_menu_access" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_encounter";
CREATE TABLE "event_page_command_change_encounter" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_transfer_player";
CREATE TABLE "event_page_command_transfer_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "with_variables" INTEGER NOT NULL CHECK ("with_variables" in (0, 1)),
    "target_map_id" INTEGER NOT NULL,
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "no_fade" INTEGER NOT NULL CHECK ("no_fade" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_event_location";
CREATE TABLE "event_page_command_set_event_location" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "appoint_type" INTEGER NOT NULL REFERENCES "appoint_type" ("id"),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_scroll_map";
CREATE TABLE "event_page_command_scroll_map" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "distance" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_map_settings_panorama";
CREATE TABLE "event_page_command_change_map_settings_panorama" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Panoramas'),
    "hue" INTEGER NOT NULL CHECK ("hue" BETWEEN 0 AND 360),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_map_settings_fog";
CREATE TABLE "event_page_command_change_map_settings_fog" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Fogs'),
    "hue" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    "zoom" INTEGER NOT NULL,
    "sx" INTEGER NOT NULL,
    "sy" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_map_settings_battle_back";
CREATE TABLE "event_page_command_change_map_settings_battle_back" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlebacks'),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_map_settings";
CREATE TABLE "event_page_command_change_map_settings" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_fog_color_tone";
CREATE TABLE "event_page_command_change_fog_color_tone" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_fog_opacity";
CREATE TABLE "event_page_command_change_fog_opacity" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_animation";
CREATE TABLE "event_page_command_show_animation" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "animation_id" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_transparent_flag";
CREATE TABLE "event_page_command_change_transparent_flag" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "is_normal" INTEGER NOT NULL CHECK ("is_normal" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command";
CREATE TABLE "event_page_command_set_move_route_move_command" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_blank";
CREATE TABLE "event_page_command_set_move_route_move_command_blank" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_down";
CREATE TABLE "event_page_command_set_move_route_move_command_move_down" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_left";
CREATE TABLE "event_page_command_set_move_route_move_command_move_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_right";
CREATE TABLE "event_page_command_set_move_route_move_command_move_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_up";
CREATE TABLE "event_page_command_set_move_route_move_command_move_up" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_lower_left";
CREATE TABLE "event_page_command_set_move_route_move_command_move_lower_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_lower_right";
CREATE TABLE "event_page_command_set_move_route_move_command_move_lower_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_upper_left";
CREATE TABLE "event_page_command_set_move_route_move_command_move_upper_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_upper_right";
CREATE TABLE "event_page_command_set_move_route_move_command_move_upper_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_at_random";
CREATE TABLE "event_page_command_set_move_route_move_command_move_at_random" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_toward_player";
CREATE TABLE "event_page_command_set_move_route_move_command_move_toward_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_away_from_player";
CREATE TABLE "event_page_command_set_move_route_move_command_move_away_from_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_step_forward";
CREATE TABLE "event_page_command_set_move_route_move_command_step_forward" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_step_backward";
CREATE TABLE "event_page_command_set_move_route_move_command_step_backward" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_jump";
CREATE TABLE "event_page_command_set_move_route_move_command_jump" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_wait";
CREATE TABLE "event_page_command_set_move_route_move_command_wait" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_down";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_down" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_left";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_right";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_up";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_up" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn90_right";
CREATE TABLE "event_page_command_set_move_route_move_command_turn90_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn90_left";
CREATE TABLE "event_page_command_set_move_route_move_command_turn90_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn180";
CREATE TABLE "event_page_command_set_move_route_move_command_turn180" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn90_right_or_left";
CREATE TABLE "event_page_command_set_move_route_move_command_turn90_right_or_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_at_random";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_at_random" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_toward_player";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_toward_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_turn_away_from_player";
CREATE TABLE "event_page_command_set_move_route_move_command_turn_away_from_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_switch_on";
CREATE TABLE "event_page_command_set_move_route_move_command_switch_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_switch_off";
CREATE TABLE "event_page_command_set_move_route_move_command_switch_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_change_speed";
CREATE TABLE "event_page_command_set_move_route_move_command_change_speed" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_change_freq";
CREATE TABLE "event_page_command_set_move_route_move_command_change_freq" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_animation_on";
CREATE TABLE "event_page_command_set_move_route_move_command_move_animation_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_move_animation_off";
CREATE TABLE "event_page_command_set_move_route_move_command_move_animation_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_stop_animation_on";
CREATE TABLE "event_page_command_set_move_route_move_command_stop_animation_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_stop_animation_off";
CREATE TABLE "event_page_command_set_move_route_move_command_stop_animation_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_direction_fix_on";
CREATE TABLE "event_page_command_set_move_route_move_command_direction_fix_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_direction_fix_off";
CREATE TABLE "event_page_command_set_move_route_move_command_direction_fix_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_through_on";
CREATE TABLE "event_page_command_set_move_route_move_command_through_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_through_off";
CREATE TABLE "event_page_command_set_move_route_move_command_through_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_always_on_top_on";
CREATE TABLE "event_page_command_set_move_route_move_command_always_on_top_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_always_on_top_off";
CREATE TABLE "event_page_command_set_move_route_move_command_always_on_top_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_graphic";
CREATE TABLE "event_page_command_set_move_route_move_command_graphic" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_change_opacity";
CREATE TABLE "event_page_command_set_move_route_move_command_change_opacity" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_change_blending";
CREATE TABLE "event_page_command_set_move_route_move_command_change_blending" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_play_se";
CREATE TABLE "event_page_command_set_move_route_move_command_play_se" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route_move_command_script";
CREATE TABLE "event_page_command_set_move_route_move_command_script" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "event_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index", "event_page_command_set_move_route_index") REFERENCES "event_page_command_set_move_route" ("map_id", "event_id", "event_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_move_route";
CREATE TABLE "event_page_command_set_move_route" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "move_route_repeat" INTEGER NOT NULL CHECK ("move_route_repeat" in (0, 1)),
    "move_route_skippable" INTEGER NOT NULL CHECK ("move_route_skippable" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_wait_for_move_completion";
CREATE TABLE "event_page_command_wait_for_move_completion" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_prepare_for_transition";
CREATE TABLE "event_page_command_prepare_for_transition" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_execute_transition";
CREATE TABLE "event_page_command_execute_transition" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_screen_color_tone";
CREATE TABLE "event_page_command_change_screen_color_tone" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_screen_flash";
CREATE TABLE "event_page_command_screen_flash" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "color_red" REAL NOT NULL CHECK ("color_red" BETWEEN 0 AND 255),
    "color_green" REAL NOT NULL CHECK ("color_green" BETWEEN 0 AND 255),
    "color_blue" REAL NOT NULL CHECK ("color_blue" BETWEEN 0 AND 255),
    "color_alpha" REAL NOT NULL CHECK ("color_alpha" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_screen_shake";
CREATE TABLE "event_page_command_screen_shake" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "power" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_picture";
CREATE TABLE "event_page_command_show_picture" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Pictures'),
    "origin" INTEGER NOT NULL,
    "appoint_with_vars" INTEGER NOT NULL CHECK ("appoint_with_vars" in (0, 1)),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "zoom_x" INTEGER NOT NULL,
    "zoom_y" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_move_picture";
CREATE TABLE "event_page_command_move_picture" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    "origin" INTEGER NOT NULL,
    "appoint_with_vars" INTEGER NOT NULL CHECK ("appoint_with_vars" in (0, 1)),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "zoom_x" INTEGER NOT NULL,
    "zoom_y" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_rotate_picture";
CREATE TABLE "event_page_command_rotate_picture" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_change_picture_color_tone";
CREATE TABLE "event_page_command_change_picture_color_tone" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_erase_picture";
CREATE TABLE "event_page_command_erase_picture" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_set_weather_effects";
CREATE TABLE "event_page_command_set_weather_effects" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "type" INTEGER NOT NULL REFERENCES "weather" ("id"),
    "power" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_play_bgm";
CREATE TABLE "event_page_command_play_bgm" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_fade_out_bgm";
CREATE TABLE "event_page_command_fade_out_bgm" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "seconds" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_play_bgs";
CREATE TABLE "event_page_command_play_bgs" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGS'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_fade_out_bgs";
CREATE TABLE "event_page_command_fade_out_bgs" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "seconds" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_memorize_bgaudio";
CREATE TABLE "event_page_command_memorize_bgaudio" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_restore_bgaudio";
CREATE TABLE "event_page_command_restore_bgaudio" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_play_me";
CREATE TABLE "event_page_command_play_me" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_play_se";
CREATE TABLE "event_page_command_play_se" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_stop_se";
CREATE TABLE "event_page_command_stop_se" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_battle_processing";
CREATE TABLE "event_page_command_battle_processing" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opponent_troop_id" INTEGER REFERENCES "troop" ("id"),
    "can_escape" INTEGER NOT NULL CHECK ("can_escape" in (0, 1)),
    "can_continue_when_loser" INTEGER NOT NULL CHECK ("can_continue_when_loser" in (0, 1)),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_shop_processing";
CREATE TABLE "event_page_command_shop_processing" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "goods" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_name_input_processing";
CREATE TABLE "event_page_command_name_input_processing" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "maxlen" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_recover_all";
CREATE TABLE "event_page_command_recover_all" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_enemy_appearance";
CREATE TABLE "event_page_command_enemy_appearance" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_index" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_enemy_transform";
CREATE TABLE "event_page_command_enemy_transform" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_index" INTEGER NOT NULL,
    "new_enemy_id" INTEGER REFERENCES "enemy" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_abort_battle";
CREATE TABLE "event_page_command_abort_battle" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_call_menu_screen";
CREATE TABLE "event_page_command_call_menu_screen" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_call_save_screen";
CREATE TABLE "event_page_command_call_save_screen" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_game_over";
CREATE TABLE "event_page_command_game_over" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_return_to_title_screen";
CREATE TABLE "event_page_command_return_to_title_screen" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_script";
CREATE TABLE "event_page_command_script" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_show_text";
CREATE TABLE "event_page_command_continue_show_text" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_choices_when_choice";
CREATE TABLE "event_page_command_show_choices_when_choice" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "choice_index" INTEGER NOT NULL,
    "choice_text" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_choices_when_cancel";
CREATE TABLE "event_page_command_show_choices_when_cancel" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_show_choices_branch_end";
CREATE TABLE "event_page_command_show_choices_branch_end" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_comment";
CREATE TABLE "event_page_command_continue_comment" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_else";
CREATE TABLE "event_page_command_else" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_conditional_branch_end";
CREATE TABLE "event_page_command_conditional_branch_end" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_repeat_above";
CREATE TABLE "event_page_command_repeat_above" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_blank";
CREATE TABLE "event_page_command_continue_set_move_route_blank" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_down";
CREATE TABLE "event_page_command_continue_set_move_route_move_down" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_left";
CREATE TABLE "event_page_command_continue_set_move_route_move_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_right";
CREATE TABLE "event_page_command_continue_set_move_route_move_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_up";
CREATE TABLE "event_page_command_continue_set_move_route_move_up" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_lower_left";
CREATE TABLE "event_page_command_continue_set_move_route_move_lower_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_lower_right";
CREATE TABLE "event_page_command_continue_set_move_route_move_lower_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_upper_left";
CREATE TABLE "event_page_command_continue_set_move_route_move_upper_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_upper_right";
CREATE TABLE "event_page_command_continue_set_move_route_move_upper_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_at_random";
CREATE TABLE "event_page_command_continue_set_move_route_move_at_random" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_toward_player";
CREATE TABLE "event_page_command_continue_set_move_route_move_toward_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_away_from_player";
CREATE TABLE "event_page_command_continue_set_move_route_move_away_from_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_step_forward";
CREATE TABLE "event_page_command_continue_set_move_route_step_forward" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_step_backward";
CREATE TABLE "event_page_command_continue_set_move_route_step_backward" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_jump";
CREATE TABLE "event_page_command_continue_set_move_route_jump" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_wait";
CREATE TABLE "event_page_command_continue_set_move_route_wait" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_down";
CREATE TABLE "event_page_command_continue_set_move_route_turn_down" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_left";
CREATE TABLE "event_page_command_continue_set_move_route_turn_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_right";
CREATE TABLE "event_page_command_continue_set_move_route_turn_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_up";
CREATE TABLE "event_page_command_continue_set_move_route_turn_up" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn90_right";
CREATE TABLE "event_page_command_continue_set_move_route_turn90_right" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn90_left";
CREATE TABLE "event_page_command_continue_set_move_route_turn90_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn180";
CREATE TABLE "event_page_command_continue_set_move_route_turn180" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn90_right_or_left";
CREATE TABLE "event_page_command_continue_set_move_route_turn90_right_or_left" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_at_random";
CREATE TABLE "event_page_command_continue_set_move_route_turn_at_random" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_toward_player";
CREATE TABLE "event_page_command_continue_set_move_route_turn_toward_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_turn_away_from_player";
CREATE TABLE "event_page_command_continue_set_move_route_turn_away_from_player" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_switch_on";
CREATE TABLE "event_page_command_continue_set_move_route_switch_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_switch_off";
CREATE TABLE "event_page_command_continue_set_move_route_switch_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_change_speed";
CREATE TABLE "event_page_command_continue_set_move_route_change_speed" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_change_freq";
CREATE TABLE "event_page_command_continue_set_move_route_change_freq" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_animation_on";
CREATE TABLE "event_page_command_continue_set_move_route_move_animation_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_move_animation_off";
CREATE TABLE "event_page_command_continue_set_move_route_move_animation_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_stop_animation_on";
CREATE TABLE "event_page_command_continue_set_move_route_stop_animation_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_stop_animation_off";
CREATE TABLE "event_page_command_continue_set_move_route_stop_animation_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_direction_fix_on";
CREATE TABLE "event_page_command_continue_set_move_route_direction_fix_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_direction_fix_off";
CREATE TABLE "event_page_command_continue_set_move_route_direction_fix_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_through_on";
CREATE TABLE "event_page_command_continue_set_move_route_through_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_through_off";
CREATE TABLE "event_page_command_continue_set_move_route_through_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_always_on_top_on";
CREATE TABLE "event_page_command_continue_set_move_route_always_on_top_on" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_always_on_top_off";
CREATE TABLE "event_page_command_continue_set_move_route_always_on_top_off" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_graphic";
CREATE TABLE "event_page_command_continue_set_move_route_graphic" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_change_opacity";
CREATE TABLE "event_page_command_continue_set_move_route_change_opacity" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_change_blending";
CREATE TABLE "event_page_command_continue_set_move_route_change_blending" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_play_se";
CREATE TABLE "event_page_command_continue_set_move_route_play_se" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route_script";
CREATE TABLE "event_page_command_continue_set_move_route_script" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_set_move_route";
CREATE TABLE "event_page_command_continue_set_move_route" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "command_code" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_if_win";
CREATE TABLE "event_page_command_if_win" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_if_escape";
CREATE TABLE "event_page_command_if_escape" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_if_lose";
CREATE TABLE "event_page_command_if_lose" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_battle_processing_end";
CREATE TABLE "event_page_command_battle_processing_end" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_shop_processing";
CREATE TABLE "event_page_command_continue_shop_processing" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "goods" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "event_page_command_continue_script";
CREATE TABLE "event_page_command_continue_script" (
    "map_id" INTEGER NOT NULL,
    "event_id" INTEGER NOT NULL,
    "event_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("map_id", "event_id", "event_page_index", "index"),
    FOREIGN KEY ("map_id", "event_id", "event_page_index") REFERENCES "event_page" ("map_id", "event_id", "index")
) STRICT;

DROP TABLE IF EXISTS "map";
CREATE TABLE "map" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "tileset_id" INTEGER NOT NULL REFERENCES "tileset" ("id"),
    "width" INTEGER NOT NULL,
    "height" INTEGER NOT NULL,
    "autoplay_bgm" INTEGER NOT NULL CHECK ("autoplay_bgm" in (0, 1)),
    "bgm_name" TEXT,
    "bgm_volume" INTEGER NOT NULL,
    "bgm_pitch" INTEGER NOT NULL,
    "autoplay_bgs" INTEGER NOT NULL CHECK ("autoplay_bgs" in (0, 1)),
    "bgs_name" TEXT,
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
    "icon_name" TEXT,
    "_icon_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_icon_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Icons'),
    "description" TEXT NOT NULL,
    "scope" INTEGER NOT NULL REFERENCES "scope" ("id"),
    "occasion" INTEGER NOT NULL REFERENCES "occasion" ("id"),
    "animation1_id" INTEGER REFERENCES "animation" ("id"),
    "animation2_id" INTEGER REFERENCES "animation" ("id"),
    "menu_se_name" TEXT,
    "_menu_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_menu_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
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
    "variance" INTEGER NOT NULL,
    FOREIGN KEY ("icon_name", "_icon_name__type", "_icon_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("menu_se_name", "_menu_se_name__type", "_menu_se_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "skill_element";
CREATE TABLE "skill_element" (
    "skill_id" INTEGER NOT NULL REFERENCES "skill" ("id"),
    "element_id" INTEGER REFERENCES "element" ("id"),
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
    "element_id" INTEGER REFERENCES "element" ("id"),
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
    "windowskin_name" TEXT,
    "_windowskin_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_windowskin_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Windowskins'),
    "title_name" TEXT,
    "_title_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_title_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Titles'),
    "gameover_name" TEXT,
    "_gameover_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_gameover_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Gameovers'),
    "battle_transition" TEXT,
    "_battle_transition__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_battle_transition__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Transitions'),
    "title_bgm_name" TEXT,
    "_title_bgm_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_title_bgm_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "title_bgm_volume" INTEGER NOT NULL,
    "title_bgm_pitch" INTEGER NOT NULL,
    "battle_bgm_name" TEXT,
    "_battle_bgm_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_battle_bgm_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "battle_bgm_volume" INTEGER NOT NULL,
    "battle_bgm_pitch" INTEGER NOT NULL,
    "battle_end_me_name" TEXT,
    "_battle_end_me_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_battle_end_me_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "battle_end_me_volume" INTEGER NOT NULL,
    "battle_end_me_pitch" INTEGER NOT NULL,
    "gameover_me_name" TEXT,
    "_gameover_me_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_gameover_me_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "gameover_me_volume" INTEGER NOT NULL,
    "gameover_me_pitch" INTEGER NOT NULL,
    "cursor_se_name" TEXT,
    "_cursor_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_cursor_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "cursor_se_volume" INTEGER NOT NULL,
    "cursor_se_pitch" INTEGER NOT NULL,
    "decision_se_name" TEXT,
    "_decision_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_decision_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "decision_se_volume" INTEGER NOT NULL,
    "decision_se_pitch" INTEGER NOT NULL,
    "cancel_se_name" TEXT,
    "_cancel_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_cancel_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "cancel_se_volume" INTEGER NOT NULL,
    "cancel_se_pitch" INTEGER NOT NULL,
    "buzzer_se_name" TEXT,
    "_buzzer_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_buzzer_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "buzzer_se_volume" INTEGER NOT NULL,
    "buzzer_se_pitch" INTEGER NOT NULL,
    "equip_se_name" TEXT,
    "_equip_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_equip_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "equip_se_volume" INTEGER NOT NULL,
    "equip_se_pitch" INTEGER NOT NULL,
    "shop_se_name" TEXT,
    "_shop_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_shop_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "shop_se_volume" INTEGER NOT NULL,
    "shop_se_pitch" INTEGER NOT NULL,
    "save_se_name" TEXT,
    "_save_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_save_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "save_se_volume" INTEGER NOT NULL,
    "save_se_pitch" INTEGER NOT NULL,
    "load_se_name" TEXT,
    "_load_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_load_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "load_se_volume" INTEGER NOT NULL,
    "load_se_pitch" INTEGER NOT NULL,
    "battle_start_se_name" TEXT,
    "_battle_start_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_battle_start_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "battle_start_se_volume" INTEGER NOT NULL,
    "battle_start_se_pitch" INTEGER NOT NULL,
    "escape_se_name" TEXT,
    "_escape_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_escape_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "escape_se_volume" INTEGER NOT NULL,
    "escape_se_pitch" INTEGER NOT NULL,
    "actor_collapse_se_name" TEXT,
    "_actor_collapse_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_actor_collapse_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "actor_collapse_se_volume" INTEGER NOT NULL,
    "actor_collapse_se_pitch" INTEGER NOT NULL,
    "enemy_collapse_se_name" TEXT,
    "_enemy_collapse_se_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_enemy_collapse_se_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
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
    "battleback_name" TEXT,
    "_battleback_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_battleback_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlebacks'),
    "battler_name" TEXT,
    "_battler_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_battler_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlers'),
    "battler_hue" INTEGER NOT NULL CHECK ("battler_hue" BETWEEN 0 AND 360),
    "edit_map_id" INTEGER REFERENCES "map" ("id"),
    "_" INTEGER NOT NULL,
    FOREIGN KEY ("windowskin_name", "_windowskin_name__type", "_windowskin_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("title_name", "_title_name__type", "_title_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("gameover_name", "_gameover_name__type", "_gameover_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battle_transition", "_battle_transition__type", "_battle_transition__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("title_bgm_name", "_title_bgm_name__type", "_title_bgm_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battle_bgm_name", "_battle_bgm_name__type", "_battle_bgm_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battle_end_me_name", "_battle_end_me_name__type", "_battle_end_me_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("gameover_me_name", "_gameover_me_name__type", "_gameover_me_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("cursor_se_name", "_cursor_se_name__type", "_cursor_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("decision_se_name", "_decision_se_name__type", "_decision_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("cancel_se_name", "_cancel_se_name__type", "_cancel_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("buzzer_se_name", "_buzzer_se_name__type", "_buzzer_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("equip_se_name", "_equip_se_name__type", "_equip_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("shop_se_name", "_shop_se_name__type", "_shop_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("save_se_name", "_save_se_name__type", "_save_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("load_se_name", "_load_se_name__type", "_load_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battle_start_se_name", "_battle_start_se_name__type", "_battle_start_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("escape_se_name", "_escape_se_name__type", "_escape_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("actor_collapse_se_name", "_actor_collapse_se_name__type", "_actor_collapse_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("enemy_collapse_se_name", "_enemy_collapse_se_name__type", "_enemy_collapse_se_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battleback_name", "_battleback_name__type", "_battleback_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battler_name", "_battler_name__type", "_battler_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "party_member";
CREATE TABLE "party_member" (
    "index" INTEGER NOT NULL CHECK ("index" >= 0) PRIMARY KEY,
    "actor_id" INTEGER NOT NULL REFERENCES "actor" ("id")
) STRICT;

DROP TABLE IF EXISTS "element";
CREATE TABLE "element" (
    "id" INTEGER NOT NULL CHECK ("id" >= 1) PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "switch";
CREATE TABLE "switch" (
    "id" INTEGER NOT NULL CHECK ("id" >= 1) PRIMARY KEY,
    "name" TEXT NOT NULL
) STRICT;

DROP TABLE IF EXISTS "variable";
CREATE TABLE "variable" (
    "id" INTEGER NOT NULL CHECK ("id" >= 1) PRIMARY KEY,
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
    "tileset_name" TEXT,
    "_tileset_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_tileset_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Tilesets'),
    "panorama_name" TEXT,
    "_panorama_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_panorama_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Panoramas'),
    "panorama_hue" INTEGER NOT NULL CHECK ("panorama_hue" BETWEEN 0 AND 360),
    "fog_name" TEXT,
    "_fog_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_fog_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Fogs'),
    "fog_hue" INTEGER NOT NULL CHECK ("fog_hue" BETWEEN 0 AND 360),
    "fog_opacity" INTEGER NOT NULL,
    "fog_blend_type" INTEGER NOT NULL,
    "fog_zoom" INTEGER NOT NULL,
    "fog_sx" INTEGER NOT NULL,
    "fog_sy" INTEGER NOT NULL,
    "battleback_name" TEXT,
    "_battleback_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_battleback_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlebacks'),
    "passages" BLOB NOT NULL,
    "priorities" BLOB NOT NULL,
    "terrain_tags" BLOB NOT NULL,
    FOREIGN KEY ("tileset_name", "_tileset_name__type", "_tileset_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("panorama_name", "_panorama_name__type", "_panorama_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("fog_name", "_fog_name__type", "_fog_name__subtype") REFERENCES "material" ("name", "type", "subtype"),
    FOREIGN KEY ("battleback_name", "_battleback_name__type", "_battleback_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "tileset_autotile";
CREATE TABLE "tileset_autotile" (
    "tileset_id" INTEGER NOT NULL REFERENCES "tileset" ("id"),
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "autotile_name" TEXT,
    "_autotile_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_autotile_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Autotiles'),
    PRIMARY KEY ("tileset_id", "index"),
    FOREIGN KEY ("autotile_name", "_autotile_name__type", "_autotile_name__subtype") REFERENCES "material" ("name", "type", "subtype")
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
    "condition_switch_id" INTEGER REFERENCES "switch" ("id"),
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

DROP TABLE IF EXISTS "troop_page_command";
CREATE TABLE "troop_page_command" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    "indent" INTEGER NOT NULL CHECK ("indent" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_blank";
CREATE TABLE "troop_page_command_blank" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_text";
CREATE TABLE "troop_page_command_show_text" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_choices_choice";
CREATE TABLE "troop_page_command_show_choices_choice" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_show_choices_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "choice" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_show_choices_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_show_choices_index") REFERENCES "troop_page_command_show_choices" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_choices";
CREATE TABLE "troop_page_command_show_choices" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "cancel_type" INTEGER NOT NULL REFERENCES "choices_cancel_type" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_input_number";
CREATE TABLE "troop_page_command_input_number" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    "max_digits" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_text_options";
CREATE TABLE "troop_page_command_change_text_options" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "position" INTEGER NOT NULL REFERENCES "text_position" ("id"),
    "no_frame" INTEGER NOT NULL CHECK ("no_frame" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_button_input_processing";
CREATE TABLE "troop_page_command_button_input_processing" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_wait";
CREATE TABLE "troop_page_command_wait" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_comment";
CREATE TABLE "troop_page_command_comment" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_switch";
CREATE TABLE "troop_page_command_conditional_branch_switch" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_variable";
CREATE TABLE "troop_page_command_conditional_branch_variable" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER NOT NULL,
    "value_is_variable" INTEGER NOT NULL CHECK ("value_is_variable" in (0, 1)),
    "value" INTEGER NOT NULL,
    "comparison" INTEGER NOT NULL REFERENCES "comparison" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_self_switch";
CREATE TABLE "troop_page_command_conditional_branch_self_switch" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_timer";
CREATE TABLE "troop_page_command_conditional_branch_timer" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" INTEGER NOT NULL,
    "bound_type" INTEGER NOT NULL REFERENCES "bound_type" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor_in_party";
CREATE TABLE "troop_page_command_conditional_branch_actor_in_party" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor_name";
CREATE TABLE "troop_page_command_conditional_branch_actor_name" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor_skill";
CREATE TABLE "troop_page_command_conditional_branch_actor_skill" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "skill_id" INTEGER REFERENCES "skill" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor_weapon";
CREATE TABLE "troop_page_command_conditional_branch_actor_weapon" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor_armor";
CREATE TABLE "troop_page_command_conditional_branch_actor_armor" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor_state";
CREATE TABLE "troop_page_command_conditional_branch_actor_state" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_actor";
CREATE TABLE "troop_page_command_conditional_branch_actor" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "infracode" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_enemy_appear";
CREATE TABLE "troop_page_command_conditional_branch_enemy_appear" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_enemy_state";
CREATE TABLE "troop_page_command_conditional_branch_enemy_state" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "state_id" INTEGER REFERENCES "state" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_enemy";
CREATE TABLE "troop_page_command_conditional_branch_enemy" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_id" INTEGER REFERENCES "enemy" ("id"),
    "infracode" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_character";
CREATE TABLE "troop_page_command_conditional_branch_character" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_reference" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_gold";
CREATE TABLE "troop_page_command_conditional_branch_gold" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "amount" INTEGER NOT NULL,
    "bound_type" INTEGER NOT NULL REFERENCES "bound_type" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_item";
CREATE TABLE "troop_page_command_conditional_branch_item" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "item_id" INTEGER REFERENCES "item" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_weapon";
CREATE TABLE "troop_page_command_conditional_branch_weapon" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_armor";
CREATE TABLE "troop_page_command_conditional_branch_armor" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_button";
CREATE TABLE "troop_page_command_conditional_branch_button" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "button" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_script";
CREATE TABLE "troop_page_command_conditional_branch_script" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "expr" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch";
CREATE TABLE "troop_page_command_conditional_branch" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_loop";
CREATE TABLE "troop_page_command_loop" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_break_loop";
CREATE TABLE "troop_page_command_break_loop" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_exit_event_processing";
CREATE TABLE "troop_page_command_exit_event_processing" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_erase_event";
CREATE TABLE "troop_page_command_erase_event" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_call_common_event";
CREATE TABLE "troop_page_command_call_common_event" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "called_event_id" INTEGER REFERENCES "common_event" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_label";
CREATE TABLE "troop_page_command_label" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "id" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_jump_to_label";
CREATE TABLE "troop_page_command_jump_to_label" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "id" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_switches";
CREATE TABLE "troop_page_command_control_switches" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id_lo" INTEGER NOT NULL,
    "switch_id_hi" INTEGER NOT NULL,
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_variables_invariant";
CREATE TABLE "troop_page_command_control_variables_invariant" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "value" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_variables_variable";
CREATE TABLE "troop_page_command_control_variables_variable" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id" INTEGER REFERENCES "variable" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_variables_random_number";
CREATE TABLE "troop_page_command_control_variables_random_number" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "lb" INTEGER NOT NULL,
    "ub" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_variables_character";
CREATE TABLE "troop_page_command_control_variables_character" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "attr_value" INTEGER NOT NULL,
    "attr_code" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_variables_other";
CREATE TABLE "troop_page_command_control_variables_other" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "other_operand_type" INTEGER NOT NULL REFERENCES "other_operand_type" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_variables";
CREATE TABLE "troop_page_command_control_variables" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "variable_id_hi" INTEGER NOT NULL,
    "variable_id_lo" INTEGER NOT NULL,
    "assign_type" INTEGER NOT NULL REFERENCES "assign_type" ("id"),
    "operand_type" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_self_switch";
CREATE TABLE "troop_page_command_control_self_switch" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "self_switch_ch" TEXT NOT NULL REFERENCES "self_switch" ("id"),
    "state" INTEGER NOT NULL REFERENCES "switch_state" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_timer_start";
CREATE TABLE "troop_page_command_control_timer_start" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "initial_value" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_timer_stop";
CREATE TABLE "troop_page_command_control_timer_stop" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_control_timer";
CREATE TABLE "troop_page_command_control_timer" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_gold";
CREATE TABLE "troop_page_command_change_gold" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "diff_type" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "with_variable" INTEGER NOT NULL CHECK ("with_variable" in (0, 1)),
    "amount" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_items";
CREATE TABLE "troop_page_command_change_items" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "item_id" INTEGER REFERENCES "item" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_weapons";
CREATE TABLE "troop_page_command_change_weapons" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "weapon_id" INTEGER REFERENCES "weapon" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_armor";
CREATE TABLE "troop_page_command_change_armor" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "armor_id" INTEGER REFERENCES "armor" ("id"),
    "operation" INTEGER NOT NULL REFERENCES "diff_type" ("id"),
    "operand_type" INTEGER NOT NULL REFERENCES "const_or_var" ("id"),
    "operand" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_party_member";
CREATE TABLE "troop_page_command_change_party_member" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "add_or_remove" INTEGER NOT NULL REFERENCES "add_or_remove" ("id"),
    "initialize" INTEGER NOT NULL CHECK ("initialize" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_battle_bgm";
CREATE TABLE "troop_page_command_change_battle_bgm" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_battle_end_me";
CREATE TABLE "troop_page_command_change_battle_end_me" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_save_access";
CREATE TABLE "troop_page_command_change_save_access" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_menu_access";
CREATE TABLE "troop_page_command_change_menu_access" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_encounter";
CREATE TABLE "troop_page_command_change_encounter" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enabled" INTEGER NOT NULL CHECK ("enabled" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_transfer_player";
CREATE TABLE "troop_page_command_transfer_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "with_variables" INTEGER NOT NULL CHECK ("with_variables" in (0, 1)),
    "target_map_id" INTEGER NOT NULL,
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "no_fade" INTEGER NOT NULL CHECK ("no_fade" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_event_location";
CREATE TABLE "troop_page_command_set_event_location" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "appoint_type" INTEGER NOT NULL REFERENCES "appoint_type" ("id"),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_scroll_map";
CREATE TABLE "troop_page_command_scroll_map" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "distance" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_map_settings_panorama";
CREATE TABLE "troop_page_command_change_map_settings_panorama" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Panoramas'),
    "hue" INTEGER NOT NULL CHECK ("hue" BETWEEN 0 AND 360),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_map_settings_fog";
CREATE TABLE "troop_page_command_change_map_settings_fog" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Fogs'),
    "hue" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    "zoom" INTEGER NOT NULL,
    "sx" INTEGER NOT NULL,
    "sy" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_map_settings_battle_back";
CREATE TABLE "troop_page_command_change_map_settings_battle_back" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Battlebacks'),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_map_settings";
CREATE TABLE "troop_page_command_change_map_settings" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "subcode" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_fog_color_tone";
CREATE TABLE "troop_page_command_change_fog_color_tone" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_fog_opacity";
CREATE TABLE "troop_page_command_change_fog_opacity" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_animation";
CREATE TABLE "troop_page_command_show_animation" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "animation_id" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_transparent_flag";
CREATE TABLE "troop_page_command_change_transparent_flag" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "is_normal" INTEGER NOT NULL CHECK ("is_normal" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command";
CREATE TABLE "troop_page_command_set_move_route_move_command" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "code" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_blank";
CREATE TABLE "troop_page_command_set_move_route_move_command_blank" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_down";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_down" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_left";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_right";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_up";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_up" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_lower_left";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_lower_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_lower_right";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_lower_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_upper_left";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_upper_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_upper_right";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_upper_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_at_random";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_at_random" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_toward_player";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_toward_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_away_from_player";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_away_from_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_step_forward";
CREATE TABLE "troop_page_command_set_move_route_move_command_step_forward" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_step_backward";
CREATE TABLE "troop_page_command_set_move_route_move_command_step_backward" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_jump";
CREATE TABLE "troop_page_command_set_move_route_move_command_jump" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_wait";
CREATE TABLE "troop_page_command_set_move_route_move_command_wait" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_down";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_down" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_left";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_right";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_up";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_up" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn90_right";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn90_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn90_left";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn90_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn180";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn180" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn90_right_or_left";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn90_right_or_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_at_random";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_at_random" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_toward_player";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_toward_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_turn_away_from_player";
CREATE TABLE "troop_page_command_set_move_route_move_command_turn_away_from_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_switch_on";
CREATE TABLE "troop_page_command_set_move_route_move_command_switch_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_switch_off";
CREATE TABLE "troop_page_command_set_move_route_move_command_switch_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_change_speed";
CREATE TABLE "troop_page_command_set_move_route_move_command_change_speed" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_change_freq";
CREATE TABLE "troop_page_command_set_move_route_move_command_change_freq" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_animation_on";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_animation_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_move_animation_off";
CREATE TABLE "troop_page_command_set_move_route_move_command_move_animation_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_stop_animation_on";
CREATE TABLE "troop_page_command_set_move_route_move_command_stop_animation_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_stop_animation_off";
CREATE TABLE "troop_page_command_set_move_route_move_command_stop_animation_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_direction_fix_on";
CREATE TABLE "troop_page_command_set_move_route_move_command_direction_fix_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_direction_fix_off";
CREATE TABLE "troop_page_command_set_move_route_move_command_direction_fix_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_through_on";
CREATE TABLE "troop_page_command_set_move_route_move_command_through_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_through_off";
CREATE TABLE "troop_page_command_set_move_route_move_command_through_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_always_on_top_on";
CREATE TABLE "troop_page_command_set_move_route_move_command_always_on_top_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_always_on_top_off";
CREATE TABLE "troop_page_command_set_move_route_move_command_always_on_top_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_graphic";
CREATE TABLE "troop_page_command_set_move_route_move_command_graphic" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_change_opacity";
CREATE TABLE "troop_page_command_set_move_route_move_command_change_opacity" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_change_blending";
CREATE TABLE "troop_page_command_set_move_route_move_command_change_blending" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_play_se";
CREATE TABLE "troop_page_command_set_move_route_move_command_play_se" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route_move_command_script";
CREATE TABLE "troop_page_command_set_move_route_move_command_script" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "troop_page_command_set_move_route_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index", "troop_page_command_set_move_route_index") REFERENCES "troop_page_command_set_move_route" ("troop_id", "troop_page_index", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_move_route";
CREATE TABLE "troop_page_command_set_move_route" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "event_reference" INTEGER NOT NULL,
    "move_route_repeat" INTEGER NOT NULL CHECK ("move_route_repeat" in (0, 1)),
    "move_route_skippable" INTEGER NOT NULL CHECK ("move_route_skippable" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_wait_for_move_completion";
CREATE TABLE "troop_page_command_wait_for_move_completion" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_prepare_for_transition";
CREATE TABLE "troop_page_command_prepare_for_transition" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_execute_transition";
CREATE TABLE "troop_page_command_execute_transition" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "name" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_screen_color_tone";
CREATE TABLE "troop_page_command_change_screen_color_tone" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_screen_flash";
CREATE TABLE "troop_page_command_screen_flash" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "color_red" REAL NOT NULL CHECK ("color_red" BETWEEN 0 AND 255),
    "color_green" REAL NOT NULL CHECK ("color_green" BETWEEN 0 AND 255),
    "color_blue" REAL NOT NULL CHECK ("color_blue" BETWEEN 0 AND 255),
    "color_alpha" REAL NOT NULL CHECK ("color_alpha" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_screen_shake";
CREATE TABLE "troop_page_command_screen_shake" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "power" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_picture";
CREATE TABLE "troop_page_command_show_picture" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "name" TEXT,
    "_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Pictures'),
    "origin" INTEGER NOT NULL,
    "appoint_with_vars" INTEGER NOT NULL CHECK ("appoint_with_vars" in (0, 1)),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "zoom_x" INTEGER NOT NULL,
    "zoom_y" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("name", "_name__type", "_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_move_picture";
CREATE TABLE "troop_page_command_move_picture" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    "origin" INTEGER NOT NULL,
    "appoint_with_vars" INTEGER NOT NULL CHECK ("appoint_with_vars" in (0, 1)),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    "zoom_x" INTEGER NOT NULL,
    "zoom_y" INTEGER NOT NULL,
    "opacity" INTEGER NOT NULL,
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_rotate_picture";
CREATE TABLE "troop_page_command_rotate_picture" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "speed" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_change_picture_color_tone";
CREATE TABLE "troop_page_command_change_picture_color_tone" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    "tone_red" REAL NOT NULL CHECK ("tone_red" BETWEEN -255 AND 255),
    "tone_green" REAL NOT NULL CHECK ("tone_green" BETWEEN -255 AND 255),
    "tone_blue" REAL NOT NULL CHECK ("tone_blue" BETWEEN -255 AND 255),
    "tone_grey" REAL NOT NULL CHECK ("tone_grey" BETWEEN 0 AND 255),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_erase_picture";
CREATE TABLE "troop_page_command_erase_picture" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "number" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_set_weather_effects";
CREATE TABLE "troop_page_command_set_weather_effects" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "type" INTEGER NOT NULL REFERENCES "weather" ("id"),
    "power" INTEGER NOT NULL,
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_play_bgm";
CREATE TABLE "troop_page_command_play_bgm" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGM'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_fade_out_bgm";
CREATE TABLE "troop_page_command_fade_out_bgm" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "seconds" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_play_bgs";
CREATE TABLE "troop_page_command_play_bgs" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('BGS'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_fade_out_bgs";
CREATE TABLE "troop_page_command_fade_out_bgs" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "seconds" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_memorize_bgaudio";
CREATE TABLE "troop_page_command_memorize_bgaudio" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_restore_bgaudio";
CREATE TABLE "troop_page_command_restore_bgaudio" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_play_me";
CREATE TABLE "troop_page_command_play_me" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('ME'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_play_se";
CREATE TABLE "troop_page_command_play_se" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_stop_se";
CREATE TABLE "troop_page_command_stop_se" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_battle_processing";
CREATE TABLE "troop_page_command_battle_processing" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opponent_troop_id" INTEGER REFERENCES "troop" ("id"),
    "can_escape" INTEGER NOT NULL CHECK ("can_escape" in (0, 1)),
    "can_continue_when_loser" INTEGER NOT NULL CHECK ("can_continue_when_loser" in (0, 1)),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_shop_processing";
CREATE TABLE "troop_page_command_shop_processing" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "goods" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_name_input_processing";
CREATE TABLE "troop_page_command_name_input_processing" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    "maxlen" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_recover_all";
CREATE TABLE "troop_page_command_recover_all" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "actor_id" INTEGER REFERENCES "actor" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_enemy_appearance";
CREATE TABLE "troop_page_command_enemy_appearance" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_index" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_enemy_transform";
CREATE TABLE "troop_page_command_enemy_transform" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "enemy_index" INTEGER NOT NULL,
    "new_enemy_id" INTEGER REFERENCES "enemy" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_abort_battle";
CREATE TABLE "troop_page_command_abort_battle" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_call_menu_screen";
CREATE TABLE "troop_page_command_call_menu_screen" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_call_save_screen";
CREATE TABLE "troop_page_command_call_save_screen" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_game_over";
CREATE TABLE "troop_page_command_game_over" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_return_to_title_screen";
CREATE TABLE "troop_page_command_return_to_title_screen" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_script";
CREATE TABLE "troop_page_command_script" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_show_text";
CREATE TABLE "troop_page_command_continue_show_text" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_choices_when_choice";
CREATE TABLE "troop_page_command_show_choices_when_choice" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "choice_index" INTEGER NOT NULL,
    "choice_text" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_choices_when_cancel";
CREATE TABLE "troop_page_command_show_choices_when_cancel" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_show_choices_branch_end";
CREATE TABLE "troop_page_command_show_choices_branch_end" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_comment";
CREATE TABLE "troop_page_command_continue_comment" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "text" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_else";
CREATE TABLE "troop_page_command_else" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_conditional_branch_end";
CREATE TABLE "troop_page_command_conditional_branch_end" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_repeat_above";
CREATE TABLE "troop_page_command_repeat_above" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_blank";
CREATE TABLE "troop_page_command_continue_set_move_route_blank" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_down";
CREATE TABLE "troop_page_command_continue_set_move_route_move_down" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_left";
CREATE TABLE "troop_page_command_continue_set_move_route_move_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_right";
CREATE TABLE "troop_page_command_continue_set_move_route_move_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_up";
CREATE TABLE "troop_page_command_continue_set_move_route_move_up" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_lower_left";
CREATE TABLE "troop_page_command_continue_set_move_route_move_lower_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_lower_right";
CREATE TABLE "troop_page_command_continue_set_move_route_move_lower_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_upper_left";
CREATE TABLE "troop_page_command_continue_set_move_route_move_upper_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_upper_right";
CREATE TABLE "troop_page_command_continue_set_move_route_move_upper_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_at_random";
CREATE TABLE "troop_page_command_continue_set_move_route_move_at_random" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_toward_player";
CREATE TABLE "troop_page_command_continue_set_move_route_move_toward_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_away_from_player";
CREATE TABLE "troop_page_command_continue_set_move_route_move_away_from_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_step_forward";
CREATE TABLE "troop_page_command_continue_set_move_route_step_forward" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_step_backward";
CREATE TABLE "troop_page_command_continue_set_move_route_step_backward" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_jump";
CREATE TABLE "troop_page_command_continue_set_move_route_jump" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "x" INTEGER NOT NULL,
    "y" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_wait";
CREATE TABLE "troop_page_command_continue_set_move_route_wait" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "duration" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_down";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_down" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_left";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_right";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_up";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_up" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn90_right";
CREATE TABLE "troop_page_command_continue_set_move_route_turn90_right" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn90_left";
CREATE TABLE "troop_page_command_continue_set_move_route_turn90_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn180";
CREATE TABLE "troop_page_command_continue_set_move_route_turn180" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn90_right_or_left";
CREATE TABLE "troop_page_command_continue_set_move_route_turn90_right_or_left" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_at_random";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_at_random" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_toward_player";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_toward_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_turn_away_from_player";
CREATE TABLE "troop_page_command_continue_set_move_route_turn_away_from_player" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_switch_on";
CREATE TABLE "troop_page_command_continue_set_move_route_switch_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_switch_off";
CREATE TABLE "troop_page_command_continue_set_move_route_switch_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "switch_id" INTEGER REFERENCES "switch" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_change_speed";
CREATE TABLE "troop_page_command_continue_set_move_route_change_speed" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "speed" INTEGER NOT NULL REFERENCES "move_speed" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_change_freq";
CREATE TABLE "troop_page_command_continue_set_move_route_change_freq" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "freq" INTEGER NOT NULL REFERENCES "move_frequency" ("id"),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_animation_on";
CREATE TABLE "troop_page_command_continue_set_move_route_move_animation_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_move_animation_off";
CREATE TABLE "troop_page_command_continue_set_move_route_move_animation_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_stop_animation_on";
CREATE TABLE "troop_page_command_continue_set_move_route_stop_animation_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_stop_animation_off";
CREATE TABLE "troop_page_command_continue_set_move_route_stop_animation_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_direction_fix_on";
CREATE TABLE "troop_page_command_continue_set_move_route_direction_fix_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_direction_fix_off";
CREATE TABLE "troop_page_command_continue_set_move_route_direction_fix_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_through_on";
CREATE TABLE "troop_page_command_continue_set_move_route_through_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_through_off";
CREATE TABLE "troop_page_command_continue_set_move_route_through_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_always_on_top_on";
CREATE TABLE "troop_page_command_continue_set_move_route_always_on_top_on" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_always_on_top_off";
CREATE TABLE "troop_page_command_continue_set_move_route_always_on_top_off" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_graphic";
CREATE TABLE "troop_page_command_continue_set_move_route_graphic" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "character_name" TEXT,
    "_character_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_character_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Characters'),
    "character_hue" INTEGER NOT NULL CHECK ("character_hue" BETWEEN 0 AND 360),
    "direction" INTEGER NOT NULL REFERENCES "direction" ("id"),
    "pattern" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("character_name", "_character_name__type", "_character_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_change_opacity";
CREATE TABLE "troop_page_command_continue_set_move_route_change_opacity" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "opacity" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_change_blending";
CREATE TABLE "troop_page_command_continue_set_move_route_change_blending" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "blend_type" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_play_se";
CREATE TABLE "troop_page_command_continue_set_move_route_play_se" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "audio_name" TEXT,
    "_audio_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Audio'),
    "_audio_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('SE'),
    "audio_volume" INTEGER NOT NULL,
    "audio_pitch" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index"),
    FOREIGN KEY ("audio_name", "_audio_name__type", "_audio_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route_script";
CREATE TABLE "troop_page_command_continue_set_move_route_script" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_set_move_route";
CREATE TABLE "troop_page_command_continue_set_move_route" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "command_code" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_if_win";
CREATE TABLE "troop_page_command_if_win" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_if_escape";
CREATE TABLE "troop_page_command_if_escape" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_if_lose";
CREATE TABLE "troop_page_command_if_lose" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_battle_processing_end";
CREATE TABLE "troop_page_command_battle_processing_end" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_shop_processing";
CREATE TABLE "troop_page_command_continue_shop_processing" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "goods" INTEGER NOT NULL,
    "price" INTEGER NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "troop_page_command_continue_script";
CREATE TABLE "troop_page_command_continue_script" (
    "troop_id" INTEGER NOT NULL,
    "troop_page_index" INTEGER NOT NULL,
    "index" INTEGER NOT NULL CHECK ("index" >= 0),
    "line" TEXT NOT NULL,
    PRIMARY KEY ("troop_id", "troop_page_index", "index"),
    FOREIGN KEY ("troop_id", "troop_page_index") REFERENCES "troop_page" ("troop_id", "index")
) STRICT;

DROP TABLE IF EXISTS "weapon";
CREATE TABLE "weapon" (
    "id" INTEGER NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "icon_name" TEXT,
    "_icon_name__type" TEXT NOT NULL GENERATED ALWAYS AS ('Graphics'),
    "_icon_name__subtype" TEXT NOT NULL GENERATED ALWAYS AS ('Icons'),
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
    "int_plus" INTEGER NOT NULL,
    FOREIGN KEY ("icon_name", "_icon_name__type", "_icon_name__subtype") REFERENCES "material" ("name", "type", "subtype")
) STRICT;

DROP TABLE IF EXISTS "weapon_element";
CREATE TABLE "weapon_element" (
    "weapon_id" INTEGER NOT NULL REFERENCES "weapon" ("id"),
    "element_id" INTEGER REFERENCES "element" ("id"),
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