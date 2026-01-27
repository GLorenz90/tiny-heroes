extends Node2D
class_name Main

const firstScene = preload("uid://btl3e5lc6dq5e");
const oneCamView = preload("uid://rsclqkvvvl0y");
const twoCamView = preload("uid://3rpiy63a7deb");

@onready var sceneParent: Node = $SceneParent;
@onready var mainView: SubViewport = $SceneParent/MainView;

#menus
@onready var mainMenu: MainMenu = $Menus/MainMenu;
@onready var optionsMenu: OptionsMenu = $Menus/OptionsMenu;
@onready var controlsMenu := $Menus/OptionsMenu;

func _init():
  Global.main = self;
# end _init

func _ready():
  Global.debug_label = $DebugLabel;
# end _ready

func startGame() -> void:
  var newView = oneCamView.instantiate();
  sceneParent.add_child(newView);
  var newScene = firstScene.instantiate();
  mainView.add_child(newScene);
  $HUD.show();
# end startGame
