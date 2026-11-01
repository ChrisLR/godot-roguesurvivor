class_name MessageManager
extends RefCounted
## Port of Engine/MessageManager.cs

var _messages: Array[Message] = []
var _lines_spacing: int
var _fadeout_factor: int
var _history: Array[Message] = []
var _history_size: int


func _init(lines_spacing: int, fadeout_factor: int, history_size: int) -> void:
	if lines_spacing < 0:
		push_error("linesSpacing < 0")
	if fadeout_factor < 0:
		push_error("fadeoutFactor < 0")
	_lines_spacing = lines_spacing
	_fadeout_factor = fadeout_factor
	_history_size = history_size
	_history = []


func count() -> int:
	return _messages.size()


func get_history() -> Array[Message]:
	return _history


func clear() -> void:
	_messages.clear()


func clear_history() -> void:
	_history.clear()


func add(msg: Message) -> void:
	_messages.append(msg)
	_history.append(msg)
	if _history.size() > _history_size:
		_history.remove_at(0)


func remove_last_message() -> void:
	if _messages.is_empty():
		return
	_messages.remove_at(_messages.size() - 1)


func draw(ui: IRogueUI, fresh_messages_turn: int, gx: int, gy: int) -> void:
	for i: int in _messages.size():
		var msg: Message = _messages[i]
		var alpha: int = max(64, 255 - _fadeout_factor * (_messages.size() - 1 - i))
		var is_latest: bool = _messages[i].turn >= fresh_messages_turn
		var dimmed_color := Color(msg.color, alpha / 255.0)

		if is_latest:
			ui.ui_draw_string_bold(dimmed_color, msg.text, gx, gy)
		else:
			ui.ui_draw_string(dimmed_color, msg.text, gx, gy)

		gy += _lines_spacing
