class_name ActionChat
extends ActorAction
## Port of Engine/Actions/ActionChat.cs

var target: Actor


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target


func is_legal() -> bool:
	return true


func perform() -> void:
	game.do_chat(actor, target)
