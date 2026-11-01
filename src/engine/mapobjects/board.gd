class_name Board
extends MapObject
## Port of Engine/MapObjects/Board.cs

var text: PackedStringArray


func _init(p_name: String, p_image_id: String, p_text: PackedStringArray) -> void:
	super(p_name, p_image_id)
	text = p_text


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["text"] = text


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	text = d.get("text", text)
