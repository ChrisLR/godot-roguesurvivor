class_name ActionEatFoodOnGround
extends ActorAction
## Port of Engine/Actions/ActionEatFoodOnGround.cs

var item: Item


func _init(p_actor: Actor, p_game: RogueGame, it: Item) -> void:
	super(p_actor, p_game)
	assert(it != null, "item")
	item = it


func is_legal() -> bool:
	var r: Dictionary = game.rules.can_actor_eat_food_on_ground(actor, item)
	fail_reason = r.fail_reason
	return r.ok


func perform() -> void:
	game.do_eat_food_from_ground(actor, item)
