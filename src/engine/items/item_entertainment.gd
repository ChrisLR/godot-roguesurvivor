class_name ItemEntertainment
extends Item
## Port of Engine/Items/ItemEntertainment.cs
## A concrete entertainment item instance.

# alpha10 boring items moved out of Actor
var _boring_for = null  # null or Array of Actor; C# uses a nullable List.


func entertainment_model() -> ItemEntertainmentModel:
	return model as ItemEntertainmentModel


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemEntertainmentModel, "model is not a EntertainmentModel")


# alpha10 boring items moved out of Actor

func add_boring_for(a: Actor) -> void:
	if _boring_for == null:
		_boring_for = []
	if _boring_for.has(a):
		return
	_boring_for.append(a)


func is_boring_for(a: Actor) -> bool:
	if _boring_for == null:
		return false
	return _boring_for.has(a)


# alpha10
## Pre-saving
func optimize_before_saving() -> void:
	super.optimize_before_saving()

	# clean up dead actors refs
	# side effect: revived actors will forget about boring items
	if _boring_for != null:
		var i: int = 0
		while i < _boring_for.size():
			if _boring_for[i].is_dead:
				_boring_for.remove_at(i)
			else:
				i += 1
		if _boring_for.is_empty():
			_boring_for = null


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	if _boring_for == null:
		d["boring_for"] = null
	else:
		var refs := []
		for a in _boring_for:
			refs.append(Session.actor_ref(a))
		d["boring_for"] = refs


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	var refs = d.get("boring_for", null)
	if refs == null:
		_boring_for = null
	else:
		var it := self
		_pending_refs.append([func(arr):
			var actors := []
			for r in arr:
				actors.append(r)
			it._boring_for = actors, refs])


func resolve_refs(world: World) -> void:
	super.resolve_refs(world)
