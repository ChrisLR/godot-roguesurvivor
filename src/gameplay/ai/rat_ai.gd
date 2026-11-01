class_name RatAI
extends BaseAI
## Port of Gameplay/AI/RatAI.cs
## Rat AI : used by Zombie Rat branch.

# Fields

var _los_sensor: LOSSensor = null
var _living_smell_sensor: SmellSensor = null


# BaseAI

func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS | LOSSensor.SensingFilter.CORPSES)
	_living_smell_sensor = SmellSensor.new(Odor.LIVING)


func update_sensors(game: RogueGame) -> Array[Percept]:
	var list: Array[Percept] = _los_sensor.sense(game, _actor)
	list.append_array(_living_smell_sensor.sense(game, _actor))
	return list


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	var fov = _los_sensor.fov
	var map_percepts = filter_same_map(game, percepts)

	##############################################################
	# 1 move closer to an enemy, nearest & visible enemies first
	# 2 eat corpses
	# 2 move to highest living scent
	# 3 wander
	##############################################################

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
					var bump_action: ActorAction = behavior_stupid_bump_toward(game, enemy_p.location.position, false, false)
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
					var bump_action: ActorAction = behavior_stupid_bump_toward(game, enemy_p.location.position, false, false)
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

	# 3 move to highest living scent
	var track_living_action: ActorAction = behavior_track_scent(game, _living_smell_sensor.scents)
	if track_living_action != null:
		_actor.activity = Activity.TRACKING
		return track_living_action

	# 4 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null)
