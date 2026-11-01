class_name ItemTrapModel
extends ItemModel
## Port of Engine/Items/ItemTrapModel.cs
## Static definition of a trap item kind.

## [Flags] enum Flags
const FLAG_NONE = 0
const FLAG_USE_TO_ACTIVATE = (1 << 0)
const FLAG_IS_NOISY = (1 << 1)
const FLAG_IS_ONE_TIME_USE = (1 << 2)
const FLAG_IS_FLAMMABLE = (1 << 3)
const FLAG_DROP_ACTIVATE = (1 << 4)

var _flags: int = FLAG_NONE
var trigger_chance: int
var damage: int
var break_chance: int
var break_chance_when_escape: int
var block_chance: int
var noise_name: String


func _init(p_single_name: String, p_plural_name: String, p_image_id: String, p_stack_limit: int,
		p_trigger_chance: int, p_damage: int,
		p_drop_activate: bool, p_use_to_activate: bool, p_is_one_time_use: bool,
		p_break_chance: int, p_block_chance: int, p_break_chance_when_escape: int,
		p_is_noisy: bool, p_noise_name: String, p_is_flammable: bool) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	dont_auto_equip = true

	if p_stack_limit > 1:
		is_stackable = true
		stacking_limit = p_stack_limit
	trigger_chance = p_trigger_chance
	damage = p_damage
	break_chance = p_break_chance
	block_chance = p_block_chance
	break_chance_when_escape = p_break_chance_when_escape
	_flags = FLAG_NONE
	if p_drop_activate:
		_flags |= FLAG_DROP_ACTIVATE
	if p_use_to_activate:
		_flags |= FLAG_USE_TO_ACTIVATE
	if p_is_noisy:
		_flags |= FLAG_IS_NOISY
		noise_name = p_noise_name
	if p_is_one_time_use:
		_flags |= FLAG_IS_ONE_TIME_USE
	if p_is_flammable:
		_flags |= FLAG_IS_FLAMMABLE


func use_to_activate() -> bool:
	return (_flags & FLAG_USE_TO_ACTIVATE) != 0


func is_noisy() -> bool:
	return (_flags & FLAG_IS_NOISY) != 0


func is_one_time_use() -> bool:
	return (_flags & FLAG_IS_ONE_TIME_USE) != 0


func is_flammable() -> bool:
	return (_flags & FLAG_IS_FLAMMABLE) != 0


func activates_when_dropped() -> bool:
	return (_flags & FLAG_DROP_ACTIVATE) != 0
