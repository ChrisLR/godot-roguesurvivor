class_name Zone
extends RefCounted
## Port of Data/Zone.cs

var name: String = "unnamed zone"
var bounds: Rect2i
var attributes: Dictionary = {}


func _init(p_name: String, p_bounds: Rect2i) -> void:
	assert(p_name != null, "name")

	name = p_name
	bounds = p_bounds


## C# HasGameAttribute(key).
func has_game_attribute(key: String) -> bool:
	return attributes.has(key)


## C# SetGameAttribute<_T_>(key, value); generics dropped, value is a Variant.
func set_game_attribute(key: String, value) -> void:
	attributes[key] = value


## C# GetGameAttribute<_T_>(key); generics dropped, returns null when unset
## (the C# default(_T_) equivalent for reference types).
func get_game_attribute(key: String):
	var value = attributes.get(key)
	if value == null:
		return null
	return value


# --- save system ---
func serialize() -> Dictionary:
	return {"name": name, "bounds": bounds, "attributes": attributes}


static func deserialize_data(data: Dictionary) -> Zone:
	var z := Zone.new(data.get("name", "unnamed zone"), data.get("bounds", Rect2i()))
	z.attributes = data.get("attributes", {})
	return z
