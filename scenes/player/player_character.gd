extends CharacterBody2D
class_name PlayerCharacter

#region CONSTANT VARIABLES =========================================================================
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");
const LERP_SPEED = 10.0;
const MAX_ATTACK_STEP = 3;
const owlet_sprites = preload("uid://cedyrtuag5yu");
const bunny_sprites = preload("uid://qbycopj8sitg");
const seal_sprites = preload("uid://db6y45q0b7kde");

var jump_dust_scene: PackedScene = preload("uid://dmufl1i2pnrvo");

var attack_punch_1_scene = preload("uid://c16k38eecuo8b");
var attack_punch_2_scene = preload("uid://cirjrpfjm6q05")
#endregion

#region COMPUTED VARIABLES =========================================================================
@export var is_p1 := true;
var input_data := Global.input_manager.template_input_buffer;

var coyote_time_remaining = CharStats.MAX_COYOTE_TIME;

var movement_state: Enums.MOVEMENT_STATES = Enums.MOVEMENT_STATES.IDLE;
var next_movement_state: Enums.MOVEMENT_STATES = Enums.MOVEMENT_STATES.IDLE;
var movement_state_position: Enums.STATE_POSITIONS = Enums.STATE_POSITIONS.CHANGE;

var attack_state: Enums.ATTACK_STATES = Enums.ATTACK_STATES.NONE;
var next_attack_state: Enums.ATTACK_STATES = Enums.ATTACK_STATES.NONE;
var attack_state_position: Enums.STATE_POSITIONS = Enums.STATE_POSITIONS.CHANGE;

var last_collision = null;
var last_collision_direction := 0.0;
var is_input_toward_wall := false;
var is_in_damage_area := false;
var was_in_air := false;

@onready var last_safe_pos := global_position;
#endregion

#region BUILT IN FUNCTIONS =========================================================================
func _ready() -> void:
  if(is_p1):
    Global.p1_char = self;
    
    match(Global.p1_char_display):
      Enums.CHARS.OWLET:
        $Sprite/Sprites.texture = owlet_sprites;
      Enums.CHARS.BUNNY:
        $Sprite/Sprites.texture = bunny_sprites;
      Enums.CHARS.SEAL:
        $Sprite/Sprites.texture = seal_sprites;
    # end match
  else:
    Global.p2_char = self;
    
    match(Global.p2_char_display):
      Enums.CHARS.OWLET:
        $Sprite/Sprites.texture = owlet_sprites;
      Enums.CHARS.BUNNY:
        $Sprite/Sprites.texture = bunny_sprites;
      Enums.CHARS.SEAL:
        $Sprite/Sprites.texture = seal_sprites;
    # end match
  # end if

  $DashTimer.wait_time = CharStats.TOTAL_ROLL_TIME;
  $JumpTimer.wait_time = CharStats.TOTAL_JUMP_TIME;

  $HurtTimer.wait_time = CharStats.HURT_TIME;
  $InputDelayTimer.wait_time = CharStats.HURT_TIME;
  $InvulnTimer.wait_time = CharStats.INVULN_TIME;
# end _init

func _physics_process(delta: float) -> void:
  #set_debug_text();
  if(!is_on_floor() && coyote_time_remaining > 0.0):
    coyote_time_remaining = max(0.0, coyote_time_remaining - delta);
  # end if
  
  set_input_data();
  update_collision_direction();
  update_input_toward_wall();
  
  check_is_in_damage_area();
  process_movement_state(delta);
  if(!$AttackTimer.is_stopped()):
    process_attack_state(delta);
    
  update_sprite();
  move_and_slide();
  
  check_safe_pos();
  check_landing();
  was_in_air = !is_on_floor();
  # prevent blur when standing still.
  if(velocity.x == 0.0 && velocity.y == 0.0):
    global_position = round(self.global_position);
# end _physics_process
#endregion

#region RUNNING FUNCTIONS ==========================================================================
func set_input_data() -> void:
  input_data = Global.input_manager.p1_input_buffer if is_p1 else Global.input_manager.p2_input_buffer;
# end set_input_data

func check_safe_pos() -> void:
  if is_on_floor() \
    && !is_in_damage_area \
    && $SafeGround/RayCast2D.is_colliding() \
    && $SafeGround/RayCast2D2.is_colliding():
    last_safe_pos = global_position;
  # end if
# end check_safe_pos

func check_is_in_damage_area() -> void:
  is_in_damage_area = false;
  if $InteractionArea.get_overlapping_areas().size() > 0:
    for area: Area2D in $InteractionArea.get_overlapping_areas():
      if(area is DamageArea):
        is_in_damage_area = true;
        if($InvulnTimer.is_stopped()):
          take_damage(area);
        # end if
    
        if(area.resets_position):
          #TODO: camera lerp
          global_position = last_safe_pos;
          velocity = Vector2.ZERO;
        # end if
        
        break;
      # end if
    # end for
  # end if
# end check_is_in_damage_area

func take_damage(area: DamageArea) -> void:
  if is_p1:
    CharStats.P1_CURRENT_HEALTH -= area.damage;
    # TODO: death check
  else:
    CharStats.P2_CURRENT_HEALTH -= area.damage;
    # TODO: death check
  # end if
  
  # knockback
  velocity.x = CharStats.BASE_HURT_VELOCITY * $Sprite.scale.x * -1.0;
  velocity.y = CharStats.BASE_HURT_VELOCITY * -1;
  
  change_movement_state(Enums.MOVEMENT_STATES.HURT);
# end take_damage

func check_landing():
  if was_in_air && is_on_floor():
    create_movement_effect(jump_dust_scene, $EffectAreas/Ground.global_position);
  # end if
# end check_landing
#endregion

#region MOVEMENT STATE FUNCTIONS ===================================================================
func process_movement_state(delta) -> void:
  match(movement_state_position):
    Enums.STATE_POSITIONS.CHANGE:
      process_movement_ending_state(delta);
      movement_state = next_movement_state;
      process_movement_starting_state(delta);
      process_movement_running_state(delta);
      change_movement_state_position(Enums.STATE_POSITIONS.RUN);
    Enums.STATE_POSITIONS.RUN:
      process_movement_running_state(delta);
  # end match
#end process_movement_state

func process_movement_starting_state(delta) -> void:
  match(movement_state):
    Enums.MOVEMENT_STATES.INIT:
      start_movement_init_state(delta);
    Enums.MOVEMENT_STATES.IDLE:
      start_movement_idle_state(delta);
    Enums.MOVEMENT_STATES.RUNNING:
      start_movement_running_state(delta);
    Enums.MOVEMENT_STATES.JUMPING:
      start_movement_jumping_state(delta);
    Enums.MOVEMENT_STATES.FALLING:
      start_movement_falling_state(delta);
    Enums.MOVEMENT_STATES.CROUCHING:
      pass;
    Enums.MOVEMENT_STATES.ROLLING:
      pass;
    Enums.MOVEMENT_STATES.LADDER:
      pass;
    Enums.MOVEMENT_STATES.HURT:
      start_movement_hurt_state(delta);
  #end match
# end process_movement_starting_state

func process_movement_running_state(delta) -> void:
  match(movement_state):
    Enums.MOVEMENT_STATES.INIT:
      run_movement_init_state(delta);
    Enums.MOVEMENT_STATES.IDLE:
      run_movement_idle_state(delta);
    Enums.MOVEMENT_STATES.RUNNING:
      run_movement_running_state(delta);
    Enums.MOVEMENT_STATES.JUMPING:
      run_movement_jumping_state(delta);
    Enums.MOVEMENT_STATES.FALLING:
      run_movement_falling_state(delta);
    Enums.MOVEMENT_STATES.CROUCHING:
      pass;
    Enums.MOVEMENT_STATES.ROLLING:
      pass;
    Enums.MOVEMENT_STATES.LADDER:
      pass;
    Enums.MOVEMENT_STATES.HURT:
      run_movement_hurt_state(delta);
  #end match
# end process_movement_starting_state

func process_movement_ending_state(delta) -> void:
  match(movement_state):
    Enums.MOVEMENT_STATES.INIT:
      end_movement_init_state(delta);
    Enums.MOVEMENT_STATES.IDLE:
      end_movement_idle_state(delta);
    Enums.MOVEMENT_STATES.RUNNING:
      end_movement_running_state(delta);
    Enums.MOVEMENT_STATES.JUMPING:
      end_movement_jumping_state(delta);
    Enums.MOVEMENT_STATES.FALLING:
      end_movement_falling_state(delta);
    Enums.MOVEMENT_STATES.CROUCHING:
      pass;
    Enums.MOVEMENT_STATES.ROLLING:
      pass;
    Enums.MOVEMENT_STATES.LADDER:
      pass;
    Enums.MOVEMENT_STATES.HURT:
      end_movement_hurt_state(delta);
  #end match
# end process_movement_starting_state

func change_movement_state(newState: Enums.MOVEMENT_STATES):
  next_movement_state = newState;
  change_movement_state_position(Enums.STATE_POSITIONS.CHANGE);
  # end if
# end changeState

func change_movement_state_position(new_movement_state_position: Enums.STATE_POSITIONS):
  if(movement_state_position != new_movement_state_position):
    movement_state_position = new_movement_state_position;
  # end if
# end change_movement_state_position
#endregion

#region STARTING MOVEMENT STATE FUNCTIONS ==========================================================
func start_movement_init_state(_delta) -> void:
  pass;
# end start_movement_init_state

func start_movement_idle_state(_delta) -> void:
  pass;
# end start_movement_idle_state

func start_movement_running_state(delta) -> void:
  update_horizontal_velocity(delta);
# end start_movement_running_state

func start_movement_jumping_state(delta) -> void:
  $JumpTimer.start();
  update_vertical_velocity(delta);
  input_data["char_jump_held_time"] = CharStats.MAX_INPUT_BUFFER_TIME + .1; #prevent double jump from wall buffer
  coyote_time_remaining = 0.0;
  stop_attacking(true);
  if is_on_floor():
    create_movement_effect(jump_dust_scene, $EffectAreas/Ground.global_position);
# end start_movement_jumping_state

func start_movement_falling_state(delta) -> void:
  update_vertical_velocity(delta);
# end start_movement_falling_state

func start_movement_hurt_state(_delta) -> void:
  $HurtTimer.start();
  $InputDelayTimer.start();
  $InvulnTimer.start();
  reset_jump_flags();
  stop_attacking(true);
# end start_movement_hurt_state
#endregion

#region RUNNING MOVEMENT STATE FUNCTIONS ===========================================================
func run_movement_init_state(_delta) -> void:
  #TODO: Intro animation
  change_movement_state(Enums.MOVEMENT_STATES.IDLE);
# end run_movement_init_state

func run_movement_idle_state(delta) -> void:
  if(is_attack_buffered()):
    start_attacking();
  elif(is_jump_buffered()):
    change_movement_state(Enums.MOVEMENT_STATES.JUMPING);
  elif(!is_on_floor()):
    change_movement_state(Enums.MOVEMENT_STATES.FALLING);
  elif(is_attempting_run(delta)):
    change_movement_state(Enums.MOVEMENT_STATES.RUNNING);
  else:
    update_horizontal_velocity(delta);
    update_vertical_velocity(delta);
  # end if
# end run_movement_init_state

func run_movement_running_state(delta) -> void:
  if(is_attack_buffered()):
    start_attacking();

  if(is_jump_buffered()):
    change_movement_state(Enums.MOVEMENT_STATES.JUMPING);
  elif(!is_on_floor()):
    change_movement_state(Enums.MOVEMENT_STATES.FALLING);
  elif(velocity.x == 0.0 || is_on_wall()):
    change_movement_state(Enums.MOVEMENT_STATES.IDLE);
  else:
    update_horizontal_velocity(delta);
    update_vertical_velocity(delta);
  # end if
# end run_movement_running_state

func run_movement_jumping_state(delta) -> void:
  if(is_attack_buffered()):
    start_attacking();

  #if still or moving down
  if(velocity.y >= 0.0):
    if(is_on_floor()):
      change_movement_state(Enums.MOVEMENT_STATES.IDLE);
    else:
      change_movement_state(Enums.MOVEMENT_STATES.FALLING);
  elif(is_jump_buffered()):
    change_movement_state(Enums.MOVEMENT_STATES.JUMPING);
  else: # run the state
    update_horizontal_velocity(delta);
    update_vertical_velocity(delta);
  # end if
# end run_movement_init_state

func run_movement_falling_state(delta) -> void:
  if(is_attack_buffered()):
    start_attacking();

  if(is_jump_buffered()):
    change_movement_state(Enums.MOVEMENT_STATES.JUMPING);
  elif(is_on_floor()):
    change_movement_state(Enums.MOVEMENT_STATES.IDLE);
  else:
    update_horizontal_velocity(delta);
    update_vertical_velocity(delta);
  # end if
# end run_movement_falling_state

func run_movement_hurt_state(delta) -> void:
  update_horizontal_velocity(delta);
  update_vertical_velocity(delta);
# end run_movement_hurt_state
#endregion

#region ENDING MOVEMENT STATE FUNCTIONS ============================================================
func end_movement_init_state(_delta) -> void:
  pass;
# end end_movement_init_state

func end_movement_idle_state(_delta) -> void:
  pass;
# end end_movement_idle_state

func end_movement_running_state(_delta) -> void:
  pass;
# end end_movement_running_state

func end_movement_jumping_state(_delta) -> void:
  $JumpTimer.stop();
  # end if
# end end_movement_jumping_state

func end_movement_falling_state(_delta) -> void:
  if(is_on_wall() || is_on_floor()):
    reset_jump_flags();
  # end if
# end end_movement_falling_state

func end_movement_hurt_state(_delta) -> void: 
  pass;
# end run_movement_hurt_state
#endregion

#region MOVEMENT UTILITY FUNCTIONS =================================================================
func update_horizontal_velocity(delta) -> void:
  if($InputDelayTimer.is_stopped() && input_data["char_h"]):
    velocity.x = move_toward(velocity.x, input_data["char_h"] * CharStats.TOTAL_WALK_SPEED, CharStats.TOTAL_WALK_SPEED * delta * LERP_SPEED);
  else:
    velocity.x = move_toward(velocity.x, 0, CharStats.TOTAL_WALK_SPEED * delta * (LERP_SPEED if is_on_floor() else 1.0));
  #end if
# end updateVelocity

func update_vertical_velocity(delta) -> void:
  if(movement_state == Enums.MOVEMENT_STATES.JUMPING && input_data["char_jump_held"] && !$JumpTimer.is_stopped()):
    velocity.y = CharStats.TOTAL_JUMP_VELOCITY * -1;
  elif (!is_on_floor() || (movement_state == Enums.MOVEMENT_STATES.HURT && velocity.y < 0)):
    velocity.y = clamp(velocity.y + (gravity * delta * 2), -CharStats.MAX_VELOCITY, CharStats.MAX_VELOCITY)
  else:
    velocity.y = 0;
  #end if
# end update_vertical_velocity

func can_jump() -> bool:
  return $InputDelayTimer.is_stopped() && (is_on_floor() || coyote_time_remaining > 0.0);
# end can_jump

func is_jump_buffered() -> bool:
  return can_jump() && (input_data["char_jump_pressed"] || (input_data["char_jump_held"] && input_data["char_jump_held_time"] <= CharStats.MAX_INPUT_BUFFER_TIME));
# end is_jump_buffered

func is_attempting_run(delta) -> bool:
  update_horizontal_velocity(delta);
  return $InputDelayTimer.is_stopped() && (input_data["char_h"] != 0.0) && is_on_floor() && !is_input_toward_wall && !test_move(global_transform, velocity * delta);
# end is_attempting_run

func update_collision_direction() -> void:
  last_collision = get_last_slide_collision();
  if(is_on_wall()):
    last_collision_direction = sign(last_collision.get_position().x - global_position.x);
  else:
    last_collision_direction = 0;
  # end if
# end update_collision_direction

func update_input_toward_wall() -> void:
  is_input_toward_wall = last_collision_direction != 0 && input_data["char_h"] != 0.0 && last_collision_direction == sign(input_data["char_h"]);
  # end if
# end update_input_toward_wall

func reset_jump_flags() -> void:
  stop_attacking(true);
  coyote_time_remaining = CharStats.MAX_COYOTE_TIME;
# end reset_jump_flags

func create_movement_effect(scene: PackedScene, location: Vector2):
  var new_scene = scene.instantiate();
  new_scene.position = round(location);
  new_scene.scale.x *= $Sprite.scale.x;
  add_sibling(new_scene);
# end create_movement_effect
#endregion

#region ATTACK UTILITY FUNCTIONS ================================================================
func process_attack_state(_delta) -> void:
  pass;
# end process_attack_state

func start_attacking() -> void:
  match(movement_state):
    Enums.MOVEMENT_STATES.IDLE, \
    Enums.MOVEMENT_STATES.JUMPING, \
    Enums.MOVEMENT_STATES.FALLING, \
    Enums.MOVEMENT_STATES.RUNNING:
      handle_standing_attack_combo();
    Enums.MOVEMENT_STATES.INIT:
      pass;
  #end match
  $AttackTimer.wait_time = CharStats.ATTACK_TIMING[attack_state];
  $AttackDelayTimer.wait_time = CharStats.ATTACK_DELAY_TIMING[attack_state];
  $AttackTimer.start();
  $AttackDelayTimer.start();
  input_data["char_attack_held_time"] = CharStats.MAX_INPUT_BUFFER_TIME + .1; #prevent double jump from wall buffer
# end start_attacking

func handle_standing_attack_combo() -> void:
  match(attack_state):
    Enums.ATTACK_STATES.NONE, \
    Enums.ATTACK_STATES.PUNCH_2:
      attack_state = Enums.ATTACK_STATES.PUNCH_1;
      create_attack_effect(attack_punch_1_scene, $ProjectileAreas/Punch.position);
    Enums.ATTACK_STATES.PUNCH_1:
      attack_state = Enums.ATTACK_STATES.PUNCH_2;
      create_attack_effect(attack_punch_2_scene, $ProjectileAreas/Punch2.position, 1);
  # end match
  set_sprite_facing(true);
# end handle_standing_attack_combo

func create_attack_effect(scene: PackedScene, location: Vector2, new_z: int = 0):
  var new_scene = scene.instantiate();
  new_scene.position = location;
  new_scene.position.x *= $Sprite.scale.x;
  new_scene.scale.x *= $Sprite.scale.x;
  new_scene.z_index = new_z;
  add_child(new_scene);
# end create_attack_effect

func stop_attacking(stopDelay: bool = false) -> void:
  $AttackTimer.stop();
  if(stopDelay):
    $AttackDelayTimer.stop();
  attack_state = Enums.ATTACK_STATES.NONE;
# end stop_attacking

func is_attack_buffered() -> bool:
  return $InputDelayTimer.is_stopped() && $AttackDelayTimer.is_stopped() && (input_data["char_attack_pressed"] || (input_data["char_attack_held"] && input_data["char_attack_held_time"] <= CharStats.MAX_INPUT_BUFFER_TIME))
# end is_attack_buffered
#endregion

#region SPRITE FUNCTIONS ===========================================================================
func set_sprite_facing(ignore_timer: bool = false) -> void:
  if((ignore_timer || $AttackTimer.is_stopped()) && $HurtTimer.is_stopped()):
    if velocity.x > 0:
      $Sprite.scale.x = 1;
    elif velocity.x < 0:
      $Sprite.scale.x = -1;
    elif velocity.x == 0 && input_data["char_h"] != 0:
      $Sprite.scale.x = roundi(input_data["char_h"]);
    # end if
  # end if
  
  $EffectAreas.scale.x = $Sprite.scale.x;
# end set_sprite_facing

func update_sprite() -> void:
  set_sprite_facing();

  if(!$InvulnTimer.is_stopped()):
    $Sprite.modulate.a = .5;
  else:
    $Sprite.modulate.a = 1.0;
  # end if

  if(!$HurtTimer.is_stopped()):
    $Sprite/Anim.play("hurt");
  elif(!$AttackTimer.is_stopped() && attack_state != Enums.ATTACK_STATES.NONE):
    match(attack_state):
      Enums.ATTACK_STATES.PUNCH_1:
         $Sprite/Anim.play("punch_1");
      Enums.ATTACK_STATES.PUNCH_2:
         $Sprite/Anim.play("punch_2");
    # end match
  else:
    match(movement_state):
      Enums.MOVEMENT_STATES.INIT:
        $Sprite/Anim.play("idle");
      Enums.MOVEMENT_STATES.IDLE:
        $Sprite/Anim.play("idle");
      Enums.MOVEMENT_STATES.RUNNING:
        $Sprite/Anim.play("running");
      Enums.MOVEMENT_STATES.JUMPING:
        $Sprite/Anim.play("jumping");
      Enums.MOVEMENT_STATES.FALLING:
        if $Sprite/Anim.get_assigned_animation() != "falling":
          $Sprite/Anim.play("falling");
    #end match
# end update_sprite
#endregion

#region SIGNALS ====================================================================================
func _on_attack_timer_timeout() -> void:
  stop_attacking();
# end _on_attack_timer_timeout

func _on_hurt_timer_timeout() -> void:
  change_movement_state(Enums.MOVEMENT_STATES.IDLE);
# end _on_hurt_timer_timeout

func _on_interaction_area_body_entered(body: Node2D) -> void:
  if (body is Pickup):
    var pickup: Pickup = body;
    if(body.health_value > 0):
      if is_p1 && CharStats.P1_CURRENT_HEALTH < CharStats.TOTAL_MAX_HEALTH:
        CharStats.P1_CURRENT_HEALTH += pickup.health_value;
        body.destroy();
      elif !is_p1 && CharStats.P2_CURRENT_HEALTH < CharStats.TOTAL_MAX_HEALTH:
        CharStats.P2_CURRENT_HEALTH += pickup.health_value;
        body.destroy();
      # end if
    else:
      CharStats.CURRENT_MONEY += pickup.money_value;
      body.destroy();
  # end if
#endregion
