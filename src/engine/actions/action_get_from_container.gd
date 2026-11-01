class_name ActionGetFromContainer
extends ActorAction
## Port of Engine/Actions/ActionGetFromContainer.cs

var position: Vector2i


func _init(p_actor: Actor, p_game: RogueGame, p_position: Vector2i) -> void:
	super(p_actor, p_game)
	position = p_position


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_get_item_from_container(actor, position)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_take_from_container(actor, position)
