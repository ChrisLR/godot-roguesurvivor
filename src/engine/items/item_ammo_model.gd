class_name ItemAmmoModel
extends ItemModel
## Port of Engine/Items/ItemAmmoModel.cs
## Static definition of an ammo item kind.
##
## The C# source declares AmmoType at namespace level; in GDScript it is a
## named enum on this class (call sites: ItemAmmoModel.AmmoType.XXX).

enum AmmoType {
	_FIRST = 0,

	LIGHT_PISTOL = 0,
	HEAVY_PISTOL,
	SHOTGUN,
	LIGHT_RIFLE,
	HEAVY_RIFLE,
	BOLT,

	_COUNT,
}

var ammo_type: AmmoType


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_ammo_type: AmmoType, p_max_quantity: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	ammo_type = p_ammo_type
	is_stackable = true
	stacking_limit = p_max_quantity


func max_quantity() -> int:
	return stacking_limit
