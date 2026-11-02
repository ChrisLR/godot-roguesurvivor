class_name Sensor
extends RefCounted
## Port of Engine/AI/Sensor.cs
## Abstract base of sensors.

## Abstract. C# Sense(game, actor).
func sense(_game: RogueGame, _actor: Actor) -> Array[Percept]:
	assert(false, "abstract method")
	return []
