class_name GodotRogueUI
extends IRogueUI
## Godot implementation of IRogueUI (port of the GDI+ game canvas).
##
## Rendering uses built-in Godot nodes instead of immediate-mode _draw():
##   - TileMapLayer nodes (MapTiles / DecorLayer / CoverLayer) for the map
##     tiles, tile decorations and above-entity covers (water, weather),
##     backed by a runtime TileSet atlas built from every GameImages image.
##   - Pooled StaticBody2D+Sprite2D nodes for map objects (interactibles),
##     Node2D+Sprite2D for actors (characters), Sprite2D pools for corpses,
##     items, scents and effect icons.
##   - Line2D / ColorRect pools for overlay lines, rects and points.
##   - Control-based HUD (CanvasLayer): pooled Labels for strings, a pooled
##     PanelContainer for popups, and a TextureRect for the minimap.
##   - A Camera2D owns the world->screen transform of the map: the engine
##     keeps it anchored (top-left) on the map view-rect origin, which follows
##     the player (compute_view_rect -> ui_set_camera_focus). Map content is
##     drawn in world pixels (map pos * TILE_SIZE); the HUD lives on a
##     CanvasLayer, so panels/labels/popups/minimap stay in screen space.
##
## The game thread still only accumulates draw commands into _batch;
## ui_repaint() publishes the batch atomically and _process() (main thread)
## applies it to the node tree, so a frame is never applied half-drawn.

const CANVAS_WIDTH := 1024
const CANVAS_HEIGHT := 768
const TILE := 32

# Draw commands are batched like the C# in-memory game canvas: the game
# thread accumulates into _batch (ui_clear resets it), and ui_repaint()
# publishes the whole batch atomically. _process() then applies the batch
# to the node tree on the main thread.
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
var _mouse_mutex := Mutex.new()
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

# ------------------------------------------------------------------
# node-based view (built-in Godot nodes, see main.tscn)

var _background: ColorRect
var _camera: Camera2D
var _map_tiles: TileMapLayer
var _decor_layer: TileMapLayer
var _cover_layer: TileMapLayer
var _corpse_layer: Node2D
var _mapobj_layer: Node2D
var _scent_layer: Node2D
var _items_layer: Node2D
var _actors_layer: Node2D
var _effects_layer: Node2D
var _overlay_layer: Control  # screen-space lines/rects/points (HUD)
var _hud_sprites: Control  # screen-space images (inventory icons, minimap markers, menus)
var _labels_root: Control
var _popups_root: Control
var _minimap_rect: TextureRect

# Draw space: while _world_draw is set, commands carry world pixels (map pos
# * TILE_SIZE) rendered through the camera; otherwise canvas (1024x768)
# screen pixels on the HUD. Set by the game thread via ui_set_world_draw.
var _world_draw := false

# Camera follow: the game thread sets the focus (view-rect origin in world
# px); applied to the Camera2D on the main thread.
var _cam_target := Vector2.ZERO

# Runtime TileSet atlas: every GameImages image gets two atlas sources
# (normal + gray-level), mapped in _tile_src / _tile_src_gray.
var _tile_set: TileSet
var _tile_src: Dictionary = {}
var _tile_src_gray: Dictionary = {}

# Fonts (DejaVu Sans Mono, metrics chosen to fit LINE_SPACING=12 /
# BOLD_LINE_SPACING=14 of the engine layout).
var _font: FontFile
var _font_bold: FontFile
const FONT_SIZE := 10
const FONT_SIZE_BOLD := 11
const POPUP_LINE_HEIGHT := 14
const POPUP_PAD := 4

# Node pools, keyed by kind: {layer, nodes, cursor, factory}.
# On "clear" every pool node is hidden and the cursor reset; commands then
# reuse pool nodes sequentially (frames are full redraws after a clear).
var _pools: Dictionary = {}


func _ready() -> void:
	_minimap = Image.create(MINIMAP_WIDTH, MINIMAP_HEIGHT, false, Image.FORMAT_RGBA8)
	_update_canvas_scale()
	# Preload every image on the main thread: the game thread only reads the
	# GameImages cache afterwards (ResourceLoader is not called off-thread).
	GameImages.load_resources(self)
	# Same for scripts: GDScript compilation is not reliable off the main
	# thread, so force every game script into the ResourceLoader cache here
	# before the game thread starts touching them.
	_preload_scripts("res://src")
	_init_view()
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


## Force-load every .gd under dir (recursively) so all GDScripts are compiled
## and cached on the main thread before the game thread starts.
func _preload_scripts(dir: String) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var _name := d.get_next()
	while _name != "":
		if d.current_is_dir():
			if _name != "." and _name != "..":
				_preload_scripts(dir.path_join(_name))
		elif _name.ends_with(".gd"):
			load(dir.path_join(_name))
		_name = d.get_next()
	d.list_dir_end()


func _init_view() -> void:
	_background = $Background
	_camera = $Camera2D
	_map_tiles = $World/MapTiles
	_decor_layer = $World/DecorLayer
	_cover_layer = $World/CoverLayer
	_corpse_layer = $World/Corpses
	_mapobj_layer = $World/MapObjects
	_scent_layer = $World/Scents
	_items_layer = $World/Items
	_actors_layer = $World/Actors
	_effects_layer = $World/Effects
	_overlay_layer = $UILayer/HUD/Shapes
	_hud_sprites = $UILayer/HUD/Sprites
	_labels_root = $UILayer/HUD/Labels
	_popups_root = $UILayer/HUD/Popups
	_minimap_rect = $UILayer/HUD/Minimap
	_minimap_rect.visible = false
	# camera: top-left anchored, so camera.position is the world pixel shown
	# at the viewport's top-left corner (the engine keeps it on the view rect)
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	_cam_target = _camera.position
	_font = load("res://assets/fonts/DejaVuSansMono.ttf") as FontFile
	_font_bold = load("res://assets/fonts/DejaVuSansMono-Bold.ttf") as FontFile
	_build_tile_set()
	_register_pool("corpses", _corpse_layer, _factory_sprite(_corpse_layer))
	_register_pool("mapobjects", _mapobj_layer, _factory_map_object)
	_register_pool("scents", _scent_layer, _factory_sprite(_scent_layer))
	_register_pool("items", _items_layer, _factory_sprite(_items_layer))
	_register_pool("actors", _actors_layer, _factory_actor)
	_register_pool("effects", _effects_layer, _factory_sprite(_effects_layer))
	_register_pool("screenfx", _hud_sprites, _factory_sprite(_hud_sprites))
	_register_pool("lines", _overlay_layer, _factory_line)
	_register_pool("rects", _overlay_layer, _factory_rect)
	_register_pool("labels", _labels_root, _factory_label)
	_register_pool("popups", _popups_root, _factory_popup)


func _build_tile_set() -> void:
	_tile_set = TileSet.new()
	_tile_set.tile_size = Vector2i(TILE, TILE)
	var next_id := 1
	for id in GameImages.image_ids():
		var tex := GameImages.get_image(id)
		if tex == null:
			continue
		_tile_src[id] = _add_atlas_source(tex, next_id)
		next_id += 1
		_tile_src_gray[id] = _add_atlas_source(GameImages.get_gray_level(id), next_id)
		next_id += 1
	_map_tiles.tile_set = _tile_set
	_decor_layer.tile_set = _tile_set
	_cover_layer.tile_set = _tile_set


func _add_atlas_source(tex: Texture2D, source_id: int) -> int:
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(mini(TILE, tex.get_width()), mini(TILE, tex.get_height()))
	src.create_tile(Vector2i.ZERO)
	_tile_set.add_source(src, source_id)
	return source_id


# ------------------------------------------------------------------
# pools

func _register_pool(kind: String, layer: Node, factory: Callable) -> void:
	_pools[kind] = {"layer": layer, "nodes": [], "cursor": 0, "factory": factory}


func _factory_sprite(layer: Node) -> Callable:
	return func() -> Sprite2D:
		var spr := Sprite2D.new()
		spr.centered = false  # top-left origin, like the C# canvas blit
		layer.add_child(spr)
		return spr


func _factory_actor() -> Node2D:
	var n := Node2D.new()
	var spr := Sprite2D.new()
	spr.centered = false
	n.add_child(spr)
	_actors_layer.add_child(n)
	return n


func _factory_map_object() -> StaticBody2D:
	var body := StaticBody2D.new()
	var spr := Sprite2D.new()
	spr.centered = false
	body.add_child(spr)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(TILE, TILE)
	shape.shape = rect
	body.add_child(shape)
	_mapobj_layer.add_child(body)
	return body


func _factory_line() -> Line2D:
	var ln := Line2D.new()
	ln.width = 1.0
	_overlay_layer.add_child(ln)
	return ln


func _factory_rect() -> ColorRect:
	var r := ColorRect.new()
	_overlay_layer.add_child(r)
	return r


func _factory_label() -> Label:
	var l := Label.new()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_labels_root.add_child(l)
	return l


func _factory_popup() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.content_margin_left = POPUP_PAD
	style.content_margin_top = POPUP_PAD
	style.content_margin_right = POPUP_PAD
	style.content_margin_bottom = POPUP_PAD
	panel.add_theme_stylebox_override("panel", style)
	panel.set_meta("style", style)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)
	_popups_root.add_child(panel)
	return panel


func _pool_next(kind: String) -> Node:
	var p: Dictionary = _pools[kind]
	if p.cursor >= p.nodes.size():
		p.nodes.append(p.factory.call())
	var n: Node = p.nodes[p.cursor]
	p.cursor += 1
	n.visible = true
	return n


func _reset_view() -> void:
	_map_tiles.clear()
	_decor_layer.clear()
	_cover_layer.clear()
	for kind in _pools.keys():
		var p: Dictionary = _pools[kind]
		for n in p.nodes:
			n.visible = false
		p.cursor = 0
	_minimap_rect.visible = false


# ------------------------------------------------------------------
# batch application (main thread, from _process)

func _apply_batch(batch: Array) -> void:
	if batch.is_empty():
		return
	if batch[0].op == "clear":
		_reset_view()
	for cmd: Dictionary in batch:
		_apply_command(cmd)


func _apply_command(cmd: Dictionary) -> void:
	match cmd.op:
		"clear":
			_background.color = cmd.color
		"image", "gray_image":
			_apply_image_cmd(cmd)
		"image_transform":
			_apply_sprite(cmd.id, int(cmd.pos.x), int(cmd.pos.y), cmd.modulate, false, cmd.rot, cmd.scale, cmd.get("world", false))
		"image_tex":
			_minimap_rect.texture = cmd.tex
			_minimap_rect.position = cmd.pos
			_minimap_rect.size = Vector2(MINIMAP_WIDTH, MINIMAP_HEIGHT)
			_minimap_rect.visible = true
		"point":
			var p := _pool_next("rects") as ColorRect
			p.color = cmd.color
			p.position = cmd.pos
			p.size = Vector2(1, 1)
		"line":
			var ln := _pool_next("lines") as Line2D
			ln.points = PackedVector2Array([cmd.from, cmd.to])
			ln.default_color = cmd.color
		"rect":
			# outline rect as a closed Line2D loop
			var r: Rect2 = cmd.rect
			var ln2 := _pool_next("lines") as Line2D
			ln2.points = PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0),
				r.end, r.position + Vector2(0, r.size.y), r.position])
			ln2.default_color = cmd.color
		"fill_rect":
			var fr := _pool_next("rects") as ColorRect
			fr.color = cmd.color
			fr.position = Vector2(cmd.rect.position)
			fr.size = Vector2(cmd.rect.size)
		"string":
			_apply_string_cmd(cmd)
		"popup":
			_apply_popup_cmd(cmd)


func _is_layered_tile_image(id: String) -> bool:
	return id.contains("/Tiles/") or id.contains("weather_") or id.contains("map_exit")


func _tile_layer_for(id: String) -> TileMapLayer:
	if id.contains("/Tiles/Decoration/"):
		return _decor_layer
	if id.contains("water_cover") or id.contains("weather_"):
		return _cover_layer
	return _map_tiles


func _apply_image_cmd(cmd: Dictionary) -> void:
	var id: String = cmd.id
	var gx := int(cmd.pos.x)
	var gy := int(cmd.pos.y)
	var gray: bool = cmd.op == "gray_image"
	var mod: Color = cmd.get("modulate", Color.WHITE)
	var world: bool = cmd.get("world", false)
	# TileMapLayer cells are positioned on the 32px grid and support no
	# per-cell tint: grid-aligned, untinted, world-space tile images go to
	# the TileMapLayers; everything else to sprite pools (world layers under
	# the camera, or the screen-space HUD pool).
	var aligned := gx % TILE == 0 and gy % TILE == 0
	if world and aligned and mod == Color.WHITE and _is_layered_tile_image(id):
		var src_map: Dictionary = _tile_src_gray if gray else _tile_src
		if src_map.has(id):
			_tile_layer_for(id).set_cell(Vector2i(gx / TILE, gy / TILE), src_map[id], Vector2i.ZERO)
			return
	_apply_sprite(id, gx, gy, mod, gray, 0.0, 1.0, world)


func _sprite_kind(id: String) -> String:
	if id.contains("/Actors/"):
		return "actors"
	if id.contains("/MapObjects/") or id.contains("map_exit"):
		return "mapobjects"
	if id.contains("/Items/"):
		return "items"
	if id.contains("scent"):
		return "scents"
	return "effects"


func _apply_sprite(id: String, gx: int, gy: int, mod: Color, gray: bool, rot: float = 0.0, _scale: float = 1.0, world: bool = true) -> void:
	var kind := _sprite_kind(id) if world else "screenfx"
	var node := _pool_next(kind)
	var spr: Sprite2D = node if node is Sprite2D else node.get_child(0)
	spr.texture = GameImages.get_gray_level(id) if gray else GameImages.get_image(id)
	spr.modulate = mod
	spr.rotation = rot
	spr.scale = Vector2(_scale, _scale)
	node.position = Vector2(gx, gy)


func _apply_string_cmd(cmd: Dictionary) -> void:
	var label := _pool_next("labels") as Label
	label.text = cmd.text
	label.position = cmd.pos
	var bold: bool = cmd.bold
	label.add_theme_font_override("font", _font_bold if bold else _font)
	label.add_theme_font_size_override("font_size", FONT_SIZE_BOLD if bold else FONT_SIZE)
	label.add_theme_color_override("font_color", cmd.color)
	if cmd.shadow != Color.TRANSPARENT:
		label.add_theme_color_override("font_shadow_color", cmd.shadow)
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	else:
		label.remove_theme_color_override("font_shadow_color")
		label.remove_theme_constant_override("shadow_offset_x")
		label.remove_theme_constant_override("shadow_offset_y")


func _apply_popup_cmd(cmd: Dictionary) -> void:
	var panel := _pool_next("popups") as PanelContainer
	panel.position = cmd.pos
	var style: StyleBoxFlat = panel.get_meta("style")
	style.bg_color = cmd.fill
	style.border_color = cmd.border
	var vbox := panel.get_child(0) as VBoxContainer
	for c in vbox.get_children():
		c.queue_free()
	var lines: PackedStringArray = cmd.lines
	var colors: Array = cmd.colors
	var max_w := 0.0
	if cmd.title != "":
		max_w = maxf(max_w, _font_bold.get_string_size(cmd.title, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE_BOLD).x)
	for l in lines:
		max_w = maxf(max_w, _font.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x)
	if cmd.title != "":
		vbox.add_child(_make_popup_label(cmd.title, cmd.title_color, true, max_w))
	for i in lines.size():
		var c: Color = cmd.text_color
		if i < colors.size() and colors[i] != null:
			c = colors[i]
		vbox.add_child(_make_popup_label(lines[i], c, false, max_w))


func _make_popup_label(text: String, color: Color, bold: bool, max_w: float) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _font_bold if bold else _font)
	l.add_theme_font_size_override("font_size", FONT_SIZE_BOLD if bold else FONT_SIZE)
	l.add_theme_color_override("font_color", color)
	l.custom_minimum_size = Vector2(max_w, POPUP_LINE_HEIGHT)
	return l


func _process(_delta: float) -> void:
	_update_canvas_scale()  # main thread only; window may resize at any time
	# apply the last published frame atomically to the node tree: a batch
	# starting with "clear" resets the view (C# UI_Clear), otherwise it
	# appends (repaints without clear accumulate, like the C# game canvas)
	_cmd_mutex.lock()
	var batch: Array = _pending_commands
	_pending_commands = []
	_cmd_mutex.unlock()
	if not batch.is_empty():
		_apply_batch(batch)
	if _redraw_requested:
		_redraw_requested = false
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
	_mouse_mutex.lock()
	var pos := _mouse_position
	_mouse_mutex.unlock()
	return pos


func ui_peek_mouse_buttons() -> int:
	_mouse_mutex.lock()
	var btns := _mouse_buttons
	_mouse_mutex.unlock()
	return btns


func ui_post_mouse_buttons(buttons: int) -> void:
	_mouse_mutex.lock()
	_mouse_buttons = buttons
	_mouse_mutex.unlock()


func ui_set_cursor(cursor: Resource) -> void:
	# may be called from the game thread; Input must be touched on main
	call_deferred("_set_cursor_deferred", cursor)


func _set_cursor_deferred(cursor: Resource) -> void:
	Input.set_custom_mouse_cursor(cursor as Texture2D)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		ui_post_key(event)
	elif event is InputEventMouseMotion:
		_mouse_mutex.lock()
		_mouse_position = Vector2i((event as InputEventMouseMotion).position)
		_mouse_mutex.unlock()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		_mouse_mutex.lock()
		var mask := _mouse_buttons
		match mb.button_index:
			MOUSE_BUTTON_LEFT:
				mask = (mask & ~1) | (1 if mb.pressed else 0)
			MOUSE_BUTTON_RIGHT:
				mask = (mask & ~2) | (2 if mb.pressed else 0)
			MOUSE_BUTTON_MIDDLE:
				mask = (mask & ~4) | (4 if mb.pressed else 0)
		_mouse_buttons = mask
		_mouse_mutex.unlock()


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


func ui_set_world_draw(enabled: bool) -> void:
	# called from the game thread; read when tagging commands and when the
	# main thread applies them (benign race on a bool, same as _batch)
	_world_draw = enabled


func ui_set_camera_focus(world_pos: Vector2) -> void:
	# called from the game thread; the camera lives on the main thread
	call_deferred("_set_camera_focus_deferred", world_pos)


func _set_camera_focus_deferred(world_pos: Vector2) -> void:
	_cam_target = world_pos
	_camera.position = world_pos


func _push_command(cmd: Dictionary) -> void:
	# game-thread side only (plus _ready before the thread starts)
	cmd["world"] = _world_draw
	_batch.append(cmd)


func ui_clear(clear_color: Color) -> void:
	# Take the mutex like ui_repaint does: keeps the write atomic w.r.t. any
	# concurrent reader of _batch on the game thread.
	_cmd_mutex.lock()
	_batch = [{"op": "clear", "color": clear_color}]
	_cmd_mutex.unlock()


func ui_draw_image(image_id: String, gx: int, gy: int) -> void:
	_push_command({"op": "image", "id": image_id, "pos": Vector2(gx, gy), "modulate": Color.WHITE})


func ui_draw_image_tint(image_id: String, gx: int, gy: int, tint: Color) -> void:
	_push_command({"op": "image", "id": image_id, "pos": Vector2(gx, gy), "modulate": tint})


func ui_draw_image_transform(image_id: String, gx: int, gy: int, _rotation: float, _scale: float) -> void:
	_push_command({"op": "image_transform", "id": image_id, "pos": Vector2(gx, gy), "rot": _rotation, "scale": _scale, "modulate": Color.WHITE})


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
	# headless runs have no viewport texture; nothing to save there
	var tex := get_viewport().get_texture()
	if tex == null:
		return
	var img := tex.get_image()
	if img == null:
		return
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


func _exit_tree() -> void:
	# Safety net: never let the game thread be destroyed while still running
	# (the engine warns and leaks ObjectDB instances otherwise).
	if _game != null:
		_game.is_game_running = false
	if _game_thread != null and _game_thread.is_alive():
		# Nudge a possibly blocked ui_wait_key() so the thread can observe
		# is_game_running and exit its loop.
		var k := InputEventKey.new()
		k.keycode = KEY_ENTER
		k.pressed = true
		ui_post_key(k)
		_game_thread.wait_to_finish()
	# Tear down the game object graph (breaks reference cycles so RefCounted
	# objects are actually freed instead of leaked at exit) and drop globals.
	# Drop the thread first: its bound callable still references the game.
	_game_thread = null
	if _game != null:
		_game.shutdown()
	_game = null
	Session.shutdown_all()
	Models.clear_statics()
	RogueGame.options = null
	RogueGame.key_bindings = null
	RogueGame.hints = null
	GameImages.clear_cache()
	if _sound_manager != null:
		_sound_manager.shutdown()
