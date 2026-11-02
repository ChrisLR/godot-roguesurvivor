class_name FeralDogAI
extends BaseAI
## Port of Gameplay/AI/FeralDogAI.cs
## alpha10: this is unused for now.

# Constants

const FOLLOW_NPCLEADER_MAXDIST: int = 1
const FOLLOW_PLAYERLEADER_MAXDIST: int = 1
const RUN_TO_TARGET_DISTANCE: int = 3  # dogs run to their target when close enough

static var FIGHT_EMOTES: Array[String] = [
	"waf",            # flee
	"waf!?",          # trapped
	"GRRRRR WAF WAF", # fight
]

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
	if not has_valid_location():
		return null
	var fov = _los_sensor.fov
	var map_percepts = filter_same_map(game, percepts)

	##############################################################
	# 1 defend our leader.
	# 2 attack or flee enemies.
	# 3 go eat food on floor if almost hungry
	# 4 go eat corpses if hungry
	# 5 rest or sleep
	# 6 follow leader
	# 7 wander
	##############################################################

	# 1 defend our leader
	if _actor.has_leader:
		var target: Actor = _actor.leader.target_actor
		if target != null && target.location.map == _actor.location.map:
			# emote: bark
			game.do_say(_actor, target, "GRRRRRR WAF WAF",
				RogueGame.Sayflags.IS_FREE_ACTION | RogueGame.Sayflags.IS_DANGER)
			# charge.
			var charge_enemy: ActorAction = behavior_stupid_bump_toward(game, target.location.position, true, false)
			if charge_enemy != null:
				run_to_if_close_to(game, target.location.position, RUN_TO_TARGET_DISTANCE)
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = target
				return charge_enemy

	var enemies = filter_enemies(game, map_percepts)
	var is_leader_visible: bool = _actor.has_leader && _los_sensor.fov.has(_actor.leader.location.position)
	var is_leader_fighting: bool = _actor.has_leader && is_adjacent_to_enemy(game, _actor.leader)

	# 2 attack or flee enemies.
	if enemies != null:
		var allowed_charge_actions: int = RouteFinder.SpecialActions.JUMP  # alpha10
		var ff: ActorAction = behavior_fight_or_flee(game, enemies, is_leader_visible, is_leader_fighting,
			directives.courage, FIGHT_EMOTES, allowed_charge_actions)
		if ff != null:
			# run to (or away if fleeing) if close.
			if _actor.target_actor != null:
				run_to_if_close_to(game, _actor.target_actor.location.position, RUN_TO_TARGET_DISTANCE)
			return ff

	# 3 go eat food on floor if almost hungry
	if game.is_almost_hungry(_actor):
		var items_stack = filter_stacks(game, map_percepts)
		if items_stack != null:
			var eat_food: ActorAction = behavior_go_eat_food_on_ground(game, items_stack)
			if eat_food != null:
				run_if_possible(game.rules)
				_actor.activity = Activity.IDLE
				return eat_food

	# 4 go eat corpses if hungry
	if game.rules.is_actor_hungry(_actor):
		var corpses = filter_corpses(game, map_percepts)
		if corpses != null:
			var eat_corpses: ActorAction = behavior_go_eat_corpse(game, corpses)
			if eat_corpses != null:
				run_if_possible(game.rules)
				_actor.activity = Activity.IDLE
				return eat_corpses

	# 5 rest or sleep
	if game.rules.is_actor_tired(_actor):
		_actor.activity = Activity.IDLE
		return ActionWait.new(_actor, game)
	if game.rules.is_actor_sleepy(_actor):
		_actor.activity = Activity.SLEEPING
		return ActionSleep.new(_actor, game)

	# 6 follow leader
	if _actor.has_leader:
		var last_known_leader_position: Vector2i = _actor.leader.location.position
		var max_dist: int = FOLLOW_PLAYERLEADER_MAXDIST if _actor.leader.is_player else FOLLOW_NPCLEADER_MAXDIST
		var follow_action: ActorAction = behavior_follow_actor(game, _actor.leader, last_known_leader_position, is_leader_visible, max_dist)
		if follow_action != null:
			_actor.is_running = false
			_actor.activity = Activity.FOLLOWING
			_actor.target_actor = _actor.leader
			return follow_action

	# 7 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null)


# Dogs specifics

func run_to_if_close_to(game: RogueGame, pos: Vector2i, close_distance: int) -> void:
	if game.rules.grid_distance_points(_actor.location.position, pos) <= close_distance:
		_actor.is_running = game.rules.can_actor_run(_actor)["ok"]
	else:
		_actor.is_running = false
