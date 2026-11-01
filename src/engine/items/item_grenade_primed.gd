class_name ItemGrenadePrimed
extends ItemPrimedExplosive
## Port of Engine/Items/ItemGrenadePrimed.cs
## A concrete primed grenade item instance.


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemGrenadePrimedModel, "model is not ItemGrenadePrimedModel")
