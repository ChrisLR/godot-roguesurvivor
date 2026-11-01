class_name SoldierAI
extends OrderableAI
## Port of Gameplay/AI/SoldierAI.cs
## Soldier AI.

# Constants

const LOS_MEMORY: int = 10
const FOLLOW_LEADER_MIN_DIST: int = 1
const FOLLOW_LEADER_MAX_DIST: int = 2

const EXPLORATION_LOCATIONS: int = 30
const EXPLORATION_ZONES: int = 3

const BUILD_SMALL_FORT_CHANCE: int = 20
const BUILD_LARGE_FORT_CHANCE: int = 50
const START_FORT_LINE_CHANCE: int = 1

const DONT_LEAVE_BEHIND_EMOTE_CHANCE: int = 50

static var FIGHT_EMOTES: Array[String] = [
	"Damn",
	"Fuck I'm cornered",
	"Die",
]

# Fields

var _los_sensor: LOSSensor = null
var _mem_los_sensor: MemorizedSensor = null

var _exploration: ExplorationData = null


# BaseAI

func take_control(actor: Actor) -> void:
	super(actor)

	_exploration = ExplorationData.new(EXPLORATION_LOCATIONS, EXPLORATION_ZONES)


func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS | LOSSensor.SensingFilter.ITEMS)
	_mem_los_sensor = MemorizedSensor.new(_los_sensor, LOS_MEMORY)


func update_sensors(game: RogueGame) -> Array[Percept]:
	return _mem_los_sensor.sense(game, _actor)


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	var map_percepts = filter_same_map(game, percepts)

	# alpha10
	# don't run by default.
	_actor.is_running = false

	# 0. Equip best item
	var best_equip: ActorAction = behavior_equip_best_items(game, false, true)
	if best_equip != null:
		return best_equip

	# 1. Follow order
	if order != null:
		var order_action: ActorAction = execute_order(game, order, map_percepts, _exploration)
		if order_action == null:
			set_order(null)
		else:
			_actor.activity = Activity.FOLLOWING_ORDER
			return order_action

	###################################
	# 0 run away from primed explosives.
	# 1 throw grenades at enemies.
	# alpha10 OBSOLETE 2 equip weapon/armor.
	# 3 shout, fire/hit at nearest enemy.
	# 4 rest if tired
	# alpha10 obsolete and redundant with rule 3! 5 charge enemy.
	# 6 use med.
	# 7 sleep.
	# 8 chase old enemy.
	# 9 build fortification.
	# 10 hang around leader.
	# 11 (leader) don't leave followers behind.
	# 12 explore.
	# 13 wander.
	###################################

	# get data.
	var all_enemies = filter_enemies(game, map_percepts)
	var current_enemies = filter_current(game, all_enemies)
	var check_our_leader: bool = _actor.has_leader and not dont_follow_leader
	var has_current_enemies: bool = current_enemies != null
	var has_any_enemies: bool = all_enemies != null

	# exploration.
	_exploration.update(_actor.location)

	# 0 run away from primed explosives.
	var run_from_explosives: ActorAction = behavior_flee_from_explosives(game, filter_stacks(game, map_percepts))
	if run_from_explosives != null:
		_actor.activity = Activity.FLEEING_FROM_EXPLOSIVE
		return run_from_explosives

	# 1 throw grenades at enemies.
	if has_current_enemies:
		var throw_action: ActorAction = behavior_throw_grenade(game, _los_sensor.fov, current_enemies)
		if throw_action != null:
			return throw_action

	# 3 shout, fire/hit at nearest enemy.
	if has_current_enemies:
		# shout?
		if game.rules.roll_chance(50):
			var friends = filter_non_enemies(game, map_percepts)
			if friends != null:
				var shout_action: ActorAction = behavior_warn_friends(game, friends,
					(filter_nearest(game, current_enemies) as Percept).percepted as Actor)
				if shout_action != null:
					_actor.activity = Activity.IDLE
					return shout_action

		# fire?
		var fire_targets = filter_fire_targets(game, current_enemies)
		if fire_targets != null:
			var nearest_target: Percept = filter_nearest(game, fire_targets)
			var fire_action: ActorAction = behavior_ranged_attack(game, nearest_target)
			if fire_action != null:
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = nearest_target.percepted as Actor
				return fire_action

		# fight or flee?
		var allowed_charge_actions: int = RouteFinder.SpecialActions.JUMP | RouteFinder.SpecialActions.DOORS  # alpha10
		var fight_or_flee: ActorAction = behavior_fight_or_flee(game, current_enemies, true, true,
			ActorCourage.COURAGEOUS, FIGHT_EMOTES, allowed_charge_actions)
		if fight_or_flee != null:
			return fight_or_flee

	# 4 rest if tired
	var rest_action: ActorAction = behavior_rest_if_tired(game)
	if rest_action != null:
		_actor.activity = Activity.IDLE
		return rest_action

	# 6 use medicine
	var use_med_action: ActorAction = behavior_use_medecine(game, 2, 1, 2, 4, 2)
	if use_med_action != null:
		_actor.activity = Activity.IDLE
		return use_med_action

	# 7 sleep.
	if not has_any_enemies && would_like_to_sleep(game, _actor) && is_inside(_actor) \
			&& game.rules.can_actor_sleep(_actor)["ok"]:
		# secure sleep?
		var secure_sleep_action: ActorAction = behavior_secure_perimeter(game, _los_sensor.fov)
		if secure_sleep_action != null:
			_actor.activity = Activity.IDLE
			return secure_sleep_action

		# sleep.
		var sleep_action: ActorAction = behavior_sleep(game, _los_sensor.fov)
		if sleep_action != null:
			if sleep_action is ActionSleep:
				_actor.activity = Activity.SLEEPING
			return sleep_action

	# 8 chase old enemy
	var old_enemies = null
	if all_enemies != null:
		var turn_counter: int = _actor.location.map.local_time.turn_counter
		old_enemies = filter(game, all_enemies, func(p: Percept) -> bool: return p.turn != turn_counter)
	if old_enemies != null:
		var chase_percept: Percept = filter_nearest(game, old_enemies)

		# cheat a bit for good chasing behavior.
		if _actor.location == chase_percept.location:
			# memorized location reached, chase now the actor directly (cheat so they appear more intelligent)
			var chased_actor := chase_percept.percepted as Actor
			chase_percept = Percept.new(chased_actor, _actor.location.map.local_time.turn_counter, chased_actor.location)

		# chase.
		var charge_action: ActorAction = behavior_charge_enemy(game, chase_percept, false, false)
		if charge_action != null:
			_actor.activity = Activity.FIGHTING
			_actor.target_actor = chase_percept.percepted as Actor
			return charge_action

	# 9 build fortification
	# large fortification.
	if game.rules.roll_chance(BUILD_LARGE_FORT_CHANCE):
		var build_action: ActorAction = behavior_build_large_fortification(game, START_FORT_LINE_CHANCE)
		if build_action != null:
			_actor.activity = Activity.IDLE
			return build_action
	# small fortification.
	if game.rules.roll_chance(BUILD_SMALL_FORT_CHANCE):
		var build_action: ActorAction = behavior_build_small_fortification(game)
		if build_action != null:
			_actor.activity = Activity.IDLE
			return build_action

	# 10 hang around leader.
	if check_our_leader:
		var last_known_leader_position: Vector2i = _actor.leader.location.position
		var follow_action: ActorAction = behavior_hang_around_actor(game, _actor.leader, last_known_leader_position, FOLLOW_LEADER_MIN_DIST, FOLLOW_LEADER_MAX_DIST)
		if follow_action != null:
			_actor.activity = Activity.FOLLOWING
			_actor.target_actor = _actor.leader
			return follow_action

	# 11 (leader) don't leave followers behind.
	if _actor.count_followers > 0:
		var stick_together_r: Dictionary = behavior_dont_leave_followers_behind(game, 4)
		var stick_together: ActorAction = stick_together_r.action
		if stick_together != null:
			var target: Actor = stick_together_r.target

			# emote?
			if game.rules.roll_chance(DONT_LEAVE_BEHIND_EMOTE_CHANCE):
				if target.is_sleeping:
					game.do_emote(_actor, "patiently waits for %s to wake up." % target.name)
				else:
					if _los_sensor.fov.has(target.location.position):
						game.do_emote(_actor, "%s! Don't lag behind!" % target.name)
					else:
						game.do_emote(_actor, "Where the hell is %s?" % target.name)

			# go!
			_actor.activity = Activity.IDLE
			return stick_together

	# 12 explore
	var explore_action: ActorAction = behavior_explore(game, _exploration)
	if explore_action != null:
		_actor.activity = Activity.IDLE
		return explore_action

	# 13 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null, _exploration)
