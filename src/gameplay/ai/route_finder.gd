class_name RouteFinder
extends RefCounted
## Port of Gameplay/AI/Tools/RouteFinder.cs
## A very simple and restricted pathfinder that just checks if an actor ai
## can reach a tile. Only explores tiles that are closer to the goal
## (mimicking BaseAI behavior_bump_toward) and within a max distance from start.
## Not meant to be persistent; each BaseAI should use an instance.

class RouteNode:
	var is_visited: bool = false
	var pos: Vector2i
	var dist_to_goal: int


## Allowed actions when blocked by a map object. Will ask game rules for validity.
enum SpecialActions {
	NONE = 0,
	## Allowed to try to open doors.
	DOORS = (1 << 0),
	## Allowed to try jump on jumpables.
	JUMP = (1 << 1),
	## Allowed to try push pushable objects.
	PUSH = (1 << 2),
	## Allowed to try to break objects eg: break blocking doors.
	BREAK = (1 << 3),
	## Any tile adj to dest is a goal, not only the dest itself.
	ADJ_TO_DEST_IS_GOAL = (1 << 4),
}

var _ai: BaseAI
## Open list as a binary min-heap keyed on dist_to_goal (like an A* open list),
## plus a position index for O(1) node lookup. Replaces the old sorted Array,
## whose linear scans made the search O(n^2).
var _heap: Array[RouteNode] = []
var _node_map: Dictionary = {}  # Vector2i -> RouteNode

## Actions the RouteFinder for this AI is allowed to try when checking route.
var allowed_actions: int = SpecialActions.NONE


func _init(ai: BaseAI) -> void:
	_ai = ai


func _make_node(pos: Vector2i, dist_to_goal: int) -> RouteNode:
	var n := RouteNode.new()
	n.pos = pos
	n.dist_to_goal = dist_to_goal
	return n


## Can the BaseAI expect to reach this destination by using its simple
## movement logic behavior_bump_toward.
func can_reach_simple(game: RogueGame, dest: Vector2i, max_dist: int, distance_fn: Callable) -> bool:
	var a: Actor = _ai.controlled_actor
	var start: Vector2i = a.location.position
	var map: Map = a.location.map

	# trivial case of starting adj to dest.
	var adj_to_dest_is_goal: bool = (allowed_actions & SpecialActions.ADJ_TO_DEST_IS_GOAL) != 0
	if distance_fn.call(start, dest) == 1:
		if adj_to_dest_is_goal:
			return true
		return can_move_in(game, a, map, dest)

	# search similar to A*...
	_heap.clear()
	_node_map.clear()
	var start_node := _make_node(start, distance_fn.call(start, dest))
	_heap_push(start_node)
	_node_map[start] = start_node
	# Safety cap: exploration is bounded by map size + strictly-decreasing
	# distance, but never loop unbounded if that invariant ever breaks.
	var iterations := 0
	const MAX_ITERATIONS := 100000
	while not _heap.is_empty():
		iterations += 1
		if iterations > MAX_ITERATIONS:
			push_warning("RouteFinder.can_reach_simple: iteration cap hit, giving up.")
			return false
		# get most promising node: min dist_to_goal in the heap.
		var current: RouteNode = _heap_pop()
		if current.pos == dest:
			return true  # found goal
		if adj_to_dest_is_goal and distance_fn.call(current.pos, dest) == 1:
			return true  # found adj to goal
		if current.is_visited:
			continue
		current.is_visited = true

		# explore this node by looking at adj tiles.
		# only explore tiles that are not too far, closer to the goal and can be moved in.
		var current_dist_to_goal: int = distance_fn.call(current.pos, dest)
		for dir in Direction.COMPASS:
			var adj: Vector2i = current.pos + dir.vector
			if not map.is_in_bounds_p(adj):
				continue
			var adj_dist_to_goal: int = distance_fn.call(adj, dest)
			if adj_dist_to_goal >= current_dist_to_goal or adj_dist_to_goal > max_dist:
				continue
			if not can_move_in(game, a, map, adj):
				continue
			# skip tiles already in the open list or already explored.
			if _node_map.has(adj):
				continue
			var adj_node := _make_node(adj, adj_dist_to_goal)
			_heap_push(adj_node)
			_node_map[adj] = adj_node
	return false


## Push a node onto the open-list heap, keyed on dist_to_goal.
func _heap_push(n: RouteNode) -> void:
	_heap.append(n)
	var i: int = _heap.size() - 1
	while i > 0:
		var parent: int = (i - 1) / 2
		if _heap[parent].dist_to_goal <= _heap[i].dist_to_goal:
			break
		var tmp: RouteNode = _heap[parent]
		_heap[parent] = _heap[i]
		_heap[i] = tmp
		i = parent


## Pop the node with the smallest dist_to_goal from the heap.
func _heap_pop() -> RouteNode:
	var top: RouteNode = _heap[0]
	var last: RouteNode = _heap.pop_back()
	if not _heap.is_empty():
		_heap[0] = last
		var i := 0
		while true:
			var l: int = i * 2 + 1
			var r: int = l + 1
			var smallest: int = i
			if l < _heap.size() and _heap[l].dist_to_goal < _heap[smallest].dist_to_goal:
				smallest = l
			if r < _heap.size() and _heap[r].dist_to_goal < _heap[smallest].dist_to_goal:
				smallest = r
			if smallest == i:
				break
			var tmp: RouteNode = _heap[smallest]
			_heap[smallest] = _heap[i]
			_heap[i] = tmp
			i = smallest
	return top


## Check if actor can move in this tile.
## As per map.is_walkable_p() check only tile and mapobject, ignore actors.
func can_move_in(game: RogueGame, a: Actor, map: Map, pos: Vector2i) -> bool:
	# check tile & mapobj.
	if map.is_walkable_p(pos):
		return true

	var mobj: MapObject = map.get_map_object_at(pos)
	if mobj == null:
		# blocked by a wall tile.
		return false

	# blocked by a mapobj, can we operate it?

	# ... a door?
	if (allowed_actions & SpecialActions.DOORS) != 0:
		var door: DoorWindow = mobj as DoorWindow
		if door != null:
			# open?
			if game.rules.is_openable_for(a, door)["ok"]:
				return true
			# break?
			if (allowed_actions & SpecialActions.BREAK) != 0 and game.rules.is_breakable_for(a, door)["ok"]:
				return true
			# nope, blocked by door.
			return false

	# ... a jumpable?
	if (allowed_actions & SpecialActions.JUMP) != 0 and mobj.is_jumpable and game.rules.has_actor_jump_ability(a):
		return true

	# ... a pushable?
	if (allowed_actions & SpecialActions.PUSH) != 0 and game.rules.can_actor_push(a, mobj):
		return true

	# ... a breakable?
	if (allowed_actions & SpecialActions.BREAK) != 0 and game.rules.is_breakable_for(a, mobj)["ok"]:
		return true

	# blocked by a mapobject we can't handle.
	return false
