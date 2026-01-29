extends Node2D
class_name Level

@export var music: AudioStream;

@export_group("Background")
@export var still_bg: Texture2D;
@export var far_bg: Texture2D;
@export var mid_bg: Texture2D;
@export var near_bg: Texture2D;

var background_scene = preload("uid://be6sw31moxdax");

func _ready():
  if music != null:
    Global.music_manager.change_music(music);
  # end if
  
  if (still_bg != null || far_bg != null || mid_bg != null || near_bg != null):
    if Global.p1_cam != null:
      var new_background: FourLayerBackground = background_scene.instantiate();
      new_background.position = Vector2.ZERO;
      if still_bg != null:
        new_background.still_bg = still_bg;
      if far_bg != null:
        new_background.far_bg = far_bg;
      if mid_bg != null:
        new_background.mid_bg = mid_bg;
      if near_bg != null:
        new_background.near_bg = near_bg;
      
      Global.p1_cam.add_sibling(new_background);
    # end if
    
    if Global.p2_cam != null:
      var new_background: FourLayerBackground = background_scene.instantiate();
      new_background.position = Vector2.ZERO;
      if still_bg != null:
        new_background.still_bg = still_bg;
      if far_bg != null:
        new_background.far_bg = far_bg;
      if mid_bg != null:
        new_background.mid_bg = mid_bg;
      if near_bg != null:
        new_background.near_bg = near_bg;
      
      Global.p2_cam.add_sibling(new_background);
    # end if
  # end if
# end _ready
