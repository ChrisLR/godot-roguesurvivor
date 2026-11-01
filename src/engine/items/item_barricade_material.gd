class_name ItemBarricadeMaterial
extends Item
## Port of Engine/Items/ItemBarricadeMaterial.cs
## A concrete barricade material item instance.


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemBarricadeMaterialModel, "model is not BarricadeMaterialModel")
