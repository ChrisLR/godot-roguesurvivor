class_name Corpse
extends RefCounted
## Port of Data/Corpse.cs

var dead_guy: Actor
var turn: int
var position: Vector2i
var hit_points: float
var max_hit_points: int
var rotation: float
var scale: float:
	set(value):
		# C# setter clamps to [0, 1].
		scale = maxf(0.0, minf(1.0, value))
var dragged_by: Actor = null


func _init(p_dead_guy: Actor, p_hit_points: int, p_max_hit_points: int, corpse_turn: int,
		p_rotation: float, p_scale: float) -> void:
	dead_guy = p_dead_guy
	turn = corpse_turn
	hit_points = p_hit_points
	max_hit_points = p_max_hit_points
	rotation = p_rotation
	scale = p_scale
	dragged_by = null


func is_dragged() -> bool:
	return dragged_by != null and not dragged_by.is_dead


# --- save system ---
## Pending world-graph references, resolved by resolve_refs() after the whole
## world graph has been deserialized. In-memory only, never saved.
var _pending_refs: Array = []


func serialize() -> Dictionary:
	return {
		"dead_guy": Session.actor_ref(dead_guy),
		"turn": turn,
		"position": position,
		"hit_points": hit_points,
		"max_hit_points": max_hit_points,
		"rotation": rotation,
		"scale": scale,
		"dragged_by": Session.actor_ref(dragged_by),
	}


static func deserialize_data(data: Dictionary) -> Corpse:
	var c := Corpse.new(null, 0, 0, 0, 0.0, 1.0)
	c.turn = data.get("turn", 0)
	c.position = data.get("position", Vector2i())
	c.hit_points = data.get("hit_points", 0.0)
	c.max_hit_points = data.get("max_hit_points", 0)
	c.rotation = data.get("rotation", 0.0)
	c.scale = data.get("scale", 1.0)
	var dg = data.get("dead_guy")
	var cc := c
	c._pending_refs.append([func(a): cc.dead_guy = a, dg])
	c._pending_refs.append([func(a): cc.dragged_by = a, data.get("dragged_by")])
	return c


func resolve_refs(world: World) -> void:
	for pair in _pending_refs:
		pair[0].call(Session.resolve_ref(world, pair[1]))
	_pending_refs.clear()
