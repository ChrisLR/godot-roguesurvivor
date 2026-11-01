class_name ActionDropItem
extends ActorAction
## Port of Engine/Actions/ActionDropItem.cs

var item: Item


func _init(p_actor: Actor, p_game: RogueGame, it: Item) -> void:
	super(p_actor, p_game)
	assert(it != null, "item")
	item = it


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_drop_item(actor, item)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_drop_item(actor, item)
