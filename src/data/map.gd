class_name Map
extends RefCounted
## Port of Data/Map.cs
## A playable map : tiles, exits, zones, actors, map objects, ground items,
## corpses, scents and timers.
##
## Also contains the Exit class and the Lighting enum, which are declared in
## the same C# file (access them as Map.Exit and Map.Lighting).

## Port of the Exit class declared in Map.cs.
class Exit:
	var to_map: Map
	var to_position: Vector2i
	## Can be used by AIs.
	var is_an_ai_exit: bool = false

	func _init(p_to_map: Map, p_to_position: Vector2i) -> void:
		to_map = p_to_map
		to_position = p_to_position


## Port of the Lighting enum declared in Map.cs.
enum Lighting {
	DARKNESS = 0, # _FIRST
	OUTSIDE,
	LIT,
	_LAST,
}

const GROUND_INVENTORY_SLOTS = 10

# Primary data : serialize (Godot-native save format).
@warning_ignore("shadowed_global_identifier")
var seed: int
var district: District = null
var name: String
var bg_music: String # alpha10
var lighting: Lighting = Lighting.DARKNESS
var local_time: WorldTime

var width: int
var height: int
var rect: Rect2i

## Tiles are stored row-major as tiles[x][y] (C# Tile[width, height]).
var tiles: Array = []

var exits: Dictionary = {} # Vector2i -> Exit

var zones: Array[Zone] = []

var actors_list: Array[Actor] = []
var check_next_actor_index: int = 0
var map_objects_list: Array[MapObject] = []
var ground_items_by_position: Dictionary = {} # Vector2i -> Inventory

var corpses_list: Array[Corpse] = []

## All scents, there is only one scent by odor possible at each location :
## identical odors combine their strength.
var scents: Array[Odor.OdorScent] = []

var timers: Array[TimedTask] = []

# Auxiliary data : don't serialize, reconstruct at load time AFTER the Session
# has been deserialized (see reconstruct_auxiliary_fields).
var aux_actors_by_position: Dictionary = {} # Vector2i -> Actor
var aux_map_objects_by_position: Dictionary = {} # Vector2i -> MapObject
var aux_ground_items_list: Array[Inventory] = []
var aux_corpses_by_position: Dictionary = {} # Vector2i -> Array[Corpse]
# scent hash
var aux_scents_by_position: Dictionary = {} # Vector2i -> Array[Odor.OdorScent]


var is_secret: bool = false


# Counters (C# Count* properties)

var count_exits: int:
	get:
		return exits.size()


var count_actors: int:
	get:
		return actors_list.size()


var count_corpses: int:
	get:
		return corpses_list.size()


var count_timers: int:
	get:
		return 0 if timers == null else timers.size()


# Init

func _init(p_seed: int, p_name: String, p_width: int, p_height: int) -> void:
	assert(p_name != null, "name")
	assert(p_width > 0, "width <=0")
	assert(p_height > 0, "height <=0")

	seed = p_seed
	name = p_name
	width = p_width
	height = p_height
	rect = Rect2i(0, 0, width, height)
	local_time = WorldTime.new()
	lighting = Lighting.OUTSIDE
	is_secret = false

	tiles = []
	for x in width:
		tiles.append([])
		tiles[x].resize(height)
		for y in height:
			tiles[x][y] = Tile.new(TileModel.UNDEF)

	exits = {}

	zones = []

	aux_actors_by_position = {}
	actors_list = []

	aux_map_objects_by_position = {}
	map_objects_list = []

	ground_items_by_position = {}
	aux_ground_items_list = []

	corpses_list = []
	aux_corpses_by_position = {}

	scents = []
	aux_scents_by_position = {}

	timers = []


# Bounds

func is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 && x < width && y >= 0 && y < height


func is_in_bounds_p(p: Vector2i) -> bool:
	return is_in_bounds(p.x, p.y)


## C# TrimToBounds(ref int, ref int) -> returns the trimmed coordinates.
func trim_to_bounds(x: int, y: int) -> Vector2i:
	if x < 0:
		x = 0
	elif x > width - 1:
		x = width - 1

	if y < 0:
		y = 0
	elif y > height - 1:
		y = height - 1

	return Vector2i(x, y)


## C# TrimToBounds(ref Point) -> returns the trimmed position.
func trim_point_to_bounds(p: Vector2i) -> Vector2i:
	return trim_to_bounds(p.x, p.y)


func is_map_boundary(x: int, y: int) -> bool:
	return x == -1 || x == width || y == -1 || y == height


func is_on_map_border(x: int, y: int) -> bool:
	return x == 0 || x == width - 1 || y == 0 || y == height - 1


# Tiles

func get_tile_at(x: int, y: int) -> Tile:
	if not is_in_bounds(x, y):
		return null
	return tiles[x][y]


func get_tile_at_p(p: Vector2i) -> Tile:
	return get_tile_at(p.x, p.y)


func set_tile_model_at(x: int, y: int, model: TileModel) -> void:
	assert(is_in_bounds(x, y), "position out of map bounds")
	assert(model != null, "model")

	tiles[x][y].model = model


# Exits

func get_exit_at(p: Vector2i) -> Exit:
	return exits.get(p)


func get_exit_at_xy(x: int, y: int) -> Exit:
	return get_exit_at(Vector2i(x, y))


func set_exit_at(p: Vector2i, exit: Exit) -> void:
	assert(not exits.has(p), "an exit already exists at this position")
	exits[p] = exit


func remove_exit_at(p: Vector2i) -> void:
	exits.erase(p)


func has_an_exit_in(r: Rect2i) -> bool:
	for x in range(r.position.x, r.end.x):
		for y in range(r.position.y, r.end.y):
			if get_exit_at_xy(x, y) != null:
				return true
	return false


## C# returns Point? -> Vector2i or null.
func get_exit_pos(exit: Exit) -> Variant:
	if exit == null:
		return null
	for p: Vector2i in exits:
		if exits[p] == exit:
			return p
	return null


# Zones

func add_zone(zone: Zone) -> void:
	zones.append(zone)


func remove_zone(zone: Zone) -> void:
	zones.erase(zone)


func remove_all_zones_at(x: int, y: int) -> void:
	var zs: Array[Zone] = get_zones_at(x, y)
	if zs == null:
		return
	for z: Zone in zs:
		remove_zone(z)


## null if no zone there.
func get_zones_at(x: int, y: int) -> Array[Zone]:
	var list: Array[Zone] = []

	for zone: Zone in zones:
		if zone.bounds.has_point(Vector2i(x, y)):
			list.append(zone)

	return list


func get_zone_by_name(p_name: String) -> Zone:
	for zone: Zone in zones:
		if zone.name == p_name:
			return zone
	return null


func get_zone_by_partial_name(part_of_name: String) -> Zone:
	for zone: Zone in zones:
		if zone.name.contains(part_of_name):
			return zone
	return null


func has_zone_partially_named_at(pos: Vector2i, part_of_name: String) -> bool:
	var zs: Array[Zone] = get_zones_at(pos.x, pos.y)
	if zs == null:
		return false

	for z: Zone in zs:
		if z.name.contains(part_of_name):
			return true

	return false


# Actors

func has_actor(actor: Actor) -> bool:
	return actors_list.has(actor)


func get_actor(index: int) -> Actor:
	return actors_list[index]


func get_actor_at(position: Vector2i) -> Actor:
	return aux_actors_by_position.get(position)


func get_actor_at_xy(x: int, y: int) -> Actor:
	return get_actor_at(Vector2i(x, y))


## Add or move an actor to a position.
func place_actor_at(actor: Actor, position: Vector2i) -> void:
	assert(actor != null, "actor")
	var other: Actor = get_actor_at(position)
	assert(other != actor, "actor already at position")
	assert(other == null, "another actor already at position")
	assert(is_in_bounds(position.x, position.y), "position out of map bounds")

	if has_actor(actor):
		aux_actors_by_position.erase(actor.location.position)
	else:
		actors_list.append(actor)
	aux_actors_by_position[position] = actor
	actor.location = Location.new(self, position)

	# reset check actor index, as it is now invalidated.
	check_next_actor_index = 0


func move_actor_to_first_position(actor: Actor) -> void:
	assert(actors_list.has(actor), "actor not in map")

	actors_list.erase(actor)
	if actors_list.is_empty():
		actors_list.append(actor)
	else:
		actors_list.insert(0, actor)

	# reset check actor index, as it is now invalidated.
	check_next_actor_index = 0


func remove_actor(actor: Actor) -> void:
	if not actors_list.has(actor):
		return

	actors_list.erase(actor)
	aux_actors_by_position.erase(actor.location.position)

	# reset check actor index, as it is now invalidated.
	check_next_actor_index = 0


# Map Objects

func has_map_object(map_obj: MapObject) -> bool:
	return map_objects_list.has(map_obj)


func get_map_object_at(position: Vector2i) -> MapObject:
	return aux_map_objects_by_position.get(position)


func get_map_object_at_xy(x: int, y: int) -> MapObject:
	return get_map_object_at(Vector2i(x, y))


func place_map_object_at(map_obj: MapObject, position: Vector2i) -> void:
	assert(map_obj != null, "actor")
	var other: MapObject = get_map_object_at(position)
	if other == map_obj:
		return
	# NOTE: the C# original re-tests (other == mapObj) here and throws, but
	# that branch is unreachable after the early return above.
	assert(other == null, "another mapObject already at position")
	assert(is_in_bounds(position.x, position.y), "position out of map bounds")
	assert(get_tile_at(position.x, position.y).model.is_walkable, "cannot place map objects on unwalkable tiles")

	if has_map_object(map_obj):
		aux_map_objects_by_position.erase(map_obj.location.position)
	else:
		map_objects_list.append(map_obj)
	aux_map_objects_by_position[position] = map_obj
	map_obj.location = Location.new(self, position)


func remove_map_object_at(x: int, y: int) -> void:
	var o: MapObject = get_map_object_at_xy(x, y)
	if o == null:
		return

	map_objects_list.erase(o)
	aux_map_objects_by_position.erase(Vector2i(x, y))


# Items

func get_items_at(position: Vector2i) -> Inventory:
	if not is_in_bounds_p(position):
		return null

	return ground_items_by_position.get(position)


func get_items_at_xy(x: int, y: int) -> Inventory:
	return get_items_at(Vector2i(x, y))


## C# returns Point? -> Vector2i or null.
func get_ground_inventory_position(ground_inv: Inventory) -> Variant:
	for p: Vector2i in ground_items_by_position:
		if ground_items_by_position[p] == ground_inv:
			return p

	return null


func drop_item_at(it: Item, position: Vector2i) -> void:
	assert(it != null, "item")
	assert(is_in_bounds_p(position), "position out of map bounds")

	var inv_there: Inventory = get_items_at(position)
	if inv_there == null:
		inv_there = Inventory.new(GROUND_INVENTORY_SLOTS)
		aux_ground_items_list.append(inv_there)
		ground_items_by_position[position] = inv_there
		inv_there.add_all(it)
	else:
		if inv_there.is_full:
			# ground is full, first try to stack as much as possible then if necessary remove oldest item.

			var prev_quantity: int = it.quantity
			var result: Dictionary = inv_there.add_as_much_as_possible(it)
			var quantity_added: int = result.added

			if quantity_added < prev_quantity:
				# could not stack everything, remove oldest ground item and add the remaining quantity.
				inv_there.remove_all_quantity(inv_there.bottom_item)
				inv_there.add_as_much_as_possible(it)
		else:
			inv_there.add_all(it)


func drop_item_at_xy(it: Item, x: int, y: int) -> void:
	drop_item_at(it, Vector2i(x, y))


func remove_item_at(it: Item, position: Vector2i) -> void:
	assert(it != null, "item")
	assert(is_in_bounds_p(position), "position out of map bounds")

	var inv_there: Inventory = get_items_at(position)
	assert(inv_there != null, "no items at this position")
	assert(inv_there.contains(it), "item not at this position")

	inv_there.remove_all_quantity(it)

	if inv_there.is_empty:
		ground_items_by_position.erase(position)
		aux_ground_items_list.erase(inv_there)
		inv_there = null


func remove_item_at_xy(it: Item, x: int, y: int) -> void:
	remove_item_at(it, Vector2i(x, y))


func remove_all_items_at(position: Vector2i) -> void:
	var inv_there: Inventory = get_items_at(position)
	if inv_there == null:
		return
	ground_items_by_position.erase(position)
	aux_ground_items_list.erase(inv_there)


# Corpses

## null if no corpses there.
func get_corpses_at(p: Vector2i):
	return aux_corpses_by_position.get(p)


func get_corpses_at_xy(x: int, y: int):
	return get_corpses_at(Vector2i(x, y))


func has_corpse(c: Corpse) -> bool:
	return corpses_list.has(c)


func add_corpse_at(c: Corpse, p: Vector2i) -> void:
	assert(not corpses_list.has(c), "corpse already in this map")

	c.position = p
	corpses_list.append(c)
	_insert_corpse_at_pos(c)

	# make sure the dead actor follows!
	c.dead_guy.location = Location.new(self, p)


func move_corpse_to(c: Corpse, new_pos: Vector2i) -> void:
	assert(corpses_list.has(c), "corpse not in this map")

	_remove_corpse_from_pos(c)
	c.position = new_pos
	_insert_corpse_at_pos(c)

	# make sure the dead actor follows!
	c.dead_guy.location = Location.new(self, new_pos)


func remove_corpse(c: Corpse) -> void:
	assert(corpses_list.has(c), "corpse not in this map")

	corpses_list.erase(c)
	_remove_corpse_from_pos(c)


func try_remove_corpse_of(a: Actor) -> bool:
	var i: int = 0
	while i < corpses_list.size():
		if corpses_list[i].dead_guy == a:
			remove_corpse(corpses_list[i])
			return true
		else:
			i += 1
	return false


func _remove_corpse_from_pos(c: Corpse) -> void:
	var list = aux_corpses_by_position.get(c.position)
	if list != null:
		list.erase(c)
		if list.is_empty():
			aux_corpses_by_position.erase(c.position)


func _insert_corpse_at_pos(c: Corpse) -> void:
	var list = aux_corpses_by_position.get(c.position)
	if list != null:
		list.insert(0, c)
	else:
		var new_list: Array[Corpse] = [c]
		aux_corpses_by_position[c.position] = new_list


# Timers

func add_timer(t: TimedTask) -> void:
	if timers == null:
		timers = []
	timers.append(t)


func remove_timer(t: TimedTask) -> void:
	timers.erase(t)


# Odors

func get_scent_by_odor_at(odor: int, position: Vector2i) -> int:
	if not is_in_bounds_p(position):
		return 0

	var scent: Odor.OdorScent = _get_scent_by_odor(odor, position)

	return 0 if scent == null else scent.strength


func _get_scent_by_odor(odor: int, p: Vector2i) -> Odor.OdorScent:
	var scents_there = aux_scents_by_position.get(p)
	if scents_there != null:
		for scent: Odor.OdorScent in scents_there:
			if scent.odor == odor:
				return scent
		return null
	else:
		return null


func _add_new_scent(scent: Odor.OdorScent) -> void:
	# list
	if not scents.has(scent):
		scents.append(scent)

	# hash
	var scents_there = aux_scents_by_position.get(scent.position)
	if scents_there != null:
		scents_there.append(scent)
	else:
		var new_list: Array[Odor.OdorScent] = [scent]
		aux_scents_by_position[scent.position] = new_list


## Adds or merge a scent.
func modify_scent_at(odor: int, strength_change: int, position: Vector2i) -> void:
	assert(is_in_bounds_p(position), "position")

	var old_scent: Odor.OdorScent = _get_scent_by_odor(odor, position)
	if old_scent == null:
		# new odor there.
		var new_scent := Odor.OdorScent.new(odor, strength_change, position)
		_add_new_scent(new_scent)
	else:
		# existing odor here.
		old_scent.change(strength_change)


## Sets odor strength to new strength if is it stronger (more "fresh").
func refresh_scent_at(odor: int, fresh_strength: int, position: Vector2i) -> void:
	assert(is_in_bounds_p(position), "position; (%d,%d) map %s odor %s" % [position.x, position.y, name, odor])

	var old_scent: Odor.OdorScent = _get_scent_by_odor(odor, position)
	if old_scent == null:
		# new odor there.
		var new_scent := Odor.OdorScent.new(odor, fresh_strength, position)
		_add_new_scent(new_scent)
	else:
		# existing odor here.
		if old_scent.strength < fresh_strength:
			old_scent.set_(fresh_strength)


func remove_scent(scent: Odor.OdorScent) -> void:
	# list.
	scents.erase(scent)

	# hash.
	var scents_there = aux_scents_by_position.get(scent.position)
	if scents_there != null:
		scents_there.erase(scent)
		if scents_there.is_empty():
			aux_scents_by_position.erase(scent.position)


# View & Visit

## Set all tiles property visible to false.
func clear_view() -> void:
	for x in width:
		for y in height:
			tiles[x][y].is_in_view = false


func set_view(visible_positions: Array) -> void:
	clear_view()
	for pt: Vector2i in visible_positions:
		assert(is_in_bounds(pt.x, pt.y), "point %s not in map bounds" % pt)
		tiles[pt.x][pt.y].is_in_view = true


func mark_as_visited(positions: Array) -> void:
	for pt: Vector2i in positions:
		assert(is_in_bounds(pt.x, pt.y), "point %s not in map bounds" % pt)
		tiles[pt.x][pt.y].is_visited = true


func set_view_and_mark_visited(visible_positions: Array) -> void:
	clear_view()
	for pt: Vector2i in visible_positions:
		assert(is_in_bounds(pt.x, pt.y), "point %s not in map bounds" % pt)
		tiles[pt.x][pt.y].is_in_view = true
		tiles[pt.x][pt.y].is_visited = true


## Sets all the tiles as visited, usefull cheat for debugging.
func set_all_as_visited() -> void:
	for x in width:
		for y in height:
			tiles[x][y].is_visited = true


func set_all_as_unvisited() -> void:
	for x in width:
		for y in height:
			tiles[x][y].is_visited = false


# Helpers for transparency, walkable && fire line.

## Helper that checks for tile transparency : check tile model and check map object.
func is_transparent(x: int, y: int) -> bool:
	if not is_in_bounds(x, y):
		return false

	if not tiles[x][y].model.is_transparent:
		return false

	var map_obj: MapObject = get_map_object_at_xy(x, y)
	if map_obj == null:
		return true
	return map_obj.is_transparent()


## Helper that checks if tile is walkable : check tile model and check map object.
func is_walkable(x: int, y: int) -> bool:
	if not is_in_bounds(x, y):
		return false

	if not tiles[x][y].model.is_walkable:
		return false

	var map_obj: MapObject = get_map_object_at_xy(x, y)
	if map_obj == null:
		return true
	return map_obj.is_walkable


func is_walkable_p(p: Vector2i) -> bool:
	return is_walkable(p.x, p.y)


## Helper that checks if tile is blocking fire. Checks for tile model, map
## object and actor.
## Blocked by:
## - Non transparent tile model (eg: wall).
## - Non transparent map object.
## - Any actor.
func is_blocking_fire(x: int, y: int) -> bool:
	if not is_in_bounds(x, y):
		return true

	# - Non transparent tile model (eg: wall)
	if not tiles[x][y].model.is_transparent:
		return true

	# - Non transparent map object.
	var map_obj: MapObject = get_map_object_at_xy(x, y)
	if map_obj != null && not map_obj.is_transparent():
		return true

	# - Any actor.
	var actor: Actor = get_actor_at_xy(x, y)
	if actor != null:
		return true

	# all clear.
	return false


## Helper that checks if tile is blocking a throw.
## Blocked by :
## - Unwalkable tiles (eg: walls).
## - Blocking objects : not walkable (eg:closed doors, shelves...) and not jumpables (eg: burning cars...)
func is_blocking_throw(x: int, y: int) -> bool:
	if not is_in_bounds(x, y):
		return true

	# - Unwalkable tiles (eg: walls).
	if not tiles[x][y].model.is_walkable:
		return true

	# - Blocking objects : not walkable (eg:closed doors, shelves...) and not jumpables (eg: burning cars...)
	var map_obj: MapObject = get_map_object_at_xy(x, y)
	if map_obj != null:
		if not map_obj.is_walkable && not map_obj.is_jumpable:
			return true

	# all clear.
	return false


# Predicates helpers

## Makes a list of all adjacent positions in map matching a predicate.
## null if no match.
func filter_adjacent_in_map(position: Vector2i, predicate_fn: Callable):
	if not is_in_bounds_p(position):
		return null

	var list = null
	for d: Direction in Direction.COMPASS:
		var next: Vector2i = position + d.vector

		if is_in_bounds_p(next) && predicate_fn.call(next):
			if list == null:
				list = []
			list.append(next)

	return list


## Checks if at least one adjacent position in map match a predicate.
func has_any_adjacent_in_map(position: Vector2i, predicate_fn: Callable) -> bool:
	if not is_in_bounds_p(position):
		return false

	for d: Direction in Direction.COMPASS:
		var next: Vector2i = position + d.vector

		if is_in_bounds_p(next) && predicate_fn.call(next):
			return true

	return false


## Count how many adjacent positions in map match a predicate.
func count_adjacent_in_map(position: Vector2i, predicate_fn: Callable) -> int:
	if not is_in_bounds_p(position):
		return 0

	var count: int = 0
	for d: Direction in Direction.COMPASS:
		var next: Vector2i = position + d.vector

		if is_in_bounds_p(next) && predicate_fn.call(next):
			count += 1

	return count


## Apply a fonction on each adjacent tiles in map.
func for_each_adjacent_in_map(position: Vector2i, fn: Callable) -> void:
	if not is_in_bounds_p(position):
		return

	for d: Direction in Direction.COMPASS:
		var next: Vector2i = position + d.vector

		if is_in_bounds_p(next):
			fn.call(next)


## C# returns Point? -> Vector2i or null.
func find_first_in_map(predicate_fn: Callable) -> Variant:
	for x in width:
		for y in height:
			var p := Vector2i(x, y)
			if predicate_fn.call(p):
				return p

	return null


# Load reconstruction
## Reconstruct auxiliary fields at load time, after the Session has been
## deserialized (replaces the C# deserialization constructor machinery).
func reconstruct_auxiliary_fields() -> void:
	aux_actors_by_position = {}
	for a: Actor in actors_list:
		aux_actors_by_position[a.location.position] = a

	aux_ground_items_list = []
	for inv: Inventory in ground_items_by_position.values():
		aux_ground_items_list.append(inv)

	aux_map_objects_by_position = {}
	for obj: MapObject in map_objects_list:
		aux_map_objects_by_position[obj.location.position] = obj

	aux_scents_by_position = {}
	for scent: Odor.OdorScent in scents:
		var list_here = aux_scents_by_position.get(scent.position)
		if list_here != null:
			list_here.append(scent)
		else:
			var new_list: Array[Odor.OdorScent] = [scent]
			aux_scents_by_position[scent.position] = new_list

	aux_corpses_by_position = {}
	for corpse: Corpse in corpses_list:
		var list_here = aux_corpses_by_position.get(corpse.position)
		if list_here != null:
			list_here.append(corpse)
		else:
			var new_list: Array[Corpse] = [corpse]
			aux_corpses_by_position[corpse.position] = new_list


# Pre-saving

func optimize_before_saving() -> void:
	# tiles
	for x in width:
		for y in height:
			tiles[x][y].optimize_before_saving()

	# alpha10 items stacks
	for stack: Inventory in ground_items_by_position.values():
		stack.optimize_before_saving()

	# actors
	for a: Actor in actors_list:
		a.optimize_before_saving()

	# lists : C# TrimExcess() calls are capacity-only, nothing to do in GDScript.


# --- save system ---
## Pending exit destination references (position -> map ref), resolved by
## resolve_refs() once the whole world graph exists. In-memory only.
var _exit_refs: Array = []


func serialize() -> Dictionary:
	var tile_data := []
	tile_data.resize(width * height)
	var i := 0
	for x in width:
		for y in height:
			tile_data[i] = tiles[x][y].serialize()
			i += 1
	var exit_data := []
	for pos in exits:
		var ex: Exit = exits[pos]
		exit_data.append({
			"x": pos.x,
			"y": pos.y,
			"to_map": Session.map_ref(ex.to_map),
			"to_x": ex.to_position.x,
			"to_y": ex.to_position.y,
			"is_an_ai_exit": ex.is_an_ai_exit,
		})
	var zone_data := []
	for z in zones:
		zone_data.append(z.serialize())
	var actor_data := []
	for a in actors_list:
		actor_data.append(a.serialize())
	var object_data := []
	for o in map_objects_list:
		object_data.append(o.serialize())
	var ground_data := []
	for pos in ground_items_by_position:
		ground_data.append({
			"x": pos.x,
			"y": pos.y,
			"inventory": ground_items_by_position[pos].serialize(),
		})
	var corpse_data := []
	for c in corpses_list:
		corpse_data.append(c.serialize())
	var scent_data := []
	for s in scents:
		scent_data.append(s.serialize())
	var timer_data := []
	for t in timers:
		timer_data.append(t.serialize())
	return {
		"seed": seed,
		"name": name,
		"bg_music": bg_music,
		"lighting": lighting,
		"local_time": (local_time.serialize() as Variant) if local_time != null else null,
		"width": width,
		"height": height,
		"tiles": tile_data,
		"exits": exit_data,
		"zones": zone_data,
		"actors": actor_data,
		"check_next_actor_index": check_next_actor_index,
		"map_objects": object_data,
		"ground_items": ground_data,
		"corpses": corpse_data,
		"scents": scent_data,
		"timers": timer_data,
		"is_secret": is_secret,
	}


static func deserialize_data(data: Dictionary) -> Map:
	var m := Map.new(data.get("seed", 0), data.get("name", ""),
		data.get("width", 1), data.get("height", 1))
	m.bg_music = data.get("bg_music", "")
	m.lighting = data.get("lighting", Lighting.DARKNESS)
	m.is_secret = data.get("is_secret", false)
	var lt = data.get("local_time")
	m.local_time = WorldTime.deserialize_data(lt) if lt != null else WorldTime.new()
	var tile_data: Array = data.get("tiles", [])
	var i := 0
	for x in m.width:
		for y in m.height:
			if i < tile_data.size():
				m.tiles[x][y] = Tile.deserialize_data(tile_data[i])
			i += 1
	m.exits = {}
	m._exit_refs = []
	for e in data.get("exits", []):
		var pos := Vector2i(e.get("x", 0), e.get("y", 0))
		var ex := Exit.new(null, Vector2i(e.get("to_x", 0), e.get("to_y", 0)))
		ex.is_an_ai_exit = e.get("is_an_ai_exit", false)
		m.exits[pos] = ex
		m._exit_refs.append([pos, e.get("to_map")])
	m.zones = []
	for z in data.get("zones", []):
		m.zones.append(Zone.deserialize_data(z))
	m.actors_list = []
	for a in data.get("actors", []):
		m.actors_list.append(Actor.deserialize_data(a))
	m.check_next_actor_index = data.get("check_next_actor_index", 0)
	m.map_objects_list = []
	for o in data.get("map_objects", []):
		m.map_objects_list.append(MapObject.deserialize_data(o))
	m.ground_items_by_position = {}
	for g in data.get("ground_items", []):
		m.ground_items_by_position[Vector2i(g.get("x", 0), g.get("y", 0))] = Inventory.deserialize_data(g.get("inventory"))
	m.corpses_list = []
	for c in data.get("corpses", []):
		m.corpses_list.append(Corpse.deserialize_data(c))
	m.scents = []
	for s in data.get("scents", []):
		m.scents.append(Odor.OdorScent.deserialize_data(s))
	m.timers = []
	for t in data.get("timers", []):
		m.timers.append(TimedTask.deserialize_data(t))
	return m


## Resolve cross-references after the whole world graph has been built.
func resolve_refs(world: World) -> void:
	for pair in _exit_refs:
		exits[pair[0]].to_map = Session.map_from_ref(world, pair[1])
	_exit_refs.clear()
	for a in actors_list:
		a.resolve_refs(world)
	for o in map_objects_list:
		o.resolve_refs(world)
	for c in corpses_list:
		c.resolve_refs(world)
	for inv in ground_items_by_position.values():
		inv.resolve_refs(world)


## Sever all references at shutdown so the whole map graph (tiles, actors,
## map objects, corpses, exits, ...) can be freed by refcounting.
func shutdown() -> void:
	for a in actors_list:
		a.shutdown()
	actors_list.clear()
	aux_actors_by_position.clear()
	for o in map_objects_list:
		o.shutdown()
	map_objects_list.clear()
	aux_map_objects_by_position.clear()
	for c in corpses_list:
		c.shutdown()
	corpses_list.clear()
	aux_corpses_by_position.clear()
	for inv in ground_items_by_position.values():
		inv.clear_all()
	ground_items_by_position.clear()
	for inv in aux_ground_items_list:
		inv.clear_all()
	aux_ground_items_list.clear()
	for e in exits.values():
		e.to_map = null
	exits.clear()
	_exit_refs.clear()
	tiles.clear()
	zones.clear()
	scents.clear()
	aux_scents_by_position.clear()
	timers.clear()
	district = null
	local_time = null


static var zz_maps := 0
static var zz_actors := 0
