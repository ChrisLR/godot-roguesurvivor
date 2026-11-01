class_name ActionShout
extends ActorAction
## Port of Engine/Actions/ActionShout.cs

var text: String


func _init(p_actor: Actor, p_game: RogueGame, p_text: String = "") -> void:
	super(p_actor, p_game)
	text = p_text


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_shout(actor)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_shout(actor, text)
