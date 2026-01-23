extends Control

const color_good = Color("00d0ffff");
const color_warning = Color("ffff00ff");
const color_danger = Color("ff6f00ff");

@onready var health_bar = $Health/HealthBar

func _process(_delta: float) -> void:
  if Global.p1_char != null:
    show();
  else:
    return;
  # end
  
  # TODO: tween value with follow effect
  health_bar.value = CharStats.P1_CURRENT_HEALTH;
    
  if(health_bar.value <= 3):
    health_bar.self_modulate = color_danger;
  elif(health_bar.value <= 7):
    health_bar.self_modulate = color_warning;
  else:
    health_bar.self_modulate = color_good;
  # end if
# end _process
