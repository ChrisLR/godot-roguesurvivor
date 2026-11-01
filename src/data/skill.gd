class_name SkillTable
extends RefCounted
## Port of Data/Skill.cs
## Per-actor skill levels, keyed by skill id. The Skill record is an inner
## class (C# had two classes in one file); access it as SkillTable.Skill.

class Skill:
	var id: int
	var level: int = 0

	func _init(p_id: int) -> void:
		id = p_id


# Allocated only if needed (some actors have 0 skills): id -> Skill.
var table: Dictionary = {}


## Get all skills, null if no skills.
func skills():
	if table.is_empty():
		return null
	return table.values()


## List all non-zero skills ids as an array; null if no skills.
func skills_list():
	if table.is_empty():
		return null
	var array: Array[int] = []
	for sk: Skill in table.values():
		array.append(sk.id)
	return array


## Count non-zero skills.
func count_skills() -> int:
	return table.size()


func count_total_skill_levels() -> int:
	var sum := 0
	for sk: Skill in table.values():
		sum += sk.level
	return sum


func _init(starting_skills = null) -> void:
	if starting_skills == null:
		return
	for sk in starting_skills:
		add_skill(sk)


func get_skill(id: int) -> Skill:
	if table.is_empty():
		return null
	return table.get(id)


## Returns 0 for a missing skill.
func get_skill_level(id: int) -> int:
	var sk := get_skill(id)
	if sk == null:
		return 0
	return sk.level


func add_skill(sk: Skill) -> void:
	assert(not table.has(sk.id), "skill of same ID already in table")
	assert(not table.values().has(sk), "skill already in table")

	table[sk.id] = sk


func add_or_increase_skill(id: int) -> void:
	var sk := get_skill(id)
	if sk == null:
		sk = Skill.new(id)
		table[id] = sk

	sk.level += 1


func dec_or_remove_skill(id: int) -> void:
	if table.is_empty():
		return

	var sk := get_skill(id)
	if sk == null:
		return
	sk.level -= 1
	if sk.level <= 0:
		table.erase(id)


# --- save system ---
func serialize() -> Dictionary:
	var skills := []
	for sk in table.values():
		skills.append({"id": sk.id, "level": sk.level})
	return {"skills": skills}


static func deserialize_data(data: Dictionary) -> SkillTable:
	var st := SkillTable.new()
	for s in data.get("skills", []):
		var sk := Skill.new(s.get("id", 0))
		sk.level = s.get("level", 0)
		st.table[sk.id] = sk
	return st
