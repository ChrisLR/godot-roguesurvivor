class_name ItemSprayPaint
extends Item
## Port of Engine/Items/ItemSprayPaint.cs
## A concrete spray paint item instance; spawns full of paint.

var paint_quantity: int


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemSprayPaintModel, "model is not a SprayPaintModel")

	paint_quantity = (p_model as ItemSprayPaintModel).max_paint_quantity


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["paint_quantity"] = paint_quantity


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	paint_quantity = d.get("paint_quantity", paint_quantity)
