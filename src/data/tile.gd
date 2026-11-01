class_name Tile
extends RefCounted
## Port of Data/Tile.cs
## A concrete map cell: a tile model plus runtime flags and decorations.

enum Flags {
	NONE = 0,
	IS_INSIDE = (1 << 0),
	IS_IN_VIEW = (1 << 1),
	IS_VISITED = (1 << 2),
}

var model_id: int
var flags: int = Flags.NONE
var decorations = null  # Array of String, or null if no decorations.

var is_inside: bool:
	get:
		return (flags & Flags.IS_INSIDE) != 0
	set(value):
		if value:
			flags |= Flags.IS_INSIDE
		else:
			flags &= ~Flags.IS_INSIDE

var is_in_view: bool:
	get:
		return (flags & Flags.IS_IN_VIEW) != 0
	set(value):
		if value:
			flags |= Flags.IS_IN_VIEW
		else:
			flags &= ~Flags.IS_IN_VIEW

var is_visited: bool:
	get:
		return (flags & Flags.IS_VISITED) != 0
	set(value):
		if value:
			flags |= Flags.IS_VISITED
		else:
			flags &= ~Flags.IS_VISITED


func _init(model: TileModel) -> void:
	assert(model != null)
	model_id = model.id


var model: TileModel:
	get:
		return Models.tiles.get_model(model_id)
	set(value):
		set_model(value)


func set_model(model: TileModel) -> void:
	assert(model != null)
	model_id = model.id


func has_decorations() -> bool:
	return decorations != null


## Get tile decorations array, null if no decorations.
func get_decorations():
	return decorations


func add_decoration(image_id: String) -> void:
	if decorations == null:
		decorations = []
	if decorations.has(image_id):
		return
	decorations.append(image_id)


func has_decoration(image_id: String) -> bool:
	if decorations == null:
		return false
	return decorations.has(image_id)


func remove_all_decorations() -> void:
	if decorations != null:
		decorations.clear()
	decorations = null


func remove_decoration(image_id: String) -> void:
	if decorations == null:
		return
	decorations.erase(image_id)
	if decorations.is_empty():
		decorations = null


## Pre-saving hook. The C# version trims the list capacity; nothing to do here.
func optimize_before_saving() -> void:
	pass


# --- save system ---
func serialize() -> Dictionary:
	return {"model_id": model_id, "flags": flags, "decorations": decorations}


static func deserialize_data(data: Dictionary) -> Tile:
	var t := Tile.new(Models.tiles.get_model(data.get("model_id", 0)))
	t.flags = data.get("flags", Flags.NONE)
	t.decorations = data.get("decorations", null)
	return t
