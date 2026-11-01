class_name ItemSprayScentModel
extends ItemModel
## Port of Engine/Items/ItemSprayScentModel.cs
## Static definition of a scent spray item kind.

var max_spray_quantity: int
var odor: int  # Odor enum value
var strength: int


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_spray_quantity: int, p_odor: int, p_strength: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	max_spray_quantity = p_spray_quantity
	odor = p_odor
	strength = p_strength
