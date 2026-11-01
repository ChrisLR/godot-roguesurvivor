class_name Skills
extends RefCounted
## Port of Gameplay/Skills.cs
## Skill IDs, names and CSV-loaded skill data. Static class.

## [Serializable] enum IDs
## C# aliases (_FIRST_LIVING = _FIRST, ...) are written as explicit values.
enum IDs {
	_FIRST = 0,

	# Living skills

	_FIRST_LIVING = 0, # _FIRST

	## Bonus to melee hit & defence.
	AGILE = 0,

	## Bonus to max sleep.
	AWAKE = 1,

	## Bonus to bows attack.
	BOWS = 2,

	## Bonus to barricading points; can build fortifications, consume less material.
	CARPENTRY = 3,

	## Bonus to trust gain, trade and can steal followers.
	CHARISMATIC = 4,

	## Bonus to firearms attack.
	FIREARMS = 5,

	## Can sleep heal anywhere, increase sleep healing chance.
	HARDY = 6,

	## Bonus to inventory capacity.
	HAULER = 7,

	## Bonus to max stamina.
	HIGH_STAMINA = 8,

	## Bonus to max followers.
	LEADERSHIP = 9,

	## Bonus to max food.
	LIGHT_EATER = 10,

	## Avoid traps.
	LIGHT_FEET = 11,

	## Easier wake up.
	LIGHT_SLEEPER = 12,

	## Better unarmed fighting.
	MARTIAL_ARTS = 13,

	## Bonus to medecine effects.
	MEDIC = 14,

	## Dead things.
	NECROLOGY = 15,

	## Bonus to melee damage.
	STRONG = 16,

	## Sanity resistance.
	STRONG_PSYCHE = 17,

	## Bonus to max HPs
	TOUGH = 18,

	## Bonus to evade murders.
	UNSUSPICIOUS = 19,

	_LAST_LIVING = 19, # UNSUSPICIOUS

	# Undead skills
	_FIRST_UNDEAD = 20,
	Z_AGILE = 20,
	Z_EATER = 21,
	Z_GRAB = 22,
	Z_INFECTOR = 23,
	Z_LIGHT_EATER = 24,
	Z_LIGHT_FEET = 25,
	Z_STRONG = 26,
	Z_TOUGH = 27,
	Z_TRACKER = 28,
	_LAST_UNDEAD = 28, # Z_TRACKER

	_COUNT = 29,
}


static var names: Array = []


static var UNDEAD_SKILLS: Array = [
	IDs.Z_AGILE,
	IDs.Z_EATER,
	IDs.Z_GRAB,
	IDs.Z_INFECTOR,
	IDs.Z_LIGHT_EATER,
	IDs.Z_LIGHT_FEET,
	IDs.Z_STRONG,
	IDs.Z_TOUGH,
	IDs.Z_TRACKER,
]


## C# Name(IDs) and Name(int) overloads collapse into one function.
static func name(id: int) -> String:
	return names[id]


static func max_skill_level(id: int) -> int:
	match id:
		IDs.HAULER:
			return 3
		_:
			return 5


static func roll_living(roller: DiceRoller) -> int:
	return roller.roll(IDs._FIRST_LIVING, IDs._LAST_LIVING + 1)


static func roll_undead(roller: DiceRoller) -> int:
	return roller.roll(IDs._FIRST_UNDEAD, IDs._LAST_UNDEAD + 1)


# Data


## struct SkillData
class SkillData:
	const COUNT_FIELDS = 6

	var name: String
	var value1: float
	var value2: float
	var value3: float
	var value4: float

	static func from_csv_line(line: CSVParser.CSVLine) -> SkillData:
		var d := SkillData.new()
		d.name = line.get_field(1).parse_text()
		d.value1 = line.get_field(2).parse_float()
		d.value2 = line.get_field(3).parse_float()
		d.value3 = line.get_field(4).parse_float()
		d.value4 = line.get_field(5).parse_float()
		return d


# Helpers


static func _notify(ui: IRogueUI, stage: String) -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading skills data : " + stage, 0, 0)
	ui.ui_repaint()


static func _find_line_for_model(table: CSVParser.CSVTable, skill_id: int) -> CSVParser.CSVLine:
	# C# compares l[0].ParseText() with skillID.ToString(), ie an enum member
	# name. Several members can share a value (AGILE == _FIRST_LIVING == _FIRST
	# == 0, Z_AGILE == _FIRST_UNDEAD) and which alias .NET ToString() picks for
	# duplicated values is unspecified; the shipped Skills.csv labels those rows
	# "_FIRST_LIVING" and "_FIRST_UNDEAD". So match ANY member name having this
	# id value.
	for l in table.lines:
		var label: String = l.get_field(0).parse_text()
		if label in IDs && IDs[label] == skill_id:
			return l
	return null


## C# generic GetDataFromCSVTable<_DATA_TYPE_> specialized for SkillData.
## C# throws InvalidOperationException; here push_error + null.
static func _get_data_from_csv_table(_ui: IRogueUI, table: CSVParser.CSVTable, skill_id: int) -> SkillData:
	# get line for skill in table.
	var line := _find_line_for_model(table, skill_id)
	if line == null:
		push_error("skill %s not found" % IDs.keys()[skill_id])
		return null

	# get data from line.
	# (C# wraps FromCSVLine in a try/catch that rethrows with context; GDScript
	# has no try/catch, field errors surface directly.)
	return SkillData.from_csv_line(line)


## C# LoadDataFromCSV<_DATA_TYPE_>(ui, path, kind, fieldsCount, fn, idsToRead, out data)
## specialized for SkillData; the out param becomes the return value
## (null on failure instead of exception). Untyped return: can be null.
static func _load_data_from_csv(ui: IRogueUI, path: String, fields_count: int, ids_to_read: Array):
	# read & parse csv file.
	_notify(ui, "loading file...")
	# read the whole file.
	var raw_lines := CSVParser.read_lines_cp1252(path)
	# (get_file_as_string returns "" when the file cannot be opened.)
	if raw_lines.size() == 1 && raw_lines[0].is_empty():
		push_error("cannot open CSV file %s" % path)
		return null

	var all_lines := PackedStringArray()
	for i in raw_lines.size():
		# skip header; also drop empty lines (trailing newline).
		if i == 0 || raw_lines[i].strip_edges().is_empty():
			continue
		all_lines.append(raw_lines[i])

	# parse all the lines read.
	_notify(ui, "parsing CSV...")
	var parser := CSVParser.new()
	var table := parser.parse_to_table(all_lines, fields_count)

	# set data.
	_notify(ui, "reading data...")

	var data: Array = []
	data.resize(ids_to_read.size())
	for i in ids_to_read.size():
		data[i] = _get_data_from_csv_table(ui, table, ids_to_read[i])

	# all fine.
	_notify(ui, "done!")
	return data


# Loading


static func load_skills_from_csv(ui: IRogueUI, path: String) -> bool:
	# NOTE: like the C# original, data is indexed by position in this list;
	# the list is every skill in id order so data[i] == data for skill id i.
	var data: Array = _load_data_from_csv(ui, path, SkillData.COUNT_FIELDS, [
		IDs.AGILE, IDs.AWAKE, IDs.BOWS, IDs.CARPENTRY, IDs.CHARISMATIC, IDs.FIREARMS, IDs.HARDY, IDs.HAULER,
		IDs.HIGH_STAMINA, IDs.LEADERSHIP, IDs.LIGHT_EATER, IDs.LIGHT_FEET, IDs.LIGHT_SLEEPER, IDs.MARTIAL_ARTS, IDs.MEDIC,
		IDs.NECROLOGY, IDs.STRONG, IDs.STRONG_PSYCHE, IDs.TOUGH, IDs.UNSUSPICIOUS,
		IDs.Z_AGILE, IDs.Z_EATER, IDs.Z_GRAB, IDs.Z_INFECTOR, IDs.Z_LIGHT_EATER, IDs.Z_LIGHT_FEET, IDs.Z_STRONG, IDs.Z_TOUGH, IDs.Z_TRACKER,
	])
	if data == null:
		return false

	# names.
	names.resize(IDs._COUNT)
	for i in range(IDs._FIRST, IDs._COUNT):
		names[i] = data[i].name

	# then skills value.
	var s: SkillData

	s = data[IDs.AGILE]
	Rules.SKILL_AGILE_ATK_BONUS = int(s.value1)
	Rules.SKILL_AGILE_DEF_BONUS = int(s.value2)

	s = data[IDs.AWAKE]
	Rules.SKILL_AWAKE_SLEEP_BONUS = s.value1
	Rules.SKILL_AWAKE_SLEEP_REGEN_BONUS = s.value2

	s = data[IDs.BOWS]
	Rules.SKILL_BOWS_ATK_BONUS = int(s.value1)
	Rules.SKILL_BOWS_DMG_BONUS = int(s.value2)

	s = data[IDs.CARPENTRY]
	Rules.SKILL_CARPENTRY_BARRICADING_BONUS = s.value1
	Rules.SKILL_CARPENTRY_LEVEL3_BUILD_BONUS = int(s.value2)

	s = data[IDs.CHARISMATIC]
	Rules.SKILL_CHARISMATIC_TRUST_BONUS = int(s.value1)
	Rules.SKILL_CHARISMATIC_TRADE_BONUS = int(s.value2)

	s = data[IDs.FIREARMS]
	Rules.SKILL_FIREARMS_ATK_BONUS = int(s.value1)
	Rules.SKILL_FIREARMS_DMG_BONUS = int(s.value2)

	s = data[IDs.HARDY]
	Rules.SKILL_HARDY_HEAL_CHANCE_BONUS = int(s.value1)

	s = data[IDs.HAULER]
	Rules.SKILL_HAULER_INV_BONUS = int(s.value1)

	s = data[IDs.HIGH_STAMINA]
	Rules.SKILL_HIGH_STAMINA_STA_BONUS = int(s.value1)

	s = data[IDs.LEADERSHIP]
	Rules.SKILL_LEADERSHIP_FOLLOWER_BONUS = int(s.value1)

	s = data[IDs.LIGHT_EATER]
	Rules.SKILL_LIGHT_EATER_FOOD_BONUS = s.value1
	Rules.SKILL_LIGHT_EATER_MAXFOOD_BONUS = s.value2

	s = data[IDs.LIGHT_FEET]
	Rules.SKILL_LIGHT_FEET_TRAP_BONUS = int(s.value1)

	s = data[IDs.LIGHT_SLEEPER]
	Rules.SKILL_LIGHT_SLEEPER_WAKEUP_CHANCE_BONUS = int(s.value1)

	s = data[IDs.MARTIAL_ARTS]
	Rules.SKILL_MARTIAL_ARTS_ATK_BONUS = int(s.value1)
	Rules.SKILL_MARTIAL_ARTS_DMG_BONUS = int(s.value2)
	Rules.SKILL_MARTIAL_ARTS_DISARM_BONUS = int(s.value3)

	s = data[IDs.MEDIC]
	Rules.SKILL_MEDIC_BONUS = s.value1
	Rules.SKILL_MEDIC_REVIVE_BONUS = int(s.value2)

	s = data[IDs.NECROLOGY]
	Rules.SKILL_NECROLOGY_UNDEAD_BONUS = int(s.value1)
	Rules.SKILL_NECROLOGY_CORPSE_BONUS = int(s.value2)

	s = data[IDs.STRONG]
	Rules.SKILL_STRONG_DMG_BONUS = int(s.value1)
	Rules.SKILL_STRONG_THROW_BONUS = int(s.value2)

	s = data[IDs.STRONG_PSYCHE]
	Rules.SKILL_STRONG_PSYCHE_LEVEL_BONUS = s.value1

	s = data[IDs.TOUGH]
	Rules.SKILL_TOUGH_HP_BONUS = int(s.value1)

	s = data[IDs.UNSUSPICIOUS]
	Rules.SKILL_UNSUSPICIOUS_BONUS = int(s.value1)

	s = data[IDs.Z_AGILE]
	Rules.SKILL_ZAGILE_ATK_BONUS = int(s.value1)
	Rules.SKILL_ZAGILE_DEF_BONUS = int(s.value2)

	s = data[IDs.Z_EATER]
	Rules.SKILL_ZEATER_REGEN_BONUS = s.value1

	s = data[IDs.Z_INFECTOR]
	Rules.SKILL_ZINFECTOR_BONUS = s.value1

	s = data[IDs.Z_GRAB]
	Rules.SKILL_ZGRAB_CHANCE = int(s.value1)

	s = data[IDs.Z_LIGHT_EATER]
	Rules.SKILL_ZLIGHT_EATER_FOOD_BONUS = s.value1
	Rules.SKILL_ZLIGHT_EATER_MAXFOOD_BONUS = s.value2

	s = data[IDs.Z_LIGHT_FEET]
	Rules.SKILL_ZLIGHT_FEET_TRAP_BONUS = int(s.value1)

	s = data[IDs.Z_STRONG]
	Rules.SKILL_ZSTRONG_DMG_BONUS = int(s.value1)

	s = data[IDs.Z_TOUGH]
	Rules.SKILL_ZTOUGH_HP_BONUS = int(s.value1)

	s = data[IDs.Z_TRACKER]
	Rules.SKILL_ZTRACKER_SMELL_BONUS = s.value1

	return true

