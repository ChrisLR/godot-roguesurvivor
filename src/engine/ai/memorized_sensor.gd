class_name MemorizedSensor
extends Sensor
## Port of Engine/AI/MemorizedSensor.cs
## Sensor with a memory of past percepts.
## Implemented with the decorator pattern.

var _sensor: Sensor
var _percepts: Array[Percept] = []
var _persistance: int


var sensor: Sensor:
	get:
		return _sensor


## noMemorySensor: sensor with no memory to get new percepts from
## persistance: number of turns to keep old percepts in memory; 0 is equivalent to having no memory
func _init(no_memory_sensor: Sensor, persistance: int) -> void:
	assert(no_memory_sensor != null, "decoratedSensor")
	_sensor = no_memory_sensor
	_persistance = persistance


func clear() -> void:
	_percepts.clear()


func sense(game: RogueGame, actor: Actor) -> Array[Percept]:
	# Forget aged percepts
	var i := 0
	while i < _percepts.size():
		if _percepts[i].get_age(actor.location.map.local_time.turn_counter) > _persistance:
			_percepts.remove_at(i)
		else:
			i += 1

	# Forget dead actors or actors that are not anymore in the same map.
	i = 0
	while i < _percepts.size():
		var p: Percept = _percepts[i]
		var a := p.percepted as Actor
		if a != null and (a.is_dead or a.location.map != actor.location.map):
			_percepts.remove_at(i)
		else:
			i += 1

	# Get new percepts.
	var turn_percepts: Array[Percept] = _sensor.sense(game, actor)

	# Update old percepts and add new ones.
	var percepts_to_add = null
	for turn_p: Percept in turn_percepts:
		# Update?
		var has_updated := false
		for old_p: Percept in _percepts:
			if old_p.percepted == turn_p.percepted:
				old_p.location = turn_p.location
				old_p.turn = turn_p.turn
				has_updated = true
				break

		# New one?
		if not has_updated:
			if percepts_to_add == null:
				percepts_to_add = []
			percepts_to_add.append(turn_p)

	if percepts_to_add != null:
		for add_p: Percept in percepts_to_add:
			_percepts.append(add_p)

	# Return updated percepts.
	return _percepts
