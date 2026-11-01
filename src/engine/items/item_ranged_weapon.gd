class_name ItemRangedWeapon
extends ItemWeapon
## Port of Engine/Items/ItemRangedWeapon.cs
## A concrete ranged weapon item instance; spawns fully loaded.

var ammo: int
var ammo_type: ItemAmmoModel.AmmoType


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemRangedWeaponModel, "model is not RangedWeaponModel")

	var m: ItemRangedWeaponModel = p_model
	ammo = m.max_ammo
	ammo_type = m.ammo_type


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["ammo"] = ammo
	d["ammo_type"] = ammo_type


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	ammo = d.get("ammo", ammo)
	ammo_type = d.get("ammo_type", ammo_type)
