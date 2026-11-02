class_name District
extends RefCounted
## Port of Data/District.cs
## A group of maps in the world grid (residential block, sewers, ...).

enum DistrictKind {
	_FIRST = 0,
	GENERAL = 0,
	RESIDENTIAL = 1,
	SHOPPING = 2,
	GREEN = 3,
	BUSINESS = 4,
	_COUNT = 5,
}

var world_position: Vector2i
var kind: DistrictKind
var name: String = ""
var maps: Array[Map] = []
## INVARIANT: entry_map / sewers_map / subway_map are always also present in
## the maps list (the setter calls add_map). During deserialization the maps
## list is populated first via add_map(), then the setters are assigned —
## add_map() dedupes so the double-add is a no-op. Never assign these without
## going through the setter; never remove from maps directly without
## clearing the corresponding property.
var entry_map: Map = null:
	set(value):
		if entry_map != null:
			remove_map(entry_map)
		entry_map = value
		if value != null:
			add_map(value)
var sewers_map: Map = null:
	set(value):
		if sewers_map != null:
			remove_map(sewers_map)
		sewers_map = value
		if value != null:
			add_map(value)
var subway_map: Map = null:
	set(value):
		if subway_map != null:
			remove_map(subway_map)
		subway_map = value
		if value != null:
			add_map(value)


func _init(p_world_position: Vector2i, p_kind: DistrictKind) -> void:
	world_position = p_world_position
	kind = p_kind


func count_maps() -> int:
	return maps.size()


func has_subway() -> bool:
	return subway_map != null


func add_map(map: Map) -> void:
	assert(map != null)

	if maps.has(map):
		return

	map.district = self
	maps.append(map)


## Add a unique map (not Entry, Sewers or Subway map).
func add_unique_map(map: Map) -> void:
	add_map(map)


func get_map(index: int) -> Map:
	return maps[index]


func remove_map(map: Map) -> void:
	assert(map != null)

	maps.erase(map)
	map.district = null


## Pre-saving hook.
func optimize_before_saving() -> void:
	for m: Map in maps:
		m.optimize_before_saving()


func hash_code() -> int:
	return hash(world_position)


# --- save system ---
func serialize() -> Dictionary:
	var map_data := []
	for m in maps:
		map_data.append(m.serialize())
	return {
		"world_position": world_position,
		"kind": kind,
		"name": name,
		"maps": map_data,
		"entry_index": maps.find(entry_map) if entry_map != null else -1,
		"sewers_index": maps.find(sewers_map) if sewers_map != null else -1,
		"subway_index": maps.find(subway_map) if subway_map != null else -1,
	}


static func deserialize_data(data: Dictionary) -> District:
	var d := District.new(data.get("world_position", Vector2i.ZERO),
		data.get("kind", DistrictKind.GENERAL))
	d.name = data.get("name", "")
	for m_data in data.get("maps", []):
		d.add_map(Map.deserialize_data(m_data))
	# The property setters only add the map to the maps list, which already
	# contains it, so assigning them here is side-effect free.
	var ei: int = data.get("entry_index", -1)
	if ei >= 0 and ei < d.maps.size():
		d.entry_map = d.maps[ei]
	var si: int = data.get("sewers_index", -1)
	if si >= 0 and si < d.maps.size():
		d.sewers_map = d.maps[si]
	var ui: int = data.get("subway_index", -1)
	if ui >= 0 and ui < d.maps.size():
		d.subway_map = d.maps[ui]
	return d


func resolve_refs(world: World) -> void:
	for m in maps:
		m.resolve_refs(world)


## Sever references at shutdown (breaks district <-> map cycles).
func shutdown() -> void:
	for m in maps:
		m.shutdown()
	maps.clear()
	entry_map = null
	sewers_map = null
	subway_map = null
