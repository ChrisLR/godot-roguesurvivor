class_name ItemWeapon
extends Item
## Port of Engine/Items/ItemWeapon.cs
## A concrete weapon item instance.


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemWeaponModel, "model is not a WeaponModel")
