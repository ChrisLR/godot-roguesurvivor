class_name ActorController
extends RefCounted
## Port of Data/ActorController.cs
## Abstract base of actor controllers.

var controlled_actor: Actor = null


## C# TakeControl(actor).
func take_control(actor: Actor) -> void:
	controlled_actor = actor


## C# LeaveControl().
func leave_control() -> void:
	controlled_actor = null


## Abstract. C# GetAction(game).
func get_action(_p_game: RogueGame) -> ActorAction:
	assert(false, "abstract method")
	return null
