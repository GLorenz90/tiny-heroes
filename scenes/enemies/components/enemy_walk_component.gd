extends Node2D
class_name EnemyWalkComponent

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

@export var move_speed := 40.0;
@export var turn_at_edge := true;
@export var idle_animation := "idle";
@export var move_animation := "moving";
@export var animationPlayer: AnimationPlayer;
@export var left_edge_raycast: RayCast2D;
@export var right_edge_raycast: RayCast2D;
@export var wall_shapecast: ShapeCast2D;
@export var facing_right := true;

@onready var parent: Enemy = self.get_parent();
var ledge_cleared := false;

func _ready() -> void:
  if(animationPlayer != null):
    animationPlayer.play(move_animation);
  # end if
# end _ready

func _physics_process(delta: float) -> void:  
  if(!ledge_cleared \
    && right_edge_raycast.is_colliding() \
    && left_edge_raycast.is_colliding() \
    && !wall_shapecast.is_colliding()
  ):
    ledge_cleared = true;
  # end if
  
  if(parent.is_on_floor() && ledge_cleared && 
    ((parent.scale.x > 0 && !right_edge_raycast.is_colliding()) \
      || (parent.scale.x < 0 && !left_edge_raycast.is_colliding()) \
      || wall_shapecast.is_colliding()
    )
  ):
    facing_right = !facing_right;
    parent.scale.x *= -1;
    ledge_cleared = false;
  # end if
  
  if (!parent.is_on_floor()):
    parent.velocity.y = clamp(parent.velocity.y + (gravity * delta * 2), -Global.MAX_VELOCITY, Global.MAX_VELOCITY)
  else:
    parent.velocity.y = 0;
  # end if
  
  parent.velocity.x = (1 if facing_right else -1) * move_speed;
  parent.move_and_slide();
# end _physics_process
