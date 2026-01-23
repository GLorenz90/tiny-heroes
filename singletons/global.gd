extends Node

#region COMPONENTS =============================================================
var main: Main;
var p1_char: Node2D;
var p2_char: Node2D;
#endregion

#region CONSTANTS ==============================================================
const MAX_VELOCITY := 500.0;

#region FUNCTIONS ==============================================================
func to_fixed(num, digits) -> float:
  return roundf(num * 10**digits)/10**digits
# end to_fixed
#endregion
