class_name ItemAmmo
extends Item
## Port of Engine/Items/ItemAmmo.cs
## A concrete ammo item instance; spawns at full quantity.

var ammo_type: ItemAmmoModel.AmmoType


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemAmmoModel, "model is not a AmmoModel")

	var m: ItemAmmoModel = p_model
	ammo_type = m.ammo_type
	quantity = m.max_quantity()


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["ammo_type"] = ammo_type


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	ammo_type = d.get("ammo_type", ammo_type)
