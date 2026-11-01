class_name ActionUseExit
extends ActorAction
## Port of Engine/Actions/ActionUseExit.cs

var exit_point: Vector2i


func _init(p_actor: Actor, p_exit_point: Vector2i, p_game: RogueGame) -> void:
	super(p_actor, p_game)
	exit_point = p_exit_point


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_use_exit(actor, exit_point)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_use_exit(actor, exit_point)
