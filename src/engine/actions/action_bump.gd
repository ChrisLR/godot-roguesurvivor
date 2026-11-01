class_name ActionBump
extends ActorAction
## Port of Engine/Actions/ActionBump.cs
## High-level bump action that translates into a concrete action
## (move, use, attack, chat...). Very useful for "intelligent" AI.

var direction: Direction
var new_location: Location
var concrete_action: ActorAction


func _init(p_actor: Actor, p_game: RogueGame, p_direction: Direction) -> void:
	super(p_actor, p_game)
	direction = p_direction
	new_location = actor.location.plus(direction)

	var r: Dictionary = game.rules.is_bumpable_for(actor, game, new_location)
	fail_reason = r.get("fail_reason", "") if r != null else ""
	concrete_action = r.get("action") if r != null else null


func is_legal() -> bool:
	if concrete_action == null:
		return false
	return concrete_action.is_legal()


func perform() -> void:
	if concrete_action == null:
		return
	concrete_action.perform()
