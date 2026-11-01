class_name Percept
extends RefCounted
## Port of Engine/AI/Percept.cs

var turn: int:
	get:
		return _turn
	set(value):
		_turn = value
var percepted: Variant
var location: Location:
	get:
		return _location
	set(value):
		_location = value

var _turn: int
var _location: Location


func _init(p_percepted: Variant, p_turn: int, p_location: Location) -> void:
	assert(p_percepted != null, "percepted")
	percepted = p_percepted
	_turn = p_turn
	_location = p_location


func get_age(current_game_turn: int) -> int:
	return maxi(0, current_game_turn - _turn)
