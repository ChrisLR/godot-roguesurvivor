class_name Direction
extends RefCounted
## Port of Data/Direction.cs
## The 8 compass directions + neutral, with vectors and helpers.
##
## Note: this script avoids referencing its own class_name in type annotations
## (a Godot limitation when a script resolves its own global name during
## compilation). Callers outside this file can use the Direction type normally.

# The neutral direction
static var NEUTRAL: Direction = new_dir(-1, "neutral", Vector2i(0, 0))

# The eight directions
# 0 North (0,-1)
static var N: Direction = new_dir(0, "N", Vector2i(0, -1))
# 1 North-East (+1,-1)
static var NE: Direction = new_dir(1, "NE", Vector2i(1, -1))
# 2 East (+1,0)
static var E: Direction = new_dir(2, "E", Vector2i(1, 0))
# 3 South-East (+1,+1)
static var SE: Direction = new_dir(3, "SE", Vector2i(1, 1))
# 4 South (0,+1)
static var S: Direction = new_dir(4, "S", Vector2i(0, 1))
# 5 South-West (-1,+1)
static var SW: Direction = new_dir(5, "SW", Vector2i(-1, 1))
# 6 West (-1,0)
static var W: Direction = new_dir(6, "W", Vector2i(-1, 0))
# 7 North-West (-1,-1)
static var NW: Direction = new_dir(7, "NW", Vector2i(-1, -1))

# The compass, clockwise starting north.
static var COMPASS: Array = [N, NE, E, SE, S, SW, W, NW]
static var COMPASS_LIST: Array = [N, NE, E, SE, S, SW, W, NW]

# 4 directions compass
static var COMPASS_4: Array = [N, E, S, W]

var index: int
var dir_name: String
var vector: Vector2i
var normalized_vector: Vector2


# GDScript has no private constructors; use new_dir() in static setup.
static func new_dir(p_index: int, p_name: String, p_vector: Vector2i) -> Direction:
	var d: Direction = new()
	d.index = p_index
	d.dir_name = p_name
	d.vector = p_vector
	var length := sqrt(float(p_vector.x * p_vector.x + p_vector.y * p_vector.y))
	if length != 0.0:
		d.normalized_vector = Vector2(p_vector.x / length, p_vector.y / length)
	else:
		d.normalized_vector = Vector2.ZERO
	return d


static func from_vector(v: Vector2i) -> Direction:
	for d in COMPASS:
		if d.vector == v:
			return d
	return null


static func from_vector_xy(vx: int, vy: int) -> Direction:
	return from_vector(Vector2i(vx, vy))


static func approximate_from_vector(v: Vector2i) -> Direction:
	# compute normalized vector.
	var length := sqrt(float(v.x * v.x + v.y * v.y))
	if length == 0.0:
		return N
	var vf := Vector2(v.x / length, v.y / length)

	# find best matching direction.
	var best_error := INF
	var best_dir: Direction = N
	for d in COMPASS:
		var error := absf(vf.x - d.normalized_vector.x) + absf(vf.y - d.normalized_vector.y)
		if error < best_error:
			best_dir = d
			best_error = error
	return best_dir


static func right(d: Direction) -> Direction:
	return COMPASS[(d.index + 1) % 8]


static func left(d: Direction) -> Direction:
	# note: GDScript % is always non-negative for positive divisor, so this
	# wraps correctly (the C# original would produce a negative index).
	return COMPASS[(d.index - 1) % 8]


static func opposite(d: Direction) -> Direction:
	return COMPASS[(d.index + 4) % 8]


func _to_string() -> String:
	return dir_name
