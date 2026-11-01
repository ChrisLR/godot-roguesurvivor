class_name ItemMedicineModel
extends ItemModel
## Port of Engine/Items/ItemMedicineModel.cs
## Static definition of a medicine item kind.

var healing: int
var stamina_boost: int
var sleep_boost: int
var infection_cure: int
var sanity_cure: int


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_healing: int, p_stamina_boost: int, p_sleep_boost: int,
		p_infection_cure: int, p_sanity_cure: int) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	healing = p_healing
	stamina_boost = p_stamina_boost
	sleep_boost = p_sleep_boost
	infection_cure = p_infection_cure
	sanity_cure = p_sanity_cure
