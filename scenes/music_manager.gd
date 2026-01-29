extends Node
class_name MusicManager

@onready var music = $MusicPlayer;

func _ready() -> void:
  Global.music_manager = self;
# end _ready

func change_music(musicToPlay: AudioStream):
  if music != null:
    music.stop();
    music.stream = musicToPlay;
    music.play();
  # end if
# end change_music

func stop_music():
  music.stop();
# end stop_music
