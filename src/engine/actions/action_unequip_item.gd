class_name ActionUnequipItem
extends ActorAction
## Port of Engine/Actions/ActionUnequipItem.cs

var item: Item


func _init(p_actor: Actor, p_game: RogueGame, it: Item) -> void:
	super(p_actor, p_game)
	assert(it != null, "item")
	item = it


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_unequip_item(actor, item)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_unequip_item(actor, item)
