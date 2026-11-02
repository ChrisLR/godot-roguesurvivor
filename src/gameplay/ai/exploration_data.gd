class_name ExplorationData
extends RefCounted
## Port of Gameplay/AI/ExplorationData.cs
## alpha10.1 added Age concept, changed implementation from Queue to List.

var _locations_queue_size: int
var _locations_queue: Array[Location] = []  # from oldest to most recent
var _zones_queue_size: int
var _zones_queue: Array[Zone] = []  # from oldest to most recent


func _init(locations_to_remember: int, zones_to_remember: int) -> void:
	assert(locations_to_remember >= 1, "locationsQueueSize < 1")
	assert(zones_to_remember >= 1, "zonesQueueSize < 1")
	_locations_queue_size = locations_to_remember
	_zones_queue_size = zones_to_remember


func clear() -> void:
	_locations_queue.clear()
	_zones_queue.clear()


# --- Locations ---

func has_explored(loc: Location) -> bool:
	for l in _locations_queue:
		if l.equals(loc):
			return true
	return false


func add_explored(loc: Location) -> void:
	if _locations_queue.size() >= _locations_queue_size:
		_locations_queue.pop_front()
	_locations_queue.append(loc)


## 0 for locs not explored.
func get_explored_age(loc: Location) -> int:
	var n: int = _locations_queue.size()
	for i: int in range(n - 1, -1, -1):
		if _locations_queue[i].equals(loc):
			return n - i
	return 0


# --- Zones ---

func has_explored_zone(zone: Zone) -> bool:
	return _zones_queue.has(zone)


## Null/empty zones are considered as explored.
func has_explored_zones(zones) -> bool:
	if zones == null or zones.is_empty():
		return true
	for z in zones:
		if not _zones_queue.has(z):
			return false
	return true


func add_explored_zone(zone: Zone) -> void:
	if _zones_queue.size() >= _zones_queue_size:
		_zones_queue.pop_front()
	_zones_queue.append(zone)


## 0 for zones not explored.
func get_explored_age_zone(zone: Zone) -> int:
	var n: int = _zones_queue.size()
	for i: int in range(n - 1, -1, -1):
		if _zones_queue[i] == zone:
			return n - i
	return 0


## Get age of most recently explored from list ("youngest").
func get_explored_age_zones(zones) -> int:
	if zones == null or zones.is_empty():
		return 0
	var youngest_age: int = 2147483647
	for z in zones:
		var age: int = get_explored_age_zone(z)
		if age < youngest_age:
			youngest_age = age
	return youngest_age


# --- Updating ---

func update(location: Location) -> void:
	# location.
	if not has_explored(location):
		add_explored(location)

	# zones.
	var zones: Array[Zone] = location.map.get_zones_at(location.position.x, location.position.y)
	if zones != null and not zones.is_empty():
		for z in zones:
			if has_explored_zone(z):
				continue
			add_explored_zone(z)


# --- save system ---
## Only the locations queue is persisted: zones have no global ref scheme
## (they live inside maps), so the zones queue restarts empty after a load.
func serialize() -> Dictionary:
	var locs := []
	for l in _locations_queue:
		locs.append(Location.serialize(l))
	return {
		"locations_queue_size": _locations_queue_size,
		"zones_queue_size": _zones_queue_size,
		"locations": locs,
	}


func deserialize(world: World, data: Dictionary) -> void:
	if data == null:
		return
	_locations_queue.clear()
	for l in data.get("locations", []):
		_locations_queue.append(Location.deserialize_data(world, l))
	# keep the queue within its capacity.
	while _locations_queue.size() > _locations_queue_size:
		_locations_queue.pop_front()
