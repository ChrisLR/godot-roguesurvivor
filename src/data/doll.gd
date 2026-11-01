class_name Doll
extends RefCounted
## Port of Data/Doll.cs
## Paper-doll body + per-part image decorations used to draw actors.
## The DollPart enum is nested here; access it as Doll.DollPart.XXX.

enum DollPart {
	NONE = 0,
	_FIRST = 1,
	RIGHT_HAND = 1,
	LEFT_HAND = 2,
	HEAD = 3,
	TORSO = 4,
	LEGS = 5,
	FEET = 6,
	SKIN = 7,
	EYES = 8,
	_COUNT = 9,
}


## Blank doll body.
static var UNDEF: DollBody = DollBody.new(true, 0)


class DollBody:
	var is_male: bool
	var speed: int

	func _init(p_is_male: bool, p_speed: int) -> void:
		is_male = p_is_male
		speed = p_speed


var body: DollBody
# One entry per DollPart: Array of String, or null if the part has no decoration.
var decorations: Array = []


func _init(p_body: DollBody) -> void:
	body = p_body
	decorations.resize(DollPart._COUNT)


func get_decorations(part: int) -> Array:
	if decorations[part] == null:
		return []
	return decorations[part]


func count_decorations(part: int) -> int:
	var part_list: Array = get_decorations(part)
	if part_list == null:
		return 0
	return part_list.size()


func add_decoration(part: int, image_id: String) -> void:
	# NB: get_decorations() returns a fresh [] for empty parts, so the null
	# check must go against decorations[part] directly, else the decoration
	# is appended to a throwaway array and lost.
	if decorations[part] == null:
		decorations[part] = []
	decorations[part].append(image_id)


func remove_decoration(image_id: String) -> void:
	for part in DollPart._COUNT:
		var part_list: Array = decorations[part]
		if part_list == null:
			continue
		if part_list.has(image_id):
			part_list.erase(image_id)
			if part_list.is_empty():
				decorations[part] = null
			return


func remove_part_decorations(part: int) -> void:
	decorations[part] = null


func remove_all_decorations() -> void:
	for part in DollPart._COUNT:
		decorations[part] = null


# --- save system ---
func serialize() -> Dictionary:
	return {
		"is_male": body.is_male,
		"speed": body.speed,
		"decorations": decorations,
	}


static func deserialize_data(data: Dictionary) -> Doll:
	var doll := Doll.new(DollBody.new(data.get("is_male", true), data.get("speed", 0)))
	var dec = data.get("decorations", null)
	if dec != null:
		doll.decorations = dec
	return doll
