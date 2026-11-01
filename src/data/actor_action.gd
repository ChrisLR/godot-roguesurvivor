class_name ActorAction
extends RefCounted
## Port of Data/ActorAction.cs
## Abstract base of actor actions.

var game: RogueGame
var actor: Actor
var fail_reason: String


func _init(p_actor: Actor, p_game: RogueGame) -> void:
	assert(p_actor != null, "actor")
	assert(p_game != null, "game")

	actor = p_actor
	game = p_game


## Abstract. C# IsLegal().
func is_legal() -> bool:
	assert(false, "abstract method")
	return false


## Abstract. C# Perform().
func perform() -> void:
	assert(false, "abstract method")
