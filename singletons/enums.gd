extends Node

enum STATE_POSITIONS {
  RUN,
  CHANGE
}

#TODO: Rolling, Crouching, Ladder, Hanging
enum MOVEMENT_STATES {
  INIT,
  IDLE,
  RUNNING,
  JUMPING,
  FALLING,
  HURT
}

# TODO: Special attacks go here
enum ATTACK_STATES{
  NONE,
  PUNCH_1,
  PUNCH_2,
  SWORD_1,
  SWORD_2,
  SWORD_AIR,
  SWORD_CROUCH,
  BOW,
  BOW_AIR
}
