class_name ItemPrimedExplosive
extends ItemExplosive
## Port of Engine/Items/ItemPrimedExplosive.cs
## A concrete explosive item instance with its fuse burning.

var fuse_time_left: int


func _init(p_model: ItemModel) -> void:
	super._init(p_model, p_model)
	assert(p_model is ItemExplosiveModel, "model is not ItemExplosiveModel")

	fuse_time_left = (p_model as ItemExplosiveModel).fuse_delay


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	super._serialize_fields(d)
	d["fuse_time_left"] = fuse_time_left


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	fuse_time_left = d.get("fuse_time_left", fuse_time_left)
