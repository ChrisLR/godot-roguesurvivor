class_name World
extends RefCounted
## Port of Data/World.cs
## The world grid of districts.

var districts_grid: Array = []  # Array (size * size) of District.
var size: int
var weather: int = Weather.CLEAR
var next_weather_check_turn: int = 0  # alpha10


func _init(p_size: int) -> void:
	assert(p_size > 0, "size <= 0")

	districts_grid.resize(p_size * p_size)
	size = p_size


func get_district(x: int, y: int) -> District:
	assert(x >= 0 and x < size, "x out of range")
	assert(y >= 0 and y < size, "y out of range")
	return districts_grid[x * size + y]


func set_district(x: int, y: int, district: District) -> void:
	assert(x >= 0 and x < size, "x out of range")
	assert(y >= 0 and y < size, "y out of range")
	districts_grid[x * size + y] = district


## Trim district coordinates to world bounds.
## The C# version used ref ints; we take and return a Vector2i.
func trim_to_bounds(pos: Vector2i) -> Vector2i:
	var result := pos
	if result.x < 0:
		result.x = 0
	if result.x >= size:
		result.x = size - 1
	if result.y < 0:
		result.y = 0
	if result.y >= size:
		result.y = size - 1
	return result


## District coordinates to string: [A-Z][0-9].
static func coord_to_string(x: int, y: int) -> String:
	return "%s%d" % [String.chr("A".unicode_at(0) + x), y]


## Pre-saving hook.
func optimize_before_saving() -> void:
	for x in size:
		for y in size:
			districts_grid[x * size + y].optimize_before_saving()


# --- save system ---
func serialize() -> Dictionary:
	var districts := []
	districts.resize(size * size)
	for x in size:
		for y in size:
			districts[x * size + y] = districts_grid[x * size + y].serialize()
	return {
		"size": size,
		"weather": weather,
		"next_weather_check_turn": next_weather_check_turn,
		"districts": districts,
	}


static func deserialize_data(data: Dictionary) -> World:
	var w := World.new(data.get("size", 1))
	w.weather = data.get("weather", Weather.CLEAR)
	w.next_weather_check_turn = data.get("next_weather_check_turn", 0)
	var districts: Array = data.get("districts", [])
	for x in w.size:
		for y in w.size:
			var idx := x * w.size + y
			if idx < districts.size():
				w.districts_grid[idx] = District.deserialize_data(districts[idx])
	# Pass 2: resolve cross-references now that the whole graph exists.
	for x in w.size:
		for y in w.size:
			var d: District = w.districts_grid[x * w.size + y]
			if d != null:
				d.resolve_refs(w)
	return w


## Sever references at shutdown (breaks world -> district -> map cycles).
func shutdown() -> void:
	for d in districts_grid:
		if d != null:
			d.shutdown()
	districts_grid.clear()
