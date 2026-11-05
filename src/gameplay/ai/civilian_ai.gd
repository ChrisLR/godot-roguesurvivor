class_name CivilianAI
extends OrderableAI
## Port of Gameplay/AI/CivilianAI.cs
## Civilian AI : Civilians, Survivors, Cops.

# Constants

const FOLLOW_NPCLEADER_MAXDIST: int = 1
const FOLLOW_PLAYERLEADER_MAXDIST: int = 1

const EXPLORATION_MAX_LOCATIONS: int = 30
const EXPLORATION_MAX_ZONES: int = 6  # alpha10.1 doubled from 3 to 6

const USE_EXIT_CHANCE: int = 20

const BUILD_TRAP_CHANCE: int = 50
const BUILD_SMALL_FORT_CHANCE: int = 20
const BUILD_LARGE_FORT_CHANCE: int = 50
const START_FORT_LINE_CHANCE: int = 1

const TELL_FRIEND_ABOUT_RAID_CHANCE: int = 20
const TELL_FRIEND_ABOUT_ENEMY_CHANCE: int = 10
const TELL_FRIEND_ABOUT_ITEMS_CHANCE: int = 10
const TELL_FRIEND_ABOUT_SOLDIER_CHANCE: int = 20

const MIN_TURNS_SAFE_TO_SLEEP: int = 10

const USE_STENCH_KILLER_CHANCE: int = 75

const HUNGRY_CHARGE_EMOTE_CHANCE: int = 50
const HUNGRY_PUSH_OBJECTS_CHANCE: int = 25

const LAW_ENFORCE_CHANCE: int = 30

const DONT_LEAVE_BEHIND_EMOTE_CHANCE: int = 50

static var FIGHT_EMOTES: Array[String] = [
	"Go away",              # flee
	"Damn it I'm trapped!", # trapped
	"I'm not afraid",       # fight
]

# alpha10
const CANT_GET_ITEM_EMOTE: String = "Mmmh. Looks like I can't reach what I want."

# Unique emotes.
static var BIG_BEAR_EMOTES: Array[String] = [
	"You fool",   # flee
	"I'm fooled!", # trapped
	"Be a man",   # fight
]
static var FAMU_FATARU_EMOTES: Array[String] = [
	"Bakemono",   # flee
	"Nani!?",     # trapped
	"Kawaii",     # fight
]
static var SANTAMAN_EMOTES: Array[String] = [
	"DEM BLOODY KIDS!",                          # flee
	"LEAVE ME ALONE I AIN'T HAVE NO PRESENTS!",  # trapped
	"MERRY FUCKIN' CHRISTMAS",                   # fight
]
static var ROGUEDJACK_EMOTES: Array[String] = [
	"Sorry butt I am le busy,",                  # flee
	"I should have redone ze AI rootines!",      # trapped
	"Let me test le something on you",           # fight
]
static var DUCKMAN_EMOTES: Array[String] = [
	"I'LL QUACK YOU BACK",      # flee
	"THIS IS MY FINAL QUACK",   # trapped
	"I'M GONNA QUACK YOU",      # fight
]
static var HANS_VON_HANZ_EMOTES: Array[String] = [
	"RAUS",             # flee
	"MEIN FUHRER!",     # trapped
	"KOMM HIER BITE",   # fight
]

# Fields

var _los_sensor: LOSSensor = null

var _safe_turns: int = 0
var _exploration: ExplorationData = null

var _emotes = null


# BaseAI

func take_control(actor: Actor) -> void:
	super(actor)

	_safe_turns = 0
	_exploration = _track_exploration(ExplorationData.new(EXPLORATION_MAX_LOCATIONS, EXPLORATION_MAX_ZONES))

	_last_enemy_saw = null
	_last_items_saw = null
	_last_soldier_saw = null
	_last_raid_heard = null
	_emotes = null


func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS | LOSSensor.SensingFilter.ITEMS | LOSSensor.SensingFilter.CORPSES)


func update_sensors(game: RogueGame) -> Array[Percept]:
	# emotes!
	if _emotes == null:
		# FIXME: uggly code.
		if _actor.is_unique:
			if _actor == game.session.unique_actors.big_bear.the_actor:
				_emotes = BIG_BEAR_EMOTES
			elif _actor == game.session.unique_actors.famu_fataru.the_actor:
				_emotes = FAMU_FATARU_EMOTES
			elif _actor == game.session.unique_actors.santaman.the_actor:
				_emotes = SANTAMAN_EMOTES
			elif _actor == game.session.unique_actors.roguedjack.the_actor:
				_emotes = ROGUEDJACK_EMOTES
			elif _actor == game.session.unique_actors.duckman.the_actor:
				_emotes = DUCKMAN_EMOTES
			elif _actor == game.session.unique_actors.hans_von_hanz.the_actor:
				_emotes = HANS_VON_HANZ_EMOTES
			else:
				_emotes = FIGHT_EMOTES
		else:
			_emotes = FIGHT_EMOTES

	# sense.
	return _los_sensor.sense(game, _actor)


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	if not has_valid_location():
		return null
	var map_percepts = filter_same_map(game, percepts)

	#######################
	# 0. Equip best item.  # alpha10
	# 1. Follow order
	# 2. Normal behavior.
	#######################

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

	# 2. Normal behavior.
	######################################################################
	# BEHAVIOR
	# - FLAGS
	# "courageous" : has leader, see leader, he is fighting and actor not tired.
	# - RULES
	# 0 run away from primed explosives.
	# 1 throw grenades at enemies.
	# alpha10 OBSOLETE 2 equip weapon/armor
	# 3 fire at nearest (always if has leader, half of the time if not)  - check directives
	# 4 fight or flee, shout
	# 5 use medicine
	# 6 rest if tired
	# alpha10 obsolete and redundant with rule 4! 7 charge enemy if courageous
	# 8 eat when hungry (also eat corpses)
	# 9 sleep when almost sleepy and safe.
	# 10 drop light/tracker with no batteries
	# alpha10 OBSOLETE 11 equip light/tracker/scent spray
	# 12 make room for food items if needed.
	# 13 get nearby item/trade (not if seeing enemy) - check directives.
	# 14 if hungry and no food, charge at people for food (option, not follower or law enforcer)
	# 15 use stench killer.
	# 16 close door behind me.
	# 17 use entertainment
	# 18 follow leader.
	# 19 take lead (if leadership)
	# 20 if hungry, tear down barricades & push objects.
	# 21 go revive corpse.
	# 22 use exit.
	# 23 build trap or fortification.
	# 24 tell friend about latest raid.
	# 25 tell friend about latest friendly soldier.
	# 26 tell friend about latest enemy.
	# 27 tell friend about latest items.
	# 28 (law enforcer) watch for murderers.
	# 29 (leader) don't leave followers behind.
	# 30 explore.
	# 31 wander.
	######################################################################

	# get data.
	var enemies = filter_enemies(game, map_percepts)
	var has_enemies: bool = enemies != null and not enemies.is_empty()
	var check_our_leader: bool = _actor.has_leader and not dont_follow_leader
	var see_leader: bool = check_our_leader && _los_sensor.fov.has(_actor.leader.location.position)
	var is_leader_fighting: bool = check_our_leader && is_adjacent_to_enemy(game, _actor.leader)
	var _is_courageous: bool = check_our_leader && see_leader && is_leader_fighting && not game.rules.is_actor_tired(_actor)

	# safety counter.
	if has_enemies:
		_safe_turns = 0
	else:
		_safe_turns += 1

	# exploration.
	_exploration.update(_actor.location)

	# clear taboo tiles : periodically or when changing maps.
	if _actor.location.map.local_time.turn_counter % WorldTime.TURNS_PER_HOUR == 0 \
			|| (prev_location != null && prev_location.map != _actor.location.map):
		clear_taboo_tiles()
	# clear trades.
	if _actor.location.map.local_time.turn_counter % WorldTime.TURNS_PER_DAY == 0:
		clear_taboo_trades()

	# last enemy saw.
	if has_enemies:
		_last_enemy_saw = enemies[game.rules.roll(0, enemies.size())]

	# 0 run away from primed explosives.
	var run_from_explosives: ActorAction = behavior_flee_from_explosives(game, filter_stacks(game, map_percepts))
	if run_from_explosives != null:
		_actor.activity = Activity.FLEEING_FROM_EXPLOSIVE
		return run_from_explosives

	# 1 throw grenades at enemies.
	# if directive off, unequip.
	if not directives.can_throw_grenades:
		# unequip grenade?
		var eq_grenade := _actor.get_equipped_weapon() as ItemGrenade
		if eq_grenade != null:
			var unequip_gre: ActorAction = ActionUnequipItem.new(_actor, game, eq_grenade)
			if unequip_gre.is_legal():
				_actor.activity = Activity.IDLE
				return unequip_gre
	# throw?
	if has_enemies:
		var throw_action: ActorAction = behavior_throw_grenade(game, _los_sensor.fov, enemies)
		if throw_action != null:
			return throw_action

	# 3 fire at nearest enemy
	if has_enemies && directives.can_fire_weapons && _actor.get_equipped_weapon() is ItemRangedWeapon:
		var fire_targets = filter_fire_targets(game, enemies)
		if fire_targets != null:
			var nearest_target: Percept = filter_nearest(game, fire_targets)
			var target := nearest_target.percepted as Actor

			# flee contact from someone SLOWER with no ranged weapon.
			if game.rules.grid_distance_points(nearest_target.location.position, _actor.location.position) == 1 \
					&& not has_equiped_ranged_weapon(target) \
					&& has_speed_advantage(game, _actor, target):
				# flee!
				var flee_action: ActorAction = behavior_walk_away_from(game, nearest_target)
				if flee_action != null:
					run_if_possible(game.rules)
					_actor.activity = Activity.FLEEING
					return flee_action

			# fire ze missiles!
			var fire_action: ActorAction = behavior_ranged_attack(game, nearest_target)
			if fire_action != null:
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = target
				return fire_action

	# 4 fight or flee, shout
	if has_enemies:
		# shout?
		if game.rules.roll_chance(50):
			var friends = filter_non_enemies(game, map_percepts)
			if friends != null:
				var shout_action: ActorAction = behavior_warn_friends(game, friends,
					(filter_nearest(game, enemies) as Percept).percepted as Actor)
				if shout_action != null:
					_actor.activity = Activity.IDLE
					return shout_action
		# fight or flee.
		var allowed_charge_actions: int = RouteFinder.SpecialActions.JUMP | RouteFinder.SpecialActions.DOORS  # alpha10
		var fight_or_flee: ActorAction = behavior_fight_or_flee(game, enemies, see_leader, is_leader_fighting,
			directives.courage, _emotes, allowed_charge_actions)
		if fight_or_flee != null:
			return fight_or_flee

	# 5 use medicine
	var use_med_action: ActorAction = behavior_use_medecine(game, 2, 1, 2, 4, 2)
	if use_med_action != null:
		_actor.activity = Activity.IDLE
		return use_med_action

	# 6 rest if tired
	var rest_action: ActorAction = behavior_rest_if_tired(game)
	if rest_action != null:
		_actor.activity = Activity.IDLE
		return ActionWait.new(_actor, game)

	# 8 eat when hungry (also eat corpses)
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

	# 9 sleep when almost sleepy and safe.
	if _safe_turns >= MIN_TURNS_SAFE_TO_SLEEP && directives.can_sleep \
			&& would_like_to_sleep(game, _actor) && is_inside(_actor) && game.rules.can_actor_sleep(_actor)["ok"]:
		# secure sleep.
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

	# 10 drop useless light/tracker/spray
	var drop_useless: ActorAction = behavior_drop_useless_item(game)
	if drop_useless != null:
		_actor.activity = Activity.IDLE
		return drop_useless

	# 12 make room for food items if needed.
	# &&
	# 13 get nearby item/trade (not if seeing enemy)
	# ignore not currently visible items & blocked items.
	if not has_enemies && directives.can_take_items:
		var map: Map = _actor.location.map

		# Get items
		# alpha10 new common behaviour code, also used by GangAI
		var get_item_r: Dictionary = behavior_go_get_interesting_items(game, map_percepts,
			false, false, CANT_GET_ITEM_EMOTE, true)
		if get_item_r.action != null:
			return get_item_r.action
		_last_items_saw = get_item_r.last_items_saw

		# Trade
		if directives.can_trade:
			# get actors we want to trade with.
			var turn_counter: int = map.local_time.turn_counter
			var trading_actors = filter_out(game, filter_non_enemies(game, map_percepts),
				func(p: Percept) -> bool:
					if p.turn != turn_counter:
						return true
					var other: Actor = p.percepted if p.percepted is Actor else null
					if other == null:
						return true
					# dont bother player or someone we can't trade with or already did trade.
					if other.is_player:
						return true
					if not game.rules.can_actor_initiate_trade_with(_actor, other)["ok"]:
						return true
					if is_actor_taboo_trade(other):
						return true
					# alpha10 dont bother someone who is fighting or fleeing
					if other.activity == Activity.CHASING || other.activity == Activity.FIGHTING \
							|| other.activity == Activity.FLEEING || other.activity == Activity.FLEEING_FROM_EXPLOSIVE:
						return true
					# dont bother if no interesting items.
					if not has_any_interesting_item(game, other.inventory, ItemSource.ANOTHER_ACTOR):
						return true
					if not ((other.controller as BaseAI).has_any_interesting_item(game, _actor.inventory, ItemSource.ANOTHER_ACTOR)):
						return true
					# alpha10 reject if unreachable by baseai simple behaviours
					if not can_reach_simple(game, other.location.position, RouteFinder.SpecialActions.DOORS | RouteFinder.SpecialActions.JUMP):
						return true
					# don't reject.
					return false)
			# trade with nearest.
			if trading_actors != null:
				var trade_target := filter_nearest(game, trading_actors).percepted as Actor
				if game.rules.is_adjacent(_actor.location, trade_target.location):
					var trade_action: ActorAction = ActionTrade.new(_actor, game, trade_target)
					if trade_action.is_legal():
						# remember we tried to trade.
						mark_actor_as_recent_trade(trade_target)
						# say, so we make sure we spend a turn and won't loop.
						game.do_say(_actor, trade_target, "Hey %s, let's make a deal!" % trade_target.name,
							RogueGame.Sayflags.NONE)
						return trade_action
				else:
					var bump: ActorAction = behavior_intelligent_bump_toward(game, trade_target.location.position, false, false)
					if bump != null:
						# alpha10 announce it to make it clear to the player whats happening but dont spend AP (free action)
						# might spam for a few turns, but its better than not understanding whats going on.
						game.do_say(_actor, trade_target, "Hey %s, let's make a deal!" % trade_target.name,
							RogueGame.Sayflags.IS_FREE_ACTION)

						_actor.activity = Activity.FOLLOWING
						_actor.target_actor = trade_target
						return bump

	# 14 if hungry and no food, charge at people for food (option, not follower or law enforcer)
	if RogueGame.options.is_aggressive_hungry_civilians_on \
			&& map_percepts != null && not _actor.has_leader && not _actor.model.abilities.is_law_enforcer \
			&& game.rules.is_actor_hungry(_actor) && has_no_food_items(_actor):
		var target_for_food: Percept = filter_nearest(game, filter_actors(game, map_percepts,
			func(a: Actor) -> bool:
				# reject self, dead and leader/follower.
				if a == _actor:
					return false
				if a.is_dead:
					return false
				if a.inventory == null || a.inventory.is_empty:
					return false
				if a.leader == _actor || _actor.leader == a:
					return false

				# actor has food or is standing on food.
				if a.inventory.has_item_of_type(ItemFood):
					return true
				var ground_inv = a.location.map.get_items_at(a.location.position)
				if ground_inv == null || ground_inv.is_empty:
					return false
				return ground_inv.has_item_of_type(ItemFood)))

		if target_for_food != null:
			# alpha10 hungry civs can break and push
			var charge_action: ActorAction = behavior_charge_enemy(game, target_for_food, true, true)
			if charge_action != null:
				# randomly emote.
				if game.rules.roll_chance(HUNGRY_CHARGE_EMOTE_CHANCE):
					game.do_say(_actor, target_for_food.percepted as Actor, "HEY! YOU! SHARE SOME FOOD!",
						RogueGame.Sayflags.IS_FREE_ACTION | RogueGame.Sayflags.IS_DANGER)

				# chaaarge!
				_actor.activity = Activity.FIGHTING
				_actor.target_actor = target_for_food.percepted as Actor
				return charge_action

	# 15 use stench killer.
	if game.rules.roll_chance(USE_STENCH_KILLER_CHANCE):
		var spray_action: ActorAction = behavior_use_stench_killer(game)
		if spray_action != null:
			_actor.activity = Activity.IDLE
			return spray_action

	# 16 close door behind me.
	var close_behind_me: ActorAction = behavior_close_door_behind_me(game, prev_location)
	if close_behind_me != null:
		_actor.activity = Activity.IDLE
		return close_behind_me

	# 17 use entertainment
	if _actor.model.abilities.has_sanity:
		if _actor.sanity < 0.75 * game.rules.actor_max_sanity(_actor):
			var ent_action: ActorAction = behavior_use_entertainment(game)
			if ent_action != null:
				_actor.activity = Activity.IDLE
				return ent_action
		# TODO -- consider moving this to DropUselessItems()
		var drop_ent: ActorAction = behavior_drop_boring_entertainment(game)
		if drop_ent != null:
			_actor.activity = Activity.IDLE
			return drop_ent

	# 18 build trap or fortification.
	# alpha10.1 moved trap/fortification rule before following leader rule so they will do it much more often
	if game.rules.roll_chance(BUILD_TRAP_CHANCE):
		var trap_action: ActorAction = behavior_build_trap(game)
		if trap_action != null:
			_actor.activity = Activity.IDLE
			return trap_action
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

	# 19 follow leader
	if check_our_leader:
		var last_known_leader_position: Vector2i = _actor.leader.location.position
		var is_leader_visible: bool = _los_sensor.fov.has(_actor.leader.location.position)
		var max_dist: int = FOLLOW_PLAYERLEADER_MAXDIST if _actor.leader.is_player else FOLLOW_NPCLEADER_MAXDIST
		var follow_action: ActorAction = behavior_follow_actor(game, _actor.leader, last_known_leader_position, is_leader_visible, max_dist)
		if follow_action != null:
			_actor.activity = Activity.FOLLOWING
			_actor.target_actor = _actor.leader
			return follow_action

	# 20 take lead (if leadership)
	var has_leadership: bool = _actor.sheet.skill_table.get_skill_level(Skills.IDs.LEADERSHIP) >= 1
	if has_leadership:
		var can_lead: bool = not check_our_leader && _actor.count_followers < game.rules.actor_max_followers(_actor)
		if can_lead:
			var nearest_friend: Percept = filter_nearest(game, filter_non_enemies(game, map_percepts))
			if nearest_friend != null:
				# alpha10 only if unreachable by baseai simple behaviours
				if can_reach_simple(game, nearest_friend.location.position, RouteFinder.SpecialActions.DOORS | RouteFinder.SpecialActions.JUMP):
					var lead_action: ActorAction = behavior_lead_actor(game, nearest_friend)
					if lead_action != null:
						_actor.activity = Activity.IDLE
						_actor.target_actor = nearest_friend.percepted as Actor
						return lead_action

	# 21 if hungry, tear down barricades & push objects.
	if game.rules.is_actor_hungry(_actor):
		var attack_barricade_action: ActorAction = behavior_attack_barricade(game)
		if attack_barricade_action != null:
			# emote.
			game.do_emote(_actor, "Open damn it! I know there is food there!", true)

			# go!
			_actor.activity = Activity.IDLE
			return attack_barricade_action
		if game.rules.roll_chance(HUNGRY_PUSH_OBJECTS_CHANCE):
			# alpha10.1 do that only inside where food is more likely to be hidden, pushing cars outside is stupid -_-
			if _actor.location.map.get_tile_at_p(_actor.location.position).is_inside:
				var push_action: ActorAction = behavior_push_non_walkable_object(game)
				if push_action != null:
					# emote.
					game.do_emote(_actor, "Where is all the damn food?!", true)

					# go!
					_actor.activity = Activity.IDLE
					return push_action

	# 22 go revive corpse.
	var revive: ActorAction = behavior_go_revive_corpse(game, filter_corpses(game, map_percepts))
	if revive != null:
		_actor.activity = Activity.IDLE
		return revive

	# 23 use exit.
	if game.rules.roll_chance(USE_EXIT_CHANCE):
		var use_exit: ActorAction = behavior_use_exit(game, UseExitFlags.DONT_BACKTRACK)
		if use_exit != null:
			_actor.activity = Activity.IDLE
			return use_exit

	# 24 tell friend about latest raid.
	# tell?
	if _last_raid_heard != null && game.rules.roll_chance(TELL_FRIEND_ABOUT_RAID_CHANCE):
		var tell_action: ActorAction = behavior_tell_friend_about_percept(game, _last_raid_heard)
		if tell_action != null:
			_actor.activity = Activity.IDLE
			return tell_action

	# 25 tell friend about latest soldier.
	# update percept.
	var seeing_soldier: Percept = filter_first(game, map_percepts,
		func(p: Percept) -> bool:
			var other: Actor = p.percepted if p.percepted is Actor else null
			if other == null || other == _actor:
				return false
			return is_soldier(other))
	if seeing_soldier != null:
		_last_soldier_saw = seeing_soldier
	# tell?
	if game.rules.roll_chance(TELL_FRIEND_ABOUT_SOLDIER_CHANCE) && _last_soldier_saw != null:
		var tell_action: ActorAction = behavior_tell_friend_about_percept(game, _last_soldier_saw)
		if tell_action != null:
			_actor.activity = Activity.IDLE
			return tell_action

	# 26 tell friend about latest enemy.
	if game.rules.roll_chance(TELL_FRIEND_ABOUT_ENEMY_CHANCE) && _last_enemy_saw != null:
		var tell_action: ActorAction = behavior_tell_friend_about_percept(game, _last_enemy_saw)
		if tell_action != null:
			_actor.activity = Activity.IDLE
			return tell_action

	# 27 tell friend about latest items.
	if game.rules.roll_chance(TELL_FRIEND_ABOUT_ITEMS_CHANCE) && _last_items_saw != null:
		var tell_action: ActorAction = behavior_tell_friend_about_percept(game, _last_items_saw)
		if tell_action != null:
			_actor.activity = Activity.IDLE
			return tell_action

	# 28 (law enforcer) watch for murderers.
	if _actor.model.abilities.is_law_enforcer && map_percepts != null && game.rules.roll_chance(LAW_ENFORCE_CHANCE):
		var law_r: Dictionary = behavior_enforce_law(game, map_percepts)
		if law_r.action != null:
			_actor.target_actor = law_r.target
			return law_r.action

	# 29 (leader) don't leave followers behind.
	if _actor.count_followers > 0:
		var stick_together_r: Dictionary = behavior_dont_leave_followers_behind(game, 2)
		var stick_together: ActorAction = stick_together_r.action
		if stick_together != null:
			var target: Actor = stick_together_r.target

			# emote?
			if game.rules.roll_chance(DONT_LEAVE_BEHIND_EMOTE_CHANCE):
				if target.is_sleeping:
					game.do_emote(_actor, "patiently waits for %s to wake up." % target.name)
				else:
					if _los_sensor.fov.has(target.location.position):
						game.do_emote(_actor, "Come on %s! Hurry up!" % target.name)
					else:
						game.do_emote(_actor, "Where the hell is %s?" % target.name)

			# go!
			_actor.activity = Activity.IDLE
			return stick_together

	# 30 explore
	var explore_action: ActorAction = behavior_explore(game, _exploration)
	if explore_action != null:
		_actor.activity = Activity.IDLE
		return explore_action

	# 31 wander.
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null, _exploration)
