extends RigidBody2D
class_name Pickup
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

@export var health_value = 0;
@export var money_value = 0;
@export var lives_value = 0;
