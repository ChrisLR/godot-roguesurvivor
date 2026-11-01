class_name ActionSleep
extends ActorAction
## Port of Engine/Actions/ActionSleep.cs


func _init(p_actor: Actor, p_game: RogueGame) -> void:
	super(p_actor, p_game)


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_sleep(actor)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_start_sleeping(actor)
