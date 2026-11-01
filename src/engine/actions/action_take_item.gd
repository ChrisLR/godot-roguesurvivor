class_name ActionTakeItem
extends ActorAction
## Port of Engine/Actions/ActionTakeItem.cs

var position: Vector2i
var item: Item


func _init(p_actor: Actor, p_game: RogueGame, p_position: Vector2i, it: Item) -> void:
	super(p_actor, p_game)
	position = p_position
	item = it


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_get_item(actor, item)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_take_item(actor, position, item)
