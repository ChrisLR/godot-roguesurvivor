class_name ActionRangedAttack
extends ActorAction
## Port of Engine/Actions/ActionRangedAttack.cs

var target: Actor
var lof: Array = []  # List<Point>, filled by Rules.CanActorFireAt
var mode: Attack.FireMode


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor, p_mode: Attack.FireMode = Attack.FireMode.DEFAULT) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target
	mode = p_mode


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_fire_at(actor, target, lof)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_ranged_attack(actor, target, lof, mode)
