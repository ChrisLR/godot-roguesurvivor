class_name ItemSprayScent
extends Item
## Port of Engine/Items/ItemSprayScent.cs
## A concrete scent spray item instance; spawns full.

var spray_quantity: int


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemSprayScentModel, "model is not a ItemScentSprayModel")

	spray_quantity = (p_model as ItemSprayScentModel).max_spray_quantity


# alpha10
func odor() -> int:
	return (model as ItemSprayScentModel).odor


func strength() -> int:
	return (model as ItemSprayScentModel).strength


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["spray_quantity"] = spray_quantity


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	spray_quantity = d.get("spray_quantity", spray_quantity)
