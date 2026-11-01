extends SceneTree

func _initialize() -> void:
	var f: FontFile = load("res://assets/fonts/DejaVuSansMono.ttf")
	for size in [10, 11, 12, 13, 14, 16]:
		print("size ", size, ": height=", f.get_height(size), " ascent=", f.get_ascent(size), " descent=", f.get_descent(size), " char_w=", f.get_string_size("X", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)
	quit(0)
