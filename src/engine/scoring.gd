class_name Scoring
extends RefCounted
## Port of Engine/Scoring.cs
## Session scoring : achievements, kills, sightings, events, death record and
## the difficulty rating.
##
## The Achievement class, its IDs enum and the DifficultySide enum are declared
## in the same C# file; access them as Scoring.Achievement, Scoring.Achievement.IDs
## and Scoring.DifficultySide.
##
## Serialization replaces the C# [Serializable]/BinaryFormatter machinery :
## see serialize()/deserialize_data(). References into the world graph (visited
## maps, killer, zombified player, followers) are stored as Session.map_ref() /
## Session.actor_ref() dictionaries and resolved by reconstruct_auxiliary_fields()
## once the World is loaded.


## Port of the DifficultySide enum declared in Scoring.cs.
enum DifficultySide {
	FOR_SURVIVOR = 0,
	FOR_UNDEAD,
}


## Port of the Achievement class declared in Scoring.cs.
class Achievement:
	enum IDs {
		_FIRST = 0,

		REACHED_DAY_07 = _FIRST,
		REACHED_DAY_14,
		REACHED_DAY_21,
		REACHED_DAY_28,

		CHAR_BROKE_INTO_OFFICE,
		CHAR_FOUND_UNDERGROUND_FACILITY,
		CHAR_POWER_UNDERGROUND_FACILITY,

		KILLED_THE_SEWERS_THING,

		_COUNT,
	}

	var id: int
	var name: String
	var tease_name: String
	var text: Array = [] # of String
	var music_id: String
	var score_value: int
	var is_done: bool = false


	func _init(p_id: int, p_name: String, p_tease_name: String, p_text: Array, p_music_id: String, p_score_value: int) -> void:
		id = p_id
		name = p_name
		tease_name = p_tease_name
		text = p_text
		music_id = p_music_id
		score_value = p_score_value
		is_done = false


## Port of the KillData class declared in Scoring.cs.
class KillData:
	var actor_model_id: int
	var amount: int
	var first_kill_turn: int


	func _init(p_actor_model_id: int, turn: int) -> void:
		actor_model_id = p_actor_model_id
		amount = 1
		first_kill_turn = turn


## Port of the GameEventData class declared in Scoring.cs.
class GameEventData:
	var turn: int
	var text: String


	func _init(p_turn: int, p_text: String) -> void:
		turn = p_turn
		text = p_text


# Constants

const SCORE_BONUS_FOR_KILLING_LIVING_AS_UNDEAD: int = 12 * WorldTime.TURNS_PER_HOUR

# Fields

var _start_scoring_turn: int = 0
var _reincarnation_number: int = 0
var _kills: Dictionary = {} # actor model id -> KillData
var _sightings: Array = [] # of int (actor model ids)
var _visited_maps: Array = [] # of Map
var _events: Array = [] # of GameEventData
var _kill_points: int = 0
var _difficulty_rating: float = 1.0
var _side: int = DifficultySide.FOR_SURVIVOR

# C# auto-properties.
var achievements: Array = [] # of Achievement, indexed by Achievement.IDs
var starting_skill: int = Skills.IDs._FIRST # obsolete
var turns_survived: int = 0
var death_reason = null # String or null before dying
var death_place = null # String or null before dying
var real_life_playing_time: int = 0 # reallife playing time in seconds
var completed_achievements_count: int = 0

# References into the world graph; killer/zombified player/followers can be null.
var killer = null # Actor or null
var zombified_player = null # Actor or null
var followers_when_died = null # Array of Actor or null


# Properties

var side: int:
	get:
		return _side
	set(value):
		_side = value


var start_scoring_turn: int:
	get:
		return _start_scoring_turn
	set(value):
		_start_scoring_turn = value


## Current reincarnation, 0 is the first life.
var reincarnation_number: int:
	get:
		return _reincarnation_number
	set(value):
		_reincarnation_number = value


var events: Array:
	get:
		return _events


var has_no_events: bool:
	get:
		return _events.is_empty()


var kills: Array:
	get:
		return _kills.values()


var has_no_kills: bool:
	get:
		return _kills.is_empty()


var sightings: Array:
	get:
		return _sightings


var survival_points: int:
	get:
		return 2 * (turns_survived - _start_scoring_turn)


var achievement_points: int:
	get:
		var bonus := 0

		for i in range(Achievement.IDs._FIRST, Achievement.IDs._COUNT):
			if has_completed_achievement(i):
				bonus += get_achievement(i).score_value

		return bonus


## Difficulty as a float (0..1+), divided by current reincarnation number.
var difficulty_rating: float:
	get:
		return _difficulty_rating / (1.0 + _reincarnation_number)
	set(value):
		_difficulty_rating = value


## (Difficulty * (SurvivalPoints + KillPoints + Achievement))
var total_points: int:
	get:
		return int(difficulty_rating * (_kill_points + survival_points + achievement_points))


var kill_points: int:
	get:
		return _kill_points


# Init

func _init() -> void:
	achievements.resize(Achievement.IDs._COUNT)

	# CHAR related
	_init_achievement(Achievement.IDs.CHAR_BROKE_INTO_OFFICE,
		Achievement.new(Achievement.IDs.CHAR_BROKE_INTO_OFFICE,
			"Broke into a CHAR Office",
			"Did not broke into XXX",
			["Now try not to die too soon..."],
			GameMusics.HEYTHERE,
			1000))

	_init_achievement(Achievement.IDs.CHAR_FOUND_UNDERGROUND_FACILITY,
		Achievement.new(Achievement.IDs.CHAR_FOUND_UNDERGROUND_FACILITY,
			"Found the CHAR Underground Facility",
			"Did not found XXX",
			["Now, where is the light switch?..." ],
			GameMusics.CHAR_UNDERGROUND_FACILITY,
			2000))

	_init_achievement(Achievement.IDs.CHAR_POWER_UNDERGROUND_FACILITY,
		Achievement.new(Achievement.IDs.CHAR_POWER_UNDERGROUND_FACILITY,
			"Powered the CHAR Underground Facility",
			"Did not XXX the XXX",
			["Personal message from the game developper : ",
				"Sorry, the rest of the plot is missing.",
				"For now its a dead end.",
				"Enjoy the rest of the game.",
				"See you in a next game version :)"],
			GameMusics.CHAR_UNDERGROUND_FACILITY,
			3000))

	# Killing uniques
	_init_achievement(Achievement.IDs.KILLED_THE_SEWERS_THING,
		Achievement.new(Achievement.IDs.KILLED_THE_SEWERS_THING,
			"Killed The Sewers Thing",
			"Did not kill the XXX",
			["One less Thing to worry about!"],
			GameMusics.HEYTHERE,
			1000))

	# Reaching Day X
	_init_achievement(Achievement.IDs.REACHED_DAY_07,
		Achievement.new(Achievement.IDs.REACHED_DAY_07,
			"Reached Day 7",
			"Did not reach XXX",
			["Keep staying alive!"],
			GameMusics.HEYTHERE,
			1000))

	_init_achievement(Achievement.IDs.REACHED_DAY_14,
		Achievement.new(Achievement.IDs.REACHED_DAY_14,
			"Reached Day 14",
			"Did not reach XXX",
			["Keep staying alive!"],
			GameMusics.HEYTHERE,
			1000))

	_init_achievement(Achievement.IDs.REACHED_DAY_21,
		Achievement.new(Achievement.IDs.REACHED_DAY_21,
			"Reached Day 21",
			"Did not reach XXX",
			["Keep staying alive!"],
			GameMusics.HEYTHERE,
			1000))

	_init_achievement(Achievement.IDs.REACHED_DAY_28,
		Achievement.new(Achievement.IDs.REACHED_DAY_28,
			"Reached Day 28",
			"Did not reach XXX",
			["Is this the end?"],
			GameMusics.HEYTHERE,
			1000))


## Setup scoring for a new life (reincarnation).
func start_new_life(game_turn: int) -> void:
	# new life.
	_reincarnation_number += 1

	# reset achievements.
	for a in achievements:
		if a != null:
			a.is_done = false
	completed_achievements_count = 0

	# reset visited maps.
	_visited_maps.clear()

	# clear events.
	_events.clear()

	# clear sightings.
	_sightings.clear()

	# clear kills.
	_kills.clear()

	# reset killer, followers & zombified form.
	killer = null
	followers_when_died = null
	zombified_player = null

	# reset points.
	_kill_points = 0

	# start scoring at this turn.
	_start_scoring_turn = game_turn


# Achievements

func has_completed_achievement(id: int) -> bool:
	return achievements[id] != null and achievements[id].is_done


func set_completed_achievement(id: int) -> void:
	achievements[id].is_done = true


func get_achievement(id: int) -> Achievement:
	return achievements[id]


func _init_achievement(id: int, a: Achievement) -> void:
	achievements[id] = a


## - side : side the difficulty is computed for.
## - reincarnation_number : 0 for the first life.
## Returns [0..1+].
static func compute_difficulty_rating(options: GameOptions, __side: int, __reincarnation_number: int) -> float:
	var rating := 1.0

	###########
	# Constant factors.
	#  Harder:
	#  - Don't reveal starting map : +10%
	#  Survivor Easier/Undead Harder:
	#  - Disable NPC starvation    : -10%/+10%
	#  Harder/Easier:
	#  - Nat Guards                : -50% -> +50%
	#  - Supplies                  : -50% -> +50%
	#  - Zombifieds UpDay
	###########
	# - Don't reveal starting map: +10%
	if not options.reveal_starting_district:
		rating += 0.10

	# - Disable NPC starvation: -10%
	if not options.npc_can_starve_to_death:
		if __side == DifficultySide.FOR_SURVIVOR:
			rating -= 0.10
		else:
			rating += 0.10

	# - Nat Guards                : -50% -> +50%
	if options.nat_guard_factor != GameOptions.DEFAULT_NATGUARD_FACTOR:
		var k := float(options.nat_guard_factor - GameOptions.DEFAULT_NATGUARD_FACTOR) / float(GameOptions.DEFAULT_NATGUARD_FACTOR)
		if __side == DifficultySide.FOR_SURVIVOR:
			rating -= 0.50 * k
		else:
			rating += 0.50 * k

	# - Supplies                  : -50% -> +50%
	if options.supplies_drop_factor != GameOptions.DEFAULT_SUPPLIESDROP_FACTOR:
		var k := float(options.supplies_drop_factor - GameOptions.DEFAULT_SUPPLIESDROP_FACTOR) / float(GameOptions.DEFAULT_SUPPLIESDROP_FACTOR)
		if __side == DifficultySide.FOR_SURVIVOR:
			rating -= 0.50 * k
		else:
			rating += 0.50 * k

	# - Zombifieds UpDay
	if options.zombifieds_upgrade_days != GameOptions.DEFAULT_ZOMBIFIEDS_UPGRADE_DAYS:
		var k := 0.0
		match options.zombifieds_upgrade_days:
			GameOptions.ZupDays.OFF: k = -0.50
			GameOptions.ZupDays.ONE: k = 0.50
			GameOptions.ZupDays.TWO: k = 0.25
			GameOptions.ZupDays.THREE: pass
			GameOptions.ZupDays.FOUR: k -= 0.10
			GameOptions.ZupDays.FIVE: k -= 0.20
			GameOptions.ZupDays.SIX: k -= 0.30
			GameOptions.ZupDays.SEVEN: k -= 0.40
		if __side == DifficultySide.FOR_SURVIVOR:
			rating += k
		else:
			rating -= k

	###########
	# Dynamic factors:
	#  !reversed for undeads!
	#  - Density            : f(mapsize, civs+undeads), +/- 99%   // alpha10.1 removed citysize from difficulty formula
	#  - Undeads            : f(undeads/civs, day0, invasion%), +/- 50%
	#  - Civilians          : f(zombification%, canstarve&starvedzomb%), +/- 50%
	###########
	# - Density            : f(mapsize, civs+undeads), +/- 99%   // alpha10.1 removed citysize from difficulty formula
	var k_default_density := sqrt(GameOptions.DEFAULT_MAX_CIVILIANS + GameOptions.DEFAULT_MAX_UNDEADS) / float(GameOptions.DEFAULT_DISTRICT_SIZE * GameOptions.DEFAULT_DISTRICT_SIZE)
	# Guard user-configurable options against zero denominators.
	var district_size := options.district_size if options.district_size > 0 else GameOptions.DEFAULT_DISTRICT_SIZE
	var k_density := sqrt(options.max_civilians + options.max_undeads) / float(district_size * district_size)
	var r_density := (k_density - k_default_density) / k_default_density
	if __side == DifficultySide.FOR_SURVIVOR:
		rating += 0.99 * r_density
	else:
		rating -= 0.99 * r_density

	# - Undeads            : f(undeads/civs, day0, invasion%), +/- 50%
	var k_default_undeads_ratio := float(GameOptions.DEFAULT_MAX_UNDEADS) / float(GameOptions.DEFAULT_MAX_CIVILIANS)
	var max_civilians := options.max_civilians if options.max_civilians > 0 else GameOptions.DEFAULT_MAX_CIVILIANS
	var k_undeads_ratio := float(options.max_undeads) / float(max_civilians)
	var k_undeads_nb := (k_undeads_ratio - k_default_undeads_ratio) / k_default_undeads_ratio
	var k_undeads_day0 := float(options.day_zero_undeads_percent - GameOptions.DEFAULT_DAY_ZERO_UNDEADS_PERCENT) / float(GameOptions.DEFAULT_DAY_ZERO_UNDEADS_PERCENT)
	var k_undeads_inv := float(options.zombie_invasion_daily_increase - GameOptions.DEFAULT_ZOMBIE_INVASION_DAILY_INCREASE) / float(GameOptions.DEFAULT_ZOMBIE_INVASION_DAILY_INCREASE)
	if __side == DifficultySide.FOR_SURVIVOR:
		rating += 0.30 * k_undeads_nb + 0.05 * k_undeads_day0 + 0.15 * k_undeads_inv
	else:
		rating -= 0.30 * k_undeads_nb + 0.05 * k_undeads_day0 + 0.15 * k_undeads_inv

	# - Civilians          : f(zombification%, canstarve&starvedzomb%), +/- 50%
	var k_default_civ_zombification := float(GameOptions.DEFAULT_MAX_CIVILIANS) * float(GameOptions.DEFAULT_ZOMBIFICATION_CHANCE)
	var k_civ_zombification := float(options.max_civilians * options.zombification_chance - k_default_civ_zombification) / k_default_civ_zombification

	var k_default_civ_starvation := float(GameOptions.DEFAULT_MAX_CIVILIANS) * float(GameOptions.DEFAULT_STARVED_ZOMBIFICATION_CHANCE)
	var k_civ_starvation := float(options.max_civilians * options.starved_zombification_chance - k_default_civ_starvation) / k_default_civ_starvation
	if not options.npc_can_starve_to_death:
		k_civ_starvation = -1.0
	if __side == DifficultySide.FOR_SURVIVOR:
		rating += 0.30 * k_civ_zombification + 0.20 * k_civ_starvation
	else:
		rating -= 0.30 * k_civ_zombification + 0.20 * k_civ_starvation


	###########
	# Scaling factors.
	#  - Disable undeads evolution  : x0.5 / x2
	#  - Enable Combat Assistant    : x0.75
	#  - Enable permadeath          : x2
	#  - Aggressive Hungry Civs     : x0.5 / x2
	#  - Rats Upgrade               : x1.10 / x0.90
	#  - Skeletons Upgrade          : x1.20 / x0.80
	#  - Shamblers Upgrade          : x1.25 / x0.75
	###########
	# - Disable undeads evolution: x0.5 / x2
	if not options.allow_undeads_evolution:
		if __side == DifficultySide.FOR_SURVIVOR:
			rating *= 0.5
		else:
			rating *= 2.0

	# - Enable Combat Assistant   : x0.75
	if options.is_combat_assistant_on:
		rating *= 0.75

	# - Enable permadeath          : x2
	if options.is_permadeath_on:
		rating *= 2.0

	# - Aggressive Hungry Civs     : x0.5 / x2
	if not options.is_aggressive_hungry_civilians_on:
		if __side == DifficultySide.FOR_SURVIVOR:
			rating *= 0.5
		else:
			rating *= 2.0
	# - Rats Upgrade
	if options.rats_upgrade:
		if __side == DifficultySide.FOR_SURVIVOR:
			rating *= 1.10
		else:
			rating *= 0.90
	# - Skeletons Upgrade
	if options.skeletons_upgrade:
		if __side == DifficultySide.FOR_SURVIVOR:
			rating *= 1.20
		else:
			rating *= 0.80
	# - Shamblers Upgrade
	if options.shamblers_upgrade:
		if __side == DifficultySide.FOR_SURVIVOR:
			rating *= 1.25
		else:
			rating *= 0.75

	###########
	# Divide by reincarnation.
	###########
	rating /= 1.0 + __reincarnation_number

	# done.
	return max(rating, 0.0)


# Kills & Sightings

## Add kill to record and increase kill points.
## Distinguish killing as living vs killing as undead.
func add_kill(_player: Actor, victim: Actor, turn: int) -> void:
	var actor_model_id: int = victim.model.id

	# add kill.
	var data = _kills.get(actor_model_id)
	if data != null:
		data.amount += 1
	else:
		# first kill!
		_kills[actor_model_id] = KillData.new(actor_model_id, turn)
		_events.append(GameEventData.new(turn, "Killed first %s." % Models.actors.get_model(actor_model_id).name))

	# add to score.
	_kill_points += Models.actors.get_model(actor_model_id).score_value

	# killing livings as undead give bonuses.
	if _side == DifficultySide.FOR_UNDEAD and not Models.actors.get_model(actor_model_id).abilities.is_undead:
		_kill_points += SCORE_BONUS_FOR_KILLING_LIVING_AS_UNDEAD


func add_sighting(actor_model_id: int, turn: int) -> void:
	# ignore if already sighted.
	if actor_model_id in _sightings:
		return

	# add.
	_sightings.append(actor_model_id)
	_events.append(GameEventData.new(turn, "Sighted first %s." % Models.actors.get_model(actor_model_id).name))


func has_sighted(actor_model_id: int) -> bool:
	return actor_model_id in _sightings


# Map & zones visits

func has_visited(map: Map) -> bool:
	return map in _visited_maps


func add_visit(_turn: int, map: Map) -> void:
	# NOTE: C# took a lock for thread safety ; the port is single-threaded.
	if map in _visited_maps:
		return
	_visited_maps.append(map)


# Dying : stuff to remember at death.

## k : can be null
func set_killer(k: Actor) -> void:
	killer = k


## z : can be null
func set_zombified_player(z: Actor) -> void:
	zombified_player = z


## Adds an actor that was a player follower at time of death.
func add_follower_when_died(fo: Actor) -> void:
	if followers_when_died == null:
		followers_when_died = []
	followers_when_died.append(fo)


# Misc events

func add_event(turn: int, text: String) -> void:
	# NOTE: C# took a lock for thread safety ; the port is single-threaded.
	_events.append(GameEventData.new(turn, text))


# Serialization (Godot-native save format).
# Replaces the C# [Serializable]/BinaryFormatter graph walk : plain state is
# saved field by field, references into the world graph (visited maps, killer,
# zombified player, followers) are saved as Session.map_ref()/Session.actor_ref()
# dictionaries and resolved by reconstruct_auxiliary_fields() once the World
# is loaded (same contract as Session).

## Pending world-graph references, filled by deserialize_data() and resolved by
## reconstruct_auxiliary_fields(). Not part of the C# original.
var _pending_visited_maps: Array = [] # of map ref Dictionary
var _pending_killer = null # actor ref Dictionary or null
var _pending_zombified_player = null # actor ref Dictionary or null
var _pending_followers_when_died = null # Array of actor ref Dictionary or null


func serialize() -> Dictionary:
	var data := {}
	data["start_scoring_turn"] = _start_scoring_turn
	data["reincarnation_number"] = _reincarnation_number
	data["completed_achievements_count"] = completed_achievements_count

	# Achievement definitions are rebuilt by _init(), only the IsDone flags
	# are saved.
	var done := {} # achievement id -> true
	for a: Achievement in achievements:
		if a != null and a.is_done:
			done[a.id] = true
	data["achievements_done"] = done

	data["starting_skill"] = starting_skill

	var events_data: Array = []
	for e: GameEventData in _events:
		events_data.append({"turn": e.turn, "text": e.text})
	data["events"] = events_data

	var kills_data: Array = []
	for id: int in _kills:
		var kd: KillData = _kills[id]
		kills_data.append({"actor_model_id": kd.actor_model_id, "amount": kd.amount, "first_kill_turn": kd.first_kill_turn})
	data["kills"] = kills_data

	data["sightings"] = _sightings.duplicate()

	var visited_maps_data: Array = []
	for map: Map in _visited_maps:
		var ref: Dictionary = Session.map_ref(map)
		if not ref.is_empty():
			visited_maps_data.append(ref)
	data["visited_maps"] = visited_maps_data

	data["turns_survived"] = turns_survived
	data["death_reason"] = death_reason
	data["death_place"] = death_place
	data["kill_points"] = _kill_points
	data["real_life_playing_time"] = real_life_playing_time
	data["difficulty_rating"] = _difficulty_rating
	data["side"] = _side

	data["killer"] = (Session.actor_ref(killer) as Variant) if killer != null else null
	data["zombified_player"] = (Session.actor_ref(zombified_player) as Variant) if zombified_player != null else null
	if followers_when_died != null:
		var followers_data: Array = []
		for fo: Actor in followers_when_died:
			var ref: Dictionary = Session.actor_ref(fo)
			if not ref.is_empty():
				followers_data.append(ref)
		data["followers_when_died"] = followers_data
	else:
		data["followers_when_died"] = null

	return data


## Restore a Scoring from serialize() data. The caller must then call
## reconstruct_auxiliary_fields(world) once the World graph is loaded.
static func deserialize_data(data: Dictionary) -> Scoring:
	var scoring := Scoring.new()

	scoring._start_scoring_turn = data.get("start_scoring_turn", 0)
	scoring._reincarnation_number = data.get("reincarnation_number", 0)
	scoring.completed_achievements_count = data.get("completed_achievements_count", 0)

	var done: Dictionary = data.get("achievements_done", {})
	for id: int in done:
		if id >= 0 && id < Achievement.IDs._COUNT && scoring.achievements[id] != null:
			scoring.achievements[id].is_done = true

	scoring.starting_skill = data.get("starting_skill", 0)

	scoring._events.clear()
	for e_data in data.get("events", []):
		scoring._events.append(GameEventData.new(e_data["turn"], e_data["text"]))

	scoring._kills.clear()
	for kd_data in data.get("kills", []):
		var kd := KillData.new(kd_data["actor_model_id"], kd_data["first_kill_turn"])
		kd.amount = kd_data["amount"]
		scoring._kills[kd.actor_model_id] = kd

	scoring._sightings.clear()
	for model_id in data.get("sightings", []):
		scoring._sightings.append(model_id)

	scoring._pending_visited_maps = data.get("visited_maps", []).duplicate()

	scoring.turns_survived = data.get("turns_survived", 0)
	scoring.death_reason = data.get("death_reason")
	scoring.death_place = data.get("death_place")
	scoring._kill_points = data.get("kill_points", 0)
	scoring.real_life_playing_time = data.get("real_life_playing_time", 0)
	scoring._difficulty_rating = data.get("difficulty_rating", 1.0)
	scoring._side = data.get("side", DifficultySide.FOR_SURVIVOR)

	scoring._pending_killer = data.get("killer")
	scoring._pending_zombified_player = data.get("zombified_player")
	scoring._pending_followers_when_died = data.get("followers_when_died")

	return scoring


## Resolve the world-graph references saved by serialize(). Must be called once
## the World is loaded (the C# BinaryFormatter resolved them during deserialization).
func reconstruct_auxiliary_fields(world: World) -> void:
	_visited_maps.clear()
	for ref in _pending_visited_maps:
		var map: Map = Session.map_from_ref(world, ref)
		if map != null:
			_visited_maps.append(map)
	_pending_visited_maps = []

	killer = null
	if _pending_killer != null:
		killer = Session.actor_from_ref(world, _pending_killer)
	_pending_killer = null

	zombified_player = null
	if _pending_zombified_player != null:
		zombified_player = Session.actor_from_ref(world, _pending_zombified_player)
	_pending_zombified_player = null

	followers_when_died = null
	if _pending_followers_when_died != null:
		followers_when_died = []
		for ref in _pending_followers_when_died:
			var fo: Actor = Session.actor_from_ref(world, ref)
			if fo != null:
				followers_when_died.append(fo)
	_pending_followers_when_died = null
