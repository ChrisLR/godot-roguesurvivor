class_name HiScoreTable
extends RefCounted
## Port of Engine/HiScoreTable.cs (contains HiScore + HiScoreTable).
## Save/load uses Godot-native serialization (store_var/get_var)
## instead of .NET BinaryFormatter.


## Port of the HiScore class declared in HiScoreTable.cs.
class HiScore:
	var name: String = ""
	var total_points: int = 0
	var difficulty_percent: int = 0
	var survival_points: int = 0
	var kill_points: int = 0
	var achievement_points: int = 0
	var turn_survived: int = 0
	# C# TimeSpan : kept as seconds.
	var playing_time: float = 0.0
	var skills_description: String = ""
	var death: String = ""


	## C# HiScore.FromScoring(name, sc, skillsDescription).
	## Scoring is not ported yet, so it is passed untyped.
	static func from_scoring(p_name: String, sc, p_skills_description: String) -> HiScore:
		assert(sc != null, "scoring")

		var hi := HiScore.new()
		hi.achievement_points = sc.achievement_points
		hi.death = sc.death_reason
		hi.difficulty_percent = int(100 * sc.difficulty_rating)
		hi.kill_points = sc.kill_points
		hi.name = p_name
		hi.playing_time = sc.real_life_playing_time
		hi.skills_description = p_skills_description
		hi.survival_points = sc.survival_points
		hi.total_points = sc.total_points
		hi.turn_survived = sc.turns_survived
		return hi


	func to_dict() -> Dictionary:
		return {
			"name": name,
			"total_points": total_points,
			"difficulty_percent": difficulty_percent,
			"survival_points": survival_points,
			"kill_points": kill_points,
			"achievement_points": achievement_points,
			"turn_survived": turn_survived,
			"playing_time": playing_time,
			"skills_description": skills_description,
			"death": death,
		}


	static func from_dict(d: Dictionary) -> HiScore:
		var hi := HiScore.new()
		hi.name = d.get("name", "")
		hi.total_points = d.get("total_points", 0)
		hi.difficulty_percent = d.get("difficulty_percent", 0)
		hi.survival_points = d.get("survival_points", 0)
		hi.kill_points = d.get("kill_points", 0)
		hi.achievement_points = d.get("achievement_points", 0)
		hi.turn_survived = d.get("turn_survived", 0)
		hi.playing_time = d.get("playing_time", 0.0)
		hi.skills_description = d.get("skills_description", "")
		hi.death = d.get("death", "")
		return hi


const DEFAULT_MAX_ENTRIES := 12


var _table: Array = []
var _max_entries: int


var count: int:
	get:
		return _table.size()


# Init

func _init(max_entries: int) -> void:
	assert(max_entries >= 1, "maxEntries < 1")
	_table = []
	_max_entries = max_entries


## Fill the table with default empty entries.
func clear() -> void:
	for i: int in _max_entries:
		var hi := HiScore.new()
		hi.death = "no death"
		hi.difficulty_percent = 0
		hi.kill_points = 0
		hi.name = "no one"
		hi.playing_time = 0.0
		hi.survival_points = 0
		hi.total_points = 0
		hi.turn_survived = 0
		hi.skills_description = "no skills"
		_table.append(hi)


# Storing & Retrieving

func register(hi: HiScore) -> bool:
	var i := 0
	while i < _table.size() && _table[i].total_points >= hi.total_points:
		i += 1

	if i > _max_entries:
		return false

	_table.insert(i, hi)
	while _table.size() > _max_entries:
		_table.remove_at(_table.size() - 1)
	return true


func get_score(index: int) -> HiScore:
	assert(index >= 0 && index < _table.size(), "index")
	return _table[index]


# Saving & Loading (Godot-native serialization)

static func save(table, filepath: String) -> bool:
	assert(table != null, "table")
	if filepath == null:
		push_error("saving hiscore table : null filepath")
		return false

	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("saving hiscore table exception: %s (%s)" % [filepath, FileAccess.get_open_error()])
		return false

	var data: Array = []
	for hi: HiScore in table._table:
		data.append(hi.to_dict())
	file.store_var(data)
	file.close()
	return true


## Try to load, null if failed.
static func load_table(filepath: String):
	if filepath == null:
		push_error("loading hiscore table : null filepath")
		return null

	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		# No hiscore file yet (first run): not an error, start with an empty table.
		return null

	var data = file.get_var()
	file.close()
	if not (data is Array):
		push_warning("failed to load hiscore table, bad data.")
		return null

	var table = HiScoreTable.new(DEFAULT_MAX_ENTRIES)
	table._table = []
	for d in data:
		table._table.append(HiScore.from_dict(d))
	return table
