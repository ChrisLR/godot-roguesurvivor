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
		var a: Actor = p.percepted if p.percepted is Actor else null
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
			# percepted may be a non-object (corpse list Array); Object == Array
			# is a runtime error, so only compare when both sides are same kind.
			if (old_p.percepted is Object) == (turn_p.percepted is Object) \
					and old_p.percepted == turn_p.percepted:
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


# --- save system ---

## Serialize the memorized percepts. Actor/Corpse percepts become world-graph
## refs, String percepts (raid descriptions) are stored raw; anything else is
## dropped (not restorable).
func serialize() -> Dictionary:
	var list := []
	for p: Percept in _percepts:
		var entry := {"turn": p.turn, "location": Location.serialize(p.location)}
		if p.percepted is Actor:
			entry["kind"] = "actor"
			entry["ref"] = Session.actor_ref(p.percepted)
		elif p.percepted is Corpse:
			entry["kind"] = "corpse"
			entry["ref"] = Session.corpse_ref(p.percepted)
		elif p.percepted is String:
			entry["kind"] = "string"
			entry["text"] = p.percepted
		else:
			continue
		list.append(entry)
	return {"persistance": _persistance, "percepts": list}


## Restore memorized percepts from serialize() data (world needed to resolve
## actor/corpse refs).
func deserialize(world: World, data: Dictionary) -> void:
	_percepts.clear()
	if data == null:
		return
	_persistance = data.get("persistance", _persistance)
	for entry in data.get("percepts", []):
		var percepted: Variant = null
		match entry.get("kind", ""):
			"actor", "corpse":
				percepted = Session.resolve_ref(world, entry.get("ref"))
			"string":
				percepted = entry.get("text", "")
		if percepted == null:
			continue
		var loc := Location.deserialize_data(world, entry.get("location", {}))
		_percepts.append(Percept.new(percepted, entry.get("turn", 0), loc))
