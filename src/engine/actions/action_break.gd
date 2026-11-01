class_name ActionBreak
extends ActorAction
## Port of Engine/Actions/ActionBreak.cs

var obj: MapObject


## obj is needed by RogueGame to ask the player if he really wants to break it.
func _init(p_actor: Actor, p_game: RogueGame, p_obj: MapObject) -> void:
	super(p_actor, p_game)
	assert(p_obj != null, "obj")
	obj = p_obj


func is_legal() -> bool:
	var r: Dictionary = game.rules.is_breakable_for(actor, obj)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_break(actor, obj)
