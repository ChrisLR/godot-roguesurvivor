class_name ItemMeleeWeapon
extends ItemWeapon
## Port of Engine/Items/ItemMeleeWeapon.cs
## A concrete melee weapon item instance.


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemMeleeWeaponModel, "model is not a MeleeWeaponModel")


func is_fragile() -> bool:
	return (model as ItemMeleeWeaponModel).is_fragile


# alpha10
func tool_bash_damage_bonus() -> int:
	return (model as ItemMeleeWeaponModel).tool_bash_damage_bonus


func tool_build_bonus() -> float:
	return (model as ItemMeleeWeaponModel).tool_build_bonus


func is_tool() -> bool:
	return (model as ItemMeleeWeaponModel).is_tool()
