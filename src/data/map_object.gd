class_name MapObject
extends RefCounted
## Port of Data/MapObject.cs
## Base class for map objects (furniture, props...).

enum Break {
	UNBREAKABLE,
	BREAKABLE,
	BROKEN,
}

enum Fire {
	UNINFLAMMABLE,
	BURNABLE,
	ONFIRE,
	ASHES,
}

# [Flags] enum Flags
const FLAG_NONE = 0
const FLAG_IS_AN = (1 << 0)
const FLAG_IS_PLURAL = (1 << 1)
const FLAG_IS_MATERIAL_TRANSPARENT = (1 << 2)
const FLAG_IS_WALKABLE = (1 << 3)
const FLAG_IS_CONTAINER = (1 << 4)
const FLAG_IS_COUCH = (1 << 5)
const FLAG_GIVES_WOOD = (1 << 6)
const FLAG_IS_MOVABLE = (1 << 7)
const FLAG_BREAKS_WHEN_FIRED_THROUGH = (1 << 8)
const FLAG_STANDON_FOV_BONUS = (1 << 9)

var image_id: String
var hidden_image_id: String
var name: String

var _flags: int = FLAG_NONE

var _weight: int = 0

var jump_level: int = 0

var break_state: Break = Break.UNBREAKABLE
var max_hit_points: int = 0
var hit_points: int = 0

var fire_state: Fire = Fire.UNINFLAMMABLE

var location: Location


var a_name: String:
	get:
		return ("an " if is_an else "some " if is_plural else "a ") + name


var the_name: String:
	get:
		return "the " + name


var is_an: bool:
	get:
		return _get_flag(FLAG_IS_AN)
	set(value):
		_set_flag(FLAG_IS_AN, value)


var is_plural: bool:
	get:
		return _get_flag(FLAG_IS_PLURAL)
	set(value):
		_set_flag(FLAG_IS_PLURAL, value)


# C# virtual property -> method so subclasses can override.
func is_transparent() -> bool:
	if fire_state == Fire.ONFIRE:
		return false
	if break_state == Break.BROKEN:
		return true
	if fire_state == Fire.ASHES:
		return true

	return _get_flag(FLAG_IS_MATERIAL_TRANSPARENT)


var is_material_transparent: bool:
	get:
		return _get_flag(FLAG_IS_MATERIAL_TRANSPARENT)
	set(value):
		_set_flag(FLAG_IS_MATERIAL_TRANSPARENT, value)


var is_walkable: bool:
	get:
		return _get_flag(FLAG_IS_WALKABLE)
	set(value):
		_set_flag(FLAG_IS_WALKABLE, value)


## Gets if object are walkable by actors with the CanJump ability.
var is_jumpable: bool:
	get:
		return jump_level > 0


## Gets or sets if the object behaves as a container : an actor bumping into
## the object will pickup items stacked there.
var is_container: bool:
	get:
		return _get_flag(FLAG_IS_CONTAINER)
	set(value):
		_set_flag(FLAG_IS_CONTAINER, value)


var is_couch: bool:
	get:
		return _get_flag(FLAG_IS_COUCH)
	set(value):
		_set_flag(FLAG_IS_COUCH, value)


var is_breakable: bool:
	get:
		return break_state == Break.BREAKABLE


var gives_wood: bool:
	get:
		return _get_flag(FLAG_GIVES_WOOD) && break_state != Break.BROKEN
	set(value):
		_set_flag(FLAG_GIVES_WOOD, value)


var is_movable: bool:
	get:
		return _get_flag(FLAG_IS_MOVABLE)
	set(value):
		_set_flag(FLAG_IS_MOVABLE, value)


var breaks_when_fired_through: bool:
	get:
		return _get_flag(FLAG_BREAKS_WHEN_FIRED_THROUGH)
	set(value):
		_set_flag(FLAG_BREAKS_WHEN_FIRED_THROUGH, value)


var stand_on_fov_bonus: bool:
	get:
		return _get_flag(FLAG_STANDON_FOV_BONUS)
	set(value):
		_set_flag(FLAG_STANDON_FOV_BONUS, value)


var weight: int:
	get:
		return _weight
	set(value):
		_weight = max(1, value)


var is_flammable: bool:
	get:
		return fire_state == Fire.ONFIRE || fire_state == Fire.BURNABLE


var is_on_fire: bool:
	get:
		return fire_state == Fire.ONFIRE


var is_burnt_to_ashes: bool:
	get:
		return fire_state == Fire.ASHES


func _init(p_name: String, p_hidden_image_id: String, p_breakable: Break = Break.UNBREAKABLE, p_burnable: Fire = Fire.UNINFLAMMABLE, p_hit_points: int = 0) -> void:
	assert(p_name != null, "aName")
	assert(p_hidden_image_id != null, "hiddenImageID")

	name = p_name
	image_id = p_hidden_image_id
	hidden_image_id = p_hidden_image_id
	break_state = p_breakable
	fire_state = p_burnable
	if p_breakable != Break.UNBREAKABLE || p_burnable != Fire.UNINFLAMMABLE:
		hit_points = p_hit_points
		max_hit_points = p_hit_points


# Flags helpers

func _get_flag(f: int) -> bool:
	return (_flags & f) != 0


func _set_flag(f: int, value: bool) -> void:
	if value:
		_flags |= f
	else:
		_flags &= ~f


# --- save system ---
## Pending world-graph references, resolved by resolve_refs() after the whole
## world graph has been deserialized. In-memory only, never saved.
var _pending_refs: Array = []


func serialize() -> Dictionary:
	var d := {
		"class_path": get_script().resource_path,
		"image_id": image_id,
		"hidden_image_id": hidden_image_id,
		"name": name,
		"flags": _flags,
		"weight": _weight,
		"jump_level": jump_level,
		"break_state": break_state,
		"max_hit_points": max_hit_points,
		"hit_points": hit_points,
		"fire_state": fire_state,
		"location": Location.serialize(location),
	}
	_serialize_fields(d)
	return d


## Overridden by subclasses to add their own fields.
func _serialize_fields(d: Dictionary) -> void:
	pass


static func deserialize_data(data: Dictionary) -> MapObject:
	var script: GDScript = load(data["class_path"])
	var obj_name: String = data.get("name", "")
	var image: String = data.get("image_id", "")
	var obj: MapObject
	if script == Board:
		obj = Board.new(obj_name, image, data.get("text", PackedStringArray()))
	elif script == DoorWindow:
		obj = DoorWindow.new(obj_name, data.get("closed_image_id", image),
			data.get("open_image_id", image), data.get("broken_image_id", image),
			data.get("max_hit_points", 0))
	elif script == Fortification:
		obj = Fortification.new(obj_name, image, data.get("max_hit_points", 0))
	elif script == PowerGenerator:
		obj = PowerGenerator.new(obj_name, data.get("off_image_id", image),
			data.get("on_image_id", image))
	else:
		obj = script.new(obj_name, image, data.get("break_state", Break.UNBREAKABLE),
			data.get("fire_state", Fire.UNINFLAMMABLE), data.get("max_hit_points", 0))
	obj._deserialize_fields(data)
	return obj


## Restores the base fields; subclasses extend it for their own fields.
## All fields are assigned directly (no property setters) so constructor
## side effects are not re-triggered.
func _deserialize_fields(d: Dictionary) -> void:
	image_id = d.get("image_id", image_id)
	hidden_image_id = d.get("hidden_image_id", hidden_image_id)
	name = d.get("name", name)
	_flags = d.get("flags", _flags)
	_weight = d.get("weight", _weight)
	jump_level = d.get("jump_level", jump_level)
	break_state = d.get("break_state", break_state)
	max_hit_points = d.get("max_hit_points", max_hit_points)
	hit_points = d.get("hit_points", hit_points)
	fire_state = d.get("fire_state", fire_state)
	var self_obj := self
	_pending_refs.append([func(loc): self_obj.location = loc, d.get("location")])


func resolve_refs(world: World) -> void:
	for pair in _pending_refs:
		pair[0].call(Location.deserialize_data(world, pair[1]))
	_pending_refs.clear()


## Sever references at shutdown (breaks map_object -> location -> map cycle).
func shutdown() -> void:
	location = null
	_pending_refs.clear()
