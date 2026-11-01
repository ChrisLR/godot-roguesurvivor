class_name Location
extends RefCounted
## Port of Data/Location.cs
## C# struct -> GDScript reference class; operator== and operator+ are ported
## as equals() and plus().

var map: Map
var position: Vector2i


func _init(p_map: Map = null, p_position: Vector2i = Vector2i.ZERO) -> void:
	# C# default-struct Locations have a null map; the explicit ctor's
	# ArgumentNullException is covered by caller-side checks in the port.
	map = p_map
	position = p_position


## C# operator==.
func equals(other: Location) -> bool:
	return map == other.map and position == other.position


## C# operator+(Location, Direction).
func plus(dir: Direction) -> Location:
	return Location.new(map, position + dir.vector)


# --- save system ---
## Serialize a Location as a map reference + position.
static func serialize(loc: Location) -> Dictionary:
	if loc == null or loc.map == null:
		return {}
	var ref := Session.map_ref(loc.map)
	ref["x"] = loc.position.x
	ref["y"] = loc.position.y
	return ref


static func deserialize_data(world: World, data: Dictionary) -> Location:
	var loc := Location.new()
	if data != null and not data.is_empty():
		loc.map = Session.map_from_ref(world, data)
		loc.position = Vector2i(data.get("x", 0), data.get("y", 0))
	return loc
