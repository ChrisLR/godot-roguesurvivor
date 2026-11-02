class_name ActorSheet
extends RefCounted
## Port of Data/ActorSheet.cs
## C# has two constructors (full 11-argument form and copy constructor);
## GDScript has no overloading, so _init takes either an ActorSheet (copy
## path, like the landed actor.gd's ActorSheet.new(model.starting_sheet))
## or the full argument list.

var skill_table: SkillTable = SkillTable.new()

## Blank sheet (C# [NonSerialized] static readonly).
static var BLANK: ActorSheet = ActorSheet.new(0, 0, 0, 0, 0, Attack.BLANK, Defence.BLANK,
	0, 0, 0, 0)

var base_hit_points: int
var base_stamina_points: int
var base_food_points: int
var base_sleep_points: int
var base_sanity: int
var unarmed_attack: Attack
var base_defence: Defence
var base_view_range: int
var base_audio_range: int
var base_smell_rating: float
var base_inventory_capacity: int


func _init(base_hit_points_or_copy: Variant, p_base_stamina_points: int = 0,
		p_base_food_points: int = 0, p_base_sleep_points: int = 0, p_base_sanity: int = 0,
		p_unarmed_attack: Attack = null, p_base_defence: Defence = null,
		p_base_view_range: int = 0, p_base_audio_range: int = 0, smell_rating: int = 0,
		inventory_capacity: int = 0) -> void:
	if base_hit_points_or_copy is ActorSheet:
		# C# copy constructor ActorSheet(copyFrom).
		var copy_from: ActorSheet = base_hit_points_or_copy
		assert(copy_from != null, "copyFrom")

		base_hit_points = copy_from.base_hit_points
		base_stamina_points = copy_from.base_stamina_points
		base_food_points = copy_from.base_food_points
		base_sleep_points = copy_from.base_sleep_points
		base_sanity = copy_from.base_sanity
		unarmed_attack = copy_from.unarmed_attack
		base_defence = copy_from.base_defence
		base_view_range = copy_from.base_view_range
		base_audio_range = copy_from.base_audio_range
		base_smell_rating = copy_from.base_smell_rating
		base_inventory_capacity = copy_from.base_inventory_capacity

		if copy_from.skill_table.skills() != null:
			skill_table = SkillTable.new(copy_from.skill_table.skills())
	else:
		base_hit_points = base_hit_points_or_copy
		base_stamina_points = p_base_stamina_points
		base_food_points = p_base_food_points
		base_sleep_points = p_base_sleep_points
		base_sanity = p_base_sanity
		unarmed_attack = p_unarmed_attack
		base_defence = p_base_defence
		base_view_range = p_base_view_range
		base_audio_range = p_base_audio_range
		base_smell_rating = smell_rating / 100.0
		base_inventory_capacity = inventory_capacity


# --- save system ---
func serialize() -> Dictionary:
	return {
		"skill_table": (skill_table.serialize() as Variant) if skill_table != null else null,
		"base_hit_points": base_hit_points,
		"base_stamina_points": base_stamina_points,
		"base_food_points": base_food_points,
		"base_sleep_points": base_sleep_points,
		"base_sanity": base_sanity,
		"unarmed_attack": (unarmed_attack.serialize() as Variant) if unarmed_attack != null else null,
		"base_defence": (base_defence.serialize() as Variant) if base_defence != null else null,
		"base_view_range": base_view_range,
		"base_audio_range": base_audio_range,
		"base_smell_rating": base_smell_rating,
		"base_inventory_capacity": base_inventory_capacity,
	}


static func deserialize_data(data: Dictionary) -> ActorSheet:
	var s := ActorSheet.new(data.get("base_hit_points", 0),
		data.get("base_stamina_points", 0), data.get("base_food_points", 0),
		data.get("base_sleep_points", 0), data.get("base_sanity", 0))
	var st_data = data.get("skill_table")
	s.skill_table = SkillTable.deserialize_data(st_data) if st_data != null else SkillTable.new()
	var ua = data.get("unarmed_attack")
	s.unarmed_attack = Attack.deserialize_data(ua) if ua != null else null
	var bd = data.get("base_defence")
	s.base_defence = Defence.deserialize_data(bd) if bd != null else null
	s.base_view_range = data.get("base_view_range", 0)
	s.base_audio_range = data.get("base_audio_range", 0)
	s.base_smell_rating = data.get("base_smell_rating", 0.0)
	s.base_inventory_capacity = data.get("base_inventory_capacity", 0)
	return s
