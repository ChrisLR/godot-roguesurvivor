class_name ItemSprayPaintModel
extends ItemModel
## Port of Engine/Items/ItemSprayPaintModel.cs
## Static definition of a spray paint item kind.

var max_paint_quantity: int
var tag_image_id: String


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_paint_quantity: int, p_tag_image_id: String) -> void:
	assert(p_tag_image_id != null, "tagImageID")
	super._init(p_single_name, p_plural_name, p_image_id)
	max_paint_quantity = p_paint_quantity
	tag_image_id = p_tag_image_id
