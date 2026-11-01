class_name GodotSoundManager
extends IMusicManager
## Godot port of the SFML/MDX sound managers.
## Threading: the game loop runs on a background thread (see GodotRogueUI),
## but AudioStreamPlayer nodes may only be touched from the main thread.
## Every operation therefore updates local shadow state immediately (so the
## game thread's getters stay consistent) and queues the node-touching part;
## pump() applies the queue on the main thread once per frame.

const SFX_POOL_SIZE := 8

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_next := 0
var _players_ready := false

var _sounds: Dictionary = {}  # name -> AudioStream
var _music_enabled_internal := true
var _volume_internal := 100
var _priority_internal := MusicPriority.PRIORITY_NULL
var _current_music := ""
var _looping := false
var _playing_internal := false

var _queue_mutex := Mutex.new()
var _queue: Array[Dictionary] = []


func _enqueue(op: Dictionary) -> void:
	_queue_mutex.lock()
	_queue.append(op)
	_queue_mutex.unlock()


## Called once per frame from the main thread (by GodotRogueUI._process).
func pump() -> void:
	if not _players_ready:
		_ensure_players()
	_queue_mutex.lock()
	var ops: Array = _queue.duplicate()
	_queue.clear()
	_queue_mutex.unlock()
	for op: Dictionary in ops:
		_apply(op)


func _ensure_players() -> void:
	if _players_ready:
		return
	var root := Engine.get_main_loop()
	if root is SceneTree:
		_music_player = AudioStreamPlayer.new()
		_music_player.bus = "Master"
		(root as SceneTree).root.add_child(_music_player)
		for i: int in SFX_POOL_SIZE:
			var p := AudioStreamPlayer.new()
			p.bus = "Master"
			(root as SceneTree).root.add_child(p)
			_sfx_players.append(p)
		_apply_volume()
		_players_ready = true


func _apply(op: Dictionary) -> void:
	match op.get("op"):
		"load":
			var stream: AudioStream = load(op["file"])
			if stream == null:
				push_warning("sound file not found: %s" % op["file"])
			else:
				_sounds[op["name"]] = stream
		"play":
			if _sounds.has(op["name"]) and _music_player != null:
				var stream: AudioStream = _sounds[op["name"]]
				if stream is AudioStreamOggVorbis:
					(stream as AudioStreamOggVorbis).loop = op["looping"]
				_music_player.stream = stream
				_music_player.play()
				_playing_internal = true
		"stop":
			if _music_player != null:
				_music_player.stop()
			_playing_internal = false
		"sfx":
			if _sounds.has(op["name"]) and not _sfx_players.is_empty():
				var p := _sfx_players[_sfx_next]
				_sfx_next = (_sfx_next + 1) % _sfx_players.size()
				p.stream = _sounds[op["name"]]
				p.play()
		"volume":
			_apply_volume()


func _apply_volume() -> void:
	if _music_player == null:
		return
	var db := linear_to_db(_volume_internal / 100.0) if _volume_internal > 0 else -80.0
	_music_player.volume_db = db
	for p: AudioStreamPlayer in _sfx_players:
		p.volume_db = db


# ------------------------------------------------------- property overrides
func _get_is_music_enabled() -> bool:
	return _music_enabled_internal


func _set_is_music_enabled(value: bool) -> void:
	_music_enabled_internal = value
	if not value:
		stop()


func _get_volume() -> int:
	return _volume_internal


func _set_volume(value: int) -> void:
	_volume_internal = clampi(value, 0, 100)
	_enqueue({"op": "volume"})


func _get_priority() -> int:
	return _priority_internal


func _get_music() -> String:
	return _current_music


func _get_is_playing() -> bool:
	return _playing_internal


func _get_has_ended() -> bool:
	return _current_music != "" and not _playing_internal


# ------------------------------------------------------------- loading
func load_music(musicname: String, filename: String) -> bool:
	_enqueue({"op": "load", "name": musicname, "file": filename})
	return true


func load_sfx(sfxname: String, filename: String) -> bool:
	_enqueue({"op": "load", "name": sfxname, "file": filename})
	return true


func unload(musicname: String) -> void:
	_sounds.erase(musicname)


# ------------------------------------------------------------- playing
func play(musicname: String, pri: int) -> void:
	if not _music_enabled_internal:
		return
	if pri < _priority_internal:
		return
	_play_stream(musicname, pri, false)


func play_looping(musicname: String, pri: int) -> void:
	if not _music_enabled_internal:
		return
	if pri < _priority_internal:
		return
	_play_stream(musicname, pri, true)


func _play_stream(musicname: String, pri: int, looping: bool) -> void:
	_current_music = musicname
	_priority_internal = pri
	_looping = looping
	_enqueue({"op": "play", "name": musicname, "looping": looping})


func stop() -> void:
	_current_music = ""
	_priority_internal = MusicPriority.PRIORITY_NULL
	_looping = false
	_playing_internal = false
	_enqueue({"op": "stop"})


func play_sfx(sfxname: String) -> void:
	_enqueue({"op": "sfx", "name": sfxname})


func dispose() -> void:
	stop()
