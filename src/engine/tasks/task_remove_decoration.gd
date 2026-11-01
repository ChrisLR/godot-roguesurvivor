class_name TaskRemoveDecoration
extends TimedTask
## Port of Engine/Tasks/TaskRemoveDecoration.cs

var x: int
var y: int
var image_id: String


func _init(p_turns: int, p_x: int, p_y: int, p_image_id: String) -> void:
	super(p_turns)
	x = p_x
	y = p_y
	image_id = p_image_id


func trigger(m: Map) -> void:
	m.get_tile_at(x, y).remove_decoration(image_id)


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["x"] = x
	d["y"] = y
	d["image_id"] = image_id


static func deserialize_data(data: Dictionary) -> TaskRemoveDecoration:
	return TaskRemoveDecoration.new(data.get("turns_left", 0), data.get("x", 0),
		data.get("y", 0), data.get("image_id", ""))
