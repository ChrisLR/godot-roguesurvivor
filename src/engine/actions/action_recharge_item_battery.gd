class_name ActionRechargeItemBattery
extends ActorAction
## Port of Engine/Actions/ActionRechargeItemBattery.cs

var item: Item


func _init(p_actor: Actor, p_game: RogueGame, it: Item) -> void:
	super(p_actor, p_game)
	assert(it != null, "item")
	item = it


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_recharge_item_battery(actor, item)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_recharge_item_battery(actor, item)
