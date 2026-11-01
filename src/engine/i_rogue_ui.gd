class_name IRogueUI
extends Node2D
## Port of Engine/IRogueUI.cs
## GDScript has no interfaces; this is the base class the UI implements.
## The simulation (RogueGame) calls these methods; the Godot UI overrides them.
## All coordinates are canvas coordinates (1024x768, 32px tiles).
## Extends Node2D (not RefCounted) so the real UI (GodotRogueUI, a scene node)
## can be passed anywhere an IRogueUI is expected; HeadlessUI tolerates being
## a Node that never enters the tree.

const NOT_IMPLEMENTED := "IRogueUI method not implemented"


# Input
func ui_wait_key() -> InputEventKey:
	push_error(NOT_IMPLEMENTED)
	return null


func ui_peek_key() -> InputEventKey:
	push_error(NOT_IMPLEMENTED)
	return null


func ui_post_key(e: InputEventKey) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_get_mouse_position() -> Vector2i:
	push_error(NOT_IMPLEMENTED)
	return Vector2i.ZERO


func ui_peek_mouse_buttons() -> int:
	# bitmask equivalent of MouseButtons (1=left, 2=right, 4=middle)
	push_error(NOT_IMPLEMENTED)
	return 0


func ui_post_mouse_buttons(buttons: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_set_cursor(cursor: Resource) -> void:
	push_error(NOT_IMPLEMENTED)


# Delay
func ui_wait(msecs: int) -> void:
	push_error(NOT_IMPLEMENTED)


# Canvas painting
func ui_repaint() -> void:
	push_error(NOT_IMPLEMENTED)


func ui_clear(clear_color: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_image(image_id: String, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_image_tint(image_id: String, gx: int, gy: int, tint: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_image_transform(image_id: String, gx: int, gy: int, rotation: float, scale: float) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_gray_level_image(image_id: String, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_transparent_image(alpha: float, image_id: String, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_point(color: Color, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_line(color: Color, gx_from: int, gy_from: int, gx_to: int, gy_to: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_rect(color: Color, rect: Rect2i) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_fill_rect(color: Color, rect: Rect2i) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_string(color: Color, text: String, gx: int, gy: int, shadow_color: Color = Color.TRANSPARENT) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_string_bold(color: Color, text: String, gx: int, gy: int, shadow_color: Color = Color.TRANSPARENT) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_popup(lines: PackedStringArray, text_color: Color, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_popup_title(title: String, title_color: Color, lines: PackedStringArray, text_color: Color, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_popup_title_colors(title: String, title_color: Color, lines: PackedStringArray, colors: Array, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


# Minimap painting
func ui_clear_minimap(color: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_set_minimap_color(x: int, y: int, color: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_minimap(gx: int, gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


# Canvas scaling - to convert mouse coordinates to canvas coordinates.
func ui_get_canvas_scale_x() -> float:
	push_error(NOT_IMPLEMENTED)
	return 1.0


func ui_get_canvas_scale_y() -> float:
	push_error(NOT_IMPLEMENTED)
	return 1.0


# Screenshots
## file path without the extension, eg: "user://screenshots/shot100"
func ui_save_screenshot(file_path: String) -> String:
	push_error(NOT_IMPLEMENTED)
	return ""


## extension without the point, eg: "png"
func ui_screenshot_extension() -> String:
	push_error(NOT_IMPLEMENTED)
	return "png"


# Exiting
func ui_do_quit() -> void:
	push_error(NOT_IMPLEMENTED)
