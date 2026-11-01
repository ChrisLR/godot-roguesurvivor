class_name ItemExplosive
extends Item
## Port of Engine/Items/ItemExplosive.cs
## A concrete explosive item instance; knows the model of its primed form.

var primed_model_id: int


func _init(p_model: ItemModel, p_primed_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemExplosiveModel, "model is not ItemExplosiveModel")

	primed_model_id = p_primed_model.id


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["primed_model_id"] = primed_model_id


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	primed_model_id = d.get("primed_model_id", primed_model_id)
