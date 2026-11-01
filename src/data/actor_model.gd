class_name ActorModel
extends RefCounted
## Port of Data/ActorModel.cs
## Static definition of an actor kind; factory for Actor instances.

var id: int = 0
var image_id: String
var doll_body: Doll.DollBody
var name: String
var plural_name: String
var abilities: Abilities
var starting_sheet: ActorSheet
# The controller script (a GDScript type with class_name) or null for no controller.
# C# used System.Type + reflection; we store the type itself and call .new().
var default_controller  # ActorController script or null
var flavor_description: String = ""
var score_value: int = 0
var created_count: int = 0


func _init(p_image_id: String, p_name: String, p_plural_name: String, p_score_value: int,
		p_body: Doll.DollBody, p_abilities: Abilities, p_starting_sheet: ActorSheet,
		p_default_controller) -> void:
	assert(p_name != null)
	assert(p_body != null)
	assert(p_abilities != null)
	assert(p_starting_sheet != null)

	image_id = p_image_id
	doll_body = p_body
	name = p_name
	plural_name = p_plural_name
	starting_sheet = p_starting_sheet
	abilities = p_abilities
	default_controller = p_default_controller
	score_value = p_score_value

	created_count = 0


## Internal factory (C# private Create).
func create(faction: Faction, spawn_time: int) -> Actor:
	created_count += 1
	var actor := Actor.new_spawn(self, faction, spawn_time)
	actor.controller = instanciate_controller()
	return actor


func instanciate_controller() -> ActorController:
	if default_controller == null:
		return null
	return default_controller.new() as ActorController


func create_anonymous(faction: Faction, spawn_time: int) -> Actor:
	return create(faction, spawn_time)


func create_numbered_name(faction: Faction, spawn_time: int) -> Actor:
	var actor := create(faction, spawn_time)
	var number := str(created_count)
	actor.name += number
	actor.is_proper_name = true
	return actor


func create_named(faction: Faction, proper_name: String, is_plural_name: bool,
		spawn_time: int) -> Actor:
	var actor := create(faction, spawn_time)
	actor.name = proper_name
	actor.is_proper_name = true
	actor.is_plural_name = is_plural_name
	return actor
