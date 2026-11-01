class_name ItemFoodModel
extends ItemModel
## Port of Engine/Items/ItemFoodModel.cs
## Static definition of a food item kind.

var nutrition: int
var is_perishable: bool = false
var best_before_days: int = 0


## best_before_days: -1 for non perishable food.
func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_nutrition: int, p_best_before_days: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	nutrition = p_nutrition
	if p_best_before_days < 0:
		is_perishable = false
	else:
		is_perishable = true
		best_before_days = p_best_before_days
