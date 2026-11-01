class_name ItemTracker
extends Item
## Port of Engine/Items/ItemTracker.cs
## A concrete tracker item instance with a battery charge.

var tracking: ItemTrackerModel.TrackingFlags
var _batteries: int = 0


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemTrackerModel, "model is not a TrackerModel")

	var m: ItemTrackerModel = p_model
	tracking = m.tracking
	# C# goes through the Batteries setter; set the backing field directly so
	# construction does not depend on the model database being up.
	_batteries = m.max_batteries


func can_track_followers_or_leader() -> bool:
	return (tracking & ItemTrackerModel.TrackingFlags.FOLLOWER_AND_LEADER) != 0


func can_track_undeads() -> bool:
	return (tracking & ItemTrackerModel.TrackingFlags.UNDEADS) != 0


func can_track_blackops() -> bool:
	return (tracking & ItemTrackerModel.TrackingFlags.BLACKOPS_FACTION) != 0


func can_track_police() -> bool:
	return (tracking & ItemTrackerModel.TrackingFlags.POLICE_FACTION) != 0


# alpha10
func has_clock() -> bool:
	return (model as ItemTrackerModel).has_clock


var batteries: int:
	get:
		return _batteries
	set(value):
		if value < 0:
			value = 0
		_batteries = mini(value, (model as ItemTrackerModel).max_batteries)


var is_fully_charged: bool:
	get:
		return _batteries >= (model as ItemTrackerModel).max_batteries


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["tracking"] = tracking
	d["batteries"] = _batteries


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	tracking = d.get("tracking", tracking)
	_batteries = d.get("batteries", _batteries)
