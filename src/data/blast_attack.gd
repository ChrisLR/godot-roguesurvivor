class_name BlastAttack
extends RefCounted
## Port of Data/BlastAttack.cs
## C# struct -> GDScript reference class.

var radius: int
var damage: Array[int]
var can_damage_objects: bool
var can_destroy_walls: bool


func _init(p_radius: int, p_damage: Array[int], p_can_damage_objects: bool,
		p_can_destroy_walls: bool) -> void:
	assert(p_damage.size() == p_radius + 1, "damage.Length != radius + 1")

	radius = p_radius
	damage = p_damage
	can_damage_objects = p_can_damage_objects
	can_destroy_walls = p_can_destroy_walls
