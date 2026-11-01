class_name ItemGrenadeModel
extends ItemExplosiveModel
## Port of Engine/Items/ItemGrenadeModel.cs
## Static definition of a grenade item kind.

var max_throw_distance: int


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_fuse_delay: int, p_attack: BlastAttack, p_blast_image_id: String,
		p_max_throw_distance: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id, p_fuse_delay, p_attack, p_blast_image_id)
	max_throw_distance = p_max_throw_distance
