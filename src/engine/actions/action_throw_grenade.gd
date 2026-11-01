class_name ActionThrowGrenade
extends ActorAction
## Port of Engine/Actions/ActionThrowGrenade.cs

var throw_pos: Vector2i


func _init(p_actor: Actor, p_game: RogueGame, p_throw_pos: Vector2i) -> void:
	super(p_actor, p_game)
	throw_pos = p_throw_pos


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_throw_to(actor, throw_pos, null)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	var grenade: Item = actor.get_equipped_weapon()

	if grenade is ItemPrimedExplosive:
		game.do_throw_grenade_primed(actor, throw_pos)
	else:
		game.do_throw_grenade_unprimed(actor, throw_pos)
