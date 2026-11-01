class_name ActionMoveStep
extends ActorAction
## Port of Engine/Actions/ActionMoveStep.cs

var new_location: Location


func _init(p_actor: Actor, p_game: RogueGame, direction: Direction) -> void:
	super(p_actor, p_game)
	new_location = actor.location.plus(direction)


## C# second constructor: to an explicit position.
static func new_to(p_actor: Actor, p_game: RogueGame, to: Vector2i) -> ActionMoveStep:
	var a: ActionMoveStep = ActionMoveStep.new(p_actor, p_game, Direction.NEUTRAL)
	a.new_location = Location.new(p_actor.location.map, to)
	return a


func is_legal() -> bool:
	var r: Dictionary = game.rules.is_walkable_for(actor, new_location)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_move_actor(actor, new_location)
