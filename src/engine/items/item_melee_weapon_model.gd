class_name ItemMeleeWeaponModel
extends ItemWeaponModel
## Port of Engine/Items/ItemMeleeWeaponModel.cs
## Static definition of a melee weapon item kind.

var is_fragile: bool = false

# alpha10
var tool_bash_damage_bonus: int = 0
var tool_build_bonus: float = 0.0


func _init(p_single_name: String, p_plural_name: String, p_image_id: String, p_attack: Attack) -> void:
	super._init(p_single_name, p_plural_name, p_image_id, p_attack)


func is_tool() -> bool:
	return tool_bash_damage_bonus != 0 || tool_build_bonus != 0.0
