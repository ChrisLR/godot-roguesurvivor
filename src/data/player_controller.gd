class_name PlayerController
extends ActorController
## Port of Data/PlayerController.cs
## "Marker" class to tell the game the actor is controller by the human
## player. The class does nothing as the game itself handles all the work.


## Shouldn't get here (C# throws InvalidOperationException).
func get_action(_p_game: RogueGame) -> ActorAction:
	push_error("do not call PlayerController.get_action()")
	assert(false, "do not call PlayerController.get_action()")
	return null
