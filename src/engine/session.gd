class_name Session
extends RefCounted
## Port of Engine/Session.cs
## All the data that is needed to represent the game state, or in other words
## everything that need to be saved and loaded.
##
## NOTE: the original uses .NET BinaryFormatter/Soap/XML for save files.
## This port uses Godot-native serialization (FileAccess.store_var/get_var)
## with explicit field-by-field (de)serialization, see serialize()/deserialize().

enum GameMode {
	GM_STANDARD,
	GM_CORPSES_INFECTION,
	GM_VINTAGE
}


enum ScriptStage {
	STAGE_0,
	STAGE_1,
	STAGE_2,
	STAGE_3,
	STAGE_4,
	STAGE_5
}


enum RaidType {
	_FIRST = 0,

	BIKERS = _FIRST,
	GANGSTA,
	BLACKOPS,
	SURVIVORS,

	## "Fake" raid for AIs.
	NATGUARD,

	## "Fake" raid for AIs.
	ARMY_SUPLLIES,

	_COUNT
}


enum AdvisorHint {
	_FIRST = 0,

	## Basic movement directions.
	MOVE_BASIC = _FIRST,

	## Looking with the mouse.
	MOUSE_LOOK,

	## Redefining keys & options.
	KEYS_OPTIONS,

	## Night effects.
	NIGHT,

	## Rainy weather effects.
	RAIN,

	## Attacking in melee.
	ACTOR_MELEE,

	## Running.
	MOVE_RUN,

	## Resting.
	MOVE_RESTING,

	## Jumping.
	MOVE_JUMP,

	## Grabbing an item from a container.
	ITEM_GRAB_CONTAINER,

	## Grabbing an item from the floor.
	ITEM_GRAB_FLOOR,

	## Unequiping an item.
	ITEM_UNEQUIP,

	## Equiping an item.
	ITEM_EQUIP,

	## Barricading material.
	ITEM_TYPE_BARRICADING,

	## Dropping an item.
	ITEM_DROP,

	## Using an item.
	ITEM_USE,

	## Flashlights.
	FLASHLIGHT,

	## Cellphones.
	CELLPHONES,

	## Using spraypaint.
	SPRAYS_PAINT,

	## Using scent sprays.
	SPRAYS_SCENT,

	## Firing a weapon.
	WEAPON_FIRE,

	## Reloading a weapon.
	WEAPON_RELOAD,

	## Using grenades.
	GRENADE,

	## Opening a door/window.
	DOORWINDOW_OPEN,

	## Closing a door/window.
	DOORWINDOW_CLOSE,

	## Pushing/Pulling objects/actors.
	OBJECT_PUSH,

	## Breaking objects.
	OBJECT_BREAK,

	## Barricading.
	BARRICADE,

	## Using an exit such as ladders, stairs.
	EXIT_STAIRS_LADDERS,

	## Using an exit to leave the district.
	EXIT_LEAVING_DISTRICT,

	## Sleeping.
	STATE_SLEEPY,

	## Eating.
	STATE_HUNGRY,

	## Trading with NPCs.
	NPC_TRADE,

	## Giving items.
	NPC_GIVING_ITEM,

	## Shouting.
	NPC_SHOUTING,

	## Building fortifications.
	BUILD_FORTIFICATION,

	## Leading : need Leadership skill.
	LEADING_NEED_SKILL,

	## Leading : can recruit someone.
	LEADING_CAN_RECRUIT,

	## Leading : give orders.
	LEADING_GIVE_ORDERS,

	## Leading : switching place.
	LEADING_SWITCH_PLACE,

	## Saving/Loading.
	GAME_SAVE_LOAD,

	## City Information.
	CITY_INFORMATION,

	# alpha10 merge corpse hints
	## Corpse actions.
	CORPSE,

	## Eating corpses (undead).
	CORPSE_EAT,

	# alpha10 new hints

	## Sanity.
	SANITY,

	## Infection.
	INFECTION,

	## Traps.
	TRAPS,

	_COUNT
}


## Port of the UniqueActor class declared in Session.cs.
class UniqueActor:
	var is_spawned: bool = false
	var the_actor: Actor = null
	var is_with_refugees: bool = false
	var event_theme_music: String = ""
	var event_message: String = ""


## Port of the UniqueActors class declared in Session.cs.
class UniqueActors:
	var big_bear: UniqueActor = null
	var duckman: UniqueActor = null
	var famu_fataru: UniqueActor = null
	var hans_von_hanz: UniqueActor = null
	var jason_myers: UniqueActor = null
	var police_station_prisoner: UniqueActor = null
	var roguedjack: UniqueActor = null
	var santaman: UniqueActor = null
	var the_sewers_thing: UniqueActor = null


	## Allocate a new array each call don't overuse it...
	## TODO -- consider caching it.
	func to_array() -> Array:
		return [
			big_bear, duckman, famu_fataru, hans_von_hanz, roguedjack, santaman,
			police_station_prisoner, the_sewers_thing,
			jason_myers  # alpha10
		]


## Port of the UniqueItem class declared in Session.cs.
class UniqueItem:
	var is_spawned: bool = false
	var the_item: Item = null


## Port of the UniqueItems class declared in Session.cs.
class UniqueItems:
	var the_subway_worker_badge: UniqueItem = null


## Port of the UniqueMap class declared in Session.cs.
class UniqueMap:
	var the_map: Map = null


## Port of the UniqueMaps class declared in Session.cs.
class UniqueMaps:
	var char_underground_facility: UniqueMap = null
	var police_station_offices_level: UniqueMap = null
	var police_station_jails_level: UniqueMap = null
	var hospital_admissions: UniqueMap = null
	var hospital_offices: UniqueMap = null
	var hospital_patients: UniqueMap = null
	var hospital_storage: UniqueMap = null
	var hospital_power: UniqueMap = null


enum SaveFormat {
	FORMAT_BIN,
	FORMAT_SOAP,
	FORMAT_XML
}


# region Fields

# Game Mode
var game_mode: GameMode = GameMode.GM_STANDARD
var seed: int = 0
var last_turn_player_acted: int = 0

# World map
var world_time: WorldTime = null
var world: World = null
var current_map: Map = null

# Scoring
## NOTE: Scoring (Engine/Scoring.cs) is ported in parallel ; kept untyped so
## this file parses before it lands. Use through the helpers below.
var scoring = null

# Events
## [RaidType, District.WorldPosition.X, District.WorldPosition.Y] -> turnCounter
var event_raids = null

# alpha10.1
# AutoSave
var next_auto_save_time: int = 0

# Uniques
var unique_actors: UniqueActors = null
var unique_items: UniqueItems = null
var unique_maps: UniqueMaps = null

# Special flags
var player_knows_char_underground_facility_location: bool = false
var player_knows_the_sewers_thing_location: bool = false
var char_underground_facility_activated: bool = false
var script_stage_police_station_prisoner: ScriptStage = ScriptStage.STAGE_0
# alpha10
var player_current_fire_mode: Attack.FireMode = Attack.FireMode.DEFAULT
var player_turn_charisma_roll: int = 0

# endregion

# Not saved : the session singleton.
static var the_session = null


## Gets the curent Session (singleton).
static func get_session() -> Session:
	if the_session == null:
		the_session = Session.new()
	return the_session


# region Init

func _init() -> void:
	reset()


func reset() -> void:
	seed = int(Time.get_unix_time_from_system() * 1000000.0) % 2147483647
	current_map = null
	scoring = new_scoring()
	world = null
	world_time = WorldTime.new()
	last_turn_player_acted = 0

	event_raids = []
	var city_size: int = RogueGame.options.city_size
	for i: int in range(RaidType._FIRST, RaidType._COUNT):
		var per_raid = []
		per_raid.resize(city_size)
		for x: int in city_size:
			var per_x = []
			per_x.resize(city_size)
			for y: int in city_size:
				per_x[y] = -1
			per_raid[x] = per_x
		event_raids.append(per_raid)

	############################
	# Reset special properties.
	############################
	char_underground_facility_activated = false
	player_knows_char_underground_facility_location = false
	player_knows_the_sewers_thing_location = false
	script_stage_police_station_prisoner = ScriptStage.STAGE_0
	unique_actors = UniqueActors.new()
	unique_items = UniqueItems.new()
	unique_maps = UniqueMaps.new()
	# alpha10
	player_current_fire_mode = Attack.FireMode.DEFAULT
	player_turn_charisma_roll = 0
	# alpha10.1

# region Events

func has_raid_happened(raid: int, district: District) -> bool:
	assert(district != null, "district")

	return event_raids[raid][district.world_position.x][district.world_position.y] > -1


func last_raid_time(raid: int, district: District) -> int:
	assert(district != null, "district")

	return event_raids[raid][district.world_position.x][district.world_position.y]


func set_last_raid_time(raid: int, district: District, turn_counter: int) -> void:
	assert(district != null, "district")

	# NOTE: the C# version took a lock for thread safety ; the port runs the
	# simulation on the main thread so no lock is needed.
	event_raids[raid][district.world_position.x][district.world_position.y] = turn_counter


# region Saving & Loading

## Resolve the Scoring class dynamically (ported in parallel).
const SCORING_PATH := "res://src/engine/scoring.gd"


func new_scoring():
	if ResourceLoader.exists(SCORING_PATH):
		return ResourceLoader.load(SCORING_PATH).new()
	push_warning("Scoring class not ported yet (%s)" % SCORING_PATH)
	return null


## Serialize the session (and its object graph) field by field.
## Replaces the C# BinaryFormatter graph walk : the session's own fields are
## explicit here and graph objects (World, Scoring) delegate to their own
## serialize()/deserialize_data() functions in the data layer.
func serialize() -> Dictionary:
	var data := {}
	data["game_mode"] = game_mode
	data["seed"] = seed
	data["world_time_turn"] = world_time.turn_counter
	# World map graph (maps, actors, items...).
	# data-layer contract : see World.serialize()/deserialize_data()
	# (Engine port of the C# BinaryFormatter graph walk).
	if world != null && world.has_method("serialize"):
		data["world"] = world.serialize()
	else:
		data["world"] = null
	data["current_map"] = map_ref(current_map)
	data["scoring"] = scoring.serialize() if scoring != null else null
	data["last_turn_player_acted"] = last_turn_player_acted
	data["event_raids"] = event_raids
	data["next_auto_save_time"] = next_auto_save_time
	data["unique_actors"] = _serialize_unique_actors()
	data["unique_items"] = _serialize_unique_items()
	data["unique_maps"] = _serialize_unique_maps()
	# Special flags.
	data["player_knows_char_underground_facility_location"] = player_knows_char_underground_facility_location
	data["player_knows_the_sewers_thing_location"] = player_knows_the_sewers_thing_location
	data["char_underground_facility_activated"] = char_underground_facility_activated
	data["script_stage_police_station_prisoner"] = script_stage_police_station_prisoner
	data["player_current_fire_mode"] = player_current_fire_mode
	data["player_turn_charisma_roll"] = player_turn_charisma_roll
	return data


## Restore fields from serialize() data. The caller must then call
## reconstruct_auxiliary_fields() once the world graph is loaded.
func deserialize(data: Dictionary) -> void:
	game_mode = data.get("game_mode", GameMode.GM_STANDARD)
	seed = data.get("seed", 0)
	world_time = WorldTime.new(data.get("world_time_turn", 0))

	world = null
	var world_data = data.get("world")
	if world_data != null:
		# data-layer contract : see World.serialize()/deserialize_data()
		# (Engine port of the C# BinaryFormatter graph walk).
		world = World.deserialize_data(world_data)
	current_map = map_from_ref(world, data.get("current_map"))

	scoring = null
	var scoring_data = data.get("scoring")
	if scoring_data != null && ResourceLoader.exists(SCORING_PATH):
		scoring = ResourceLoader.load(SCORING_PATH).call("deserialize_data", scoring_data)

	last_turn_player_acted = data.get("last_turn_player_acted", 0)
	event_raids = data.get("event_raids")
	next_auto_save_time = data.get("next_auto_save_time", 0)
	_deserialize_unique_actors(data.get("unique_actors"))
	_deserialize_unique_items(data.get("unique_items"))
	_deserialize_unique_maps(data.get("unique_maps"))

	player_knows_char_underground_facility_location = data.get("player_knows_char_underground_facility_location", false)
	player_knows_the_sewers_thing_location = data.get("player_knows_the_sewers_thing_location", false)
	char_underground_facility_activated = data.get("char_underground_facility_activated", false)
	script_stage_police_station_prisoner = data.get("script_stage_police_station_prisoner", ScriptStage.STAGE_0)
	player_current_fire_mode = data.get("player_current_fire_mode", Attack.FireMode.DEFAULT)
	player_turn_charisma_roll = data.get("player_turn_charisma_roll", 0)


# --- unique objects references ---

## Serialize a reference to a map inside the world graph :
## district world position + index of the map in the district maps list.
static func map_ref(map: Map) -> Dictionary:
	if map == null || map.district == null:
		return {}
	var district: District = map.district
	return {
		"district_x": district.world_position.x,
		"district_y": district.world_position.y,
		"map_index": district.maps.find(map),
	}


static func map_from_ref(world: World, ref: Dictionary) -> Map:
	if world == null || ref == null || ref.is_empty():
		return null
	var district: District = world.get_district(ref["district_x"], ref["district_y"])
	return district.get_map(ref["map_index"])


## Serialize a reference to an actor inside the world graph :
## map reference + index of the actor in the map actors list.
static func actor_ref(actor: Actor) -> Dictionary:
	if actor == null or actor.location == null or actor.location.map == null:
		return {}
	var map: Map = actor.location.map
	var ref := map_ref(map)
	ref["actor_index"] = map.actors_list.find(actor)
	return ref


static func actor_from_ref(world: World, ref: Dictionary) -> Actor:
	if world == null || ref == null || ref.is_empty():
		return null
	var map := map_from_ref(world, ref)
	if map == null:
		return null
	return map.actors_list[ref["actor_index"]]


## Serialize a reference to an item inside the world graph : the item is
## either on the ground or carried by an actor (that covers all the uses of
## the unique subway worker badge in the original game).
## Items are found by scanning the map, they have no back-reference to it.
static func item_ref(item: Item) -> Dictionary:
	if item == null:
		return {}
	return _find_item_map_and_ref(get_session().world, item)


static func _find_item_map_and_ref(world: World, item: Item) -> Dictionary:
	if world == null:
		return {}
	for x: int in world.size:
		for y: int in world.size:
			var ref := _find_item_in_map(item, world.get_district(x, y))
			if not ref.is_empty():
				return ref
	return {}


static func _find_item_in_map(item: Item, district: District) -> Dictionary:
	for map: Map in district.maps:
		# carried by an actor?
		for i_actor: int in map.actors_list.size():
			var actor: Actor = map.actors_list[i_actor]
			if actor.inventory != null && actor.inventory.contains(item):
				var ref := map_ref(map)
				ref["holder"] = "actor"
				ref["actor_index"] = i_actor
				ref["item_index"] = actor.inventory.items.find(item)
				return ref

		# on the ground?
		for position: Vector2i in map.ground_items_by_position:
			var inv: Inventory = map.ground_items_by_position[position]
			if inv.contains(item):
				var ref := map_ref(map)
				ref["holder"] = "ground"
				ref["position_x"] = position.x
				ref["position_y"] = position.y
				ref["item_index"] = inv.items.find(item)
				return ref

	return {}


static func item_from_ref(world: World, ref: Dictionary) -> Item:
	if world == null || ref == null || ref.is_empty():
		return null
	var map := map_from_ref(world, ref)
	if map == null:
		return null
	match ref.get("holder", ""):
		"actor":
			var actor: Actor = map.actors_list[ref["actor_index"]]
			if actor.inventory == null:
				return null
			return actor.inventory.get_item_at(ref["item_index"])
		"ground":
			var inv: Inventory = map.ground_items_by_position[Vector2i(ref["position_x"], ref["position_y"])]
			return inv.get_item_at(ref["item_index"])
	return null


func _serialize_unique_actors() -> Dictionary:
	var data := {}
	for actor_name: String in ["big_bear", "duckman", "famu_fataru", "hans_von_hanz",
			"jason_myers", "police_station_prisoner", "roguedjack", "santaman",
			"the_sewers_thing"]:
		data[actor_name] = _serialize_unique_actor(unique_actors.get(actor_name))
	return data


func _serialize_unique_actor(u: UniqueActor) -> Dictionary:
	if u == null:
		return {}
	return {
		"is_spawned": u.is_spawned,
		"actor": actor_ref(u.the_actor),
		"is_with_refugees": u.is_with_refugees,
		"event_theme_music": u.event_theme_music,
		"event_message": u.event_message,
	}


func _deserialize_unique_actors(data) -> void:
	if data == null:
		return
	for actor_name: String in data:
		unique_actors.set(actor_name, _deserialize_unique_actor(data[actor_name]))


func _deserialize_unique_actor(data: Dictionary) -> UniqueActor:
	if data == null || data.is_empty():
		return null
	var u := UniqueActor.new()
	u.is_spawned = data.get("is_spawned", false)
	u.the_actor = actor_from_ref(world, data.get("actor"))
	u.is_with_refugees = data.get("is_with_refugees", false)
	u.event_theme_music = data.get("event_theme_music", "")
	u.event_message = data.get("event_message", "")
	return u


func _serialize_unique_items() -> Dictionary:
	var data := {}
	data["the_subway_worker_badge"] = _serialize_unique_item(unique_items.the_subway_worker_badge)
	return data


func _serialize_unique_item(u: UniqueItem) -> Dictionary:
	if u == null:
		return {}
	var item_data: Dictionary = item_ref(u.the_item)
	if item_data.is_empty() and u.the_item != null:
		# Item exists but is not placed in the world yet (e.g. the subway
		# worker badge when no subway map was generated): embed it inline,
		# a world scan cannot reference it.
		item_data = {"inline": u.the_item.serialize()}
	return {
		"is_spawned": u.is_spawned,
		"item": item_data,
	}


func _deserialize_unique_items(data) -> void:
	if data == null:
		return
	if data.has("the_subway_worker_badge"):
		unique_items.the_subway_worker_badge = _deserialize_unique_item(data["the_subway_worker_badge"])


func _deserialize_unique_item(data: Dictionary) -> UniqueItem:
	if data == null || data.is_empty():
		return null
	var u := UniqueItem.new()
	u.is_spawned = data.get("is_spawned", false)
	var ref = data.get("item")
	if ref is Dictionary and ref.has("inline"):
		u.the_item = Item.deserialize_data(ref["inline"])
	else:
		u.the_item = item_from_ref(world, ref)
	return u


func _serialize_unique_maps() -> Dictionary:
	var data := {}
	for map_name: String in ["char_underground_facility", "police_station_offices_level",
			"police_station_jails_level", "hospital_admissions", "hospital_offices",
			"hospital_patients", "hospital_storage", "hospital_power"]:
		var u: UniqueMap = unique_maps.get(map_name)
		if u == null:
			data[map_name] = {}
		else:
			data[map_name] = map_ref(u.the_map)
	return data


func _deserialize_unique_maps(data) -> void:
	if data == null:
		return
	for map_name: String in data:
		var u := UniqueMap.new()
		u.the_map = map_from_ref(world, data[map_name])
		unique_maps.set(map_name, u)


## C# Save(Session, filepath, format).
## The original BIN/SOAP/XML formats are replaced by Godot-native var
## serialization ; the format argument is kept for API compatibility.
static func save(session: Session, filepath: String, format: SaveFormat = SaveFormat.FORMAT_BIN) -> void:
	assert(session != null, "session")
	assert(filepath != null, "filepath")

	# optimize.
	if session.world != null:
		session.world.optimize_before_saving()

	print("saving session...")

	var file := FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("saving session exception : %s (%s)" % [filepath, FileAccess.get_open_error()])
		return
	file.store_var(session.serialize())
	file.close()

	print("saving session... done!")


## Try to load, false if failed.
static func load(filepath: String, format: SaveFormat = SaveFormat.FORMAT_BIN) -> bool:
	assert(filepath != null, "filepath")

	print("loading session...")

	var file := FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_warning("failed to load session (no save game?) : %s (%s)" % [filepath, FileAccess.get_open_error()])
		the_session = null
		return false

	var data = file.get_var()
	file.close()

	if not (data is Dictionary):
		push_warning("failed to load session, bad data.")
		the_session = null
		return false

	# deserialize.
	var session := Session.new()
	session.deserialize(data)
	the_session = session

	# reconstruct auxiliary fields.
	if the_session.world != null:
		the_session.reconstruct_auxiliary_fields()

	print("loading session... done!")
	return true


static func delete(filepath: String) -> bool:
	assert(filepath != null, "filepath")

	print("deleting saved game...")

	var has_deleted := false
	if DirAccess.remove_absolute(filepath) == OK:
		has_deleted = true
	else:
		push_warning("failed to delete saved game (no save?), failing silently : %s" % filepath)

	print("deleting saved game... done!")

	return has_deleted


func reconstruct_auxiliary_fields() -> void:
	# reconstruct all maps auxiliary fields.
	for x: int in world.size:
		for y: int in world.size:
			for map: Map in world.get_district(x, y).maps:
				map.reconstruct_auxiliary_fields()


# region Helpers

static func desc_game_mode(mode: GameMode) -> String:
	match mode:
		GameMode.GM_STANDARD:
			return "STD - Standard Game"
		GameMode.GM_CORPSES_INFECTION:
			return "C&I - Corpses & Infection"
		GameMode.GM_VINTAGE:
			return "VTG - Vintage Zombies"
	push_error("unhandled game mode")
	return ""


static func desc_short_game_mode(mode: GameMode) -> String:
	match mode:
		GameMode.GM_STANDARD:
			return "STD"
		GameMode.GM_CORPSES_INFECTION:
			return "C&I"
		GameMode.GM_VINTAGE:
			return "VTG"
	push_error("unhandled game mode")
	return ""


# alpha10
func actor_to_unique_actor(a: Actor) -> UniqueActor:
	assert(a.is_unique, "actor is not unique")
	for unique: UniqueActor in unique_actors.to_array():
		if unique.the_actor == a:
			return unique
	push_error("actor is flaged as unique but did not find it!")
	return null


# region Dev (DEBUG_STATS)

const DEBUG_STATS := false


class DistrictStat:
	class Record:
		var livings: int = 0
		var undeads: int = 0

	var turn_records: Dictionary = {}  # int turn -> Record


var stats = null  # DistrictStat[world.size, world.size] when DEBUG_STATS.


func update_stats(d: District) -> void:
	if not DEBUG_STATS:
		return

	if stats == null:
		stats = []
		stats.resize(world.size * world.size)
		for x: int in world.size:
			for y: int in world.size:
				stats[x * world.size + y] = DistrictStat.new()

	var turn: int = d.entry_map.local_time.turn_counter
	var district_stat: DistrictStat = stats[d.world_position.x * world.size + d.world_position.y]
	if district_stat.turn_records.has(turn):
		return

	var l: int = 0
	var u: int = 0
	for m: Map in d.maps:
		for a: Actor in m.actors_list:
			if a.is_dead:
				continue
			if a.model.abilities.is_undead:
				u += 1
			else:
				l += 1
	var record := DistrictStat.Record.new()
	record.livings = l
	record.undeads = u
	district_stat.turn_records[turn] = record


## C# returns Record? -> null or Record.
func get_stat_record(d: District, turn: int) -> DistrictStat.Record:
	if stats == null:
		return null
	var district_stat: DistrictStat = stats[d.world_position.x * world.size + d.world_position.y]
	return district_stat.turn_records.get(turn)

# endregion


# region Save-system helpers used by the data layer

## Serialize a reference to a corpse inside the world graph :
## map reference + index of the corpse in the map corpses list.
static func corpse_ref(corpse: Corpse) -> Dictionary:
	if corpse == null:
		return {}
	var world: World = get_session().world
	if world == null:
		return {}
	for x: int in world.size:
		for y: int in world.size:
			var district: District = world.get_district(x, y)
			for m: Map in district.maps:
				var idx: int = m.corpses_list.find(corpse)
				if idx >= 0:
					var ref := map_ref(m)
					ref["corpse_index"] = idx
					return ref
	return {}


static func corpse_from_ref(world: World, ref: Dictionary) -> Corpse:
	if world == null || ref == null || ref.is_empty():
		return null
	var map := map_from_ref(world, ref)
	if map == null:
		return null
	var idx: int = ref.get("corpse_index", -1)
	if idx < 0 || idx >= map.corpses_list.size():
		return null
	return map.corpses_list[idx]


## Resolve any world-graph reference produced by map_ref/actor_ref/corpse_ref.
## Arrays are resolved element-wise.
static func resolve_ref(world: World, ref):
	if ref == null or (ref is Dictionary and ref.is_empty()):
		return null
	if ref is Array:
		var out := []
		for r in ref:
			out.append(resolve_ref(world, r))
		return out
	if ref.has("corpse_index"):
		return corpse_from_ref(world, ref)
	if ref.has("actor_index"):
		return actor_from_ref(world, ref)
	if ref.has("map_index"):
		return map_from_ref(world, ref)
	return null


## Serialize all script-declared storage properties of scalar type
## (bool/int/float/String) of an object. Used by the save system for the
## purely-scalar data classes (Abilities, Defence, ActorDirective...).
static func serialize_scalar_vars(obj: Object) -> Dictionary:
	var data := {}
	for p in obj.get_property_list():
		if not (p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		match p.type:
			TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
				data[p.name] = obj.get(p.name)
	return data


## Inverse of serialize_scalar_vars.
static func apply_scalar_vars(obj: Object, data: Dictionary) -> void:
	if data == null:
		return
	for p in obj.get_property_list():
		if not (p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		match p.type:
			TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
				if data.has(p.name):
					obj.set(p.name, data[p.name])

# endregion
