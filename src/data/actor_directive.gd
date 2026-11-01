class_name ActorDirective
extends RefCounted
## Port of Data/ActorDirective.cs (ActorCourage enum + ActorDirective class).
## GDScript allows one global class_name per file, so the enum is a named
## nested enum; C# `ActorCourage.CAUTIOUS` reads `ActorDirective.ActorCourage.CAUTIOUS`.

enum ActorCourage
{
	COWARD,
	CAUTIOUS,
	COURAGEOUS
}

var can_take_items: bool
var can_fire_weapons: bool
var can_throw_grenades: bool
var can_sleep: bool
var can_trade: bool
var courage: ActorCourage


func _init() -> void:
	reset()


func reset() -> void:
	can_take_items = true
	can_fire_weapons = true
	can_throw_grenades = true
	can_sleep = true
	can_trade = true
	courage = ActorCourage.CAUTIOUS


## C# static CourageString(c).
static func courage_string(c: ActorCourage) -> String:
	match c:
		ActorCourage.CAUTIOUS:
			return "Cautious"
		ActorCourage.COURAGEOUS:
			return "Courageous"
		ActorCourage.COWARD:
			return "Coward"
		_:
			push_error("unhandled courage")
			return ""


# --- save system ---
func serialize() -> Dictionary:
	return Session.serialize_scalar_vars(self)


static func deserialize_data(data: Dictionary) -> ActorDirective:
	var d := ActorDirective.new()
	Session.apply_scalar_vars(d, data)
	return d
