class_name ActionTrade
extends ActorAction
## Port of Engine/Actions/ActionTrade.cs

var target: Actor


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target


func is_legal() -> bool:
	return game.rules.can_actor_initiate_trade_with(actor, target).ok


func perform() -> void:
	game.do_trade(actor, target)
