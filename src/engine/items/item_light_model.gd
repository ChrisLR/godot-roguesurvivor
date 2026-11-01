class_name ItemLightModel
extends ItemModel
## Port of Engine/Items/ItemLightModel.cs
## Static definition of a light item kind.

var max_batteries: int
var fov_bonus: int
var out_of_batteries_image_id: String


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_fov_bonus: int, p_max_batteries: int, p_out_of_batteries_image_id: String) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	fov_bonus = p_fov_bonus
	max_batteries = p_max_batteries
	out_of_batteries_image_id = p_out_of_batteries_image_id
	dont_auto_equip = true
