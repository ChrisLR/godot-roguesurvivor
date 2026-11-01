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
## LinkedList<Node> ported as Array kept sorted by dist_to_goal, like A*.
var _nodes: Array[RouteNode] = []

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
	_nodes.clear()
	_nodes.append(_make_node(start, distance_fn.call(start, dest)))
	while true:
		# get most promising node, nodes are sorted by their distance to goal.
		var current_idx: int = -1
		for i: int in _nodes.size():
			if _nodes[i].pos == dest:
				return true  # found goal
			if adj_to_dest_is_goal and distance_fn.call(_nodes[i].pos, dest) == 1:
				return true  # found adj to goal
			if not _nodes[i].is_visited:
				current_idx = i
				break  # visit this one
		# no unvisited node left : out of nodes to explore.
		if current_idx < 0:
			return false

		# explore this node by looking at adj tiles.
		# only explore tiles that are not too far, closer to the goal and can be moved in.
		var current: RouteNode = _nodes[current_idx]
		current.is_visited = true
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
			var adj_node: RouteNode = get_node(adj)
			var explore_it: bool = false
			if adj_node == null:
				# new one to explore.
				adj_node = _make_node(adj, adj_dist_to_goal)
				explore_it = true
			else:
				# explore only if not already explored.
				explore_it = not adj_node.is_visited
			if explore_it:
				insert(adj_node)
	return false


## Insert a new node and keep nodes list sorted on distance to goal.
func insert(new_node: RouteNode) -> void:
	var idx: int = 0
	while idx < _nodes.size() and _nodes[idx].dist_to_goal < new_node.dist_to_goal:
		idx += 1
	_nodes.insert(idx, new_node)


## Get node in list at position, if any. Null if no node there.
func get_node(at: Vector2i) -> RouteNode:
	for n in _nodes:
		if n.pos == at:
			return n
	return null


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
