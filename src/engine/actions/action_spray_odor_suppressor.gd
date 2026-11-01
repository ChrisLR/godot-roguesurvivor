class_name ActionSprayOdorSuppressor
extends ActorAction
## Port of Engine/Actions/ActionSprayOdorSuppressor.cs

var spray: ItemSprayScent
var spray_on: Actor


func _init(p_actor: Actor, p_game: RogueGame, p_spray: ItemSprayScent, p_spray_on: Actor) -> void:
	super(p_actor, p_game)
	spray = p_spray
	spray_on = p_spray_on


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_spray_odor_suppressor(actor, spray, spray_on)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_spray_odor_suppressor(actor, spray, spray_on)
