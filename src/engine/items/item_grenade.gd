class_name ItemGrenade
extends ItemExplosive
## Port of Engine/Items/ItemGrenade.cs
## A concrete grenade item instance.


func _init(p_model: ItemModel, p_primed_model: ItemModel) -> void:
	super._init(p_model, p_primed_model)
	assert(p_model is ItemGrenadeModel, "model is not ItemGrenadeModel")
