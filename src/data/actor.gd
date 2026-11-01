class_name Actor
extends RefCounted
## Port of Data/Actor.cs
## An actor in play : model instance + live state.

## Port of the TrustRecord class declared in Actor.cs.
class TrustRecord:
	var actor: Actor
	var trust: int


# [Flags] enum Flags
const FLAG_NONE = 0
const FLAG_IS_UNIQUE = (1 << 0)
const FLAG_IS_PROPER_NAME = (1 << 1)
const FLAG_IS_PLURAL_NAME = (1 << 2)
const FLAG_IS_DEAD = (1 << 3)
const FLAG_IS_RUNNING = (1 << 4)
const FLAG_IS_SLEEPING = (1 << 5)

var _flags: int = FLAG_NONE

# Definition
var model_id: int = 0
var faction_id: int = 0
var gang_id: int = 0
var _name: String
var sheet: ActorSheet = null
var spawn_time: int = 0

# State
var inventory: Inventory = null
var doll: Doll = null
var _hit_points: int = 0
var _previous_hit_points: int = 0
var _stamina_points: int = 0
var _previous_stamina: int = 0
var _food_points: int = 0
var _previous_food_points: int = 0
var _sleep_points: int = 0
var _previous_sleep_points: int = 0
var _sanity: int = 0
var _previous_sanity: int = 0
var location: Location
var action_points: int = 0
var last_action_turn: int = 0
var activity: int = Activity.IDLE
var target_actor: Actor = null
var _audio_range_mod: int = 0
var current_melee_attack: Attack = null
var current_ranged_attack: Attack = null
var current_defence: Defence = null
var leader: Actor = null
var followers = null
var trust_in_leader: int = 0
var _trust_list = null
var kills_count: int = 0
var aggressor_of = null
var self_defence_from = null
var murders_counter: int = 0
var _infection: int = 0
var dragged_corpse: Corpse = null
# alpha10
var is_invincible: bool = false
var odor_suppressor_counter: int = 0


# Definition

## Gets or sets model. Setting model reset inventory and all stats to the model default values.
var model: ActorModel:
	get:
		var db: ActorModelDB = Models.actors
		if db == null:
			return null
		return db.get_model(model_id)
	set(value):
		model_id = value.id
		_on_model_set()


var is_unique: bool:
	get:
		return _get_flag(FLAG_IS_UNIQUE)
	set(value):
		_set_flag(FLAG_IS_UNIQUE, value)


var faction: Faction:
	get:
		return Models.factions.get_model(faction_id)
	set(value):
		faction_id = value.id


## Appends "(YOU) " if the actor is the player.
var name: String:
	get:
		return "(YOU) " + _name if is_player else _name
	set(value):
		_name = value
		if value != null:
			# NOTE: faithful to the C# original : the Replace() result is
			# discarded (strings are immutable), so this is a no-op there too.
			value.replace("(YOU) ", "")


## Raw name without "(YOU) " for the player.
var unmodified_name: String:
	get:
		return _name


var is_proper_name: bool:
	get:
		return _get_flag(FLAG_IS_PROPER_NAME)
	set(value):
		_set_flag(FLAG_IS_PROPER_NAME, value)


var is_plural_name: bool:
	get:
		return _get_flag(FLAG_IS_PLURAL_NAME)
	set(value):
		_set_flag(FLAG_IS_PLURAL_NAME, value)


var the_name: String:
	get:
		return name if (is_proper_name || is_plural_name) else "the " + _name


## Gets if this actor is controlled by the player or bot.
var is_player: bool:
	get:
		return controller != null && controller is PlayerController


## alpha10.1 bot
var is_bot_player: bool = false


## C# Controller property : setting it calls LeaveControl on the old
## controller and TakeControl on the new one.
var controller: ActorController = null:
	set(value):
		if controller != null:
			controller.leave_control()
		controller = value
		if controller != null:
			controller.take_control(self)


var is_in_a_gang: bool:
	get:
		return gang_id != GameGangs.IDs.NONE


# State

var is_dead: bool:
	get:
		return _get_flag(FLAG_IS_DEAD)
	set(value):
		_set_flag(FLAG_IS_DEAD, value)


var is_sleeping: bool:
	get:
		return _get_flag(FLAG_IS_SLEEPING)
	set(value):
		_set_flag(FLAG_IS_SLEEPING, value)


var is_running: bool:
	get:
		return _get_flag(FLAG_IS_RUNNING)
	set(value):
		_set_flag(FLAG_IS_RUNNING, value)


var hit_points: int:
	get:
		return _hit_points
	set(value):
		if is_invincible && value < _hit_points: # alpha10
			return
		_hit_points = value


var previous_hit_points: int:
	get:
		return _previous_hit_points
	set(value):
		_previous_hit_points = value


var stamina_points: int:
	get:
		return _stamina_points
	set(value):
		if is_invincible && value < _stamina_points: # alpha10
			return
		_stamina_points = value


var previous_stamina_points: int:
	get:
		return _previous_stamina
	set(value):
		_previous_stamina = value


var food_points: int:
	get:
		return _food_points
	set(value):
		if is_invincible && value < _food_points: # alpha10
			return
		_food_points = value


var previous_food_points: int:
	get:
		return _previous_food_points
	set(value):
		_previous_food_points = value


var sleep_points: int:
	get:
		return _sleep_points
	set(value):
		if is_invincible && value < _sleep_points: # alpha10
			return
		_sleep_points = value


var previous_sleep_points: int:
	get:
		return _previous_sleep_points
	set(value):
		_previous_sleep_points = value


var sanity: int:
	get:
		return _sanity
	set(value):
		if is_invincible && value < _sanity: # alpha10
			return
		_sanity = value


var previous_sanity: int:
	get:
		return _previous_sanity
	set(value):
		_previous_sanity = value


var audio_range: int:
	get:
		return sheet.base_audio_range + _audio_range_mod


var audio_range_mod: int:
	get:
		return _audio_range_mod
	set(value):
		_audio_range_mod = value


var has_leader: bool:
	get:
		return leader != null && not leader.is_dead


var count_followers: int:
	get:
		if followers == null:
			return 0
		return followers.size()


var count_aggressor_of: int:
	get:
		if aggressor_of == null:
			return 0
		return aggressor_of.size()


var count_self_defence_from: int:
	get:
		if self_defence_from == null:
			return 0
		return self_defence_from.size()


var infection: int:
	get:
		return _infection
	set(value):
		if is_invincible && value > _infection: # alpha10
			return
		_infection = value


# Init

## C# convenience constructor Actor(model, faction, spawnTime)
##     : this(model, faction, model.Name, false, false, spawnTime)
static func new_spawn(model: ActorModel, faction: Faction, spawn_time: int) -> Actor:
	return Actor.new(model, faction, model.name, false, false, spawn_time)


func _init(p_model: ActorModel, p_faction: Faction, p_name: String, p_is_proper_name: bool = false, p_is_plural_name: bool = false, p_spawn_time: int = 0) -> void:
	assert(p_model != null, "model")
	assert(p_faction != null, "faction")
	assert(p_name != null, "name")

	model_id = p_model.id
	faction_id = p_faction.id
	gang_id = GameGangs.IDs.NONE
	_name = p_name
	is_proper_name = p_is_proper_name
	is_plural_name = p_is_plural_name
	location = Location.new()
	spawn_time = p_spawn_time
	is_unique = false
	is_dead = false

	_on_model_set()


## C# convenience constructor : name defaults to the model name.
static func new_from_model(p_model: ActorModel, p_faction: Faction, p_spawn_time: int) -> Actor:
	return Actor.new(p_model, p_faction, p_model.name, false, false, p_spawn_time)


func _on_model_set() -> void:
	var m: ActorModel = model

	doll = Doll.new(m.doll_body)
	sheet = ActorSheet.new(m.starting_sheet)

	# starting points maxed.
	action_points = doll.body.speed
	_hit_points = sheet.base_hit_points
	_previous_hit_points = _hit_points
	_stamina_points = sheet.base_stamina_points
	_previous_stamina = _stamina_points
	_food_points = sheet.base_food_points
	_previous_food_points = _food_points
	_sleep_points = sheet.base_sleep_points
	_previous_sleep_points = _sleep_points
	_sanity = sheet.base_sanity
	_previous_sanity = _sanity

	# create inventory.
	if m.abilities.has_inventory:
		inventory = Inventory.new(m.starting_sheet.base_inventory_capacity)

	# starting attacks.
	current_melee_attack = m.starting_sheet.unarmed_attack
	current_defence = m.starting_sheet.base_defence
	current_ranged_attack = Attack.BLANK


# Group, Followers & Trust

func add_follower(other: Actor) -> void:
	assert(other != null, "other")
	assert(followers == null || not followers.has(other), "other is already a follower")

	if followers == null:
		followers = []
	followers.append(other)

	if other.leader != null:
		other.leader.remove_follower(other)
	other.leader = self


func remove_follower(other: Actor) -> void:
	assert(other != null, "other")
	assert(followers != null, "no followers")

	followers.erase(other)
	if followers.is_empty():
		followers = null

	other.leader = null

	# reset directives & order.
	var ai := other.controller as AIController
	if ai != null:
		ai.directives.reset()
		ai.set_order(null)


func remove_all_followers() -> void:
	while followers != null && followers.size() > 0:
		remove_follower(followers[0])


func set_trust_in(other: Actor, trust: int) -> void:
	if _trust_list == null:
		var list: Array[TrustRecord] = [TrustRecord.new()]
		list[0].actor = other
		list[0].trust = trust
		_trust_list = list
		return

	for r: TrustRecord in _trust_list:
		if r.actor == other:
			r.trust = trust
			return

	var record := TrustRecord.new()
	record.actor = other
	record.trust = trust
	_trust_list.append(record)


func get_trust_in(other: Actor) -> int:
	if _trust_list == null:
		return 0
	for r: TrustRecord in _trust_list:
		if r.actor == other:
			return r.trust
	return 0


# alpha10
## Is this other actor our leader, a follower or a mate.
func is_in_group_with(other: Actor) -> bool:
	# my leader?
	if has_leader && leader == other:
		return true

	# a mate?
	if other.has_leader && other.leader == leader:
		return true

	# a follower?
	if followers != null:
		if followers.has(other):
			return true

	# nope
	return false


# Aggressor & Self Defence

func mark_as_agressor_of(other: Actor) -> void:
	if other == null || other.is_dead:
		return

	if aggressor_of == null:
		aggressor_of = []
	elif aggressor_of.has(other):
		return
	aggressor_of.append(other)


func mark_as_self_defence_from(other: Actor) -> void:
	if other == null || other.is_dead:
		return

	if self_defence_from == null:
		self_defence_from = []
	elif self_defence_from.has(other):
		return
	self_defence_from.append(other)


func is_aggressor_of(other: Actor) -> bool:
	if aggressor_of == null:
		return false
	return aggressor_of.has(other)


func is_self_defence_from(other: Actor) -> bool:
	if self_defence_from == null:
		return false
	return self_defence_from.has(other)


func remove_aggressor_of(other: Actor) -> void:
	if aggressor_of == null:
		return
	aggressor_of.erase(other)
	if aggressor_of.is_empty():
		aggressor_of = null


func remove_self_defence_from(other: Actor) -> void:
	if self_defence_from == null:
		return
	self_defence_from.erase(other)
	if self_defence_from.is_empty():
		self_defence_from = null


func remove_all_agressor_self_defence_relations() -> void:
	while aggressor_of != null:
		var other: Actor = aggressor_of[0]
		remove_aggressor_of(other)
		other.remove_self_defence_from(self)
	while self_defence_from != null:
		var other: Actor = self_defence_from[0]
		remove_self_defence_from(other)
		other.remove_aggressor_of(self)


# Equipment helpers

func get_equipped_item(part: int) -> Item:
	if inventory == null || part == Doll.DollPart.NONE:
		return null

	for it: Item in inventory.items:
		if it.equipped_part == part:
			return it

	return null


## Assumed to be equiped at Right hand.
func get_equipped_weapon() -> Item:
	return get_equipped_item(Doll.DollPart.RIGHT_HAND)


# alpha10
## Assumed to be equiped at Right hand.
func get_equipped_melee_weapon() -> ItemMeleeWeapon:
	return get_equipped_item(Doll.DollPart.RIGHT_HAND) as ItemMeleeWeapon


# alpha10
## Assumed to be equiped at Right hand.
func get_equipped_ranged_weapon() -> ItemRangedWeapon:
	return get_equipped_item(Doll.DollPart.RIGHT_HAND) as ItemRangedWeapon


# Flags helpers

func _get_flag(f: int) -> bool:
	return (_flags & f) != 0


func _set_flag(f: int, value: bool) -> void:
	if value:
		_flags |= f
	else:
		_flags &= ~f


# Pre-save

func optimize_before_saving() -> void:
	# remove dead target.
	if target_actor != null && target_actor.is_dead:
		target_actor = null

	# alpha10
	# remove trust entries with dead actors.
	# side effect: this means revived actor will forget their trust after a save game!
	if _trust_list != null:
		var i: int = 0
		while i < _trust_list.size():
			if _trust_list[i].actor.is_dead:
				_trust_list.remove_at(i)
			else:
				i += 1
		if _trust_list.is_empty():
			_trust_list = null
	# remove & trim agressor/self-defence entries with dead actors.
	# side effect: this means revived actor will forget their agressor/self-defence after a save game!
	if aggressor_of != null:
		var i: int = 0
		while i < aggressor_of.size():
			if aggressor_of[i].is_dead:
				aggressor_of.remove_at(i)
			else:
				i += 1
		if aggressor_of.is_empty():
			aggressor_of = null
	if self_defence_from != null:
		var i: int = 0
		while i < self_defence_from.size():
			if self_defence_from[i].is_dead:
				self_defence_from.remove_at(i)
			else:
				i += 1
		if self_defence_from.is_empty():
			self_defence_from = null

	# alpha10 inventory
	if inventory != null:
		inventory.optimize_before_saving()


# --- save system ---
## Raw (unresolved) world-graph references captured by deserialize_data and
## resolved by resolve_refs() once the whole world graph exists.
## In-memory only, never saved.
var _raw_refs: Dictionary = {}


static func _serialize_actor_list(list):
	if list == null:
		return null
	var refs := []
	for a in list:
		refs.append(Session.actor_ref(a))
	return refs


func _serialize_controller() -> Dictionary:
	var c := controller
	if c == null:
		return {}
	if c is PlayerController:
		return {"kind": "player"}
	var d := {"kind": "ai", "class_path": c.get_script().resource_path}
	var ai := c as AIController
	if ai != null:
		d["order"] = ai.order.serialize() if ai.order != null else null
		d["directives"] = ai.directives.serialize()
	return d


func serialize() -> Dictionary:
	var trust_data = null
	if _trust_list != null:
		trust_data = []
		for rec in _trust_list:
			trust_data.append({"actor": Session.actor_ref(rec.actor), "trust": rec.trust})
	return {
		"flags": _flags,
		"model_id": model_id,
		"faction_id": faction_id,
		"gang_id": gang_id,
		"name": _name,
		"sheet": sheet.serialize() if sheet != null else null,
		"spawn_time": spawn_time,
		"inventory": inventory.serialize() if inventory != null else null,
		"doll": doll.serialize() if doll != null else null,
		"hit_points": _hit_points,
		"previous_hit_points": _previous_hit_points,
		"stamina_points": _stamina_points,
		"previous_stamina": _previous_stamina,
		"food_points": _food_points,
		"previous_food_points": _previous_food_points,
		"sleep_points": _sleep_points,
		"previous_sleep_points": _previous_sleep_points,
		"sanity": _sanity,
		"previous_sanity": _previous_sanity,
		"location": Location.serialize(location),
		"action_points": action_points,
		"last_action_turn": last_action_turn,
		"activity": activity,
		"target_actor": Session.actor_ref(target_actor),
		"audio_range_mod": _audio_range_mod,
		"current_melee_attack": current_melee_attack.serialize() if current_melee_attack != null else null,
		"current_ranged_attack": current_ranged_attack.serialize() if current_ranged_attack != null else null,
		"current_defence": current_defence.serialize() if current_defence != null else null,
		"leader": Session.actor_ref(leader),
		"followers": _serialize_actor_list(followers),
		"trust_in_leader": trust_in_leader,
		"trust_list": trust_data,
		"kills_count": kills_count,
		"aggressor_of": _serialize_actor_list(aggressor_of),
		"self_defence_from": _serialize_actor_list(self_defence_from),
		"murders_counter": murders_counter,
		"infection": _infection,
		"dragged_corpse": Session.corpse_ref(dragged_corpse),
		"is_invincible": is_invincible,
		"odor_suppressor_counter": odor_suppressor_counter,
		"is_bot_player": is_bot_player,
		"controller": _serialize_controller(),
	}


static func deserialize_data(data: Dictionary) -> Actor:
	var model: ActorModel = Models.actors.get_model(data.get("model_id", 0))
	var faction: Faction = Models.factions.get_model(data.get("faction_id", 0))
	# The constructor rebuilds sheet/doll/inventory from the model ; all live
	# state is then overwritten from the saved data below.
	var a := Actor.new(model, faction, data.get("name", ""))
	a._flags = data.get("flags", 0)
	a.gang_id = data.get("gang_id", GameGangs.IDs.NONE)
	var sheet_data = data.get("sheet")
	if sheet_data != null:
		a.sheet = ActorSheet.deserialize_data(sheet_data)
	a.spawn_time = data.get("spawn_time", 0)
	var inv_data = data.get("inventory")
	a.inventory = Inventory.deserialize_data(inv_data) if inv_data != null else null
	var doll_data = data.get("doll")
	if doll_data != null:
		a.doll = Doll.deserialize_data(doll_data)
	a._hit_points = data.get("hit_points", 0)
	a._previous_hit_points = data.get("previous_hit_points", 0)
	a._stamina_points = data.get("stamina_points", 0)
	a._previous_stamina = data.get("previous_stamina", 0)
	a._food_points = data.get("food_points", 0)
	a._previous_food_points = data.get("previous_food_points", 0)
	a._sleep_points = data.get("sleep_points", 0)
	a._previous_sleep_points = data.get("previous_sleep_points", 0)
	a._sanity = data.get("sanity", 0)
	a._previous_sanity = data.get("previous_sanity", 0)
	a.action_points = data.get("action_points", 0)
	a.last_action_turn = data.get("last_action_turn", 0)
	a.activity = data.get("activity", Activity.IDLE)
	a._audio_range_mod = data.get("audio_range_mod", 0)
	var melee = data.get("current_melee_attack")
	a.current_melee_attack = Attack.deserialize_data(melee) if melee != null else null
	var ranged = data.get("current_ranged_attack")
	a.current_ranged_attack = Attack.deserialize_data(ranged) if ranged != null else null
	var def = data.get("current_defence")
	a.current_defence = Defence.deserialize_data(def) if def != null else null
	a.trust_in_leader = data.get("trust_in_leader", 0)
	a.kills_count = data.get("kills_count", 0)
	a.murders_counter = data.get("murders_counter", 0)
	a._infection = data.get("infection", 0)
	a.is_invincible = data.get("is_invincible", false)
	a.odor_suppressor_counter = data.get("odor_suppressor_counter", 0)
	a.is_bot_player = data.get("is_bot_player", false)
	# Controller: recreate the concrete controller (take_control rebuilds the
	# AI sensors); order/directives are restored below / in resolve_refs.
	var cdata: Dictionary = data.get("controller", {})
	match cdata.get("kind", ""):
		"player":
			a.controller = PlayerController.new()
		"ai":
			var c: ActorController = load(cdata["class_path"]).new()
			a.controller = c
			var ai := c as AIController
			if ai != null:
				var dir_data = cdata.get("directives")
				if dir_data != null:
					ai.directives = ActorDirective.deserialize_data(dir_data)
	# Raw references, resolved in resolve_refs().
	a._raw_refs = {
		"location": data.get("location"),
		"target_actor": data.get("target_actor"),
		"leader": data.get("leader"),
		"followers": data.get("followers"),
		"aggressor_of": data.get("aggressor_of"),
		"self_defence_from": data.get("self_defence_from"),
		"dragged_corpse": data.get("dragged_corpse"),
		"trust_list": data.get("trust_list"),
		"controller_order": cdata.get("order") if cdata.get("kind", "") == "ai" else null,
	}
	return a


func resolve_refs(world: World) -> void:
	location = Location.deserialize_data(world, _raw_refs.get("location"))
	target_actor = Session.resolve_ref(world, _raw_refs.get("target_actor"))
	leader = Session.resolve_ref(world, _raw_refs.get("leader"))
	followers = Session.resolve_ref(world, _raw_refs.get("followers"))
	aggressor_of = Session.resolve_ref(world, _raw_refs.get("aggressor_of"))
	self_defence_from = Session.resolve_ref(world, _raw_refs.get("self_defence_from"))
	dragged_corpse = Session.resolve_ref(world, _raw_refs.get("dragged_corpse"))
	var tl = _raw_refs.get("trust_list")
	if tl != null:
		_trust_list = []
		for t in tl:
			var rec := TrustRecord.new()
			rec.actor = Session.resolve_ref(world, t.get("actor"))
			rec.trust = t.get("trust", 0)
			_trust_list.append(rec)
	else:
		_trust_list = null
	var ai := controller as AIController
	if ai != null and _raw_refs.get("controller_order") != null:
		ai.set_order(ActorOrder.deserialize_data(world, _raw_refs["controller_order"]))
	_raw_refs.clear()
	if inventory != null:
		inventory.resolve_refs(world)
