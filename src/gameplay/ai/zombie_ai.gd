class_name ZombieAI
extends BaseAI
## Port of Gameplay/AI/ZombieAI.cs
## Zombie AI : used by Zombie, Zombie Master and Zombified branches.

# Constants

const LOS_MEMORY: int = 20

const EXPLORATION_LOCATIONS: int = 30
const EXPLORATION_ZONES: int = 3

const USE_EXIT_CHANCE: int = 50
const FOLLOW_SCENT_THROUGH_EXIT_CHANCE: int = 90
const PUSH_OBJECT_CHANCE: int = 20

# Fields

var _mem_los_sensor: MemorizedSensor = null
var _living_smell_sensor: SmellSensor = null
var _master_smell_sensor: SmellSensor = null

var _exploration: ExplorationData = null


# BaseAI

func take_control(actor: Actor) -> void:
	super(actor)

	if _actor.model.abilities.zombie_ai_explore:
		_exploration = _track_exploration(ExplorationData.new(EXPLORATION_LOCATIONS, EXPLORATION_ZONES))


func create_sensors() -> void:
	_mem_los_sensor = _track_memorized_sensor(MemorizedSensor.new(
		LOSSensor.new(LOSSensor.SensingFilter.ACTORS | LOSSensor.SensingFilter.CORPSES),
		LOS_MEMORY))
	_living_smell_sensor = SmellSensor.new(Odor.LIVING)
	_master_smell_sensor = SmellSensor.new(Odor.UNDEAD_MASTER)


func update_sensors(game: RogueGame) -> Array[Percept]:
	var list: Array[Percept] = _mem_los_sensor.sense(game, _actor)
	list.append_array(_living_smell_sensor.sense(game, _actor))
	list.append_array(_master_smell_sensor.sense(game, _actor))
	return list


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	if not has_valid_location():
		return null
	var _fov = (_mem_los_sensor.sensor as LOSSensor).fov
	var map_percepts = filter_same_map(game, percepts)

	##############################################################
	# 1 move closer to an enemy, nearest & visible enemies first
	# 2 eat corpses.
	# 3 use exits (if ability)
	# 4 move close to nearest undead master (if not master)
	# 5 move to highest adjacent undead master scent (if not master)
	# 6 move to highest living scent
	# 7 **DISABLED** assault breakables (if ability)
	# 8 randomly push objects around (if ability OR skill STRONG)
	# 9 explore (if ability)
	# 10 wander
	##############################################################

	# get data.
	if _actor.model.abilities.zombie_ai_explore:
		# exploration.
		_exploration.update(_actor.location)

	# 1 move closer to an enemy, nearest & visible enemies first
	var enemies = filter_enemies(game, map_percepts)
	if enemies != null:
		# try visible enemies first, the closer the best.
		var turn_counter: int = _actor.location.map.local_time.turn_counter
		var visible_enemies = filter(game, enemies,
			func(p: Percept) -> bool: return p.turn == turn_counter)
		if visible_enemies != null:
			var best_enemy_percept: Percept = null
			var best_bump_action: ActorAction = null
			var closest: int = 2147483647

			for enemy_p: Percept in visible_enemies:
				var distance: int = game.rules.grid_distance_points(_actor.location.position, enemy_p.location.position)
				if distance < closest:
					var bump_action: ActorAction = behavior_stupid_bump_toward(game, enemy_p.location.position, true, true)
					if bump_action != null:
						closest = distance
						best_enemy_percept = enemy_p
						best_bump_action = bump_action

			if best_bump_action != null:
				_actor.activity = Activity.CHASING
				_actor.target_actor = best_enemy_percept.percepted as Actor
				return best_bump_action

		# then try rest, the closer the best.
		var old_enemies = filter(game, enemies,
			func(p: Percept) -> bool: return p.turn != turn_counter)
		if old_enemies != null:
			var best_enemy_percept: Percept = null
			var best_bump_action: ActorAction = null
			var closest: int = 2147483647

			for enemy_p: Percept in old_enemies:
				var distance: int = game.rules.grid_distance_points(_actor.location.position, enemy_p.location.position)
				if distance < closest:
					var bump_action: ActorAction = behavior_stupid_bump_toward(game, enemy_p.location.position, true, true)
					if bump_action != null:
						closest = distance
						best_enemy_percept = enemy_p
						best_bump_action = bump_action

			if best_bump_action != null:
				_actor.activity = Activity.CHASING
				_actor.target_actor = best_enemy_percept.percepted as Actor
				return best_bump_action

	# 2 eat corpses.
	var corpses = filter_corpses(game, map_percepts)
	if corpses != null:
		var eat_corpses: ActorAction = behavior_go_eat_corpse(game, corpses)
		if eat_corpses != null:
			_actor.activity = Activity.IDLE
			return eat_corpses

	# 3 use exit (if ability)
	# move before following scents so the AI is more likely to move into basements etc...
	if _actor.model.abilities.ai_can_use_ai_exits && game.rules.roll_chance(USE_EXIT_CHANCE):
		var use_exit: ActorAction = behavior_use_exit(game,
			UseExitFlags.ATTACK_BLOCKING_ENEMIES | UseExitFlags.BREAK_BLOCKING_OBJECTS | UseExitFlags.DONT_BACKTRACK)
		if use_exit != null:
			# memory is obsolete, clear it.
			_mem_los_sensor.clear()
			_actor.activity = Activity.IDLE
			return use_exit

	# 4 move close to nearest undead master (if not master)
	if not _actor.model.abilities.is_undead_master:
		var nearest_master: Percept = filter_nearest(game,
			filter_actors(game, map_percepts, func(a: Actor) -> bool: return a.model.abilities.is_undead_master))
		if nearest_master != null:
			var bump_action: ActorAction = behavior_stupid_bump_toward(game,
				random_position_near(game.rules, _actor.location.map, nearest_master.location.position, 3),
				true, true)
			if bump_action != null:
				# MAASTEERRR!
				_actor.activity = Activity.FOLLOWING
				_actor.target_actor = nearest_master.percepted as Actor
				return bump_action

	# 5 move to highest undead master scent (if not master)
	if not _actor.model.abilities.is_undead_master:
		var track_master_action: ActorAction = behavior_track_scent(game, _master_smell_sensor.scents)
		if track_master_action != null:
			_actor.activity = Activity.TRACKING
			return track_master_action

	# 6 move to highest living scent
	var track_living_action: ActorAction = behavior_track_scent(game, _living_smell_sensor.scents)
	if track_living_action != null:
		_actor.activity = Activity.TRACKING
		return track_living_action

	# 7 **DISABLED** assault breakables (if ability)
	# (disabled in the C# original, kept disabled here)

	# 8 randomly push objects around (if ability OR skill STRONG)
	if game.rules.has_actor_push_ability(_actor) && game.rules.roll_chance(PUSH_OBJECT_CHANCE):
		var push_action: ActorAction = behavior_push_non_walkable_object(game)
		if push_action != null:
			_actor.activity = Activity.IDLE
			return push_action

	# 9 explore (if ability)
	if _actor.model.abilities.zombie_ai_explore:
		var explore_action: ActorAction = behavior_explore(game, _exploration)
		if explore_action != null:
			_actor.activity = Activity.IDLE
			return explore_action

	# 10 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null)
