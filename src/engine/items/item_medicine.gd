class_name ItemMedicine
extends Item
## Port of Engine/Items/ItemMedicine.cs
## A concrete medicine item instance.

var healing: int
var stamina_boost: int
var sleep_boost: int
var infection_cure: int
var sanity_cure: int


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemMedicineModel, "model is not a MedecineModel")

	var m: ItemMedicineModel = p_model
	healing = m.healing
	stamina_boost = m.stamina_boost
	sleep_boost = m.sleep_boost
	infection_cure = m.infection_cure
	sanity_cure = m.sanity_cure


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["healing"] = healing
	d["stamina_boost"] = stamina_boost
	d["sleep_boost"] = sleep_boost
	d["infection_cure"] = infection_cure
	d["sanity_cure"] = sanity_cure


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	healing = d.get("healing", healing)
	stamina_boost = d.get("stamina_boost", stamina_boost)
	sleep_boost = d.get("sleep_boost", sleep_boost)
	infection_cure = d.get("infection_cure", infection_cure)
	sanity_cure = d.get("sanity_cure", sanity_cure)
