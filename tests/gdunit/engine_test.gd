extends GdUnitTestSuite
## Fast unit tests + regression pins for bugs fixed during porting.
## No world generation here; runs in seconds. Run: tests/run_gdunit.sh


func test_dice_roll_stays_in_half_open_range() -> void:
	# C# DiceRoller.Roll(min, max) is [min, max-1]; the GDScript port must
	# match, otherwise generator switch tables miss cases.
	var roller := DiceRoller.new(42)
	for i in 1000:
		var r := roller.roll(0, 24)
		assert_int(r).is_between(0, 23)
	for i in 100:
		assert_int(roller.roll(5, 5)).is_equal(5)  # sanity clamp: max <= min


func test_doll_add_decoration_persists() -> void:
	# Regression: add_decoration used to append to a throwaway [] returned by
	# get_decorations, so every doll stayed empty and actors were invisible.
	var doll := Doll.new(Doll.DollBody.new(true, 3))
	assert_int(doll.count_decorations(Doll.DollPart.SKIN)).is_equal(0)
	doll.add_decoration(Doll.DollPart.SKIN, "skin1")
	doll.add_decoration(Doll.DollPart.SKIN, "skin2")
	doll.add_decoration(Doll.DollPart.HEAD, "hair1")
	assert_int(doll.count_decorations(Doll.DollPart.SKIN)).is_equal(2)
	assert_array(doll.get_decorations(Doll.DollPart.SKIN)).is_equal(["skin1", "skin2"])
	assert_array(doll.get_decorations(Doll.DollPart.HEAD)).is_equal(["hair1"])
	assert_array(doll.get_decorations(Doll.DollPart.FEET)).is_empty()
	doll.remove_all_decorations()
	assert_int(doll.count_decorations(Doll.DollPart.SKIN)).is_equal(0)


func test_ui_peek_consumes_semaphore_so_wait_never_returns_null() -> void:
	# Regression: ui_peek_key popped the queue without consuming the semaphore
	# post, so a later ui_wait_key returned null and crashed on .keycode
	# (SHIFT+H advisor "press ENTER" prompt).
	var ui := GodotRogueUI.new()  # not added to the tree: _ready never runs
	var a := InputEventKey.new()
	a.keycode = KEY_A
	ui.ui_post_key(a)
	var peeked: InputEventKey = ui.ui_peek_key()
	assert_int(peeked.keycode).is_equal(KEY_A)

	var box: Array = []
	var t := Thread.new()
	t.start(func() -> void: box.append(ui.ui_wait_key()))
	OS.delay_msec(200)  # let the thread block on the semaphore
	var b := InputEventKey.new()
	b.keycode = KEY_ENTER
	ui.ui_post_key(b)
	t.wait_to_finish()
	assert_int(box.size()).is_equal(1)
	var result: InputEventKey = box[0]
	assert_that(result).override_failure_message("ui_wait_key must block until a fresh key, never return null").is_not_null()
	assert_int(result.keycode).is_equal(KEY_ENTER)
	ui.free()  # IRogueUI is a Node2D: avoid gdUnit orphan-node warnings
