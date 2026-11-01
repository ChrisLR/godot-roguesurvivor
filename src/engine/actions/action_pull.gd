class_name ActionPull
extends ActorAction
## Port of Engine/Actions/ActionPull.cs

var object: MapObject
var move_actor_dir: Direction
var move_actor_to: Vector2i


func _init(p_actor: Actor, p_game: RogueGame, pull_obj: MapObject, p_move_actor_dir: Direction) -> void:
	super(p_actor, p_game)
	object = pull_obj
	move_actor_dir = p_move_actor_dir
	move_actor_to = actor.location.position + p_move_actor_dir.vector


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_pull_object(actor, object, move_actor_to)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_pull(actor, object, move_actor_to)
