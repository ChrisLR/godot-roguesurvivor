extends GdUnitTestSuite
## gdUnit4 port of the old tests/smoke.gd: headless new game + 30-turn
## simulation, plus regression pins for bugs found during the rendered
## playtest (invisible doll decorations, unhandled bedroom roll).
## Run: tests/run_gdunit.sh

var ui: _RecordingUI
var game: RogueGame


func before() -> void:
	ui = _RecordingUI.new()
	# generous input script: ENTER for all the "press ENTER" waits, then
	# KP_5 (wait) for every player turn.
	for i in 50:
		ui.push_key(KEY_ENTER)
	for i in 500:
		ui.push_key(KEY_KP_5)

	game = RogueGame.new(ui)
	game.init_directories()
	game.load_data()
	game.load_options()
	game.load_hints()
	game.apply_options(false)
	game.load_keybindings()
	game.load_manual()
	game.load_hi_score_table()
	game.session.reset()
	game.char_gen = RogueGame.CharGen.new()  # living male civilian, first skill
	game.start_new_game()


func after() -> void:
	# IRogueUI is a Node2D: free it so gdUnit doesn't report orphan nodes.
	if ui != null:
		ui.free()
		ui = null


# Tests run in declaration order and share the suite game; the destructive
# 30-turn simulation goes last.

func test_world_generates() -> void:
	assert_int(game.session.world.size).is_equal(5)
	assert_that(game.session.current_map).is_not_null()
	assert_str(game.session.current_map.name).is_not_empty()


func test_player_spawns_on_map() -> void:
	var session: Session = game.session
	assert_that(game.player).is_not_null()
	assert_str(game.player.the_name).is_not_empty()
	assert_int(game.player.hit_points).is_greater(0)
	assert_that(session.current_map.get_actor_at_xy(
		game.player.location.position.x, game.player.location.position.y)).is_equal(game.player)


func test_player_doll_is_dressed() -> void:
	# Regression: Doll.add_decoration used to append to a throwaway array,
	# leaving every actor invisible.
	for part in [Doll.DollPart.SKIN, Doll.DollPart.HEAD, Doll.DollPart.EYES,
			Doll.DollPart.TORSO, Doll.DollPart.LEGS, Doll.DollPart.FEET]:
		assert_int(game.player.doll.count_decorations(part)) \
			.override_failure_message("doll part %d has decorations" % part).is_greater(0)


func test_player_sprite_drawn_at_player_tile() -> void:
	# Regression: with an empty doll no image was emitted for the player.
	game.update_player_fov(game.player)
	game.compute_view_rect(game.player.location.position)
	# map content is drawn in world pixels (the UI camera maps world->screen)
	var world := game.map_to_world(game.player.location.position)
	ui.tint_draws.clear()
	game.redraw_play_screen()
	var sprite_draws: Array = ui.tint_draws_at(world.x + RogueGame.ACTOR_OFFSET, world.y + RogueGame.ACTOR_OFFSET)
	assert_array(sprite_draws) \
		.override_failure_message("actor sprite images drawn at player tile %s" % str(world)).is_not_empty()


func test_bedroom_item_roll_fully_covered() -> void:
	# Regression: roll(0,24) missed case 18 -> "unhandled roll" push_error.
	for i in 300:
		var it: Item = game.town_generator.make_random_bedroom_item()
		assert_that(it).override_failure_message("bedroom roll %d returned an item" % i).is_not_null()


func test_simulate_30_turns() -> void:
	var session: Session = game.session
	ui.key_queue.clear()
	for i in 1000:
		ui.push_key(KEY_KP_5)
	var turns := 0
	for i in 30:
		if game.player == null or game.player.is_dead:
			break
		game.advance_play_district(session.current_map.district, RogueGame.SimFlags.NOT_SIMULATING)
		turns += 1
	assert_int(turns).is_equal(30)
	assert_int(session.world_time.turn_counter).is_greater(0)


class _RecordingUI extends HeadlessUI:
	var tint_draws: Array = []
	func ui_draw_image_tint(image_id: String, gx: int, gy: int, tint: Color) -> void:
		tint_draws.append({"id": image_id, "gx": gx, "gy": gy})
	func tint_draws_at(gx: int, gy: int) -> Array:
		var out: Array = []
		for d in tint_draws:
			if d.gx == gx and d.gy == gy:
				out.append(d.id)
		return out
