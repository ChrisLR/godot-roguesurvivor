extends SceneTree
## Dump the main-menu draw commands to JSON for offline rasterization.
## Run: godot --headless --script tests/dump_ui.gd

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	return e


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scene: Node = load("res://src/ui/main.tscn").instantiate()
	root.add_child(scene)
	var ui := scene as GodotRogueUI
	# stay at the main menu (no keys)
	var frames := 0
	while frames < 600:
		await process_frame
		frames += 1
	# serialize commands (strip non-serializable values)
	var out: Array = []
	for cmd: Dictionary in ui._commands:
		var c := {}
		for k in cmd.keys():
			var v = cmd[k]
			match typeof(v):
				TYPE_STRING, TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_VECTOR2, TYPE_RECT2, TYPE_COLOR:
					c[k] = v
				TYPE_OBJECT:
					if v is Texture2D:
						c[k] = {"tex": v.resource_path}
					elif v == null:
						c[k] = null
				TYPE_PACKED_STRING_ARRAY, TYPE_ARRAY:
					c[k] = v
				_:
					c[k] = str(v)
		out.append(c)
	var f := FileAccess.open("/tmp/draw_commands.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"commands": out, "canvas": [1024, 768]}, "  "))
	f.close()
	print("DUMPED ", out.size(), " commands")
	quit(0)
