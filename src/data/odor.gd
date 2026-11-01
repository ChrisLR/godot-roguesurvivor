class_name Odor
## Port of Data/Odor.cs (Odor enum + OdorScent class).
## GDScript allows one global class_name per file, so the OdorScent class is
## nested; C# `OdorScent` reads `Odor.OdorScent`.

## Anonymous enum so members are direct constants (C# call sites: Odor.LIVING).
enum {
	LIVING,
	UNDEAD_MASTER,

	# alpha 10
	SUPPRESSOR,
	#PERFUME_LIVING_SUPRESSOR,
	#PERFUME_LIVING_GENERATOR
}


class OdorScent:
	extends RefCounted

	const MIN_STRENGTH: int = 1
	const MAX_STRENGTH: int = 9 * WorldTime.TURNS_PER_HOUR

	var odor: int
	var strength: int
	var position: Vector2i


	func _init(p_odor: int, p_strength: int, p_position: Vector2i) -> void:
		odor = p_odor
		strength = mini(MAX_STRENGTH, p_strength)
		position = p_position


	func change(amount: int) -> void:
		var new_strength: int = strength + amount

		if new_strength < MIN_STRENGTH:
			new_strength = 0
		elif new_strength > MAX_STRENGTH:
			new_strength = MAX_STRENGTH

		strength = new_strength


	## C# method Set(value); named set_ because set is an Object built-in.
	func set_(value: int) -> void:
		var new_strength: int = value

		if new_strength < MIN_STRENGTH:
			new_strength = 0
		elif new_strength > MAX_STRENGTH:
			new_strength = MAX_STRENGTH

		strength = new_strength

	# --- save system ---
	func serialize() -> Dictionary:
		return {"odor": odor, "strength": strength, "position": position}


	static func deserialize_data(data: Dictionary) -> OdorScent:
		return OdorScent.new(data.get("odor", 0), data.get("strength", 0),
			data.get("position", Vector2i()))
