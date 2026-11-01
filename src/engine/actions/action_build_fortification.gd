class_name ActionBuildFortification
extends ActorAction
## Port of Engine/Actions/ActionBuildFortification.cs

var build_pos: Vector2i
var is_large: bool


func _init(p_actor: Actor, p_game: RogueGame, p_build_pos: Vector2i, p_is_large: bool) -> void:
	super(p_actor, p_game)
	build_pos = p_build_pos
	is_large = p_is_large


func is_legal() -> bool:
	return game.rules.can_actor_build_fortification(actor, build_pos, is_large).ok


func perform() -> void:
	game.do_build_fortification(actor, build_pos, is_large)
