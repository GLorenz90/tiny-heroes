extends Node

const distThreshold = 20.0;

var isViewSet = false;

#outside view
@onready var viewMain: SubViewport = Global.main.mainView;

#inside view
@onready var cam1: Camera2D = $"../SubViewportContainer/SubViewport/P1Cam";
@onready var view: SubViewport = $"../SubViewportContainer/SubViewport";
#@onready var camTarget: Node2D = Global.p1_char;

func _process(_delta: float) -> void:
  if(Global.main.mainView != null && !isViewSet):
    viewMain = Global.main.mainView;
    view.world_2d = viewMain.world_2d;
    isViewSet = true;
    
  if(Global.p1_char != null):
    cam1.global_position = Global.p1_char.global_position;
