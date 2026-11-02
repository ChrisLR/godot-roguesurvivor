class_name NullMusicManager
extends IMusicManager
## No-op IMusicManager for headless runs, where no audio backend is wired.
## RogueGame defaults music_manager to this so game code can call it
## unconditionally; the real UI replaces it with GodotSoundManager in _ready.

func load_music(_musicname: String, _filename: String) -> bool:
	return true

func load_sfx(_sfxname: String, _filename: String) -> bool:
	return true

func unload(_musicname: String) -> void:
	pass

func play(_musicname: String, _pri: int) -> void:
	pass

func play_looping(_musicname: String, _pri: int) -> void:
	pass

func stop() -> void:
	pass


# Property internals: the IMusicManager base getters recurse through these,
# so they must be overridden to return plain values.
var _music_enabled: bool = true
var _volume: int = 100

func _get_is_music_enabled() -> bool:
	return _music_enabled

func _set_is_music_enabled(value: bool) -> void:
	_music_enabled = value

func _get_volume() -> int:
	return _volume

func _set_volume(value: int) -> void:
	_volume = value
