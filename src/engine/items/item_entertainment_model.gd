class_name ItemEntertainmentModel
extends ItemModel
## Port of Engine/Items/ItemEntertainmentModel.cs
## Static definition of an entertainment item kind.

var value: int
var bore_chance: int


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_value: int, p_bore_chance: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	value = p_value
	bore_chance = p_bore_chance
