# Autoload AudioManager.gd
extends Node

@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

@export var music_list: Array[AudioStream] = []

var is_music_playing: bool = true: set = _set_music_playing
func _set_music_playing(value: bool):
	is_music_playing = value
	
	if is_music_playing:
		play_music()
	else:
		stop_music()

func _ready():
	music_player.finished.connect(_on_music_finished)
	SignalHub.game_paused.connect(apply_pause_bus_swap)

	play_music()

#region SFX
func play_sfx(sfx: AudioStream, scale_pitch: float = 1.0, volume_db: float = 0.0) -> void:
	sfx_player.stream = sfx
	sfx_player.pitch_scale = scale_pitch
	sfx_player.volume_db = volume_db
	sfx_player.play()
#endregion


func play_music() -> void:
	if not is_music_playing:
		return


	music_player.stream = pick_random_music()
	music_player.play()

func stop_music():
	music_player.stop()

func pick_random_music() -> AudioStream:
	if music_list.size() == 0:
		return

	var random_music = music_list[randi() % music_list.size()]
	return random_music
	
func _on_music_finished():
	if is_music_playing:
		play_music()

func apply_pause_bus_swap(is_paused: bool):
	if is_paused:
		music_player.bus = "MusicPause"
	else:
		music_player.bus = "Music"
#endregion
