class_name Keybindings
extends RefCounted
## Port of Engine/Keybindings.cs
##
## Bindings are packed ints: Godot Key | KeyModifierMask bits, mirroring the
## C# Keys flags enum. Save/load uses user:// (original used BinaryFormatter).

# Keys.Shift / Keys.Control equivalents.
const SHIFT := KEY_MASK_SHIFT
const CTRL := KEY_MASK_CTRL

var _command_to_key: Dictionary = {}  # Command -> packed int
var _key_to_command: Dictionary = {}  # packed int -> Command


func _init() -> void:
	reset_to_defaults()


func reset_to_defaults() -> void:
	_command_to_key.clear()
	_key_to_command.clear()

	set_binding(PlayerCommand.Command.BARRICADE_MODE, KEY_B)
	set_binding(PlayerCommand.Command.BREAK_MODE, KEY_K)
	set_binding(PlayerCommand.Command.CLOSE_DOOR, KEY_C)
	set_binding(PlayerCommand.Command.FIRE_MODE, KEY_F)
	set_binding(PlayerCommand.Command.HELP_MODE, KEY_H)
	set_binding(PlayerCommand.Command.KEYBINDING_MODE, KEY_K | SHIFT)

	set_binding(PlayerCommand.Command.ITEM_SLOT_0, KEY_1)
	set_binding(PlayerCommand.Command.ITEM_SLOT_1, KEY_2)
	set_binding(PlayerCommand.Command.ITEM_SLOT_2, KEY_3)
	set_binding(PlayerCommand.Command.ITEM_SLOT_3, KEY_4)
	set_binding(PlayerCommand.Command.ITEM_SLOT_4, KEY_5)
	set_binding(PlayerCommand.Command.ITEM_SLOT_5, KEY_6)
	set_binding(PlayerCommand.Command.ITEM_SLOT_6, KEY_7)
	set_binding(PlayerCommand.Command.ITEM_SLOT_7, KEY_8)
	set_binding(PlayerCommand.Command.ITEM_SLOT_8, KEY_9)
	set_binding(PlayerCommand.Command.ITEM_SLOT_9, KEY_0)

	set_binding(PlayerCommand.Command.ABANDON_GAME, KEY_A | SHIFT)
	set_binding(PlayerCommand.Command.ADVISOR, KEY_H | SHIFT)
	set_binding(PlayerCommand.Command.BUILD_LARGE_FORTIFICATION, KEY_N | CTRL)
	set_binding(PlayerCommand.Command.BUILD_SMALL_FORTIFICATION, KEY_N)
	set_binding(PlayerCommand.Command.CITY_INFO, KEY_I)
	set_binding(PlayerCommand.Command.EAT_CORPSE, KEY_E | SHIFT)
	set_binding(PlayerCommand.Command.GIVE_ITEM, KEY_G)
	set_binding(PlayerCommand.Command.HINTS_SCREEN_MODE, KEY_H | CTRL)
	set_binding(PlayerCommand.Command.NEGOCIATE_TRADE, KEY_E)
	set_binding(PlayerCommand.Command.LOAD_GAME, KEY_L | SHIFT)
	set_binding(PlayerCommand.Command.MARK_ENEMIES_MODE, KEY_E | CTRL)
	set_binding(PlayerCommand.Command.MESSAGE_LOG, KEY_M | SHIFT)
	set_binding(PlayerCommand.Command.MOVE_E, KEY_KP_6)
	set_binding(PlayerCommand.Command.MOVE_N, KEY_KP_8)
	set_binding(PlayerCommand.Command.MOVE_NE, KEY_KP_9)
	set_binding(PlayerCommand.Command.MOVE_NW, KEY_KP_7)
	set_binding(PlayerCommand.Command.MOVE_S, KEY_KP_2)
	set_binding(PlayerCommand.Command.MOVE_SE, KEY_KP_3)
	set_binding(PlayerCommand.Command.MOVE_SW, KEY_KP_1)
	set_binding(PlayerCommand.Command.MOVE_W, KEY_KP_4)
	set_binding(PlayerCommand.Command.OPTIONS_MODE, KEY_O | SHIFT)
	set_binding(PlayerCommand.Command.ORDER_MODE, KEY_O)
	set_binding(PlayerCommand.Command.PULL_MODE, KEY_P | CTRL)  # alpha10
	set_binding(PlayerCommand.Command.PUSH_MODE, KEY_P)
	set_binding(PlayerCommand.Command.QUIT_GAME, KEY_Q | SHIFT)
	set_binding(PlayerCommand.Command.REVIVE_CORPSE, KEY_R | SHIFT)
	set_binding(PlayerCommand.Command.RUN_TOGGLE, KEY_R)
	set_binding(PlayerCommand.Command.SAVE_GAME, KEY_S | SHIFT)
	set_binding(PlayerCommand.Command.SCREENSHOT, KEY_N | SHIFT)
	set_binding(PlayerCommand.Command.SHOUT, KEY_S)
	set_binding(PlayerCommand.Command.SLEEP, KEY_Z)
	set_binding(PlayerCommand.Command.SWITCH_PLACE, KEY_S | CTRL)
	set_binding(PlayerCommand.Command.LEAD_MODE, KEY_T)
	set_binding(PlayerCommand.Command.USE_SPRAY, KEY_A)
	set_binding(PlayerCommand.Command.USE_EXIT, KEY_X)
	set_binding(PlayerCommand.Command.WAIT_OR_SELF, KEY_KP_5)
	set_binding(PlayerCommand.Command.WAIT_LONG, KEY_W)


# Getting & Setting
func get_key(command: PlayerCommand.Command) -> int:
	# Get KeyData (key code & modifiers).
	if _command_to_key.has(command):
		return _command_to_key[command]
	return KEY_NONE


func get_command(key: int) -> PlayerCommand.Command:
	# key is KeyData (key code & modifiers).
	if _key_to_command.has(key):
		return _key_to_command[key]
	return PlayerCommand.Command.NONE


func set_binding(command: PlayerCommand.Command, key: int) -> void:
	# remove previous bind.
	var prev_command: PlayerCommand.Command = get_command(key)
	if prev_command != PlayerCommand.Command.NONE:
		_command_to_key.erase(prev_command)
	var prev_key: int = get_key(command)
	if prev_key != KEY_NONE:
		_key_to_command.erase(prev_key)

	# rebind.
	_command_to_key[command] = key
	_key_to_command[key] = command


# Checking for keys conflict
func check_for_conflict() -> bool:
	for key: int in _command_to_key.values():
		var bound := 0
		for k: int in _key_to_command.keys():
			if k == key:
				bound += 1
		if bound > 1:
			return true
	return false


# Saving & Loading
const SAVE_PATH := "user://keybindings.dat"


func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("failed to save keybindings")
		return
	f.store_var(_command_to_key)
	f.store_var(_key_to_command)
	f.close()


## Attempt to load; on failure return bindings with defaults.
static func load_bindings() -> Keybindings:
	var kb := Keybindings.new()
	if not FileAccess.file_exists(SAVE_PATH):
		return kb
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return kb
	var cmd_to_key: Dictionary = f.get_var()
	var key_to_cmd: Dictionary = f.get_var()
	f.close()
	if cmd_to_key is Dictionary and key_to_cmd is Dictionary:
		kb._command_to_key = cmd_to_key
		kb._key_to_command = key_to_cmd
	return kb
