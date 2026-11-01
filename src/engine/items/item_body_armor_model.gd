class_name ItemBodyArmorModel
extends ItemModel
## Port of Engine/Items/ItemBodyArmorModel.cs
## Static definition of a body armor item kind.

var protection_hit: int
var protection_shot: int
var encumbrance: int
var weight: int


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_protection_hit: int, p_protection_shot: int, p_encumbrance: int,
		p_weight: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	protection_hit = p_protection_hit
	protection_shot = p_protection_shot
	encumbrance = p_encumbrance
	weight = p_weight


func to_defence() -> Defence:
	return Defence.new(-encumbrance, protection_hit, protection_shot)
