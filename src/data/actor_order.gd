class_name ActorOrder
extends RefCounted
## Port of Data/ActorOrder.cs (ActorTasks enum + ActorOrder class).
## GDScript allows one global class_name per file, so the enum is a named
## nested enum; C# `ActorTasks.GUARD` reads `ActorOrder.ActorTasks.GUARD`.

enum ActorTasks
{
	BARRICADE_ONE,
	BARRICADE_MAX,
	GUARD,
	PATROL,
	DROP_ALL_ITEMS,
	BUILD_SMALL_FORTIFICATION,
	BUILD_LARGE_FORTIFICATION,
	REPORT_EVENTS,
	SLEEP_NOW,
	FOLLOW_TOGGLE,
	WHERE_ARE_YOU
}

var task: int
var location: Location


func _init(p_task: int, p_location: Location) -> void:
	task = p_task
	location = p_location


func _to_string() -> String:
	match task:
		ActorTasks.BARRICADE_ONE:
			return "barricade one (%d,%d)" % [location.position.x, location.position.y]
		ActorTasks.BARRICADE_MAX:
			return "barricade max (%d,%d)" % [location.position.x, location.position.y]
		ActorTasks.BUILD_LARGE_FORTIFICATION:
			return "build large fortification (%d,%d)" % [location.position.x, location.position.y]
		ActorTasks.BUILD_SMALL_FORTIFICATION:
			return "build small fortification (%d,%d)" % [location.position.x, location.position.y]
		ActorTasks.DROP_ALL_ITEMS:
			return "drop all items"
		ActorTasks.GUARD:
			return "guard (%d,%d)" % [location.position.x, location.position.y]
		ActorTasks.PATROL:
			return "patrol (%d,%d)" % [location.position.x, location.position.y]
		ActorTasks.REPORT_EVENTS:
			return "reporting events to leader"
		ActorTasks.SLEEP_NOW:
			return "sleep there"
		ActorTasks.FOLLOW_TOGGLE:
			return "stop/start following"
		ActorTasks.WHERE_ARE_YOU:
			return "reporting position"
		_:
			push_error("unhandled task")
			return ""


# --- save system ---
func serialize() -> Dictionary:
	return {"task": task, "location": Location.serialize(location)}


static func deserialize_data(world: World, data: Dictionary) -> ActorOrder:
	return ActorOrder.new(data.get("task", 0), Location.deserialize_data(world, data.get("location")))
