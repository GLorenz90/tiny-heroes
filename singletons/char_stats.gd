extends Node

#region CONSTANTS ==============================================================
const MAX_VELOCITY := 300.0;
const MAX_COYOTE_TIME := 0.15;
const MAX_INPUT_BUFFER_TIME := 0.2;
const WALL_NUDGE_SPEED := 50.0;

const BASE_WALK_SPEED := 100.0;
const BASE_ROLL_SPEED := 350.0;
const BASE_ROLL_TIME := 0.4;
const BASE_JUMP_TIME := 0.08;
const BASE_JUMP_VELOCITY := 200.0;
const BASE_HURT_VELOCITY := 150.0;
const BASE_ATTACK_DELAY := 0.2;
const BASE_MAX_HEALTH := 6;

const OWLET_EFFECT_COLOR := Color("fa9c05");
const BUNNY_EFFECT_COLOR := Color("c787ff");
const SEAL_EFFECT_COLOR := Color("17ffff");

const HURT_TIME := .75;
const INVULN_TIME := 2.0;

# How long each attack is
const ATTACK_TIMING = {
  Enums.ATTACK_STATES.NONE: 0.01, # Cannot be 0
  Enums.ATTACK_STATES.PUNCH_1: 0.3,
  Enums.ATTACK_STATES.PUNCH_2: 0.4
}

# How long must a state wait before the next attack can happen
# If this is less than the attack timing it means it is interruptable
const ATTACK_DELAY_TIMING = {
  Enums.ATTACK_STATES.NONE: 0.01, # Cannot be 0
  Enums.ATTACK_STATES.PUNCH_1: 0.2,
  Enums.ATTACK_STATES.PUNCH_2: 0.6
}

const COMBO_ATTACK_STATES = [Enums.ATTACK_STATES.NONE, Enums.ATTACK_STATES.PUNCH_1];
#endregion

#region ADJUSTABLES ============================================================
# These should always start at 0 on new game.
var ADJUST_WALK_SPEED := 0.0;
var ADJUST_ROLL_SPEED := 0.0;
var ADJUST_ROLL_TIME := 0.0;
var ADJUST_JUMP_TIME := 0.0;
var ADJUST_JUMP_VELOCITY := 0.0;
var ADJUST_ATTACK_DELAY := 0.0;
var ADJUST_MAX_HEALTH := 0;

var TOTAL_WALK_SPEED: float:
  get: return BASE_WALK_SPEED + ADJUST_WALK_SPEED;
var TOTAL_ROLL_SPEED: float:
  get: return BASE_ROLL_SPEED + ADJUST_ROLL_SPEED;
var TOTAL_ROLL_TIME: float:
  get: return BASE_ROLL_TIME + ADJUST_ROLL_TIME;
var TOTAL_JUMP_TIME: float:
  get: return BASE_JUMP_TIME + ADJUST_JUMP_TIME;
var TOTAL_JUMP_VELOCITY: float:
  get: return BASE_JUMP_VELOCITY + ADJUST_JUMP_VELOCITY;
var TOTAL_ATTACK_DELAY: float:
  get: return BASE_ATTACK_DELAY + ADJUST_ATTACK_DELAY;
var TOTAL_MAX_HEALTH: int:
  get: return BASE_MAX_HEALTH + ADJUST_MAX_HEALTH;
#endregion

#region PLAYER STATS =========================================================
var P1_CURRENT_HEALTH := TOTAL_MAX_HEALTH:
  set(value):
    P1_CURRENT_HEALTH = clampi(value, 0, TOTAL_MAX_HEALTH);
var P2_CURRENT_HEALTH := TOTAL_MAX_HEALTH:
  set(value):
    P2_CURRENT_HEALTH = clampi(value, 0, TOTAL_MAX_HEALTH);

var CURRENT_MONEY := 0;
#endregion
