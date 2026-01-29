extends Node

const distThreshold = 20.0;

var isViewSet = false;

#inside view
@onready var cam1: Camera2D = $"../SubViewportContainer/SubViewport/P1Cam";
@onready var view: SubViewport = $"../SubViewportContainer/SubViewport";

func _ready() -> void:
  Global.p1_cam = cam1;

func _process(_delta: float) -> void:
  if(Global.main.main_view != null && !isViewSet):
    view.world_2d = Global.main.main_view.world_2d;
    isViewSet = true;
    
  if(Global.p1_char != null):
    cam1.global_position = Global.p1_char.global_position;
    cam1.global_position.y -= 64;
