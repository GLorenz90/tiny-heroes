class_name MainMenu
extends Control

@onready var startButton := $MenuContainer/VBoxContainer/btnStartGame;
@onready var optionsButton := $MenuContainer/VBoxContainer/btnOptions;
@onready var quitButton := $MenuContainer/VBoxContainer/btnQuitGame;

var isActive = true;

func toggleActive() -> void:
  isActive = !isActive;
  startButton.disabled = !isActive;
  optionsButton.disabled = !isActive;
  quitButton.disabled = !isActive;
  
  if(isActive):
    $MenuContainer.modulate.a = 1.0;
  else:
    $MenuContainer.modulate.a = .5;
  #endif
#end toggleActive

func showMenu() -> void:
  toggleActive();
#end showMenu

func removeMenu() -> void:
  Global.main.main_menu = null;
  get_parent().remove_child(self);
  queue_free();
#end showMenu

func _on_btn_start_game_pressed() -> void:
  removeMenu();
  Global.main.start_game();
# end _on_btn_start_game_pressed

func _on_btn_options_pressed() -> void:
  toggleActive();
  Global.main.options_menu.showMenu();
#end _on_btn_options_pressed

func _on_btn_quit_game_pressed() -> void:
  get_tree().quit();
# end _on_btn_quit_game_pressed
