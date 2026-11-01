class_name Fortification
extends MapObject
## Port of Engine/MapObjects/Fortification.cs

# C# consts derived from DoorWindow.BASE_HITPOINTS; GDScript cannot use a
# cross-class reference in a const expression, so these are static vars.
static var SMALL_BASE_HITPOINTS: int = DoorWindow.BASE_HITPOINTS / 2
static var LARGE_BASE_HITPOINTS: int = DoorWindow.BASE_HITPOINTS


func _init(p_name: String, p_image_id: String, p_hit_points: int) -> void:
	super(p_name, p_image_id, Break.BREAKABLE, Fire.BURNABLE, p_hit_points)
