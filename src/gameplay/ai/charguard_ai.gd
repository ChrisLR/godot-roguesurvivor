class_name CHARGuardAI
extends OrderableAI
## Port of Gameplay/AI/CHARGuardAI.cs
## CHAR Guard AI.

# Constants

const LOS_MEMORY: int = 10

static var FIGHT_EMOTES: Array[String] = [
	"Go away",
	"Damn it I'm trapped!",
	"Hey",
]

# Fields

var _los_sensor: LOSSensor = null
var _memorized_sensor: MemorizedSensor = null


# BaseAI

func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS | LOSSensor.SensingFilter.ITEMS)
	_memorized_sensor = _track_memorized_sensor(MemorizedSensor.new(_los_sensor, LOS_MEMORY))


func take_control(actor: Actor) -> void:
	super(actor)


func update_sensors(game: RogueGame) -> Array[Percept]:
	return _memorized_sensor.sense(game, _actor)


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	if not has_valid_location():
		return null
	var map_percepts = filter_same_map(game, percepts)

	# alpha10
	# don't run by default.
	_actor.is_running = false

	# 0. Equip best item
	var best_equip: ActorAction = behavior_equip_best_items(game, true, true)
	if best_equip != null:
		return best_equip

	# 1. Follow order
	if order != null:
		var order_action: ActorAction = execute_order(game, order, map_percepts, null)
		if order_action == null:
			set_order(null)
		else:
			_actor.activity = Activity.FOLLOWING_ORDER
			return order_action

	#######################################
	# alpha10 OBSOLETE 1 equip weapon
	# alpha10 OBSOLETE 2 equip armor
	# 3 fire at nearest enemy.
	# 4 hit adjacent enemy.
	# 5 warn trepassers.
	# 6 shout
	# 7 rest if tired
	# 8 charge enemy
	# 9 sleep when sleepy.
	# 10 follow leader.
	# 11 wander in CHAR office.
	# 12 wander.
	#######################################

	# don't run by default.
	_actor.is_running = false

	# get data.
	var all_enemies = filter_enemies(game, map_percepts)
	var current_enemies = filter_current(game, all_enemies)
	var check_our_leader: bool = _actor.has_leader and not dont_follow_leader
	var has_any_enemies: bool = all_enemies != null

	# 3 fire at nearest enemy.
	if current_enemies != null:
		var fire_targets = filter_fire_targets(game, current_enemies)
		if fire_targets != null:
			var nearest_target: Percept = filter_nearest(game, fire_targets)
			var target_actor := nearest_target.percepted as Actor

			var fire_action: ActorAction = behavior_ranged_attack(game, nearest_target)
			if fire_action != null:
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = target_actor
				return fire_action

	# 4 hit adjacent enemy
	if current_enemies != null:
		# fight or flee?
		var allowed_charge_actions: int = RouteFinder.SpecialActions.JUMP | RouteFinder.SpecialActions.DOORS  # alpha10
		var fight_or_flee: ActorAction = behavior_fight_or_flee(game, current_enemies, true, true,
			ActorCourage.COURAGEOUS, FIGHT_EMOTES, allowed_charge_actions)
		if fight_or_flee != null:
			return fight_or_flee

	# 5 warn trepassers.
	var non_enemies = filter_non_enemies(game, map_percepts)
	if non_enemies != null:
		var turn_counter: int = _actor.location.map.local_time.turn_counter
		var trespassers = filter(game, non_enemies,
			func(p: Percept) -> bool:
				var other := p.percepted as Actor
				if other.faction == game.game_factions.the_char_corporation():
					return false

				# alpha10 bug fix only if visible right now!
				if p.turn != turn_counter:
					return false

				return game.is_in_char_property(other.location))
		if trespassers != null:
			# Hey YOU!
			var trespasser := filter_nearest(game, trespassers).percepted as Actor

			game.do_make_aggression(_actor, trespasser)

			_actor.activity = Activity.FIGHTING
			_actor.target_actor = trespasser
			return ActionSay.new(_actor, game, trespasser, "Hey YOU!",
				RogueGame.Sayflags.IS_IMPORTANT | RogueGame.Sayflags.IS_DANGER)

	# 6 shout
	if has_any_enemies:
		if non_enemies != null:
			var shout_action: ActorAction = behavior_warn_friends(game, non_enemies,
				(filter_nearest(game, all_enemies) as Percept).percepted as Actor)
			if shout_action != null:
				_actor.activity = Activity.IDLE
				return shout_action

	# 7 rest if tired
	var rest_action: ActorAction = behavior_rest_if_tired(game)
	if rest_action != null:
		_actor.activity = Activity.IDLE
		return ActionWait.new(_actor, game)

	# 8 charge/chase enemy
	if all_enemies != null:
		var chase_percept: Percept = filter_nearest(game, all_enemies)

		# cheat a bit for good chasing behavior.
		if _actor.location == chase_percept.location:
			# memorized location reached, chase now the actor directly (cheat so they appear more intelligent)
			var chased_actor := chase_percept.percepted as Actor
			chase_percept = Percept.new(chased_actor, _actor.location.map.local_time.turn_counter, chased_actor.location)

		# alpha10 chase only if reachable
		if can_reach_simple(game, chase_percept.location.position, RouteFinder.SpecialActions.DOORS | RouteFinder.SpecialActions.JUMP):
			# chase.
			var charge_action: ActorAction = behavior_charge_enemy(game, chase_percept, false, false)
			if charge_action != null:
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = chase_percept.percepted as Actor
				return charge_action

	# 9 sleep when sleepy
	if game.rules.is_actor_sleepy(_actor) and not has_any_enemies:
		var sleep_action: ActorAction = behavior_sleep(game, _los_sensor.fov)
		if sleep_action != null:
			if sleep_action is ActionSleep:
				_actor.activity = Activity.SLEEPING
			return sleep_action

	# 10 follow leader
	if check_our_leader:
		var last_known_leader_position: Vector2i = _actor.leader.location.position
		var is_leader_visible: bool = _los_sensor.fov.has(_actor.leader.location.position)
		var follow_action: ActorAction = behavior_follow_actor(game, _actor.leader, last_known_leader_position, is_leader_visible, 1)
		if follow_action != null:
			_actor.activity = Activity.FOLLOWING
			_actor.target_actor = _actor.leader
			return follow_action

	# 11 wander in CHAR office.
	var wander_in_office_action: ActorAction = behavior_wander(game, func(loc: Location) -> bool: return RogueGame.is_in_char_office(loc), null)
	if wander_in_office_action != null:
		_actor.activity = Activity.IDLE
		return wander_in_office_action

	# 12 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null)
