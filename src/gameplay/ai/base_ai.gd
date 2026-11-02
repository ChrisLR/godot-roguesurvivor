class_name BaseAI
extends AIController
## Port of Gameplay/AI/BaseAI.cs
## Abstract base of the gameplay AI controllers. Concrete controllers
## (ZombieAI, HumanAI...) implement create_sensors/update_sensors/select_action.
##
## NOTE: C# m_Actor is ported as the inherited ActorController.controlled_actor.

class ChoiceEval:
	## Port of the ChoiceEval<_T_> class declared in BaseAI.cs.
	var choice: Variant
	var value: float


	func _init(p_choice: Variant, p_value: float) -> void:
		choice = p_choice
		value = p_value


	func _to_string() -> String:
		return "ChoiceEval(%s; %.2f)" % ["NULL" if choice == null else str(choice), value]


# Constants

## C# protected Actor m_Actor : ported as an alias of the inherited
## ActorController.controlled_actor (the ported controllers use _actor).
@warning_ignore("unused_private_class_variable")
var _actor: Actor:
	get:
		return controlled_actor
	set(value):
		controlled_actor = value


## C# uses the ActorCourage enum from Data/ActorDirective.cs; aliased here so
## the controllers can keep writing ActorCourage.XXX unqualified.
const ActorCourage = ActorDirective.ActorCourage


## alpha10 increased from 50%
const FLEE_THROUGH_EXIT_CHANCE: int = 90

const EMOTE_GRAB_ITEM_CHANCE: int = 30
const EMOTE_FLEE_CHANCE: int = 30
const EMOTE_FLEE_TRAPPED_CHANCE: int = 50
const EMOTE_CHARGE_CHANCE: int = 30

## slightly > to diagonal distance (sqrt(2))
const MOVE_DISTANCE_PENALTY: float = 0.42
## alpha10
const MOVE_INTO_TRAPS_PENALTY: float = 1.0

## alpha10 int
const IN_LEADER_LOF_SAFETY_PENALTY: int = 1


# Fields

var _prev_location: Location = null
var _taboo_items = null    # list is better than dictionary since we expect it to be very small.
var _taboo_tiles = null
var _taboo_trades = null
# alpha10
var _route_finder: RouteFinder = null
var _reserved_equipment_slots: int = 0
## Port of the C# ref lastItemsSaw state kept by controllers, see
## behavior_go_get_interesting_items.
var _last_items_saw: Percept = null
# Save-system registries: concrete controllers register the MemorizedSensor /
# ExplorationData instances they create in create_sensors() so their memory
# can be persisted (take_control -> create_sensors runs before the restore).
var _tracked_sensors: Array[MemorizedSensor] = []
var _tracked_explorations: Array[ExplorationData] = []


func _track_memorized_sensor(s: MemorizedSensor) -> MemorizedSensor:
	_tracked_sensors.append(s)
	return s


func _track_exploration(e: ExplorationData) -> ExplorationData:
	_tracked_explorations.append(e)
	return e


## Serialize the AI memory worth persisting: taboo tiles/trades, reserved
## equipment slots, memorized sensor percepts and exploration locations.
## (Taboo ITEMS are Item instances with no global ref scheme and are not
## persisted; worst case after a load an AI reconsiders a rejected item.)
func serialize_ai_state() -> Dictionary:
	var taboo_trades_data = null
	if _taboo_trades != null:
		taboo_trades_data = []
		for a in _taboo_trades:
			taboo_trades_data.append(Session.actor_ref(a))
	var sensors_data := []
	for s in _tracked_sensors:
		sensors_data.append(s.serialize())
	var explorations_data := []
	for e in _tracked_explorations:
		explorations_data.append(e.serialize())
	return {
		"taboo_tiles": _taboo_tiles,
		"taboo_trades": taboo_trades_data,
		"reserved_equipment_slots": _reserved_equipment_slots,
		"sensors": sensors_data,
		"explorations": explorations_data,
	}


## Restore AI memory saved by serialize_ai_state(). Must be called after
## take_control (so the tracked sensors/explorations exist), i.e. from
## Actor.resolve_refs with the loaded world graph.
func deserialize_ai_state(world: World, data: Dictionary) -> void:
	if data == null:
		return
	_taboo_tiles = data.get("taboo_tiles", null)
	var trades_data = data.get("taboo_trades")
	if trades_data != null:
		_taboo_trades = []
		for ref in trades_data:
			var a := Session.actor_from_ref(world, ref)
			if a != null:
				_taboo_trades.append(a)
	else:
		_taboo_trades = null
	_reserved_equipment_slots = data.get("reserved_equipment_slots", 0)
	var sensors_data: Array = data.get("sensors", [])
	for i in mini(sensors_data.size(), _tracked_sensors.size()):
		_tracked_sensors[i].deserialize(world, sensors_data[i])
	var explorations_data: Array = data.get("explorations", [])
	for i in mini(explorations_data.size(), _tracked_explorations.size()):
		_tracked_explorations[i].deserialize(world, explorations_data[i])


# Properties

## C# PrevLocation.
var prev_location: Location:
	get:
		return _prev_location


## C# TabooItems.
var taboo_items:
	get:
		return _taboo_items


## C# TabooTiles.
var taboo_tiles:
	get:
		return _taboo_tiles


## C# TabooTrades.
var taboo_trades:
	get:
		return _taboo_trades


# AIController

## C# TakeControl(actor).
func take_control(actor: Actor) -> void:
	super(actor)

	_taboo_items = null
	_taboo_tiles = null
	_taboo_trades = null
	# Cleared first so create_sensors() re-registers them via the _track_*
	# helpers; their saved memory is restored later in deserialize_ai_state
	# (called from Actor.resolve_refs).
	_tracked_sensors.clear()
	_tracked_explorations.clear()
	create_sensors()


## C# SetOrder(newOrder) : inherited AIController.set_order already stores it.


## True when the controlled actor has a model and a valid map location.
## Concrete controllers should call this at the top of select_action() /
## update_sensors() before dereferencing _actor.location.map or _actor.model.
func has_valid_location() -> bool:
	return controlled_actor != null and controlled_actor.model != null \
		and controlled_actor.location != null and controlled_actor.location.map != null


## C# GetAction(game).
func get_action(p_game: RogueGame) -> ActorAction:
	#########################
	# 1. Update sensors.
	# 2. Issue action.
	#########################

	# Guard: actor may have no valid location (removed from map, mid-transition).
	if not has_valid_location():
		return null

	# 2. Update sensors.
	var percepts: Array[Percept] = update_sensors(p_game)

	# 3. Issue action.
	if _prev_location == null or _prev_location.map == null:
		_prev_location = controlled_actor.location
	controlled_actor.target_actor = null
	var best_action: ActorAction = select_action(p_game, percepts)
	_prev_location = controlled_actor.location
	if best_action == null:
		controlled_actor.activity = Activity.IDLE
		return ActionWait.new(controlled_actor, p_game)
	return best_action


# Strategy followed in GetAction

## Abstract. C# CreateSensors(). Concrete controllers override this.
func create_sensors() -> void:
	pass


## Abstract. C# UpdateSensors(game). Base fallback: no percepts, so the
## actor simply waits (see get_action).
func update_sensors(_p_game: RogueGame) -> Array[Percept]:
	return []


## Abstract. C# SelectAction(game, percepts). Base fallback: null, which
## get_action turns into an ActionWait.
func select_action(_p_game: RogueGame, _percepts: Array[Percept]) -> ActorAction:
	return null


# Common sensor filters

## C# FilterSameMap(game, percepts).
func filter_same_map(_p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null
	var map: Map = controlled_actor.location.map
	for p: Percept in percepts:
		if p.location.map == map:
			if list == null:
				list = []
			list.append(p)

	return list


## C# FilterEnemies(game, percepts). Returns null if no enemies.
func filter_enemies(p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null

	for p: Percept in percepts:
		var other := p.percepted as Actor
		if other != null and other != controlled_actor:
			if p_game.rules.are_enemies(controlled_actor, other):
				if list == null:
					list = []
				list.append(p)

	return list


## C# FilterNonEnemies(game, percepts).
func filter_non_enemies(p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null

	for p: Percept in percepts:
		var other := p.percepted as Actor
		if other != null and other != controlled_actor:
			if not p_game.rules.are_enemies(controlled_actor, other):
				if list == null:
					list = []
				list.append(p)

	return list


## C# FilterCurrent(game, percepts).
func filter_current(_p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null

	var turn: int = controlled_actor.location.map.local_time.turn_counter
	for p: Percept in percepts:
		if p.turn == turn:
			if list == null:
				list = []
			list.append(p)

	return list


## C# FilterNearest(game, percepts).
func filter_nearest(p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var best: Percept = percepts[0]
	var nearest: float = p_game.rules.std_distance(controlled_actor.location.position, percepts[0].location.position)

	for i in range(1, percepts.size()):
		var p: Percept = percepts[i]
		var dist: float = p_game.rules.std_distance(controlled_actor.location.position, p.location.position)
		if dist < nearest:
			best = p
			nearest = dist

	return best


## C# FilterStrongestScent(game, scents).
func filter_strongest_scent(_p_game: RogueGame, scents) -> Variant:
	if scents == null or scents.size() == 0:
		return null

	var p_best: Percept = null
	var best: SmellSensor.AIScent = null
	for p: Percept in scents:
		var ai_scent: SmellSensor.AIScent = p.percepted as SmellSensor.AIScent
		assert(ai_scent != null, "percept not an aiScent")
		if p_best == null or ai_scent.strength > best.strength:
			best = ai_scent
			p_best = p

	return p_best


# NOTE: the obsolete C# filters (FilterOdor, FilterStrongestAdjacentScent,
# FilterStrongestVisibleScent) are inside #if false and are not ported.


## C# FilterActorsModel(game, percepts, model).
func filter_actors_model(_p_game: RogueGame, percepts, model: ActorModel) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null

	for p: Percept in percepts:
		var a := p.percepted as Actor
		if a != null and a.model == model:
			if list == null:
				list = []
			list.append(p)

	return list


## C# FilterActors(game, percepts, predicateFn).
func filter_actors(_p_game: RogueGame, percepts, predicate_fn: Callable) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null

	for p: Percept in percepts:
		var a := p.percepted as Actor
		if a != null and predicate_fn.call(a):
			if list == null:
				list = []
			list.append(p)

	return list


## C# FilterFireTargets(game, percepts).
func filter_fire_targets(p_game: RogueGame, percepts) -> Variant:
	return filter(p_game, percepts, func(p: Percept) -> bool:
		var other := p.percepted as Actor
		if other == null:
			return false
		return p_game.rules.can_actor_fire_at(controlled_actor, other).ok)


## C# FilterStacks(game, percepts).
func filter_stacks(p_game: RogueGame, percepts) -> Variant:
	return filter(p_game, percepts, func(p: Percept) -> bool:
		var it := p.percepted as Inventory
		return it != null)


## C# FilterCorpses(game, percepts).
func filter_corpses(p_game: RogueGame, percepts) -> Variant:
	return filter(p_game, percepts, func(p: Percept) -> bool:
		# C# : percepted as List<Corpse>.
		return p.percepted is Array)


## C# Filter(game, percepts, predicateFn).
func filter(_p_game: RogueGame, percepts, predicate_fn: Callable) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var list = null

	for p: Percept in percepts:
		if predicate_fn.call(p):
			if list == null:
				list = []
			list.append(p)

	return list


## C# FilterFirst(game, percepts, predicateFn).
func filter_first(_p_game: RogueGame, percepts, predicate_fn: Callable) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	for p: Percept in percepts:
		if predicate_fn.call(p):
			return p

	return null


## C# FilterOut(game, percepts, rejectPredicateFn).
func filter_out(p_game: RogueGame, percepts, reject_predicate_fn: Callable) -> Variant:
	return filter(p_game, percepts, func(p: Percept) -> bool:
		return not reject_predicate_fn.call(p))


## Closest first.
## C# SortByDistance(game, percepts).
func sort_by_distance(p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var from: Vector2i = controlled_actor.location.position

	var sorted_list: Array = percepts.duplicate()

	sorted_list.sort_custom(func(p_a: Percept, p_b: Percept) -> bool:
		var d_a: float = p_game.rules.std_distance(p_a.location.position, from)
		var d_b: float = p_game.rules.std_distance(p_b.location.position, from)
		return d_a < d_b)

	return sorted_list


## Most recent first.
## C# SortByDate(game, percepts).
func sort_by_date(_p_game: RogueGame, percepts) -> Variant:
	if percepts == null or percepts.size() == 0:
		return null

	var sorted_list: Array = percepts.duplicate()

	sorted_list.sort_custom(func(p_a: Percept, p_b: Percept) -> bool:
		# C# sorts most recent first (descending).
		return p_a.turn > p_b.turn)

	return sorted_list


# Common behaviors

# Movement

## C# BehaviorWander(game, goodWanderLocFn, exploration) and its 2-arg overload.
## goodWanderLocFn can be null; exploration can be null for ais with no exploration.
func behavior_wander(p_game: RogueGame, good_wander_loc_fn = null, exploration: ExplorationData = null) -> ActorAction:
	var choose_dir: BaseAI.ChoiceEval = choose(p_game,
		Direction.COMPASS_LIST,
		func(dir: Direction) -> bool:
			var next: Location = controlled_actor.location.plus(dir)
			if good_wander_loc_fn != null and not good_wander_loc_fn.call(next):
				return false
			var bump_action: ActorAction = p_game.rules.is_bumpable_for(controlled_actor, p_game, next).action
			return is_valid_wander_action(p_game, bump_action),
		func(dir: Direction) -> float:
			var next: Location = controlled_actor.location.plus(dir)

			var score: int = 0

			# alpha10.1
			var BREAKING_OBJ: int = -50000
			var BACKTRACKING: int = -10000
			var BREAKING_BARRICADES: int = -1000
			var AVOID_TRAPS: int = -1000
			var UNEXPLORED_LOC: int = 1000  # should not happen, see below
			var DOORWINDOWS: int = 100
			var EXITS: int = 50
			var INSIDE_WHEN_ALMOST_SLEEPY: int = 100
			var WANDER_RANDOM: int = 10  # alpha10.1 much smaller random factor

			if next.equals(_prev_location):
				score += BACKTRACKING

			if controlled_actor.model.abilities.is_intelligent:
				if is_any_unsafe_damaging_trap_there(p_game, controlled_actor.location.map, next.position):
					score += AVOID_TRAPS

			# alpha10.1 allowing break action prevent rare cases of getting stuck or going back and forth but we penalize it
			if next.map.get_map_object_at(next.position) != null:
				var bump_obj_action: ActorAction = p_game.rules.is_bumpable_for(controlled_actor, p_game, next).action
				if bump_obj_action != null and (bump_obj_action is ActionBreak or bump_obj_action is ActionBashDoor):
					if bump_obj_action is ActionBashDoor:
						score += BREAKING_BARRICADES
					else:
						score += BREAKING_OBJ
					# if we have to break things, prefer objs we can break more quickly
					score -= get_object_hit_points(next.map.get_map_object_at(next.position))

			# alpha10.1 prefer unexplored/oldest
			# unexplored should not happen because exploration rule is tested before wander rule but just to be more robust...
			if exploration != null:
				var loc_age: int = exploration.get_explored_age(next)
				if loc_age == 0:
					score += UNEXPLORED_LOC
				else:
					score += loc_age

			# alpha10.1 prefer wandering to doorwindows and exits.
			# helps civs ai getting stuck in semi-infinite loop when running out of new exploration to do.
			# as a side effect, make ais with no exploration data (eg zombies) more eager to visit door/windows and exits.
			var door_window: DoorWindow = next.map.get_map_object_at(next.position) as DoorWindow
			if door_window != null:
				score += DOORWINDOWS
			if next.map.get_exit_at(next.position) != null:
				score += EXITS

			# alpha10.1 prefer inside when almost sleepy
			if p_game.rules.is_almost_sleepy(controlled_actor) and next.map.get_tile_at_p(next.position).is_inside:
				score += INSIDE_WHEN_ALMOST_SLEEPY

			# alpha10.1 add random factor
			score += p_game.rules.roll(0, WANDER_RANDOM)

			# done
			return float(score),
		func(a: float, b: float) -> bool:
			return a > b)

	if choose_dir != null:
		return ActionBump.new(controlled_actor, p_game, choose_dir.choice)
	else:
		return null


# alpha10 added break & push
## C# BehaviorBumpToward(game, goal, canCheckBreak, canCheckPush, distanceFn).
## distanceFn : float.NAN to forbid a move; can be null.
func behavior_bump_toward(p_game: RogueGame, goal: Vector2i, can_check_break: bool, can_check_push: bool, distance_fn: Callable) -> ActorAction:
	var best_closer_dir: BaseAI.ChoiceEval = choose_extended(p_game,
		Direction.COMPASS_LIST,
		func(dir: Direction) -> Variant:
			var next: Location = controlled_actor.location.plus(dir)
			var bump_action: ActorAction = p_game.rules.is_bumpable_for(controlled_actor, p_game, next).action
			if bump_action == null:
				# for undeads, try to push the blocking object randomly.
				if controlled_actor.model.abilities.is_undead and p_game.rules.has_actor_push_ability(controlled_actor):
					var obj: MapObject = controlled_actor.location.map.get_map_object_at(next.position)
					if obj != null:
						if p_game.rules.can_actor_push(controlled_actor, obj):
							var push_dir: Direction = p_game.rules.roll_direction()
							if p_game.rules.can_push_object_to(obj, obj.location.position + push_dir.vector).ok:
								return ActionPush.new(controlled_actor, p_game, obj, push_dir)

				# alpha10 check special actions
				if can_check_break:
					var obj: MapObject = controlled_actor.location.map.get_map_object_at(next.position)
					if obj != null:
						if p_game.rules.is_breakable_for(controlled_actor, obj).ok:
							return ActionBreak.new(controlled_actor, p_game, obj)
				if can_check_push:
					var obj: MapObject = controlled_actor.location.map.get_map_object_at(next.position)
					if obj != null:
						if p_game.rules.can_actor_push(controlled_actor, obj):
							# push in a valid direction at random
							var valid_pushes: Array = []
							for push_dir in Direction.COMPASS:
								if p_game.rules.can_push_object_to(obj, obj.location.position + push_dir.vector).ok:
									valid_pushes.append(push_dir)
							if valid_pushes.size() > 0:
								return ActionPush.new(controlled_actor, p_game, obj, valid_pushes[p_game.rules.roll(0, valid_pushes.size())])

				# failed.
				return null
			if next.position == goal:
				return bump_action
			if is_valid_move_toward_goal_action(bump_action):
				return bump_action
			else:
				return null,
		func(dir: Direction, action: ActorAction) -> float:
			var next: Location = controlled_actor.location.plus(dir)
			var cost: float = (distance_fn.call(next.position, goal) if distance_fn != null else p_game.rules.std_distance(next.position, goal))

			# alpha10 add action cost heuristic if npc is intelligent
			if not is_nan(cost):
				if controlled_actor.model.abilities.is_intelligent:
					cost += estimate_bump_action_cost(p_game, next, action)

			return cost,
		func(a: float, b: float) -> bool:
			return not is_nan(a) and a < b)

	if best_closer_dir != null:
		return best_closer_dir.choice
	else:
		return null


# alpha10
## For intelligent npcs, additional cost to distance cost when chosing which adj tile to bump to.
## C# EstimateBumpActionCost(game, loc, action).
func estimate_bump_action_cost(_p_game: RogueGame, loc: Location, action: ActorAction) -> float:
	var cost: float = 0

	if action is ActionBump:
		action = (action as ActionBump).concrete_action


	# Consuming additional sta
	if controlled_actor.model.abilities.can_tire:
		# jumping
		if action is ActionMoveStep:
			var mobj: MapObject = loc.map.get_map_object_at(loc.position)
			if mobj != null and mobj.is_jumpable:
				cost = MOVE_DISTANCE_PENALTY

		# actions that always consume sta or may take more than one turn
		if action is ActionBashDoor or action is ActionBreak or action is ActionPush:
			cost = MOVE_DISTANCE_PENALTY

	return cost


# alpha10 can check break and push
## C# BehaviorStupidBumpToward(game, goal, canCheckBreak, canCheckPush).
func behavior_stupid_bump_toward(p_game: RogueGame, goal: Vector2i, can_check_break: bool, can_check_push: bool) -> ActorAction:
	return behavior_bump_toward(p_game, goal, can_check_break, can_check_push,
		func(pt_a: Vector2i, pt_b: Vector2i) -> float:
			if pt_a == pt_b:
				return 0.0
			var distance: float = p_game.rules.std_distance(pt_a, pt_b)

			# penalize having to push/bash/jump.
			if not p_game.rules.is_walkable_for(controlled_actor, controlled_actor.location.map, pt_a.x, pt_a.y).ok:
				distance += MOVE_DISTANCE_PENALTY

			return distance)


# alpha10 added break & push
## C# BehaviorIntelligentBumpToward(game, goal, canCheckBreak, canCheckPush).
func behavior_intelligent_bump_toward(p_game: RogueGame, goal: Vector2i, can_check_break: bool, can_check_push: bool) -> ActorAction:
	var current_distance: float = p_game.rules.std_distance(controlled_actor.location.position, goal)
	var im_starving_or_courageous: bool = p_game.rules.is_actor_starving(controlled_actor) \
		or directives.courage == ActorDirective.ActorCourage.COURAGEOUS

	var bump: ActorAction = behavior_bump_toward(p_game, goal, can_check_break, can_check_push,
		func(pt_a: Vector2i, pt_b: Vector2i) -> float:
			if pt_a == pt_b:
				return 0.0
			var distance: float = p_game.rules.std_distance(pt_a, pt_b)

			# consider only moves that make takes us closer.
			if distance >= current_distance:
				return NAN

			# avoid stepping on damaging traps, unless starving or courageous.
			if not im_starving_or_courageous:
				var traps_damage: int = compute_traps_max_damage_for_me(p_game, controlled_actor.location.map, pt_a)
				if traps_damage > 0:
					# if instant death, don't do it.
					if traps_damage >= controlled_actor.hit_points:
						return NAN
					# avoid.
					distance += MOVE_INTO_TRAPS_PENALTY

			return distance)
	return bump


## C# BehaviorWalkAwayFrom(game, goal).
func behavior_walk_away_from(p_game: RogueGame, goal: Percept) -> ActorAction:
	var goals: Array = [goal]
	return behavior_walk_away_from_goals(p_game, goals)


## C# BehaviorWalkAwayFrom(game, goals).
func behavior_walk_away_from_goals(p_game: RogueGame, goals) -> ActorAction:
	# stuff to avoid stepping into leader LoF.
	var my_leader: Actor = controlled_actor.leader
	var leader_is_firing: bool = controlled_actor.has_leader and controlled_actor.get_equipped_weapon() is ItemRangedWeapon
	var leader_nearest_target: Actor = null
	if leader_is_firing:
		leader_nearest_target = get_nearest_target_for(p_game, controlled_actor.leader)
	var check_leader_lof: bool = leader_nearest_target != null and leader_nearest_target.location.map == controlled_actor.location.map
	var leader_lof = null
	if check_leader_lof:
		leader_lof = []
		var wpn: ItemRangedWeapon = controlled_actor.get_equipped_weapon() as ItemRangedWeapon
		LOS.can_trace_fire_line(my_leader.location, leader_nearest_target.location.position, (wpn.model as ItemRangedWeaponModel).attack.range_value, leader_lof)

	var best_away_dir: BaseAI.ChoiceEval = choose(p_game,
		Direction.COMPASS_LIST,
		func(dir: Direction) -> bool:
			var next: Location = controlled_actor.location.plus(dir)
			var bump_action: ActorAction = p_game.rules.is_bumpable_for(controlled_actor, p_game, next).action
			return is_valid_fleeing_action(bump_action),
		func(dir: Direction) -> float:
			var next: Location = controlled_actor.location.plus(dir)
			# Heuristic value:
			# - Safety from dangers.
			# - If follower, stay close to leader but avoid stepping into leader LoF.
			var safety_value: float = safety_from(p_game, next.position, goals)
			if controlled_actor.has_leader:
				# stay close to leader.
				safety_value -= 100 * p_game.rules.grid_distance_points(next.position, controlled_actor.leader.location.position)
				# don't step into leader LoF.
				if check_leader_lof:
					if leader_lof.has(next.position):
						safety_value -= 100 * IN_LEADER_LOF_SAFETY_PENALTY

			return safety_value,
		func(a: float, b: float) -> bool:
			return a > b)

	if best_away_dir != null:  # && bestAwayDir.Value > notMovingValue) nope, moving is always better than not moving
		return ActionBump.new(controlled_actor, p_game, best_away_dir.choice)
	else:
		return null


# Melee attack

## C# BehaviorMeleeAttack(game, target).
func behavior_melee_attack(p_game: RogueGame, target: Percept) -> ActorAction:
	var target_actor := target.percepted as Actor
	assert(target_actor != null, "percepted is not an actor")

	# if illegal cant.
	if not p_game.rules.can_actor_melee_attack(controlled_actor, target_actor).ok:
		return null

	# melee!
	return ActionMeleeAttack.new(controlled_actor, p_game, target_actor)


# Ranged attack

## C# BehaviorRangedAttack(game, target).
func behavior_ranged_attack(p_game: RogueGame, target: Percept) -> ActorAction:
	var target_actor := target.percepted as Actor
	assert(target_actor != null, "percepted is not an actor")

	# if illegal cant.
	if not p_game.rules.can_actor_fire_at(controlled_actor, target_actor).ok:
		return null

	# alpha10
	# select rapid fire if one shot is not enough to kill target, has more than one ammo loaded and chances to hit good enough.
	var fire_mode: Attack.FireMode = Attack.FireMode.DEFAULT
	if (get_equipped_weapon() as ItemRangedWeapon).ammo >= 2:
		var ranged_attack: Attack = p_game.rules.actor_ranged_attack(controlled_actor, controlled_actor.current_ranged_attack, p_game.rules.grid_distance_points(controlled_actor.location.position, target_actor.location.position), target_actor)
		if ranged_attack.damage_value < target_actor.hit_points:
			var rapid_hit_1_chance: int = p_game.rules.compute_chances_ranged_hit(controlled_actor, target_actor, 1)
			var rapid_hit_2_chance: int = p_game.rules.compute_chances_ranged_hit(controlled_actor, target_actor, 2)
			# "good chances" = both hits at least 50%
			if rapid_hit_1_chance >= 50 and rapid_hit_2_chance >= 50:
				fire_mode = Attack.FireMode.RAPID

	# fire!
	return ActionRangedAttack.new(controlled_actor, p_game, target_actor, fire_mode)


# Equiping items

# NOTE: the obsolete C# BehaviorEquipWeapon is inside #if false and is not ported.


## C# BehaviorEquipBestBodyArmor(game).
func behavior_equip_best_body_armor(p_game: RogueGame) -> ActorAction:
	# Get best armor available.
	var best_armor: ItemBodyArmor = get_best_body_armor(p_game, func(it: Item) -> bool: return not is_item_taboo(it))

	# If none, don't bother.
	if best_armor == null:
		return null

	# If already equipped, fine.
	var eq_armor: Item = get_equipped_body_armor()
	if eq_armor == best_armor:
		return null

	# If another armor already equipped, unequip it first.
	if eq_armor != null:
		if p_game.rules.can_actor_unequip_item(controlled_actor, eq_armor).ok:
			return ActionUnequipItem.new(controlled_actor, p_game, eq_armor)
		else:
			return null

	# Equip the new armor.
	if eq_armor == null:
		if p_game.rules.can_actor_equip_item(controlled_actor, best_armor).ok:
			return ActionEquipItem.new(controlled_actor, p_game, best_armor)
		else:
			return null

	# Fail.
	return null


## C# BehaviorEquipCellPhone(game).
func behavior_equip_cell_phone(p_game: RogueGame) -> ActorAction:
	# Only equip cellphone if :
	# - is a leader.
	# - or if leader does.
	var want_tracker: bool = false
	if controlled_actor.count_followers > 0:
		want_tracker = true
	elif controlled_actor.has_leader:
		var leader_has_tracker_eq: bool = false
		var leader_tr: ItemTracker = controlled_actor.leader.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
		if leader_tr == null:
			leader_has_tracker_eq = false
		elif leader_tr.can_track_followers_or_leader():
			leader_has_tracker_eq = true

		want_tracker = leader_has_tracker_eq

	# If already equiped a cellphone, nothing to do or unequip it.
	var eq_track: Item = get_equipped_cell_phone()
	if eq_track != null:
		if not want_tracker and p_game.rules.can_actor_unequip_item(controlled_actor, eq_track).ok:
			return ActionUnequipItem.new(controlled_actor, p_game, eq_track)
		else:
			return null

	if not want_tracker:
		return null

	# Equip first available cellphone.
	var new_tracker: Item = get_first_tracker(func(it: Item) -> bool: return it.can_track_followers_or_leader() and not is_item_taboo(it))
	if new_tracker != null:
		# equip new.
		if p_game.rules.can_actor_equip_item(controlled_actor, new_tracker).ok:
			return ActionEquipItem.new(controlled_actor, p_game, new_tracker)

	# Fail.
	return null


## C# BehaviorUnequipCellPhoneIfLeaderHasNot(game).
func behavior_unequip_cell_phone_if_leader_has_not(p_game: RogueGame) -> ActorAction:
	# alpha10
	# if we are leader, dont unequip.
	if controlled_actor.count_followers > 0:
		return null

	# get left eq item.
	var _tr: ItemTracker = controlled_actor.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
	if _tr == null:
		return null
	if not _tr.can_track_followers_or_leader():
		return null

	# we have a cell phone equiped.
	# unequip if leader has not one equiped.
	var leader_tr: ItemTracker = controlled_actor.leader.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
	if leader_tr == null or not leader_tr.can_track_followers_or_leader():
		# unequip!
		if p_game.rules.can_actor_unequip_item(controlled_actor, _tr).ok:
			return ActionUnequipItem.new(controlled_actor, p_game, _tr)

	# fail.
	return null


## C# BehaviorUnequipLeftItem(game).
func behavior_unequip_left_item(p_game: RogueGame) -> ActorAction:
	# get left eq item.
	var eq_left: Item = controlled_actor.get_equipped_item(Doll.DollPart.LEFT_HAND)
	if eq_left == null:
		return null

	# try to unequip it.
	if p_game.rules.can_actor_unequip_item(controlled_actor, eq_left).ok:
		return ActionUnequipItem.new(controlled_actor, p_game, eq_left)

	# fail.
	return null


# alpha10
## Get action to perform to manage the best ranged weapon we have.
## - equip a new best ranged weapon
## - reload the one we have equiped
## - unequip a completly out of ammo weapon
## - nothing if we already have equiped the best we have
## C# BehaviorEquipBestRangedWeapon(game). Returns null if not wanting an action.
func behavior_equip_best_ranged_weapon(p_game: RogueGame) -> ActorAction:
	# get best range weapon with ammo we have
	var best: ItemRangedWeapon = get_best_ranged_weapon_with_ammo(func(it: Item) -> bool: return not is_item_taboo(it))

	if best == null:
		# useless equipped rw we should unequip (best is null in this case since no ammo in inv):
		# if we have a rw equiped but out of ammo and no ammo to reload it, unequip, leave hand free for melee weapon.
		var eq_rw: ItemRangedWeapon = controlled_actor.get_equipped_ranged_weapon()
		if eq_rw != null and eq_rw.ammo == 0 and get_compatible_ammo_item(p_game, eq_rw, false) == null:
			return ActionUnequipItem.new(controlled_actor, p_game, eq_rw)

		# no rw with ammo to equip
		return null

	if best.is_equipped:
		# if out of ammo try to reload, else unequip to make room for a melee weapon
		if best.ammo == 0:
			var ammo: ItemAmmo = get_compatible_ammo_item(p_game, best, true)
			if ammo != null:
				return ActionUseItem.new(controlled_actor, p_game, ammo)
			else:
				return ActionUnequipItem.new(controlled_actor, p_game, best)

		# best ranged weapon equiped & has ammo, we're fine.
		return null

	# if not equiped but out of ammo and no ammo to reload it, dont equip, leave hand free for melee weapon.
	if best.ammo == 0 and get_compatible_ammo_item(p_game, best, false) == null:
		return null

	# replace current weapon with best one
	return behaviour_replace_equipped(p_game, controlled_actor.get_equipped_weapon(), best)


## C# BehaviorEquipBestMeleeWeapon(game).
func behavior_equip_best_melee_weapon(p_game: RogueGame) -> ActorAction:
	var best: Item = get_best_melee_weapon(p_game, func(it: Item) -> bool: return not is_item_taboo(it))

	if best == null:
		return null
	if best.is_equipped:
		return null

	return behaviour_replace_equipped(p_game, controlled_actor.get_equipped_weapon(), best)


## C# BehaviorEquipBestLight(game).
func behavior_equip_best_light(p_game: RogueGame) -> ActorAction:
	var best: ItemLight = get_best_light(p_game, func(it: Item) -> bool: return not is_item_taboo(it))

	if best == null:
		return null
	if best.is_equipped:
		# unequip if light out of batteries
		if best.batteries <= 0:
			return ActionUnequipItem.new(controlled_actor, p_game, best)
		# already got best light equiped
		return null
	# don't equip if out of batteries
	if best.batteries <= 0:
		return null

	# replace current left hand item with best one
	return behaviour_replace_equipped(p_game, controlled_actor.get_equipped_item(Doll.DollPart.LEFT_HAND), best)


## C# BehaviorEquipBestCellPhone(game).
func behavior_equip_best_cell_phone(p_game: RogueGame) -> ActorAction:
	var best: ItemTracker = get_best_cell_phone(p_game, func(it: Item) -> bool: return not is_item_taboo(it))

	if best == null:
		return null
	if best.is_equipped:
		# unequip if phone out of batteries
		if best.batteries <= 0:
			return ActionUnequipItem.new(controlled_actor, p_game, best)
		# already got best spray equiped
		return null
	# don't equip if out of batteries
	if best.batteries <= 0:
		return null

	# replace current left hand item with best one
	return behaviour_replace_equipped(p_game, controlled_actor.get_equipped_item(Doll.DollPart.LEFT_HAND), best)


## C# BehaviorEquipBestStenchKiller(game).
func behavior_equip_best_stench_killer(p_game: RogueGame) -> ActorAction:
	var best: ItemSprayScent = get_best_stench_killer(p_game, func(it: Item) -> bool: return not is_item_taboo(it))


	if best == null:
		return null
	if best.is_equipped:
		# unequip if out of spray
		if best.spray_quantity <= 0:
			return ActionUnequipItem.new(controlled_actor, p_game, best)
		return null
	# don't equip if out of spray
	if best.spray_quantity <= 0:
		return null

	# replace current left hand item with best one
	return behaviour_replace_equipped(p_game, controlled_actor.get_equipped_item(Doll.DollPart.LEFT_HAND), best)


## C# WantsCellPhoneEquipped(game).
func wants_cell_phone_equipped(_p_game: RogueGame) -> bool:
	# follower wants if leader has one equipped,
	# leader wants if any follower has one with batteries in its inventory
	if controlled_actor.has_leader:
		var leader_phone: ItemTracker = controlled_actor.leader.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
		if leader_phone != null and leader_phone.can_track_followers_or_leader():
			return true
		return false
	elif controlled_actor.count_followers > 0:
		for follower in controlled_actor.followers:
			if follower.inventory.has_item_matching(func(it: Item) -> bool:
				var follower_phone := it as ItemTracker
				if follower_phone != null and follower_phone.can_track_followers_or_leader() and follower_phone.batteries > 0:
					return true
				return false):
				return true
		return false
	else:
		return false


## Will try to unequip old item first, then equip the new one.
## C# BehaviourReplaceEquipped(game, equipped, replaceWith). equipped/replaceWith can be null.
func behaviour_replace_equipped(p_game: RogueGame, equipped: Item, replace_with: Item) -> ActorAction:
	if equipped != null:
		if p_game.rules.can_actor_unequip_item(controlled_actor, equipped).ok:
			return ActionUnequipItem.new(controlled_actor, p_game, equipped)
		return null
	if replace_with != null:
		if p_game.rules.can_actor_equip_item(controlled_actor, replace_with).ok:
			return ActionEquipItem.new(controlled_actor, p_game, replace_with)
	return null


## Equip best items available : armors, weapons, lights/sprays/phones.
## Will ignore an equipment slot that is reserved by other behaviors (taboo).
## Actions:
## - equip an item
## - unequip an item
## - reload a weapon
## C# BehaviorEquipBestItems(game, allowCellPhones, allowStenchKiller).
func behavior_equip_best_items(p_game: RogueGame, allow_cell_phones: bool, allow_stench_killer: bool) -> ActorAction:
	var action: ActorAction = null

	# keep in mind which equipment slots are reserved by other behaviors and dont mess with them
	var can_use_torso: bool = not is_equipment_slot_taboo(Doll.DollPart.TORSO)
	var can_use_right_hand: bool = not is_equipment_slot_taboo(Doll.DollPart.RIGHT_HAND)
	var can_use_left_hand: bool = not is_equipment_slot_taboo(Doll.DollPart.LEFT_HAND)

	# armor
	if can_use_torso:
		action = behavior_equip_best_body_armor(p_game)
		if action != null:
			return action

	# right hand weapons, prefering ranged weapon over melee in most cases.
	if can_use_right_hand:
		# equip best ranged weapon only if not forbidden by directives or ai
		if directives.can_fire_weapons and not controlled_actor.model.abilities.ai_not_interested_in_ranged_weapons:
			action = behavior_equip_best_ranged_weapon(p_game)
			if action != null:
				return action
		else:
			var equipped_rw := get_equipped_weapon() as ItemRangedWeapon
			if equipped_rw != null:
				return ActionUnequipItem.new(controlled_actor, p_game, equipped_rw)

		# equip melee only if no ranged weapon equiped and not skilled martial artist
		if not has_equiped_ranged_weapon(controlled_actor) \
				and controlled_actor.sheet.skill_table.get_skill_level(Skills.IDs.MARTIAL_ARTS) < 3:
			action = behavior_equip_best_melee_weapon(p_game)
			if action != null:
				return action
		else:
			var equipped_mw := get_equipped_weapon() as ItemMeleeWeapon
			if equipped_mw != null:
				return ActionUnequipItem.new(controlled_actor, p_game, equipped_mw)

	# left-hand items
	if can_use_left_hand:
		# ordered by priority: cellphone -> lights -> spray
		var eq_cellphone: ItemTracker = get_equipped_cell_phone()
		var eq_light: ItemLight = get_equipped_light()
		var eq_stench_killer: ItemSprayScent = get_equipped_stench_killer()

		# cellphone
		if allow_cell_phones and wants_cell_phone_equipped(p_game):
			action = behavior_equip_best_cell_phone(p_game)
			if action != null:
				return action
		else:
			if eq_cellphone != null:
				return ActionUnequipItem.new(controlled_actor, p_game, eq_cellphone)

		# lights, if no cellphone equipped
		if eq_cellphone == null:
			if needs_light(p_game):
				action = behavior_equip_best_light(p_game)
				if action != null:
					return action
			else:
				# doesnt need light, unequip if equipped.
				if eq_light != null:
					return ActionUnequipItem.new(controlled_actor, p_game, eq_light)

		# spray scent, if no cellphone or light equipped
		if eq_cellphone == null and eq_light == null:
			if allow_stench_killer:
				action = behavior_equip_best_stench_killer(p_game)
				if action != null:
					return action
			else:
				if eq_stench_killer != null:
					return ActionUnequipItem.new(controlled_actor, p_game, eq_stench_killer)

	# no equipement action to do
	return null


# Getting items

## C# BehaviorGrabFromStack(game, position, stack, canBreak, canPush).
func behavior_grab_from_stack(p_game: RogueGame, position: Vector2i, stack: Inventory, can_break: bool, can_push: bool) -> ActorAction:
	# ignore empty stacks.
	if stack == null or stack.is_empty:
		return null

	# fix: don't try to get items under blocking map objects - bumping will say "yes can move" but we actually cannot take it.
	var obj_there: MapObject = controlled_actor.location.map.get_map_object_at(position)
	if obj_there != null:
		# un-walkable fortification
		var fort := obj_there as Fortification
		if fort != null and not fort.is_walkable:
			return null
		# barricaded door/window
		var door := obj_there as DoorWindow
		if door != null and door.is_barricaded:
			return null

	# for each item in the stack, consider only the takeable and interesting ones.
	var good_item: Item = null
	for it in stack.items:
		# if can't take, ignore.
		if not p_game.rules.can_actor_get_item(controlled_actor, it).ok:
			continue
		# if not interesting, ignore.
		if not is_interesting_item_to_own(p_game, it, ItemSource.GROUND_STACK):
			continue
		# gettable and interesting, get it.
		good_item = it
		break

	# if no good item, ignore.
	if good_item == null:
		return null

	# take it!
	var take_it: Item = good_item

	# emote?
	if p_game.rules.roll_chance(EMOTE_GRAB_ITEM_CHANCE):
		p_game.do_emote(controlled_actor, "%s! Great!" % take_it.a_name)

	# try to move/get one.
	if position == controlled_actor.location.position:
		return ActionTakeItem.new(controlled_actor, p_game, position, take_it)
	else:
		return behavior_intelligent_bump_toward(p_game, position, can_break, can_push)


# alpha10 made improved get item rule into a new behaviour; need taboo tile upkeep by caller though!
## C# BehaviorGoGetInterestingItems(game, mapPercepts, canBreak, canPush, cantGetItemEmote, setLastItemsSaw, ref lastItemsSaw).
## The C# ref param is ported as an internal _last_items_saw state, returned in
## the Dictionary : {"action": ActorAction (null if none), "last_items_saw": Percept}.
func behavior_go_get_interesting_items(p_game: RogueGame, map_percepts, can_break: bool, can_push: bool, cant_get_item_emote: String, set_last_items_saw: bool) -> Dictionary:
	var allowed_actions: int = RouteFinder.SpecialActions.JUMP | RouteFinder.SpecialActions.DOORS

	var map: Map = controlled_actor.location.map

	var interesting_reachable_stacks: Variant = filter_out(p_game, filter_stacks(p_game, map_percepts),
		func(p: Percept) -> bool:
			if p.turn != map.local_time.turn_counter:
				return true
			if is_occupied_by_other(map, p.location.position):
				return true
			if is_tile_taboo(p.location.position):
				return true
			if not has_any_interesting_item(p_game, p.percepted as Inventory, ItemSource.GROUND_STACK):
				return true
			# alpha10 check reachability
			var a: int = allowed_actions
			if is_container_at(p.location):
				a |= RouteFinder.SpecialActions.ADJ_TO_DEST_IS_GOAL
			if not can_reach_simple(p_game, p.location.position, a):
				return true
			# can and wants to get it
			return false)

	if interesting_reachable_stacks == null:
		return {"action": null, "last_items_saw": _last_items_saw}

	# update last percept saw.
	var nearest_stack: Percept = filter_nearest(p_game, interesting_reachable_stacks)
	if set_last_items_saw:
		_last_items_saw = nearest_stack

	# make room for food if needed.
	var make_room_for_food: ActorAction = behavior_make_room_for_food(p_game, interesting_reachable_stacks)
	if make_room_for_food != null:
		controlled_actor.activity = Activity.IDLE
		return {"action": make_room_for_food, "last_items_saw": _last_items_saw}

	# try to grab.
	var grab_action: ActorAction = behavior_grab_from_stack(p_game, nearest_stack.location.position, nearest_stack.percepted as Inventory, can_break, can_push)
	if grab_action != null:
		controlled_actor.activity = Activity.IDLE
		return {"action": grab_action, "last_items_saw": _last_items_saw}

	# we can't grab the item. mark the tile as taboo.
	mark_tile_as_taboo(nearest_stack.location.position)
	# emote
	p_game.do_emote(controlled_actor, cant_get_item_emote)
	# failed
	return {"action": null, "last_items_saw": _last_items_saw}


# Droping items

## C# BehaviorDropItem(game, it).
func behavior_drop_item(p_game: RogueGame, it: Item) -> ActorAction:
	if it == null:
		return null

	# 1. unequip?
	if p_game.rules.can_actor_unequip_item(controlled_actor, it).ok:
		# mark item as taboo.
		mark_item_as_taboo(it)

		# unequip.
		return ActionUnequipItem.new(controlled_actor, p_game, it)

	# 2. drop?
	if p_game.rules.can_actor_drop_item(controlled_actor, it).ok:
		# unmark item as taboo.
		unmark_item_as_taboo(it)

		# drop.
		return ActionDropItem.new(controlled_actor, p_game, it)

	# failed!
	return null


## C# BehaviorDropUselessItem(game).
func behavior_drop_useless_item(p_game: RogueGame) -> ActorAction:
	if controlled_actor.inventory.is_empty:
		return null

	# unequip/drop first light/tracker/spray out of batteries/quantity.
	# alpha10 ammo with no compatible ranged weapon and inventory full
	# alpha10 duplicate ranged weapon with no ammo if inventory 50% full
	# alpha10 empty cans!
	var is_inv_full: bool = controlled_actor.inventory.is_full
	var is_inv_50_full: bool = controlled_actor.inventory.count_items >= (controlled_actor.inventory.max_capacity / 2)
	for it in controlled_actor.inventory.items:
		var drop_it: bool = false

		if it is ItemLight:
			drop_it = (it as ItemLight).batteries <= 0
		elif it is ItemTracker:
			drop_it = (it as ItemTracker).batteries <= 0
		elif it is ItemSprayPaint:
			drop_it = (it as ItemSprayPaint).paint_quantity <= 0
		elif it is ItemSprayScent:
			drop_it = (it as ItemSprayScent).spray_quantity <= 0
		# alpha10 ammo with no compatible ranged weapon and inventory full
		elif is_inv_full and it is ItemAmmo:
			if get_compatible_ranged_weapon(p_game, it as ItemAmmo) == null:
				drop_it = true
		# alpha10 duplicate ranged weapon with no ammo if inventory 50% full
		elif is_inv_50_full and it is ItemRangedWeapon:
			var rw := it as ItemRangedWeapon
			if rw.ammo == 0:
				# if we have the same rw with ammo, this one is useless as rw dont break.
				# there is still the risk we get disarmed and would have loved a spare rw,
				# so we are a bit conservative and drop it only if 50% inv full as we prob need
				# the item slot for something else.
				for other_it in controlled_actor.inventory.items:
					if other_it != it and other_it.model == it.model:
						if (other_it as ItemRangedWeapon).ammo > 0:
							drop_it = true
							break
		# alpha10 empty cans!
		elif it.model == p_game.game_items.empty_can():  # comparing model instead of attributes is bad but makes sense in this case
			drop_it = true

		if drop_it:
			return behavior_drop_item(p_game, it)

	# nope.
	return null


# Resting, Eating & Sleeping

## C# BehaviorRestIfTired(game).
func behavior_rest_if_tired(p_game: RogueGame) -> ActorAction:
	# if not tired, don't.
	if controlled_actor.stamina_points >= Rules.STAMINA_MIN_FOR_ACTIVITY:
		return null

	# tired, rest.
	return ActionWait.new(controlled_actor, p_game)


## C# BehaviorEat(game).
func behavior_eat(p_game: RogueGame) -> ActorAction:
	# find best edible eat.
	var it: Item = get_best_edible_item(p_game)
	if it == null:
		return null

	# i can haz it?
	if not p_game.rules.can_actor_use_item(controlled_actor, it).ok:
		return null

	# eat it!
	return ActionUseItem.new(controlled_actor, p_game, it)


## C# BehaviorSleep(game, FOV). FOV : iterable of Vector2i.
func behavior_sleep(p_game: RogueGame, fov) -> ActorAction:
	# can?
	if not p_game.rules.can_actor_sleep(controlled_actor).ok:
		return null

	# if next to a door/window, try moving away from it.
	var map: Map = controlled_actor.location.map
	if map.has_any_adjacent_in_map(controlled_actor.location.position, func(pt: Vector2i) -> bool: return map.get_map_object_at(pt) is DoorWindow):
		# wander where there is no door/window and not adjacent to a door window.
		var wander_away_from_door: ActorAction = behavior_wander(p_game,
			func(loc: Location) -> bool:
				return (map.get_map_object_at(loc.position) as DoorWindow) == null \
					and not map.has_any_adjacent_in_map(loc.position, func(pt: Vector2i) -> bool: return loc.map.get_map_object_at(pt) is DoorWindow),
			null)
		if wander_away_from_door != null:
			return wander_away_from_door
		# no good spot, just try normal sleep behavior.

	# sleep on a couch.
	if p_game.rules.is_on_couch(controlled_actor):
		return ActionSleep.new(controlled_actor, p_game)
	# find nearest couch.
	var couch_pos = null
	var nearest_dist: float = INF
	for p in fov:
		var map_obj: MapObject = map.get_map_object_at(p)
		if map_obj != null and map_obj.is_couch and map.get_actor_at(p) == null:
			var dist: float = p_game.rules.std_distance(controlled_actor.location.position, p)
			if dist < nearest_dist:
				nearest_dist = dist
				couch_pos = p
	# if we have a couch, try to get there.
	if couch_pos != null:
		var move_there: ActorAction = behavior_intelligent_bump_toward(p_game, couch_pos, false, false)
		if move_there != null:
			return move_there

	# no couch or can't move there, sleep there.
	return ActionSleep.new(controlled_actor, p_game)


# Barricading & Building & Traps

## C# ComputeTrapsMaxDamageForMe(game, map, pos).
func compute_traps_max_damage_for_me(p_game: RogueGame, map: Map, pos: Vector2i) -> int:
	var inv: Inventory = map.get_items_at(pos)
	if inv == null:
		return 0

	var sum: int = 0
	var trp: ItemTrap = null
	for it in inv.items:
		trp = it as ItemTrap
		if trp == null:
			continue
		if not p_game.rules.is_safe_from_trap(trp, controlled_actor):  # alpha10 ignore safe traps we can't trigger them


			sum += trp.trap_model().damage
	return sum


## C# BehaviorBuildTrap(game).
func behavior_build_trap(p_game: RogueGame) -> ActorAction:
	# don't bother if we don't have a trap.
	var trap: ItemTrap = controlled_actor.inventory.get_first_by_type(ItemTrap) as ItemTrap
	if trap == null:
		return null

	# is this a good spot for a trap?
	var r: Dictionary = is_good_trap_spot(p_game, controlled_actor.location.map, controlled_actor.location.position)
	if not r.ok:
		return null
	var reason: String = r.reason

	# if trap needs to be activated, do it.
	if not trap.is_activated() and not trap.trap_model().activates_when_dropped():
		return ActionUseItem.new(controlled_actor, p_game, trap)

	# trap ready to setup, do it!
	p_game.do_emote(controlled_actor, "%s %s!" % [reason, trap.a_name], true)
	return ActionDropItem.new(controlled_actor, p_game, trap)


## C# IsGoodTrapSpot(game, map, pos, out reason) -> Dictionary {"ok":..., "reason":...}.
func is_good_trap_spot(_p_game: RogueGame, map: Map, pos: Vector2i) -> Dictionary:
	var reason: String = ""
	var potential_spot: bool = false

	# 1. Potential spot?
	# 2. Don't overdo it.

	# 1. Potential spot?
	# outside and has a corpse.
	var _is_inside: bool = map.get_tile_at_p(pos).is_inside
	if not _is_inside and map.get_corpses_at(pos) != null:
		reason = "that corpse will serve as a bait for"
		potential_spot = true
	else:
		#  entering or leaving a building?
		var was_inside: bool = _prev_location.map.get_tile_at_p(_prev_location.position).is_inside
		if was_inside != _is_inside:
			reason = "protecting the building with"
			potential_spot = true
		else:
			# ...or a door/window?
			var obj_there: MapObject = map.get_map_object_at(pos)
			if obj_there != null and obj_there is DoorWindow:
				reason = "protecting the doorway with"
				potential_spot = true
			# ...or an exit?
			elif map.get_exit_at(pos) != null:
				reason = "protecting the exit with"
				potential_spot = true
	if not potential_spot:
		return {"ok": false, "reason": ""}

	# 2. Don't overdo it.
	# Never drop more than 3 traps.
	var items_there: Inventory = map.get_items_at(pos)
	if items_there != null:
		var count_activated: int = items_there.count_items_matching(func(it: Item) -> bool:
			var trap := it as ItemTrap
			if trap == null:
				return false
			return trap.is_activated())
		if count_activated > 3:
			return {"ok": false, "reason": ""}
	# TODO Need at least 2 neighbouring non adjacent tiles free of activated traps.

	# ok!
	return {"ok": true, "reason": reason}


## C# BehaviorBuildSmallFortification(game).
func behavior_build_small_fortification(p_game: RogueGame) -> ActorAction:
	# don't bother if no carpentry skill or not enough material.
	if controlled_actor.sheet.skill_table.get_skill_level(Skills.IDs.CARPENTRY) == 0:
		return null
	if p_game.rules.count_barricading_material(controlled_actor) < p_game.rules.actor_barricading_material_need_for_fortification(controlled_actor, false):
		return null

	# pick a good adjacent tile.
	# good tiles are :
	# - in bounds, walkable, empty, not border.
	# - not exits.
	# - doorways.
	# eval is random.
	var map: Map = controlled_actor.location.map
	var choice: BaseAI.ChoiceEval = choose(p_game, Direction.COMPASS_LIST,
		func(dir: Direction) -> bool:
			var pt: Vector2i = controlled_actor.location.position + dir.vector
			if not map.is_in_bounds_p(pt):
				return false
			if not map.is_walkable_p(pt):
				return false
			if map.is_on_map_border(pt.x, pt.y):
				return false
			if map.get_actor_at(pt) != null:
				return false
			if map.get_exit_at(pt) != null:
				return false
			return is_doorway_or_corridor(p_game, map, pt),
		func(_dir: Direction) -> float:
			return float(p_game.rules.roll(0, 666)),
		func(a: float, b: float) -> bool:
			return a > b)

	# if no choice, fail.
	if choice == null:
		return null

	# get pos.
	var adj: Vector2i = controlled_actor.location.position + choice.choice.vector

	# if can't build there, fail.
	if not p_game.rules.can_actor_build_fortification(controlled_actor, adj, false).ok:
		return null

	# ok!
	return ActionBuildFortification.new(controlled_actor, p_game, adj, false)


## Try to make a line of large fortifications.
## C# BehaviorBuildLargeFortification(game, startLineChance).
func behavior_build_large_fortification(p_game: RogueGame, start_line_chance: int) -> ActorAction:
	# don't bother if no carpentry skill or not enough material.
	if controlled_actor.sheet.skill_table.get_skill_level(Skills.IDs.CARPENTRY) == 0:
		return null
	if p_game.rules.count_barricading_material(controlled_actor) < p_game.rules.actor_barricading_material_need_for_fortification(controlled_actor, true):
		return null

	# pick a good adjacent tile.
	# good tiles are :
	# - not exit.
	# - not map border.
	# - outside and anchor/continue wall.
	# all things being equal, eval is random.
	var map: Map = controlled_actor.location.map
	var choice: BaseAI.ChoiceEval = choose(p_game, Direction.COMPASS_LIST,
		func(dir: Direction) -> bool:
			var pt: Vector2i = controlled_actor.location.position + dir.vector
			if not map.is_in_bounds_p(pt):
				return false
			if not map.is_walkable_p(pt):
				return false
			if map.is_on_map_border(pt.x, pt.y):
				return false
			if map.get_actor_at(pt) != null:
				return false
			if map.get_exit_at(pt) != null:
				return false

			# outside.
			if map.get_tile_at(pt.x, pt.y).is_inside:
				return false

			# count stuff there.
			var walls_around: int = map.count_adjacent_in_map(pt, func(pt_adj: Vector2i) -> bool: return not map.get_tile_at_p(pt_adj).model.is_walkable)
			var lforts_around: int = map.count_adjacent_in_map(pt,
				func(pt_adj: Vector2i) -> bool:
					var f := map.get_map_object_at(pt_adj) as Fortification
					return f != null and not f.is_transparent)

			# good spot?
			if walls_around == 3 and lforts_around == 0 and p_game.rules.roll_chance(start_line_chance):
				# fort line anchor.
				return true
			if walls_around == 0 and lforts_around == 1:
				# fort line continuation.
				return true

			# nope.
			return false,
		func(_dir: Direction) -> float:
			return float(p_game.rules.roll(0, 666)),
		func(a: float, b: float) -> bool:
			return a > b)

	# if no choice, fail.
	if choice == null:
		return null

	# get pos.
	var adj: Vector2i = controlled_actor.location.position + choice.choice.vector

	# if can't build there, fail.
	if not p_game.rules.can_actor_build_fortification(controlled_actor, adj, true).ok:
		return null

	# ok!
	return ActionBuildFortification.new(controlled_actor, p_game, adj, true)


# Breaking objects

## C# BehaviorAttackBarricade(game).
func behavior_attack_barricade(p_game: RogueGame) -> ActorAction:
	# find barricades.
	var map: Map = controlled_actor.location.map
	var adj_barricades = map.filter_adjacent_in_map(controlled_actor.location.position,
		func(pt: Vector2i) -> bool:
			var door := map.get_map_object_at(pt) as DoorWindow
			return door != null and door.is_barricaded)

	# if none, fail.
	if adj_barricades == null:
		return null

	# try to attack one at random.
	var random_barricade: DoorWindow = map.get_map_object_at(adj_barricades[p_game.rules.roll(0, adj_barricades.size())]) as DoorWindow
	var attack_barricade: ActionBreak = ActionBreak.new(controlled_actor, p_game, random_barricade)
	if attack_barricade.is_legal():
		return attack_barricade

	# nope :(
	return null


## C# BehaviorAssaultBreakables(game, fov).
func behavior_assault_breakables(p_game: RogueGame, fov) -> ActorAction:
	# find all barricades & breakables in fov.
	var map: Map = controlled_actor.location.map
	var breakables = null
	for pt in fov:
		var map_obj: MapObject = map.get_map_object_at(pt)
		if map_obj == null:
			continue
		if not map_obj.is_breakable:
			continue
		if breakables == null:
			breakables = []
		breakables.append(Percept.new(map_obj, map.local_time.turn_counter, Location.new(map, pt)))

	# if nothing to assault, fail.
	if breakables == null:
		return null

	# get nearest.
	var nearest: Percept = filter_nearest(p_game, breakables)

	# if adjacent, try to break it.
	if p_game.rules.is_adjacent(controlled_actor.location.position, nearest.location.position):
		var break_it: ActionBreak = ActionBreak.new(controlled_actor, p_game, nearest.percepted as MapObject)
		if break_it.is_legal():
			return break_it
		else:
			# illegal, don't bother with it.
			return null

	# not adjacent, try to get there.
	return behavior_intelligent_bump_toward(p_game, nearest.location.position, true, true)


# Pushing

## C# BehaviorPushNonWalkableObject(game).
func behavior_push_non_walkable_object(p_game: RogueGame) -> ActorAction:
	# check ability.
	if not p_game.rules.has_actor_push_ability(controlled_actor):
		return null

	# find adjacent pushables that are blocking for us.
	var map: Map = controlled_actor.location.map
	var adj_pushables = map.filter_adjacent_in_map(controlled_actor.location.position,
		func(pt: Vector2i) -> bool:
			var obj: MapObject = map.get_map_object_at(pt)
			if obj == null:
				return false
			# ignore if we can walk through it.
			if obj.is_walkable:
				return false
			# finally only if we can push it.
			return p_game.rules.can_actor_push(controlled_actor, obj))

	# if none, fail.
	if adj_pushables == null:
		return null

	# try to push one at random in a random direction.
	var random_pushable: MapObject = map.get_map_object_at(adj_pushables[p_game.rules.roll(0, adj_pushables.size())])
	var push_it: ActionPush = ActionPush.new(controlled_actor, p_game, random_pushable, p_game.rules.roll_direction())
	if push_it.is_legal():
		return push_it

	# nope :(
	return null


# Healing & Entertainment

## C# BehaviorUseMedecine(game, factorHealing, factorStamina, factorSleep, factorCure, factorSan).
func behavior_use_medecine(p_game: RogueGame, factor_healing: int, factor_stamina: int, factor_sleep: int, factor_cure: int, factor_san: int) -> ActorAction:
	# if no items, don't bother.
	var inv: Inventory = controlled_actor.inventory
	if inv == null or inv.is_empty:
		return null

	# check needs.
	var need_hp: bool = controlled_actor.hit_points < p_game.rules.actor_max_hps(controlled_actor)
	var need_sta: bool = p_game.rules.is_actor_tired(controlled_actor)
	var need_slp: bool = controlled_actor.model.abilities.has_to_sleep and would_like_to_sleep(p_game, controlled_actor)
	var need_cure: bool = controlled_actor.infection > 0
	var need_san: bool = controlled_actor.model.abilities.has_sanity and controlled_actor.sanity < int(0.75 * p_game.rules.actor_max_sanity(controlled_actor))

	# if no need, don't.
	if not need_hp and not need_sta and not need_slp and not need_cure and not need_san:
		return null

	# list meds items.
	var med_items = inv.get_items_by_type(ItemMedicine)
	if med_items == null:
		return null

	# use best item.
	var best_med_choice: BaseAI.ChoiceEval = choose(p_game, med_items,
		func(_it: ItemMedicine) -> bool:
			return true,
		func(it: ItemMedicine) -> float:
			var score: int = 0
			if need_hp:
				score += factor_healing * it.healing
			if need_sta:
				score += factor_stamina * it.stamina_boost
			if need_slp:
				score += factor_sleep * it.sleep_boost
			if need_cure:
				score += factor_cure * it.infection_cure
			if need_san:
				score += factor_san * it.sanity_cure
			return float(score),
		func(a: float, b: float) -> bool:
			return a > b)

	# if no suitable items or best item scores zero, do not want!
	if best_med_choice == null or best_med_choice.value <= 0:
		return null

	# use med.
	return ActionUseItem.new(controlled_actor, p_game, best_med_choice.choice)


## C# BehaviorUseEntertainment(game).
func behavior_use_entertainment(p_game: RogueGame) -> ActorAction:
	var inv: Inventory = controlled_actor.inventory
	if inv.is_empty:
		return null

	# use first entertainment item available.
	var ent := inv.get_first_by_type(ItemEntertainment) as ItemEntertainment
	if ent == null:
		return null

	if not p_game.rules.can_actor_use_item(controlled_actor, ent).ok:
		return null

	return ActionUseItem.new(controlled_actor, p_game, ent)


## C# BehaviorDropBoringEntertainment(game).
func behavior_drop_boring_entertainment(p_game: RogueGame) -> ActorAction:
	var inv: Inventory = controlled_actor.inventory
	if inv.is_empty:
		return null

	for it in inv.items:
		var ent := it as ItemEntertainment
		if ent != null and ent.is_boring_for(controlled_actor):  # alpha10 boring items item centric
			return ActionDropItem.new(controlled_actor, p_game, it)

	return null


# Following

## C# BehaviorFollowActor(game, other, otherPosition, isVisible, maxDist).
func behavior_follow_actor(p_game: RogueGame, other: Actor, other_position: Vector2i, is_visible: bool, max_dist: int) -> ActorAction:
	# if no other or dead, don't.
	if other == null or other.is_dead:
		return null

	# if close enough and visible, wait there.
	var dist: int = p_game.rules.grid_distance_points(controlled_actor.location.position, other_position)
	if is_visible and dist <= max_dist:
		return ActionWait.new(controlled_actor, p_game)

	# if in different map and standing on an exit that leads there, try to use the exit.
	if other.location.map != controlled_actor.location.map:
		var exit_there: Map.Exit = controlled_actor.location.map.get_exit_at(controlled_actor.location.position)
		if exit_there != null and exit_there.to_map == other.location.map:
			if p_game.rules.can_actor_use_exit(controlled_actor, controlled_actor.location.position).ok:
				return ActionUseExit.new(controlled_actor, controlled_actor.location.position, p_game)

	# try to get close.
	var bump_action: ActorAction = behavior_intelligent_bump_toward(p_game, other_position, false, false)
	if bump_action != null and bump_action.is_legal():
		# run if other is running.
		if other.is_running:
			run_if_possible(p_game.rules)

		# done.
		return bump_action

	# fail.
	return null


## C# BehaviorHangAroundActor(game, other, otherPosition, minDist, maxDist).
func behavior_hang_around_actor(p_game: RogueGame, other: Actor, other_position: Vector2i, min_dist: int, max_dist: int) -> ActorAction:
	# if no other or dead, don't.
	if other == null or other.is_dead:
		return null

	# pick a random spot around other within distance.
	var hang_spot: Vector2i
	var tries: int = 0
	var MAX_TRIES: int = 100
	while tries < MAX_TRIES:
		hang_spot = other_position
		hang_spot.x += p_game.rules.roll(min_dist, max_dist + 1) - p_game.rules.roll(min_dist, max_dist + 1)
		hang_spot.y += p_game.rules.roll(min_dist, max_dist + 1) - p_game.rules.roll(min_dist, max_dist + 1)
		hang_spot = controlled_actor.location.map.trim_to_bounds(hang_spot.x, hang_spot.y)
		tries += 1
		if p_game.rules.grid_distance_points(hang_spot, other_position) >= min_dist:
			break

	# try to get close.
	var bump_action: ActorAction = behavior_intelligent_bump_toward(p_game, hang_spot, false, false)
	if bump_action != null and is_valid_move_toward_goal_action(bump_action) and bump_action.is_legal():
		# run if other is running.
		if other.is_running:
			run_if_possible(p_game.rules)

		# done.
		return bump_action

	# fail.
	return null


# Tracking scents

## C# BehaviorTrackScent(game, scents).
func behavior_track_scent(p_game: RogueGame, scents) -> ActorAction:
	# if no scents, nothing to do.
	if scents == null or scents.size() == 0:
		return null

	# get highest scent.
	var best: Percept = filter_strongest_scent(p_game, scents)

	# 2 cases:
	# 1. Standing on best scent.
	# or
	# 2. Best scent is adjacent.
	var map: Map = controlled_actor.location.map
	# 1. Standing on best scent.
	if controlled_actor.location.position == best.location.position:
		# if exit there and can and want to use it, do it.
		var exit_there: Map.Exit = map.get_exit_at(controlled_actor.location.position)
		if exit_there != null and controlled_actor.model.abilities.ai_can_use_ai_exits:
			return behavior_use_exit(p_game, UseExitFlags.ATTACK_BLOCKING_ENEMIES | UseExitFlags.BREAK_BLOCKING_OBJECTS)
		else:
			return null

	# 2. Best scent is adjacent.
	# try to bump there.
	var bump: ActorAction = behavior_intelligent_bump_toward(p_game, best.location.position, false, false)
	if bump != null:
		return bump

	# nope.
	return null


# Charging enemy

# alpha10 added break and push
## C# BehaviorChargeEnemy(game, target, canCheckBreak, canCheckPush).
func behavior_charge_enemy(p_game: RogueGame, target: Percept, can_check_break: bool, can_check_push: bool) -> ActorAction:
	# try melee attack first.
	var attack: ActorAction = behavior_melee_attack(p_game, target)
	if attack != null:
		return attack

	var enemy := target.percepted as Actor

	# if we are tired and next to enemy, use med or rest to recover our STA for the next attack.
	if p_game.rules.is_actor_tired(controlled_actor) and p_game.rules.is_adjacent(controlled_actor.location, target.location):
		# meds?
		var use_med: ActorAction = behavior_use_medecine(p_game, 0, 1, 0, 0, 0)
		if use_med != null:
			return use_med

		# rest!
		return ActionWait.new(controlled_actor, p_game)

	# then try getting closer.
	var bump_action: ActorAction = behavior_intelligent_bump_toward(p_game, target.location.position, can_check_break, can_check_push)
	if bump_action != null:
		# do we rush?
		# we want to rush if enemy has a range advantage, we want to get closer asap.
		if controlled_actor.current_ranged_attack.range_value < enemy.current_ranged_attack.range_value:
			run_if_possible(p_game.rules)

		# chaaarge!
		return bump_action

	# failed.
	return null


# Leading

## C# BehaviorLeadActor(game, target).
func behavior_lead_actor(p_game: RogueGame, target: Percept) -> ActorAction:
	var other := target.percepted as Actor

	# if can't lead him, fail.
	if not p_game.rules.can_actor_take_lead(controlled_actor, other).ok:
		return null

	# if next to him, lead him.
	if p_game.rules.is_adjacent(controlled_actor.location.position, other.location.position):
		return ActionTakeLead.new(controlled_actor, p_game, other)

	# then try getting closer.
	var bump_action: ActorAction = behavior_intelligent_bump_toward(p_game, other.location.position, false, false)
	if bump_action != null:
		return bump_action

	# failed.
	return null


## C# BehaviorDontLeaveFollowersBehind(game, distance, out target)
## -> Dictionary {"action": ActorAction (null if none), "target": Actor (null if none)}.
func behavior_dont_leave_followers_behind(p_game: RogueGame, distance: int) -> Dictionary:
	var target: Actor = null

	# alpha10.1 dont always check for lagging followers, prevent leader from getting stuck waiting too much.
	# side effect is more occurence of followers lagging behind.
	if p_game.rules.roll_chance(25):
		return {"action": null, "target": null}

	# Scan the group:
	# - Find farthest member of the group.
	# - If at least half the group is close enough we consider the group cohesion to be good enough and do nothing.
	var worst_dist: int = -2147483648
	var map: Map = controlled_actor.location.map
	var my_pos: Vector2i = controlled_actor.location.position
	var close_count: int = 0
	var half_group: int = controlled_actor.count_followers / 2
	for a in controlled_actor.followers:
		# ignore actors on different map.
		if a.location.map != map:
			continue

		# this actor close enough?
		if p_game.rules.grid_distance_points(a.location.position, my_pos) <= distance:
			# if half close enough, nothing to do.
			close_count += 1
			if close_count >= half_group:
				return {"action": null, "target": null}

		# farthest?
		var dist: int = p_game.rules.grid_distance_points(a.location.position, my_pos)
		if target == null or dist > worst_dist:
			target = a
			worst_dist = dist

	# try to move toward farther dude.
	if target == null:
		return {"action": null, "target": null}
	return {"action": behavior_intelligent_bump_toward(p_game, target.location.position, false, false), "target": target}


## Engage in mele fight with the nearest reachable enemy or flee from him.
## emotes : 0 = flee; 1 = trapped; 2 = charge.
## C# BehaviorFightOrFlee(game, enemies, hasVisibleLeader, isLeaderFighting, courage, emotes, allowedChargeActions).
func behavior_fight_or_flee(p_game: RogueGame, enemies, _has_visible_leader: bool, is_leader_fighting: bool, courage: int,
		emotes: Array, allowed_charge_actions: int) -> ActorAction:
	# alpha10 filter out unreachables if no ranged weapon equipped
	# (we shouldnt be here anyway if we have a ranged weapon)
	if controlled_actor.get_equipped_ranged_weapon() == null:
		enemies = filter_out_unreachable_percepts(p_game, enemies, allowed_charge_actions)
		if enemies.size() == 0:
			return null

	var nearest_enemy: Percept = filter_nearest(p_game, enemies)

	var decide_to_flee: bool
	var do_run: bool = false  # don't run by default.

	var enemy := nearest_enemy.percepted as Actor

	# alpha10
	# get enemy attack
	var enemy_attack: Attack = get_actor_attack(p_game, enemy)

	# always try to heal if enemy next attack could kill us
	if controlled_actor.hit_points - enemy_attack.damage_value <= 0:
		var heal_action: ActorAction = behavior_use_medecine(p_game, 10, 0, 0, 0, 0)
		if heal_action != null:
			controlled_actor.activity = Activity.FIGHTING
			controlled_actor.target_actor = enemy
			return heal_action

	# get safe range from enemy, just out of his reach.
	var safe_range: int = maxi(2, enemy_attack.range_value + 1)  # melee attack range is 0 not 1!
	var dist_to_enemy: int = p_game.rules.grid_distance_points(controlled_actor.location.position, enemy.location.position)
	var _in_safe_range: bool = dist_to_enemy >= safe_range

	# Cases that are a no brainer, in this order:
	# 1. Always fight if he has a ranged weapon.
	# 2. Always fight if law enforcer vs murderer.
	# 3. Always flee melee if tired

	# 1. Always fight if enemy has ranged weapon.
	# if we are here, it means we can't shoot him, cause firing behavior has priority.
	# so we want to get a chance at melee a shooting enemy.
	if has_equiped_ranged_weapon(enemy):
		decide_to_flee = false
	# 2. Always fight if law enforcer vs murderer.
	# do our duty.
	elif controlled_actor.model.abilities.is_law_enforcer and enemy.murders_counter > 0:
		decide_to_flee = false
	# 3. Always flee melee if tired
	elif p_game.rules.is_actor_tired(controlled_actor) and dist_to_enemy == 1:
		decide_to_flee = true
	# Case need more analysis.
	else:
		if controlled_actor.leader != null:
			##########################
			# Fighting with a leader.
			##########################
			match courage:
				ActorDirective.ActorCourage.COWARD:
					# always flee and run.
					decide_to_flee = true
					do_run = true

				ActorDirective.ActorCourage.CAUTIOUS:
					# kite.
					decide_to_flee = want_to_evade_melee(p_game, controlled_actor, courage, enemy)
					do_run = not has_speed_advantage(p_game, controlled_actor, enemy)

				ActorDirective.ActorCourage.COURAGEOUS:
					# fight if leader is fighting.
					# otherwise kite.
					if is_leader_fighting:
						decide_to_flee = false
					else:
						decide_to_flee = want_to_evade_melee(p_game, controlled_actor, courage, enemy)
						do_run = not has_speed_advantage(p_game, controlled_actor, enemy)

				_:
					# C# threw; keep a safe default (stand ground) instead of
					# hard-crashing debug builds.
					push_error("unhandled courage %s" % courage)
		else:
			########################
			# Leaderless fighting.
			########################
			match courage:
				ActorDirective.ActorCourage.COWARD:
					# always flee and run.
					decide_to_flee = true
					do_run = true

				ActorDirective.ActorCourage.CAUTIOUS, ActorDirective.ActorCourage.COURAGEOUS:
					# kite.
					decide_to_flee = want_to_evade_melee(p_game, controlled_actor, courage, enemy)
					do_run = not has_speed_advantage(p_game, controlled_actor, enemy)

				_:
					# C# threw; keep a safe default (stand ground) instead of
					# hard-crashing debug builds.
					push_error("unhandled courage %s" % courage)

	# alpha10
	# Improve STA management a bit.
	# Cancel running if this would make us tired and we don't have equipped a ranged weapon so keeping
	# TODO -- consider other cases were running would be a waste of STA.
	if do_run and will_tire_after_running(p_game, controlled_actor):
		if not has_equiped_ranged_weapon(controlled_actor):
			do_run = false

	# alpha10
	# If we have no ranged weapon and target is unreachable, no point charging him as we can't get into
	# melee contact. Flee if enemy has equipped a ranged weapon and do nothing if not.
	if not decide_to_flee:
		if not has_any_ranged_weapon_with_ammo():
			# check route
			if not can_reach_simple(p_game, enemy.location.position, allowed_charge_actions):
				var enemy_wpn := enemy.get_equipped_weapon() as ItemRangedWeapon
				if enemy_wpn != null:
					# even if out of ammo assumes he will reload or find ammo, better be safe.
					decide_to_flee = true
				else:
					# enemy has no ranged weapon and unreachable, possibly no threat to us better
					# do something else instead.
					return null

	# flee or fight?
	if decide_to_flee:
		# Try to:
		# 1. Close door between me and the enemy if he can't open it right after we closed it.
		# 2. Barricade door between me and the enemy.
		# 3. Use exit?
		# 4. Use medecine?
		# 5. Rest if tired and at safe distance  // alpha10
		# 6. Walk/run away.
		# 7. Blocked, turn to fight.

		# emote?
		if controlled_actor.model.abilities.can_talk and p_game.rules.roll_chance(EMOTE_FLEE_CHANCE):
			p_game.do_emote(controlled_actor, "%s %s!" % [emotes[0], enemy.name])

		# 1. Close door between me and the enemy if he can't open it right after we closed it.
		if controlled_actor.model.abilities.can_use_map_objects:
			var close_door_between_direction: BaseAI.ChoiceEval = choose(p_game, Direction.COMPASS_LIST,
				func(dir: Direction) -> bool:
					var pos: Vector2i = controlled_actor.location.position + dir.vector
					var door := controlled_actor.location.map.get_map_object_at(pos) as DoorWindow
					if door == null:
						return false
					if not is_between(p_game, controlled_actor.location.position, pos, enemy.location.position):
						return false
					if not p_game.rules.is_closable_for(controlled_actor, door).ok:
						return false
					if p_game.rules.grid_distance_points(pos, enemy.location.position) == 1 and p_game.rules.is_closable_for(enemy, door).ok:
						return false
					return true,
				func(_dir: Direction) -> float:
					return float(p_game.rules.roll(0, 666)),  # random eval, all things being equal.
				func(a: float, b: float) -> bool:
					return a > b)
			if close_door_between_direction != null:
				return ActionCloseDoor.new(controlled_actor, p_game, controlled_actor.location.map.get_map_object_at(controlled_actor.location.position + close_door_between_direction.choice.vector) as DoorWindow)

		# 2. Barricade door between me and the enemy.
		if controlled_actor.model.abilities.can_barricade:
			var barricade_door_between_direction: BaseAI.ChoiceEval = choose(p_game, Direction.COMPASS_LIST,
				func(dir: Direction) -> bool:
					var pos: Vector2i = controlled_actor.location.position + dir.vector
					var door := controlled_actor.location.map.get_map_object_at(pos) as DoorWindow
					if door == null:
						return false
					if not is_between(p_game, controlled_actor.location.position, pos, enemy.location.position):
						return false
					if not p_game.rules.can_actor_barricade_door(controlled_actor, door).ok:
						return false
					return true,
				func(_dir: Direction) -> float:
					return float(p_game.rules.roll(0, 666)),  # random eval, all things being equal.
				func(a: float, b: float) -> bool:
					return a > b)
			if barricade_door_between_direction != null:
				return ActionBarricadeDoor.new(controlled_actor, p_game, controlled_actor.location.map.get_map_object_at(controlled_actor.location.position + barricade_door_between_direction.choice.vector) as DoorWindow)

		# 3. Use exit?
		if controlled_actor.model.abilities.ai_can_use_ai_exits and p_game.rules.roll_chance(FLEE_THROUGH_EXIT_CHANCE):
			var use_exit: ActorAction = behavior_use_exit(p_game, UseExitFlags.NONE)
			if use_exit != null:
				var do_use_exit: bool = true

				# Exception : if follower use exit only if leading to our leader.
				# we don't want to leave our leader behind (mostly annoying for the player).
				if controlled_actor.has_leader:
					var exit_there: Map.Exit = controlled_actor.location.map.get_exit_at(controlled_actor.location.position)
					if exit_there != null:  # well. who knows?
						do_use_exit = (controlled_actor.leader.location.map == exit_there.to_map)

				# do it?
				if do_use_exit:
					controlled_actor.activity = Activity.FLEEING
					return use_exit

		# 4. Use medecine?
		# when to use medecine? only when fighting vs an unranged enemy and not in contact.
		if enemy.get_equipped_ranged_weapon() == null and not p_game.rules.is_adjacent(controlled_actor.location, enemy.location):
			var med_action: ActorAction = behavior_use_medecine(p_game, 2, 2, 1, 0, 0)
			if med_action != null:
				controlled_actor.activity = Activity.FLEEING
				return med_action

		# alpha10
		# 5. Rest if tired and at safe distance
		if p_game.rules.is_actor_tired(controlled_actor):
			if p_game.rules.grid_distance_points(controlled_actor.location.position, enemy.location.position) >= safe_range:
				controlled_actor.activity = Activity.FLEEING
				return ActionWait.new(controlled_actor, p_game)

		# 6. Walk/run away.
		var bump_action: ActorAction = behavior_walk_away_from_goals(p_game, enemies)
		if bump_action != null:
			if do_run:
				run_if_possible(p_game.rules)
			controlled_actor.activity = Activity.FLEEING
			return bump_action

		# 7. Blocked, turn to fight.
		if bump_action == null:
			# fight!
			if is_adjacent_to_enemy(p_game, enemy):
				# emote?
				if controlled_actor.model.abilities.can_talk and p_game.rules.roll_chance(EMOTE_FLEE_TRAPPED_CHANCE):
					p_game.do_emote(controlled_actor, emotes[1], true)

				return behavior_melee_attack(p_game, nearest_enemy)
	else:
		# Fight
		var attack_action: ActorAction = behavior_charge_enemy(p_game, nearest_enemy, true, true)
		if attack_action != null:
			# emote?
			if controlled_actor.model.abilities.can_talk and p_game.rules.roll_chance(EMOTE_CHARGE_CHANCE):
				p_game.do_emote(controlled_actor, "%s %s!" % [emotes[2], enemy.name], true)

			# chaaarge!
			controlled_actor.activity = Activity.FIGHTING
			controlled_actor.target_actor = nearest_enemy.percepted as Actor
			return attack_action

	# nope.
	return null


# Communication

## C# BehaviorWarnFriends(game, friends, nearestEnemy).
func behavior_warn_friends(p_game: RogueGame, friends, nearest_enemy: Actor) -> ActorAction:
	# Never if actor is itself adjacent to the enemy.
	if p_game.rules.is_adjacent(controlled_actor.location, nearest_enemy.location):
		return null

	# Shout if leader is sleeping.


	# (kinda hax, but make followers more useful for players over phone)
	if controlled_actor.has_leader and controlled_actor.leader.is_sleeping:
		return ActionShout.new(controlled_actor, p_game)

	# Shout if we have a friend sleeping.
	for p: Percept in friends:
		var other := p.percepted as Actor
		assert(other != null, "percept not an actor")
		if other == null or other == controlled_actor:
			continue
		if not other.is_sleeping:
			continue
		if p_game.rules.are_enemies(controlled_actor, other):
			continue
		if not p_game.rules.are_enemies(other, nearest_enemy):
			continue

		# friend sleeping, wake up!
		var shout_text: String = "Wake up %s!" % other.name if nearest_enemy == null else "Wake up %s! %s sighted!" % [other.name, nearest_enemy.name]
		return ActionShout.new(controlled_actor, p_game, shout_text)

	# no one to alert.
	return null


## C# BehaviorTellFriendAboutPercept(game, percept).
func behavior_tell_friend_about_percept(p_game: RogueGame, percept: Percept) -> ActorAction:
	# get an adjacent awake friend, if none nothing to do.
	var map: Map = controlled_actor.location.map
	var friends = map.filter_adjacent_in_map(controlled_actor.location.position,
		func(pt: Vector2i) -> bool:
			var other_actor: Actor = map.get_actor_at(pt)
			if other_actor == null:
				return false
			if other_actor.is_sleeping:
				return false
			if p_game.rules.are_enemies(controlled_actor, other_actor):
				return false
			return true)
	if friends == null or friends.size() == 0:
		return null

	# pick a random friend.
	var friend: Actor = map.get_actor_at(friends[p_game.rules.roll(0, friends.size())])

	# make message.
	var tell_msg: String
	var where_msg: String = make_centric_location_direction(p_game, controlled_actor.location, percept.location)
	var time_msg: String = "%s ago" % WorldTime.make_time_duration_message(controlled_actor.location.map.local_time.turn_counter - percept.turn)
	if percept.percepted is Actor:
		var who := percept.percepted as Actor
		tell_msg = "I saw %s %s %s." % [who.name, where_msg, time_msg]
	elif percept.percepted is Inventory:
		# tell about a random item from the pile.
		# warning: the items might have changed since then, the AI cheats a bit by knowing which items are there now.
		var inv := percept.percepted as Inventory
		if inv.is_empty:
			return null    # all items were taken or destroyed.
		var what: Item = inv.items[p_game.rules.roll(0, inv.count_items)]

		# ignore worthless items (eg: don't spam about stupid items like planks)
		if not is_item_worth_telling_about(what):
			return null

		# ignore stacks that are probably in plain view of the friend.
		var friend_fov_range: int = p_game.rules.actor_fov(friend, map.local_time, p_game.session.world.weather)
		if percept.location.map == friend.location.map \
				and p_game.rules.std_distance(percept.location.position, friend.location.position) <= 2 + friend_fov_range:
			return null

		# do it.
		tell_msg = "I saw %s %s %s." % [what.a_name, where_msg, time_msg]
	elif percept.percepted is String:
		var raid_desc: String = percept.percepted
		tell_msg = "I heard %s %s %s!" % [raid_desc, where_msg, time_msg]
	else:
		# C# threw; don't hard-crash debug builds.
		push_error("unhandled percept.Percepted type")
		return null

	# tell friend - if legal.
	var say: ActionSay = ActionSay.new(controlled_actor, p_game, friend, tell_msg, RogueGame.Sayflags.NONE)
	if say.is_legal():
		return say
	else:
		return null


# Exploring

## C# BehaviorExplore(game, exploration).
func behavior_explore(p_game: RogueGame, exploration: ExplorationData) -> ActorAction:
	# prepare data.
	var prev_direction: Direction = Direction.from_vector_xy(controlled_actor.location.position.x - _prev_location.position.x, controlled_actor.location.position.y - _prev_location.position.y)
	var im_starving_or_courageous: bool = p_game.rules.is_actor_starving(controlled_actor) or directives.courage == ActorDirective.ActorCourage.COURAGEOUS
	var is_intelligent: bool = controlled_actor.model.abilities.is_intelligent

	# eval all adjacent tiles for exploration utility and get the best one.

	var choose_explore_dir: BaseAI.ChoiceEval = choose(p_game,
		Direction.COMPASS_LIST,
		func(dir: Direction) -> bool:
			var next: Location = controlled_actor.location.plus(dir)

			# alpha10.1 bot mode fix (C# DEBUG build)
			if not next.map.is_in_bounds_p(next.position):
				return false

			if exploration.has_explored(next):
				return false

			# alpha10.1 dont break stuff to explore
			var bump_action: ActorAction = p_game.rules.is_bumpable_for(controlled_actor, p_game, next).action
			if bump_action != null and (bump_action is ActionBreak or bump_action is ActionBashDoor):
				return false

			return is_valid_move_toward_goal_action(bump_action),
		func(dir: Direction) -> float:
			var next: Location = controlled_actor.location.plus(dir)
			var map: Map = next.map
			var pos: Vector2i = next.position

			# intelligent NPC: forbid stepping on deadly traps, unless starving or courageous (desperate).
			if controlled_actor.model.abilities.is_intelligent and not im_starving_or_courageous:
				var traps_damage: int = compute_traps_max_damage_for_me(p_game, map, pos)
				if traps_damage >= controlled_actor.hit_points:
					return NAN

			# Heuristic scoring:
			# 0st Punish backtracking // alpha10.1
			# 1st Prefer unexplored zones.
			# 2nd Prefer unexplored locs.
			# 3rd Prefer doors and barricades (doors/windows, pushables)
			# 4th If intelligent punish stepping on unsafe traps. // alpha10
			# 5th Prefer inside during the night vs outside during the day, and inside if sleepy // alpha10.1
			# 6th Prefer continue in same direction.
			# 7th Small randomness.
			var BACKTRACKING: int = -10000  # alpha10.1
			var EXPLORE_ZONES: int = 1000
			var EXPLORE_LOCS: int = 500
			var EXPLORE_BARRICADES: int = 100
			var AVOID_TRAPS: int = -1000  # alpha10 greatly increase penalty and x by potential damage; was -50
			var EXPLORE_INOUT: int = 50
			var EXPLORE_IN_ALMOST_SLEEPY: int = 100  # alpha10.1
			var EXPLORE_DIRECTION: int = 25
			var EXPLORE_RANDOM: int = 10

			var score: int = 0
			# 0st Punish backtracking // alpha10.1
			if next.map == _prev_location.map and pos == _prev_location.position:
				score += BACKTRACKING
			# 1st Prefer unexplored zones.
			# alpha10.1 use age to prefer older zones
			var zone_age: int = exploration.get_explored_age_zones(map.get_zones_at(pos.x, pos.y))
			if zone_age == 0:  # unexplored (or expired)
				score += EXPLORE_ZONES
			else:
				score += zone_age
			# 2nd Prefer unexplored locs.
			# alpha10.1 use age to prefer older locs
			var loc_age: int = exploration.get_explored_age(next)
			if loc_age == 0:  # unexplored (or expired)
				score += EXPLORE_LOCS
			else:
				score += 2 * loc_age
			# 3rd Prefer doors and barricades (doors/windows, pushables)
			var map_obj: MapObject = map.get_map_object_at(pos)
			if map_obj != null and (map_obj.is_movable or map_obj is DoorWindow):
				score += EXPLORE_BARRICADES
			# 4th If intelligent punish stepping on unsafe traps. // alpha10
			if is_intelligent:
				var traps_dmg: int = compute_traps_max_damage_for_me(p_game, map, pos)
				if traps_dmg > 0:
					score += traps_dmg * AVOID_TRAPS
			# 5th Prefer inside during the night vs outside during the day, and inside if sleepy // alpha10.1
			var _is_inside: bool = map.get_tile_at(pos.x, pos.y).is_inside
			if _is_inside:
				if p_game.rules.is_almost_sleepy(controlled_actor):
					score += EXPLORE_IN_ALMOST_SLEEPY
				if map.local_time.is_night:
					score += EXPLORE_INOUT
			else:
				if not map.local_time.is_night:
					score += EXPLORE_INOUT
			# 6th Prefer continue in same direction.
			if dir == prev_direction:
				score += EXPLORE_DIRECTION
			# 7th Small randomness.
			score += p_game.rules.roll(0, EXPLORE_RANDOM)

			# done.
			return float(score),
		func(a: float, b: float) -> bool:
			return not is_nan(a) and a > b)

	if choose_explore_dir != null:
		return ActionBump.new(controlled_actor, p_game, choose_explore_dir.choice)
	else:
		return null


# Advanced movement

## C# BehaviorCloseDoorBehindMe(game, previousLocation).
func behavior_close_door_behind_me(p_game: RogueGame, previous_location: Location) -> ActorAction:
	# if we've gone through a door, try to close it.
	var prev_door := previous_location.map.get_map_object_at(previous_location.position) as DoorWindow
	if prev_door == null:
		return null
	if p_game.rules.is_closable_for(controlled_actor, prev_door).ok:
		return ActionCloseDoor.new(controlled_actor, p_game, prev_door)

	# nope.
	return null


## C# BehaviorSecurePerimeter(game, fov).
func behavior_secure_perimeter(p_game: RogueGame, fov) -> ActorAction:


	# Secure room procedure:
	# 1. Close doors/windows.
	# 2. Barricade unbarricaded windows.
	var map: Map = controlled_actor.location.map

	for pt in fov:
		var map_obj: MapObject = map.get_map_object_at(pt)
		if map_obj == null:
			continue
		var door := map_obj as DoorWindow
		if door == null:
			continue

		# 1. Close doors/windows.
		if door.is_open and p_game.rules.is_closable_for(controlled_actor, door).ok:
			if p_game.rules.is_adjacent(door.location.position, controlled_actor.location.position):
				return ActionCloseDoor.new(controlled_actor, p_game, door)
			else:
				return behavior_intelligent_bump_toward(p_game, door.location.position, false, false)

		# 2. Barricade unbarricaded windows.
		if door.is_window and not door.is_barricaded and p_game.rules.can_actor_barricade_door(controlled_actor, door).ok:
			if p_game.rules.is_adjacent(door.location.position, controlled_actor.location.position):
				return ActionBarricadeDoor.new(controlled_actor, p_game, door)
			else:
				return behavior_intelligent_bump_toward(p_game, door.location.position, false, false)

	# nothing to secure.
	return null


# Exits

## [Flags] enum UseExitFlags.
enum UseExitFlags {
	## Use only free exits.
	NONE = 0,
	## Can try to break a blocking object.
	BREAK_BLOCKING_OBJECTS = (1 << 0),
	## Can try to attack a blocking actor.
	ATTACK_BLOCKING_ENEMIES = (1 << 1),
	## Do not use exit if we go back to our last location.
	DONT_BACKTRACK = (1 << 2),
}


## Intelligent use of exit through flags : can prevent from backtracking, can attack object, can attack actor.
## C# BehaviorUseExit(game, useFlags).
func behavior_use_exit(p_game: RogueGame, use_flags: int) -> ActorAction:
	# get exit at location, if none or ai flag not set, fail.
	var exit: Map.Exit = controlled_actor.location.map.get_exit_at(controlled_actor.location.position)
	if exit == null:
		return null
	if not exit.is_an_ai_exit:
		return null

	# don't backtrack?
	if (use_flags & UseExitFlags.DONT_BACKTRACK) != 0:
		if exit.to_map == _prev_location.map and exit.to_position == _prev_location.position:
			return null

	# if exit blocked by an enemy and want to attack it, do it.
	if (use_flags & UseExitFlags.ATTACK_BLOCKING_ENEMIES) != 0:
		var blocking_actor: Actor = exit.to_map.get_actor_at(exit.to_position)
		if blocking_actor != null and p_game.rules.are_enemies(controlled_actor, blocking_actor) and p_game.rules.can_actor_melee_attack(controlled_actor, blocking_actor).ok:
			return ActionMeleeAttack.new(controlled_actor, p_game, blocking_actor)

	# if exit blocked by a breakable object and want to bash, do it.
	if (use_flags & UseExitFlags.BREAK_BLOCKING_OBJECTS) != 0:
		var blocking_obj: MapObject = exit.to_map.get_map_object_at(exit.to_position)
		if blocking_obj != null and p_game.rules.is_breakable_for(controlled_actor, blocking_obj).ok:
			return ActionBreak.new(controlled_actor, p_game, blocking_obj)

	# if using exit is illegal, fail.
	if not p_game.rules.can_actor_use_exit(controlled_actor, controlled_actor.location.position).ok:
		return null

	# use the exit.
	return ActionUseExit.new(controlled_actor, controlled_actor.location.position, p_game)


# Explosives

## C# BehaviorFleeFromExplosives(game, itemStacks).
func behavior_flee_from_explosives(p_game: RogueGame, item_stacks) -> ActorAction:
	# if no items in view, don't bother.
	if item_stacks == null or item_stacks.size() == 0:
		return null

	# filter stacks that have primed explosives.
	var primed_explosives: Variant = filter(p_game, item_stacks,
		func(p: Percept) -> bool:
			var stack := p.percepted as Inventory
			if stack == null or stack.is_empty:
				return false
			for it in stack.items:
				var explosive := it as ItemPrimedExplosive
				if explosive == null:
					continue
				# found a primed explosive.
				return true
			# no primed explosive in this stack.
			return false)

	# if no primed explosive in sight, no worries.
	if primed_explosives == null or primed_explosives.size() == 0:
		return null

	# run away from primed explosives!
	var run_away: ActorAction = behavior_walk_away_from_goals(p_game, primed_explosives)
	if run_away == null:
		return null
	run_if_possible(p_game.rules)
	return run_away


## C# BehaviorThrowGrenade(game, fov, enemies).
func behavior_throw_grenade(p_game: RogueGame, fov, enemies) -> ActorAction:
	# don't bother if no enemies.
	if enemies == null or enemies.size() == 0:
		return null

	# only throw if enough enemies.
	if enemies.size() < 3:
		return null

	# don't bother if no grenade in inventory.
	var inv: Inventory = controlled_actor.inventory
	if inv == null or inv.is_empty:
		return null
	var grenade: ItemGrenade = get_first_grenade(func(it: Item) -> bool: return not is_item_taboo(it))
	if grenade == null:
		return null
	var model := grenade.model as ItemGrenadeModel

	# find the best throw point : a spot with many enemies around and no friend to hurt.
	var max_throw_range: int = p_game.rules.actor_max_throw_range(controlled_actor, model.max_throw_distance)
	var best_spot = null
	var best_spot_score: int = 0
	for pt in fov:
		# never throw within blast radius - don't suicide ^^
		if p_game.rules.grid_distance_points(controlled_actor.location.position, pt) <= model.blast_attack.radius:
			continue

		# if we can't throw there, don't bother.
		if p_game.rules.grid_distance_points(controlled_actor.location.position, pt) > max_throw_range:
			continue
		if not LOS.can_trace_throw_line(controlled_actor.location, pt, max_throw_range, null):
			continue

		# compute interest of throwing there.
		# - pro: number of enemies within blast radius.
		# - cons: friend in radius.
		# don't bother checking for blast wave actuallly reaching the targets.
		var score: int = 0
		var aborted: bool = false
		for x in range(pt.x - model.blast_attack.radius, pt.x + model.blast_attack.radius + 1):
			for y in range(pt.y - model.blast_attack.radius, pt.y + model.blast_attack.radius + 1):
				if not controlled_actor.location.map.is_in_bounds(x, y):
					continue
				var other_actor: Actor = controlled_actor.location.map.get_actor_at_xy(x, y)
				if other_actor == null:
					continue
				if other_actor == controlled_actor:
					continue
				var blast_dist_to_target: int = p_game.rules.grid_distance_points(pt, other_actor.location.position)
				if blast_dist_to_target > model.blast_attack.radius:
					continue

				# other actor within blast radius.
				# - if friend, abort and never throw there.
				# - if enemy, increase score.
				if p_game.rules.are_enemies(controlled_actor, other_actor):
					# score = damage inflicted vs target toughness(max hp).
					# -> means it is better to hurt badly one big enemy than a few scratch on a group of weaklings.
					var value: int = p_game.rules.blast_damage(blast_dist_to_target, model.blast_attack) * p_game.rules.actor_max_hps(other_actor)
					score += value
				else:
					score = -1
					aborted = true
					break
			if aborted:
				break

		# if negative score (eg: friends get hurt), don't throw.
		if score <= 0:
			continue

		# possible spot. best one?
		if best_spot == null or score > best_spot_score:
			best_spot = pt
			best_spot_score = score

	# if no throw point, don't.
	if best_spot == null:
		return null

	# equip then throw.
	if not grenade.is_equipped:
		# alpha10 mark right hand as taboo so behavior BehaviorEquipBestItems will not undo us and loop forever
		mark_equipment_slot_as_taboo(Doll.DollPart.RIGHT_HAND)

		var other_equipped: Item = controlled_actor.get_equipped_weapon()
		if other_equipped != null:
			return ActionUnequipItem.new(controlled_actor, p_game, other_equipped)
		else:
			return ActionEquipItem.new(controlled_actor, p_game, grenade)
	else:


		# alpha10 release right hand from taboo so behavior BehaviorEquipBestItems can use right hand
		unmark_equipment_slot_as_taboo(Doll.DollPart.RIGHT_HAND)

		var throw_action: ActorAction = ActionThrowGrenade.new(controlled_actor, p_game, best_spot)
		if not throw_action.is_legal():
			return null
		return throw_action


# Inventory management

## C# BehaviorMakeRoomForFood(game, stacks).
func behavior_make_room_for_food(p_game: RogueGame, stacks) -> ActorAction:
	# if no items in view, fail.
	if stacks == null or stacks.size() == 0:
		return null

	# if inventory not full, no need.
	var max_inv: int = p_game.rules.actor_max_inv(controlled_actor)
	if controlled_actor.inventory.count_items < max_inv:
		return null

	# if food item in inventory, no need.
	if has_item_of_type(ItemFood):
		return null

	# if no food item in view, fail.
	var has_food_visible: bool = false
	for p: Percept in stacks:
		var inv := p.percepted as Inventory
		if inv == null:
			continue

		if inv.has_item_of_type(ItemFood):
			has_food_visible = true
			break
	if not has_food_visible:
		return null

	# want to get rid of an item.
	# order of preference:
	# 1. get rid of not interesting item.
	# 2. get rid of barricading material.
	# 3. get rid of light & sprays.
	# 4. get rid of ammo.
	# 5. get rid of entertainment  // alpha10
	# 6. get rid of medecine.
	# 7. last resort, get rid of random item.
	var my_inv: Inventory = controlled_actor.inventory

	# 1. get rid of not interesting item.
	var not_interesting: Item = my_inv.get_first_matching(func(it: Item) -> bool: return not is_interesting_item_to_own(p_game, it, ItemSource.OWNED))
	if not_interesting != null:
		return behavior_drop_item(p_game, not_interesting)

	# 2. get rid of barricading material.
	var material: Item = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemBarricadeMaterial)
	if material != null:
		return behavior_drop_item(p_game, material)

	# 3. get rid of light & sprays.
	var light: Item = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemLight)
	if light != null:
		return behavior_drop_item(p_game, light)
	var spray: Item = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemSprayPaint)
	if spray != null:
		return behavior_drop_item(p_game, spray)
	spray = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemSprayScent)
	if spray != null:
		return behavior_drop_item(p_game, spray)

	# 4. get rid of ammo.
	var ammo: Item = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemAmmo)
	if ammo != null:
		return behavior_drop_item(p_game, ammo)

	# 5. get rid of entertainment  // alpha10
	var ent: Item = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemEntertainment)
	if ent != null:
		return behavior_drop_item(p_game, ent)

	# 6. get rid of medecine.
	var med: Item = my_inv.get_first_matching(func(it: Item) -> bool: return it is ItemMedicine)
	if med != null:
		return behavior_drop_item(p_game, med)

	# 7. last resort, get rid of random item.
	var any_item: Item = my_inv.items[p_game.rules.roll(0, my_inv.count_items)]
	return behavior_drop_item(p_game, any_item)


# Sprays

## C# BehaviorUseStenchKiller(game).
func behavior_use_stench_killer(p_game: RogueGame) -> ActorAction:
	var spray := controlled_actor.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemSprayScent

	# if no spray or empty, nope.
	if spray == null:
		return null
	if spray.spray_quantity <= 0:
		return null
	# if not proper odor, nope.
	var model := spray.model as ItemSprayScentModel
	if model.odor != Odor.SUPPRESSOR:  # alpha10
		return null

	# C# local function WantsToSprayOn(a).
	var wants_to_spray_on = func(a: Actor) -> bool:
		# never spray on player, could mess with his tactics
		if a.is_player:
			return false

		# only if self or adjacent
		if not (a == controlled_actor or p_game.rules.is_adjacent(controlled_actor.location, a.location)):
			return false

		# dont spray if already suppressed for 2h or more
		if a.odor_suppressor_counter >= 2 * WorldTime.TURNS_PER_HOUR:
			return false

		# spot must be interesting to spray for either us or the target.
		if is_good_stench_killer_spot(p_game, controlled_actor.location.map, controlled_actor.location.position):
			return true
		if is_good_stench_killer_spot(p_game, a.location.map, a.location.position):
			return true
		return false

	# alpha10
	# first check if wants to use it on self, then check on adj leader/follower
	var spray_on: Actor = null

	# self?...
	if wants_to_spray_on.call(controlled_actor):
		spray_on = controlled_actor
	else:
		# ...adj leader/mates/followers
		if controlled_actor.has_leader:
			if wants_to_spray_on.call(controlled_actor.leader):
				spray_on = controlled_actor.leader
			else:
				for mate in controlled_actor.leader.followers:
					if spray_on == null and mate != controlled_actor and wants_to_spray_on.call(mate):
						spray_on = mate

		if spray_on == null and controlled_actor.count_followers > 0:
			for follower in controlled_actor.followers:
				if spray_on == null and wants_to_spray_on.call(follower):
					spray_on = follower

	#  spray?
	if spray_on != null:
		var spray_it: ActionSprayOdorSuppressor = ActionSprayOdorSuppressor.new(controlled_actor, p_game, spray, spray_on)
		if spray_it.is_legal():
			return spray_it

	# nope.
	return null


## C# IsGoodStenchKillerSpot(game, map, pos).
func is_good_stench_killer_spot(_p_game: RogueGame, map: Map, pos: Vector2i) -> bool:
	# alpha10 obsolete 1. Don't spray at an already sprayed spot.
	# 2. Spray in a good position:
	#    2.1 entering or leaving a building.
	#    2.2 a door/window.
	#    2.3 an exit.

	# 2. Spray in a good position:

	#    2.1 entering or leaving a building.
	var was_inside: bool = _prev_location.map.get_tile_at_p(_prev_location.position).is_inside
	var _is_inside: bool = map.get_tile_at_p(pos).is_inside
	if was_inside != _is_inside:
		return true
	#    2.2 a door/window.
	var obj_there: MapObject = map.get_map_object_at(pos)
	if obj_there != null and obj_there is DoorWindow:
		return true
	#    2.3 an exit.
	if map.get_exit_at(pos) != null:
		return true

	# nope.
	return false


# Law enforcement

## C# BehaviorEnforceLaw(game, percepts, out target)
## -> Dictionary {"action": ActorAction (null if none), "target": Actor (null if none)}.
func behavior_enforce_law(p_game: RogueGame, percepts) -> Dictionary:
	var target: Actor = null

	# sanity checks.
	if not controlled_actor.model.abilities.is_law_enforcer:
		return {"action": null, "target": null}
	if percepts == null:
		return {"action": null, "target": null}

	# filter murderers that are not our enemies yet.
	var murderers: Variant = filter_actors(p_game, percepts,
		func(a: Actor) -> bool: return a.murders_counter > 0 and not p_game.rules.are_enemies(controlled_actor, a))

	# if none, nothing to do.
	if murderers == null or murderers.size() == 0:
		return {"action": null, "target": null}

	# get nearest murderer.
	var nearest_murderer: Percept = filter_nearest(p_game, murderers)
	target = nearest_murderer.percepted as Actor

	# roll against target unsuspicious skill.
	if p_game.rules.roll_chance(p_game.rules.actor_unsuspicous_chance(controlled_actor, target)):
		# emote.
		p_game.do_emote(target, "moves unnoticed by %s." % controlled_actor.name)

		# done.
		return {"action": null, "target": null}

	# mmmmhhh. who's that?
	p_game.do_emote(controlled_actor, "takes a closer look at %s." % target.name)

	# then roll chance to spot and recognize him as murderer.
	var spot_chance: int = p_game.rules.actor_spot_murderer_chance(controlled_actor, target)

	# if did not spot, nothing to do.
	if not p_game.rules.roll_chance(spot_chance):
		return {"action": null, "target": target}

	# make him our enemy and tell him!
	p_game.do_make_aggression(controlled_actor, target)
	return {"action": ActionSay.new(controlled_actor, p_game, target,
		"HEY! YOU ARE WANTED FOR %d MURDER%s!" % [target.murders_counter, "s" if target.murders_counter > 1 else ""],
		RogueGame.Sayflags.IS_IMPORTANT | RogueGame.Sayflags.IS_DANGER), "target": target}


# Animals

## C# BehaviorGoEatFoodOnGround(game, stacksPercepts).
func behavior_go_eat_food_on_ground(p_game: RogueGame, stacks_percepts) -> ActorAction:
	# nope if no percepts.
	if stacks_percepts == null:
		return null

	# filter stacks with food.
	var food_stacks: Variant = filter(p_game, stacks_percepts, func(p: Percept) -> bool:
		var inv := p.percepted as Inventory
		return inv.has_item_of_type(ItemFood))

	# nope if no food stacks.
	if food_stacks == null:
		return null

	# either 1) eat there or 2) go get it

	# 1) check food here.
	var inv_there: Inventory = controlled_actor.location.map.get_items_at(controlled_actor.location.position)
	if inv_there != null and inv_there.has_item_of_type(ItemFood):
		# eat the first food we get.
		var eat_it: Item = inv_there.get_first_by_type(ItemFood)
		return ActionEatFoodOnGround.new(controlled_actor, p_game, eat_it)
	# 2) go to nearest food.
	var nearest: Percept = filter_nearest(p_game, food_stacks)
	return behavior_stupid_bump_toward(p_game, nearest.location.position, false, false)


# Corpses & Revival

## C# BehaviorGoEatCorpse(game, corpsesPercepts).
func behavior_go_eat_corpse(p_game: RogueGame, corpses_percepts) -> ActorAction:
	# nope if no percepts.
	if corpses_percepts == null:
		return null

	# if undead, must need health.
	if controlled_actor.model.abilities.is_undead and controlled_actor.hit_points >= p_game.rules.actor_max_hps(controlled_actor):
		return null

	# either 1) eat corpses or 2) go get them.

	# 1) check corpses here.
	var corpses = controlled_actor.location.map.get_corpses_at(controlled_actor.location.position)
	if corpses != null:
		# eat the first corpse.
		var eat_it: Corpse = corpses[0]
		if p_game.rules.can_actor_eat_corpse(controlled_actor, eat_it).ok:
			return ActionEatCorpse.new(controlled_actor, p_game, eat_it)
	# 2) go to nearest corpses.
	var nearest: Percept = filter_nearest(p_game, corpses_percepts)
	return behavior_intelligent_bump_toward(p_game, nearest.location.position, true, true) \
		if controlled_actor.model.abilities.is_intelligent else \
		behavior_stupid_bump_toward(p_game, nearest.location.position, true, true)


## TrRy to revive non-enemy corpses.
## C# BehaviorGoReviveCorpse(game, corpsesPercepts).
func behavior_go_revive_corpse(p_game: RogueGame, corpses_percepts) -> ActorAction:
	# nope if no percepts.
	if corpses_percepts == null:
		return null

	# make sure we have the basics : medic skill & medikit item.
	if controlled_actor.sheet.skill_table.get_skill_level(Skills.IDs.MEDIC) == 0:
		return null
	if not has_item_of_model(p_game.game_items.medikit()):
		return null

	# keep only corpses stacks where we can revive at least one corpse.
	var revivables: Variant = filter(p_game, corpses_percepts, func(p: Percept) -> bool:
		# C# : percepted as List<Corpse>.
		var corpses_there: Array = p.percepted
		for c in corpses_there:
			# dont revive enemies!
			if p_game.rules.can_actor_revive_corpse(controlled_actor, c).ok and not p_game.rules.are_enemies(controlled_actor, c.dead_guy):
				return true
		return false)
	if revivables == null:
		return null

	# either 1) revive corpse or 2) go get them.

	# 1) check corpses here.
	var corpses = controlled_actor.location.map.get_corpses_at(controlled_actor.location.position)
	if corpses != null:
		# get the first corpse we can revive.
		for c in corpses:
			if p_game.rules.can_actor_revive_corpse(controlled_actor, c).ok and not p_game.rules.are_enemies(controlled_actor, c.dead_guy):
				return ActionReviveCorpse.new(controlled_actor, p_game, c)
	# 2) go to nearest revivable.
	var nearest: Percept = filter_nearest(p_game, revivables)
	return behavior_intelligent_bump_toward(p_game, nearest.location.position, false, false) \
		if controlled_actor.model.abilities.is_intelligent else \
		behavior_stupid_bump_toward(p_game, nearest.location.position, false, false)


# Behaviors helpers

# Messages

## C# MakeCentricLocationDirection(game, from, to).
func make_centric_location_direction(p_game: RogueGame, from: Location, to: Location) -> String:
	# if not same location, just says the map.
	if from.map != to.map:
		return "in %s" % to.map.name

	# same location, says direction.
	var from_pos: Vector2i = from.position
	var to_pos: Vector2i = to.position
	var v_dir: Vector2i = Vector2i(to_pos.x - from_pos.x, to_pos.y - from_pos.y)
	return "%d tiles to the %s" % [int(p_game.rules.std_distance_vec(v_dir)), Direction.approximate_from_vector(v_dir)]


# Items

## C# IsItemWorthTellingAbout(it).
func is_item_worth_telling_about(it: Item) -> bool:
	if it == null:
		return false

	# items type to ignore:
	# - barricading material (planks drop a lot).
	if it is ItemBarricadeMaterial:
		return false

	# ignore items we are carrying (we have seen it then taken it)
	if controlled_actor.inventory != null and not controlled_actor.inventory.is_empty and controlled_actor.inventory.contains(it):
		return false

	# ok.
	return true


## C# GetEquippedWeapon().
func get_equipped_weapon() -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it.is_equipped and it is ItemWeapon:
			return it

	return null


## Get best ranged weapon in our inventory that has ammo loaded or we have ammo to reload it.
## C# GetBestRangedWeaponWithAmmo(fn). fn can be null.
func get_best_ranged_weapon_with_ammo(fn: Callable = Callable()) -> ItemRangedWeapon:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	var best: ItemRangedWeapon = null
	var best_sc: int = 0
	for it in controlled_actor.inventory.items:
		var w := it as ItemRangedWeapon
		if w != null and (fn.is_null() or fn.call(it)):
			var check_it: bool = false
			if w.ammo > 0:
				check_it = true
			else:
				# out of ammo, but do we have a matching ammo item in inventory we could reload it with?
				for it_reload in controlled_actor.inventory.items:
					if it_reload is ItemAmmo and (fn.is_null() or fn.call(it_reload)):
						var it_ammo := it_reload as ItemAmmo
						if it_ammo.ammo_type == w.ammo_type:
							check_it = true
							break
			if check_it:
				var sc: int = score_ranged_weapon(w)
				if best == null or sc > best_sc:
					best = w
					best_sc = sc

	return best


## Score this rw over others. Prefer range then attack then ammo loaded.
## C# ScoreRangedWeapon(rWp).
func score_ranged_weapon(r_wp: ItemRangedWeapon) -> int:
	# prefer range then damage
	var a: Attack = (r_wp.model as ItemRangedWeaponModel).attack
	return 10000 * a.range_value + 100 * a.damage_value + r_wp.ammo


## C# GetFirstMeleeWeapon(fn).
func get_first_melee_weapon(fn: Callable) -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null


	for it in controlled_actor.inventory.items:
		if it is ItemMeleeWeapon and (fn.is_null() or fn.call(it)):
			return it

	return null


## C# GetFirstBodyArmor(fn).
func get_first_body_armor(fn: Callable) -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it is ItemBodyArmor and (fn.is_null() or fn.call(it)):
			return it

	return null


## C# GetFirstGrenade(fn).
func get_first_grenade(fn: Callable) -> ItemGrenade:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it is ItemGrenade and (fn.is_null() or fn.call(it)):
			return it as ItemGrenade

	return null


## C# GetEquippedBodyArmor().
func get_equipped_body_armor() -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it.is_equipped and it is ItemBodyArmor:
			return it

	return null


## C# GetEquippedCellPhone().
func get_equipped_cell_phone() -> ItemTracker:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it.is_equipped and it is ItemTracker:
			var t := it as ItemTracker
			if t.can_track_followers_or_leader():
				return t

	return null


## C# GetFirstTracker(fn).
func get_first_tracker(fn: Callable) -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		var t := it as ItemTracker
		if t != null and (fn.is_null() or fn.call(t)):
			return it

	return null


## C# GetEquippedLight().
func get_equipped_light() -> ItemLight:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it.is_equipped and it is ItemLight:
			return it as ItemLight

	return null


## C# GetFirstLight(fn).
func get_first_light(fn: Callable) -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it is ItemLight and (fn.is_null() or fn.call(it)):
			return it

	return null


## C# GetEquippedStenchKiller().
func get_equipped_stench_killer() -> ItemSprayScent:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it.is_equipped and it is ItemSprayScent:
			var m := (it as ItemSprayScent).model as ItemSprayScentModel
			if m.odor == Odor.SUPPRESSOR:  # alpha10
				return it as ItemSprayScent

	return null


## C# GetFirstStenchKiller(fn).
func get_first_stench_killer(fn: Callable) -> ItemSprayScent:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	for it in controlled_actor.inventory.items:
		if it is ItemSprayScent and (fn.is_null() or fn.call(it as ItemSprayScent)):
			return it as ItemSprayScent

	return null


## C# IsRangedWeaponOutOfAmmo(it).
func is_ranged_weapon_out_of_ammo(it: Item) -> bool:
	var w := it as ItemRangedWeapon
	if w == null:
		return false
	return w.ammo <= 0


## C# IsLightOutOfBatteries(it).
func is_light_out_of_batteries(it: Item) -> bool:
	var l := it as ItemLight
	if l == null:
		return false
	return l.batteries <= 0


## C# GetBestEdibleItem(game).
func get_best_edible_item(p_game: RogueGame) -> Item:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return null

	var turn: int = controlled_actor.location.map.local_time.turn_counter
	var need: int = p_game.rules.actor_max_food(controlled_actor) - controlled_actor.food_points
	var best_food: Item = null
	var best_score: int = -2147483648
	for it in controlled_actor.inventory.items:
		var food_it := it as ItemFood
		if food_it == null:
			continue

		# compute heuristic score.
		# - economize food : punish food wasting, the more waste the worse.
		# - keep non-perishable food : punish eating non-perishable food, the more nutrition the worse.
		var score: int = 0

		var nutrition: int = p_game.rules.food_item_nutrition(food_it, turn)
		var waste: int = nutrition - need

		# - punish food wasting, the more waste the worse.
		if waste > 0:
			score -= waste

		# - punish eating non-perishable food, the more nutrition the worse.
		if not food_it.is_perishable:
			score -= nutrition

		# best?
		if best_food == null or score > best_score:
			best_food = food_it
			best_score = score

	# return best.
	return best_food


# alpha10.1 added item/inventory source
## enum ItemSource.
enum ItemSource {
	## Item is in a ground stack (could be a container, which is the same thing)
	GROUND_STACK,
	## Item is in the actor own inventory.
	OWNED,
	## Item is in another actor inventory.
	ANOTHER_ACTOR,
}


## Check if item is ok to have in inventory.
## Uses cases:
## - pickup: checking to pickup an item or not.
## - steal: gangs check to agress an npc to steal his item or not.
## - gift: how cool is it to be gifted this item by another actor.
## - drop: when dropping the item to make room for a food item.
## DO NOT USE FOR TRADING use rate_item() and rate_trade_offer() instead.
## C# IsInterestingItemToOwn(game, it, itemSrc).
func is_interesting_item_to_own(p_game: RogueGame, it: Item, item_src: int) -> bool:
	# alpha10 base idea is any non-junk non-taboo item is interesting.
	# using itemrating is consistent with new trade logic.
	# exception:
	# - reject anything new not food if no food and only one one slot left; needed to be consistent
	# with BehaviorMakeRoomForFood() or the npc will cycle drop-take-drop...

	# taboo
	if is_item_taboo(it):
		return false

	# consistent with BehaviorMakeRoomForFood (was already in alpha9)
	if item_src != ItemSource.OWNED and controlled_actor.inventory.count_items >= controlled_actor.inventory.max_capacity - 1:
		if not (it is ItemFood) and count_item_quantity_of_type(ItemFood) == 0:
			return false

	# alpha10.1 not interested in picking up safe traps from the ground : dont undo your or your friends traps!
	if item_src == ItemSource.GROUND_STACK and it is ItemTrap:
		var it_trap := it as ItemTrap
		if p_game.rules.is_safe_from_trap(it_trap, controlled_actor):
			return false

	# then use normal rating as if was trading and accept anything non-junk.
	var rating: int = rate_item(p_game, it, false)
	return rating != ItemRating.JUNK

	# NOTE: the pre alpha10 logic is inside #if false in the C# and is not ported.


## C# HasAnyInterestingItem(game, inv, inventorySrc).
func has_any_interesting_item(p_game: RogueGame, inv: Inventory, inventory_src: int) -> bool:
	if inv == null:
		return false
	var _owned: bool = (inv == controlled_actor.inventory)
	for it in inv.items:
		if is_interesting_item_to_own(p_game, it, inventory_src):
			return true
	return false


## C# FirstInterestingItem(game, inv, inventorySrc).
func first_interesting_item(p_game: RogueGame, inv: Inventory, inventory_src: int) -> Item:
	if inv == null:
		return null
	var _owned: bool = (inv == controlled_actor.inventory)
	for it in inv.items:
		if is_interesting_item_to_own(p_game, it, inventory_src):
			return it
	return null


# alpha10 new helpers

## C# IsContainerAt(loc).
func is_container_at(loc: Location) -> bool:
	var mobj: MapObject = loc.map.get_map_object_at(loc.position)
	return mobj != null and mobj.is_container


## C# GetBestMeleeWeapon(game, fn). fn can be null.
func get_best_melee_weapon(_p_game: RogueGame, fn: Callable = Callable()) -> ItemMeleeWeapon:
	var best: ItemMeleeWeapon = null
	var best_score: int = -1

	for it in controlled_actor.inventory.items:
		if fn.is_null() or fn.call(it):
			var m_wp := it as ItemMeleeWeapon
			if m_wp != null:
				var score: int = score_melee_weapon(m_wp)
				if best == null or score > best_score:
					best = m_wp
					best_score = score

	return best


## C# ScoreMeleeWeapon(mWp).
func score_melee_weapon(m_wp: ItemMeleeWeapon) -> int:
	# prefer weapon with more dmg, then atk, then disarm, then less sta loss.
	var a: Attack = (m_wp.model as ItemMeleeWeaponModel).attack
	return 100000 * a.damage_value + 1000 * a.hit_value + a.disarm_chance - a.stamina_penalty


## Get best light in inventory with preference for currently equipped light to avoid infinite equip-unequip loops.
## Note that the returned light might have 0 batteries!
## C# GetBestLight(game, fn). fn can be null.
func get_best_light(_p_game: RogueGame, fn: Callable = Callable()) -> ItemLight:
	var equipped_light: ItemLight = null
	var best_scoring_light: ItemLight = null
	var best_score: int = -1
	var best_fov_light: ItemLight = null
	var best_fov: int = -1

	# keep using currently equipped light if it has the best fov and batteries left,
	# otherwise pick best scoring one.
	# we need to check equipped light because equipping a light actually consumes one battery
	# point (see RogueGame OnEquipItem, was added as an anti player fov exploit) and it will
	# make the ai loop forever switching between lights constantly since equip/unequip is a free ap action.

	equipped_light = get_equipped_light()
	if equipped_light != null:
		best_fov_light = equipped_light
		best_fov = (best_fov_light.model as ItemLightModel).fov_bonus
		best_score = score_light(equipped_light)
		best_scoring_light = equipped_light

	for it in controlled_actor.inventory.items:
		if fn.is_null() or fn.call(it):
			var light := it as ItemLight
			if light != null and not light.is_equipped:  # skip equiped because we already scored it
				var fov: int = (light.model as ItemLightModel).fov_bonus
				if fov > best_fov:
					best_fov_light = light
					best_fov = fov

				var score: int = score_light(light)
				if best_scoring_light == null or score > best_score:
					best_scoring_light = light
					best_score = score


	if best_fov_light == equipped_light:
		return equipped_light
	return best_scoring_light


## C# ScoreLight(light).
func score_light(light: ItemLight) -> int:
	# out of batteries sucks
	if light.batteries <= 0:
		return 0

	# prefer range then batteries
	return 10000 * (light.model as ItemLightModel).fov_bonus + light.batteries


## C# GetBestCellPhone(game, fn). fn can be null.
func get_best_cell_phone(_p_game: RogueGame, fn: Callable = Callable()) -> ItemTracker:
	# if one equipped with batteries, that's it.
	var eq_phone: ItemTracker = get_equipped_cell_phone()
	if eq_phone != null and eq_phone.batteries > 0 and (fn.is_null() or fn.call(eq_phone)):
		return eq_phone

	# find first phone with batteries
	return controlled_actor.inventory.get_first_matching(func(it: Item) -> bool:
		if not fn.is_null() and not fn.call(it):
			return false
		var phone := it as ItemTracker
		return phone != null and phone.batteries > 0 and phone.can_track_followers_or_leader()) as ItemTracker


## C# GetBestStenchKiller(game, fn). fn can be null.
func get_best_stench_killer(_p_game: RogueGame, fn: Callable = Callable()) -> ItemSprayScent:
	var best: ItemSprayScent = null
	var best_score: int = -1

	for it in controlled_actor.inventory.items:
		if fn.is_null() or fn.call(it):
			var spray := it as ItemSprayScent
			if spray != null:
				var score: int = score_stench_killer(spray)
				if best == null or score > best_score:
					best = spray
					best_score = score

	return best


## C# ScoreStenchKiller(spray).
func score_stench_killer(spray: ItemSprayScent) -> int:
	# out of spray sucks
	if spray.spray_quantity <= 0:
		return 0

	var m_spray := spray.model as ItemSprayScentModel

	# must be stench killer
	if m_spray.odor != Odor.SUPPRESSOR:  # alpha10
		return -1

	# prefer stronger strength then spray quantity
	return 10000 * m_spray.strength + spray.spray_quantity


## C# GetItemNutritionValue(game, it).
func get_item_nutrition_value(p_game: RogueGame, it: Item) -> int:
	var it_food := it as ItemFood
	if it_food == null:
		return 0
	return p_game.rules.actor_item_nutrition_value(controlled_actor, it_food.nutrition)


## C# GetTotalNutritionInInventory(game).
func get_total_nutrition_in_inventory(p_game: RogueGame) -> int:
	var total: int = 0

	for it in controlled_actor.inventory.items:
		total += get_item_nutrition_value(p_game, it)

	return total


## C# CountFullAmmoStacksInInventoryFor(rWp).
func count_full_ammo_stacks_in_inventory_for(r_wp: ItemRangedWeapon) -> int:
	var count: int = 0

	for it in controlled_actor.inventory.items:
		var it_ammo := it as ItemAmmo
		if it_ammo != null and it_ammo.ammo_type == r_wp.ammo_type:
			if it_ammo.quantity >= it_ammo.model.stacking_limit:
				count += 1

	return count


## Total ammo for this weapon in our inventory, including ammo in the weapon.
## C# CountTotalAmmoInInventoryFor(rWp).
func count_total_ammo_in_inventory_for(r_wp: ItemRangedWeapon) -> int:
	var ammo: int = 0

	# add weapon ammo
	ammo += r_wp.ammo

	# add ammo from inventory
	for it in controlled_actor.inventory.items:
		var it_ammo := it as ItemAmmo
		if it_ammo != null and it_ammo.ammo_type == r_wp.ammo_type:
			ammo += it_ammo.quantity

	return ammo


## C# CountItemsFullStacksOfSameType(tt, excludingThisOne). tt : Item script type.
func count_items_full_stacks_of_same_type(tt: GDScript, excluding_this_one: Item = null) -> int:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return 0

	var count: int = 0
	for other_it in controlled_actor.inventory.items:
		if other_it != excluding_this_one and not other_it.can_stack_more and other_it.get_script() == tt:
			count += 1

	return count


# alpha10 new item rating and trading logic

## enum ItemRating.
enum ItemRating {
	JUNK = 0,   # dont want it at all, the lowest possible rating.
	OKAY = 1,
	NEED = 2,   # wants it to cover a need, the highest possible rating.
}


## Rate item when trading for another item of a different type and in most some cases if checking is interesting to pick up/steal/not drop.
## Items of same type MUST be checked with rate_item_exchange() instead, as a new item might be
## an improvement over an old one, even if individually it would be rated as junk by rate_item().
## C# RateItem(game, it, owned).
func rate_item(p_game: RogueGame, it: Item, owned: bool) -> int:
	# Junk :
	# j1 AI forbidden items.
	# **disabled; handled preventively in IsInterestingItemToOwn* Anything new not food if only one slot left.**
	# j3 Spray paint (ai never use it)
	# j4 Melee weapons if martial arts or enough.
	# j5 Unsafe activated traps and empty cans
	# j6 Primed explosives.
	# j7 Light/Tracker/Spray scent out of batteries/paint or if has already enough
	# j8 Entertainment: boring or already enough
	# j9 Ammo with no compatible ranged weapon.
	# j10 Ranged weapons
	#     - ai not interested in rw
	#     - no ammo for it
	#     - has already same model with more potential ammo
	#     - has already better scoring rw with ammo
	# j11 Barricading material if has already enough.
	# Need :
	# n1 Food if hungry or not enough food in inventory.
	# n2 Ammo for ranged weapon if not enough.
	# n3 Melee weapon if no ranged weapon with ammo.
	# n4 Ranged weapon if none with ammo.
	# n5 Any meds if none. Other meds if need it.
	# n6 Barricade material if none.
	# **disabled** n7 Light if bad fov.
	# n8 (Unprimed) Explosive if none.
	# n9 Armor if none.
	# n10 Entertainment if not sane.
	# Okay:
	# - Anything else.

	# Junk :
	# j1 AI forbidden items.
	if it.is_forbidden_to_ai:
		return ItemRating.JUNK

	# j2 Anything new not food if only one slot left.
	#if (!owned && (m_Actor.Inventory.CountItems >= game.Rules.ActorMaxInv(m_Actor) - 1) && !(it is ItemFood))
	#    return ItemRating.JUNK;

	# j3 Spray paint.
	if it is ItemSprayPaint:
		return ItemRating.JUNK

	# j4 Melee weapons if martial arts or enough.
	if it is ItemMeleeWeapon:
		if controlled_actor.sheet.skill_table.get_skill_level(Skills.IDs.MARTIAL_ARTS) > 0:
			return ItemRating.JUNK

		# one melee weapon is enough
		if count_items_of_same_type(ItemMeleeWeapon, it) >= 1:
			return ItemRating.JUNK

	# j5 Unsafe activated traps and empty cans
	if it is ItemTrap:
		var _tr := it as ItemTrap
		if _tr.model == p_game.game_items.empty_can():
			return ItemRating.JUNK
		if _tr.is_activated() and not p_game.rules.is_safe_from_trap(_tr, controlled_actor):
			return ItemRating.JUNK

	# j6 Primed explosives.
	if it is ItemPrimedExplosive:
		return ItemRating.JUNK

	# j7 Light/Tracker/Spray scent out of batteries/paint or if has already enough


	# j7 Light/Tracker/Spray scent out of batteries/paint or if has already enough
	if it is ItemLight:
		var it_light := it as ItemLight

		if it_light.batteries <= 0:
			return ItemRating.JUNK

		# light is junk if already has 6 hours of batteries worth.
		var total_lights_batteries: int = 0
		for i in controlled_actor.inventory.items:
			if i == it:
				continue
			var l := i as ItemLight
			if l == null:
				continue
			total_lights_batteries += l.batteries

		if total_lights_batteries >= 6 * WorldTime.TURNS_PER_HOUR:
			return ItemRating.JUNK

	if it is ItemTracker:
		if (it as ItemTracker).batteries <= 0:
			return ItemRating.JUNK

		# don't hoard trackers, one with batteries is enough.
		var enough: bool = controlled_actor.inventory.has_item_matching(func(i: Item) -> bool:
			if i == it:
				return false
			var t := i as ItemTracker
			return t != null and t.batteries > 0)
		if enough:
			return ItemRating.JUNK

	if it is ItemSprayScent:
		if (it as ItemSprayScent).spray_quantity <= 0:
			return ItemRating.JUNK

		# don't hoard spray scent, one with spray left is enough.
		var enough: bool = controlled_actor.inventory.has_item_matching(func(i: Item) -> bool:
			if i == it:
				return false
			var t := i as ItemSprayScent
			return t != null and t.spray_quantity > 0)
		if enough:
			return ItemRating.JUNK

	# j8 Entertainment: boring or already enough
	if it is ItemEntertainment:
		if (it as ItemEntertainment).is_boring_for(controlled_actor):
			return ItemRating.JUNK

		# one full stack of entertainment is enough if sane
		if not p_game.rules.is_actor_disturbed(controlled_actor) and count_items_full_stacks_of_same_type(ItemEntertainment, it) >= 1:
			return ItemRating.JUNK

	# j9 Ammo with no compatible ranged weapon.
	if it is ItemAmmo:
		if get_compatible_ranged_weapon(p_game, it as ItemAmmo) == null:
			return ItemRating.JUNK

	# j10 Ranged weapons
	#     - ai not interested in rw
	#     - no ammo for it
	#     - has already same model with at least more potential ammo
	#     - has already better scoring rw with ammo
	if it is ItemRangedWeapon:
		var it_rw := it as ItemRangedWeapon

		# ai not interested in rw
		if controlled_actor.model.abilities.ai_not_interested_in_ranged_weapons:
			return ItemRating.JUNK

		# no ammo for it
		var ammo_in_inv: int = count_total_ammo_in_inventory_for(it_rw)
		if ammo_in_inv == 0:
			return ItemRating.JUNK

		# has already same model with at least more potential ammo
		# has already at least better scoring rw with ammo
		var score_it: int = score_ranged_weapon(it_rw)
		for inv_it in controlled_actor.inventory.items:
			if inv_it != it_rw:
				var inv_rw := inv_it as ItemRangedWeapon
				if inv_rw != null:
					if inv_rw.model == it.model and count_total_ammo_in_inventory_for(inv_rw) >= it_rw.ammo:
						return ItemRating.JUNK
					if inv_rw.ammo > 0 and score_ranged_weapon(inv_rw) >= score_it:
						return ItemRating.JUNK

	# j11 Barricading material if has already enough.
	if it is ItemBarricadeMaterial:
		# one full stack of barricading material is enough
		if count_items_full_stacks_of_same_type(ItemBarricadeMaterial, it) >= 1:
			return ItemRating.JUNK

	# Need :

	# n1 Food if hungry or not enough food in inventory.
	if it is ItemFood:
		if p_game.rules.is_actor_hungry(controlled_actor):
			return ItemRating.NEED
		var nutrition_points: int = get_total_nutrition_in_inventory(p_game)
		if owned:
			nutrition_points -= get_item_nutrition_value(p_game, it as ItemFood)
		# rule of thumb: has to cover 25% more than hungry level
		if nutrition_points <= ((5 * Rules.FOOD_HUNGRY_LEVEL) / 4):
			return ItemRating.NEED

	# n2 Ammo for ranged weapon if not enough.
	if it is ItemAmmo:
		var it_ammo := it as ItemAmmo
		var r_wp: ItemRangedWeapon = get_compatible_ranged_weapon(p_game, it_ammo)
		if r_wp != null:
			# we want 2 full stacks of ammo
			if count_full_ammo_stacks_in_inventory_for(r_wp) < 2:
				return ItemRating.NEED

	# n3 Melee weapon if no ranged weapon with ammo.
	if it is ItemMeleeWeapon:
		if not has_any_ranged_weapon_with_ammo():
			return ItemRating.NEED

	# n4 Ranged weapon if none with ammo.
	if it is ItemRangedWeapon:
		if not has_any_ranged_weapon_with_ammo(it):
			return ItemRating.NEED

	# n5 Any meds if none. Other meds if need (or could) it.
	if it is ItemMedicine:
		var it_med := it as ItemMedicine
		if count_items_of_same_type(ItemMedicine, it) == 0:
			return ItemRating.NEED

		# be lenient and consider we need a med if the corresponding stat is about 75% or less.
		# exception: always want to cure health and infection.
		# this is will allow the player to trade meds for other items, which will increase the
		# value of meds players mostly ignored previously (eg: sta healers).
		if it_med.healing > 0 and controlled_actor.hit_points < p_game.rules.actor_max_hps(controlled_actor):
			return ItemRating.NEED
		if it_med.stamina_boost > 0 and controlled_actor.stamina_points < int(0.75 * p_game.rules.actor_max_sta(controlled_actor)):
			return ItemRating.NEED
		if it_med.sleep_boost > 0 and controlled_actor.sleep_points < int(0.75 * p_game.rules.actor_max_sleep(controlled_actor)):
			return ItemRating.NEED
		if it_med.sanity_cure > 0 and controlled_actor.sanity < int(0.75 * p_game.rules.actor_max_sanity(controlled_actor)):
			return ItemRating.NEED
		if it_med.infection_cure > 0 and controlled_actor.infection > 0:  # always want to cure infection
			return ItemRating.NEED

	# n6 Barricade material if none.
	if it is ItemBarricadeMaterial:
		if count_items_of_same_type(ItemBarricadeMaterial, it) == 0:
			return ItemRating.NEED

	# **disabled; was willing to eg trade away a weapon for a light during the night! **
	# (C# commented-out n7 Light if bad fov block not ported)

	# n8 (Unprimed) Explosive if none.
	if it is ItemExplosive:
		if count_items_of_same_type(ItemExplosive, it) == 0:
			return ItemRating.NEED

	# n9 Armor if none.
	if it is ItemBodyArmor:
		if count_items_of_same_type(ItemBodyArmor, it) == 0:
			return ItemRating.NEED

	# n10 Entertainment if not sane.
	if it is ItemEntertainment:
		if p_game.rules.is_actor_disturbed(controlled_actor):
			return ItemRating.NEED

	# Okay:
	# - Anything else.
	return ItemRating.OKAY


## enum TradeRating.
enum TradeRating {
	REFUSE = 0,
	MAYBE = 1,  # will need a charisma roll, accept if success refuse if failed.
	ACCEPT = 3,
}

# offeredRating X askedRating => tradeRating
## C# TRADE_RATING_MATRIX[offered, asked].
static var TRADE_RATING_MATRIX: Array = [
	# asked JUNK,        asked OKAY,         asked NEED
	[TradeRating.ACCEPT, TradeRating.MAYBE, TradeRating.REFUSE],   # offered JUNK
	[TradeRating.ACCEPT, TradeRating.ACCEPT, TradeRating.REFUSE],  # offered OKAY
	[TradeRating.ACCEPT, TradeRating.ACCEPT, TradeRating.MAYBE],   # offered NEED
]


## Rates a trade offer by another actor.
## Check for trusted leader but do not check for charisma here, handled by the caller on "Maybe" answers.
## Mostly wants to get an item of equal or better value, unless the item asked is needed, see the matrix.
## Some additional rules are used for special tricky cases.
## C# RateTradeOffer(game, tradingWith, offered, asked).
## offered : the item the other actor is offering; asked : the item the other actor wants from us.
func rate_trade_offer(p_game: RogueGame, trading_with: Actor, offered: Item, asked: Item) -> int:
	# always accept deals with trusted leader
	if trading_with == controlled_actor.leader and p_game.rules.is_actor_trusting_leader(controlled_actor):
		return TradeRating.ACCEPT

	# handle special case of trading items of the same type. eg: trading melee weapons.
	if offered.get_script() == asked.get_script():
		return rate_item_exchange(p_game, asked, offered)

	# special case of asking a rw and offering compatible ammo.
	# eg: offering light rifle bullets but asking the rifle.
	# due to items individual ratings this could be accepted
	# (eg: both rated as needed and rolling charisma), which is silly.
	# always refuse such trades!
	if asked is ItemRangedWeapon and offered is ItemAmmo:
		if (asked as ItemRangedWeapon).ammo_type == (offered as ItemAmmo).ammo_type:
			return TradeRating.REFUSE

	# alpha10.1 never trade away a unique item, unless for another unique item
	if asked.is_unique and not offered.is_unique:
		return TradeRating.REFUSE

	# not a special case, compare item ratings.
	var offered_rating: int = rate_item(p_game, offered, false)
	var asked_rating: int = rate_item(p_game, asked, true)
	# compare ratings with matrix (lazy way of doing lots of if/else)
	return TRADE_RATING_MATRIX[offered_rating][asked_rating]


# Rating exhange of items of same type

## Compare items of the same type for trading. Items MUST be of the same type.
## Needs to be handled differently than trading items of different types.
## Wants to exhange items if get an improvement over the old one eg: a ranged weapon with better range.
## C# RateItemExhange(game, oIt, nIt). oIt : item we are losing; nIt : item we are getting.
func rate_item_exchange(p_game: RogueGame, o_it: Item, n_it: Item) -> int:
	# first reject/accept if one is junk and not the other
	var o_rating: int = rate_item(p_game, o_it, true)
	var n_rating: int = rate_item(p_game, n_it, false)
	if n_rating == ItemRating.JUNK and o_rating != ItemRating.JUNK:
		return TradeRating.REFUSE
	if o_rating == ItemRating.JUNK and n_rating != ItemRating.JUNK:
		return TradeRating.ACCEPT

	# then compare items value

	if o_it is ItemAmmo:
		# just compare quantity
		return TradeRating.ACCEPT if (n_it as ItemAmmo).quantity > (o_it as ItemAmmo).quantity \
			else TradeRating.REFUSE if (n_it as ItemAmmo).quantity < (o_it as ItemAmmo).quantity \
			else TradeRating.MAYBE

	if o_it is ItemBarricadeMaterial:
		# just compare quantity
		return TradeRating.ACCEPT if (n_it as ItemBarricadeMaterial).quantity > (o_it as ItemBarricadeMaterial).quantity \
			else TradeRating.REFUSE if (n_it as ItemBarricadeMaterial).quantity < (o_it as ItemBarricadeMaterial).quantity \
			else TradeRating.MAYBE

	if o_it is ItemBodyArmor:
		var o_arm := o_it as ItemBodyArmor
		var n_arm := n_it as ItemBodyArmor

		# prefer better overal protection
		var o_score: int = o_arm.protection_hit + o_arm.protection_shot
		var n_score: int = n_arm.protection_hit + n_arm.protection_shot

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	if o_it is ItemEntertainment:
		var o_ent := o_it as ItemEntertainment
		var n_ent := n_it as ItemEntertainment

		# prefer non-boring ent first. if both are boring then maybe.
		var o_bored: bool = o_ent.is_boring_for(controlled_actor)
		var n_bored: bool = n_ent.is_boring_for(controlled_actor)
		if not n_bored and o_bored:
			return TradeRating.ACCEPT
		if n_bored and not n_bored:  # faithful to the C# original : always false there too
			return TradeRating.REFUSE
		if n_bored and o_bored:
			return TradeRating.MAYBE

		# then prefer ent with more sanity potential
		var o_score: int = (o_ent.quantity * 100 * o_ent.entertainment_model().value) / (1 + o_ent.entertainment_model().bore_chance)
		var n_score: int = (n_ent.quantity * 100 * n_ent.entertainment_model().value) / (1 + n_ent.entertainment_model().bore_chance)

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	if o_it is ItemExplosive:  # also ItemGrenade
		var o_ex := (o_it as ItemExplosive).model as ItemExplosiveModel
		var n_ex := (n_it as ItemExplosive).model as ItemExplosiveModel

		# prefer explosive with more range 0 damage
		return TradeRating.ACCEPT if n_ex.blast_attack.damage[0] > o_ex.blast_attack.damage[0] \
			else TradeRating.REFUSE if n_ex.blast_attack.damage[0] < o_ex.blast_attack.damage[0] \
			else TradeRating.MAYBE

	if o_it is ItemFood:
		var o_food := o_it as ItemFood
		var n_food := n_it as ItemFood

		# prefer food with more nutrition
		var o_nut: int = get_item_nutrition_value(p_game, o_food)
		var n_nut: int = get_item_nutrition_value(p_game, n_food)

		return TradeRating.ACCEPT if n_nut > o_nut \
			else TradeRating.REFUSE if n_nut < o_nut \
			else TradeRating.MAYBE

	if o_it is ItemLight:
		var o_lt := o_it as ItemLight
		var n_lt := n_it as ItemLight

		# score
		var o_score: int = score_light(o_lt)
		var n_score: int = score_light(n_lt)

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	if o_it is ItemMedicine:
		var o_med := o_it as ItemMedicine
		var n_med := n_it as ItemMedicine

		# first prefer med we need the most (basically re-use the med logic from item rating)
		if n_rating > o_rating:
			return TradeRating.ACCEPT
		if o_rating < n_rating:
			return TradeRating.REFUSE

		# for other cases, prefer in order: hp, inf, slp, san, sta
		# use scoring.
		var o_score: int = 10000 * o_med.healing + 1000 * o_med.infection_cure + 100 * o_med.sleep_boost + 10 * o_med.sanity_cure + o_med.stamina_boost
		var n_score: int = 10000 * n_med.healing + 1000 * n_med.infection_cure + 100 * n_med.sleep_boost + 10 * n_med.sanity_cure + n_med.stamina_boost

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	if o_it is ItemMeleeWeapon:
		var o_mw := o_it as ItemMeleeWeapon
		var n_mw := n_it as ItemMeleeWeapon

		# score
		var o_score: int = score_melee_weapon(o_mw)
		var n_score: int = score_melee_weapon(n_mw)

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	if o_it is ItemPrimedExplosive:  # also ItemGrenadePrimed
		# refuse any primed explosive
		return TradeRating.REFUSE

	if o_it is ItemRangedWeapon:
		var o_rw := o_it as ItemRangedWeapon
		var n_rw := n_it as ItemRangedWeapon

		# score
		var o_score: int = score_ranged_weapon(o_rw)
		var n_score: int = score_ranged_weapon(n_rw)

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	if o_it is ItemSprayPaint:
		var o_sp := o_it as ItemSprayPaint
		var n_sp := n_it as ItemSprayPaint

		# useless items for ai, but prefer one with more spray left...
		return TradeRating.ACCEPT if n_sp.paint_quantity > o_sp.paint_quantity \
			else TradeRating.REFUSE if n_sp.paint_quantity < o_sp.paint_quantity \
			else TradeRating.MAYBE

	if o_it is ItemSprayScent:
		var o_sp := o_it as ItemSprayScent
		var n_sp := n_it as ItemSprayScent

		# prefer spray scent with more spray left
		return TradeRating.ACCEPT if n_sp.spray_quantity > o_sp.spray_quantity \
			else TradeRating.REFUSE if n_sp.spray_quantity < o_sp.spray_quantity \
			else TradeRating.MAYBE

	if o_it is ItemTrap:
		var o_tr := o_it as ItemTrap
		var n_tr := n_it as ItemTrap

		# prefer trap with more potential damage then blocking.
		# use scoring
		var o_mtr: ItemTrapModel = o_tr.trap_model()
		var n_mtr: ItemTrapModel = n_tr.trap_model()

		var o_score: int = 100 * o_mtr.damage * o_mtr.trigger_chance + o_mtr.block_chance * o_mtr.trigger_chance
		var n_score: int = 100 * n_mtr.damage * n_mtr.trigger_chance + n_mtr.block_chance * n_mtr.trigger_chance

		return TradeRating.ACCEPT if n_score > o_score \
			else TradeRating.REFUSE if n_score < o_score \
			else TradeRating.MAYBE

	# unhandled items! should not happen!
	assert(false, "RateItemExhange: unhandled item type")
	return TradeRating.REFUSE

	# NOTE: the alpha10 previous-attempt scoring code (IsJunkItem, ScoreItemValue,
	# ...) is inside #if false in the C# and is not ported.


# end alpha10

## C# HasEnoughFoodFor(game, nutritionNeed).
func has_enough_food_for(p_game: RogueGame, nutrition_need: int) -> bool:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return false

	var turn_counter: int = controlled_actor.location.map.local_time.turn_counter
	var nutrition_total: int = 0
	for it in controlled_actor.inventory.items:
		if it is ItemFood:
			nutrition_total += p_game.rules.food_item_nutrition(it as ItemFood, turn_counter)
			if nutrition_total >= nutrition_need:  # exit asap
				return true

	return false


## [Obsolete] C# HasAtLeastFullStackOfItemTypeOrModel(it, n).
func has_at_least_full_stack_of_item_type_or_model(it: Item, n: int) -> bool:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return false

	if it.model.is_stackable:
		# we want N stacks of it.
		return count_items_quantity_of_model(it.model) >= n * it.model.stacking_limit
	else:
		# not stackable, we are happy with N items of its type.
		return count_items_of_same_type(it.get_script()) >= n


## C# HasItemOfModel(model).
func has_item_of_model(model: ItemModel) -> bool:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return false

	for it in controlled_actor.inventory.items:
		if it.model == model:
			return true

	return false


## C# CountItemsQuantityOfModel(model).
func count_items_quantity_of_model(model: ItemModel) -> int:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return 0

	var count: int = 0
	for it in controlled_actor.inventory.items:
		if it.model == model:
			count += it.quantity

	return count


## C# HasItemOfType(tt). tt : Item script type.
func has_item_of_type(tt: GDScript) -> bool:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return false

	return controlled_actor.inventory.has_item_of_type(tt)


## C# CountItemQuantityOfType(tt, excludingThisOne). tt : Item script type.
func count_item_quantity_of_type(tt: GDScript, excluding_this_one: Item = null) -> int:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return 0

	var quantity: int = 0
	for other_it in controlled_actor.inventory.items:
		if other_it != excluding_this_one and other_it.get_script() == tt:
			quantity += other_it.quantity

	return quantity


## C# CountItemsOfSameType(tt, excludingThisOne). tt : Item script type.
func count_items_of_same_type(tt: GDScript, excluding_this_one: Item = null) -> int:
	if controlled_actor.inventory == null or controlled_actor.inventory.is_empty:
		return 0

	var count: int = 0
	for other_it in controlled_actor.inventory.items:
		if other_it != excluding_this_one and other_it.get_script() == tt:
			count += 1

	return count


# alpha10
## C# HasAnyRangedWeaponWithAmmo(excludingThisRangedWeapon).
func has_any_ranged_weapon_with_ammo(excluding_this_ranged_weapon: Item = null) -> bool:
	for it in controlled_actor.inventory.items:
		if it != excluding_this_ranged_weapon and it is ItemRangedWeapon:
			var it_rw := it as ItemRangedWeapon
			if it_rw.ammo > 0:
				return true
			for other_it in controlled_actor.inventory.items:
				if other_it is ItemAmmo:
					if it_rw.ammo_type == (other_it as ItemAmmo).ammo_type:
						return true

	return false


# Running

## C# RunIfPossible(rules).
func run_if_possible(rules: Rules) -> void:
	controlled_actor.is_running = rules.can_actor_run(controlled_actor)["ok"]  # alpha10 fix


# Distances & Safety

## C# GridDistancesSum(rules, from, goals).
func grid_distances_sum(rules: Rules, from: Vector2i, goals) -> int:
	var sum: int = 0
	for to: Percept in goals:
		sum += rules.grid_distance_points(from, to.location.position)
	return sum


# alpha10 new safety scoring
## Compute safety from a list of dangers at a given position.
## C# SafetyFrom(game, from, dangers). Returns a heuristic value, the higher the
## better the safety from the dangers; base 100.
func safety_from(p_game: RogueGame, from: Vector2i, dangers) -> int:
	var rules: Rules = p_game.rules
	var map: Map = controlled_actor.location.map
	var dist_from_dangers: int = grid_distances_sum(rules, from, dangers)
	var current_dist_from_dangers: int = grid_distances_sum(rules, controlled_actor.location.position, dangers)

	var score: int = 0

	# Base score is 100*distance to danger then add minor heuristics.
	if dangers.size() > 0:
		score = (100 * dist_from_dangers) / dangers.size()

	# Heuristics
	# 1. Reward more potential escape tiles.
	# 2. Reward going outside/inside if majority of dangers are inside/outside.
	# 3. Reward ladder/stairs exits.
	# 4. If can tire, prefer not jumping.
	# 5. Punish stepping into traps.
	# 6. Punish moving on or adj to explosives.

	# 1. Reward more potential escape tiles.
	# "Escape tile" = we can walk into it or open a door.
	# Better if it is farther to dangers. Better if ladders/stairs exit.
	for d in Direction.COMPASS:
		var to: Vector2i = from + d.vector
		var is_escape: bool = rules.is_walkable_for(controlled_actor, map, to.x, to.y).ok
		if not is_escape and controlled_actor.model.abilities.can_use_map_objects:
			var door := map.get_map_object_at(to) as DoorWindow
			if door != null and not door.is_barricaded:
				is_escape = true
		if is_escape:
			score += 20
			# NOTE: the C# "else if (==)" branch is dead code (>= covers ==) and is folded here.
			if dist_from_dangers >= current_dist_from_dangers:
				score += 20
			if controlled_actor.model.abilities.ai_can_use_ai_exits:
				var adj_exit: Map.Exit = map.get_exit_at(to)
				if adj_exit != null:
					score += 10

	# 2. Reward going outside/inside if majority of dangers are inside/outside.
	var is_from_inside: bool = map.get_tile_at_p(from).is_inside
	var majority_dangers_inside: int = 0
	for p: Percept in dangers:
		if map.get_tile_at_p(p.location.position).is_inside:
			majority_dangers_inside += 1
		else:
			majority_dangers_inside -= 1
	if is_from_inside:
		# from is inside, want that if majority dangers are outside.
		if majority_dangers_inside < 0:
			score += 100
	else:
		# from is outside, want that if majority dangers are inside.
		if majority_dangers_inside > 0:
			score += 100

	# 3. Reward ladder/stairs exits.
	if controlled_actor.model.abilities.ai_can_use_ai_exits:
		var exit_there: Map.Exit = map.get_exit_at(from)
		if exit_there != null and exit_there.is_an_ai_exit and exit_there.to_map.district == map.district:
			score += 200

	# 4. If can tire, prefer not jumping.
	if controlled_actor.model.abilities.can_tire and controlled_actor.model.abilities.can_jump:
		var obj: MapObject = map.get_map_object_at(from)
		if obj != null and obj.is_jumpable:
			score -= 50


	# done
	return score


# Choice making

## Port of the generic C# Choose<_T_>. listOfChoices : untyped Array; the three
## Callables are isChoiceValidFn(choice), evalChoiceFn(choice) and
## isBetterEvalThanFn(value, bestValue). Returns a ChoiceEval or null.
func choose(p_game: RogueGame, list_of_choices: Array,
		is_choice_valid_fn: Callable, eval_choice_fn: Callable, is_better_eval_than_fn: Callable) -> BaseAI.ChoiceEval:
	# Degenerate cases.
	if list_of_choices.size() == 0:
		return null

	# Find valid choices and best value.
	var has_value: bool = false
	var best_value: float = 0    # irrevelant for 1st value, use flag hasValue instead.
	var valid_choices: Array = []
	for choice in list_of_choices:
		if not is_choice_valid_fn.call(choice):
			continue

		var value_i: float = eval_choice_fn.call(choice)
		if is_nan(value_i):
			continue

		valid_choices.append(ChoiceEval.new(choice, value_i))

		if not has_value or is_better_eval_than_fn.call(value_i, best_value):
			has_value = true
			best_value = value_i

	# Degenerate cases.
	if valid_choices.size() == 0:
		return null
	if valid_choices.size() == 1:
		return valid_choices[0]

	# Keep all the candidates that have the best value.
	var candidates: Array = []
	for vc in valid_choices:
		if vc.value == best_value:
			candidates.append(vc)

	# Of all the candidates randomly choose one.
	var i_choice: int = p_game.rules.roll(0, candidates.size())
	return candidates[i_choice]


# alpha10 evalChoiceFn now also accepts data param from isChoiceValidFn; eg: an action
## Port of the generic C# ChooseExtended<_T_, _DATA_>. isChoiceValidFn(choice)
## returns the data (null to reject) and evalChoiceFn(choice, data) its value.
## Returns a ChoiceEval (choice = data) or null.
func choose_extended(p_game: RogueGame, list_of_choices: Array,
		is_choice_valid_fn: Callable, eval_choice_fn: Callable, is_better_eval_than_fn: Callable) -> BaseAI.ChoiceEval:
	# Degenerate cases.
	if list_of_choices.size() == 0:
		return null

	# Find valid choices and best value.
	var has_value: bool = false
	var best_value: float = 0    # irrevelant for 1st value, use flag hasValue instead.
	var valid_choices: Array = []
	for choice in list_of_choices:
		var choice_data: Variant = is_choice_valid_fn.call(choice)
		if choice_data == null:
			continue

		var value_i: float = eval_choice_fn.call(choice, choice_data)

		if is_nan(value_i):
			continue

		valid_choices.append(ChoiceEval.new(choice_data, value_i))

		if not has_value or is_better_eval_than_fn.call(value_i, best_value):
			has_value = true
			best_value = value_i

	# Degenerate cases.
	if valid_choices.size() == 0:
		return null
	if valid_choices.size() == 1:
		return valid_choices[0]

	# Keep all the candidates that have the best value.
	var candidates: Array = []
	for vc in valid_choices:
		if vc.value == best_value:
			candidates.append(vc)

	# TEST: if no best value, nope.
	if candidates.size() == 0:
		return null

	# Of all the candidates randomly choose one.
	var i_choice: int = p_game.rules.roll(0, candidates.size())
	return candidates[i_choice]


# Action filtering

## Checks if an action can be considered a valid fleeing action : Move, OpenDoor, SwitchPlace.
## C# IsValidFleeingAction(a).
func is_valid_fleeing_action(a: ActorAction) -> bool:
	return a != null and (a is ActionMoveStep or a is ActionOpenDoor or a is ActionSwitchPlace)


## Checks if an action can be considered a valid wandering action : Move, SwitchPlace, Push, OpenDoor, Chat/Trade, Bash, GetFromContainer, Barricade.
## C# IsValidWanderAction(game, a).
func is_valid_wander_action(p_game: RogueGame, a: ActorAction) -> bool:
	if a == null:
		return false
	if a is ActionMoveStep or a is ActionSwitchPlace or a is ActionPush or a is ActionOpenDoor:
		return true
	# (the C# lists ActionBashDoor twice; collapsed here)
	if a is ActionBashDoor or a is ActionBreak:  # alpha10.1 prevent rare cases of getting stuck or going back and forth but we rate it very very low
		return true
	if a is ActionChat and (directives.can_trade or (a as ActionChat).target == controlled_actor.leader):
		return true
	if a is ActionGetFromContainer:
		# C# ActionGetFromContainer.Item : top item from container position.
		var stack: Inventory = controlled_actor.location.map.get_items_at((a as ActionGetFromContainer).position)
		return stack != null and is_interesting_item_to_own(p_game, stack.top_item, ItemSource.GROUND_STACK)
	if a is ActionBarricadeDoor:
		return true
	return false


## Checks if an action can be considered a valid action to move toward a goal.
## Not valid actions : Chat, GetFromContainer, SwitchPowerGenerator, RechargeItemBattery.
## C# IsValidMoveTowardGoalAction(a).
func is_valid_move_toward_goal_action(a: ActorAction) -> bool:
	return a != null \
		and not (a is ActionChat or a is ActionGetFromContainer or a is ActionSwitchPowerGenerator or a is ActionRechargeItemBattery)


# Actors predicates

## C# HasNoFoodItems(actor).
func has_no_food_items(actor: Actor) -> bool:
	var inv: Inventory = actor.inventory
	if inv == null or inv.is_empty:
		return true
	return not inv.has_item_of_type(ItemFood)


## C# IsSoldier(actor).
func is_soldier(actor: Actor) -> bool:
	return actor != null and actor.controller is SoldierAI


## C# WouldLikeToSleep(game, actor).
func would_like_to_sleep(p_game: RogueGame, actor: Actor) -> bool:
	return p_game.rules.is_almost_sleepy(actor) or p_game.rules.is_actor_sleepy(actor)


## C# IsOccupiedByOther(map, position).
func is_occupied_by_other(map: Map, position: Vector2i) -> bool:
	var other: Actor = map.get_actor_at(position)
	return other != null and other != controlled_actor


## C# IsAdjacentToEnemy(game, actor).
func is_adjacent_to_enemy(p_game: RogueGame, actor: Actor) -> bool:
	if actor == null:
		return false

	var map: Map = actor.location.map

	return map.has_any_adjacent_in_map(actor.location.position,
		func(pt: Vector2i) -> bool:
			var other: Actor = map.get_actor_at(pt)
			if other == null:
				return false
			return p_game.rules.are_enemies(actor, other))


## C# IsInside(actor).
func is_inside(actor: Actor) -> bool:
	if actor == null:
		return false

	return actor.location.map.get_tile_at(actor.location.position.x, actor.location.position.y).is_inside


## C# HasEquipedRangedWeapon(actor).
func has_equiped_ranged_weapon(actor: Actor) -> bool:
	return (actor.get_equipped_weapon() as ItemRangedWeapon) != null


## C# GetCompatibleAmmoItem(game, rw, checkForUseNow).
func get_compatible_ammo_item(p_game: RogueGame, rw: ItemRangedWeapon, check_for_use_now: bool) -> ItemAmmo:
	if controlled_actor.inventory == null:
		return null

	# get first compatible ammo item.
	for it in controlled_actor.inventory.items:
		var ammo_it := it as ItemAmmo
		if ammo_it == null:
			continue
		if ammo_it.ammo_type == rw.ammo_type and (not check_for_use_now or p_game.rules.can_actor_use_item(controlled_actor, ammo_it).ok):
			return ammo_it

	# failed.
	return null


## C# GetCompatibleRangedWeapon(game, am).
func get_compatible_ranged_weapon(_p_game: RogueGame, am: ItemAmmo) -> ItemRangedWeapon:
	if controlled_actor.inventory == null:
		return null

	# get first compatible ammo item.
	for it in controlled_actor.inventory.items:
		var ranged_it := it as ItemRangedWeapon
		if ranged_it == null:
			continue
		if ranged_it.ammo_type == am.ammo_type:
			return ranged_it

	# failed.
	return null


## C# GetBestBodyArmor(game, fn).
func get_best_body_armor(_p_game: RogueGame, fn: Callable) -> ItemBodyArmor:
	if controlled_actor.inventory == null:
		return null

	# best = most PRO.
	var best_pro: int = 0
	var best_armor: ItemBodyArmor = null

	for it in controlled_actor.inventory.items:
		if fn != null and not fn.call(it):
			continue

		var armor := it as ItemBodyArmor
		if armor == null:
			continue

		var pro: int = armor.protection_hit + armor.protection_shot
		if pro > best_pro:
			best_pro = pro
			best_armor = armor

	# done.
	return best_armor


## C# WantToEvadeMelee(game, actor, courage, target).
## Targets to evade or not:
## 1. Yes : if fighting makes me tired vs a slower target (so i will lose my speed advantage by tiring) // alpha10 added slower target condition
## 2. Yes : slower targets that will act next turn (kiting) and are targetting us.
## 3. No  : target is weaker.
## 4. Yes : actor is weaker.
## 5. Unclear cases, utimately decide on courage.
func want_to_evade_melee(p_game: RogueGame, actor: Actor, courage: int, target: Actor) -> bool:
	var has_speed_advantage_: bool = p_game.rules.actor_speed(actor) > p_game.rules.actor_speed(target)

	# 1. Yes : if fighting makes me tired vs a slower target (so i will lose my speed advantage by tiring) // alpha10 added slower target condition
	if has_speed_advantage_ and will_tire_after_attack(p_game, actor):
		return true

	# 2. Yes : slower targets that will act next turn (kiting) and are targetting us.
	if has_speed_advantage_:
		# don't evade if we're gonna act again.
		if p_game.rules.will_actor_act_again_before(actor, target):
			return false
		else:
			# evade if he is targetting us.
			if target.target_actor == actor:
				return true

	# get weaker actor in melee.
	var weaker_one: Actor = find_weaker_in_melee(p_game, controlled_actor, target)

	# 3. No : target is weaker.
	if weaker_one == target:
		return false

	# 4. Yes : actor is weaker.
	if weaker_one == controlled_actor:
		return true

	# 5. Unclear cases, utimately decide on courage.
	return courage != ActorDirective.ActorCourage.COURAGEOUS


## Get which of the two actor can be considered as a weaker one in a melee fight.
## Returns weaker actor, null if they are equal.
## C# FindWeakerInMelee(game, a, b).
func find_weaker_in_melee(_p_game: RogueGame, a: Actor, b: Actor) -> Actor:
	# alpha10 count how many hits it would take to kill each other
	# the actor that dies faster is the weaker one

	# silly cases of peope already dead, you never know -_-
	if a.is_dead:
		return a
	if b.is_dead:
		return b

	# count hits, lowest hit dies first
	var hits_to_kill_a: int = int(ceil(float(a.hit_points) / float(b.current_melee_attack.damage_value)))
	var hits_to_kill_b: int = int(ceil(float(b.hit_points) / float(a.current_melee_attack.damage_value)))

	if hits_to_kill_a < hits_to_kill_b:
		return a
	elif hits_to_kill_a > hits_to_kill_b:
		return b
	return null


## C# WillTireAfterAttack(game, actor).
func will_tire_after_attack(_p_game: RogueGame, actor: Actor) -> bool:
	if not actor.model.abilities.can_tire:
		return false
	var sta_after: int = actor.stamina_points - Rules.STAMINA_COST_MELEE_ATTACK
	return sta_after < Rules.STAMINA_MIN_FOR_ACTIVITY


## C# WillTireAfterRunning(game, actor).
func will_tire_after_running(_p_game: RogueGame, actor: Actor) -> bool:
	if not actor.model.abilities.can_tire:
		return false
	var sta_after: int = actor.stamina_points - Rules.STAMINA_COST_RUNNING
	return sta_after < Rules.STAMINA_MIN_FOR_ACTIVITY


## C# HasSpeedAdvantage(game, actor, target).
func has_speed_advantage(p_game: RogueGame, actor: Actor, target: Actor) -> bool:
	var actor_speed: int = p_game.rules.actor_speed(actor)
	var target_speed: int = p_game.rules.actor_speed(target)

	# if better speed, yes.
	if actor_speed > target_speed:
		return true

	# if we can run and the target can't and that would make us faster without tiring us, then yes!
	if p_game.rules.can_actor_run(actor)["ok"] and not p_game.rules.can_actor_run(target)["ok"] \
			and not will_tire_after_running(p_game, actor) and actor_speed * 2 > target_speed:
		return true

	# TODO: other tricky cases?

	return false


## C# NeedsLight(game).
func needs_light(_p_game: RogueGame) -> bool:
	match controlled_actor.location.map.lighting:
		Map.Lighting.DARKNESS:
			return true
		Map.Lighting.LIT:
			return false
		Map.Lighting.OUTSIDE:
			# alpha10 outside, lights have an effect only during the night.
			return controlled_actor.location.map.local_time.is_night
		_:
			assert(false, "unhandled lighting")
			return false


## Check if a point can be considered between two others.
## C# IsBetween(game, A, between, B).
func is_between(p_game: RogueGame, a: Vector2i, between: Vector2i, b: Vector2i) -> bool:
	var a_between: float = p_game.rules.std_distance(a, between)
	var b_between: float = p_game.rules.std_distance(b, between)
	var a_b: float = p_game.rules.std_distance(a, b)

	return a_between + b_between <= a_b + 0.25


## C# IsDoorwayOrCorridor(game, map, pos).
func is_doorway_or_corridor(_p_game: RogueGame, map: Map, pos: Vector2i) -> bool:


	var wall: bool = not map.get_tile_at_p(pos).model.is_walkable
	if wall:
		return false

	var n: Vector2i = pos + Direction.N.vector
	var n_wall: bool = map.is_in_bounds_p(n) and not map.get_tile_at_p(n).model.is_walkable
	var s: Vector2i = pos + Direction.S.vector
	var s_wall: bool = map.is_in_bounds_p(s) and not map.get_tile_at_p(s).model.is_walkable
	var e: Vector2i = pos + Direction.E.vector
	var e_wall: bool = map.is_in_bounds_p(e) and not map.get_tile_at_p(e).model.is_walkable
	var w: Vector2i = pos + Direction.W.vector
	var w_wall: bool = map.is_in_bounds_p(w) and not map.get_tile_at_p(w).model.is_walkable

	var ne: Vector2i = pos + Direction.NE.vector
	var ne_wall: bool = map.is_in_bounds_p(ne) and not map.get_tile_at_p(ne).model.is_walkable
	var nw: Vector2i = pos + Direction.NW.vector
	var nw_wall: bool = map.is_in_bounds_p(nw) and not map.get_tile_at_p(nw).model.is_walkable
	var se: Vector2i = pos + Direction.SE.vector
	var se_wall: bool = map.is_in_bounds_p(se) and not map.get_tile_at_p(se).model.is_walkable
	var sw: Vector2i = pos + Direction.SW.vector
	var sw_wall: bool = map.is_in_bounds_p(sw) and not map.get_tile_at_p(sw).model.is_walkable

	var free_corners: bool = not ne_wall and not se_wall and not nw_wall and not sw_wall

	if free_corners and n_wall and s_wall and not e_wall and not w_wall:
		return true
	if free_corners and e_wall and w_wall and not n_wall and not s_wall:
		return true

	return false


## Not an enemy AND same faction.
## C# IsFriendOf(game, other).
func is_friend_of(p_game: RogueGame, other: Actor) -> bool:
	return not p_game.rules.are_enemies(controlled_actor, other) and controlled_actor.faction == other.faction


## C# GetNearestTargetFor(game, actor).
func get_nearest_target_for(p_game: RogueGame, actor: Actor) -> Actor:
	var map: Map = actor.location.map
	var nearest: Actor = null
	var best: int = 2147483647

	# quite uggly but better than computing the whole FoV...
	for a in map.actors_list:
		if a.is_dead:
			continue
		if a == actor:
			continue
		if not p_game.rules.are_enemies(actor, a):
			continue

		var d: int = p_game.rules.grid_distance_points(a.location.position, actor.location.position)
		if d < best:
			if d == 1 or LOS.can_trace_view_line(actor.location, a.location.position):
				best = d
				nearest = a

	return nearest


# alpha10
## C# GetActorAttack(game, actor).
func get_actor_attack(_p_game: RogueGame, actor: Actor) -> Attack:
	return actor.current_ranged_attack if actor.get_equipped_ranged_weapon() != null else actor.current_melee_attack


# Exits

## C# ListAdjacentExits(game, fromLocation).
func list_adjacent_exits(_p_game: RogueGame, from_location: Location) -> Variant:
	var list = null
	for d in Direction.COMPASS:
		var next_pos: Vector2i = from_location.position + d.vector
		var exit: Map.Exit = from_location.map.get_exit_at(next_pos)
		if exit == null:
			continue
		if list == null:
			list = []
		list.append(exit)

	return list


## C# PickAnyAdjacentExit(game, fromLocation).
func pick_any_adjacent_exit(p_game: RogueGame, from_location: Location) -> Map.Exit:
	# get all adjacent exits.
	var list: Variant = list_adjacent_exits(p_game, from_location)

	# if none, failed.
	if list == null:
		return null

	# pick one at random.
	return list[p_game.rules.roll(0, list.size())]


# Map

# alpha10
## C# IsAnyUnsafeDamagingTrapThere(game, map, pos).
func is_any_unsafe_damaging_trap_there(p_game: RogueGame, map: Map, pos: Vector2i) -> bool:
	var inv: Inventory = map.get_items_at(pos)
	if inv == null or inv.is_empty:
		return false
	return inv.get_first_matching(func(it: Item) -> bool:
		var trap := it as ItemTrap
		return trap != null and trap.is_activated() and trap.trap_model().damage > 0 and not p_game.rules.is_safe_from_trap(trap, controlled_actor)) != null


# alpha10
## C# static IsAnyPrimedExplosiveThere(map, pos).
static func is_any_primed_explosive_there(map: Map, pos: Vector2i) -> bool:
	var inv: Inventory = map.get_items_at(pos)
	if inv == null or inv.is_empty:
		return false
	return inv.get_first_matching(func(it: Item) -> bool:
		var ex := it as ItemPrimedExplosive
		return ex != null) != null


## C# static IsZoneChange(map, pos).
static func is_zone_change(map: Map, pos: Vector2i) -> bool:
	var zones_here: Array = map.get_zones_at(pos.x, pos.y)
	if zones_here == null:
		return false

	# adjacent to another zone.
	return map.has_any_adjacent_in_map(pos, func(adj: Vector2i) -> bool:
		var zones_adj: Array = map.get_zones_at(adj.x, adj.y)
		if zones_adj == null:
			return false
		for z in zones_adj:
			if not zones_here.has(z):
				return true
		return false)


## C# RandomPositionNear(rules, map, goal, range).
func random_position_near(rules: Rules, map: Map, goal: Vector2i, range_: int) -> Vector2i:
	var x: int = goal.x + rules.roll(-range_, range_)
	var y: int = goal.y + rules.roll(-range_, range_)

	var trimmed: Vector2i = map.trim_to_bounds(x, y)

	return trimmed


# alpha10.1
## C# GetObjectHitPoints(mobj). mobj can be null (will return 0).
## Returns 0 for null objs, total hitpoints for breakable objects, a silly large amount for unbreakable objs.
func get_object_hit_points(mobj: MapObject) -> int:
	if mobj == null:
		return 0

	if not mobj.is_breakable:
		return 100000

	var hp: int = mobj.hit_points

	# add barricade hps
	var dw := mobj as DoorWindow
	if dw != null:
		if dw.is_barricaded:
			hp += dw.barricade_points

	return hp


# alpha10
# Route checking

## C# CanReachSimple(game, dest, allowedActions).
func can_reach_simple(p_game: RogueGame, dest: Vector2i, allowed_actions: int) -> bool:
	if _route_finder == null:
		_route_finder = RouteFinder.new(self)
	_route_finder.allowed_actions = allowed_actions
	var max_dist: int = p_game.rules.grid_distance_points(controlled_actor.location.position, dest)
	return _route_finder.can_reach_simple(p_game, dest, max_dist, p_game.rules.grid_distance_points)


## C# FilterOutUnreachablePercepts(game, ref percepts, allowedActions).
## Ported as mutate-in-place + return the filtered list.
func filter_out_unreachable_percepts(p_game: RogueGame, percepts, allowed_actions: int):
	var i: int = 0
	while i < percepts.size():
		if can_reach_simple(p_game, percepts[i].location.position, allowed_actions):
			i += 1
		else:
			percepts.remove_at(i)
	return percepts


# Taboo items

## C# MarkItemAsTaboo(it).
func mark_item_as_taboo(it: Item) -> void:
	if _taboo_items == null:
		_taboo_items = []
	elif _taboo_items.has(it):
		return
	_taboo_items.append(it)


## C# UnmarkItemAsTaboo(it).
func unmark_item_as_taboo(it: Item) -> void:
	if _taboo_items == null:
		return
	_taboo_items.erase(it)
	if _taboo_items.size() == 0:
		_taboo_items = null


## C# IsItemTaboo(it).
func is_item_taboo(it: Item) -> bool:
	if _taboo_items == null:
		return false
	return _taboo_items.has(it)


## C# MarkTileAsTaboo(p).
func mark_tile_as_taboo(p: Vector2i) -> void:
	if _taboo_tiles == null:
		_taboo_tiles = []
	elif _taboo_tiles.has(p):
		return
	_taboo_tiles.append(p)


## C# IsTileTaboo(p).
func is_tile_taboo(p: Vector2i) -> bool:
	if _taboo_tiles == null:
		return false
	return _taboo_tiles.has(p)


## C# ClearTabooTiles().
func clear_taboo_tiles() -> void:
	_taboo_tiles = null


# Taboo trades

## C# MarkActorAsRecentTrade(other).
func mark_actor_as_recent_trade(other: Actor) -> void:
	if _taboo_trades == null:
		_taboo_trades = []
	elif _taboo_trades.has(other):
		return
	_taboo_trades.append(other)


## C# IsActorTabooTrade(other).
func is_actor_taboo_trade(other: Actor) -> bool:
	if _taboo_trades == null:
		return false
	return _taboo_trades.has(other)


## C# ClearTabooTrades().
func clear_taboo_trades() -> void:
	_taboo_trades = null


# alpha10 Taboo Equipment slots
# Simple solution to cases of ai getting stuck in an infinite unequip-equip loop.
# Typically caused by conflicting behaviors that will "compete" for an equipment slot and will keep doing
# infinite cycle of equip-unequip, each behavior trying to get "his" item equiped on the same doll part.
# Current solution is to temporaly reserve a doll part by using taboo doll parts until the behavior is done with it.
#
# It relies on each competing behavior checking and setting taboo slots correctly.

## A Behavior wants to reserve en equipment slot for use in the next ai ticks.
## The same Behavior can keep reserving the same slot over many ticks until it is done.
## It must then release the slot by unmarking it.
## Must reserve slots ONLY FOR AP FREE actions like Equip and Unequip.
## C# MarkEquipmentSlotAsTaboo(part).
func mark_equipment_slot_as_taboo(part: int) -> void:
	_reserved_equipment_slots |= (1 << part)


## A Behavior release an equipment slot for use by other behaviors.
## MUST RELEASE an equipment slot before returning an NON-AP FREE action or the lock will persist
## for next turn.
## C# UnmarkEquipmentSlotAsTaboo(part).
func unmark_equipment_slot_as_taboo(part: int) -> void:
	_reserved_equipment_slots &= ~(1 << part)


## A Behavior checks if an equipment slot is reserved and it should not do anything with it.
## C# IsEquipmentSlotTaboo(part).
func is_equipment_slot_taboo(part: int) -> bool:
	return (_reserved_equipment_slots & (1 << part)) != 0
