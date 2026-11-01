class_name GodotRogueUI
extends IRogueUI
## Godot implementation of IRogueUI (port of the GDI+ game canvas).
## One canvas node draws everything the C# UI_Draw* methods drew, on a
## 1024x768 canvas (project stretch handles scaling).
## Images are addressed by ID string, resolved through GameImages.

const CANVAS_WIDTH := 1024
const CANVAS_HEIGHT := 768

# Draw commands are batched like the C# in-memory game canvas: the game
# thread accumulates into _batch (ui_clear resets it), and ui_repaint()
# publishes the whole batch atomically. _process() then applies the batch
# to _commands on the main thread, so a frame can never be pumped half-drawn
# (that was the per-keypress flicker).
var _commands: Array[Dictionary] = []
var _pending_commands: Array[Dictionary] = []
var _batch: Array[Dictionary] = []
var _cmd_mutex := Mutex.new()
var _redraw_requested := false

# input plumbing (port of UI_WaitKey/UI_PeekKey/UI_PostKey). Keys arrive on
# the main thread (_unhandled_input) and are consumed by the game thread,
# which blocks on _key_sem in ui_wait_key().
var _key_queue: Array[InputEventKey] = []
var _key_mutex := Mutex.new()
var _key_sem := Semaphore.new()
var _posted_key: InputEventKey = null
var _mouse_position := Vector2i.ZERO
var _mouse_buttons := 0

# bootstrap: the whole C#-style blocking game loop runs on this thread
var _game: RogueGame
var _game_thread: Thread
var _sound_manager: GodotSoundManager

# minimap buffer (port of UI_ClearMinimap/UI_SetMinimapColor/UI_DrawMinimap)
const MINIMAP_WIDTH := 100
const MINIMAP_HEIGHT := 100
var _minimap: Image

signal quit_requested


func _ready() -> void:
	_minimap = Image.create(MINIMAP_WIDTH, MINIMAP_HEIGHT, false, Image.FORMAT_RGBA8)
	_update_canvas_scale()
	# Preload every image on the main thread: the game thread only reads the
	# GameImages cache afterwards (ResourceLoader is not called off-thread).
	GameImages.load_resources(self)
	# Audio: created on the main thread; the game thread only queues ops that
	# pump() applies here once per frame.
	_sound_manager = GodotSoundManager.new()
	_game = RogueGame.new(self)
	_game.music_manager = _sound_manager
	ui_clear(Color.BLACK)
	ui_draw_string_bold(Color.WHITE, "Generating world, please wait...", 8, 8)
	ui_repaint()
	_game_thread = Thread.new()
	_game_thread.start(_game.run)


func _process(_delta: float) -> void:
	_update_canvas_scale()  # main thread only; window may resize at any time
	# apply the last published frame atomically: a batch starting with
	# "clear" replaces the canvas (C# UI_Clear), otherwise it appends
	# (repaints without clear accumulate, like the C# game canvas)
	_cmd_mutex.lock()
	var batch: Array = _pending_commands
	_pending_commands = []
	_cmd_mutex.unlock()
	if not batch.is_empty():
		if batch[0].op == "clear":
			_commands = batch
		else:
			_commands.append_array(batch)
		queue_redraw()
	if _redraw_requested:
		_redraw_requested = false
		queue_redraw()
	_sound_manager.pump()


# ------------------------------------------------------------------ input

var _debug_key_count := 0
var _debug_last_keycode := 0

var _debug_in_wait := false

func ui_wait_key() -> InputEventKey:
	# Called from the game thread: block until the main thread posts a key.
	# Loop on null: ui_peek_key() consumes queue entries (and their semaphore
	# count), so a stale semaphore post must never surface as a null key.
	_debug_in_wait = true
	var key: InputEventKey = null
	while key == null:
		_key_sem.wait()
		_key_mutex.lock()
		key = _key_queue.pop_front() if not _key_queue.is_empty() else null
		_key_mutex.unlock()
	_debug_in_wait = false
	_debug_key_count += 1
	_debug_last_keycode = key.keycode
	return key


func ui_peek_key() -> InputEventKey:
	# The C# UI_PeekKey consumes the event (callers rely on this to discard
	# key auto-repeats); HeadlessUI does the same. Consuming a key also
	# consumes its semaphore post, keeping the count in sync with the queue.
	_key_mutex.lock()
	var key: InputEventKey = _key_queue.pop_front() if not _key_queue.is_empty() else null
	_key_mutex.unlock()
	if key != null:
		_key_sem.try_wait()
		_debug_key_count += 1
		_debug_last_keycode = key.keycode
	return key


func ui_post_key(e: InputEventKey) -> void:
	_key_mutex.lock()
	_key_queue.append(e)
	_key_sem.post()  # under the lock: a concurrent pop always sees the count
	_key_mutex.unlock()


func ui_get_mouse_position() -> Vector2i:
	return _mouse_position


func ui_peek_mouse_buttons() -> int:
	return _mouse_buttons


func ui_post_mouse_buttons(buttons: int) -> void:
	_mouse_buttons = buttons


func ui_set_cursor(cursor: Resource) -> void:
	# may be called from the game thread; Input must be touched on main
	call_deferred("_set_cursor_deferred", cursor)


func _set_cursor_deferred(cursor: Resource) -> void:
	Input.set_custom_mouse_cursor(cursor as Texture2D)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		ui_post_key(event)
	elif event is InputEventMouseMotion:
		_mouse_position = Vector2i((event as InputEventMouseMotion).position)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		var mask := 0
		if _mouse_buttons & 1:
			mask |= 1
		if _mouse_buttons & 2:
			mask |= 2
		if _mouse_buttons & 4:
			mask |= 4
		match mb.button_index:
			MOUSE_BUTTON_LEFT:
				mask = (mask & ~1) | (1 if mb.pressed else 0)
			MOUSE_BUTTON_RIGHT:
				mask = (mask & ~2) | (2 if mb.pressed else 0)
			MOUSE_BUTTON_MIDDLE:
				mask = (mask & ~4) | (4 if mb.pressed else 0)
		_mouse_buttons = mask


# ------------------------------------------------------------------ delay

func ui_wait(msecs: int) -> void:
	# Called from the game thread; C# UI_Wait repaints first, then sleeps.
	# OS.delay_msec sleeps only the calling thread, so the main thread keeps
	# rendering and pumping input.
	ui_repaint()
	OS.delay_msec(msecs)


# ------------------------------------------------------------------ painting

func ui_repaint() -> void:
	# Publish the accumulated batch atomically (C# UI_Repaint semantics: the
	# frame only becomes visible here, never half-drawn).
	_cmd_mutex.lock()
	if not _batch.is_empty():
		_pending_commands = _batch
		_batch = []
	_cmd_mutex.unlock()
	_redraw_requested = true


func _push_command(cmd: Dictionary) -> void:
	# game-thread side only (plus _ready before the thread starts)
	_batch.append(cmd)


func ui_clear(clear_color: Color) -> void:
	_batch = [{"op": "clear", "color": clear_color}]


func ui_draw_image(image_id: String, gx: int, gy: int) -> void:
	_push_command({"op": "image", "id": image_id, "pos": Vector2(gx, gy), "modulate": Color.WHITE})


func ui_draw_image_tint(image_id: String, gx: int, gy: int, tint: Color) -> void:
	_push_command({"op": "image", "id": image_id, "pos": Vector2(gx, gy), "modulate": tint})


func ui_draw_image_transform(image_id: String, gx: int, gy: int, rotation: float, scale: float) -> void:
	_push_command({"op": "image_transform", "id": image_id, "pos": Vector2(gx, gy), "rot": rotation, "scale": scale, "modulate": Color.WHITE})


func ui_draw_gray_level_image(image_id: String, gx: int, gy: int) -> void:
	_push_command({"op": "gray_image", "id": image_id, "pos": Vector2(gx, gy)})


func ui_draw_transparent_image(alpha: float, image_id: String, gx: int, gy: int) -> void:
	_push_command({"op": "image", "id": image_id, "pos": Vector2(gx, gy), "modulate": Color(1, 1, 1, alpha)})


func ui_draw_point(color: Color, gx: int, gy: int) -> void:
	_push_command({"op": "point", "color": color, "pos": Vector2(gx, gy)})


func ui_draw_line(color: Color, gx_from: int, gy_from: int, gx_to: int, gy_to: int) -> void:
	_push_command({"op": "line", "color": color, "from": Vector2(gx_from, gy_from), "to": Vector2(gx_to, gy_to)})


func ui_draw_rect(color: Color, rect: Rect2i) -> void:
	_push_command({"op": "rect", "color": color, "rect": Rect2(rect)})


func ui_fill_rect(color: Color, rect: Rect2i) -> void:
	_push_command({"op": "fill_rect", "color": color, "rect": Rect2(rect)})


func ui_draw_string(color: Color, text: String, gx: int, gy: int, shadow_color: Color = Color.TRANSPARENT) -> void:
	_push_command({"op": "string", "color": color, "text": text, "pos": Vector2(gx, gy), "bold": false, "shadow": shadow_color})


func ui_draw_string_bold(color: Color, text: String, gx: int, gy: int, shadow_color: Color = Color.TRANSPARENT) -> void:
	_push_command({"op": "string", "color": color, "text": text, "pos": Vector2(gx, gy), "bold": true, "shadow": shadow_color})


func ui_draw_popup(lines: PackedStringArray, text_color: Color, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void:
	_push_command({"op": "popup", "title": "", "title_color": Color.WHITE, "lines": lines, "text_color": text_color, "border": box_border_color, "fill": box_fill_color, "pos": Vector2(gx, gy), "colors": []})


func ui_draw_popup_title(title: String, title_color: Color, lines: PackedStringArray, text_color: Color, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void:
	_push_command({"op": "popup", "title": title, "title_color": title_color, "lines": lines, "text_color": text_color, "border": box_border_color, "fill": box_fill_color, "pos": Vector2(gx, gy), "colors": []})


func ui_draw_popup_title_colors(title: String, title_color: Color, lines: PackedStringArray, colors: Array, box_border_color: Color, box_fill_color: Color, gx: int, gy: int) -> void:
	_push_command({"op": "popup", "title": title, "title_color": title_color, "lines": lines, "text_color": Color.WHITE, "border": box_border_color, "fill": box_fill_color, "pos": Vector2(gx, gy), "colors": colors})


# ------------------------------------------------------------------ minimap

func ui_clear_minimap(color: Color) -> void:
	_minimap.fill(color)


func ui_set_minimap_color(x: int, y: int, color: Color) -> void:
	if x >= 0 and x < MINIMAP_WIDTH and y >= 0 and y < MINIMAP_HEIGHT:
		_minimap.set_pixel(x, y, color)


func ui_draw_minimap(gx: int, gy: int) -> void:
	var tex := ImageTexture.create_from_image(_minimap)
	_push_command({"op": "image_tex", "tex": tex, "pos": Vector2(gx, gy), "modulate": Color.WHITE})


# ------------------------------------------------------------------ scaling

# Cached on the main thread: get_viewport_rect() is not callable from the
# game thread (it errors and returns Rect2()), so ui_get_canvas_scale_* must
# read these instead.
var _canvas_scale_x := 1.0
var _canvas_scale_y := 1.0

func _update_canvas_scale() -> void:
	var size := get_viewport_rect().size
	_canvas_scale_x = size.x / float(CANVAS_WIDTH)
	_canvas_scale_y = size.y / float(CANVAS_HEIGHT)


func ui_get_canvas_scale_x() -> float:
	return _canvas_scale_x


func ui_get_canvas_scale_y() -> float:
	return _canvas_scale_y


# ------------------------------------------------------------------ screenshots

func ui_save_screenshot(file_path: String) -> String:
	# may be called from the game thread; the viewport lives on the main thread
	var path := file_path + ".png"
	call_deferred("_save_screenshot_deferred", path)
	return path


func _save_screenshot_deferred(path: String) -> void:
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)


func ui_screenshot_extension() -> String:
	return "png"


# ------------------------------------------------------------------ exiting

func ui_do_quit() -> void:
	# called from the game thread at the end of RogueGame.run()
	call_deferred("_quit_app")


func _quit_app() -> void:
	quit_requested.emit()
	if _game_thread != null and _game_thread.is_alive():
		_game_thread.wait_to_finish()
	get_tree().quit()


# ------------------------------------------------------------------ _draw

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for cmd: Dictionary in _commands:
		match cmd.op:
			"clear":
				draw_rect(Rect2(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT), cmd.color)
			"image":
				var tex: Texture2D = GameImages.get_image(cmd.id)
				if tex != null:
					draw_texture(tex, cmd.pos, cmd.modulate)
			"image_tex":
				draw_texture(cmd.tex, cmd.pos, cmd.modulate)
			"image_transform":
				var tex2: Texture2D = GameImages.get_image(cmd.id)
				if tex2 != null:
					draw_set_transform_matrix(Transform2D(cmd.rot, Vector2(cmd.scale, cmd.scale), 0.0, cmd.pos))
					draw_texture(tex2, Vector2.ZERO, cmd.modulate)
					draw_set_transform_matrix(Transform2D())
			"gray_image":
				var gray: Texture2D = GameImages.get_gray_level(cmd.id)
				if gray != null:
					draw_texture(gray, cmd.pos, Color.WHITE)
			"point":
				draw_rect(Rect2(cmd.pos, Vector2(1, 1)), cmd.color)
			"line":
				draw_line(cmd.from, cmd.to, cmd.color, 1.0)
			"rect":
				draw_rect(cmd.rect, cmd.color, false, 1.0)
			"fill_rect":
				draw_rect(cmd.rect, cmd.color, true)
			"string":
				var pos: Vector2 = cmd.pos
				var shadow: Color = cmd.shadow
				if shadow != Color.TRANSPARENT:
					draw_string(font, pos + Vector2(1, 1), cmd.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, shadow)
				draw_string(font, pos, cmd.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, cmd.color)
			"popup":
				_draw_popup_cmd(cmd, font)
	if _redraw_requested:
		_redraw_requested = false


func _draw_popup_cmd(cmd: Dictionary, font: Font) -> void:
	var lines: PackedStringArray = cmd.lines
	var colors: Array = cmd.colors
	var line_h := 14
	var pad := 4
	var title_h := line_h + 2 if cmd.title != "" else 0
	var max_w := 0
	for l: String in lines:
		max_w = maxi(max_w, int(font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x))
	var box := Rect2(cmd.pos, Vector2(max_w + 2 * pad, title_h + lines.size() * line_h + 2 * pad))
	draw_rect(box, cmd.fill, true)
	draw_rect(box, cmd.border, false, 1.0)
	var y: float = cmd.pos.y + pad
	if cmd.title != "":
		draw_string(font, Vector2(cmd.pos.x + pad, y + 12), cmd.title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, cmd.title_color)
		y += title_h
	for i: int in lines.size():
		var c: Color = cmd.text_color
		if i < colors.size() and colors[i] != null:
			c = colors[i]
		draw_string(font, Vector2(cmd.pos.x + pad, y + 12), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, c)
		y += line_h
