class_name ItemBarricadeMaterialModel
extends ItemModel
## Port of Engine/Items/ItemBarricadeMaterialModel.cs
## Static definition of a barricade material item kind.

var barricading_value: int


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_barricading_value: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	barricading_value = p_barricading_value
