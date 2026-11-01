class_name SmellSensor
extends Sensor
## Port of Gameplay/AI/Sensors/SmellSensor.cs

## Port of the AIScent inner class.
class AIScent:
	var odor: int
	var strength: int

	func _init(p_odor: int, p_strength: int) -> void:
		odor = p_odor
		strength = p_strength


var _odor_to_smell: int
var _scents: Array[Percept] = []


var scents: Array[Percept]:
	get:
		return _scents


func _init(odor_to_smell: int) -> void:
	_odor_to_smell = odor_to_smell


func sense(game: RogueGame, actor: Actor) -> Array[Percept]:
	_scents.clear()
	var min_strength: int = game.rules.actor_smell_threshold(actor)

	# smell adjacent & self.
	var pos: Vector2i = actor.location.position
	var xmin: int = pos.x - 1
	var xmax: int = pos.x + 1
	var ymin: int = pos.y - 1
	var ymax: int = pos.y + 1
	var map: Map = actor.location.map
	var p := map.trim_to_bounds(xmin, ymin)
	xmin = p.x
	ymin = p.y
	p = map.trim_to_bounds(xmax, ymax)
	xmax = p.x
	ymax = p.y

	var turn_counter: int = map.local_time.turn_counter
	for x: int in range(xmin, xmax + 1):
		for y: int in range(ymin, ymax + 1):
			var pt := Vector2i(x, y)
			var strength: int = map.get_scent_by_odor_at(_odor_to_smell, pt)
			if strength >= 0 and strength >= min_strength:
				_scents.append(Percept.new(AIScent.new(_odor_to_smell, strength), turn_counter, Location.new(map, pt)))

	return _scents
