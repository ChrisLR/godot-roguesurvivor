extends SceneTree
## Bisect the character-creation flow step by step.

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	return e


func _init() -> void:
	var ui := HeadlessUI.new()
	for i in 20:
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_DOWN)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_ENTER)
		ui.push_key(KEY_Y)
		ui.push_key(KEY_N)

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
	game.session.reset()
	game.char_gen = RogueGame.CharGen.new()

	print("step: handle_new_game_mode")
	var ok_mode: bool = game.handle_new_game_mode()
	print("mode ok=", ok_mode, " keys_left=", ui.key_queue.size())

	print("step: handle_new_character_race")
	var roller := DiceRoller.new()
	var race := game.handle_new_character_race(roller)
	print("race done=", race.get("done"), " keys_left=", ui.key_queue.size())

	print("step: handle_new_character_gender")
	var gender := game.handle_new_character_gender(roller)
	print("gender done=", gender.get("done"), " keys_left=", ui.key_queue.size())

	print("step: handle_new_character_skill")
	var sk := game.handle_new_character_skill(roller)
	print("skill done=", sk.get("done"), " keys_left=", ui.key_queue.size())
	print("BISECT_DONE")
	quit(0)
