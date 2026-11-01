class_name HeadlessUI
extends IRogueUI
## No-op UI for headless simulation tests: all drawing is skipped, input is
## served from a scripted queue.

var key_queue: Array[InputEventKey] = []
var quit_called: bool = false


func push_key(keycode: int) -> void:
	var e := InputEventKey.new()
	e.keycode = keycode
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


func ui_post_mouse_buttons(buttons: int) -> void:
	pass


func ui_set_cursor(cursor: Resource) -> void:
	pass


# Delay
func ui_wait(msecs: int) -> void:
	pass


# Canvas painting (all no-ops)
func ui_repaint() -> void: pass
func ui_clear(clear_color: Color) -> void: pass
func ui_draw_image(image_id: String, gx: int, gy: int) -> void: pass
func ui_draw_image_tint(image_id: String, gx: int, gy: int, tint: Color) -> void: pass
func ui_draw_image_transform(image_id: String, gx: int, gy: int, rotation: float, scale: float) -> void: pass
func ui_draw_gray_level_image(image_id: String, gx: int, gy: int) -> void: pass
func ui_draw_transparent_image(alpha: float, image_id: String, gx: int, gy: int) -> void: pass
func ui_draw_point(color: Color, gx: int, gy: int) -> void: pass
func ui_draw_line(color: Color, gx_from: int, gy_from: int, gx_to: int, gy_to: int) -> void: pass
func ui_draw_rect(color: Color, rect: Rect2i) -> void: pass
func ui_fill_rect(color: Color, rect: Rect2i) -> void: pass
func ui_draw_string(color: Color, text: String, gx: int, gy: int, shadow_color: Color = Color.TRANSPARENT) -> void: pass
func ui_draw_string_bold(color: Color, text: String, gx: int, gy: int, shadow_color: Color = Color.TRANSPARENT) -> void: pass
func ui_draw_popup(lines: PackedStringArray, text_color: Color, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void: pass
func ui_draw_popup_title(title: String, title_color: Color, lines: PackedStringArray, text_color: Color, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void: pass
func ui_draw_popup_title_colors(title: String, title_color: Color, lines: PackedStringArray, colors: Array, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void: pass
func ui_clear_minimap(color: Color) -> void: pass
func ui_set_minimap_color(x: int, y: int, color: Color) -> void: pass
func ui_draw_minimap(gx: int, gy: int) -> void: pass


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
