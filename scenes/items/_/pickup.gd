extends RigidBody2D
class_name Pickup

@export var health_value := 0;
@export var money_value := 0;
@export_range(0.0, 8.0, 1.0) var anim_offset := 0.0;
@export var physics_enabled := false;
@export var effect_scene: PackedScene;

func _ready() -> void:
  if(physics_enabled):
    var initial_velocity = Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, -12.0))
    apply_impulse(initial_velocity * 10.0);
  else:
    freeze = true;
  # end if
  
  
  var anim_node: AnimationPlayer = get_node("./Anim");
  if anim_node != null:
    var anim_length = anim_node.current_animation_length;
    var offset = anim_length - (anim_offset * (1.0 / 10.0));
    anim_node.seek(offset);
# end _ready

func destroy() -> void:
  if effect_scene != null:
    var new_scene = effect_scene.instantiate();
    new_scene.position = position;
    add_sibling(new_scene);
  # end if
  queue_free();
# end destroy
