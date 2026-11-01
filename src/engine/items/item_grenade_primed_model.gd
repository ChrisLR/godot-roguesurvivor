class_name ItemGrenadePrimedModel
extends ItemExplosiveModel
## Port of Engine/Items/ItemGrenadePrimedModel.cs
## Static definition of a primed grenade item kind; shares the un-primed
## grenade's fuse, blast attack and blast image.

var grenade_model: ItemGrenadeModel


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_grenade_model: ItemGrenadeModel) -> void:
	assert(p_grenade_model != null, "grenadeModel")
	super._init(p_single_name, p_plural_name, p_image_id,
			p_grenade_model.fuse_delay, p_grenade_model.blast_attack, p_grenade_model.blast_image_id)
	grenade_model = p_grenade_model
