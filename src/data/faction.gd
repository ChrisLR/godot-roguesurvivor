class_name Faction
extends RefCounted
## Port of Data/Faction.cs

var id: int = 0
var name: String
var member_name: String
var lead_only_by_same_faction: bool = false
var enemies: Array[Faction] = []


func _init(p_name: String, p_member_name: String) -> void:
	assert(p_name != null, "name")
	assert(p_member_name != null, "memberName")

	name = p_name
	member_name = p_member_name


func add_enemy(other: Faction) -> void:
	enemies.append(other)


func is_enemy_of(other: Faction) -> bool:
	return other != self and enemies.has(other)
