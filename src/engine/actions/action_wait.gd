class_name ActionWait
extends ActorAction
## Port of Engine/Actions/ActionWait.cs


func _init(p_actor: Actor, p_game: RogueGame) -> void:
	super(p_actor, p_game)


func is_legal() -> bool:
	return true


func perform() -> void:
	game.do_wait(actor)
