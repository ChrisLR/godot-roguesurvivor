class_name TimedTask
extends RefCounted
## Port of Data/TimedTask.cs
## Abstract base of timed tasks.

var turns_left: int


func is_completed() -> bool:
	return turns_left <= 0


func _init(p_turns_left: int) -> void:
	turns_left = p_turns_left


func tick(map: Map) -> void:
	turns_left -= 1
	if turns_left <= 0:
		trigger(map)


## Abstract. C# Trigger(m).
func trigger(_p_map: Map) -> void:
	assert(false, "abstract method")


# --- save system ---
func serialize() -> Dictionary:
	var d := {"class_path": get_script().resource_path, "turns_left": turns_left}
	_serialize_fields(d)
	return d


## Overridden by subclasses to add their own fields.
func _serialize_fields(_d: Dictionary) -> void:
	pass


static func deserialize_data(data: Dictionary) -> TimedTask:
	var script: GDScript = load(data["class_path"])
	# Subclasses whose constructor needs more than turns_left provide their
	# own static deserialize_data.
	if script == TaskRemoveDecoration:
		return TaskRemoveDecoration.deserialize_data(data)
	var t: TimedTask = script.new(data.get("turns_left", 0))
	t._deserialize_fields(data)
	return t


## Overridden by subclasses to restore their own fields.
func _deserialize_fields(_d: Dictionary) -> void:
	pass
