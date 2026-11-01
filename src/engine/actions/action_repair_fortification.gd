class_name ActionRepairFortification
extends ActorAction
## Port of Engine/Actions/ActionRepairFortification.cs

var fort: Fortification


func _init(p_actor: Actor, p_game: RogueGame, p_fort: Fortification) -> void:
	super(p_actor, p_game)
	fort = p_fort


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_repair_fortification(actor, fort)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_repair_fortification(actor, fort)
