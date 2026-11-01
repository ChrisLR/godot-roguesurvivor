class_name GameActors
extends ActorModelDB
## Port of Gameplay/GameActors.cs
## The actor content database: IDs enum + CSV-driven registrations of
## ActorModels.
##
## CSV path: the C# callers pass "Resources\\Data\\Actors.csv"; here callers
## pass "res://assets/Data/Actors.csv".
##
## AI controller classes (SkeletonAI, ZombieAI, ...) are referenced by
## class_name; they may land in a later porting batch.

# region IDs
enum IDs {
	_FIRST,

	UNDEAD_SKELETON = _FIRST,
	UNDEAD_RED_EYED_SKELETON,
	UNDEAD_RED_SKELETON,

	UNDEAD_ZOMBIE,
	UNDEAD_DARK_EYED_ZOMBIE,
	UNDEAD_DARK_ZOMBIE,

	UNDEAD_ZOMBIE_MASTER,
	UNDEAD_ZOMBIE_LORD,
	UNDEAD_ZOMBIE_PRINCE,

	UNDEAD_MALE_ZOMBIFIED,
	UNDEAD_FEMALE_ZOMBIFIED,
	UNDEAD_MALE_NEOPHYTE,
	UNDEAD_FEMALE_NEOPHYTE,
	UNDEAD_MALE_DISCIPLE,
	UNDEAD_FEMALE_DISCIPLE,

	UNDEAD_RAT_ZOMBIE,

	MALE_CIVILIAN,
	FEMALE_CIVILIAN,
	FERAL_DOG,

	CHAR_GUARD,

	ARMY_NATIONAL_GUARD,

	BIKER_MAN,

	POLICEMAN,

	GANGSTA_MAN,

	BLACKOPS_MAN,

	SEWERS_THING,
	JASON_MYERS,

	_COUNT,
}
# endregion


# region Constants
const NO_INVENTORY = 0
const NO_FOOD = 0
const NO_SLEEP = 0
const NO_SANITY = 0
const NO_SMELL = 0
const NO_AUDIO = 0
# endregion


# region Fields
# Untyped array: entries may be null before create_models().
var models: Array = []


func get_model(p_id: int) -> ActorModel:
	return models[p_id]


## C# private indexer setter this[IDs id].
func _set_model(p_id: int, model: ActorModel) -> void:
	models[p_id] = model
	models[p_id].id = p_id


# C# indexer properties -> accessor methods (game_items.gd convention).
func skeleton() -> ActorModel:
	return get_model(IDs.UNDEAD_SKELETON)


func red_eyed_skeleton() -> ActorModel:
	return get_model(IDs.UNDEAD_RED_EYED_SKELETON)


func red_skeleton() -> ActorModel:
	return get_model(IDs.UNDEAD_RED_SKELETON)


func zombie() -> ActorModel:
	return get_model(IDs.UNDEAD_ZOMBIE)


func dark_eyed_zombie() -> ActorModel:
	return get_model(IDs.UNDEAD_DARK_EYED_ZOMBIE)


func dark_zombie() -> ActorModel:
	return get_model(IDs.UNDEAD_DARK_ZOMBIE)


func zombie_master() -> ActorModel:
	return get_model(IDs.UNDEAD_ZOMBIE_MASTER)


func zombie_lord() -> ActorModel:
	return get_model(IDs.UNDEAD_ZOMBIE_LORD)


func zombie_prince() -> ActorModel:
	return get_model(IDs.UNDEAD_ZOMBIE_PRINCE)


func male_zombified() -> ActorModel:
	return get_model(IDs.UNDEAD_MALE_ZOMBIFIED)


func female_zombified() -> ActorModel:
	return get_model(IDs.UNDEAD_FEMALE_ZOMBIFIED)


func male_neophyte() -> ActorModel:
	return get_model(IDs.UNDEAD_MALE_NEOPHYTE)


func female_neophyte() -> ActorModel:
	return get_model(IDs.UNDEAD_FEMALE_NEOPHYTE)


func male_disciple() -> ActorModel:
	return get_model(IDs.UNDEAD_MALE_DISCIPLE)


func female_disciple() -> ActorModel:
	return get_model(IDs.UNDEAD_FEMALE_DISCIPLE)


func rat_zombie() -> ActorModel:
	return get_model(IDs.UNDEAD_RAT_ZOMBIE)


func sewers_thing() -> ActorModel:
	return get_model(IDs.SEWERS_THING)


func male_civilian() -> ActorModel:
	return get_model(IDs.MALE_CIVILIAN)


func female_civilian() -> ActorModel:
	return get_model(IDs.FEMALE_CIVILIAN)


func feral_dog() -> ActorModel:
	return get_model(IDs.FERAL_DOG)


func char_guard() -> ActorModel:
	return get_model(IDs.CHAR_GUARD)


func national_guard() -> ActorModel:
	return get_model(IDs.ARMY_NATIONAL_GUARD)


func biker_man() -> ActorModel:
	return get_model(IDs.BIKER_MAN)


func gangsta_man() -> ActorModel:
	return get_model(IDs.GANGSTA_MAN)


func policeman() -> ActorModel:
	return get_model(IDs.POLICEMAN)


func black_ops() -> ActorModel:
	return get_model(IDs.BLACKOPS_MAN)


func jason_myers() -> ActorModel:
	return get_model(IDs.JASON_MYERS)
# endregion


# region Data stats
## C# struct ActorData -> inner class.
class ActorData:
	const COUNT_FIELDS = 16

	var name: String
	var plural: String
	var spd: int
	var hp: int
	var sta: int
	var atk: int
	var dmg: int
	var def: int
	var pro_hit: int
	var pro_shot: int
	var fov: int
	var audio: int
	var smell: int
	var score: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> ActorData:
		var d := ActorData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.spd = line.get_field(3).parse_int()
		d.hp = line.get_field(4).parse_int()
		d.sta = line.get_field(5).parse_int()
		d.atk = line.get_field(6).parse_int()
		d.dmg = line.get_field(7).parse_int()
		d.def = line.get_field(8).parse_int()
		d.pro_hit = line.get_field(9).parse_int()
		d.pro_shot = line.get_field(10).parse_int()
		d.fov = line.get_field(11).parse_int()
		d.audio = line.get_field(12).parse_int()
		d.smell = line.get_field(13).parse_int()
		d.score = line.get_field(14).parse_int()
		d.flavor = line.get_field(15).parse_text()
		return d


# region Undeads
var undead_food: int = Rules.ROT_BASE_POINTS

# Untyped: null until the corresponding load ran.
var data_skeleton = null
var data_red_eyed_skeleton = null
var data_red_skeleton = null

var data_zombie = null
var data_dark_eyed_zombie = null
var data_dark_zombie = null

var data_male_zombified = null
var data_female_zombified = null
var data_male_neophyte = null
var data_female_neophyte = null
var data_male_disciple = null
var data_female_disciple = null

var data_zm = null
var data_zp = null
var data_zl = null

var data_rat_zombie = null
# endregion

# region Unique Undeads
var data_sewers_thing = null
# endregion

# region Livings
var human_hun: int = Rules.FOOD_BASE_POINTS
var human_slp: int = Rules.SLEEP_BASE_POINTS
var human_san: int = Rules.SANITY_BASE_POINTS
var human_inventory: int = 7
static var VERB_PUNCH: Verb = Verb.new("punch", "punches")

var dog_hun: int = Rules.FOOD_BASE_POINTS
var dog_slp: int = Rules.SLEEP_BASE_POINTS
var dog_inventory: int = 1

var data_male_civilian = null
var data_female_civilian = null
var data_feral_dog = null

var data_policeman = null

var data_char_guard = null

var data_natguard = null

var data_biker_man = null

var data_gangsta_man = null

var data_blackops_man = null
# endregion

# region Unique Livings
var data_jason_myers = null
# endregion
# endregion


# region Init
func _init() -> void:
	# bind
	Models.actors = self
	# C# pre-sizes m_Models to IDs._COUNT.
	models.resize(IDs._COUNT)
# endregion


# region Models creation

## C# Abilities object initializer syntax.
static func _abilities(props: Dictionary) -> Abilities:
	var abilities := Abilities.new()
	for key in props:
		abilities.set(key, props[key])
	return abilities


## C# `this[id] = new ActorModel(...) { FlavorDescription = data.FLAVOR };`
func _register(p_id: int, p_image_id, p_data: ActorData, p_body: Doll.DollBody,
		p_abilities: Abilities, p_sheet: ActorSheet, p_controller) -> void:
	var model := ActorModel.new(p_image_id, p_data.name, p_data.plural, p_data.score,
			p_body, p_abilities, p_sheet, p_controller)
	model.flavor_description = p_data.flavor
	_set_model(p_id, model)


func create_models() -> void:
	# region Undeads

	# region Skeleton branch
	# alpha10 new disarm mechanic, Skeletons cannot disarm but can use exits.
	_register(IDs.UNDEAD_SKELETON, GameImages.ACTOR_SKELETON, data_skeleton,
			Doll.DollBody.new(true, data_skeleton.spd),
			_abilities({
				"is_undead": true,
				"can_disarm": false, # alpha10
				"ai_can_use_ai_exits": true, # alpha10
			}),
			ActorSheet.new(data_skeleton.hp, data_skeleton.sta, NO_FOOD, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("claw"),
					data_skeleton.atk, data_skeleton.dmg),
				Defence.new(data_skeleton.def, data_skeleton.pro_hit, data_skeleton.pro_shot),
				data_skeleton.fov, NO_AUDIO, NO_SMELL, NO_INVENTORY),
			SkeletonAI)

	_register(IDs.UNDEAD_RED_EYED_SKELETON, GameImages.ACTOR_RED_EYED_SKELETON, data_red_eyed_skeleton,
			Doll.DollBody.new(true, data_red_eyed_skeleton.spd),
			_abilities({
				"is_undead": true,
				"can_disarm": false, # alpha10
				"ai_can_use_ai_exits": true, # alpha10
			}),
			ActorSheet.new(data_red_eyed_skeleton.hp, data_red_eyed_skeleton.sta, NO_FOOD, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("claw"),
					data_red_eyed_skeleton.atk, data_red_eyed_skeleton.dmg),
				Defence.new(data_red_eyed_skeleton.def, data_red_eyed_skeleton.pro_hit, data_red_eyed_skeleton.pro_shot),
				data_red_eyed_skeleton.fov, NO_AUDIO, NO_SMELL, NO_INVENTORY),
			SkeletonAI)

	_register(IDs.UNDEAD_RED_SKELETON, GameImages.ACTOR_RED_SKELETON, data_red_skeleton,
			Doll.DollBody.new(true, data_red_skeleton.spd),
			_abilities({
				"is_undead": true,
				"can_disarm": false, # alpha10
				"ai_can_use_ai_exits": true, # alpha10
			}),
			ActorSheet.new(data_red_skeleton.hp, data_red_skeleton.sta, NO_FOOD, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("claw"),
					data_red_skeleton.atk, data_red_skeleton.dmg),
				Defence.new(data_red_skeleton.def, data_red_skeleton.pro_hit, data_red_skeleton.pro_shot),
				data_red_skeleton.fov, NO_AUDIO, NO_SMELL, NO_INVENTORY),
			SkeletonAI)
	# endregion

	# region Std zombie branch
	_register(IDs.UNDEAD_ZOMBIE, GameImages.ACTOR_ZOMBIE, data_zombie,
			Doll.DollBody.new(true, data_zombie.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_zombie.hp, data_zombie.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_zombie.atk, data_zombie.dmg),
				Defence.new(data_zombie.def, data_zombie.pro_hit, data_zombie.pro_shot),
				data_zombie.fov, NO_AUDIO, data_zombie.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_DARK_EYED_ZOMBIE, GameImages.ACTOR_DARK_EYED_ZOMBIE, data_dark_eyed_zombie,
			Doll.DollBody.new(true, data_dark_eyed_zombie.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_dark_eyed_zombie.hp, data_dark_eyed_zombie.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_dark_eyed_zombie.atk, data_dark_eyed_zombie.dmg),
				Defence.new(data_dark_eyed_zombie.def, data_dark_eyed_zombie.pro_hit, data_dark_eyed_zombie.pro_shot),
				data_dark_eyed_zombie.fov, NO_AUDIO, data_dark_eyed_zombie.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_DARK_ZOMBIE, GameImages.ACTOR_DARK_ZOMBIE, data_dark_zombie,
			Doll.DollBody.new(true, data_dark_zombie.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_dark_zombie.hp, data_dark_zombie.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_dark_zombie.atk, data_dark_zombie.dmg),
				Defence.new(data_dark_zombie.def, data_dark_zombie.pro_hit, data_dark_zombie.pro_shot),
				data_dark_zombie.fov, NO_AUDIO, data_dark_zombie.smell, NO_INVENTORY),
			ZombieAI)
	# endregion

	# region Zombified branch
	# C# passes null as image (no image on the model).
	_register(IDs.UNDEAD_MALE_ZOMBIFIED, "", data_male_zombified,
			Doll.DollBody.new(true, data_male_zombified.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_male_zombified.hp, data_male_zombified.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_male_zombified.atk, data_male_zombified.dmg),
				Defence.new(data_male_zombified.def, data_male_zombified.pro_hit, data_male_zombified.pro_shot),
				data_male_zombified.fov, NO_AUDIO, data_male_zombified.smell, NO_INVENTORY),
			ZombieAI)

	# C# passes null as image (no image on the model).
	_register(IDs.UNDEAD_FEMALE_ZOMBIFIED, "", data_female_zombified,
			Doll.DollBody.new(true, data_female_zombified.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_female_zombified.hp, data_female_zombified.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_female_zombified.atk, data_female_zombified.dmg),
				Defence.new(data_female_zombified.def, data_female_zombified.pro_hit, data_female_zombified.pro_shot),
				data_female_zombified.fov, NO_AUDIO, data_female_zombified.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_MALE_NEOPHYTE, GameImages.ACTOR_MALE_NEOPHYTE, data_male_neophyte,
			Doll.DollBody.new(true, data_male_neophyte.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_push": true,
				# alpha10 obsolete and was unused anyway ZombieAI_AssaultBreakables = true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_male_neophyte.hp, data_male_neophyte.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_male_neophyte.atk, data_male_neophyte.dmg),
				Defence.new(data_male_neophyte.def, data_male_neophyte.pro_hit, data_male_neophyte.pro_shot),
				data_male_neophyte.fov, NO_AUDIO, data_male_neophyte.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_FEMALE_NEOPHYTE, GameImages.ACTOR_FEMALE_NEOPHYTE, data_female_neophyte,
			Doll.DollBody.new(true, data_female_neophyte.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_push": true,
				# alpha10 obsolete and was unused anyway ZombieAI_AssaultBreakables = true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_female_neophyte.hp, data_female_neophyte.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_female_neophyte.atk, data_female_neophyte.dmg),
				Defence.new(data_female_neophyte.def, data_female_neophyte.pro_hit, data_female_neophyte.pro_shot),
				data_female_neophyte.fov, NO_AUDIO, data_female_neophyte.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_MALE_DISCIPLE, GameImages.ACTOR_MALE_DISCIPLE, data_male_disciple,
			Doll.DollBody.new(true, data_male_disciple.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_push": true,
				# alpha10 obsolete and was unused anyway ZombieAI_AssaultBreakables = true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_male_disciple.hp, data_male_disciple.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_male_disciple.atk, data_male_disciple.dmg),
				Defence.new(data_male_disciple.def, data_male_disciple.pro_hit, data_male_disciple.pro_shot),
				data_male_disciple.fov, NO_AUDIO, data_male_disciple.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_FEMALE_DISCIPLE, GameImages.ACTOR_FEMALE_DISCIPLE, data_female_disciple,
			Doll.DollBody.new(true, data_female_disciple.spd),
			_abilities({
				"is_undead": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_push": true,
				# alpha10 obsolete and was unused anyway ZombieAI_AssaultBreakables = true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_female_disciple.hp, data_female_disciple.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_female_disciple.atk, data_female_disciple.dmg),
				Defence.new(data_female_disciple.def, data_female_disciple.pro_hit, data_female_disciple.pro_shot),
				data_female_disciple.fov, NO_AUDIO, data_female_disciple.smell, NO_INVENTORY),
			ZombieAI)
	# endregion

	# region ZM branch
	_register(IDs.UNDEAD_ZOMBIE_MASTER, GameImages.ACTOR_ZOMBIE_MASTER, data_zm,
			Doll.DollBody.new(true, data_zm.spd),
			_abilities({
				"is_undead": true,
				"is_undead_master": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_use_map_objects": true,
				"can_jump": true,
				"can_jump_stumble": true,
				"can_push": true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_zm.hp, data_zm.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_zm.atk, data_zm.dmg),
				Defence.new(data_zm.def, data_zm.pro_hit, data_zm.pro_shot),
				data_zm.fov, NO_AUDIO, data_zm.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_ZOMBIE_LORD, GameImages.ACTOR_ZOMBIE_LORD, data_zl,
			Doll.DollBody.new(true, data_zl.spd),
			_abilities({
				"is_undead": true,
				"is_undead_master": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_use_map_objects": true,
				"can_jump": true,
				"can_jump_stumble": true,
				"can_push": true,
				# alpha10 obsolete and was unused anyway ZombieAI_AssaultBreakables = true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_zl.hp, data_zl.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_zl.atk, data_zl.dmg),
				Defence.new(data_zl.def, data_zl.pro_hit, data_zl.pro_shot),
				data_zl.fov, NO_AUDIO, data_zl.smell, NO_INVENTORY),
			ZombieAI)

	_register(IDs.UNDEAD_ZOMBIE_PRINCE, GameImages.ACTOR_ZOMBIE_PRINCE, data_zp,
			Doll.DollBody.new(true, data_zp.spd),
			_abilities({
				"is_undead": true,
				"is_undead_master": true,
				"is_rotting": true,
				"can_zombify_killed": true,
				"can_bash_doors": true,
				"can_break_objects": true,
				"can_use_map_objects": true,
				"can_jump": true,
				"can_jump_stumble": true,
				"can_push": true,
				# alpha10 obsolete and was unused anyway ZombieAI_AssaultBreakables = true,
				"zombie_ai_explore": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_zp.hp, data_zp.sta, undead_food, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_zp.atk, data_zp.dmg),
				Defence.new(data_zp.def, data_zp.pro_hit, data_zp.pro_shot),
				data_zp.fov, NO_AUDIO, data_zp.smell, NO_INVENTORY),
			ZombieAI)
	# endregion

	# region Rats
	# alpha10 new disarm mechanic, Rats cannot disarm.
	_register(IDs.UNDEAD_RAT_ZOMBIE, GameImages.ACTOR_RAT_ZOMBIE, data_rat_zombie,
			Doll.DollBody.new(true, data_rat_zombie.spd),
			_abilities({
				"is_undead": true,
				"is_small": true,
				"ai_can_use_ai_exits": true,
				"can_disarm": false,
			}),
			ActorSheet.new(data_rat_zombie.hp, data_rat_zombie.sta, NO_FOOD, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_rat_zombie.atk, data_rat_zombie.dmg),
				Defence.new(data_rat_zombie.def, data_rat_zombie.pro_hit, data_rat_zombie.pro_shot),
				data_rat_zombie.fov, NO_AUDIO, data_rat_zombie.smell, NO_INVENTORY),
			RatAI)
	# endregion
	# endregion

	# region Unique Undeads
	_register(IDs.SEWERS_THING, GameImages.ACTOR_SEWERS_THING, data_sewers_thing,
			Doll.DollBody.new(true, data_sewers_thing.spd),
			_abilities({
				"is_undead": true,
				"can_bash_doors": true,
				"can_break_objects": true,
			}),
			ActorSheet.new(data_sewers_thing.hp, data_sewers_thing.sta, NO_FOOD, NO_SLEEP, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_sewers_thing.atk, data_sewers_thing.dmg),
				Defence.new(data_sewers_thing.def, data_sewers_thing.pro_hit, data_sewers_thing.pro_shot),
				data_sewers_thing.fov, NO_AUDIO, data_sewers_thing.smell, NO_INVENTORY),
			SewersThingAI)
	# endregion

	# region Livings
	# region Civilians
	# C# passes null as image (no image on the model; living actors are skinned
	# and dressed at spawn time by the doll decorations).
	_register(IDs.MALE_CIVILIAN, "", data_male_civilian,
			Doll.DollBody.new(true, data_male_civilian.spd),
			_abilities({
				"has_inventory": true,
				"has_to_eat": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_talk": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_bash_doors": true, # alpha10.1 necessary to avoid getting stuck in some rare cases
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"can_trade": true,
				"can_barricade": true,
				"can_push": true,
				"is_intelligent": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_male_civilian.hp, data_male_civilian.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_male_civilian.atk, data_male_civilian.dmg),
				Defence.new(data_male_civilian.def, data_male_civilian.pro_hit, data_male_civilian.pro_shot),
				data_male_civilian.fov, data_male_civilian.audio, NO_SMELL, human_inventory),
			CivilianAI) # alpha10.1

	# C# passes null as image (no image on the model).
	_register(IDs.FEMALE_CIVILIAN, "", data_female_civilian,
			Doll.DollBody.new(false, data_female_civilian.spd),
			_abilities({
				"has_inventory": true,
				"has_to_eat": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_talk": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_bash_doors": true, # alpha10.1 necessary to avoid getting stuck in some rare cases
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"can_trade": true,
				"can_barricade": true,
				"can_push": true,
				"is_intelligent": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_female_civilian.hp, data_female_civilian.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_female_civilian.atk, data_female_civilian.dmg),
				Defence.new(data_female_civilian.def, data_female_civilian.pro_hit, data_female_civilian.pro_shot),
				data_female_civilian.fov, data_female_civilian.audio, NO_SMELL, human_inventory),
			CivilianAI) # alpha10.1
	# endregion

	# region CHAR
	# C# passes null as image (skinned & dressed).
	_register(IDs.CHAR_GUARD, "", data_char_guard,
			Doll.DollBody.new(true, data_char_guard.spd),
			_abilities({
				"has_inventory": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_talk": true,
				"can_push": true,
				"can_barricade": true,
				"is_intelligent": true,
			}),
			ActorSheet.new(data_char_guard.hp, data_char_guard.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_char_guard.atk, data_char_guard.dmg),
				Defence.new(data_char_guard.def, data_char_guard.pro_hit, data_char_guard.pro_shot),
				data_char_guard.fov, data_char_guard.audio, NO_SMELL, human_inventory),
			CHARGuardAI)
	# endregion

	# region Army
	# C# passes null as image (skinned & dressed).
	_register(IDs.ARMY_NATIONAL_GUARD, "", data_natguard,
			Doll.DollBody.new(true, data_natguard.spd),
			_abilities({
				"has_inventory": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"can_talk": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_push": true,
				"can_barricade": true,
				"is_intelligent": true,
			}),
			ActorSheet.new(data_natguard.hp, data_natguard.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_natguard.atk, data_natguard.dmg),
				Defence.new(data_natguard.def, data_natguard.pro_hit, data_natguard.pro_shot),
				data_natguard.fov, data_natguard.audio, NO_SMELL, human_inventory),
			SoldierAI)
	# endregion

	# region Bikers
	# C# passes null as image (skinned & dressed).
	_register(IDs.BIKER_MAN, "", data_biker_man,
			Doll.DollBody.new(true, data_biker_man.spd),
			_abilities({
				"has_inventory": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"has_to_eat": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_talk": true,
				"can_push": true,
				"can_barricade": true,
				"can_trade": true,
				"is_intelligent": true,
				"ai_not_interested_in_ranged_weapons": true,
			}),
			ActorSheet.new(data_biker_man.hp, data_biker_man.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_biker_man.atk, data_biker_man.dmg),
				Defence.new(data_biker_man.def, data_biker_man.pro_hit, data_biker_man.pro_shot),
				data_biker_man.fov, data_biker_man.audio, NO_SMELL, human_inventory),
			GangAI)
	# endregion

	# region Gangstas
	# C# passes null as image (skinned & dressed).
	_register(IDs.GANGSTA_MAN, "", data_gangsta_man,
			Doll.DollBody.new(true, data_gangsta_man.spd),
			_abilities({
				"has_inventory": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"has_to_eat": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_talk": true,
				"can_push": true,
				"can_barricade": true,
				"can_trade": true,
				"is_intelligent": true,
			}),
			ActorSheet.new(data_gangsta_man.hp, data_gangsta_man.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_gangsta_man.atk, data_gangsta_man.dmg),
				Defence.new(data_gangsta_man.def, data_gangsta_man.pro_hit, data_gangsta_man.pro_shot),
				data_gangsta_man.fov, data_gangsta_man.audio, NO_SMELL, human_inventory),
			GangAI)
	# endregion

	# region Police
	# C# passes null as image (skinned & dressed).
	_register(IDs.POLICEMAN, "", data_policeman,
			Doll.DollBody.new(true, data_policeman.spd),
			_abilities({
				"has_inventory": true,
				"has_to_eat": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_talk": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"can_trade": true,
				"can_barricade": true,
				"can_push": true,
				"ai_can_use_ai_exits": true,
				"is_law_enforcer": true,
				"is_intelligent": true,
			}),
			ActorSheet.new(data_policeman.hp, data_policeman.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_policeman.atk, data_policeman.dmg),
				Defence.new(data_policeman.def, data_policeman.pro_hit, data_policeman.pro_shot),
				data_policeman.fov, data_policeman.audio, NO_SMELL, human_inventory),
			CivilianAI) # alpha10.1
	# endregion

	# region BlackOps
	# C# passes null as image (skinned & dressed).
	_register(IDs.BLACKOPS_MAN, "", data_blackops_man,
			Doll.DollBody.new(true, data_blackops_man.spd),
			_abilities({
				"has_inventory": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"can_talk": true,
				"has_to_sleep": true,
				"has_sanity": true,
				"can_push": true,
				"can_barricade": true,
				"is_intelligent": true,
			}),
			ActorSheet.new(data_blackops_man.hp, data_blackops_man.sta, human_hun, human_slp, human_san,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_blackops_man.atk, data_blackops_man.dmg),
				Defence.new(data_blackops_man.def, data_blackops_man.pro_hit, data_blackops_man.pro_shot),
				data_blackops_man.fov, data_blackops_man.audio, NO_SMELL, human_inventory),
			SoldierAI)
	# endregion

	# region Animals
	# C# passes null as image (no image on the model).
	_register(IDs.FERAL_DOG, "", data_feral_dog,
			Doll.DollBody.new(true, data_feral_dog.spd),
			_abilities({
				"has_inventory": true,
				"has_to_eat": true,
				"has_to_sleep": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_feral_dog.hp, data_feral_dog.sta, dog_hun, dog_slp, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, Verb.new("bite"),
					data_feral_dog.atk, data_feral_dog.dmg),
				Defence.new(data_feral_dog.def, data_feral_dog.pro_hit, data_feral_dog.pro_shot),
				data_feral_dog.fov, data_feral_dog.audio, data_feral_dog.smell, dog_inventory),
			FeralDogAI)
	# endregion
	# endregion

	# region Jason Myers
	# C# passes null as image (skinned).
	_register(IDs.JASON_MYERS, "", data_jason_myers,
			Doll.DollBody.new(true, data_jason_myers.spd),
			_abilities({
				"has_inventory": true,
				"can_use_map_objects": true,
				"can_break_objects": true,
				"can_jump": true,
				"can_tire": true,
				"can_run": true,
				"can_use_items": true,
				"has_to_eat": false, # RAGE!
				"has_to_sleep": false, # RAGE!
				"can_talk": true,
				"can_push": true,
				"can_barricade": true,
				"ai_can_use_ai_exits": true,
			}),
			ActorSheet.new(data_jason_myers.hp, data_jason_myers.sta, human_hun, human_slp, NO_SANITY,
				Attack.new_base_melee(Attack.AttackKind.PHYSICAL, VERB_PUNCH,
					data_jason_myers.atk, data_jason_myers.dmg),
				Defence.new(data_jason_myers.def, data_jason_myers.pro_hit, data_jason_myers.pro_shot),
				data_jason_myers.fov, data_jason_myers.audio, NO_SMELL, human_inventory),
			InsaneHumanAI)
	# endregion
# endregion


# region Data loading

## C# LoadFromCSV(IRogueUI ui, string path).
func load_from_csv(ui: IRogueUI, path: String) -> bool:
	# read & parse csv file.
	_notify(ui, "loading file...")
	# read the whole file.
	var raw_lines := CSVParser.read_lines_cp1252(path)
	# (get_file_as_string returns "" when the file cannot be opened.)
	if raw_lines.size() == 1 && raw_lines[0].is_empty():
		push_error("cannot open CSV file %s" % path)
		return false

	var all_lines := PackedStringArray()
	for i in raw_lines.size():
		# skip header; also drop empty lines (trailing newline).
		if i == 0 || raw_lines[i].strip_edges().is_empty():
			continue
		all_lines.append(raw_lines[i])

	# parse all the lines read.
	_notify(ui, "parsing CSV...")
	var parser := CSVParser.new()
	var table := parser.parse_to_table(all_lines, ActorData.COUNT_FIELDS)

	# set data.
	_notify(ui, "reading data...")

	# region Undeads
	data_skeleton = _get_data_from_csv_table(ui, table, IDs.UNDEAD_SKELETON)
	data_red_eyed_skeleton = _get_data_from_csv_table(ui, table, IDs.UNDEAD_RED_EYED_SKELETON)
	data_red_skeleton = _get_data_from_csv_table(ui, table, IDs.UNDEAD_RED_SKELETON)

	data_zombie = _get_data_from_csv_table(ui, table, IDs.UNDEAD_ZOMBIE)
	data_dark_eyed_zombie = _get_data_from_csv_table(ui, table, IDs.UNDEAD_DARK_EYED_ZOMBIE)
	data_dark_zombie = _get_data_from_csv_table(ui, table, IDs.UNDEAD_DARK_ZOMBIE)

	data_male_zombified = _get_data_from_csv_table(ui, table, IDs.UNDEAD_MALE_ZOMBIFIED)
	data_female_zombified = _get_data_from_csv_table(ui, table, IDs.UNDEAD_FEMALE_ZOMBIFIED)
	data_male_neophyte = _get_data_from_csv_table(ui, table, IDs.UNDEAD_MALE_NEOPHYTE)
	data_female_neophyte = _get_data_from_csv_table(ui, table, IDs.UNDEAD_FEMALE_NEOPHYTE)
	data_male_disciple = _get_data_from_csv_table(ui, table, IDs.UNDEAD_MALE_DISCIPLE)
	data_female_disciple = _get_data_from_csv_table(ui, table, IDs.UNDEAD_FEMALE_DISCIPLE)

	data_zm = _get_data_from_csv_table(ui, table, IDs.UNDEAD_ZOMBIE_MASTER)
	data_zl = _get_data_from_csv_table(ui, table, IDs.UNDEAD_ZOMBIE_LORD)
	data_zp = _get_data_from_csv_table(ui, table, IDs.UNDEAD_ZOMBIE_PRINCE)

	data_rat_zombie = _get_data_from_csv_table(ui, table, IDs.UNDEAD_RAT_ZOMBIE)

	data_sewers_thing = _get_data_from_csv_table(ui, table, IDs.SEWERS_THING)
	# endregion

	# region Livings
	data_male_civilian = _get_data_from_csv_table(ui, table, IDs.MALE_CIVILIAN)
	data_female_civilian = _get_data_from_csv_table(ui, table, IDs.FEMALE_CIVILIAN)
	data_feral_dog = _get_data_from_csv_table(ui, table, IDs.FERAL_DOG)

	data_policeman = _get_data_from_csv_table(ui, table, IDs.POLICEMAN)

	data_char_guard = _get_data_from_csv_table(ui, table, IDs.CHAR_GUARD)

	data_natguard = _get_data_from_csv_table(ui, table, IDs.ARMY_NATIONAL_GUARD)

	data_biker_man = _get_data_from_csv_table(ui, table, IDs.BIKER_MAN)
	data_gangsta_man = _get_data_from_csv_table(ui, table, IDs.GANGSTA_MAN)

	data_blackops_man = _get_data_from_csv_table(ui, table, IDs.BLACKOPS_MAN)

	data_jason_myers = _get_data_from_csv_table(ui, table, IDs.JASON_MYERS)
	# endregion

	# create models.
	create_models()

	# all fine.
	_notify(ui, "done!")
	return true


func find_line_for_model(table: CSVParser.CSVTable, p_model_id: int) -> CSVParser.CSVLine:
	# C# compares l[0].ParseText() with modelID.ToString(), ie the enum member
	# name. Note: UNDEAD_SKELETON == _FIRST == 0 and the shipped Actors.csv
	# labels the skeleton row with the ID "_FIRST"; accept every member name
	# sharing the value so both spellings match.
	var wanted: Array = []
	for n in GameActors.IDs.keys():
		if GameActors.IDs[n] == p_model_id:
			wanted.append(n)
	for l in table.lines:
		if wanted.has(l.get_field(0).parse_text()):
			return l
	return null


func _get_data_from_csv_table(_ui: IRogueUI, table: CSVParser.CSVTable, p_model_id: int) -> ActorData:
	# get line for model in table.
	var line := find_line_for_model(table, p_model_id)
	if line == null:
		push_error("model %s not found" % IDs.keys()[p_model_id])
		return null

	# get data from line.
	# (C# wraps FromCSVLine in a try/catch that rethrows with context; GDScript
	# has no try/catch, field errors surface directly.)
	return ActorData.from_csv_line(line)


func _notify(ui: IRogueUI, stage: String) -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading actors data : " + stage, 0, 0)
	ui.ui_repaint()
# endregion


# region Branches
# FIXME: branch = property of model (kept from the C# original).

func is_zombified_branch(m: ActorModel) -> bool:
	return m == male_zombified() || m == female_zombified() \
		|| m == male_neophyte() || m == female_neophyte() \
		|| m == male_disciple() || m == female_disciple()


func is_zm_branch(m: ActorModel) -> bool:
	return m == zombie_master() || m == zombie_lord() || m == zombie_prince()


func is_skeleton_branch(m: ActorModel) -> bool:
	return m == skeleton() || m == red_eyed_skeleton() || m == red_skeleton()


func is_shambler_branch(m: ActorModel) -> bool:
	return m == zombie() || m == dark_eyed_zombie() || m == dark_zombie()


func is_rat_branch(m: ActorModel) -> bool:
	return m == rat_zombie()
# endregion

