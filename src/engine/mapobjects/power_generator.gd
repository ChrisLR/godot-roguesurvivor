class_name PowerGenerator
extends StateMapObject
## Port of Engine/MapObjects/PowerGenerator.cs

const STATE_OFF := 0
const STATE_ON := 1

var _off_image_id: String
var _on_image_id: String


var is_on: bool:
	get:
		return state == STATE_ON


func _init(p_name: String, p_off_image_id: String, p_on_image_id: String) -> void:
	super(p_name, p_off_image_id)
	_off_image_id = p_off_image_id
	_on_image_id = p_on_image_id


func set_state(new_state: int) -> void:
	super(new_state)

	match new_state:
		STATE_OFF:
			image_id = _off_image_id
		STATE_ON:
			image_id = _on_image_id
		_:
			push_error("unhandled state")
			assert(false, "unhandled state")


func toggle_power() -> void:
	set_state(STATE_ON if state == STATE_OFF else STATE_OFF)


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	super._serialize_fields(d)
	d["off_image_id"] = _off_image_id
	d["on_image_id"] = _on_image_id


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	_off_image_id = d.get("off_image_id", _off_image_id)
	_on_image_id = d.get("on_image_id", _on_image_id)
