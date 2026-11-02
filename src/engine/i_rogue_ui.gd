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


func ui_post_key(_e: InputEventKey) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_get_mouse_position() -> Vector2i:
	push_error(NOT_IMPLEMENTED)
	return Vector2i.ZERO


func ui_peek_mouse_buttons() -> int:
	# bitmask equivalent of MouseButtons (1=left, 2=right, 4=middle)
	push_error(NOT_IMPLEMENTED)
	return 0


func ui_post_mouse_buttons(_buttons: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_set_cursor(_cursor: Resource) -> void:
	push_error(NOT_IMPLEMENTED)


# Delay
func ui_wait(_msecs: int) -> void:
	push_error(NOT_IMPLEMENTED)


# Canvas painting
func ui_repaint() -> void:
	push_error(NOT_IMPLEMENTED)


func ui_clear(_clear_color: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_image(_image_id: String, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_image_tint(_image_id: String, _gx: int, _gy: int, _tint: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_image_transform(_image_id: String, _gx: int, _gy: int, _rotation: float, _scale: float) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_gray_level_image(_image_id: String, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_transparent_image(_alpha: float, _image_id: String, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_point(_color: Color, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_line(_color: Color, _gx_from: int, _gy_from: int, _gx_to: int, _gy_to: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_rect(_color: Color, _rect: Rect2i) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_fill_rect(_color: Color, _rect: Rect2i) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_string(_color: Color, _text: String, _gx: int, _gy: int, _shadow_color: Color = Color.TRANSPARENT) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_string_bold(_color: Color, _text: String, _gx: int, _gy: int, _shadow_color: Color = Color.TRANSPARENT) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_popup(_lines: PackedStringArray, _text_color: Color, _box_border_color: Color, _box_fill_color: Color, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_popup_title(_title: String, _title_color: Color, _lines: PackedStringArray, _text_color: Color, _box_border_color: Color, _box_fill_color: Color, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_popup_title_colors(_title: String, _title_color: Color, _lines: PackedStringArray, _colors: Array, _box_border_color: Color, _box_fill_color: Color, _gx: int, _gy: int) -> void:
	push_error(NOT_IMPLEMENTED)


# Minimap painting
func ui_clear_minimap(_color: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_set_minimap_color(_x: int, _y: int, _color: Color) -> void:
	push_error(NOT_IMPLEMENTED)


func ui_draw_minimap(_gx: int, _gy: int) -> void:
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
func ui_save_screenshot(_file_path: String) -> String:
	push_error(NOT_IMPLEMENTED)
	return ""


## extension without the point, eg: "png"
func ui_screenshot_extension() -> String:
	push_error(NOT_IMPLEMENTED)
	return "png"


# Draw-space / camera control (GodotRogueUI implements these; headless UIs
# can rely on the defaults: screen-space drawing only, no camera)
## While enabled, draw commands are in WORLD pixels (map pos * TILE_SIZE) and
## are rendered through the UI camera; otherwise they are canvas (1024x768)
## pixels on the screen-space HUD.
func ui_set_world_draw(_enabled: bool) -> void:
	pass


## Move the UI camera so that this world pixel sits at the top-left of the
## viewport (the engine keeps it on the map view-rect origin).
func ui_set_camera_focus(_world_pos: Vector2) -> void:
	pass


# Exiting
func ui_do_quit() -> void:
	push_error(NOT_IMPLEMENTED)
