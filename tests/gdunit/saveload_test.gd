extends GdUnitTestSuite
## gdUnit4 port of the old tests/saveload.gd: 30-turn session round-tripped
## through Session.save/load, fingerprint-compared, ref-integrity checked,
## then kept simulating. Run: tests/run_gdunit.sh

const SAVE_PATH := "user://saveload_test.bin"

var ui: HeadlessUI
var game: RogueGame


func before() -> void:
	ui = HeadlessUI.new()
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
	game.char_gen = RogueGame.CharGen.new()
	game.start_new_game()

	# simulate 30 turns before saving, like the old script
	var session: Session = game.session
	for i in 30:
		if game.player == null or game.player.is_dead:
			break
		game.advance_play_district(session.current_map.district, RogueGame.SimFlags.NOT_SIMULATING)


func after() -> void:
	# IRogueUI is a Node2D: free it so gdUnit doesn't report orphan nodes.
	if ui != null:
		ui.free()
		ui = null


## Collect a comparable fingerprint of a session's world graph.
func fingerprint(s: Session) -> Dictionary:
	var fp := {}
	fp["world_size"] = s.world.size
	fp["weather"] = s.world.weather
	fp["turn"] = s.world_time.turn_counter
	fp["game_mode"] = s.game_mode
	fp["seed"] = s.seed
	fp["current_map"] = Session.map_ref(s.current_map)
	var maps_fp := []
	var total_actors := 0
	var total_corpses := 0
	var total_objects := 0
	var total_ground := 0
	var total_tiles := 0
	for x in s.world.size:
		for y in s.world.size:
			var d := s.world.get_district(x, y)
			fp["district_%d_%d" % [x, y]] = [d.kind, d.name, d.maps.size()]
			for m in d.maps:
				var tile_sample := []
				for tx in range(0, m.width, 7):
					for ty in range(0, m.height, 5):
						tile_sample.append(m.tiles[tx][ty].model_id)
				total_tiles += m.width * m.height
				var exits_ok := 0
				for pos in m.exits:
					if m.exits[pos].to_map != null:
						exits_ok += 1
				maps_fp.append([m.name, m.width, m.height, m.actors_list.size(),
					m.corpses_list.size(), m.map_objects_list.size(),
					m.ground_items_by_position.size(), m.scents.size(),
					m.timers.size(), m.exits.size(), exits_ok,
					m.local_time.turn_counter, m.lighting, tile_sample])
				total_actors += m.actors_list.size()
				total_corpses += m.corpses_list.size()
				total_objects += m.map_objects_list.size()
				total_ground += m.ground_items_by_position.size()
	fp["maps"] = maps_fp
	fp["total_actors"] = total_actors
	fp["total_corpses"] = total_corpses
	fp["total_objects"] = total_objects
	fp["total_ground"] = total_ground
	fp["total_tiles"] = total_tiles
	# player
	for x in s.world.size:
		for y in s.world.size:
			for m in s.world.get_district(x, y).maps:
				for a in m.actors_list:
					if a.is_player:
						fp["player"] = [a.model_id, a._hit_points, a._food_points,
							a.location.position, Session.map_ref(a.location.map),
							a.inventory.count_items if a.inventory != null else -1,
							a.controller != null and a.controller is PlayerController,
							a.sheet.base_hit_points, a.kills_count, a._infection]
	return fp


func loaded_session() -> Session:
	var ok: bool = Session.load(SAVE_PATH)
	assert_bool(ok).override_failure_message("Session.load returned true").is_true()
	return Session.get_session()


func test_save_creates_file() -> void:
	Session.save(game.session, SAVE_PATH)
	assert_bool(FileAccess.file_exists(SAVE_PATH)).is_true()


func test_roundtrip_fingerprint_matches() -> void:
	Session.save(game.session, SAVE_PATH)
	var fp_before := fingerprint(game.session)
	var s2: Session = loaded_session()
	assert_that(s2).is_not_equal(game.session)  # fresh object graph
	var fp_after := fingerprint(s2)
	assert_int(fp_after.get("world_size")).is_equal(fp_before.get("world_size"))
	assert_int(fp_after.get("weather")).is_equal(fp_before.get("weather"))
	assert_int(fp_after.get("turn")).is_equal(fp_before.get("turn"))
	assert_int(fp_after.get("seed")).is_equal(fp_before.get("seed"))
	assert_that(fp_after.get("current_map")).is_equal(fp_before.get("current_map"))
	assert_int(fp_after.get("total_actors")).is_equal(fp_before.get("total_actors"))
	assert_int(fp_after.get("total_corpses")).is_equal(fp_before.get("total_corpses"))
	assert_int(fp_after.get("total_objects")).is_equal(fp_before.get("total_objects"))
	assert_int(fp_after.get("total_ground")).is_equal(fp_before.get("total_ground"))
	assert_int(fp_after.get("total_tiles")).is_equal(fp_before.get("total_tiles"))
	assert_that(fp_after.get("player")).is_equal(fp_before.get("player"))
	assert_array(fp_after.get("maps")).is_equal(fp_before.get("maps"))


func test_unique_badge_item_survives_load() -> void:
	# Regression: when the badge is not placed in the world (no subway map
	# generated), the item ref was empty and the_item came back null,
	# crashing check_special_player_events_after_action on .is_equipped.
	Session.save(game.session, SAVE_PATH)
	var s2: Session = loaded_session()
	assert_that(s2.unique_items.the_subway_worker_badge).is_not_null()
	assert_that(s2.unique_items.the_subway_worker_badge.the_item) \
		.override_failure_message("unique badge item restored after load").is_not_null()


func test_loaded_session_ref_integrity() -> void:
	Session.save(game.session, SAVE_PATH)
	var s2: Session = loaded_session()
	for x in s2.world.size:
		for y in s2.world.size:
			for m in s2.world.get_district(x, y).maps:
				assert_that(m.district).override_failure_message("map %s has district" % m.name).is_not_null()
				for a in m.actors_list:
					assert_bool(a.location != null and a.location.map == m and m.actors_list.has(a)) \
						.override_failure_message("actor %s location consistent" % a._name).is_true()
					assert_that(a.controller).override_failure_message("actor %s has controller" % a._name).is_not_null()
					assert_that(a.sheet).is_not_null()
					assert_that(a.doll).is_not_null()
					if a.inventory != null:
						for it in a.inventory.items:
							assert_that(it.model).override_failure_message("item model resolves").is_not_null()
				for pos in m.exits:
					assert_that(m.exits[pos].to_map).override_failure_message("exit at %s has to_map" % str(pos)).is_not_null()
				for c in m.corpses_list:
					assert_that(c.dead_guy).override_failure_message("corpse dead_guy resolved").is_not_null()


func test_loaded_session_keeps_simulating() -> void:
	Session.save(game.session, SAVE_PATH)
	var s2: Session = loaded_session()
	game.session = s2
	game.player = null
	for x in s2.world.size:
		for y in s2.world.size:
			for m in s2.world.get_district(x, y).maps:
				for a in m.actors_list:
					if a.is_player:
						game.player = a
	assert_that(game.player).override_failure_message("loaded player found").is_not_null()
	var turns := 0
	for i in 10:
		if game.player == null or game.player.is_dead:
			break
		game.advance_play_district(s2.current_map.district, RogueGame.SimFlags.NOT_SIMULATING)
		turns += 1
	assert_int(turns).override_failure_message("loaded session keeps simulating").is_greater(0)
