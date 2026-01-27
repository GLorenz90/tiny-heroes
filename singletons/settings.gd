extends Node

const settingsFilePath = "user://settings.cfg";

const defaultMasterVolume := 50.0;
const defaultMusicVolume := 50.0;
const defaultEffectsVolume := 50.0;

var masterVolume := defaultMasterVolume;
var musicVolume := defaultMusicVolume;
var effectsVolume := defaultEffectsVolume;

var antialiasingOptions = [Viewport.MSAA.MSAA_DISABLED, Viewport.MSAA.MSAA_2X, Viewport.MSAA.MSAA_4X, Viewport.MSAA.MSAA_8X];
var defaultAntialiasing: Viewport.MSAA = Viewport.MSAA.MSAA_4X;

var antialiasing := defaultAntialiasing;

var default_stick_deadzone := 0.25
var stick_deadzone := default_stick_deadzone;

var config = ConfigFile.new();

func _init():
  loadSettingsFile();

#region FUNCTIONS ========================================================================================
func saveSettingsFile():
  config.set_value("audio", "master_volume", masterVolume);
  config.set_value("audio", "effects_volume", effectsVolume);
  config.set_value("audio", "music_volume", musicVolume);
  
  config.set_value("visual", "antialiasing", antialiasing);
  
  config.set_value("input", "stick_deadzone", stick_deadzone);
  config.save(settingsFilePath);
  updateAudioBusses();
# end saveSettingsFile

func loadSettingsFile():
  var fileLoadStatus = config.load(settingsFilePath);
  if(fileLoadStatus == OK):
    masterVolume = config.get_value("audio", "master_volume", defaultMasterVolume);
    effectsVolume = config.get_value("audio", "effects_volume", defaultEffectsVolume);
    musicVolume = config.get_value("audio", "music_volume", defaultMusicVolume);
    
    antialiasing = config.get_value("visual", "antialiasing", defaultAntialiasing);
  
    antialiasing = config.get_value("input", "stick_deadzone", default_stick_deadzone);
    updateAudioBusses();
  # end if
# end loadSettingsFile

func updateAudioBusses():
  var masterIndex = AudioServer.get_bus_index("Master");
  var masterRatio = masterVolume/100.0;
  AudioServer.set_bus_volume_db(masterIndex, linear_to_db(masterRatio) );

  var musicIndex= AudioServer.get_bus_index("Music");
  var musicRatio = (musicVolume/100.0) * masterRatio;
  AudioServer.set_bus_volume_db(musicIndex, linear_to_db(musicRatio));

  var effectsIndex= AudioServer.get_bus_index("Effects");
  var effectsRatio = (effectsVolume/100.0) * masterRatio;
  AudioServer.set_bus_volume_db(effectsIndex, linear_to_db(effectsRatio));
# end updateAudioBusses

func updateVisualSettings():
  Global.main.viewport.set_msaa_3d(antialiasing);
# end updateVisualSettings

func resetToDefault():
  masterVolume = defaultMasterVolume;
  effectsVolume = defaultEffectsVolume;
  musicVolume = defaultMusicVolume;
  antialiasing = defaultAntialiasing;
  stick_deadzone = default_stick_deadzone;
  updateAudioBusses();
# end resetToDefault
#endregion
