class_name ItemRangedWeaponModel
extends ItemWeaponModel
## Port of Engine/Items/ItemRangedWeaponModel.cs
## Static definition of a ranged weapon item kind.
##
## The C# namespace-level AmmoType enum lives in ItemAmmoModel (Engine/Items/ItemAmmoModel.cs);
## call it as ItemAmmoModel.AmmoType.

var max_ammo: int
var ammo_type: ItemAmmoModel.AmmoType


func _init(p_single_name: String, p_plural_name: String, p_image_id: String, p_attack: Attack,
		p_max_ammo: int, p_ammo_type: ItemAmmoModel.AmmoType) -> void:
	super._init(p_single_name, p_plural_name, p_image_id, p_attack)
	max_ammo = p_max_ammo
	ammo_type = p_ammo_type


func is_firearm() -> bool:
	return attack.kind == Attack.AttackKind.FIREARM


func is_bow() -> bool:
	return attack.kind == Attack.AttackKind.BOW


# alpha10
func rapid_fire_hit1_value() -> int:
	return attack.hit2_value


func rapid_fire_hit2_value() -> int:
	return attack.hit3_value
