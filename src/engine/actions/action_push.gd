class_name ActionPush
extends ActorAction
## Port of Engine/Actions/ActionPush.cs

var object: MapObject
var direction: Direction
var to: Vector2i


func _init(p_actor: Actor, p_game: RogueGame, push_obj: MapObject, push_dir: Direction) -> void:
	super(p_actor, p_game)
	object = push_obj
	direction = push_dir
	to = push_obj.location.position + push_dir.vector


func is_legal() -> bool:
	if not game.rules.can_actor_push(actor, object):
		return false
	var r: Dictionary = game.rules.can_push_object_to(object, to)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_push(actor, object, to)
