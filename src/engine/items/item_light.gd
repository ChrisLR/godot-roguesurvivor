class_name ItemLight
extends Item
## Port of Engine/Items/ItemLight.cs
## A concrete light item instance with a battery charge.

var _batteries: int = 0


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemLightModel, "model is not a LightModel")

	# C# goes through the Batteries setter; set the backing field directly so
	# construction does not depend on the model database being up.
	_batteries = (p_model as ItemLightModel).max_batteries


var batteries: int:
	get:
		return _batteries
	set(value):
		if value < 0:
			value = 0
		_batteries = mini(value, (model as ItemLightModel).max_batteries)


var fov_bonus: int:
	get:
		return (model as ItemLightModel).fov_bonus


var is_fully_charged: bool:
	get:
		return _batteries >= (model as ItemLightModel).max_batteries


## Overridden: an equipped, charged light shows its normal image; anything
## else shows the "out of batteries" image.
func image_id() -> String:
	if is_equipped && batteries > 0:
		return model.image_id
	else:
		return (model as ItemLightModel).out_of_batteries_image_id


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["batteries"] = _batteries


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	_batteries = d.get("batteries", _batteries)
