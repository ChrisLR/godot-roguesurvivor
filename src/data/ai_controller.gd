class_name AIController
extends ActorController
## Port of Data/AIController.cs
## Abstract base of AI controllers. The abstract C# properties Order (get)
## and Directives (get/set) are ported as backed vars: concrete controllers
## (Gameplay/AI) set them up in their constructors and override set_order().

var order: ActorOrder = null

## C# Directives : the getter creates a default directive if none was set.
var _directives: ActorDirective = null
var directives: ActorDirective:
	get:
		if _directives == null:
			_directives = ActorDirective.new()
		return _directives
	set(value):
		_directives = value


## C# SetOrder(newOrder).
func set_order(p_new_order: ActorOrder) -> void:
	order = p_new_order
