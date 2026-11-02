class_name GameItems
extends ItemModelDB
## Port of Gameplay/GameItems.cs
## The item content database: IDs enum + CSV-driven registrations of
## ItemModels (subclasses from Engine/Items are ported in src/engine/items/).
##
## C# is referenced from RogueGame as e.g. "GameItems.MEDIKIT"; those are
## instance properties accessed through the "GameItems" member, so they are
## ported as instance accessor methods (medikit(), etc.).
##
## CSV paths: the C# callers pass "Resources\Data\Items_X.csv"; here callers
## pass "res://assets/Data/Items_X.csv".

enum IDs {
	_FIRST = 0,

	MEDICINE_BANDAGES = _FIRST,
	MEDICINE_MEDIKIT,
	MEDICINE_PILLS_STA,
	MEDICINE_PILLS_SLP,
	MEDICINE_PILLS_SAN,
	MEDICINE_PILLS_ANTIVIRAL,

	FOOD_ARMY_RATION,
	FOOD_GROCERIES,
	FOOD_CANNED_FOOD,

	MELEE_BASEBALLBAT,
	MELEE_COMBAT_KNIFE,
	MELEE_CROWBAR,
	UNIQUE_JASON_MYERS_AXE,
	MELEE_HUGE_HAMMER,
	MELEE_SMALL_HAMMER,
	MELEE_GOLFCLUB,
	MELEE_IRON_GOLFCLUB,
	MELEE_SHOVEL,
	MELEE_SHORT_SHOVEL,
	MELEE_TRUNCHEON,
	MELEE_IMPROVISED_CLUB,
	MELEE_IMPROVISED_SPEAR,

	RANGED_ARMY_PISTOL,
	RANGED_ARMY_RIFLE,
	RANGED_HUNTING_CROSSBOW,
	RANGED_HUNTING_RIFLE,
	RANGED_PISTOL,
	RANGED_KOLT_REVOLVER,
	RANGED_PRECISION_RIFLE,
	RANGED_SHOTGUN,

	EXPLOSIVE_GRENADE,
	EXPLOSIVE_GRENADE_PRIMED,

	BAR_WOODEN_PLANK,

	ARMOR_ARMY_BODYARMOR,
	ARMOR_CHAR_LIGHT_BODYARMOR,
	ARMOR_HELLS_SOULS_JACKET,
	ARMOR_FREE_ANGELS_JACKET,
	ARMOR_POLICE_JACKET,
	ARMOR_POLICE_RIOT,
	ARMOR_HUNTER_VEST,

	TRACKER_BLACKOPS,
	TRACKER_CELL_PHONE,
	TRACKER_ZTRACKER,
	TRACKER_POLICE_RADIO,

	SPRAY_PAINT1,
	SPRAY_PAINT2,
	SPRAY_PAINT3,
	SPRAY_PAINT4,

	SCENT_SPRAY_STENCH_KILLER,

	LIGHT_FLASHLIGHT,
	LIGHT_BIG_FLASHLIGHT,

	AMMO_LIGHT_PISTOL,
	AMMO_HEAVY_PISTOL,
	AMMO_LIGHT_RIFLE,
	AMMO_HEAVY_RIFLE,
	AMMO_SHOTGUN,
	AMMO_BOLTS,

	TRAP_EMPTY_CAN,
	TRAP_BEAR_TRAP,
	TRAP_SPIKES,
	TRAP_BARBED_WIRE,

	ENT_BOOK,
	ENT_MAGAZINE,

	UNIQUE_SUBWAY_BADGE,
	UNIQUE_FAMU_FATARU_KATANA,
	UNIQUE_BIGBEAR_BAT,
	UNIQUE_ROGUEDJACK_KEYBOARD,
	UNIQUE_SANTAMAN_SHOTGUN,
	UNIQUE_HANS_VON_HANZ_PISTOL,

	_COUNT
}


# Fields
# Untyped array: entries may be null before CreateModels().
var models: Array = []

# Data read from the CSVs, kept until CreateModels() builds the models.
# Untyped: null until the corresponding load_xxx_from_csv() ran.
var data_medicine_bandage = null
var data_medicine_medikit = null
var data_medicine_pills_sta = null
var data_medicine_pills_slp = null
var data_medicine_pills_san = null
var data_medicine_pills_antiviral = null
var data_food_army_ration = null
var data_food_groceries = null
var data_food_canned_food = null
var data_melee_crowbar = null
var data_melee_baseballbat = null
var data_melee_combat_knife = null
var data_melee_unique_jason_myers_axe = null
var data_melee_golfclub = null
var data_melee_huge_hammer = null
var data_melee_small_hammer = null
var data_melee_iron_golfclub = null
var data_melee_shovel = null
var data_melee_short_shovel = null
var data_melee_truncheon = null
var data_melee_improvised_club = null
var data_melee_improvised_spear = null
var data_melee_unique_famu_fataru_katana = null
var data_melee_unique_bigbear_bat = null
var data_melee_unique_roguedjack_keyboard = null
var data_ranged_army_pistol = null
var data_ranged_army_rifle = null
var data_ranged_hunting_crossbow = null
var data_ranged_hunting_rifle = null
var data_ranged_kolt_revolver = null
var data_ranged_pistol = null
var data_ranged_precision_rifle = null
var data_ranged_shotgun = null
var data_unique_santaman_shotgun = null
var data_unique_hans_von_hanz_pistol = null
var data_explosive_grenade = null
var data_bar_wooden_plank = null
var data_armor_army = null
var data_armor_char = null
var data_armor_hells_souls_jacket = null
var data_armor_free_angels_jacket = null
var data_armor_police_jacket = null
var data_armor_police_riot = null
var data_armor_hunter_vest = null
var data_tracker_blackops_gps = null
var data_tracker_cell_phone = null
var data_tracker_ztracker = null
var data_tracker_police_radio = null
var data_spray_paint1 = null
var data_spray_paint2 = null
var data_spray_paint3 = null
var data_spray_paint4 = null
var data_light_flashlight = null
var data_light_big_flashlight = null
var data_scent_spray_stench_killer = null
var data_trap_empty_can = null
var data_trap_bear_trap = null
var data_trap_spikes = null
var data_trap_barbed_wire = null
var data_ent_book = null
var data_ent_magazine = null


func _init() -> void:
	models.resize(IDs._COUNT)
	# bind
	Models.items = self


## C# this[int id] getter.
func get_model(p_id: int) -> ItemModel:
	return models[p_id]


## C# this[IDs id] setter (assigning a model binds its ID).
func set_model(p_id: int, p_model: ItemModel) -> void:
	models[p_id] = p_model
	models[p_id].id = p_id


static func id_name(p_id: int) -> String:
	# C# modelID.ToString() -> enum member name. The first real ID aliases
	# _FIRST (=0); the shipped CSVs label that row either "_FIRST" or with the
	# aliased member name, so accept both spellings when looking up rows.
	return IDs.keys()[p_id]


## All enum member names sharing this value (e.g. "_FIRST" and
## "MEDICINE_BANDAGES" both have value 0).
static func id_names(p_id: int) -> Array:
	var out: Array = []
	for n in IDs.keys():
		if IDs[n] == p_id:
			out.append(n)
	return out


# region Accessors (C# public properties)

# Medicine
func bandage() -> ItemMedicineModel:
	return models[IDs.MEDICINE_BANDAGES] as ItemMedicineModel

func medikit() -> ItemMedicineModel:
	return models[IDs.MEDICINE_MEDIKIT] as ItemMedicineModel

func pills_sta() -> ItemMedicineModel:
	return models[IDs.MEDICINE_PILLS_STA] as ItemMedicineModel

func pills_slp() -> ItemMedicineModel:
	return models[IDs.MEDICINE_PILLS_SLP] as ItemMedicineModel

func pills_san() -> ItemMedicineModel:
	return models[IDs.MEDICINE_PILLS_SAN] as ItemMedicineModel

func pills_antiviral() -> ItemMedicineModel:
	return models[IDs.MEDICINE_PILLS_ANTIVIRAL] as ItemMedicineModel

# Food
func army_ration() -> ItemFoodModel:
	return models[IDs.FOOD_ARMY_RATION] as ItemFoodModel

func groceries() -> ItemFoodModel:
	return models[IDs.FOOD_GROCERIES] as ItemFoodModel

func canned_food() -> ItemFoodModel:
	return models[IDs.FOOD_CANNED_FOOD] as ItemFoodModel

# Melee weapons
func crowbar() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_CROWBAR] as ItemMeleeWeaponModel

func baseball_bat() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_BASEBALLBAT] as ItemMeleeWeaponModel

func combat_knife() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_COMBAT_KNIFE] as ItemMeleeWeaponModel

func unique_jason_myers_axe() -> ItemMeleeWeaponModel:
	return models[IDs.UNIQUE_JASON_MYERS_AXE] as ItemMeleeWeaponModel

func golf_club() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_GOLFCLUB] as ItemMeleeWeaponModel

func huge_hammer() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_HUGE_HAMMER] as ItemMeleeWeaponModel

func small_hammer() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_SMALL_HAMMER] as ItemMeleeWeaponModel

func iron_golf_club() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_IRON_GOLFCLUB] as ItemMeleeWeaponModel

func shovel() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_SHOVEL] as ItemMeleeWeaponModel

func short_shovel() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_SHORT_SHOVEL] as ItemMeleeWeaponModel

func truncheon() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_TRUNCHEON] as ItemMeleeWeaponModel

func improvised_club() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_IMPROVISED_CLUB] as ItemMeleeWeaponModel

func improvised_spear() -> ItemMeleeWeaponModel:
	return models[IDs.MELEE_IMPROVISED_SPEAR] as ItemMeleeWeaponModel

func unique_famu_fataru_katana() -> ItemMeleeWeaponModel:
	return models[IDs.UNIQUE_FAMU_FATARU_KATANA] as ItemMeleeWeaponModel

func unique_bigbear_bat() -> ItemMeleeWeaponModel:
	return models[IDs.UNIQUE_BIGBEAR_BAT] as ItemMeleeWeaponModel

func unique_roguedjack_keyboard() -> ItemMeleeWeaponModel:
	return models[IDs.UNIQUE_ROGUEDJACK_KEYBOARD] as ItemMeleeWeaponModel

# Ranged weapons
func army_pistol() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_ARMY_PISTOL] as ItemRangedWeaponModel

func army_rifle() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_ARMY_RIFLE] as ItemRangedWeaponModel

func hunting_crossbow() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_HUNTING_CROSSBOW] as ItemRangedWeaponModel

func hunting_rifle() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_HUNTING_RIFLE] as ItemRangedWeaponModel

func kolt_revolver() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_KOLT_REVOLVER] as ItemRangedWeaponModel

func pistol() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_PISTOL] as ItemRangedWeaponModel

func precision_rifle() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_PRECISION_RIFLE] as ItemRangedWeaponModel

func shotgun() -> ItemRangedWeaponModel:
	return models[IDs.RANGED_SHOTGUN] as ItemRangedWeaponModel

func unique_santaman_shotgun() -> ItemRangedWeaponModel:
	return models[IDs.UNIQUE_SANTAMAN_SHOTGUN] as ItemRangedWeaponModel

func unique_hans_von_hanz_pistol() -> ItemRangedWeaponModel:
	return models[IDs.UNIQUE_HANS_VON_HANZ_PISTOL] as ItemRangedWeaponModel

# Ammos
func ammo_light_pistol() -> ItemAmmoModel:
	return models[IDs.AMMO_LIGHT_PISTOL] as ItemAmmoModel

func ammo_heavy_pistol() -> ItemAmmoModel:
	return models[IDs.AMMO_HEAVY_PISTOL] as ItemAmmoModel

func ammo_light_rifle() -> ItemAmmoModel:
	return models[IDs.AMMO_LIGHT_RIFLE] as ItemAmmoModel

func ammo_heavy_rifle() -> ItemAmmoModel:
	return models[IDs.AMMO_HEAVY_RIFLE] as ItemAmmoModel

func ammo_shotgun() -> ItemAmmoModel:
	return models[IDs.AMMO_SHOTGUN] as ItemAmmoModel

func ammo_bolts() -> ItemAmmoModel:
	return models[IDs.AMMO_BOLTS] as ItemAmmoModel

# Explosives
func grenade() -> ItemGrenadeModel:
	return models[IDs.EXPLOSIVE_GRENADE] as ItemGrenadeModel

func grenade_primed() -> ItemGrenadePrimedModel:
	return models[IDs.EXPLOSIVE_GRENADE_PRIMED] as ItemGrenadePrimedModel

# Barricades
func woodenplank() -> ItemBarricadeMaterialModel:
	return models[IDs.BAR_WOODEN_PLANK] as ItemBarricadeMaterialModel

# Body armors
func army_bodyarmor() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_ARMY_BODYARMOR] as ItemBodyArmorModel

func char_lt_bodyarmor() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_CHAR_LIGHT_BODYARMOR] as ItemBodyArmorModel

func hells_souls_jacket() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_HELLS_SOULS_JACKET] as ItemBodyArmorModel

func free_angels_jacket() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_FREE_ANGELS_JACKET] as ItemBodyArmorModel

func police_jacket() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_POLICE_JACKET] as ItemBodyArmorModel

func police_riot() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_POLICE_RIOT] as ItemBodyArmorModel

func hunter_vest() -> ItemBodyArmorModel:
	return models[IDs.ARMOR_HUNTER_VEST] as ItemBodyArmorModel

# Trackers
func blackops_gps() -> ItemTrackerModel:
	return models[IDs.TRACKER_BLACKOPS] as ItemTrackerModel

func cell_phone() -> ItemTrackerModel:
	return models[IDs.TRACKER_CELL_PHONE] as ItemTrackerModel

func ztracker() -> ItemTrackerModel:
	return models[IDs.TRACKER_ZTRACKER] as ItemTrackerModel

func police_radio() -> ItemTrackerModel:
	return models[IDs.TRACKER_POLICE_RADIO] as ItemTrackerModel

# Spray paint
func spray_paint1() -> ItemSprayPaintModel:
	return models[IDs.SPRAY_PAINT1] as ItemSprayPaintModel

func spray_paint2() -> ItemSprayPaintModel:
	return models[IDs.SPRAY_PAINT2] as ItemSprayPaintModel

func spray_paint3() -> ItemSprayPaintModel:
	return models[IDs.SPRAY_PAINT3] as ItemSprayPaintModel

func spray_paint4() -> ItemSprayPaintModel:
	return models[IDs.SPRAY_PAINT4] as ItemSprayPaintModel

# Lights
func flashlight() -> ItemLightModel:
	return models[IDs.LIGHT_FLASHLIGHT] as ItemLightModel

func big_flashlight() -> ItemLightModel:
	return models[IDs.LIGHT_BIG_FLASHLIGHT] as ItemLightModel

# Scent sprays
func stench_killer() -> ItemModel:
	return models[IDs.SCENT_SPRAY_STENCH_KILLER]

# Traps
func empty_can() -> ItemModel:
	return models[IDs.TRAP_EMPTY_CAN]

func bear_trap() -> ItemModel:
	return models[IDs.TRAP_BEAR_TRAP]

func spikes() -> ItemModel:
	return models[IDs.TRAP_SPIKES]

func barbed_wire() -> ItemModel:
	return models[IDs.TRAP_BARBED_WIRE]

# Entertainment
func book() -> ItemModel:
	return models[IDs.ENT_BOOK]

func magazine() -> ItemModel:
	return models[IDs.ENT_MAGAZINE]

# Special uniques
func unique_subway_badge() -> ItemModel:
	return models[IDs.UNIQUE_SUBWAY_BADGE]

# endregion


# region Init

# region Grammar helpers
func starts_with_vowel(p_name: String) -> bool:
	var c := p_name[0]
	return c == 'a' or c == 'A' \
			or c == 'e' or c == 'E' \
			or c == 'i' or c == 'I' \
			or c == 'y' or c == 'Y'


func check_plural(p_name: String, p_plural: String) -> bool:
	return p_name == p_plural
# endregion


## FIXME: clean up the code (sometimes uses temp local var, sometimes use explicit model)
func create_models() -> void:
	# region Medicine
	var m := ItemMedicineModel.new(data_medicine_bandage.name, data_medicine_bandage.plural, GameImages.ITEM_BANDAGES,
			data_medicine_bandage.healing, data_medicine_bandage.stamina_boost, data_medicine_bandage.sleep_boost,
			data_medicine_bandage.infection_cure, data_medicine_bandage.sanity_cure)
	m.is_plural = true
	m.is_stackable = true
	m.stacking_limit = data_medicine_bandage.stacking_limit
	m.flavor_description = data_medicine_bandage.flavor
	set_model(IDs.MEDICINE_BANDAGES, m)

	m = ItemMedicineModel.new(data_medicine_medikit.name, data_medicine_medikit.plural, GameImages.ITEM_MEDIKIT,
			data_medicine_medikit.healing, data_medicine_medikit.stamina_boost, data_medicine_medikit.sleep_boost,
			data_medicine_medikit.infection_cure, data_medicine_medikit.sanity_cure)
	m.flavor_description = data_medicine_medikit.flavor
	set_model(IDs.MEDICINE_MEDIKIT, m)

	m = ItemMedicineModel.new(data_medicine_pills_sta.name, data_medicine_pills_sta.plural, GameImages.ITEM_PILLS_GREEN,
			data_medicine_pills_sta.healing, data_medicine_pills_sta.stamina_boost, data_medicine_pills_sta.sleep_boost,
			data_medicine_pills_sta.infection_cure, data_medicine_pills_sta.sanity_cure)
	m.is_plural = true
	m.is_stackable = true
	m.stacking_limit = data_medicine_pills_sta.stacking_limit
	m.flavor_description = data_medicine_pills_sta.flavor
	set_model(IDs.MEDICINE_PILLS_STA, m)

	m = ItemMedicineModel.new(data_medicine_pills_slp.name, data_medicine_pills_slp.plural, GameImages.ITEM_PILLS_BLUE,
			data_medicine_pills_slp.healing, data_medicine_pills_slp.stamina_boost, data_medicine_pills_slp.sleep_boost,
			data_medicine_pills_slp.infection_cure, data_medicine_pills_slp.sanity_cure)
	m.is_plural = true
	m.is_stackable = true
	m.stacking_limit = data_medicine_pills_slp.stacking_limit
	m.flavor_description = data_medicine_pills_slp.flavor
	set_model(IDs.MEDICINE_PILLS_SLP, m)

	m = ItemMedicineModel.new(data_medicine_pills_san.name, data_medicine_pills_san.plural, GameImages.ITEM_PILLS_SAN,
			data_medicine_pills_san.healing, data_medicine_pills_san.stamina_boost, data_medicine_pills_san.sleep_boost,
			data_medicine_pills_san.infection_cure, data_medicine_pills_san.sanity_cure)
	m.is_plural = true
	m.is_stackable = true
	m.stacking_limit = data_medicine_pills_san.stacking_limit
	m.flavor_description = data_medicine_pills_san.flavor
	set_model(IDs.MEDICINE_PILLS_SAN, m)

	m = ItemMedicineModel.new(data_medicine_pills_antiviral.name, data_medicine_pills_antiviral.plural, GameImages.ITEM_PILLS_ANTIVIRAL,
			data_medicine_pills_antiviral.healing, data_medicine_pills_antiviral.stamina_boost, data_medicine_pills_antiviral.sleep_boost,
			data_medicine_pills_antiviral.infection_cure, data_medicine_pills_antiviral.sanity_cure)
	m.is_plural = true
	m.is_stackable = true
	m.stacking_limit = data_medicine_pills_antiviral.stacking_limit
	m.flavor_description = data_medicine_pills_antiviral.flavor
	set_model(IDs.MEDICINE_PILLS_ANTIVIRAL, m)
	# endregion

	# region Food
	var f := ItemFoodModel.new(data_food_army_ration.name, data_food_army_ration.plural, GameImages.ITEM_ARMY_RATION,
			data_food_army_ration.nutrition, data_food_army_ration.best_before)
	f.is_an = starts_with_vowel(data_food_army_ration.name)
	f.is_plural = check_plural(data_food_army_ration.name, data_food_army_ration.plural)
	f.stacking_limit = data_food_army_ration.stacking_limit
	f.flavor_description = data_food_army_ration.flavor
	set_model(IDs.FOOD_ARMY_RATION, f)

	f = ItemFoodModel.new(data_food_groceries.name, data_food_groceries.plural, GameImages.ITEM_GROCERIES,
			data_food_groceries.nutrition, data_food_groceries.best_before)
	f.is_an = starts_with_vowel(data_food_groceries.name)
	f.is_plural = check_plural(data_food_groceries.name, data_food_groceries.plural)
	f.stacking_limit = data_food_groceries.stacking_limit
	f.flavor_description = data_food_groceries.flavor
	set_model(IDs.FOOD_GROCERIES, f)

	f = ItemFoodModel.new(data_food_canned_food.name, data_food_canned_food.plural, GameImages.ITEM_CANNED_FOOD,
			data_food_canned_food.nutrition, data_food_canned_food.best_before)
	f.is_an = starts_with_vowel(data_food_canned_food.name)
	f.is_plural = check_plural(data_food_canned_food.name, data_food_canned_food.plural)
	f.stacking_limit = data_food_canned_food.stacking_limit
	f.is_stackable = true
	f.flavor_description = data_food_canned_food.flavor
	set_model(IDs.FOOD_CANNED_FOOD, f)
	# endregion

	# region Melee weapons
	# alpha10 disarm chance added to attack, tool bonuses added to properties
	var mwdata = data_melee_baseballbat
	var mw := ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_BASEBALL_BAT,
			Attack.melee_attack(Verb.new("smash", "smashes"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_BASEBALLBAT, mw)

	mwdata = data_melee_combat_knife
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_COMBAT_KNIFE,
			Attack.melee_attack(Verb.new("stab"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = true
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_COMBAT_KNIFE, mw)

	mwdata = data_melee_crowbar
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_CROWBAR,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = true
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_CROWBAR, mw)

	mwdata = data_melee_unique_jason_myers_axe
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_JASON_MYERS_AXE,
			Attack.melee_attack(Verb.new("slash", "slashes"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_proper = true
	mw.flavor_description = mwdata.flavor
	mw.is_unbreakable = true
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.UNIQUE_JASON_MYERS_AXE, mw)

	mwdata = data_melee_golfclub
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_GOLF_CLUB,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_GOLFCLUB, mw)

	mwdata = data_melee_iron_golfclub
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_IRON_GOLF_CLUB,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_IRON_GOLFCLUB, mw)

	mwdata = data_melee_huge_hammer
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_HUGE_HAMMER,
			Attack.melee_attack(Verb.new("smash", "smashes"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_HUGE_HAMMER, mw)

	mwdata = data_melee_shovel
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_SHOVEL,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_SHOVEL, mw)

	mwdata = data_melee_short_shovel
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_SHORT_SHOVEL,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_SHORT_SHOVEL, mw)

	mwdata = data_melee_truncheon
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_TRUNCHEON,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = true
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_TRUNCHEON, mw)

	mwdata = data_melee_improvised_club
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_IMPROVISED_CLUB,
			Attack.melee_attack(Verb.new("strike"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_IMPROVISED_CLUB, mw)

	mwdata = data_melee_improvised_spear
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_IMPROVISED_SPEAR,
			Attack.melee_attack(Verb.new("pierce"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_IMPROVISED_SPEAR, mw)

	mwdata = data_melee_small_hammer
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_SMALL_HAMMER,
			Attack.melee_attack(Verb.new("smash"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.is_stackable = (mwdata.stacking_limit > 1)
	mw.stacking_limit = mwdata.stacking_limit
	mw.flavor_description = mwdata.flavor
	mw.is_fragile = mwdata.is_fragile
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.MELEE_SMALL_HAMMER, mw)

	mwdata = data_melee_unique_famu_fataru_katana
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_FAMU_FATARU_KATANA,
			Attack.melee_attack(Verb.new("slash", "slashes"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.flavor_description = mwdata.flavor
	mw.is_proper = true
	mw.is_unbreakable = true
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.UNIQUE_FAMU_FATARU_KATANA, mw)

	mwdata = data_melee_unique_bigbear_bat
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_BIGBEAR_BAT,
			Attack.melee_attack(Verb.new("smash", "smashes"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.flavor_description = mwdata.flavor
	mw.is_proper = true
	mw.is_unbreakable = true
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.UNIQUE_BIGBEAR_BAT, mw)

	mwdata = data_melee_unique_roguedjack_keyboard
	mw = ItemMeleeWeaponModel.new(mwdata.name, mwdata.plural, GameImages.ITEM_ROGUEDJACK_KEYBOARD,
			Attack.melee_attack(Verb.new("bash", "bashes"), mwdata.atk, mwdata.dmg, mwdata.sta, mwdata.disarm))
	mw.equipment_part = Doll.DollPart.RIGHT_HAND
	mw.flavor_description = mwdata.flavor
	mw.is_proper = true
	mw.is_unbreakable = true
	mw.tool_bash_damage_bonus = mwdata.tool_bash_dmg_bonus  # alpha10
	mw.tool_build_bonus = mwdata.tool_build_bonus  # alpha10
	set_model(IDs.UNIQUE_ROGUEDJACK_KEYBOARD, mw)
	# endregion

	# region Ranged weapons
	# alpha10 rapid fire property
	# note: the C# passes rwp.FLAVOR as the plural-name argument (quirk kept).
	var rwp = data_ranged_army_pistol
	var rw := ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_ARMY_PISTOL,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.HEAVY_PISTOL)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	rw.is_an = true
	set_model(IDs.RANGED_ARMY_PISTOL, rw)

	rwp = data_ranged_army_rifle
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_ARMY_RIFLE,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("fire a salvo at", "fires a salvo at"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.HEAVY_RIFLE)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	rw.is_an = true
	set_model(IDs.RANGED_ARMY_RIFLE, rw)

	rwp = data_ranged_hunting_crossbow
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_HUNTING_CROSSBOW,
			Attack.ranged_attack(Attack.AttackKind.BOW, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.BOLT)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	set_model(IDs.RANGED_HUNTING_CROSSBOW, rw)

	rwp = data_ranged_hunting_rifle
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_HUNTING_RIFLE,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.LIGHT_RIFLE)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	set_model(IDs.RANGED_HUNTING_RIFLE, rw)

	rwp = data_ranged_pistol
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_PISTOL,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.LIGHT_PISTOL)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	set_model(IDs.RANGED_PISTOL, rw)

	rwp = data_ranged_kolt_revolver
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_KOLT_REVOLVER,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.LIGHT_PISTOL)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	set_model(IDs.RANGED_KOLT_REVOLVER, rw)

	rwp = data_ranged_precision_rifle
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_PRECISION_RIFLE,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.HEAVY_RIFLE)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	set_model(IDs.RANGED_PRECISION_RIFLE, rw)

	rwp = data_ranged_shotgun
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_SHOTGUN,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.SHOTGUN)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	set_model(IDs.RANGED_SHOTGUN, rw)

	rwp = data_unique_santaman_shotgun
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_SANTAMAN_SHOTGUN,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.SHOTGUN)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	rw.is_proper = true
	rw.is_unbreakable = true
	set_model(IDs.UNIQUE_SANTAMAN_SHOTGUN, rw)

	rwp = data_unique_hans_von_hanz_pistol
	rw = ItemRangedWeaponModel.new(rwp.name, rwp.flavor, GameImages.ITEM_HANS_VON_HANZ_PISTOL,
			Attack.ranged_attack(Attack.AttackKind.FIREARM, Verb.new("shoot"), rwp.atk, rwp.rapid1, rwp.rapid2, rwp.dmg, rwp.range_value),
			rwp.max_ammo, ItemAmmoModel.AmmoType.LIGHT_PISTOL)
	rw.equipment_part = Doll.DollPart.RIGHT_HAND
	rw.flavor_description = rwp.flavor
	rw.is_proper = true
	rw.is_unbreakable = true
	set_model(IDs.UNIQUE_HANS_VON_HANZ_PISTOL, rw)
	# endregion

	# region Ammos
	var am := ItemAmmoModel.new("light pistol bullets", "light pistol bullets", GameImages.ITEM_AMMO_LIGHT_PISTOL,
			ItemAmmoModel.AmmoType.LIGHT_PISTOL, 20)
	am.is_plural = true
	am.flavor_description = ""
	set_model(IDs.AMMO_LIGHT_PISTOL, am)

	am = ItemAmmoModel.new("heavy pistol bullets", "heavy pistol bullets", GameImages.ITEM_AMMO_HEAVY_PISTOL,
			ItemAmmoModel.AmmoType.HEAVY_PISTOL, 12)
	am.is_plural = true
	am.flavor_description = ""
	set_model(IDs.AMMO_HEAVY_PISTOL, am)

	am = ItemAmmoModel.new("light rifle bullets", "light rifle bullets", GameImages.ITEM_AMMO_LIGHT_RIFLE,
			ItemAmmoModel.AmmoType.LIGHT_RIFLE, 14)
	am.is_plural = true
	am.flavor_description = ""
	set_model(IDs.AMMO_LIGHT_RIFLE, am)

	am = ItemAmmoModel.new("heavy rifle bullets", "heavy rifle bullets", GameImages.ITEM_AMMO_HEAVY_RIFLE,
			ItemAmmoModel.AmmoType.HEAVY_RIFLE, 20)
	am.is_plural = true
	am.flavor_description = ""
	set_model(IDs.AMMO_HEAVY_RIFLE, am)

	am = ItemAmmoModel.new("shotgun shells", "shotgun shells", GameImages.ITEM_AMMO_SHOTGUN,
			ItemAmmoModel.AmmoType.SHOTGUN, 10)
	am.is_plural = true
	am.flavor_description = ""
	set_model(IDs.AMMO_SHOTGUN, am)

	am = ItemAmmoModel.new("crossbow bolts", "crossbow bolts", GameImages.ITEM_AMMO_BOLTS,
			ItemAmmoModel.AmmoType.BOLT, 30)
	am.is_plural = true
	am.flavor_description = ""
	set_model(IDs.AMMO_BOLTS, am)
	# endregion

	# region Explosives
	var ex_data = data_explosive_grenade
	var ex_array: Array[int] = []
	ex_array.resize(ex_data.radius + 1)
	for i in ex_data.radius + 1:
		ex_array[i] = ex_data.dmg[i]
	var gr := ItemGrenadeModel.new(ex_data.name, ex_data.plural, GameImages.ITEM_GRENADE,
			ex_data.fuse, BlastAttack.new(ex_data.radius, ex_array, true, false), GameImages.ICON_BLAST, ex_data.max_throw)
	gr.equipment_part = Doll.DollPart.RIGHT_HAND
	gr.is_stackable = true
	gr.stacking_limit = ex_data.stacking_limit
	gr.flavor_description = ex_data.flavor
	set_model(IDs.EXPLOSIVE_GRENADE, gr)

	var grp := ItemGrenadePrimedModel.new("primed " + ex_data.name, "primed " + ex_data.plural,
			GameImages.ITEM_GRENADE_PRIMED, models[IDs.EXPLOSIVE_GRENADE] as ItemGrenadeModel)
	grp.equipment_part = Doll.DollPart.RIGHT_HAND
	set_model(IDs.EXPLOSIVE_GRENADE_PRIMED, grp)
	# endregion

	# region Barricade material
	var bar_data = data_bar_wooden_plank
	var bar := ItemBarricadeMaterialModel.new(bar_data.name, bar_data.plural, GameImages.ITEM_WOODEN_PLANK, bar_data.value)
	bar.is_stackable = (bar_data.stacking_limit > 1)
	bar.stacking_limit = bar_data.stacking_limit
	bar.flavor_description = bar_data.flavor
	set_model(IDs.BAR_WOODEN_PLANK, bar)
	# endregion

	# region Bodyarmors
	var arm_data = data_armor_army
	var arm := ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_ARMY_BODYARMOR,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_ARMY_BODYARMOR, arm)

	arm_data = data_armor_char
	arm = ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_CHAR_LIGHT_BODYARMOR,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_CHAR_LIGHT_BODYARMOR, arm)

	arm_data = data_armor_hells_souls_jacket
	arm = ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_HELLS_SOULS_JACKET,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_HELLS_SOULS_JACKET, arm)

	arm_data = data_armor_free_angels_jacket
	arm = ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_FREE_ANGELS_JACKET,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_FREE_ANGELS_JACKET, arm)

	arm_data = data_armor_police_jacket
	arm = ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_POLICE_JACKET,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_POLICE_JACKET, arm)

	arm_data = data_armor_police_riot
	arm = ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_POLICE_RIOT_ARMOR,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_POLICE_RIOT, arm)

	arm_data = data_armor_hunter_vest
	arm = ItemBodyArmorModel.new(arm_data.name, arm_data.plural, GameImages.ITEM_HUNTER_VEST,
			arm_data.pro_hit, arm_data.pro_shot, arm_data.enc, arm_data.weight)
	arm.equipment_part = Doll.DollPart.TORSO
	arm.flavor_description = arm_data.flavor
	arm.is_an = starts_with_vowel(arm_data.name)
	set_model(IDs.ARMOR_HUNTER_VEST, arm)
	# endregion

	# region Trackers
	# alpha10 added clock prop to trackers
	var tra_data = data_tracker_cell_phone
	var tra := ItemTrackerModel.new(tra_data.name, tra_data.plural, GameImages.ITEM_CELL_PHONE,
			ItemTrackerModel.TrackingFlags.FOLLOWER_AND_LEADER,
			tra_data.batteries * WorldTime.TURNS_PER_HOUR,
			tra_data.has_clock)
	tra.equipment_part = Doll.DollPart.LEFT_HAND
	tra.flavor_description = tra_data.flavor
	set_model(IDs.TRACKER_CELL_PHONE, tra)

	tra_data = data_tracker_ztracker
	tra = ItemTrackerModel.new(tra_data.name, tra_data.plural, GameImages.ITEM_ZTRACKER,
			ItemTrackerModel.TrackingFlags.UNDEADS,
			tra_data.batteries * WorldTime.TURNS_PER_HOUR,
			tra_data.has_clock)
	tra.equipment_part = Doll.DollPart.LEFT_HAND
	tra.flavor_description = tra_data.flavor
	set_model(IDs.TRACKER_ZTRACKER, tra)

	tra_data = data_tracker_blackops_gps
	tra = ItemTrackerModel.new(tra_data.name, tra_data.plural, GameImages.ITEM_BLACKOPS_GPS,
			ItemTrackerModel.TrackingFlags.BLACKOPS_FACTION,
			tra_data.batteries * WorldTime.TURNS_PER_HOUR,
			tra_data.has_clock)
	tra.equipment_part = Doll.DollPart.LEFT_HAND
	tra.flavor_description = tra_data.flavor
	set_model(IDs.TRACKER_BLACKOPS, tra)

	tra_data = data_tracker_police_radio
	tra = ItemTrackerModel.new(tra_data.name, tra_data.plural, GameImages.ITEM_POLICE_RADIO,
			ItemTrackerModel.TrackingFlags.POLICE_FACTION,
			tra_data.batteries * WorldTime.TURNS_PER_HOUR,
			tra_data.has_clock)
	tra.equipment_part = Doll.DollPart.LEFT_HAND
	tra.flavor_description = tra_data.flavor
	set_model(IDs.TRACKER_POLICE_RADIO, tra)
	# endregion

	# region Spray paint
	var sp_data = data_spray_paint1
	var sp := ItemSprayPaintModel.new(sp_data.name, sp_data.plural, GameImages.ITEM_SPRAYPAINT, sp_data.quantity, GameImages.DECO_PLAYER_TAG1)
	sp.equipment_part = Doll.DollPart.LEFT_HAND
	sp.flavor_description = sp_data.flavor
	set_model(IDs.SPRAY_PAINT1, sp)

	sp_data = data_spray_paint2
	sp = ItemSprayPaintModel.new(sp_data.name, sp_data.plural, GameImages.ITEM_SPRAYPAINT2, sp_data.quantity, GameImages.DECO_PLAYER_TAG2)
	sp.equipment_part = Doll.DollPart.LEFT_HAND
	sp.flavor_description = sp_data.flavor
	set_model(IDs.SPRAY_PAINT2, sp)

	sp_data = data_spray_paint3
	sp = ItemSprayPaintModel.new(sp_data.name, sp_data.plural, GameImages.ITEM_SPRAYPAINT3, sp_data.quantity, GameImages.DECO_PLAYER_TAG3)
	sp.equipment_part = Doll.DollPart.LEFT_HAND
	sp.flavor_description = sp_data.flavor
	set_model(IDs.SPRAY_PAINT3, sp)

	sp_data = data_spray_paint4
	sp = ItemSprayPaintModel.new(sp_data.name, sp_data.plural, GameImages.ITEM_SPRAYPAINT4, sp_data.quantity, GameImages.DECO_PLAYER_TAG4)
	sp.equipment_part = Doll.DollPart.LEFT_HAND
	sp.flavor_description = sp_data.flavor
	set_model(IDs.SPRAY_PAINT4, sp)
	# endregion

	# region Lights
	var lt_data = data_light_flashlight
	var lt := ItemLightModel.new(lt_data.name, lt_data.plural, GameImages.ITEM_FLASHLIGHT,
			lt_data.fov, lt_data.batteries * WorldTime.TURNS_PER_HOUR, GameImages.ITEM_FLASHLIGHT_OUT)
	lt.equipment_part = Doll.DollPart.LEFT_HAND
	lt.flavor_description = lt_data.flavor
	set_model(IDs.LIGHT_FLASHLIGHT, lt)

	lt_data = data_light_big_flashlight
	lt = ItemLightModel.new(lt_data.name, lt_data.plural, GameImages.ITEM_BIG_FLASHLIGHT,
			lt_data.fov, lt_data.batteries * WorldTime.TURNS_PER_HOUR, GameImages.ITEM_BIG_FLASHLIGHT_OUT)
	lt.equipment_part = Doll.DollPart.LEFT_HAND
	lt.flavor_description = lt_data.flavor
	set_model(IDs.LIGHT_BIG_FLASHLIGHT, lt)
	# endregion

	# region Scent sprays
	var ssp_data = data_scent_spray_stench_killer
	# alpha10 new way of using stench killer
	var ssp := ItemSprayScentModel.new(ssp_data.name, ssp_data.plural, GameImages.ITEM_STENCH_KILLER,
			ssp_data.quantity, Odor.SUPPRESSOR, ssp_data.strength * WorldTime.TURNS_PER_HOUR)
	ssp.equipment_part = Doll.DollPart.LEFT_HAND
	ssp.flavor_description = ssp_data.flavor
	set_model(IDs.SCENT_SPRAY_STENCH_KILLER, ssp)
	# endregion

	# region Traps
	var trp_data = data_trap_empty_can
	var trp := ItemTrapModel.new(trp_data.name, trp_data.plural, GameImages.ITEM_EMPTY_CAN,
			trp_data.stacking, trp_data.chance, trp_data.damage,
			trp_data.drop_activate, trp_data.use_activate, trp_data.is_one_time,
			trp_data.break_chance, trp_data.block_chance, trp_data.break_chance_escape,
			trp_data.is_noisy, trp_data.noise_name, trp_data.is_flammable)
	trp.flavor_description = trp_data.flavor
	set_model(IDs.TRAP_EMPTY_CAN, trp)

	trp_data = data_trap_bear_trap
	trp = ItemTrapModel.new(trp_data.name, trp_data.plural, GameImages.ITEM_BEAR_TRAP,
			trp_data.stacking, trp_data.chance, trp_data.damage,
			trp_data.drop_activate, trp_data.use_activate, trp_data.is_one_time,
			trp_data.break_chance, trp_data.block_chance, trp_data.break_chance_escape,
			trp_data.is_noisy, trp_data.noise_name, trp_data.is_flammable)
	trp.flavor_description = trp_data.flavor
	set_model(IDs.TRAP_BEAR_TRAP, trp)

	trp_data = data_trap_spikes
	trp = ItemTrapModel.new(trp_data.name, trp_data.plural, GameImages.ITEM_SPIKES,
			trp_data.stacking, trp_data.chance, trp_data.damage,
			trp_data.drop_activate, trp_data.use_activate, trp_data.is_one_time,
			trp_data.break_chance, trp_data.block_chance, trp_data.break_chance_escape,
			trp_data.is_noisy, trp_data.noise_name, trp_data.is_flammable)
	trp.flavor_description = trp_data.flavor
	set_model(IDs.TRAP_SPIKES, trp)

	trp_data = data_trap_barbed_wire
	trp = ItemTrapModel.new(trp_data.name, trp_data.plural, GameImages.ITEM_BARBED_WIRE,
			trp_data.stacking, trp_data.chance, trp_data.damage,
			trp_data.drop_activate, trp_data.use_activate, trp_data.is_one_time,
			trp_data.break_chance, trp_data.block_chance, trp_data.break_chance_escape,
			trp_data.is_noisy, trp_data.noise_name, trp_data.is_flammable)
	trp.flavor_description = trp_data.flavor
	set_model(IDs.TRAP_BARBED_WIRE, trp)
	# endregion

	# region Entertainment
	var ent_data = data_ent_book
	var ent := ItemEntertainmentModel.new(ent_data.name, ent_data.plural, GameImages.ITEM_BOOK, ent_data.value, ent_data.bore_chance)
	ent.stacking_limit = ent_data.stacking
	ent.flavor_description = ent_data.flavor
	set_model(IDs.ENT_BOOK, ent)

	ent_data = data_ent_magazine
	ent = ItemEntertainmentModel.new(ent_data.name, ent_data.plural, GameImages.ITEM_MAGAZINE, ent_data.value, ent_data.bore_chance)
	ent.stacking_limit = ent_data.stacking
	ent.flavor_description = ent_data.flavor
	set_model(IDs.ENT_MAGAZINE, ent)
	# endregion

	# region Uniques
	var badge := ItemModel.new("Subway Worker Badge", "Subways Worker Badges", GameImages.ITEM_SUBWAY_BADGE)
	badge.dont_auto_equip = true
	badge.equipment_part = Doll.DollPart.LEFT_HAND
	badge.flavor_description = "You got yourself a new job!"
	set_model(IDs.UNIQUE_SUBWAY_BADGE, badge)
	# endregion

	# region Fixes/Post processing
	for i in range(IDs._FIRST, IDs._COUNT):
		var model: ItemModel = models[i]

		# grammar.
		model.is_an = starts_with_vowel(model.single_name)

		# IsStackable
		model.is_stackable = model.stacking_limit > 1
	# endregion
# endregion


# region Data loading

# region Helpers
func _notify(ui: IRogueUI, what: String, stage: String) -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading " + what + " data : " + stage, 0, 0)
	ui.ui_repaint()


func _find_line_for_model(table: CSVParser.CSVTable, model_id: int) -> CSVParser.CSVLine:
	var wanted := id_names(model_id)
	for l in table.lines:
		if wanted.has(l.get_field(0).parse_text()):
			return l
	return null


func _get_data_from_csv_table(_ui: IRogueUI, table: CSVParser.CSVTable, fn: Callable, model_id: int):
	# get line for model in table.
	var line := _find_line_for_model(table, model_id)
	if line == null:
		push_error("model %s not found" % id_name(model_id))
		return null

	# get data from line.
	return fn.call(line)


## C# LoadDataFromCSV<_DATA_TYPE_>(..., out _DATA_TYPE_[] data) -> the loaded
## data array is returned (GDScript has no out params). Elements follow the
## order of ids_to_read.
func _load_data_from_csv(ui: IRogueUI, path: String, kind: String, fields_count: int,
		fn: Callable, ids_to_read: Array) -> Array:
	# Read & parse csv file.
	_notify(ui, kind, "loading file...")
	# read the whole file.
	var raw_lines := CSVParser.read_lines_cp1252(path)
	if raw_lines.size() == 1 && raw_lines[0].is_empty():
		push_error("cannot open CSV file %s" % path)
		return []
	var all_lines := PackedStringArray()
	for i in raw_lines.size():
		# skip header; also drop empty lines (trailing newline).
		if i == 0 || raw_lines[i].strip_edges().is_empty():
			continue
		all_lines.append(raw_lines[i])

	# parse all the lines read.
	_notify(ui, kind, "parsing CSV...")
	var parser := CSVParser.new()
	var table := parser.parse_to_table(all_lines, fields_count)

	# Set data.
	_notify(ui, kind, "reading data...")
	var data: Array = []
	data.resize(ids_to_read.size())
	for i in ids_to_read.size():
		data[i] = _get_data_from_csv_table(ui, table, fn, ids_to_read[i])

	# all fine.
	_notify(ui, kind, "done!")
	return data
# endregion

# Medicine
func load_medicine_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "medicine items", MedecineData.COUNT_FIELDS,
			MedecineData.from_csv_line,
			[IDs.MEDICINE_BANDAGES, IDs.MEDICINE_MEDIKIT, IDs.MEDICINE_PILLS_SLP, IDs.MEDICINE_PILLS_STA, IDs.MEDICINE_PILLS_SAN,
			IDs.MEDICINE_PILLS_ANTIVIRAL])

	data_medicine_bandage = data[0]
	data_medicine_medikit = data[1]
	data_medicine_pills_slp = data[2]
	data_medicine_pills_sta = data[3]
	data_medicine_pills_san = data[4]
	data_medicine_pills_antiviral = data[5]

	return true

# Food
func load_food_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "food items", FoodData.COUNT_FIELDS,
			FoodData.from_csv_line,
			[IDs.FOOD_ARMY_RATION, IDs.FOOD_CANNED_FOOD, IDs.FOOD_GROCERIES])

	data_food_army_ration = data[0]
	data_food_canned_food = data[1]
	data_food_groceries = data[2]

	return true

# Melee weapons
func load_melee_weapons_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "melee weapons items", MeleeWeaponData.COUNT_FIELDS,
			MeleeWeaponData.from_csv_line,
			[IDs.MELEE_BASEBALLBAT, IDs.MELEE_COMBAT_KNIFE, IDs.MELEE_CROWBAR, IDs.MELEE_GOLFCLUB, IDs.MELEE_HUGE_HAMMER, IDs.MELEE_IRON_GOLFCLUB,
			IDs.MELEE_SHOVEL, IDs.MELEE_SHORT_SHOVEL, IDs.MELEE_TRUNCHEON, IDs.UNIQUE_JASON_MYERS_AXE,
			IDs.MELEE_IMPROVISED_CLUB, IDs.MELEE_IMPROVISED_SPEAR, IDs.MELEE_SMALL_HAMMER,
			IDs.UNIQUE_FAMU_FATARU_KATANA, IDs.UNIQUE_BIGBEAR_BAT, IDs.UNIQUE_ROGUEDJACK_KEYBOARD])

	data_melee_baseballbat = data[0]
	data_melee_combat_knife = data[1]
	data_melee_crowbar = data[2]
	data_melee_golfclub = data[3]
	data_melee_huge_hammer = data[4]
	data_melee_iron_golfclub = data[5]
	data_melee_shovel = data[6]
	data_melee_short_shovel = data[7]
	data_melee_truncheon = data[8]
	data_melee_unique_jason_myers_axe = data[9]
	data_melee_improvised_club = data[10]
	data_melee_improvised_spear = data[11]
	data_melee_small_hammer = data[12]
	data_melee_unique_famu_fataru_katana = data[13]
	data_melee_unique_bigbear_bat = data[14]
	data_melee_unique_roguedjack_keyboard = data[15]

	return true

# Ranged weapons
func load_ranged_weapons_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "ranged weapons items", RangedWeaponData.COUNT_FIELDS,
			RangedWeaponData.from_csv_line,
			[IDs.RANGED_ARMY_PISTOL, IDs.RANGED_ARMY_RIFLE, IDs.RANGED_HUNTING_CROSSBOW, IDs.RANGED_HUNTING_RIFLE, IDs.RANGED_KOLT_REVOLVER, IDs.RANGED_PISTOL, IDs.RANGED_PRECISION_RIFLE, IDs.RANGED_SHOTGUN,
			IDs.UNIQUE_SANTAMAN_SHOTGUN, IDs.UNIQUE_HANS_VON_HANZ_PISTOL])

	data_ranged_army_pistol = data[0]
	data_ranged_army_rifle = data[1]
	data_ranged_hunting_crossbow = data[2]
	data_ranged_hunting_rifle = data[3]
	data_ranged_kolt_revolver = data[4]
	data_ranged_pistol = data[5]
	data_ranged_precision_rifle = data[6]
	data_ranged_shotgun = data[7]
	data_unique_santaman_shotgun = data[8]
	data_unique_hans_von_hanz_pistol = data[9]

	return true

# Explosives
func load_explosives_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "explosives items", ExplosiveData.COUNT_FIELDS,
			ExplosiveData.from_csv_line,
			[IDs.EXPLOSIVE_GRENADE])

	data_explosive_grenade = data[0]

	return true

# Barricading material
func load_barricading_material_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "barricading items", BarricadingMaterialData.COUNT_FIELDS,
			BarricadingMaterialData.from_csv_line,
			[IDs.BAR_WOODEN_PLANK])

	data_bar_wooden_plank = data[0]

	return true

# Armors
func load_armors_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "armors items", ArmorData.COUNT_FIELDS,
			ArmorData.from_csv_line,
			[IDs.ARMOR_ARMY_BODYARMOR, IDs.ARMOR_CHAR_LIGHT_BODYARMOR,
			IDs.ARMOR_HELLS_SOULS_JACKET, IDs.ARMOR_FREE_ANGELS_JACKET,
			IDs.ARMOR_POLICE_JACKET, IDs.ARMOR_POLICE_RIOT,
			IDs.ARMOR_HUNTER_VEST])

	data_armor_army = data[0]
	data_armor_char = data[1]
	data_armor_hells_souls_jacket = data[2]
	data_armor_free_angels_jacket = data[3]
	data_armor_police_jacket = data[4]
	data_armor_police_riot = data[5]
	data_armor_hunter_vest = data[6]

	return true

# Trackers
func load_trackers_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "trackers items", TrackerData.COUNT_FIELDS,
			TrackerData.from_csv_line,
			[IDs.TRACKER_BLACKOPS, IDs.TRACKER_CELL_PHONE, IDs.TRACKER_ZTRACKER, IDs.TRACKER_POLICE_RADIO])

	data_tracker_blackops_gps = data[0]
	data_tracker_cell_phone = data[1]
	data_tracker_ztracker = data[2]
	data_tracker_police_radio = data[3]

	return true

# Spray paints
func load_spraypaints_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "spraypaint items", SprayPaintData.COUNT_FIELDS,
			SprayPaintData.from_csv_line,
			[IDs.SPRAY_PAINT1, IDs.SPRAY_PAINT2, IDs.SPRAY_PAINT3, IDs.SPRAY_PAINT4])

	data_spray_paint1 = data[0]
	data_spray_paint2 = data[1]
	data_spray_paint3 = data[2]
	data_spray_paint4 = data[3]

	return true

# Lights
func load_lights_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "lights items", LightData.COUNT_FIELDS,
			LightData.from_csv_line,
			[IDs.LIGHT_FLASHLIGHT, IDs.LIGHT_BIG_FLASHLIGHT])

	data_light_flashlight = data[0]
	data_light_big_flashlight = data[1]

	return true

# Scent sprays
func load_scentsprays_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "scentsprays items", ScentSprayData.COUNT_FIELDS,
			ScentSprayData.from_csv_line,
			[IDs.SCENT_SPRAY_STENCH_KILLER])

	data_scent_spray_stench_killer = data[0]

	return true

# Traps
func load_traps_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "traps items", TrapData.COUNT_FIELDS,
			TrapData.from_csv_line,
			[IDs.TRAP_EMPTY_CAN, IDs.TRAP_BEAR_TRAP, IDs.TRAP_SPIKES, IDs.TRAP_BARBED_WIRE])

	data_trap_empty_can = data[0]
	data_trap_bear_trap = data[1]
	data_trap_spikes = data[2]
	data_trap_barbed_wire = data[3]

	return true

# Entertainment
func load_entertainment_from_csv(ui: IRogueUI, path: String) -> bool:
	var data := _load_data_from_csv(ui, path, "entertainment items", EntData.COUNT_FIELDS,
			EntData.from_csv_line,
			[IDs.ENT_BOOK, IDs.ENT_MAGAZINE])

	data_ent_book = data[0]
	data_ent_magazine = data[1]

	return true
# endregion


# region CSV data structs

class MedecineData:
	const COUNT_FIELDS := 10

	var name: String
	var plural: String
	var healing: int
	var stamina_boost: int
	var sleep_boost: int
	var infection_cure: int
	var sanity_cure: int
	var stacking_limit: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> MedecineData:
		var d := MedecineData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.healing = line.get_field(3).parse_int()
		d.stamina_boost = line.get_field(4).parse_int()
		d.sleep_boost = line.get_field(5).parse_int()
		d.infection_cure = line.get_field(6).parse_int()
		d.sanity_cure = line.get_field(7).parse_int()
		d.stacking_limit = line.get_field(8).parse_int()
		d.flavor = line.get_field(9).parse_text()
		return d


class FoodData:
	const COUNT_FIELDS := 7

	var name: String
	var plural: String
	var nutrition: int
	var best_before: int
	var stacking_limit: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> FoodData:
		var d := FoodData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.nutrition = int(Rules.FOOD_BASE_POINTS * line.get_field(3).parse_float())
		d.best_before = line.get_field(4).parse_int()
		d.stacking_limit = line.get_field(5).parse_int()
		d.flavor = line.get_field(6).parse_text()
		return d


class MeleeWeaponData:
	const COUNT_FIELDS := 12  # alpha10

	var name: String
	var plural: String
	var atk: int
	var dmg: int
	var sta: int
	var disarm: int  # alpha10
	var tool_bash_dmg_bonus: int  # alpha10
	var tool_build_bonus: float  # alpha10
	var stacking_limit: int
	var is_fragile: bool
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> MeleeWeaponData:
		var d := MeleeWeaponData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.atk = line.get_field(3).parse_int()
		d.dmg = line.get_field(4).parse_int()
		d.sta = line.get_field(5).parse_int()
		d.disarm = line.get_field(6).parse_int()  # alpha10
		d.tool_bash_dmg_bonus = line.get_field(7).parse_int()  # alpha10
		d.tool_build_bonus = line.get_field(8).parse_float()  # alpha10
		d.stacking_limit = line.get_field(9).parse_int()
		d.is_fragile = line.get_field(10).parse_bool()
		d.flavor = line.get_field(11).parse_text()
		return d


class RangedWeaponData:
	const COUNT_FIELDS := 10  # alpha10

	var name: String
	var plural: String
	var atk: int
	var rapid1: int  # alpha10
	var rapid2: int  # alpha10
	var dmg: int
	# renamed from C# "RANGE" (shadows a GDScript built-in function).
	var range_value: int
	var max_ammo: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> RangedWeaponData:
		var d := RangedWeaponData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.atk = line.get_field(3).parse_int()
		d.rapid1 = line.get_field(4).parse_int()  # alpha10
		d.rapid2 = line.get_field(5).parse_int()  # alpha10
		d.dmg = line.get_field(6).parse_int()
		d.range_value = line.get_field(7).parse_int()
		d.max_ammo = line.get_field(8).parse_int()
		d.flavor = line.get_field(9).parse_text()
		return d


class ExplosiveData:
	const COUNT_FIELDS := 14

	var name: String
	var plural: String
	var fuse: int
	var max_throw: int
	# C# field is misspelled "STACKLINGLIMIT"; kept as stacking_limit.
	var stacking_limit: int
	var radius: int
	var dmg: Array[int]
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> ExplosiveData:
		var d := ExplosiveData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.fuse = line.get_field(3).parse_int()
		d.max_throw = line.get_field(4).parse_int()
		d.stacking_limit = line.get_field(5).parse_int()
		d.radius = line.get_field(6).parse_int()
		var _dmg: Array[int] = []
		for i in range(7, 13):
			_dmg.append(line.get_field(i).parse_int())
		d.dmg = _dmg
		d.flavor = line.get_field(13).parse_text()
		return d


class BarricadingMaterialData:
	const COUNT_FIELDS := 6

	var name: String
	var plural: String
	var value: int
	var stacking_limit: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> BarricadingMaterialData:
		var d := BarricadingMaterialData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.value = line.get_field(3).parse_int()
		d.stacking_limit = line.get_field(4).parse_int()
		d.flavor = line.get_field(5).parse_text()
		return d


class ArmorData:
	const COUNT_FIELDS := 8

	var name: String
	var plural: String
	var pro_hit: int
	var pro_shot: int
	var enc: int
	var weight: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> ArmorData:
		var d := ArmorData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.pro_hit = line.get_field(3).parse_int()
		d.pro_shot = line.get_field(4).parse_int()
		d.enc = line.get_field(5).parse_int()
		d.weight = line.get_field(6).parse_int()
		d.flavor = line.get_field(7).parse_text()
		return d


class TrackerData:
	const COUNT_FIELDS := 6

	var name: String
	var plural: String
	var batteries: int
	var has_clock: bool  # alpha10
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> TrackerData:
		var d := TrackerData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.batteries = line.get_field(3).parse_int()
		d.has_clock = line.get_field(4).parse_bool()  # alpha10
		d.flavor = line.get_field(5).parse_text()
		return d


class SprayPaintData:
	const COUNT_FIELDS := 5

	var name: String
	var plural: String
	var quantity: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> SprayPaintData:
		var d := SprayPaintData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.quantity = line.get_field(3).parse_int()
		d.flavor = line.get_field(4).parse_text()
		return d


class LightData:
	const COUNT_FIELDS := 6

	var name: String
	var plural: String
	var fov: int
	var batteries: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> LightData:
		var d := LightData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.fov = line.get_field(3).parse_int()
		d.batteries = line.get_field(4).parse_int()
		d.flavor = line.get_field(5).parse_text()
		return d


class ScentSprayData:
	const COUNT_FIELDS := 6

	var name: String
	var plural: String
	var quantity: int
	var strength: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> ScentSprayData:
		var d := ScentSprayData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.quantity = line.get_field(3).parse_int()
		d.strength = line.get_field(4).parse_int()
		d.flavor = line.get_field(5).parse_text()
		return d


class TrapData:
	const COUNT_FIELDS := 16

	var name: String
	var plural: String
	var stacking: int
	var use_activate: bool
	var chance: int
	var damage: int
	var drop_activate: bool
	var is_one_time: bool
	var break_chance: int
	var block_chance: int
	var break_chance_escape: int
	var is_noisy: bool
	var noise_name: String
	var is_flammable: bool
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> TrapData:
		var d := TrapData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.stacking = line.get_field(3).parse_int()
		d.drop_activate = line.get_field(4).parse_bool()
		d.use_activate = line.get_field(5).parse_bool()
		d.chance = line.get_field(6).parse_int()
		d.damage = line.get_field(7).parse_int()
		d.is_one_time = line.get_field(8).parse_bool()
		d.break_chance = line.get_field(9).parse_int()
		d.block_chance = line.get_field(10).parse_int()
		d.break_chance_escape = line.get_field(11).parse_int()
		d.is_noisy = line.get_field(12).parse_bool()
		d.noise_name = line.get_field(13).parse_text()
		d.is_flammable = line.get_field(14).parse_bool()
		d.flavor = line.get_field(15).parse_text()
		return d


class EntData:
	const COUNT_FIELDS := 7

	var name: String
	var plural: String
	var stacking: int
	var value: int
	var bore_chance: int
	var flavor: String

	static func from_csv_line(line: CSVParser.CSVLine) -> EntData:
		var d := EntData.new()
		d.name = line.get_field(1).parse_text()
		d.plural = line.get_field(2).parse_text()
		d.stacking = line.get_field(3).parse_int()
		d.value = line.get_field(4).parse_int()
		d.bore_chance = line.get_field(5).parse_int()
		d.flavor = line.get_field(6).parse_text()
		return d
# endregion
