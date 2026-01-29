extends Node

#region COMPONENTS =============================================================
var main: Main;
var device_manager: DeviceManager;
var input_manager: InputManager;
var music_manager: MusicManager;
var debug_label: Control;

var p1_char: PlayerCharacter;
var p1_char_display: Enums.CHARS = Enums.CHARS.OWLET;
var p1_cam: Camera2D;

var p2_char: PlayerCharacter;
var p2_char_display: Enums.CHARS = Enums.CHARS.BUNNY;
var p2_cam: Camera2D;
#endregion

#region CONSTANTS ==============================================================
const MAX_VELOCITY := 500.0;

#region FUNCTIONS ==============================================================
func to_fixed(num, digits) -> float:
  return roundf(num * 10**digits)/10**digits
# end to_fixed
#endregion
