extends Node2D
class_name Main

const first_level = preload("uid://btl3e5lc6dq5e");
const one_cam_view = preload("uid://rsclqkvvvl0y");
const two_cam_view = preload("uid://3rpiy63a7deb");

@onready var scene_parent: Node = $SceneParent;
@onready var main_view: SubViewport = $SceneParent/MainView;
@onready var main_menu: MainMenu = $Menus/MainMenu;
@onready var options_menu: OptionsMenu = $Menus/OptionsMenu;

func _init():
  Global.main = self;
# end _init

func _ready():
  Global.debug_label = $DebugLabel;
# end _ready

func start_game() -> void:
  var new_view = one_cam_view.instantiate();
  scene_parent.add_child(new_view);
  
  var new_scene = first_level.instantiate();
  main_view.add_child(new_scene);
  
  $HUD.show();
# end start_game
