extends Node2D

var heart_scene = preload("uid://b1w3lmnclmned");
@export var is_p1 := true;
var spacing: int = 15;
var cur_health := 0;
var max_health := CharStats.TOTAL_MAX_HEALTH;

func _process(_delta: float) -> void:
  cur_health = CharStats.P1_CURRENT_HEALTH if is_p1 else CharStats.P2_CURRENT_HEALTH;
  for heart in get_children():
    heart.queue_free();
  # end for
  
  var num_hearts = ceili(max_health / 2.0);
  
  for i in range(num_hearts):
    var heart = heart_scene.instantiate();
    heart.position.x = i * spacing;
    if i >= 6:
      heart.position.y = spacing;
      heart.position.x -= spacing * 6;
    # end if
    
    # Determine which frame to show based on remaining health
    var health_for_this_heart = cur_health - (i * 2)
    
    if health_for_this_heart >= 2:
      heart.frame = 0 ; # Full heart
    elif health_for_this_heart == 1:
      heart.frame = 1;  # Half heart
    else:
      heart.frame = 2;  # Empty heart
    # end if
    
    add_child(heart);
  # end for
# end _process
