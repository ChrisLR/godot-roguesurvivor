class_name ActionLeaveMap
extends ActorAction
## Port of Engine/Actions/ActionLeaveMap.cs

var exit_point: Vector2i


func _init(p_actor: Actor, p_game: RogueGame, p_exit_point: Vector2i) -> void:
	super(p_actor, p_game)
	exit_point = p_exit_point


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_leave_map(actor)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_leave_map(actor, exit_point, true)
