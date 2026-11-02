class_name MapGenerator
extends RefCounted
## Port of Engine/MapGenerator.cs
## Abstract base class with shared map-generation helpers: tile filling,
## actor/map object/item placement, area clearing and adjacency predicates.
##
## Adaptations:
## - C# method overloads are flattened (default args or *_rect / *_p / *_xy
##   variants, following the naming style used in Map).
## - System.Drawing.Point / Rectangle become Vector2i / Rect2i.
## - C# Action/Func/Predicate parameters become Callables (null -> invalid
##   Callable, checked with is_valid()).
## - C# out-parameter IsWalkableFor -> Rules.is_walkable_for returning a
##   Dictionary with an "ok" key.

var rules: Rules


func _init(p_rules: Rules) -> void:
	assert(p_rules != null, "rules")
	rules = p_rules


## Abstract in C#. Subclasses must override.
func generate(_seed: int) -> Map:
	assert(false, "MapGenerator.Generate is abstract")
	return null


# Generation helpers

# Tile filling

## C# TileFill(map, model) overload : fill the whole map.
func tile_fill_all(map: Map, model: TileModel, decorator_fn: Callable = Callable()) -> void:
	tile_fill(map, model, 0, 0, map.width, map.height, decorator_fn)


func tile_fill_rect(map: Map, model: TileModel, rect: Rect2i, decorator_fn: Callable = Callable()) -> void:
	tile_fill(map, model, rect.position.x, rect.position.y, rect.size.x, rect.size.y, decorator_fn)


func tile_fill(map: Map, model: TileModel, left: int, top: int, width: int, height: int, decorator_fn: Callable = Callable()) -> void:
	assert(map != null, "map")
	assert(model != null, "model")

	for x in range(left, left + width):
		for y in range(top, top + height):
			var prev_model: TileModel = map.get_tile_at(x, y).model
			map.set_tile_model_at(x, y, model)
			if decorator_fn.is_valid():
				decorator_fn.call(map.get_tile_at(x, y), prev_model, x, y)


func tile_h_line(map: Map, model: TileModel, left: int, top: int, width: int, decorator_fn: Callable = Callable()) -> void:
	assert(map != null, "map")
	assert(model != null, "model")

	for x in range(left, left + width):
		var prev_model: TileModel = map.get_tile_at(x, top).model
		map.set_tile_model_at(x, top, model)
		if decorator_fn.is_valid():
			decorator_fn.call(map.get_tile_at(x, top), prev_model, x, top)


func tile_v_line(map: Map, model: TileModel, left: int, top: int, height: int, decorator_fn: Callable = Callable()) -> void:
	assert(map != null, "map")
	assert(model != null, "model")

	for y in range(top, top + height):
		var prev_model: TileModel = map.get_tile_at(left, y).model
		map.set_tile_model_at(left, y, model)
		if decorator_fn.is_valid():
			decorator_fn.call(map.get_tile_at(left, y), prev_model, left, y)


func tile_rectangle(map: Map, model: TileModel, left: int, top: int, width: int, height: int, decorator_fn: Callable = Callable()) -> void:
	assert(map != null, "map")
	assert(model != null, "model")

	tile_h_line(map, model, left, top, width, decorator_fn)
	tile_h_line(map, model, left, top + height - 1, width, decorator_fn)
	tile_v_line(map, model, left, top, height, decorator_fn)
	tile_v_line(map, model, left + width - 1, top, height, decorator_fn)


## C# DigUntil : dig in a direction while the stop predicate is false.
func dig_until(map: Map, model: TileModel, start_pos: Vector2i, dig_direction: Direction, stop_fn: Callable) -> Vector2i:
	var dig_pos: Vector2i = start_pos

	while map.is_in_bounds_p(dig_pos) && not stop_fn.call(dig_pos):
		# set tile.
		map.set_tile_model_at(dig_pos.x, dig_pos.y, model)

		# continue digging.
		dig_pos += dig_direction.vector

	return dig_pos


func do_for_each_tile(_map: Map, rect: Rect2i, do_fn: Callable) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			do_fn.call(Vector2i(x, y))


func check_for_each_tile(_map: Map, rect: Rect2i, pred_fn: Callable) -> bool:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if not pred_fn.call(Vector2i(x, y)):
				return false

	return true


func do_for_each_adjacent_in_map(map: Map, pt: Vector2i, do_fn: Callable) -> void:
	for d: Direction in Direction.COMPASS:
		var adj_pt: Vector2i = pt + d.vector
		if not map.is_in_bounds_p(adj_pt):
			continue
		do_fn.call(adj_pt)


# Placing actors

## C# ActorPlace overloads with default rect (whole map).
func actor_place(roller: DiceRoller, max_tries: int, map: Map, actor: Actor, good_position_fn: Callable = Callable()) -> bool:
	return actor_place_in(roller, max_tries, map, actor, 0, 0, map.width, map.height, good_position_fn)


func actor_place_in(roller: DiceRoller, max_tries: int, map: Map, actor: Actor, left: int, top: int, width: int, height: int, good_position_fn: Callable = Callable()) -> bool:
	# try <maxTries> times to find a walkable position and place the actor there.
	var position: Vector2i
	for i in max_tries:
		position = Vector2i(roller.roll(left, left + width), roller.roll(top, top + height))

		if rules.is_walkable_for(actor, map, position.x, position.y).ok \
				&& (not good_position_fn.is_valid() || good_position_fn.call(position)):
			map.place_actor_at(actor, position)
			return true

	# failed.
	return false


# Map Objects

func map_object_place(map: Map, x: int, y: int, map_obj: MapObject) -> void:
	if map.get_map_object_at_xy(x, y) == null:
		map.place_map_object_at(map_obj, Vector2i(x, y))


func map_object_fill_rect(map: Map, rect: Rect2i, create_fn: Callable) -> void:
	map_object_fill(map, rect.position.x, rect.position.y, rect.size.x, rect.size.y, create_fn)


func map_object_fill(map: Map, left: int, top: int, width: int, height: int, create_fn: Callable) -> void:
	for x in range(left, left + width):
		for y in range(top, top + height):
			var new_map_object: MapObject = create_fn.call(Vector2i(x, y))
			if new_map_object != null && map.get_map_object_at_xy(x, y) == null:
				map.place_map_object_at(new_map_object, Vector2i(x, y))


func map_object_place_in_good_position_rect(map: Map, rect: Rect2i, is_good_pos_fn: Callable, roller: DiceRoller, create_fn: Callable) -> void:
	map_object_place_in_good_position(map, rect.position.x, rect.position.y, rect.size.x, rect.size.y, is_good_pos_fn, roller, create_fn)


func map_object_place_in_good_position(map: Map, left: int, top: int, width: int, height: int, is_good_pos_fn: Callable, roller: DiceRoller, create_fn: Callable) -> void:
	# find all good positions.
	var good_list: Array[Vector2i] = []

	for x in range(left, left + width):
		for y in range(top, top + height):
			if is_good_pos_fn.call(Vector2i(x, y)) && map.get_map_object_at_xy(x, y) == null:
				good_list.append(Vector2i(x, y))

	# pick a good position at random and put the object there.
	if good_list.is_empty():
		return
	var i_valid: int = roller.roll(0, good_list.size())
	var map_obj: MapObject = create_fn.call(good_list[i_valid])
	if map_obj != null:
		map.place_map_object_at(map_obj, good_list[i_valid])


# Items

func items_drop(map: Map, rect: Rect2i, is_good_position_fn: Callable, create_fn: Callable) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if is_good_position_fn.call(Vector2i(x, y)):
				var it: Item = create_fn.call(Vector2i(x, y))
				if it != null:
					map.drop_item_at(it, Vector2i(x, y))


# Clearing whole areas

## Remove all Actors, MapOjects, Items, Decorations and Zones in a rect.
func clear_rectangle(map: Map, rect: Rect2i, clear_zones: bool = true) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			map.remove_map_object_at(x, y)

			var stack: Inventory = map.get_items_at_xy(x, y)
			if stack != null:
				while not stack.is_empty:
					map.remove_item_at(stack.items[0], Vector2i(x, y))

			map.get_tile_at(x, y).remove_all_decorations()

			if clear_zones: # alpha10
				map.remove_all_zones_at(x, y)

			var actor_there: Actor = map.get_actor_at_xy(x, y)
			if actor_there != null:
				map.remove_actor(actor_there)


# Predicates and Actions

## Apply an action on each adjacent tiles within map bounds.
func for_each_adjacent(map: Map, x: int, y: int, do_fn: Callable) -> void:
	var p := Vector2i(x, y)

	for d: Direction in Direction.COMPASS:
		var adj: Vector2i = p + d.vector
		if not map.is_in_bounds_p(adj):
			continue

		do_fn.call(adj)


## Count how many adjacent tiles within map bounds match a predicate.
func count_for_each_adjacent(map: Map, x: int, y: int, check_fn: Callable) -> int:
	var count: int = 0
	var p := Vector2i(x, y)

	for d: Direction in Direction.COMPASS:
		var adj: Vector2i = p + d.vector
		if not map.is_in_bounds_p(adj):
			continue
		if check_fn.call(adj):
			count += 1

	return count


func count_adj_walls_xy(map: Map, x: int, y: int) -> int:
	return count_for_each_adjacent(map, x, y, func(pt: Vector2i) -> bool: return not map.get_tile_at(pt.x, pt.y).model.is_walkable)


func count_adj_walls_p(map: Map, p: Vector2i) -> int:
	return count_adj_walls_xy(map, p.x, p.y)


func count_adj_walkables(map: Map, x: int, y: int) -> int:
	return count_for_each_adjacent(map, x, y, func(pt: Vector2i) -> bool: return map.get_tile_at(pt.x, pt.y).model.is_walkable)


func count_adj_doors(map: Map, x: int, y: int) -> int:
	return count_for_each_adjacent(map, x, y, func(pt: Vector2i) -> bool: return map.get_map_object_at_xy(pt.x, pt.y) is DoorWindow)


# alpha10.1
func count_adj_map_objects(map: Map, x: int, y: int) -> int:
	return count_for_each_adjacent(map, x, y, func(pt: Vector2i) -> bool: return map.get_map_object_at_xy(pt.x, pt.y) != null)


func place_if(map: Map, x: int, y: int, floor_model: TileModel, predicate_fn: Callable, create_fn: Callable) -> void:
	if predicate_fn.call(x, y):
		var map_obj: MapObject = create_fn.call(x, y)
		if map_obj == null:
			return
		map.set_tile_model_at(x, y, floor_model)
		map_object_place(map, x, y, map_obj)


func is_accessible(map: Map, x: int, y: int) -> bool:
	return count_for_each_adjacent(map, x, y, func(pt: Vector2i) -> bool: return map.is_walkable(pt.x, pt.y)) >= 6


func has_no_object_at(map: Map, x: int, y: int) -> bool:
	return map.get_map_object_at_xy(x, y) == null


func is_inside(map: Map, x: int, y: int) -> bool:
	return map.get_tile_at(x, y).is_inside


func has_in_range(map: Map, from_pos: Vector2i, max_distance: int, pred_fn: Callable) -> bool:
	var min_corner: Vector2i = map.trim_point_to_bounds(from_pos - Vector2i(max_distance, max_distance))
	var max_corner: Vector2i = map.trim_point_to_bounds(from_pos + Vector2i(max_distance, max_distance))
	for x in range(min_corner.x, max_corner.x + 1):
		for y in range(min_corner.y, max_corner.y + 1):
			if x == from_pos.x && y == from_pos.y:
				continue
			if pred_fn.call(Vector2i(x, y)):
				return true

	return false
