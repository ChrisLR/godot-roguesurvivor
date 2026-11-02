class_name ItemFood
extends Item
## Port of Engine/Items/ItemFood.cs
## A concrete food item instance.

var nutrition: int
var is_perishable: bool = false
var best_before: WorldTime = null


## Not perishable.
func _init(p_model: ItemModel, p_best_before: int = -1) -> void:
	super._init(p_model)
	assert(p_model is ItemFoodModel, "model is not a FoodModel")

	nutrition = (p_model as ItemFoodModel).nutrition
	if p_best_before >= 0:
		# Perishable food.
		best_before = WorldTime.new(p_best_before)
		is_perishable = true
	else:
		is_perishable = false


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["nutrition"] = nutrition
	d["is_perishable"] = is_perishable
	d["best_before"] = (best_before.serialize() as Variant) if best_before != null else null


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	nutrition = d.get("nutrition", nutrition)
	is_perishable = d.get("is_perishable", is_perishable)
	var bb = d.get("best_before", null)
	best_before = WorldTime.deserialize_data(bb) if bb != null else null
