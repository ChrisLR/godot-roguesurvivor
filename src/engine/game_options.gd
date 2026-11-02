class_name GameOptions
extends RefCounted
## Port of Engine/GameOptions.cs


# region IDs

enum IDs {
	UI_MUSIC,
	UI_MUSIC_VOLUME,
	UI_SHOW_PLAYER_TAG_ON_MINIMAP,
	UI_ANIM_DELAY,
	UI_SHOW_MINIMAP,
	UI_ADVISOR,
	UI_COMBAT_ASSISTANT,
	UI_SHOW_TARGETS,
	UI_SHOW_PLAYER_TARGETS,

	GAME_DISTRICT_SIZE,
	GAME_MAX_CIVILIANS,
	GAME_MAX_DOGS,
	GAME_MAX_UNDEADS,
	GAME_SIMULATE_DISTRICTS,
	GAME_SIMULATE_SLEEP,
	GAME_SIM_THREAD,
	GAME_SPAWN_SKELETON_CHANCE,
	GAME_SPAWN_ZOMBIE_CHANCE,
	GAME_SPAWN_ZOMBIE_MASTER_CHANCE,
	GAME_CITY_SIZE,
	GAME_NPC_CAN_STARVE_TO_DEATH,
	GAME_ZOMBIFICATION_CHANCE,
	GAME_REVEAL_STARTING_DISTRICT,
	GAME_ALLOW_UNDEADS_EVOLUTION,
	GAME_DAY_ZERO_UNDEADS_PERCENT,
	GAME_ZOMBIE_INVASION_DAILY_INCREASE,
	GAME_STARVED_ZOMBIFICATION_CHANCE,
	GAME_MAX_REINCARNATIONS,
	GAME_REINCARNATE_AS_RAT,
	GAME_REINCARNATE_TO_SEWERS,
	GAME_REINC_LIVING_RESTRICTED,
	GAME_PERMADEATH,
	GAME_DEATH_SCREENSHOT,
	GAME_AGGRESSIVE_HUNGRY_CIVILIANS,
	GAME_NATGUARD_FACTOR,
	GAME_SUPPLIESDROP_FACTOR,
	GAME_UNDEADS_UPGRADE_DAYS,
	GAME_RATS_UPGRADE,
	GAME_SKELETONS_UPGRADE,
	GAME_SHAMBLERS_UPGRADE,
	GAME_AUTOSAVE_PERIOD,  # alpha10.1
}


# region ZUP Days

enum ZupDays {
	_FIRST = 0,
	ONE = 0,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	OFF,
	_COUNT,
}


# region Simulating districts

enum SimRatio {
	_FIRST = 0,
	OFF = 0,
	ONE_QUARTER,     # 1/4
	ONE_THIRD,       # 1/3
	HALF,            # 1/2
	TWO_THIRDS,      # 2/3
	THREE_QUARTER,   # 3/4
	FULL,
	_COUNT,
}


# region Reincarnation mode

enum ReincMode {
	_FIRST = 0,
	RANDOM_FOLLOWER = 0,
	KILLER,
	ZOMBIFIED,
	RANDOM_LIVING,
	RANDOM_UNDEAD,
	RANDOM_ACTOR,
	_LAST = RANDOM_ACTOR,
	_COUNT,
}


# region Default values

const DEFAULT_DISTRICT_SIZE := 50
const DEFAULT_MAX_CIVILIANS := 25
const DEFAULT_MAX_DOGS := 0  # 5
const DEFAULT_MAX_UNDEADS := 100
const DEFAULT_SPAWN_SKELETON_CHANCE := 60
const DEFAULT_SPAWN_ZOMBIE_CHANCE := 30
const DEFAULT_SPAWN_ZOMBIE_MASTER_CHANCE := 10
const DEFAULT_CITY_SIZE := 5
const DEFAULT_SIM_DISTRICTS := SimRatio.FULL
const DEFAULT_ZOMBIFICATION_CHANCE := 100
const DEFAULT_DAY_ZERO_UNDEADS_PERCENT := 30
const DEFAULT_ZOMBIE_INVASION_DAILY_INCREASE := 5
const DEFAULT_STARVED_ZOMBIFICATION_CHANCE := 50
const DEFAULT_MAX_REINCARNATIONS := 1
const DEFAULT_NATGUARD_FACTOR := 100
const DEFAULT_SUPPLIESDROP_FACTOR := 100
const DEFAULT_ZOMBIFIEDS_UPGRADE_DAYS := ZupDays.THREE
const DEFAULT_AUTOSAVE_PERIOD := 24  # alpha10.1


# region Fields

var _district_size: int
var _max_civilians: int
var _max_dogs: int
var _max_undeads: int
var _play_music: bool
var _music_volume: int
var _anim_delay: bool
var _show_minimap: bool
var _enabled_advisor: bool
var _combat_assistant: bool
var _simulate_districts: int
var _cached_sim_ratio_float: float
var _simulate_when_sleeping: bool
var _sim_thread: bool
var _show_player_tags_on_minimap: bool
var _spawn_skeleton_chance: int
var _spawn_zombie_chance: int
var _spawn_zombie_master_chance: int
var _city_size: int
var _npc_can_starve_to_death: bool
var _zombification_chance: int
var _reveal_starting_district: bool
var _allow_undeads_evolution: bool
var _day_zero_undeads_percent: int
var _zombie_invasion_daily_increase: int
var _starved_zombification_chance: int
var _max_reincarnations: int
var _can_reincarnate_as_rat: bool
var _can_reincarnate_to_sewers: bool
var _is_living_reinc_restricted: bool
var _permadeath: bool
var _death_screenshot: bool
var _aggressive_hungry_civilians: bool
var _nat_guard_factor: int
var _supplies_drop_factor: int
var _show_targets: bool
var _show_player_targets: bool
var _zup_days: int
var _rats_upgrade: bool
var _skeletons_upgrade: bool
var _shamblers_upgrade: bool
var _auto_save_period_in_hours: int  # alpha10.1


# region Properties

var play_music: bool:
	get:
		return _play_music
	set(value):
		_play_music = value


var music_volume: int:
	get:
		return _music_volume
	set(value):
		if value < 0:
			value = 0
		if value > 100:
			value = 100
		_music_volume = value


var show_player_tags_on_minimap: bool:
	get:
		return _show_player_tags_on_minimap
	set(value):
		_show_player_tags_on_minimap = value


var is_anim_delay_on: bool:
	get:
		return _anim_delay
	set(value):
		_anim_delay = value


var is_minimap_on: bool:
	get:
		return _show_minimap
	set(value):
		_show_minimap = value


var is_advisor_enabled: bool:
	get:
		return _enabled_advisor
	set(value):
		_enabled_advisor = value


var is_combat_assistant_on: bool:
	get:
		return _combat_assistant
	set(value):
		_combat_assistant = value


var city_size: int:
	get:
		return _city_size
	set(value):
		if value < 3:
			value = 3
		if value > 7:
			value = 7
		_city_size = value


var max_civilians: int:
	get:
		return _max_civilians
	set(value):
		if value < 10:
			value = 10
		if value > 75:
			value = 75
		_max_civilians = value


var max_dogs: int:
	get:
		return _max_dogs
	set(value):
		if value < 0:
			value = 0
		if value > 75:
			value = 75
		_max_dogs = value


var max_undeads: int:
	get:
		return _max_undeads
	set(value):
		if value < 10:
			value = 10
		if value > 200:
			value = 200
		_max_undeads = value


var spawn_skeleton_chance: int:
	get:
		return _spawn_skeleton_chance
	set(value):
		if value < 0:
			value = 0
		if value > 100:
			value = 100
		_spawn_skeleton_chance = value


var spawn_zombie_chance: int:
	get:
		return _spawn_zombie_chance
	set(value):
		if value < 0:
			value = 0
		if value > 100:
			value = 100
		_spawn_zombie_chance = value


var spawn_zombie_master_chance: int:
	get:
		return _spawn_zombie_master_chance
	set(value):
		if value < 0:
			value = 0
		if value > 100:
			value = 100
		_spawn_zombie_master_chance = value


var simulate_districts: int:
	get:
		return _simulate_districts
	set(value):
		_simulate_districts = value
		_cached_sim_ratio_float = sim_ratio_to_float(_simulate_districts)


var sim_ratio_float: float:
	get:
		return _cached_sim_ratio_float


var simulate_when_sleeping: bool:
	get:
		return _simulate_when_sleeping
	set(value):
		_simulate_when_sleeping = value


var is_sim_on: bool:
	get:
		return _simulate_districts != SimRatio.OFF


var sim_thread: bool:
	get:
		return _sim_thread
	set(value):
		_sim_thread = value


var district_size: int:
	get:
		return _district_size
	set(value):
		if value < 30:
			value = 30
		if value > RogueGame.MAP_MAX_HEIGHT || value > RogueGame.MAP_MAX_WIDTH:
			value = min(RogueGame.MAP_MAX_WIDTH, RogueGame.MAP_MAX_HEIGHT)
		_district_size = value


var npc_can_starve_to_death: bool:
	get:
		return _npc_can_starve_to_death
	set(value):
		_npc_can_starve_to_death = value


var zombification_chance: int:
	get:
		return _zombification_chance
	set(value):
		if value < 10:
			value = 10
		if value > 100:
			value = 100
		_zombification_chance = value


var reveal_starting_district: bool:
	get:
		return _reveal_starting_district
	set(value):
		_reveal_starting_district = value


var allow_undeads_evolution: bool:
	get:
		return _allow_undeads_evolution
	set(value):
		_allow_undeads_evolution = value


var day_zero_undeads_percent: int:
	get:
		return _day_zero_undeads_percent
	set(value):
		if value < 10:
			value = 10
		if value > 100:
			value = 100
		_day_zero_undeads_percent = value


var zombie_invasion_daily_increase: int:
	get:
		return _zombie_invasion_daily_increase
	set(value):
		if value < 1:
			value = 1
		if value > 20:
			value = 20
		_zombie_invasion_daily_increase = value


var starved_zombification_chance: int:
	get:
		return _starved_zombification_chance
	set(value):
		if value < 0:
			value = 0
		if value > 100:
			value = 100
		_starved_zombification_chance = value


var max_reincarnations: int:
	get:
		return _max_reincarnations
	set(value):
		if value < 0:
			value = 0
		if value > 7:
			value = 7
		_max_reincarnations = value


var can_reincarnate_as_rat: bool:
	get:
		return _can_reincarnate_as_rat
	set(value):
		_can_reincarnate_as_rat = value


var can_reincarnate_to_sewers: bool:
	get:
		return _can_reincarnate_to_sewers
	set(value):
		_can_reincarnate_to_sewers = value


var is_living_reinc_restricted: bool:
	get:
		return _is_living_reinc_restricted
	set(value):
		_is_living_reinc_restricted = value


var is_permadeath_on: bool:
	get:
		return _permadeath
	set(value):
		_permadeath = value


var is_death_screenshot_on: bool:
	get:
		return _death_screenshot
	set(value):
		_death_screenshot = value


var is_aggressive_hungry_civilians_on: bool:
	get:
		return _aggressive_hungry_civilians
	set(value):
		_aggressive_hungry_civilians = value


var nat_guard_factor: int:
	get:
		return _nat_guard_factor
	set(value):
		if value < 0:
			value = 0
		if value > 200:
			value = 200
		_nat_guard_factor = value


var supplies_drop_factor: int:
	get:
		return _supplies_drop_factor
	set(value):
		if value < 0:
			value = 0
		if value > 200:
			value = 200
		_supplies_drop_factor = value


var show_targets: bool:
	get:
		return _show_targets
	set(value):
		_show_targets = value


var show_player_targets: bool:
	get:
		return _show_player_targets
	set(value):
		_show_player_targets = value


var zombifieds_upgrade_days: int:
	get:
		return _zup_days
	set(value):
		_zup_days = value


var rats_upgrade: bool:
	get:
		return _rats_upgrade
	set(value):
		_rats_upgrade = value


var skeletons_upgrade: bool:
	get:
		return _skeletons_upgrade
	set(value):
		_skeletons_upgrade = value


var shamblers_upgrade: bool:
	get:
		return _shamblers_upgrade
	set(value):
		_shamblers_upgrade = value


# alpha10.1
var auto_save_period_in_hours: int:
	get:
		return _auto_save_period_in_hours
	set(value):
		if value < 0:
			value = 0
		if value > 7 * 24:
			value = 7 * 24
		_auto_save_period_in_hours = value


# region Dev only options (hidden)

var dev_show_actors_stats: bool = false


# region Init

func _init() -> void:
	# Every constructor starts from defaults, like the C# field initializers:
	# load_options() applies saved data on top of a default-constructed
	# object, and a partial/empty save must not leave backing fields at 0.
	reset_to_default_values()


func reset_to_default_values() -> void:
	_district_size = DEFAULT_DISTRICT_SIZE
	_max_civilians = DEFAULT_MAX_CIVILIANS
	_max_undeads = DEFAULT_MAX_UNDEADS
	_max_dogs = DEFAULT_MAX_DOGS
	_play_music = true
	_music_volume = 100
	_anim_delay = true
	_show_minimap = true
	_show_player_tags_on_minimap = true
	_enabled_advisor = true
	_combat_assistant = false
	simulate_districts = DEFAULT_SIM_DISTRICTS
	_simulate_when_sleeping = false
	_sim_thread = true
	_spawn_skeleton_chance = DEFAULT_SPAWN_SKELETON_CHANCE
	_spawn_zombie_chance = DEFAULT_SPAWN_ZOMBIE_CHANCE
	_spawn_zombie_master_chance = DEFAULT_SPAWN_ZOMBIE_MASTER_CHANCE
	_city_size = DEFAULT_CITY_SIZE
	_npc_can_starve_to_death = true
	_zombification_chance = DEFAULT_ZOMBIFICATION_CHANCE
	_reveal_starting_district = true
	_allow_undeads_evolution = true
	_day_zero_undeads_percent = DEFAULT_DAY_ZERO_UNDEADS_PERCENT
	_zombie_invasion_daily_increase = DEFAULT_ZOMBIE_INVASION_DAILY_INCREASE
	_starved_zombification_chance = DEFAULT_STARVED_ZOMBIFICATION_CHANCE
	_max_reincarnations = DEFAULT_MAX_REINCARNATIONS
	_can_reincarnate_as_rat = false
	_can_reincarnate_to_sewers = false
	_is_living_reinc_restricted = false
	_permadeath = false
	_death_screenshot = true
	_aggressive_hungry_civilians = true
	_nat_guard_factor = DEFAULT_NATGUARD_FACTOR
	_supplies_drop_factor = DEFAULT_SUPPLIESDROP_FACTOR
	_show_targets = true
	_show_player_targets = true
	_zup_days = DEFAULT_ZOMBIFIEDS_UPGRADE_DAYS
	_rats_upgrade = false
	_skeletons_upgrade = false
	_shamblers_upgrade = false
	_auto_save_period_in_hours = DEFAULT_AUTOSAVE_PERIOD  # alpha10.1


# region Helpers

static func name_of(option: int) -> String:
	match option:
		IDs.GAME_AGGRESSIVE_HUNGRY_CIVILIANS: return "(Living) Aggressive Hungry Civs"
		IDs.GAME_ALLOW_UNDEADS_EVOLUTION: return "(Undead) Allow Undeads Evolution"
		IDs.GAME_CITY_SIZE: return "   (Map) City Size"
		IDs.GAME_DAY_ZERO_UNDEADS_PERCENT: return "(Undead) Day 0 Undeads"
		IDs.GAME_DEATH_SCREENSHOT: return " (Death) Death Screenshot"
		IDs.GAME_DISTRICT_SIZE: return "   (Map) District Map Size"
		IDs.GAME_MAX_CIVILIANS: return "(Living) Max Civilians"
		IDs.GAME_MAX_DOGS: return "(Living) Max Dogs"
		IDs.GAME_MAX_REINCARNATIONS: return " (Reinc) Max Reincarnations"
		IDs.GAME_MAX_UNDEADS: return "(Undead) Max Undeads"
		IDs.GAME_NATGUARD_FACTOR: return " (Event) National Guard"
		IDs.GAME_NPC_CAN_STARVE_TO_DEATH: return "(Living) NPCs can starve to death"
		IDs.GAME_PERMADEATH: return " (Death) Permadeath"
		IDs.GAME_RATS_UPGRADE: return "(Undead) Rats Skill Upgrade"
		IDs.GAME_REVEAL_STARTING_DISTRICT: return "   (Map) Reveal Starting District"
		IDs.GAME_REINC_LIVING_RESTRICTED: return " (Reinc) Civilians only Reinc."
		IDs.GAME_REINCARNATE_AS_RAT: return " (Reinc) Can Reincarnate as Rat"
		IDs.GAME_REINCARNATE_TO_SEWERS: return " (Reinc) Can Reincarnate to Sewers"
		IDs.GAME_SHAMBLERS_UPGRADE: return "(Undead) Shamblers Skill Upgrade"
		IDs.GAME_SKELETONS_UPGRADE: return "(Undead) Skeletons Skill Upgrade"
		IDs.GAME_SIMULATE_DISTRICTS: return "   (Sim) Districts Simulation"
		IDs.GAME_SIMULATE_SLEEP: return "   (Sim) Simulate when Sleeping"
		IDs.GAME_SIM_THREAD: return "   (Sim) Synchronous Simulation"
		IDs.GAME_SPAWN_SKELETON_CHANCE: return "(Undead) Spawn Skeleton chance"
		IDs.GAME_SPAWN_ZOMBIE_CHANCE: return "(Undead) Spawn Zombie chance"
		IDs.GAME_SPAWN_ZOMBIE_MASTER_CHANCE: return "(Undead) Spawn Zombie Master chance"
		IDs.GAME_STARVED_ZOMBIFICATION_CHANCE: return "(Living) Starved Zombification"
		IDs.GAME_SUPPLIESDROP_FACTOR: return " (Event) Supplies Drop"
		IDs.GAME_UNDEADS_UPGRADE_DAYS: return "(Undead) Undeads Skills Upgrade Days"
		IDs.GAME_ZOMBIFICATION_CHANCE: return "(Living) Zombification Chance"
		IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE: return "(Undead) Invasion Daily Increase"
		IDs.UI_ANIM_DELAY: return "   (Gfx) Animations Delay"
		IDs.UI_MUSIC: return "   (Sfx) Music"
		IDs.UI_MUSIC_VOLUME: return "   (Sfx) Music Volume"
		IDs.UI_SHOW_MINIMAP: return "   (Gfx) Show Minimap"
		IDs.UI_SHOW_PLAYER_TAG_ON_MINIMAP: return "   (Gfx) Show Tags on Minimap"
		IDs.UI_ADVISOR: return "  (Help) Enable Advisor"
		IDs.UI_COMBAT_ASSISTANT: return "  (Help) Combat Assistant"
		IDs.UI_SHOW_TARGETS: return "  (Help) Show Other Actors Targets"
		IDs.UI_SHOW_PLAYER_TARGETS: return "  (Help) Show Player Targets"
		IDs.GAME_AUTOSAVE_PERIOD: return "  (Save) AutoSave Period"  # alpha10.1
		_:
			push_error("unhandled option")
			return ""


## alpha10
static func describe(option: int) -> String:
	match option:
		IDs.GAME_AGGRESSIVE_HUNGRY_CIVILIANS:
			return "Allows hungry civilians to attack other people for food."
		IDs.GAME_ALLOW_UNDEADS_EVOLUTION:
			return "ALWAYS OFF IN VTG-VINTAGE MODE.\nAllows undeads to evolve into stronger forms."
		IDs.GAME_CITY_SIZE:
			return "Size of the city grid. The city is a square grid of districts.\nLarger cities are more fun but rapidly increases game saves size and loading time."
		IDs.GAME_DAY_ZERO_UNDEADS_PERCENT:
			return "Percentage of max undeads spawned when the game starts."
		IDs.GAME_DEATH_SCREENSHOT:
			return "Takes a screenshot when you die and save it to the game Config\\Screenshot folder."
		IDs.GAME_DISTRICT_SIZE:
			return "How large are the maps in tiles. Larger maps are more fun but increase game saves size and loading time."
		IDs.GAME_MAX_CIVILIANS:
			return "Maximum number of civilians on a map. More civilians makes the game easier for livings, but slows the game down."
		IDs.GAME_MAX_DOGS:
			return "OPTION IS UNUSED YOU SHOULDNT BE READING THIS :)"
		IDs.GAME_MAX_REINCARNATIONS:
			return "Number of times you can reincarnate in a game after your character dies.\nSet it to 0 to disable reincarnation altogether."
		IDs.GAME_MAX_UNDEADS:
			return "Maximum number of undeads on a map. More undeads makes the game more challenging for livings, but slows the game down."
		IDs.GAME_NATGUARD_FACTOR:
			return "Affects how likely the National Guard event happens.\n100 is default, 0 to disable."
		IDs.GAME_NPC_CAN_STARVE_TO_DEATH:
			return "When NPCs are starving they can die. When disabled ai characters will never die from hunger."
		IDs.GAME_PERMADEATH:
			return "Deletes your saved game when you die so you can't reload your way out. Extra challenge and tension."
		IDs.GAME_RATS_UPGRADE:
			return "ALWAYS OFF IN VTG-VINTAGE MODE.\nCan Rats type of undeads upgrade their skills like other undeads.\nNot recommended unless you want super annoying rats."
		IDs.GAME_REVEAL_STARTING_DISTRICT:
			return "You start the game with knowing parts of the map you start in."
		IDs.GAME_REINC_LIVING_RESTRICTED:
			return "Limit choices of reincarnations as livings to civilians only. If disabled allow you to reincarnte into all kinds of livings."
		IDs.GAME_REINCARNATE_AS_RAT:
			return "Enables the possibility to reincarnate into a zombie rat."
		IDs.GAME_REINCARNATE_TO_SEWERS:
			return "Enables the possibility to reincarnate into the sewers."
		IDs.GAME_SHAMBLERS_UPGRADE:
			return "ALWAYS OFF IN VTG-VINTAGE MODE.\nCan Shamblers type of undeads upgrade their skills like other undeads."
		IDs.GAME_SKELETONS_UPGRADE:
			return "ALWAYS OFF IN VTG-VINTAGE MODE.\nCan Skeletons type of undeads upgrade their skills like other undeads."
		IDs.GAME_SIMULATE_DISTRICTS:
			return "The game simulates what is happening in districts around you. You should keep this option maxed for better gameplay.\nWhen the simulation happens depends on other sim options."
		IDs.GAME_SIMULATE_SLEEP:
			return "Performs simulation when you are sleeping. Recommended if synchronous sim is off."
		IDs.GAME_SIM_THREAD:
			return "Performs simulation in a separate thread while you are playing. Recommended unless the game is unstable."
		IDs.GAME_SPAWN_SKELETON_CHANCE:
			return "YOU SHOULDNT BE READING THIS :)"
		IDs.GAME_SPAWN_ZOMBIE_CHANCE:
			return "YOU SHOULDNT BE READING THIS :)"
		IDs.GAME_SPAWN_ZOMBIE_MASTER_CHANCE:
			return "YOU SHOULDNT BE READING THIS :)"
		IDs.GAME_STARVED_ZOMBIFICATION_CHANCE:
			return "ONLY IN STD-STANDARD MODE.\nIf NPCs can starve to death, chances of turning into a zombie."
		IDs.GAME_SUPPLIESDROP_FACTOR:
			return "Affects how likely the supplies drop event happens.\n100 is default, 0 to disable."
		IDs.GAME_UNDEADS_UPGRADE_DAYS:
			return "How often can undeads upgrade their skills. They usually upgrade at a slower pace than livings."
		IDs.GAME_ZOMBIFICATION_CHANCE:
			return "ONLY IN STD-STANDARD MODE.\nSome undeads have the ability to turn their living victims into zombies after killing them.\nThis option control the chances of zombification. Changing this value has a large impact on game difficulty.\nException: the player is always checked for zombification when killed in all game modes."
		IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE:
			return "The zombies invasion increases in size each day, to fill up to Max Undeads on a map."
		IDs.UI_ANIM_DELAY:
			return "Enable or disable delays when showing actions or events on the map.\nYou should keep it on when learning the game and then disable it for a faster play."
		IDs.UI_MUSIC:
			return "Enable or disable ingame musics. Musics are not essential for gameplay. If you can't hear music, try the configuration program."
		IDs.UI_MUSIC_VOLUME:
			return "Music volume."
		IDs.UI_SHOW_MINIMAP:
			return "Display or hide the minimap.\nThe minimap could potentially crash the game on some very old graphics cards."
		IDs.UI_SHOW_PLAYER_TAG_ON_MINIMAP:
			return "Highlight tags painted by the player as yellow dots in the minimap."
		IDs.UI_ADVISOR:
			return "Enable or disable the ingame hints system. The advisor helps you learn the game for the living side.\nIt will only tell you hints it didn't already tell you.\nAll hints are also available from the main menu."
		IDs.UI_COMBAT_ASSISTANT:
			return "When enabled draws a colored circle icon on your enemies.\nGreen = you can safely act twice before your enemy\nYellow = your enemy will act after you\nRed = your enemy will act twice after you"
		IDs.UI_SHOW_TARGETS:
			return "When mouse over an actor, will draw icons on actors that are targeting, are targeted or are in group with this actor."
		IDs.UI_SHOW_PLAYER_TARGETS:
			return "Will draw icons on actors that are targeting you."
		IDs.GAME_AUTOSAVE_PERIOD:  # alpha10.1
			return "Will autosave at regular intervals when you start sleeping, start a long wait or change map.\nManually saving the game will reschedule the next autosave."
		_:
			push_error("unhandled option")
			return ""


static func reinc_mode_name(mode: int) -> String:
	match mode:
		ReincMode.RANDOM_ACTOR: return "Random Actor"
		ReincMode.RANDOM_LIVING: return "Random Living"
		ReincMode.RANDOM_UNDEAD: return "Random Undead"
		ReincMode.RANDOM_FOLLOWER: return "Random Follower"
		ReincMode.KILLER: return "Your Killer"
		ReincMode.ZOMBIFIED: return "Your Zombie Self"
		_:
			push_error("unhandled ReincMode")
			return ""


static func sim_ratio_name(ratio: int) -> String:
	match ratio:
		SimRatio.OFF: return "OFF"
		SimRatio.ONE_QUARTER: return "25%"
		SimRatio.ONE_THIRD: return "33%"
		SimRatio.HALF: return "50%"
		SimRatio.TWO_THIRDS: return "66%"
		SimRatio.THREE_QUARTER: return "75%"
		SimRatio.FULL: return "FULL"
		_:
			push_error("unhandled simRatio")
			return ""


static func sim_ratio_to_float(ratio: int) -> float:
	match ratio:
		SimRatio.OFF: return 0.0
		SimRatio.ONE_QUARTER: return 1.0 / 4.0
		SimRatio.ONE_THIRD: return 1.0 / 3.0
		SimRatio.HALF: return 1.0 / 2.0
		SimRatio.TWO_THIRDS: return 2.0 / 3.0
		SimRatio.THREE_QUARTER: return 3.0 / 4.0
		SimRatio.FULL: return 1.0
		_:
			push_error("unhandled simRatio")
			return 0.0


static func zup_days_name(d: int) -> String:
	match d:
		ZupDays.OFF: return "OFF"
		ZupDays.ONE: return "1 d"
		ZupDays.TWO: return "2 d"
		ZupDays.THREE: return "3 d"
		ZupDays.FOUR: return "4 d"
		ZupDays.FIVE: return "5 d"
		ZupDays.SIX: return "6 d"
		ZupDays.SEVEN: return "7 d"
		_:
			push_error("unhandled zupDays")
			return ""


static func is_zup_day(d: int, day: int) -> bool:
	match d:
		ZupDays.ONE: return true
		ZupDays.TWO: return day % 2 == 0
		ZupDays.THREE: return day % 3 == 0
		ZupDays.FOUR: return day % 4 == 0
		ZupDays.FIVE: return day % 5 == 0
		ZupDays.SIX: return day % 6 == 0
		ZupDays.SEVEN: return day % 7 == 0
		_: return false


## mode is a GameMode value (enum declared in Engine/Session.cs, not yet
## ported) — it is unused by the original body and kept for signature parity.
func describe_value(_mode: int, option: int) -> String:
	match option:
		IDs.GAME_AGGRESSIVE_HUNGRY_CIVILIANS:
			return "ON    (default ON)" if is_aggressive_hungry_civilians_on else "OFF   (default ON)"
		IDs.GAME_ALLOW_UNDEADS_EVOLUTION:
			return "YES   (default YES)" if allow_undeads_evolution else "NO    (default YES)"
		IDs.GAME_CITY_SIZE:
			return "%02d*   (default %02d)" % [city_size, DEFAULT_CITY_SIZE]
		IDs.GAME_DAY_ZERO_UNDEADS_PERCENT:
			return "%03d%%  (default %03d%%)" % [day_zero_undeads_percent, DEFAULT_DAY_ZERO_UNDEADS_PERCENT]
		IDs.GAME_DEATH_SCREENSHOT:
			return "YES   (default YES)" if is_death_screenshot_on else "NO    (default YES)"
		IDs.GAME_DISTRICT_SIZE:
			return "%02d*   (default %02d)" % [district_size, DEFAULT_DISTRICT_SIZE]
		IDs.GAME_MAX_CIVILIANS:
			return "%03d*  (default %03d)" % [max_civilians, DEFAULT_MAX_CIVILIANS]
		IDs.GAME_MAX_DOGS:
			return "%03d*  (default %03d)" % [max_dogs, DEFAULT_MAX_DOGS]
		IDs.GAME_MAX_REINCARNATIONS:
			return "%03d   (default %03d)" % [max_reincarnations, DEFAULT_MAX_REINCARNATIONS]
		IDs.GAME_MAX_UNDEADS:
			return "%03d*  (default %03d)" % [max_undeads, DEFAULT_MAX_UNDEADS]
		IDs.GAME_NATGUARD_FACTOR:
			return "%03d%%  (default %03d%%)" % [nat_guard_factor, DEFAULT_NATGUARD_FACTOR]
		IDs.GAME_NPC_CAN_STARVE_TO_DEATH:
			return "YES   (default YES)" if npc_can_starve_to_death else "NO    (default YES)"
		IDs.GAME_PERMADEATH:
			return "YES   (default NO)" if is_permadeath_on else "NO    (default NO)"
		IDs.GAME_RATS_UPGRADE:
			return "YES   (default NO)" if rats_upgrade else "NO    (default NO)"
		IDs.GAME_REINC_LIVING_RESTRICTED:
			return "YES   (default NO)" if is_living_reinc_restricted else "NO    (default NO)"
		IDs.GAME_REINCARNATE_AS_RAT:
			return "YES   (default NO)" if can_reincarnate_as_rat else "NO    (default NO)"
		IDs.GAME_REINCARNATE_TO_SEWERS:
			return "YES   (default NO)" if can_reincarnate_to_sewers else "NO    (default NO)"
		IDs.GAME_REVEAL_STARTING_DISTRICT:
			return "YES   (default YES)" if reveal_starting_district else "NO    (default YES)"
		IDs.GAME_SHAMBLERS_UPGRADE:
			return "YES   (default NO)" if shamblers_upgrade else "NO    (default NO)"
		IDs.GAME_SKELETONS_UPGRADE:
			return "YES   (default NO)" if skeletons_upgrade else "NO    (default NO)"
		IDs.GAME_SIM_THREAD:
			return "YES*  (default YES)" if sim_thread else "NO*   (default YES)"
		IDs.GAME_SIMULATE_DISTRICTS:
			return "%-4s* (default %s)" % [sim_ratio_name(simulate_districts), sim_ratio_name(DEFAULT_SIM_DISTRICTS)]
		IDs.GAME_SIMULATE_SLEEP:
			return "YES*  (default NO)" if simulate_when_sleeping else "NO*   (default NO)"
		IDs.GAME_STARVED_ZOMBIFICATION_CHANCE:
			return "%03d%%  (default %03d%%)" % [starved_zombification_chance, DEFAULT_STARVED_ZOMBIFICATION_CHANCE]
		IDs.GAME_SUPPLIESDROP_FACTOR:
			return "%03d%%  (default %03d%%)" % [supplies_drop_factor, DEFAULT_SUPPLIESDROP_FACTOR]
		IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE:
			return "%03d%%  (default %03d%%)" % [zombie_invasion_daily_increase, DEFAULT_ZOMBIE_INVASION_DAILY_INCREASE]
		IDs.GAME_ZOMBIFICATION_CHANCE:
			return "%03d%%  (default %03d%%)" % [zombification_chance, DEFAULT_ZOMBIFICATION_CHANCE]
		IDs.GAME_UNDEADS_UPGRADE_DAYS:
			return "%-3s   (default %s)" % [zup_days_name(zombifieds_upgrade_days), zup_days_name(DEFAULT_ZOMBIFIEDS_UPGRADE_DAYS)]
		IDs.UI_ADVISOR:
			return "YES" if is_advisor_enabled else "NO "
		IDs.UI_ANIM_DELAY:
			return "ON " if is_anim_delay_on else "OFF"
		IDs.UI_COMBAT_ASSISTANT:
			return "ON    (default OFF)" if is_combat_assistant_on else "OFF   (default OFF)"
		IDs.UI_MUSIC:
			return "ON " if play_music else "OFF"
		IDs.UI_MUSIC_VOLUME:
			return "%d%%" % music_volume
		IDs.UI_SHOW_MINIMAP:
			return "ON " if is_minimap_on else "OFF"
		IDs.UI_SHOW_PLAYER_TAG_ON_MINIMAP:
			return "YES" if show_player_tags_on_minimap else "NO "
		IDs.UI_SHOW_PLAYER_TARGETS:
			return "ON    (default ON)" if show_player_targets else "OFF   (default ON)"
		IDs.UI_SHOW_TARGETS:
			return "ON    (default ON)" if show_targets else "OFF   (default ON)"
		IDs.GAME_AUTOSAVE_PERIOD:  # alpha10.1
			return "%-4s  (default %dh)" % [
				"OFF" if _auto_save_period_in_hours == 0 else "%dh" % _auto_save_period_in_hours,
				DEFAULT_AUTOSAVE_PERIOD]
		_: return "???"


# region Saving & Loading

## Mirrors the C# BinaryFormatter behavior (serialize all fields), using
## Godot-native FileAccess + store_var. Old C# saves are incompatible.
static func save(options: GameOptions, filepath: String) -> void:
	print("saving options...")

	var file := FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		push_error("cannot open options file '%s' for writing (%s)." % [filepath, error_string(FileAccess.get_open_error())])
		return

	file.store_var(options._make_save_data())
	file = null

	print("saving options... done!")


## Try to load, null if failed.
static func load_options(filepath: String) -> GameOptions:
	print("loading options...")

	var options: GameOptions = null

	var file := FileAccess.open(filepath, FileAccess.READ)
	if file != null:
		var data = file.get_var()
		file = null
		if data is Dictionary:
			options = GameOptions.new()
			options._apply_save_data(data)

	if options == null:
		print("failed to load options (no custom options?).")
		print("returning default values.")
		options = GameOptions.new()
		options.reset_to_default_values()

	print("loading options... done!")
	return options


func _make_save_data() -> Dictionary:
	# Only the backing fields are saved (raw values, no clamping side
	# effects); computed/read-only properties are skipped.
	var data := {}
	for prop in get_property_list():
		# NB: script member variables carry PROPERTY_USAGE_SCRIPT_VARIABLE but
		# not PROPERTY_USAGE_STORAGE; requiring STORAGE matched nothing and
		# every save was an empty Dictionary.
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			if prop.name.begins_with("_") or prop.name.begins_with("dev_"):
				data[prop.name] = get(prop.name)
	return data


func _apply_save_data(data: Dictionary) -> void:
	var known := {}
	for prop in get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			known[prop.name] = true
	for key in data:
		if known.get(key, false) and (key.begins_with("_") or key.begins_with("dev_")):
			set(key, data[key])
		else:
			push_warning("unknown option field '%s' in save, skipped." % key)
