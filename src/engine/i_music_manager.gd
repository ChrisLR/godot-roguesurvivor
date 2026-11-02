class_name IMusicManager
extends RefCounted
## Port of Engine/IMusicManager.cs (interface -> base class).
## One music at a time, with priorities. The Godot implementation is
## godot_sound_manager.gd.

var is_music_enabled: bool = true:
	get:
		return _get_is_music_enabled()
	set(value):
		_set_is_music_enabled(value)

var volume: int = 100:
	get:
		return _get_volume()
	set(value):
		_set_volume(value)

## alpha10
var priority: int:
	get:
		return _get_priority()

var music: String:
	get:
		return _get_music()

var is_playing: bool:
	get:
		return _get_is_playing()

var has_ended: bool:
	get:
		return _get_has_ended()


# Loading music
func load_music(_musicname: String, _filename: String) -> bool:
	assert(false, "abstract method")
	return false


func load_sfx(_sfxname: String, _filename: String) -> bool:
	assert(false, "abstract method")
	return false


func unload(_musicname: String) -> void:
	assert(false, "abstract method")


# Playing music
## Restart playing a music from the beginning if music is enabled.
func play(_musicname: String, _pri: int) -> void:
	assert(false, "abstract method")


## Restart playing in a loop a music from the beginning if music is enabled.
func play_looping(_musicname: String, _pri: int) -> void:
	assert(false, "abstract method")


func stop() -> void:
	assert(false, "abstract method")


func dispose() -> void:
	pass


# Property internals (override points)
func _get_is_music_enabled() -> bool:
	return is_music_enabled


func _set_is_music_enabled(value: bool) -> void:
	is_music_enabled = value


func _get_volume() -> int:
	return volume


func _set_volume(value: int) -> void:
	volume = value


func _get_priority() -> int:
	return MusicPriority.PRIORITY_NULL


func _get_music() -> String:
	return ""


func _get_is_playing() -> bool:
	return false


func _get_has_ended() -> bool:
	return false
