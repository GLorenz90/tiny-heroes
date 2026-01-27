extends Node
class_name InputManager

@onready var p1_device := Global.device_manager.get_player_device(1);
@onready var p2_device := Global.device_manager.get_player_device(2);

enum INPUTS {
  UP,
  DOWN,
  LEFT,
  RIGHT,
  JUMP,
  ATTACK,
  INTERACT,
  PAUSE,
  ACCEPT,
  CANCEL
}

enum ACTIONS {
  MOVE_X,
  MOVE_Y,
  JUMP,
  ATTACK,
  INTERACT,
  PAUSE,
  ACCEPT,
  CANCEL
}

# TODO: figure out how to support stick and dpad
var p1_action_map: Dictionary[INPUTS, InputEvent] = {
  INPUTS.UP: null,
  INPUTS.DOWN: null,
  INPUTS.LEFT: null,
  INPUTS.RIGHT: null,
  INPUTS.JUMP: null,
  INPUTS.ATTACK: null,
  INPUTS.INTERACT: null,
  INPUTS.PAUSE: null,
  INPUTS.ACCEPT: null,
  INPUTS.CANCEL: null
};

var p1_cur_action_state: Dictionary = {
  ACTIONS.MOVE_X: 0.0,
  ACTIONS.MOVE_Y: 0.0,
  ACTIONS.JUMP: false,
  ACTIONS.ATTACK: false,
  ACTIONS.INTERACT: false,
  ACTIONS.PAUSE: false,
  ACTIONS.ACCEPT: false,
  ACTIONS.CANCEL: false
};

var p1_prev_action_state = p1_cur_action_state.duplicate();
var p1_just_pressed_action_state = p1_cur_action_state.duplicate();

var p2_action_map = p1_action_map.duplicate();
var p2_cur_action_state = p1_cur_action_state.duplicate();
var p2_prev_action_state = p1_cur_action_state.duplicate();
var p2_just_pressed_action_state = p1_cur_action_state.duplicate();

const template_input_buffer := {
  "char_h": 0.0,
  "char_v": 0.0,
  "char_vector": Vector2(0.0, 0.0),
  "char_attack_pressed": false,
  "char_attack_held": false,
  "char_attack_held_time": 0.0,
  "char_jump_pressed": false,
  "char_jump_held": false,
  "char_jump_held_time": 0.0,
  "char_interact_pressed": false,
  "char_interact_held": false,
  "char_interact_held_time": 0.0
};
var p1_input_buffer := template_input_buffer.duplicate();
var p2_input_buffer := template_input_buffer.duplicate();

func _ready() -> void:
  Global.input_manager = self;
  setup_default_controls();
# end _ready

func _process(delta) -> void:
  process_action_state(1);
  process_action_state(2);
  
  process_input_buffer(1, delta);
  process_input_buffer(2, delta);
    
# end _ready

func setup_default_controls() -> void:
  set_joypad_axis_action(1, INPUTS.UP, JOY_AXIS_LEFT_Y, -1.0);
  set_joypad_axis_action(1, INPUTS.DOWN, JOY_AXIS_LEFT_Y, 1.0);
  set_joypad_axis_action(1, INPUTS.LEFT, JOY_AXIS_LEFT_X, -1.0);
  set_joypad_axis_action(1, INPUTS.RIGHT, JOY_AXIS_LEFT_X, 1.0);
  set_key_action(1, INPUTS.JUMP, KEY_SPACE);
  set_key_action(1, INPUTS.ATTACK, KEY_Q);
  set_key_action(1, INPUTS.INTERACT, KEY_W);
  set_key_action(1, INPUTS.PAUSE, KEY_TAB);
  set_key_action(1, INPUTS.ACCEPT, KEY_Q);
  set_key_action(1, INPUTS.CANCEL, KEY_SPACE);
  
  set_key_action(2, INPUTS.UP, KEY_UP);
  set_key_action(2, INPUTS.DOWN, KEY_DOWN);
  set_key_action(2, INPUTS.LEFT, KEY_LEFT);
  set_key_action(2, INPUTS.RIGHT, KEY_RIGHT);
  set_key_action(2, INPUTS.JUMP, KEY_SLASH);
  set_key_action(2, INPUTS.ATTACK, KEY_PERIOD);
  set_key_action(2, INPUTS.INTERACT, KEY_UP);
  set_key_action(2, INPUTS.PAUSE, KEY_ENTER);
  set_key_action(2, INPUTS.ACCEPT, KEY_PERIOD);
  set_key_action(2, INPUTS.CANCEL, KEY_SLASH);
  # end if
# end setup_default_controls

func process_action_state(player: int) -> void:
  var player_cur_action_state = p1_cur_action_state if player == 1 else p2_cur_action_state;
  var player_prev_action_state = p1_prev_action_state if player == 1 else p2_prev_action_state;
  var player_just_pressed_action_state = p1_just_pressed_action_state if player == 1 else p2_just_pressed_action_state;
  
  player_prev_action_state = player_cur_action_state;
  
  player_cur_action_state[ACTIONS.MOVE_X] = get_axis(player, INPUTS.LEFT, INPUTS.RIGHT);
  player_cur_action_state[ACTIONS.MOVE_Y] = get_axis(player, INPUTS.DOWN, INPUTS.UP);
  player_cur_action_state[ACTIONS.JUMP] = is_action_pressed(player, INPUTS.JUMP);
  player_cur_action_state[ACTIONS.ATTACK] = is_action_pressed(player, INPUTS.ATTACK);
  player_cur_action_state[ACTIONS.INTERACT] = is_action_pressed(player, INPUTS.INTERACT);
  player_cur_action_state[ACTIONS.PAUSE] = is_action_pressed(player, INPUTS.PAUSE);
  player_cur_action_state[ACTIONS.ACCEPT] = is_action_pressed(player, INPUTS.ACCEPT);
  player_cur_action_state[ACTIONS.CANCEL] = is_action_pressed(player, INPUTS.CANCEL);
  
  player_just_pressed_action_state[ACTIONS.JUMP] = is_action_pressed(player, INPUTS.JUMP) && !player_prev_action_state[ACTIONS.JUMP];
  player_just_pressed_action_state[ACTIONS.ATTACK] = is_action_pressed(player, INPUTS.ATTACK) && !player_prev_action_state[ACTIONS.ATTACK];
  player_just_pressed_action_state[ACTIONS.INTERACT] = is_action_pressed(player, INPUTS.INTERACT) && !player_prev_action_state[ACTIONS.INTERACT];
  player_just_pressed_action_state[ACTIONS.PAUSE] = is_action_pressed(player, INPUTS.PAUSE) && !player_prev_action_state[ACTIONS.PAUSE];
  player_just_pressed_action_state[ACTIONS.ACCEPT] = is_action_pressed(player, INPUTS.ACCEPT) && !player_prev_action_state[ACTIONS.ACCEPT];
  player_just_pressed_action_state[ACTIONS.CANCEL] = is_action_pressed(player, INPUTS.CANCEL) && !player_prev_action_state[ACTIONS.CANCEL];

  if player == 1:
    p1_cur_action_state = player_cur_action_state;
    p1_prev_action_state = player_prev_action_state;
    p1_just_pressed_action_state = player_just_pressed_action_state;
  else:
    p2_cur_action_state = player_cur_action_state;
    p2_prev_action_state = player_prev_action_state;
    p2_just_pressed_action_state = player_just_pressed_action_state;
# end process_action_state

func set_key_action(player: int, action: INPUTS, keycode: Key) -> void:
  var player_action_map = p1_action_map if player == 1 else p2_action_map;
  var event := InputEventKey.new();
  event.keycode = keycode;
  
  player_action_map[action] = event;
  # end if
# end add_key_action

func set_joypad_button_action(player: int, action: INPUTS, button: JoyButton, device_id: int = -1) -> void:
  var player_action_map = p1_action_map if player == 1 else p2_action_map;
  var event := InputEventJoypadButton.new();
  event.button_index = button;
  event.device = device_id;
  
  player_action_map[action] = event;
  # end if
# end add_joypad_button_action

func set_joypad_axis_action(player: int, action: INPUTS, axis: JoyAxis, axis_value: float, device_id: int = -1) -> void:
  var player_action_map = p1_action_map if player == 1 else p2_action_map;
  var event := InputEventJoypadMotion.new();
  event.axis = axis;
  event.axis_value = axis_value;
  event.device = device_id;
  
  player_action_map[action] = event;
  # end if
# end add_joypad_axis_action

func clear_action(player: int, action: INPUTS) -> void:
  var player_action_map = p1_action_map if player == 1 else p2_action_map;
  player_action_map[action] = null;
# end clear_action

func is_action_pressed(player: int, action: INPUTS) -> bool:
  var player_device = p1_device if player == 1 else p2_device;
  var player_action_map = p1_action_map if player == 1 else p2_action_map;
  
  if !player_action_map.has(action) || player_action_map[action] == null:
    return false;
  # end if
  
  var event = player_action_map[action];
  
  if event is InputEventKey && player_device.type == Enums.INPUT_SOURCES.KEYBOARD:
    return Input.is_key_pressed(event.keycode);
  elif event is InputEventJoypadButton && player_device.type == Enums.INPUT_SOURCES.CONTROLLER:
    return Input.is_joy_button_pressed(player_device.device_id, event.button_index);
  elif event is InputEventJoypadMotion && player_device.type == Enums.INPUT_SOURCES.CONTROLLER:
    var axis_val := Input.get_joy_axis(player_device.device_id, player_action_map[action].axis);
    return abs(axis_val) >= Settings.stick_deadzone;
  # end if
  
  return false;
# end is_action_pressed

func get_axis(player: int, negative_action: INPUTS, positive_action: INPUTS) -> float:
  var player_device = p1_device if player == 1 else p2_device;
  var player_action_map = p1_action_map if player == 1 else p2_action_map;
  
  if !player_action_map.has(negative_action) || !player_action_map.has(positive_action):
    return 0.0;
  # end if
  
  var neg_event = player_action_map[negative_action];
  var pos_event = player_action_map[positive_action];
  
  var neg_value = 0.0;
  var pos_value = 0.0;
  
  if neg_event is InputEventKey && player_device.type == Enums.INPUT_SOURCES.KEYBOARD:
    neg_value = -1.0 if Input.is_key_pressed(neg_event.keycode) else 0.0;
  elif neg_event is InputEventJoypadButton && player_device.type == Enums.INPUT_SOURCES.CONTROLLER:
    neg_value =  -1.0 if Input.is_joy_button_pressed(player_device.device_id, neg_event.button_index) else 0.0;
  elif neg_event is InputEventJoypadMotion && player_device.type == Enums.INPUT_SOURCES.CONTROLLER:
    var axis_val := Input.get_joy_axis(player_device.device_id, player_action_map[negative_action].axis);
    var neg_axis : InputEventJoypadMotion = neg_event;
    neg_event = axis_val if sign(axis_val) == sign(neg_axis.axis_value) && abs(axis_val) >= Settings.stick_deadzone else 0.0;
  # end if
  
  if pos_event is InputEventKey && player_device.type == Enums.INPUT_SOURCES.KEYBOARD:
    pos_value = 1.0 if Input.is_key_pressed(pos_event.keycode) else 0.0;
  elif pos_event is InputEventJoypadButton && player_device.type == Enums.INPUT_SOURCES.CONTROLLER:
    pos_value =  1.0 if Input.is_joy_button_pressed(player_device.device_id, pos_event.button_index) else 0.0;
  elif pos_event is InputEventJoypadMotion && player_device.type == Enums.INPUT_SOURCES.CONTROLLER:
    var axis_val := Input.get_joy_axis(player_device.device_id, player_action_map[negative_action].axis);
    var pos_axis : InputEventJoypadMotion = pos_event;
    pos_event = abs(axis_val) if sign(axis_val) == sign(pos_axis.axis_value) && abs(axis_val) >= Settings.stick_deadzone else 0.0;
  # end if
  
  return pos_value + neg_value;
# end get_axis

func process_input_buffer(player: int, delta: float) -> void:
  var prev_player_input_buffer = p1_input_buffer if player == 1 else p2_input_buffer;
  var player_cur_action_state = p1_cur_action_state if player == 1 else p2_cur_action_state;
  var player_just_pressed_action_state = p1_just_pressed_action_state if player == 1 else p2_just_pressed_action_state;
  
  var player_input_buffer = {
    "char_h": player_cur_action_state[ACTIONS.MOVE_X],
    "char_v": player_cur_action_state[ACTIONS.MOVE_Y],
    "char_vector": Vector2(player_cur_action_state[ACTIONS.MOVE_X], player_cur_action_state[ACTIONS.MOVE_Y]),
    
    "char_attack_pressed": player_just_pressed_action_state[ACTIONS.ATTACK],
    "char_attack_held": player_cur_action_state[ACTIONS.ATTACK],
    "char_attack_held_time": prev_player_input_buffer["char_attack_held_time"] + delta if player_cur_action_state[ACTIONS.ATTACK] else 0.0,
    
    "char_jump_pressed": player_just_pressed_action_state[ACTIONS.JUMP],
    "char_jump_held": player_cur_action_state[ACTIONS.JUMP],
    "char_jump_held_time": prev_player_input_buffer["char_jump_held_time"] + delta if player_cur_action_state[ACTIONS.JUMP] else 0.0,
    
    "char_interact_pressed": player_just_pressed_action_state[ACTIONS.INTERACT],
    "char_interact_held": player_cur_action_state[ACTIONS.INTERACT],
    "char_interact_held_time": prev_player_input_buffer["char_interact_held_time"] + delta if player_cur_action_state[ACTIONS.INTERACT] else 0.0
  };
  
  if(player == 1):
    p1_input_buffer = player_input_buffer;
  else:
    p2_input_buffer = player_input_buffer;
# end process_p1_input_buffer
