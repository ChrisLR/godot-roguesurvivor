class_name GangAI
extends OrderableAI
## Port of Gameplay/AI/GangAI.cs
## Gang AI : Bikers, Gangstas...

# Constants

const FOLLOW_NPCLEADER_MAXDIST: int = 1
const FOLLOW_PLAYERLEADER_MAXDIST: int = 1
const LOS_MEMORY: int = 10

const EXPLORATION_LOCATIONS: int = 30
const EXPLORATION_ZONES: int = 3

const DONT_LEAVE_BEHIND_EMOTE_CHANCE: int = 50

static var FIGHT_EMOTES: Array[String] = [
	"Fuck you",
	"Fuck it I'm trapped!",
	"Come on",
]

# alpha10
const CANT_GET_ITEM_EMOTE: String = "Fuck can't get that shit!"

# Fields

var _los_sensor: LOSSensor = null
var _memorized_sensor: MemorizedSensor = null

var _exploration: ExplorationData = null

# alpha10 needed as ref param to a new behavior but unused
var _dummy_percept_last_items_saw: Percept = null


# BaseAI

func take_control(actor: Actor) -> void:
	super(actor)

	_exploration = _track_exploration(ExplorationData.new(EXPLORATION_LOCATIONS, EXPLORATION_ZONES))


func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS | LOSSensor.SensingFilter.ITEMS)
	_memorized_sensor = _track_memorized_sensor(MemorizedSensor.new(_los_sensor, LOS_MEMORY))


func update_sensors(game: RogueGame) -> Array[Percept]:
	return _memorized_sensor.sense(game, _actor)


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	if not has_valid_location():
		return null
	var fov = _los_sensor.fov
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
		var order_action: ActorAction = execute_order(game, order, map_percepts, _exploration)
		if order_action == null:
			set_order(null)
		else:
			_actor.activity = Activity.FOLLOWING_ORDER
			return order_action

	######################################################################
	# partial copy of Civilian AI 8) but always courageous and gets into fights.
	# BEHAVIOR
	# - FLAGS
	# "courageous" : always if not tired.
	# - RULES
	# alpha10 OBSOLETE 1 equip weapon/armor
	# 2 fire at nearest.
	# 3 shout, fight or flee.
	# 4 use medecine
	# 5 rest if tired
	# // alpa10 obsolete and redundant with rule 3!! 6 charge enemy if courageous
	# 7 eat when hungry (also eat corpses)
	# 8 sleep.
	# 9 drop light/tracker with no batteries
	# alpa10 OBSOLETE 10 equip light/tracker
	# 11 get nearby item (not if seeing enemy)
	# 12 steal item from someone.
	# 13 tear down barricade
	# 14 follow leader
	# 15 take lead (if leadership)
	# 16 (leader) don't leave follower behind.
	# 17 explore
	# 18 wander
	######################################################################

	# get data.
	var all_enemies = filter_enemies(game, map_percepts)
	var current_enemies = filter_current(game, all_enemies)
	var has_current_enemies: bool = current_enemies != null
	var has_any_enemies: bool = all_enemies != null
	var check_our_leader: bool = _actor.has_leader and not dont_follow_leader
	var see_leader: bool = check_our_leader && fov.has(_actor.leader.location.position)
	var is_leader_fighting: bool = check_our_leader && is_adjacent_to_enemy(game, _actor.leader)
	var _is_courageous: bool = not game.rules.is_actor_tired(_actor)

	# exploration.
	_exploration.update(_actor.location)

	# alpha10 needed due to uggraded get item behavior
	# clear taboo tiles : periodically or when changing maps.
	if _actor.location.map.local_time.turn_counter % WorldTime.TURNS_PER_HOUR == 0 \
			|| (prev_location != null && prev_location.map != _actor.location.map):
		clear_taboo_tiles()

	# 2 fire at nearest enemy (always if has leader, half of the time if not)
	if has_current_enemies && (check_our_leader || game.rules.roll_chance(50)):
		var fire_targets = filter_fire_targets(game, current_enemies)
		if fire_targets != null:
			var nearest_target: Percept = filter_nearest(game, fire_targets)
			var fire_action: ActorAction = behavior_ranged_attack(game, nearest_target)
			if fire_action != null:
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = nearest_target.percepted as Actor
				return fire_action

	# 3 shout, fight or flee
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

		# fight or flee.
		var allowed_charge_actions: int = RouteFinder.SpecialActions.JUMP | RouteFinder.SpecialActions.DOORS  # alpha10
		# gangs are allowed to make a mess :)
		allowed_charge_actions |= RouteFinder.SpecialActions.BREAK | RouteFinder.SpecialActions.PUSH
		var fight_or_flee: ActorAction = behavior_fight_or_flee(game, current_enemies, see_leader, is_leader_fighting,
			ActorCourage.COURAGEOUS, FIGHT_EMOTES, allowed_charge_actions)
		if fight_or_flee != null:
			return fight_or_flee

	# 4 use medecine
	var use_med_action: ActorAction = behavior_use_medecine(game, 2, 1, 2, 4, 2)
	if use_med_action != null:
		_actor.activity = Activity.IDLE
		return use_med_action

	# 5 rest if tired
	var rest_action: ActorAction = behavior_rest_if_tired(game)
	if rest_action != null:
		_actor.activity = Activity.IDLE
		return ActionWait.new(_actor, game)

	# 7 eat when hungry (also eat corpses)
	if game.rules.is_actor_hungry(_actor):
		var eat_action: ActorAction = behavior_eat(game)
		if eat_action != null:
			_actor.activity = Activity.IDLE
			return eat_action
		if game.rules.is_actor_starving(_actor) || game.rules.is_actor_insane(_actor):
			eat_action = behavior_go_eat_corpse(game, filter_corpses(game, map_percepts))
			if eat_action != null:
				_actor.activity = Activity.IDLE
				return eat_action

	# 8 sleep.
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

	# 9 drop light/tracker with no batteries
	var drop_out_of_batteries: ActorAction = behavior_drop_useless_item(game)
	if drop_out_of_batteries != null:
		_actor.activity = Activity.IDLE
		return drop_out_of_batteries

	# 11 get nearby item (not if seeing enemy)
	# ignore not currently visible items & blocked items.
	# alpha10 upgraded rule to use the same new core behavior as CivilianAI with custom params
	if not has_current_enemies:
		# alpha10 new common behaviour code, also used by CivilianAI, but Gangs can break and push
		var get_item_r: Dictionary = behavior_go_get_interesting_items(game, map_percepts,
			true, true, CANT_GET_ITEM_EMOTE, false)
		if get_item_r.action != null:
			return get_item_r.action
		_dummy_percept_last_items_saw = get_item_r.last_items_saw

	# 12 steal item from someone.
	if not has_current_enemies:
		var may_steal_from = filter_actors(game, filter_current(game, map_percepts),
			func(a: Actor) -> bool:
				if a.inventory == null || a.inventory.count_items == 0 || is_friend_of(game, a):
					return false
				if game.rules.roll_chance(game.rules.actor_unsuspicous_chance(_actor, a)):
					# emote.
					game.do_emote(a, "moves unnoticed by %s." % _actor.name)
					# unnoticed.
					return false
				return has_any_interesting_item(game, a.inventory, ItemSource.ANOTHER_ACTOR))

		if may_steal_from != null:
			# alpha10 make sure to consider only reachable victims
			var allowed_actions: int = RouteFinder.SpecialActions.ADJ_TO_DEST_IS_GOAL | RouteFinder.SpecialActions.JUMP | RouteFinder.SpecialActions.DOORS
			# gangs can break & push stuff
			allowed_actions |= RouteFinder.SpecialActions.BREAK | RouteFinder.SpecialActions.PUSH
			may_steal_from = filter_out_unreachable_percepts(game, may_steal_from, allowed_actions)

			if may_steal_from.size() > 0:
				# get data.
				var nearest: Percept = filter_nearest(game, may_steal_from)
				var victim := nearest.percepted as Actor
				var want_it: Item = first_interesting_item(game, victim.inventory, ItemSource.ANOTHER_ACTOR)

				# make an enemy of him.
				game.do_make_aggression(_actor, victim)

				# declare my evil intentions.
				_actor.activity = Activity.CHASING
				_actor.target_actor = victim
				return ActionSay.new(_actor, game, victim,
					"Hey! That's some nice %s you have here!" % want_it.model.single_name,
					RogueGame.Sayflags.IS_IMPORTANT | RogueGame.Sayflags.IS_DANGER)

	# 13 tear down barricade
	var attack_barricade_action: ActorAction = behavior_attack_barricade(game)
	if attack_barricade_action != null:
		_actor.activity = Activity.IDLE
		return attack_barricade_action

	# 14 follow leader
	if check_our_leader:
		var last_known_leader_position: Vector2i = _actor.leader.location.position
		var is_leader_visible: bool = fov.has(_actor.leader.location.position)
		var max_dist: int = FOLLOW_PLAYERLEADER_MAXDIST if _actor.leader.is_player else FOLLOW_NPCLEADER_MAXDIST
		var follow_action: ActorAction = behavior_follow_actor(game, _actor.leader, last_known_leader_position, is_leader_visible, max_dist)
		if follow_action != null:
			_actor.activity = Activity.FOLLOWING
			_actor.target_actor = _actor.leader
			return follow_action

	# 15 take lead (if leadership)
	var is_leader: bool = _actor.sheet.skill_table.get_skill_level(Skills.IDs.LEADERSHIP) >= 1
	var can_lead: bool = not check_our_leader && is_leader && _actor.count_followers < game.rules.actor_max_followers(_actor)
	if can_lead:
		var nearest_friend: Percept = filter_nearest(game, filter_non_enemies(game, map_percepts))
		if nearest_friend != null:
			var lead_action: ActorAction = behavior_lead_actor(game, nearest_friend)
			if lead_action != null:
				_actor.activity = Activity.IDLE
				_actor.target_actor = nearest_friend.percepted as Actor
				return lead_action

	# 16 (leader) don't leave followers behind.
	if _actor.count_followers > 0:
		var stick_together_r: Dictionary = behavior_dont_leave_followers_behind(game, 3)
		var stick_together: ActorAction = stick_together_r.action
		if stick_together != null:
			var target: Actor = stick_together_r.target

			# emote?
			if game.rules.roll_chance(DONT_LEAVE_BEHIND_EMOTE_CHANCE):
				if target.is_sleeping:
					game.do_emote(_actor, "patiently waits for %s to wake up." % target.name)
				else:
					if _los_sensor.fov.has(target.location.position):
						game.do_emote(_actor, "Hey %s! Fucking move!" % target.name)
					else:
						game.do_emote(_actor, "Where is that %s retard?" % target.name)

			# go!
			_actor.activity = Activity.IDLE
			return stick_together

	# 17 explore
	var explore_action: ActorAction = behavior_explore(game, _exploration)
	if explore_action != null:
		_actor.activity = Activity.IDLE
		return explore_action

	# 18 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null, _exploration)
