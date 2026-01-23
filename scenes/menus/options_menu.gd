class_name OptionsMenu
extends Control

const lerpTime := .35;

@onready var masterVolSlider: HSlider = $VBoxContainer/MasterVolume/MasterSlider;
@onready var musicVolSlider: HSlider = $VBoxContainer/MusicVolume/MusicSlider;
@onready var effectsVolSlider: HSlider = $VBoxContainer/EffectsVolume/EffectsSlider;
@onready var camSize = get_viewport_rect().size;
@onready var menuClosedPos := Vector2(self.global_position.x, 0.0);
@onready var menuWidth := self.size.x + 10.0;
@onready var menuOpenPos := Vector2(self.global_position.x - menuWidth, 0.0);

var menuTween: Tween;
var isActive = false;


func _ready() -> void:
  loadFromFile();
  updateSettingsDisplay();
# end _ready

#region FUNCTIONS ==============================================================
func loadFromFile() -> void:
  Settings.loadSettingsFile();
  updateSettingsDisplay();
# end initialize

func updateSettingsDisplay() -> void:
  effectsVolSlider.value = Settings.effectsVolume;
  musicVolSlider.value = Settings.musicVolume;
  masterVolSlider.value = Settings.masterVolume;
# end updateSettingsDisplay

func showMenu() -> void:
  show();
  isActive = true;
  updateSettingsDisplay();
  animateMenu(menuOpenPos);
# end showMenu

func hideMenu() -> void:
  isActive = false;
  animateMenu(menuClosedPos, hide);
# end closeMenu

func animateMenu(newPosition: Vector2, tweenCallback: Callable = Callable()) -> void:
  if menuTween:
    menuTween.kill();
  menuTween = create_tween();
  menuTween.tween_property(self, "position", newPosition, lerpTime).set_trans(Tween.TRANS_QUINT);
  if(tweenCallback.is_valid()):
    menuTween.tween_callback(tweenCallback);
# end start_animating
#endregion

#region SIGNALS ================================================================
func _on_btn_options_reset_pressed() -> void:
  loadFromFile();
  hideMenu();
  if(Global.main.mainMenu != null):
    Global.main.mainMenu.showMenu();
# end _on_btn_options_reset_pressed
  
func _on_btn_options_save_return_pressed() -> void:
  Settings.saveSettingsFile();
  hideMenu();
  if(Global.main.mainMenu != null):
    Global.main.mainMenu.showMenu();
# end _on_btn_options_return_pressed
#endregion

func _on_master_slider_drag_ended(value_changed: bool) -> void:
  if(value_changed):
    Settings.masterVolume = masterVolSlider.value;
    Settings.updateAudioBusses();
  # end if
# end _on_h_slider_drag_ended

func _on_music_slider_drag_ended(value_changed: bool) -> void:
  if(value_changed):
    Settings.musicVolume = musicVolSlider.value;
    Settings.updateAudioBusses();
  # end if
# end _on_h_slider_drag_ended


func _on_effects_slider_drag_ended(value_changed: bool) -> void:
  if(value_changed):
    Settings.effectsVolume = effectsVolSlider.value;
    Settings.updateAudioBusses();
  # end if
# end _on_h_slider_drag_ended
