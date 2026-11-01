class_name ItemModel
extends RefCounted
## Port of Data/ItemModel.cs
## Static definition of an item kind (the "prototype"; runtime items are Item).

var id: int = 0
var single_name: String
var plural_name: String
var is_plural: bool = false
var is_an: bool = false
var is_proper: bool = false
var image_id: String
var flavor_description: String = ""
var is_stackable: bool = false
var stacking_limit: int = 0
var equipment_part: int = Doll.DollPart.NONE  # DollPart
var dont_auto_equip: bool = false
var is_unbreakable: bool = false


func _init(p_single_name: String, p_plural_name: String, p_image_id: String) -> void:
	single_name = p_single_name
	plural_name = p_plural_name
	image_id = p_image_id


func is_equipable() -> bool:
	return equipment_part != Doll.DollPart.NONE
