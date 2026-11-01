class_name ItemWeaponModel
extends ItemModel
## Port of Engine/Items/ItemWeaponModel.cs
## Static definition of a weapon item kind.

var attack: Attack


func _init(p_single_name: String, p_plural_name: String, p_image_id: String, p_attack: Attack) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	attack = p_attack
