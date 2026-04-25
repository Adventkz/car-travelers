# res://scripts/autoloads/AudioManager.gd
extends Node

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_sfx_player = AudioStreamPlayer.new()
	add_child(_music_player)
	add_child(_sfx_player)
	
	_music_player.bus = "Music"
	_sfx_player.bus = "SFX"

func play_music(path: String, loop: bool = true) -> void:
	if not ResourceLoader.exists(path):
		return
	
	var stream := load(path) as AudioStream
	if stream:
		_music_player.stream = stream
		if loop and stream is AudioStreamOggVorbis:
			stream.loop = true
		_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func play_sfx(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	
	var stream := load(path) as AudioStream
	if stream:
		_sfx_player.stream = stream
		_sfx_player.play()

func play_click() -> void:
	play_sfx("res://assets/audio/sfx/click.wav")

func play_select() -> void:
	play_sfx("res://assets/audio/sfx/select.wav")

func play_alert() -> void:
	play_sfx("res://assets/audio/sfx/alert.wav")

func play_success() -> void:
	play_sfx("res://assets/audio/sfx/success.wav")

func play_failure() -> void:
	play_sfx("res://assets/audio/sfx/failure.wav")
