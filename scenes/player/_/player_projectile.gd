extends Node2D
class_name PlayerProjectile

@export var animation: Enums.ATTACK_STATES;

func _on_anim_animation_finished(_anim_name: StringName) -> void:
  queue_free();
# end _on_anim_animation_finished
