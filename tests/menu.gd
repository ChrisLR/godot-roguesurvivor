extends SceneTree
## Headless test of the menu path: drive handle_main_menu with scripted keys.

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	return e


func _init() -> void:
	var ui := HeadlessUI.new()
	# main menu ENTER, mode ENTER, race DOWN+ENTER (living, no confirm),
	# gender ENTER, skill ENTER; then KP_5 waits
	for i in 20:
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_DOWN)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_Y)
		ui.push_key(KEY_N)
	for i in 300:
		ui.push_key(KEY_KP_5)

	var game := RogueGame.new(ui)
	game.music_manager = GodotSoundManager.new()
	game.init_directories()
	game.load_data()
	game.load_options()
	game.load_hints()
	game.apply_options(false)
	game.load_keybindings()
	game.load_manual()
	game.load_hi_score_table()
	print("setup ok, calling handle_new_character...")
	var ok: bool = game.handle_new_character()
	print("chargen ok=", ok, " keys_left=", ui.key_queue.size())
	if ok:
		print("calling start_new_game...")
		game.start_new_game()
	print("menu returned. player=", game.player != null)
	if game.player != null:
		print("player: ", game.player.the_name, " map=", game.session.current_map.name)
		print("MENU_OK")
	else:
		print("MENU_FAIL")
	quit(0)
