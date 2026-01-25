extends CharacterBody2D
class_name Enemy

@export var max_health := 1;
@export var drops_items := true;
@export var death_scene: PackedScene;
@export_range(-1.0, 15.0, 1.0) var anim_offset := -1.0;

const small_health_scene = preload("uid://c6m41xim54vit");
const coin_small_scene = preload("uid://c14hu5qjmeqh1");
const coin_large_scene = preload("uid://co82xg601lhq6");

var cur_health := max_health:
  set(value):
    cur_health = clamp(value, 0, max_health);
    
func _ready() -> void:
  if(anim_offset == -1.0):
    anim_offset = randi_range(0, 14);
  var anim_length = $Anim.current_animation_length;
  var offset = anim_length - (anim_offset * (1.0 / 10.0));
  $Anim.seek(offset);
# end _ready
    
func take_damage(damage: int) -> void:
  cur_health -= damage;
  if(cur_health == 0):
    explode();
# end take_damage

func explode():
  if death_scene != null:
    var new_effect_scene = death_scene.instantiate();
    new_effect_scene.position = round(position);
    add_sibling(new_effect_scene);
  # end if
    
  if drops_items:
    var rand_roll = randi_range(1, 100);
    if(rand_roll == 100):
      create_item(coin_large_scene); # 1%: 99 - 94
    elif(rand_roll >= 94):
      create_item(coin_small_scene); # 5%: 99 - 94
    elif(rand_roll >= 73):
      create_item(small_health_scene); # 20%: 93 - 73
    # end if
  # end if
  queue_free();
# end explode

func create_item(scene: PackedScene):
  var new_scene: Pickup = scene.instantiate();
  new_scene.position = round(position);
  new_scene.physics_enabled = true;
  call_deferred("add_sibling", new_scene);
# end create_item

func _on_interaction_area_area_entered(area: Area2D) -> void:
  if(area is DamageArea):
    var damage_area: DamageArea = area;
    take_damage(damage_area.damage);
  # end if
# end _on_interaction_area_area_entered
