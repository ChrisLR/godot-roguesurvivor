class_name ActionSay
extends ActorAction
## Port of Engine/Actions/ActionSay.cs

var target: Actor
var text: String
var flags: int  # RogueGame.Sayflags


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor, p_text: String, p_flags: int) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target
	text = p_text
	flags = p_flags


func is_legal() -> bool:
	return true


func perform() -> void:
	game.do_say(actor, target, text, flags)
