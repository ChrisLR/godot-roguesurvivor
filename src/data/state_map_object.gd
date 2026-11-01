class_name StateMapObject
extends MapObject
## Port of Data/StateMapObject.cs
## MapObject with a game-defined integer state.

var state: int = 0


## C# has two constructors; MapObject's GDScript constructor takes the same
## optional trailing arguments.
func _init(p_name: String, p_hidden_image_id: String, p_breakable: Break = Break.UNBREAKABLE,
		p_burnable: Fire = Fire.UNINFLAMMABLE, p_hit_points: int = 0) -> void:
	super(p_name, p_hidden_image_id, p_breakable, p_burnable, p_hit_points)


func set_state(new_state: int) -> void:
	state = new_state


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["state"] = state


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	state = d.get("state", state)
