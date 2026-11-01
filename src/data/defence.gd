class_name Defence
extends RefCounted
## Port of Data/Defence.cs
## C# struct -> GDScript reference class; operator+/- ported as static add()/sub().

## Blank defence (C# [NonSerialized] static readonly).
static var BLANK: Defence = Defence.new(0, 0, 0)

var value: int
var protection_hit: int
var protection_shot: int


func _init(p_value: int = 0, p_protection_hit: int = 0, p_protection_shot: int = 0) -> void:
	value = p_value
	protection_hit = p_protection_hit
	protection_shot = p_protection_shot


static func add(lhs: Defence, rhs: Defence) -> Defence:
	return Defence.new(lhs.value + rhs.value,
		lhs.protection_hit + rhs.protection_hit,
		lhs.protection_shot + rhs.protection_shot)


static func sub(lhs: Defence, rhs: Defence) -> Defence:
	return Defence.new(lhs.value - rhs.value,
		lhs.protection_hit - rhs.protection_hit,
		lhs.protection_shot - rhs.protection_shot)


# --- save system ---
func serialize() -> Dictionary:
	return Session.serialize_scalar_vars(self)


static func deserialize_data(data: Dictionary) -> Defence:
	var d := Defence.new()
	Session.apply_scalar_vars(d, data)
	return d
