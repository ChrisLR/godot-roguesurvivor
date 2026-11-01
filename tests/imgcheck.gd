extends SceneTree

func _initialize() -> void:
	var img := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	print("size=", img.get_size())
	img.set_pixel(99, 99, Color.HOT_PINK)
	print("set 99,99 ok, pixel=", img.get_pixel(99, 99))
	img.set_pixel(0, 0, Color.WHITE)
	print("set 0,0 ok")
	# simulate cross-thread use
	var t := Thread.new()
	t.start(func():
		img.set_pixel(50, 50, Color.RED)
		print("thread set ok=", img.get_pixel(50, 50))
	)
	t.wait_to_finish()
	print("IMGCHECK_DONE")
	quit(0)
