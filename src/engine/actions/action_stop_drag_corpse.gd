class_name ActionStopDragCorpse
extends ActorAction
## Port of Engine/Actions/ActionStopDragCorpse.cs

var target: Corpse


func _init(p_actor: Actor, p_game: RogueGame, p_target: Corpse) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_stop_drag_corpse(actor, target)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_stop_drag_corpse(actor, target)
