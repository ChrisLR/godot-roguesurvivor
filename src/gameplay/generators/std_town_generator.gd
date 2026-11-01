class_name StdTownGenerator
extends BaseTownGenerator
## Port of Gameplay/Generators/StdTownGenerator.cs
## The standard town generator : the base town maps plus their starting
## population (civilians, police, day-zero undeads, sewers undeads).


func _init(p_game, p_params: Dictionary = DEFAULT_PARAMS) -> void:
	super(p_game, p_params)


func generate(seed: int) -> Map:
	var map := super.generate(seed)
	map.name = "Std City"

	###################################
	# People and undeads in surface.
	###################################
	var max_tries: int = 10 * map.width * map.height
	# civilians (includes police)
	for i in RogueGame.options.max_civilians:
		# policeman, civilian?
		if _dice_roller.roll_chance(params.policeman_chance):
			# create policeman.
			var cop: Actor = create_new_policeman(0)
			# policeman on patrol starts outside.
			var outside_fn := func(pt): return !map.get_tile_at_p(pt).is_inside
			actor_place(_dice_roller, max_tries, map, cop, outside_fn)
		else:
			# create civilian with 1 skill.
			var civilian: Actor = create_new_civilian(0, 0, 1)
			# civilian starts inside.
			var inside_fn := func(pt): return map.get_tile_at_p(pt).is_inside
			actor_place(_dice_roller, max_tries, map, civilian, inside_fn)
	# dogs
	# alpha10 dogs entirely disabled for now, much more work to do on them.
	# (disabled in the C# original too)

	# start with day zero nb of undeads.
	var nb_undeads: int = (RogueGame.options.max_undeads * RogueGame.options.day_zero_undeads_percent) / 100
	for i in nb_undeads:
		var undead: Actor = create_new_undead(0)
		var outside_fn := func(pt): return !map.get_tile_at_p(pt).is_inside
		actor_place(_dice_roller, max_tries, map, undead, outside_fn)

	return map


func generate_sewers_map(seed: int, district: District) -> Map:
	var sewers := super.generate_sewers_map(seed, district)

	###############################
	# People and undeads in sewers
	###############################
	if Rules.has_zombies_in_sewers(game.session.game_mode):
		var max_tries: int = 10 * sewers.width * sewers.height
		# start with day zero nb of undeads.
		var nb_undeads: int = int(RogueGame.SEWERS_UNDEADS_FACTOR * (RogueGame.options.max_undeads * RogueGame.options.day_zero_undeads_percent) / 100.0)
		for i in nb_undeads:
			var undead: Actor = create_new_sewers_undead(0)
			actor_place(_dice_roller, max_tries, sewers, undead)

	return sewers


func generate_subway_map(seed: int, district: District) -> Map:
	var subway := super.generate_subway_map(seed, district)

	# DISABLED in the C# original (#if false) :
	# People and undeads in subways, in rails zone.

	return subway
