class_name ActionSwitchPlace
extends ActorAction
## Port of Engine/Actions/ActionSwitchPlace.cs

var target: Actor


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target


func is_legal() -> bool:
	return game.rules.can_actor_switch_place_with(actor, target).ok


func perform() -> void:
	game.do_switch_place(actor, target)
