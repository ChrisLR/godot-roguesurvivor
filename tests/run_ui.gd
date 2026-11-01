extends SceneTree
## Integration test: run the REAL main scene (GodotRogueUI + game thread)
## headless, feed scripted keys, verify the game reaches gameplay and that
## draw commands flow from the game thread to the canvas.
## Run: godot --headless --script tests/run_ui.gd

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
	if ui == null:
		print("UI_TEST_FAIL: main scene is not GodotRogueUI")
		quit(1)
		return

	# scripted input: main menu ENTER, mode ENTER, race DOWN+ENTER (living),
	# gender ENTER, skill ENTER; then KP_5 (wait a turn) for player turns
	for i in 2:  # "press ENTER" prompts if the manual is missing on first run
		ui.ui_post_key(_key(KEY_ENTER))
	for i in 20:
		ui.ui_post_key(_key(KEY_ENTER))
		ui.ui_post_key(_key(KEY_ENTER))
		ui.ui_post_key(_key(KEY_DOWN))
		ui.ui_post_key(_key(KEY_ENTER))
		ui.ui_post_key(_key(KEY_ENTER))
		ui.ui_post_key(_key(KEY_ENTER))
		ui.ui_post_key(_key(KEY_Y))
		ui.ui_post_key(_key(KEY_N))
	for i in 400:
		ui.ui_post_key(_key(KEY_KP_5))

	var frames := 0
	var start := Time.get_ticks_msec()
	var game: RogueGame = null
	var last_report := 0
	while Time.get_ticks_msec() - start < 240000:
		await process_frame
		frames += 1
		if frames - last_report >= 2000:
			last_report = frames
			var g := ui._game
			print("t=", (Time.get_ticks_msec() - start) / 1000, "s frames=", frames,
				" keys_left=", ui._key_queue.size(),
				" thread_alive=", ui._game_thread.is_alive(),
				" running=", g != null and g.is_game_running,
				" player=", g != null and g.player != null,
				" char_gen=", g != null and g.char_gen != null,
				" mode=", g != null and g.session != null and g.session.game_mode,
				" world=", g != null and g.session != null and g.session.world != null and g.session.world.size,
				" keys_seen=", ui._debug_key_count, " last_key=", ui._debug_last_keycode,
				" in_wait=", ui._debug_in_wait,
				" intro=", g != null and g.played_intro,
				" cmds=", ui._commands.size())
		if ui._game != null and ui._game.player != null:
			game = ui._game
			if game.session.current_map != null and game.session.current_map.local_time.turn_counter > 5:
				break

	if game == null:
		game = ui._game
	print("frames pumped: ", frames, " elapsed_ms: ", Time.get_ticks_msec() - start)
	print("draw commands pending/main: ", ui._pending_commands.size(), "/", ui._commands.size())
	if game == null or game.player == null:
		print("UI_TEST_FAIL: player never spawned (game thread stuck or crashed)")
		quit(1)
		return
	print("player: ", game.player.the_name, " at ", game.player.location.position,
		" hp=", game.player.hit_points, " map=", game.session.current_map.name)
	print("map turn: ", game.session.current_map.local_time.turn_counter,
		" actors: ", game.session.current_map.count_actors)
	if ui._commands.is_empty():
		print("UI_TEST_FAIL: no draw commands reached the canvas")
		quit(1)
		return
	print("UI_TEST_OK")
	quit(0)
