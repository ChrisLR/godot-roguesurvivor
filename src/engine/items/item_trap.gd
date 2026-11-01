class_name ItemTrap
extends Item
## Port of Engine/Items/ItemTrap.cs
## A concrete trap item instance.

var _is_activated: bool = false
var _is_triggered: bool = false
# alpha10
var _owner: Actor = null


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemTrapModel, "model is not a TrapModel")


func is_activated() -> bool:
	return _is_activated


var is_triggered: bool:
	get:
		return _is_triggered
	set(value):
		_is_triggered = value


func trap_model() -> ItemTrapModel:
	return model as ItemTrapModel


# alpha10
## Owner of the trap; dead owners are cleaned up on access.
var owner: Actor:
	get:
		# cleanup dead owner reference
		if _owner != null && _owner.is_dead:
			_owner = null
		return _owner


## A new trap of the same model, un-activated, no owner, un-triggered.
func clone() -> ItemTrap:
	var c: ItemTrap = ItemTrap.new(trap_model())
	return c


# alpha10
## Activating/Desactivating
func activate(p_owner: Actor) -> void:
	_owner = p_owner
	_is_activated = true


func desactivate() -> void:
	_owner = null
	_is_activated = false


# alpha10
## Pre-saving
func optimize_before_saving() -> void:
	super.optimize_before_saving()

	# cleanup dead owner ref
	if _owner != null && _owner.is_dead:
		_owner = null


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["is_activated"] = _is_activated
	d["is_triggered"] = _is_triggered
	d["owner"] = Session.actor_ref(_owner)


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	_is_activated = d.get("is_activated", false)
	_is_triggered = d.get("is_triggered", false)
	var it := self
	_pending_refs.append([func(a): it._owner = a, d.get("owner")])
