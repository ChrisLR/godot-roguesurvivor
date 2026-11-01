class_name OrderableAI
extends BaseAI
## Port of Gameplay/AI/OrderableAI.cs
## Base class for AIs that can follow orders and is notified of raid events.

# Fields

var _last_enemy_saw: Percept = null
var _last_soldier_saw: Percept = null
var _last_raid_heard: Percept = null

var _reached_patrol_point: bool = false
var _report_stage: int = 0

var dont_follow_leader: bool = false


# Orders

func set_order(new_order) -> void:
	super(new_order)

	# reset order states.
	_reached_patrol_point = false
	_report_stage = 0


func execute_order(game: RogueGame, order: ActorOrder, percepts, exploration: ExplorationData) -> ActorAction:
	# cancel if leader is dead!
	if _actor.leader == null || _actor.leader.is_dead:
		return null

	# execute task.
	match order.task:
		ActorOrder.ActorTasks.BARRICADE_ONE:
			return execute_barricading(game, order.location, false)
		ActorOrder.ActorTasks.BARRICADE_MAX:
			return execute_barricading(game, order.location, true)
		ActorOrder.ActorTasks.BUILD_SMALL_FORTIFICATION:
			return execute_build_fortification(game, order.location, false)
		ActorOrder.ActorTasks.BUILD_LARGE_FORTIFICATION:
			return execute_build_fortification(game, order.location, true)
		ActorOrder.ActorTasks.DROP_ALL_ITEMS:
			return execute_drop_all_items(game)
		ActorOrder.ActorTasks.GUARD:
			return execute_guard(game, order.location, percepts)
		ActorOrder.ActorTasks.PATROL:
			return execute_patrol(game, order.location, percepts, exploration)
		ActorOrder.ActorTasks.REPORT_EVENTS:
			return execute_report(game, percepts)
		ActorOrder.ActorTasks.SLEEP_NOW:
			return execute_sleep_now(game, percepts)
		ActorOrder.ActorTasks.FOLLOW_TOGGLE:
			return execute_toggle_follow(game)
		ActorOrder.ActorTasks.WHERE_ARE_YOU:
			return execute_report_position(game)
		_:
			assert(false, "order task not handled")
			return null


# Barricading

func execute_barricading(game: RogueGame, location: Location, to_the_max: bool) -> ActorAction:
	###################
	# 1. Check validity.
	# 2. Perform.
	###################

	# 1. Check validity.
	if _actor.location.map != location.map:
		return null
	var door := location.map.get_map_object_at(location.position) as DoorWindow
	if door == null:
		return null
	if not game.rules.can_actor_barricade_door(_actor, door)["ok"]:
		return null

	# 2. Perform.
	# 2.1 If adjacent, barricade.
	# 2.2 Move closer.

	# 2.1 If adjacent, barricade.
	if game.rules.is_adjacent(_actor.location.position, location.position):
		var barricade_action: ActorAction = ActionBarricadeDoor.new(_actor, game, door)
		if barricade_action.is_legal():
			if not to_the_max:
				set_order(null)
			return barricade_action
		else:
			return null

	# 2.2 Move closer.
	var move_action: ActorAction = behavior_intelligent_bump_toward(game, location.position, false, false)
	if move_action != null:
		run_if_possible(game.rules)
		return move_action
	else:
		return null


# Building fortification

func execute_build_fortification(game: RogueGame, location: Location, is_large: bool) -> ActorAction:
	###################
	# 1. Check validity.
	# 2. Perform.
	###################

	# 1. Check validity.
	if _actor.location.map != location.map:
		return null
	if not game.rules.can_actor_build_fortification(_actor, location.position, is_large)["ok"]:
		return null

	# 2. Perform.
	# 2.1 If adjacent, build.
	# 2.2 Move closer.

	# 2.1 If adjacent, build.
	if game.rules.is_adjacent(_actor.location.position, location.position):
		var build_action: ActorAction = ActionBuildFortification.new(_actor, game, location.position, is_large)
		if build_action.is_legal():
			set_order(null)
			return build_action
		else:
			return null

	# 2.2 Move closer.
	var move_action: ActorAction = behavior_intelligent_bump_toward(game, location.position, false, false)
	if move_action != null:
		run_if_possible(game.rules)
		return move_action
	else:
		return null


# Guarding

func execute_guard(game: RogueGame, location: Location, percepts) -> ActorAction:
	##############################
	# Interrupt guard:
	# 1. See enemy => raise alarm.
	##############################

	# 1. See enemy => raise alarm.
	var enemies = filter_enemies(game, percepts)
	if enemies != null:
		# ALAAAARRMM!!
		set_order(null)
		var nearest_enemy := filter_nearest(game, enemies).percepted as Actor
		assert(nearest_enemy != null, "null nearest enemy")
		return ActionShout.new(_actor, game, "%s sighted!!" % nearest_enemy.name)

	#############################
	# Guard duty actions:
	# 1. Mimick leader cell phone usage.
	# 2. Move to guard position.
	# 3. Eat if hungry.
	# 4. Heal if need to.
	# 5. Wait.
	#############################

	# 1. Mimick leader cell phone usage.
	var phone_action: ActorAction = behavior_equip_cell_phone(game)
	if phone_action != null:
		_actor.activity = Activity.IDLE
		return phone_action
	phone_action = behavior_unequip_cell_phone_if_leader_has_not(game)
	if phone_action != null:
		_actor.activity = Activity.IDLE
		return phone_action

	# 2. Move to guard position.
	if _actor.location.position != location.position:
		var bump_action: ActorAction = behavior_intelligent_bump_toward(game, location.position, false, false)
		if bump_action != null:
			_actor.activity = Activity.IDLE
			return bump_action

	# 3. Eat if hungry.
	if game.rules.is_actor_hungry(_actor):
		var eat_action: ActorAction = behavior_eat(game)
		if eat_action != null:
			_actor.activity = Activity.IDLE
			return eat_action

	# 4. Heal if need to.
	var use_med_action: ActorAction = behavior_use_medecine(game, 2, 1, 2, 4, 2)
	if use_med_action != null:
		_actor.activity = Activity.IDLE
		return use_med_action

	# 5. Wait.
	_actor.activity = Activity.IDLE
	return ActionWait.new(_actor, game)


# Patrolling

func execute_patrol(game: RogueGame, location: Location, percepts, exploration: ExplorationData) -> ActorAction:
	##############################
	# Interrupt patrol
	# 1. See enemy => raise alarm.
	##############################

	# 1. See enemy => raise alarm.
	var enemies = filter_enemies(game, percepts)
	if enemies != null:
		# ALAAAARRMM!!
		set_order(null)
		var nearest_enemy := filter_nearest(game, enemies).percepted as Actor
		assert(nearest_enemy != null, "null nearest enemy")
		return ActionShout.new(_actor, game, "%s sighted!!" % nearest_enemy.name)

	#############################
	# Patrol duty actions:
	# Check if patrol position reached.
	# 1. Mimick leader cell phone usage.
	# 2. Move to patrol position.
	# 3. Eat if hungry.
	# 4. Heal if need to.
	# 5. Wander in patrol zone.
	#############################

	# Check patrol position reached.
	if not _reached_patrol_point:
		_reached_patrol_point = _actor.location.position == location.position

	# 1. Mimick leader cell phone usage.
	var phone_action: ActorAction = behavior_equip_cell_phone(game)
	if phone_action != null:
		_actor.activity = Activity.IDLE
		return phone_action
	phone_action = behavior_unequip_cell_phone_if_leader_has_not(game)
	if phone_action != null:
		_actor.activity = Activity.IDLE
		return phone_action

	# 2. Move to patrol position.
	if not _reached_patrol_point:
		var bump_action: ActorAction = behavior_intelligent_bump_toward(game, location.position, false, false)
		if bump_action != null:
			_actor.activity = Activity.IDLE
			return bump_action

	# 3. Eat if hungry.
	if game.rules.is_actor_hungry(_actor):
		var eat_action: ActorAction = behavior_eat(game)
		if eat_action != null:
			_actor.activity = Activity.IDLE
			return eat_action

	# 4. Heal if need to.
	var use_med_action: ActorAction = behavior_use_medecine(game, 2, 1, 2, 4, 2)
	if use_med_action != null:
		_actor.activity = Activity.IDLE
		return use_med_action

	# 5. Wander in patrol zones.
	var patrol_zones = location.map.get_zones_at(order.location.position.x, order.location.position.y)
	var patrol_loc_fn: Callable = func(loc: Location) -> bool:
		var zones_here = loc.map.get_zones_at(loc.position.x, loc.position.y)
		if zones_here == null || zones_here.is_empty():
			return false
		for z_here in zones_here:
			for z_patrol in patrol_zones:
				if z_here == z_patrol:
					return true
		return false
	return behavior_wander(game, patrol_loc_fn, exploration)


# Dropping all items

func execute_drop_all_items(game: RogueGame) -> ActorAction:
	# if no more items, done.
	if _actor.inventory.is_empty:
		return null

	# alpha10.1 bugfix followers drop all was looping
	# use drop item behaviour on the first item it can.
	for i: int in _actor.inventory.items.size():
		var drop_action: ActorAction = behavior_drop_item(game, _actor.inventory.get_item_at(i))
		if drop_action != null:
			return drop_action

	# we still have at least one item but cannot drop it for some reason,
	# consider the order done.
	return null


# Reporting

func execute_report(game: RogueGame, percepts) -> ActorAction:
	##############################
	# Interrupt report
	# 1. See enemy => raise alarm.
	##############################

	# 1. See enemy => raise alarm.
	var enemies = filter_enemies(game, percepts)
	if enemies != null:
		# ALAAAARRMM!!
		set_order(null)
		var nearest_enemy := filter_nearest(game, enemies).percepted as Actor
		assert(nearest_enemy != null, "null nearest enemy")
		return ActionShout.new(_actor, game, "%s sighted!!" % nearest_enemy.name)

	####################
	# Continue reporting.
	####################
	var report_action: ActorAction = null
	var is_report_done: bool = false

	match _report_stage:
		0: # events.
			if _last_raid_heard != null:
				report_action = behavior_tell_friend_about_percept(game, _last_raid_heard)
			else:
				report_action = ActionSay.new(_actor, game, _actor.leader, "No raids heard.", RogueGame.Sayflags.NONE)
			_report_stage += 1

		1: # enemies.
			if _last_enemy_saw != null:
				report_action = behavior_tell_friend_about_percept(game, _last_enemy_saw)
			else:
				report_action = ActionSay.new(_actor, game, _actor.leader, "No enemies sighted.", RogueGame.Sayflags.NONE)
			_report_stage += 1

		2: # items.
			if _last_items_saw != null:
				report_action = behavior_tell_friend_about_percept(game, _last_items_saw)
			else:
				report_action = ActionSay.new(_actor, game, _actor.leader, "No items sighted.", RogueGame.Sayflags.NONE)
			_report_stage += 1

		3: # soldiers.
			if _last_soldier_saw != null:
				report_action = behavior_tell_friend_about_percept(game, _last_soldier_saw)
			else:
				report_action = ActionSay.new(_actor, game, _actor.leader, "No soldiers sighted.", RogueGame.Sayflags.NONE)
			_report_stage += 1

		4: # end of report.
			is_report_done = true
			report_action = ActionSay.new(_actor, game, _actor.leader, "That's it.", RogueGame.Sayflags.NONE)

	if is_report_done:
		set_order(null)
	if report_action != null:
		return report_action
	else:
		return ActionSay.new(_actor, game, _actor.leader, "Let me think...", RogueGame.Sayflags.NONE)


# Sleeping now

func execute_sleep_now(game: RogueGame, percepts) -> ActorAction:
	# interrupt if seeing an enemy.
	var enemies = filter_enemies(game, percepts)
	if enemies != null:
		# ALAAAARRMM!!
		set_order(null)
		var nearest_enemy := filter_nearest(game, enemies).percepted as Actor
		assert(nearest_enemy != null, "null nearest enemy")
		return ActionShout.new(_actor, game, "%s sighted!!" % nearest_enemy.name)

	# try to sleep.
	var sleep_r: Dictionary = game.rules.can_actor_sleep(_actor)
	if sleep_r.ok:
		# start sleeping only one even turns so the player has at least one turn to cancel the order...
		if _actor.location.map.local_time.turn_counter % 2 == 0:
			return ActionSleep.new(_actor, game)
		else:
			return ActionWait.new(_actor, game)
	else:
		set_order(null)
		game.do_emote(_actor, "I can't sleep now : %s." % sleep_r.fail_reason)
		return ActionWait.new(_actor, game)


# Toggle following

func execute_toggle_follow(game: RogueGame) -> ActorAction:
	# consider it done.
	set_order(null)

	# toggle.
	dont_follow_leader = not dont_follow_leader

	# emote.
	game.do_emote(_actor, "OK I'll do my stuff, see you soon!" if dont_follow_leader else "I'm ready!")
	return ActionWait.new(_actor, game)


# Where are you?

func execute_report_position(game: RogueGame) -> ActorAction:
	# consider it done.
	set_order(null)

	# do it.
	var report_txt: String = "I'm in %s at %d,%d." % [_actor.location.map.name, _actor.location.position.x, _actor.location.position.y]
	return ActionSay.new(_actor, game, _actor.leader, report_txt, RogueGame.Sayflags.NONE)


# Raid notification.

func on_raid(raid: int, location: Location, turn: int) -> void:
	if _actor.is_sleeping:
		return

	var raid_desc: String
	match raid:
		Session.RaidType.ARMY_SUPLLIES:
			raid_desc = "a chopper hovering"
		Session.RaidType.BIKERS:
			raid_desc = "motorcycles coming"
		Session.RaidType.BLACKOPS:
			raid_desc = "a chopper hovering"
		Session.RaidType.GANGSTA:
			raid_desc = "cars coming"
		Session.RaidType.NATGUARD:
			raid_desc = "the army coming"
		Session.RaidType.SURVIVORS:
			raid_desc = "honking coming"
		_:
			push_error("unhandled raidtype %s" % raid)
			return

	_last_raid_heard = Percept.new(raid_desc, turn, location)
