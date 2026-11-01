class_name ItemExplosiveModel
extends ItemModel
## Port of Engine/Items/ItemExplosiveModel.cs
## Static definition of an explosive item kind.

var fuse_delay: int
var blast_attack: BlastAttack
var blast_image_id: String


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_fuse_delay: int, p_attack: BlastAttack, p_blast_image_id: String) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	fuse_delay = p_fuse_delay
	blast_attack = p_attack
	blast_image_id = p_blast_image_id
