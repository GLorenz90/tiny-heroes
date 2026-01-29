extends Node

const distThreshold = 20.0;

var isP1LeftOfP2 := true;
var didModeChange := false;
var numPlayersInArea := 0;
var prevNumPlayersInArea := 0;
var avgX = Vector2(0.0, 0.0);
var avgY = Vector2(0.0, 0.0);
var cam1DistToTarget := 0.0;
var cam2DistToTarget := 0.0;
var cam1TargetBeyondLimit := false;
var cam2TargetBeyondLimit := false;
var isViewSet = false;

#inside view
@onready var cam1: Camera2D = $"../HBoxContainer/SubViewportContainer/SubViewport/P1Cam";
@onready var cam2: Camera2D = $"../HBoxContainer/SubViewportContainer2/SubViewport/P2Cam";
@onready var view1: SubViewport = $"../HBoxContainer/SubViewportContainer/SubViewport";
@onready var view2: SubViewport = $"../HBoxContainer/SubViewportContainer2/SubViewport";
@onready var leftTarget: Node2D = $leftCamTarget;
@onready var rightTarget: Node2D = $rightCamTarget;
@onready var camTarget1: Node2D = Global.p1_char;
@onready var camTarget2: Node2D  = Global.p2_char;
@onready var seperatorBar: ColorRect = $"../Bar";
@onready var viewportHeight: int = view1.size.y;
@onready var viewportWidth: int = view1.size.x;

func _ready() -> void:
  Global.p1_cam = cam1;
  Global.p2_cam = cam2;
  
func _process(_delta: float) -> void:
  if(Global.main.scene_parent != null && !isViewSet):
    view1.world_2d = Global.main.main_view.world_2d;
    view2.world_2d = Global.main.main_view.world_2d;
    isViewSet = true;
    
  if(isViewSet && Global.p1_char != null && Global.p2_char != null):
    camTarget1 = Global.p1_char;
    camTarget2 = Global.p2_char;
    
    prevNumPlayersInArea = numPlayersInArea;
    
    getnumPlayersInAreaInArea();
    didModeChange = (numPlayersInArea != prevNumPlayersInArea) && (numPlayersInArea == 0 || numPlayersInArea == 2)
    
    avgX = (Global.p1_char.global_position.x + Global.p2_char.global_position.x)/2
    avgY = (Global.p1_char.global_position.y + Global.p2_char.global_position.y)/2
    self.global_position = Vector2(avgX, avgY);
    
    if(didModeChange):
      changeMode();
    #end
    
    cam1.global_position = camTarget1.global_position;
    cam1.global_position.y -= 64;
    cam2.global_position = camTarget2.global_position;
    cam2.global_position.y -= 64;
    
    cam1DistToTarget = abs(camTarget1.global_position.y - cam1.get_screen_center_position().y);
    cam2DistToTarget = abs(camTarget2.global_position.y - cam2.get_screen_center_position().y);
    
    # detect cam at limits
    cam1TargetBeyondLimit = camTarget1.global_position.y > cam1.limit_bottom - (viewportHeight/2.0) || camTarget1.global_position.y < (viewportHeight/2.0);
    cam2TargetBeyondLimit = camTarget2.global_position.y > cam2.limit_bottom - (viewportHeight/2.0) || camTarget2.global_position.y < (viewportHeight/2.0);
    
    if((cam1DistToTarget < distThreshold) || cam1TargetBeyondLimit):
      cam1.position_smoothing_enabled = false;
      if(numPlayersInArea == 2):
        seperatorBar.hide();
      #end
    #end
    if((cam2DistToTarget < distThreshold) || cam2TargetBeyondLimit):
      cam2.position_smoothing_enabled = false;
    #end
  #end
#end

func changeMode() -> void:
  if(numPlayersInArea == 2):
    cam1.position_smoothing_enabled = true;
    cam2.position_smoothing_enabled = true;
    
    cam1.limit_left = 0;
    cam2.limit_left = viewportWidth;
  # TODO: make the limits a variable that each level sets on load.
    cam1.limit_right = 1536 - viewportWidth;
    cam2.limit_right = 1536;
    
    camTarget1 = leftTarget;
    camTarget2 = rightTarget;
  else:
    seperatorBar.show();
    cam1.position_smoothing_enabled = true;
    cam2.position_smoothing_enabled = true;
    
    cam1.limit_left = 0;
    cam2.limit_left = 0;
  # TODO: make the limits a variable that each level sets on load.
    cam1.limit_right = 1536;
    cam2.limit_right = 1536;
    
    if(Global.p1_char.global_position.x < Global.p2_char.global_position.x):
      camTarget1 = Global.p1_char;
      camTarget2 = Global.p2_char;
    else:
      camTarget1 = Global.p2_char;
      camTarget2 = Global.p1_char;
    #end
  #end
#end

func getnumPlayersInAreaInArea() -> void:
  numPlayersInArea = $Area2D.get_overlapping_bodies().size();
#end
