class_name ActionSwitchPowerGenerator
extends ActorAction
## Port of Engine/Actions/ActionSwitchPowerGenerator.cs

var pow_gen: PowerGenerator


func _init(p_actor: Actor, p_game: RogueGame, p_pow_gen: PowerGenerator) -> void:
	super(p_actor, p_game)
	pow_gen = p_pow_gen


func is_legal() -> bool:
	var r: Dictionary = game.rules.is_switchable_for(actor, pow_gen)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_switch_power_generator(actor, pow_gen)
