class_name SkeletonAI
extends BaseAI
## Port of Gameplay/AI/SkeletonAI.cs
## Skeleton AI : used by Skeleton branch.

# Constants

const IDLE_CHANCE: int = 80

# Fields

var _los_sensor: LOSSensor = null


# BaseAI

func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS)


func update_sensors(game: RogueGame) -> Array[Percept]:
	return _los_sensor.sense(game, _actor)


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	var map_percepts = filter_same_map(game, percepts)

	############################################
	# 1 move in straight line to nearest enemy
	# 2 idle? % chance.
	# 3 wander
	############################################

	# 1 move in straight line to nearest enemy
	var nearest_enemy: Percept = filter_nearest(game, filter_enemies(game, map_percepts))
	if nearest_enemy != null:
		var bump_action: ActorAction = behavior_stupid_bump_toward(game, nearest_enemy.location.position, true, false)
		if bump_action != null:
			_actor.activity = Activity.CHASING
			_actor.target_actor = nearest_enemy.percepted as Actor
			return bump_action

	# 2 idle? % chance.
	if game.rules.roll_chance(IDLE_CHANCE):
		_actor.activity = Activity.IDLE
		return ActionWait.new(_actor, game)

	# 3 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null)
