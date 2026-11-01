class_name Abilities
extends RefCounted
## Port of Data/Abilities.cs
## Per-model actor capability flags (undead traits, movement, item use, AI flags).

## Blank abilities.
static var NONE: Abilities = Abilities.new()

var is_undead: bool = false
var is_undead_master: bool = false
var can_zombify_killed: bool = false
var can_tire: bool = false
var has_to_eat: bool = false
var has_to_sleep: bool = false
var has_sanity: bool = false
var can_run: bool = false
var can_talk: bool = false
var can_use_map_objects: bool = false
var can_bash_doors: bool = false
var can_break_objects: bool = false
var can_jump: bool = false
var is_small: bool = false
var has_inventory: bool = false
var can_use_items: bool = false
var can_trade: bool = false
var can_barricade: bool = false
var can_push: bool = false
var can_jump_stumble: bool = false
var is_law_enforcer: bool = false
var is_intelligent: bool = false
var is_rotting: bool = false
# alpha10
var can_disarm: bool = false
# AI flag: tell some AIs it can use Exits with flag Exit.IsAnAIExit.
var ai_can_use_ai_exits: bool = false
# AI flag: ranged weapons are not interesting items.
var ai_not_interested_in_ranged_weapons: bool = false
# AI flag: tell some AIs to use the explore behavior.
var zombie_ai_explore: bool = false


# alpha10: CanDisarm by default.
func _init() -> void:
	can_disarm = true


# --- save system ---
func serialize() -> Dictionary:
	return Session.serialize_scalar_vars(self)


static func deserialize_data(data: Dictionary) -> Abilities:
	var a := Abilities.new()
	Session.apply_scalar_vars(a, data)
	return a
