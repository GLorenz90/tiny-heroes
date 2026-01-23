extends Node2D
class_name Main

const firstScene = preload("uid://btl3e5lc6dq5e")
const oneCamView = preload("uid://rsclqkvvvl0y")
const twoCamView = preload("uid://3rpiy63a7deb")

const templateInputBuffer := {
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

var p1InputBuffer := templateInputBuffer.duplicate();
var p2InputBuffer := templateInputBuffer.duplicate();

@onready var sceneParent: Node = $SceneParent;
@onready var mainView: SubViewport = $SceneParent/MainView;

#menus
@onready var mainMenu: MainMenu = $Menus/MainMenu;
@onready var optionsMenu: OptionsMenu = $Menus/OptionsMenu;
@onready var controlsMenu := $Menus/OptionsMenu;

func _init():
  Global.main = self;
# end _init

func _process(delta: float) -> void:
  process_char_inputs(delta);
# end _process

func process_char_inputs(delta) -> void:
  if(Global.p1_char != null):
    p1InputBuffer = {
      "char_h": Input.get_axis("char_left", "char_right"),
      "char_v": Input.get_axis("char_down", "char_up"),
      "char_vector": Vector2(Input.get_axis("char_left", "char_right"), Input.get_axis("char_down", "char_up")),
      "char_attack_pressed": Input.is_action_just_pressed("char_attack"),
      "char_attack_held": Input.is_action_pressed("char_attack"),
      "char_attack_held_time": p1InputBuffer["char_attack_held_time"] + delta if Input.is_action_pressed("char_attack") else 0.0,
      "char_jump_pressed": Input.is_action_just_pressed("char_jump"),
      "char_jump_held": Input.is_action_pressed("char_jump"),
      "char_jump_held_time": p1InputBuffer["char_jump_held_time"] + delta if Input.is_action_pressed("char_jump") else 0.0,
      "char_interact_pressed": Input.is_action_just_pressed("char_interact"),
      "char_interact_held": Input.is_action_pressed("char_interact"),
      "char_interact_held_time": p1InputBuffer["char_interact_held_time"] + delta if Input.is_action_pressed("char_interact") else 0.0
    };
  # end if
  if(Global.p2_char != null):
    p2InputBuffer = {
      "char_h": Input.get_axis("char_left", "char_right"),
      "char_v": Input.get_axis("char_down", "char_up"),
      "char_vector": Vector2(Input.get_axis("char_left", "char_right"), Input.get_axis("char_down", "char_up")),
      "char_attack_pressed": Input.is_action_just_pressed("char_attack"),
      "char_attack_held": Input.is_action_pressed("char_attack"),
      "char_attack_held_time": p2InputBuffer["char_attack_held_time"] + delta if Input.is_action_pressed("char_attack") else 0.0,
      "char_jump_pressed": Input.is_action_just_pressed("char_jump"),
      "char_jump_held": Input.is_action_pressed("char_jump"),
      "char_jump_held_time": p2InputBuffer["char_jump_held_time"] + delta if Input.is_action_pressed("char_jump") else 0.0,
      "char_interact_pressed": Input.is_action_just_pressed("char_interact"),
      "char_interact_held": Input.is_action_pressed("char_interact"),
      "char_interact_held_time": p2InputBuffer["char_interact_held_time"] + delta if Input.is_action_pressed("char_interact") else 0.0
    };
  # end if
# end process_inputs

func startGame() -> void:
  var newScene = firstScene.instantiate();
  mainView.add_child(newScene);
  var newView = oneCamView.instantiate();
  sceneParent.add_child(newView);
# end startGame
