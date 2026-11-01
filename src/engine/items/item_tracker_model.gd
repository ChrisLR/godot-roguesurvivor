class_name ItemTrackerModel
extends ItemModel
## Port of Engine/Items/ItemTrackerModel.cs
## Static definition of a tracker item kind.

## [Flags] TrackingFlags
## FOLLOWER_AND_LEADER: followers and leaders can track each other.
## UNDEADS: can track undeads within close range.
## BLACKOPS_FACTION: can track all BlackOps faction members on the map.
## POLICE_FACTION: can track all Police faction members on the map.
enum TrackingFlags {
	NONE = 0,
	FOLLOWER_AND_LEADER = (1 << 0),
	UNDEADS = (1 << 1),
	BLACKOPS_FACTION = (1 << 2),
	POLICE_FACTION = (1 << 3),
}

var tracking: TrackingFlags
var max_batteries: int
var has_clock: bool  # alpha10


func _init(p_single_name: String, p_plural_name: String, p_image_id: String,
		p_tracking: TrackingFlags, p_max_batteries: int, p_has_clock: bool) -> void:
	super._init(p_single_name, p_plural_name, p_image_id)
	tracking = p_tracking
	max_batteries = p_max_batteries
	has_clock = p_has_clock  # alpha10
	dont_auto_equip = true
