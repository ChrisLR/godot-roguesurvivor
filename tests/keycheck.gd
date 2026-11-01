extends SceneTree

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	return e


func _initialize() -> void:
	_check.call_deferred()


func _check() -> void:
	var scene: Node = load("res://src/ui/main.tscn").instantiate()
	# do NOT add to tree: avoid starting the game thread for this check
	var ui := scene as GodotRogueUI
	ui.ui_post_key(_key(KEY_ENTER))
	ui.ui_post_key(_key(KEY_KP_5))
	var k1: InputEventKey = ui.ui_wait_key()
	var k2: InputEventKey = ui.ui_wait_key()
	print("k1=", k1, " keycode=", k1.keycode if k1 else -1, " ENTER=", KEY_ENTER, " match=", k1 != null and k1.keycode == KEY_ENTER)
	print("k2 keycode=", k2.keycode if k2 else -1, " KP5=", KEY_KP_5, " match=", k2 != null and k2.keycode == KEY_KP_5)
	print("KEYCHECK_DONE")
	quit(0)
