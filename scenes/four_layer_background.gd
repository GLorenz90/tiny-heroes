extends Node2D
class_name FourLayerBackground

@export var still_bg: Texture2D;
@export var far_bg: Texture2D;
@export var mid_bg: Texture2D;
@export var near_bg: Texture2D;

func _ready() -> void:
  if still_bg != null:
    $StillBG/Sprite.texture = still_bg;
  if far_bg != null:
    $FarBG/Sprite.texture = far_bg;
  if mid_bg != null:
    $MidBG/Sprite.texture = mid_bg;
  if near_bg != null:
    $NearBG/Sprite.texture = near_bg;
