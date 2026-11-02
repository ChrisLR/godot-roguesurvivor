class_name Item
extends RefCounted
## Port of Data/Item.cs
## A concrete item instance in an inventory or on the ground.

var model_id: int
var quantity: int = 1:
	set(value):
		quantity = maxi(value, 0)
var equipped_part: int = Doll.DollPart.NONE  # DollPart
var is_unique: bool = false
var is_forbidden_to_ai: bool = false


func _init(_model: ItemModel) -> void:
	model_id = _model.id
	quantity = 1
	equipped_part = Doll.DollPart.NONE


var model: ItemModel:
	get:
		return Models.items.get_model(model_id)


func image_id() -> String:
	return model.image_id


func the_name() -> String:
	var m: ItemModel = model
	if m.is_proper:
		return m.single_name
	if quantity > 1 or m.is_plural:
		return "some " + m.plural_name
	return "the " + m.single_name


func a_name() -> String:
	var m: ItemModel = model
	if m.is_proper:
		return m.single_name
	if quantity > 1 or m.is_plural:
		return "some " + m.plural_name
	if m.is_an:
		return "an " + m.single_name
	return "a " + m.single_name


var can_stack_more: bool:
	get:
		return model.is_stackable and quantity < model.stacking_limit


var is_equipped: bool:
	get:
		return equipped_part != Doll.DollPart.NONE


## Pre-save hook; virtual, overridden by item subclasses.
func optimize_before_saving() -> void:
	pass


# --- save system ---
## Pending world-graph references, resolved by resolve_refs() after the whole
## world graph has been deserialized. In-memory only, never saved.
var _pending_refs: Array = []


func serialize() -> Dictionary:
	var d := {
		"class_path": get_script().resource_path,
		"model_id": model_id,
		"quantity": quantity,
		"equipped_part": equipped_part,
		"is_unique": is_unique,
		"is_forbidden_to_ai": is_forbidden_to_ai,
	}
	_serialize_fields(d)
	return d


## Overridden by subclasses to add their own fields.
func _serialize_fields(_d: Dictionary) -> void:
	pass


static func deserialize_data(data: Dictionary) -> Item:
	var script: GDScript = load(data["class_path"])
	var _model: ItemModel = Models.items.get_model(data["model_id"])
	var it: Item
	if data.has("primed_model_id"):
		# ItemExplosive/ItemGrenade constructors take the primed model too.
		it = script.new(_model, Models.items.get_model(data["primed_model_id"]))
	else:
		it = script.new(_model)
	it._deserialize_fields(data)
	return it


## Restores the base fields; subclasses extend it for their own fields.
func _deserialize_fields(d: Dictionary) -> void:
	model_id = d.get("model_id", model_id)
	quantity = d.get("quantity", 1)
	equipped_part = d.get("equipped_part", Doll.DollPart.NONE)
	is_unique = d.get("is_unique", false)
	is_forbidden_to_ai = d.get("is_forbidden_to_ai", false)


func resolve_refs(world: World) -> void:
	for pair in _pending_refs:
		pair[0].call(Session.resolve_ref(world, pair[1]))
	_pending_refs.clear()
