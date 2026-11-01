class_name ActionBashDoor
extends ActorAction
## Port of Engine/Actions/ActionBashDoor.cs

var door: DoorWindow


func _init(p_actor: Actor, p_game: RogueGame, p_door: DoorWindow) -> void:
	super(p_actor, p_game)
	assert(p_door != null, "door")
	door = p_door


func is_legal() -> bool:
	var r: Dictionary = game.rules.is_bashable_for(actor, door)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_break(actor, door)
