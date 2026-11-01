class_name ActionMeleeAttack
extends ActorAction
## Port of Engine/Actions/ActionMeleeAttack.cs

var target: Actor


func _init(p_actor: Actor, p_game: RogueGame, p_target: Actor) -> void:
	super(p_actor, p_game)
	assert(p_target != null, "target")
	target = p_target


func is_legal() -> bool:
	return true  # handled before in rules


func perform() -> void:
	game.do_melee_attack(actor, target)
