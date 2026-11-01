class_name DiceRoller
extends RefCounted
## Port of Engine/DiceRoller.cs
##
## Note: the original uses .NET's Random, whose exact sequence cannot be
## reproduced in Godot. We keep the same API and semantics ([min, max[ rolls,
## chance percentages) with Godot's RandomNumberGenerator instead. Seeded runs
## are deterministic within this port; they do not match .NET's rolls.

var _rng := RandomNumberGenerator.new()


func _init(seed_value: int = -1) -> void:
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()


## Roll in range [min, max[.
func roll(minimum: int, maximum: int) -> int:
	# sanity check, fixes crashes.
	if maximum <= minimum:
		return minimum
	# original also clamped r >= max (a rare .NET bug); randi_range is [min, max-1] already.
	return _rng.randi_range(minimum, maximum - 1)


func roll_float() -> float:
	return _rng.randf()


## chance as a percentage [0..100]
func roll_chance(chance: int) -> bool:
	return roll(0, 100) < chance


# Save/load support (the original could not meaningfully serialize Random).
func get_state() -> int:
	return _rng.get_state()


func set_state(state: int) -> void:
	_rng.state = state
