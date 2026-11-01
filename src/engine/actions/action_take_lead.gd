class_name ActionTakeLead
extends ActorAction
## Port of Engine/Actions/ActionTakeLead.cs

var target: Actor


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target


func is_legal() -> bool:
	return game.rules.can_actor_take_lead(actor, target).ok


func perform() -> void:
	# alpha10.1 steal lead vs take lead
	if target.has_leader:
		game.do_steal_lead(actor, target)
	else:
		game.do_take_lead(actor, target)
