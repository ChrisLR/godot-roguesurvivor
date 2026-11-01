class_name GameHintsStatus
extends RefCounted
## Port of Engine/GameHintsStatus (from GameHints.cs ; the file only
## contains this class, there is no GameHints class).
##
## NOTE: in C# the AdvisorHint enum lives in Session.cs. Session is not
## ported yet, so the enum is defined here to keep this file usable
## standalone; when Session is ported it can reference this one or
## declare its own copy.

## Port of Session.cs enum AdvisorHint.
enum AdvisorHint {
	_FIRST = 0,
	MOVE_BASIC = _FIRST,
	MOUSE_LOOK,
	KEYS_OPTIONS,
	NIGHT,
	RAIN,
	ACTOR_MELEE,
	MOVE_RUN,
	MOVE_RESTING,
	MOVE_JUMP,
	ITEM_GRAB_CONTAINER,
	ITEM_GRAB_FLOOR,
	ITEM_UNEQUIP,
	ITEM_EQUIP,
	ITEM_TYPE_BARRICADING,
	ITEM_DROP,
	ITEM_USE,
	FLASHLIGHT,
	CELLPHONES,
	SPRAYS_PAINT,
	SPRAYS_SCENT,
	WEAPON_FIRE,
	WEAPON_RELOAD,
	GRENADE,
	DOORWINDOW_OPEN,
	DOORWINDOW_CLOSE,
	OBJECT_PUSH,
	OBJECT_BREAK,
	BARRICADE,
	EXIT_STAIRS_LADDERS,
	EXIT_LEAVING_DISTRICT,
	STATE_SLEEPY,
	STATE_HUNGRY,
	NPC_TRADE,
	NPC_GIVING_ITEM,
	NPC_SHOUTING,
	BUILD_FORTIFICATION,
	LEADING_NEED_SKILL,
	LEADING_CAN_RECRUIT,
	LEADING_GIVE_ORDERS,
	LEADING_SWITCH_PLACE,
	GAME_SAVE_LOAD,
	CITY_INFORMATION,
	CORPSE,
	CORPSE_EAT,
	SANITY,
	INFECTION,
	TRAPS,
	_COUNT,
}


var _advisor_hints: Array = []


func _init() -> void:
	_advisor_hints.resize(AdvisorHint._COUNT)
	_advisor_hints.fill(false)


# Status

func reset_all_hints() -> void:
	for i: int in range(AdvisorHint._FIRST, AdvisorHint._COUNT):
		_advisor_hints[i] = false


func is_advisor_hint_given(hint: int) -> bool:
	return _advisor_hints[hint]


func set_advisor_hint_as_given(hint: int) -> void:
	_advisor_hints[hint] = true


func count_advisor_hints_given() -> int:
	var count := 0
	for i: int in range(AdvisorHint._FIRST, AdvisorHint._COUNT):
		if _advisor_hints[i]:
			count += 1
	return count


func has_advisor_given_all_hints() -> bool:
	return count_advisor_hints_given() >= AdvisorHint._COUNT


# Saving & Loading (Godot-native serialization instead of BinaryFormatter)

static func save(hints, filepath: String) -> bool:
	if filepath == null:
		push_error("saving hints : null filepath")
		return false

	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("saving hints exception: %s (%s)" % [filepath, FileAccess.get_open_error()])
		return false

	file.store_var(hints._advisor_hints)
	file.close()
	return true


## Try to load, returns a fresh reset status if failed (first run?).
static func load_file(filepath: String):
	if filepath == null:
		push_error("loading hints : null filepath")
		return null

	var hints = null
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_warning("failed to load hints (first run?): %s (%s)" % [filepath, FileAccess.get_open_error()])
	else:
		var data = file.get_var()
		file.close()
		if data is Array && data.size() == AdvisorHint._COUNT:
			hints = GameHintsStatus.new()
			hints._advisor_hints = data
		else:
			push_warning("failed to load hints, bad data. resetting.")

	if hints == null:
		hints = GameHintsStatus.new()
		hints.reset_all_hints()
	return hints
