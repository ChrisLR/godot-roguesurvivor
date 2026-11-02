class_name HeadlessUI
extends IRogueUI
## No-op UI for headless simulation tests: all drawing is skipped, input is
## served from a scripted queue.

var key_queue: Array[InputEventKey] = []
var quit_called: bool = false


func push_key(keycode: int) -> void:
	var e := InputEventKey.new()
	e.keycode = keycode as Key
	key_queue.append(e)


func push_keys(keycodes: Array) -> void:
	for k in keycodes:
		push_key(k)


# Input
func ui_wait_key() -> InputEventKey:
	if key_queue.is_empty():
		push_key(KEY_KP_5)  # default: "wait" command so the sim never blocks
	return key_queue.pop_front()


func ui_peek_key() -> InputEventKey:
	# headless: peek consumes, otherwise scripted input loops forever.
	if key_queue.is_empty():
		return null
	return key_queue.pop_front()


func ui_post_key(e: InputEventKey) -> void:
	key_queue.append(e)


func ui_get_mouse_position() -> Vector2i:
	return Vector2i.ZERO


func ui_peek_mouse_buttons() -> int:
	return 0


func ui_post_mouse_buttons(_buttons: int) -> void:
	pass


func ui_set_cursor(_cursor: Resource) -> void:
	pass


# Delay
func ui_wait(msecs: int) -> void:
	# Real UI sleeps the calling thread; do the same so input loops that
	# yield via ui_wait don't busy-spin headless.
	OS.delay_msec(msecs)


# Canvas painting (all no-ops)
func ui_repaint() -> void: pass
func ui_clear(_clear_color: Color) -> void: pass
func ui_draw_image(_image_id: String, _gx: int, _gy: int) -> void: pass
func ui_draw_image_tint(_image_id: String, _gx: int, _gy: int, _tint: Color) -> void: pass
func ui_draw_image_transform(_image_id: String, _gx: int, _gy: int, _rotation: float, _scale: float) -> void: pass
func ui_draw_gray_level_image(_image_id: String, _gx: int, _gy: int) -> void: pass
func ui_draw_transparent_image(_alpha: float, _image_id: String, _gx: int, _gy: int) -> void: pass
func ui_draw_point(_color: Color, _gx: int, _gy: int) -> void: pass
func ui_draw_line(_color: Color, _gx_from: int, _gy_from: int, _gx_to: int, _gy_to: int) -> void: pass
func ui_draw_rect(_color: Color, _rect: Rect2i) -> void: pass
func ui_fill_rect(_color: Color, _rect: Rect2i) -> void: pass
func ui_draw_string(_color: Color, _text: String, _gx: int, _gy: int, _shadow_color: Color = Color.TRANSPARENT) -> void: pass
func ui_draw_string_bold(_color: Color, _text: String, _gx: int, _gy: int, _shadow_color: Color = Color.TRANSPARENT) -> void: pass
func ui_draw_popup(_lines: PackedStringArray, _text_color: Color, _box_border_color: Color, _box_fill_color: Color, _gx: int, _gy: int) -> void: pass
func ui_draw_popup_title(_title: String, _title_color: Color, _lines: PackedStringArray, _text_color: Color, _box_border_color: Color, _box_fill_color: Color, _gx: int, _gy: int) -> void: pass
func ui_draw_popup_title_colors(_title: String, _title_color: Color, _lines: PackedStringArray, _colors: Array, _box_border_color: Color, _box_fill_color: Color, _gx: int, _gy: int) -> void: pass
func ui_clear_minimap(_color: Color) -> void: pass
func ui_set_minimap_color(_x: int, _y: int, _color: Color) -> void: pass
func ui_draw_minimap(_gx: int, _gy: int) -> void: pass


func ui_get_canvas_scale_x() -> float:
	return 1.0


func ui_get_canvas_scale_y() -> float:
	return 1.0


func ui_save_screenshot(file_path: String) -> String:
	return file_path


func ui_screenshot_extension() -> String:
	return "png"


func ui_do_quit() -> void:
	quit_called = true
