class_name LOS
extends RefCounted
## Port of Engine/LOS.cs
## Line Of Sight & Field Of View computing, line tracing and assorted utilities.
## Point sets are Dictionary[Vector2i, bool]; "line" args are Array[Vector2i]
## filled in place; "fn" predicates are Callable(x: int, y: int) -> bool.


## Port of AsymetricBresenhamTrace(maxSteps, ...).
## line: if not null, points forming the segment are added, source included.
## fn: called per plotted point, return false to stop the trace.
static func asymetric_bresenham_trace(max_steps: int, _map: Map, x_from: int, y_from: int, x_to: int, y_to: int, line, fn: Callable) -> bool:
	# From Roguebasin
	# http://roguebasin.roguelikedevelopment.org/index.php?title=Bresenham%27s_Line_Algorithm

	var delta_x: int = abs(x_to - x_from) << 1
	var delta_y: int = abs(y_to - y_from) << 1

	# if xFrom == xTo or yFrom == yTo, then it does not matter what we set here
	var ix := 1 if x_to > x_from else -1
	var iy := 1 if y_to > y_from else -1

	# plot
	if line != null:
		line.append(Vector2i(x_from, y_from))

	var step_count := 0

	if delta_x >= delta_y:
		# error may go below zero
		var error: int = delta_y - (delta_x >> 1)

		while x_from != x_to:
			if error >= 0:
				if error != 0 or ix > 0:
					y_from += iy
					error -= delta_x
				# else do nothing

			x_from += ix
			error += delta_y

			step_count += 1
			if step_count > max_steps:
				return false

			# plot
			if not fn.call(x_from, y_from):
				return false
			if line != null:
				line.append(Vector2i(x_from, y_from))
	else:
		# error may go below zero
		var error: int = delta_x - (delta_y >> 1)

		while y_from != y_to:
			if error >= 0:
				if error != 0 or iy > 0:
					x_from += ix
					error -= delta_y
				# else do nothing

			y_from += iy
			error += delta_x

			step_count += 1
			if step_count > max_steps:
				return false

			# plot
			if not fn.call(x_from, y_from):
				return false
			if line != null:
				line.append(Vector2i(x_from, y_from))

	# all clear.
	return true


static func asymetric_bresenham_trace_full(map: Map, x_from: int, y_from: int, x_to: int, y_to: int, line, fn: Callable) -> bool:
	return asymetric_bresenham_trace(2147483647, map, x_from, y_from, x_to, y_to, line, fn)


## C# original returns Direction.FromVector(line[0]) where line[0] is the START
## point, which can never match a unit vector; kept verbatim (dead code in the
## original - no call sites).
static func direction_to(map: Map, x_from: int, y_from: int, x_to: int, y_to: int) -> Direction:
	var line: Array = []
	asymetric_bresenham_trace(1, map, x_from, y_from, x_to, y_to, line,
		func(_x: int, _y: int) -> bool: return true)

	return Direction.from_vector(line[0])


static func can_trace_view_line(from_location: Location, to_position: Vector2i, max_range: int = 2147483647) -> bool:
	var map: Map = from_location.map
	var goal := to_position

	return asymetric_bresenham_trace(max_range,
		map,
		from_location.position.x, from_location.position.y,
		to_position.x, to_position.y,
		null,
		func(x: int, y: int) -> bool:
			if map.is_transparent(x, y):
				return true
			if x == goal.x and y == goal.y:
				return true
			return false)


## Checks if can fire from a position to another.
## line: if not null, contains the entire fire line, even if obstructed.
## Returns true if the fire line is clear.
static func can_trace_fire_line(from_location: Location, to_position: Vector2i, max_range: int, line) -> bool:
	var map: Map = from_location.map
	var start := from_location.position
	var goal := to_position
	var fire_line_clear := [true]

	asymetric_bresenham_trace(max_range,
		map,
		from_location.position.x, from_location.position.y,
		to_position.x, to_position.y,
		line,
		func(x: int, y: int) -> bool:
			if x == start.x and y == start.y:
				return true
			if x == goal.x and y == goal.y:
				return true
			if map.is_blocking_fire(x, y):
				fire_line_clear[0] = false
			return true)

	return fire_line_clear[0]


static func can_trace_throw_line(from_location: Location, to_position: Vector2i, max_range: int, line) -> bool:
	var map: Map = from_location.map
	var start := from_location.position
	var goal := to_position
	var throw_line_clear := [true]

	# check line.
	asymetric_bresenham_trace(max_range,
		map,
		from_location.position.x, from_location.position.y,
		to_position.x, to_position.y,
		line,
		func(x: int, y: int) -> bool:
			if x == start.x and y == start.y:
				return true
			if x == goal.x and y == goal.y:
				return true
			if map.is_blocking_throw(x, y):
				throw_line_clear[0] = false
			return true)

	# we can't throw on something blocking, no matter the rest of the line is clear.
	if map.is_blocking_throw(to_position.x, to_position.y):
		throw_line_clear[0] = false

	# done.
	return throw_line_clear[0]


## Asymetric bresenham : use the fact we are tracing FROM to TO to add visible
## tiles on the fly.
## Pros: fixes "holes" in fov : if you can see a tile you can see everything in
## its line too.
## Cons: rare cases of asymetry in FOV : i can see you, but you can't see me.
## Inlined Bresenham trace (instead of asymetric_bresenham_trace + Callable):
## avoids one closure allocation per traced tile and one Callable.call per step.
static func _fov_trace(map: Map, from: Vector2i, goal: Vector2i, max_range: int, visible_set: Dictionary) -> bool:
	var x_from := from.x
	var y_from := from.y
	var x_to := goal.x
	var y_to := goal.y
	var delta_x: int = abs(x_to - x_from) << 1
	var delta_y: int = abs(y_to - y_from) << 1
	var ix := 1 if x_to > x_from else -1
	var iy := 1 if y_to > y_from else -1
	var step_count := 0

	if delta_x >= delta_y:
		var error: int = delta_y - (delta_x >> 1)
		while x_from != x_to:
			if error >= 0:
				if error != 0 or ix > 0:
					y_from += iy
				error -= delta_x
			x_from += ix
			error += delta_y
			step_count += 1
			if step_count > max_range:
				return false
			if (x_from == x_to and y_from == y_to) or map.is_transparent(x_from, y_from):
				visible_set[Vector2i(x_from, y_from)] = true
			else:
				return false
	else:
		var error: int = delta_x - (delta_y >> 1)
		while y_from != y_to:
			if error >= 0:
				if error != 0 or iy > 0:
					x_from += ix
				error -= delta_y
			y_from += iy
			error += delta_x
			step_count += 1
			if step_count > max_range:
				return false
			if (x_from == x_to and y_from == y_to) or map.is_transparent(x_from, y_from):
				visible_set[Vector2i(x_from, y_from)] = true
			else:
				return false

	return true


static func compute_fov_for(rules: Rules, actor: Actor, time: WorldTime, weather: int) -> Dictionary:
	var from_location: Location = actor.location
	var visible_set: Dictionary = {}  # HashSet<Point>
	var from := from_location.position
	var map: Map = from_location.map
	var max_range: int = rules.actor_fov(actor, time, weather)

	##############################################
	# Brute force ray-casting with wall fix pass
	##############################################
	var p_min: Vector2i = map.trim_to_bounds(from.x - max_range, from.y - max_range)
	var p_max: Vector2i = map.trim_to_bounds(from.x + max_range, from.y + max_range)
	var xmin := p_min.x
	var ymin := p_min.y
	var xmax := p_max.x
	var ymax := p_max.y
	var walls_to_fix: Array[Vector2i] = []
	# Integer form of the distance check: rules.los_distance(from, to) is
	# sqrt(0.75 * d2), so "los_distance > max_range" is exactly "3 * d2 > 4 *
	# max_range^2" (both sides non-negative, and 3*d2 vs 4*r^2 are integers,
	# so no float rounding edge cases). Avoids a sqrt per tile.
	var max_range_sq4: int = 4 * max_range * max_range

	# 1st pass : trace line and remember walls that are not visible for 2nd pass.
	for x: int in range(xmin, xmax + 1):
		var dx := x - from.x
		for y: int in range(ymin, ymax + 1):
			var to := Vector2i(x, y)

			# Distance check.
			var dy := y - from.y
			if 3 * (dx * dx + dy * dy) > max_range_sq4:
				continue

			# If we already know tile is visible, pass.
			if visible_set.has(to):
				continue

			# Trace line.
			if not _fov_trace(map, from, to, max_range, visible_set):
				# if its a wall (in FoV terms), remember.
				var is_fov_wall := false
				var tile: Tile = map.get_tile_at(x, y)
				var map_obj: MapObject = map.get_map_object_at_xy(x, y)
				if not tile.model.is_transparent and not tile.model.is_walkable:
					is_fov_wall = true
				elif map_obj != null:
					is_fov_wall = true
				if is_fov_wall:
					walls_to_fix.append(to)

				# next.
				continue

			# Visible.
			visible_set[to] = true

	# 2nd pass : wall fix.
	var fixed_walls: Array[Vector2i] = []
	for wall_p: Vector2i in walls_to_fix:
		var count := 0
		for d: Direction in Direction.COMPASS:
			var next: Vector2i = wall_p + d.vector
			if visible_set.has(next):
				var tile: Tile = map.get_tile_at(next.x, next.y)
				if tile.model.is_transparent and tile.model.is_walkable:
					count += 1
		if count >= 3:
			fixed_walls.append(wall_p)

	for fixed_wall: Vector2i in fixed_walls:
		visible_set[fixed_wall] = true

	return visible_set
