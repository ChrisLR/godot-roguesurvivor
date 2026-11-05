class_name RogueGame
extends RefCounted
## Port of Engine/RogueGame.cs (in progress, chunked).
## The simulation core. All drawing lives in the UI (src/ui) behind IRogueUI.

const TILE_SIZE := 32
const CANVAS_WIDTH := 1024
const CANVAS_HEIGHT := 768
const MINITILE_SIZE := 2

# Constants region (RogueGame.cs lines 26-141)
const MAP_MAX_HEIGHT := 100
const MAP_MAX_WIDTH := 100

const ACTOR_SIZE := 32
const ACTOR_OFFSET := (TILE_SIZE - ACTOR_SIZE) / 2
const TILE_VIEW_WIDTH := 21
const TILE_VIEW_HEIGHT := 21
const HALF_VIEW_WIDTH := 10
const HALF_VIEW_HEIGHT := 10

const DAMAGE_DX := 10
const DAMAGE_DY := 10

# UI elements
const RIGHTPANEL_X := TILE_SIZE * TILE_VIEW_WIDTH + 4
const RIGHTPANEL_Y := 0
const RIGHTPANEL_TEXT_X := RIGHTPANEL_X + 4
const RIGHTPANEL_TEXT_Y := RIGHTPANEL_Y + 4

const INVENTORYPANEL_X := RIGHTPANEL_TEXT_X
const INVENTORYPANEL_Y := RIGHTPANEL_TEXT_Y + 170  # alpha10
const GROUNDINVENTORYPANEL_Y := INVENTORYPANEL_Y + 64
const CORPSESPANEL_Y := GROUNDINVENTORYPANEL_Y + 64
const INVENTORY_SLOTS_PER_LINE := 10

const SKILLTABLE_Y := CORPSESPANEL_Y + 64
const SKILLTABLE_LINES := 8  # alpha10

const LOCATIONPANEL_X := RIGHTPANEL_X
const LOCATIONPANEL_Y := TILE_VIEW_HEIGHT * TILE_SIZE + 4  # MESSAGES_Y
const LOCATIONPANEL_TEXT_X := LOCATIONPANEL_X + 4
const LOCATIONPANEL_TEXT_Y := LOCATIONPANEL_Y + 4

const MESSAGES_X := 4
const MESSAGES_Y := TILE_VIEW_HEIGHT * TILE_SIZE + 4
const MESSAGES_SPACING := 12
const MESSAGES_FADEOUT := 25
const MAX_MESSAGES := 7
const MESSAGES_HISTORY := 59

const MINIMAP_X := RIGHTPANEL_X + (CANVAS_WIDTH - RIGHTPANEL_X - MAP_MAX_WIDTH * MINITILE_SIZE) / 2
const MINIMAP_Y := MESSAGES_Y - MINITILE_SIZE * MAP_MAX_HEIGHT - 1
const MINI_TRACKER_OFFSET := 1

const DELAY_SHORT := 250
const DELAY_NORMAL := 500
const DELAY_LONG := 1000

const POPUP_FILLCOLOR := Color(0.4, 0.584, 0.929, 0.753)  # FromArgb(192, CornflowerBlue)

const LINE_SPACING := 12
const BOLD_LINE_SPACING := 14
const CREDIT_CHAR_SPACING := 8
const CREDIT_LINE_SPACING := LINE_SPACING

const NIGHT_COLOR := Color.CYAN
const DAY_COLOR := Color.GOLD

const TEXTFILE_CHARS_PER_LINE := 120
const TEXTFILE_LINES_PER_PAGE := 50

# Notable Zone names
const NAME_SUBWAY_STATION := "Subway Station"
const NAME_SEWERS_MAINTENANCE := "Sewers Maintenance"
const NAME_SUBWAY_RAILS := "rails"
const NAME_POLICE_STATION_JAILS_CELL := "jail"

# Events
const SPAWN_DISTANCE_TO_PLAYER := 10

const SEWERS_INVASION_CHANCE := 1
const SEWERS_UNDEADS_FACTOR := 0.50  # 1.0 for as much as surface undead spawning.
const SUBWAY_INVASION_CHANCE := 1
const SUBWAY_UNDEADS_FACTOR := 0.25  # 1.0 for as much as surface undead spawning.
const REFUGEES_WAVE_SIZE := 0.20
const REFUGEES_WAVE_ITEMS := 3
const REFUGEE_SURFACE_SPAWN_CHANCE := 80
const UNIQUE_REFUGEE_CHECK_CHANCE := 10
const NATGUARD_DAY := 3
const NATGUARD_END_DAY := 10
const NATGUARD_ZTRACKER_DAY := NATGUARD_DAY + 3
const NATGUARD_SQUAD_SIZE := 5
const NATGUARD_INTERVENTION_FACTOR := 5
const NATGUARD_INTERVENTION_CHANCE := 1
const ARMY_SUPPLIES_DAY := 4
const ARMY_SUPPLIES_FACTOR := 0.20 * 100.0  # 0.20f * Rules.FOOD_BASE_POINTS
const ARMY_SUPPLIES_CHANCE := 2
const ARMY_SUPPLIES_SCATTER := 1
const BIKERS_RAID_DAY := 2
const BIKERS_END_DAY := 14
const BIKERS_RAID_SIZE := 6
const BIKERS_RAID_CHANCE_PER_TURN := 1
const BIKERS_RAID_DAYS_GAP := 2
const GANGSTAS_RAID_DAY := 7
const GANGSTAS_END_DAY := 21
const GANGSTAS_RAID_SIZE := 6
const GANGSTAS_RAID_CHANCE_PER_TURN := 1
const GANGSTAS_RAID_DAYS_GAP := 3
const BLACKOPS_RAID_DAY := 14
const BLACKOPS_RAID_SIZE := 3
const BLACKOPS_RAID_CHANCE_PER_TURN := 1
const BLACKOPS_RAID_DAY_GAP := 5
const SURVIVORS_BAND_DAY := 21
const SURVIVORS_BAND_SIZE := 5
const SURVIVORS_BAND_CHANCE_PER_TURN := 1
const SURVIVORS_BAND_DAY_GAP := 5
const ZOMBIE_LORD_EVOLUTION_MIN_DAY := 7
const DISCIPLE_EVOLUTION_MIN_DAY := 7

# Map color tints for day phases
const TINT_DAY := Color.WHITE
const TINT_SUNSET := Color(235 / 255.0, 235 / 255.0, 235 / 255.0)
const TINT_EVENING := Color(215 / 255.0, 215 / 255.0, 215 / 255.0)
const TINT_MIDNIGHT := Color(195 / 255.0, 195 / 255.0, 195 / 255.0)
const TINT_NIGHT := Color(205 / 255.0, 205 / 255.0, 205 / 255.0)
const TINT_SUNRISE := Color(225 / 255.0, 225 / 255.0, 225 / 255.0)

# Hearing chances - avoid spamming messages.
const PLAYER_HEAR_FIGHT_CHANCE := 25
const PLAYER_HEAR_SCREAMS_CHANCE := 10
const PLAYER_HEAR_PUSHPULL_CHANCE := 25  # alpha10 also for pulls
const PLAYER_HEAR_BASH_CHANCE := 25
const PLAYER_HEAR_BREAK_CHANCE := 50
const PLAYER_HEAR_EXPLOSION_CHANCE := 100

# Blood splatting
const BLOOD_WALL_SPLAT_CHANCE := 20

# NPC player sleeping snoring message chance
const MESSAGE_NPC_SLEEP_SNORE_CHANCE := 10

# Weather (alpha10): stays from 1h to 3 days and then changes.
const WEATHER_MIN_DURATION := 1 * WorldTime.TURNS_PER_HOUR
const WEATHER_MAX_DURATION := 3 * WorldTime.TURNS_PER_DAY

# Music (alpha10): check bg music every Nth game hours.
const BGMUSIC_UPDATE_TURNS := 4 * WorldTime.TURNS_PER_HOUR

# World Gen
const DISTRICT_EXIT_CHANCE_PER_TILE := 15

# ===== Missing constants, verbs and Overlay classes (RogueGame.cs 92-133, 375-447, 452-644) =====
# Mode texts & colors (RogueGame.cs lines 92-133)
const CLOSE_DOOR_MODE_TEXT := ["CLOSE MODE - directions to close, ESC cancels"]
const BARRICADE_MODE_TEXT := ["BARRICADE/REPAIR MODE - directions to barricade/repair, ESC cancels"]
const BREAK_MODE_TEXT := ["BREAK MODE - directions/wait to break an object, ESC cancels"]
const BUILD_LARGE_FORT_MODE_TEXT := ["BUILD LARGE FORTIFICATION MODE - directions to build, ESC cancels"]
const BUILD_SMALL_FORT_MODE_TEXT := ["BUILD SMALL FORTIFICATION MODE - directions to build, ESC cancels"]
const TRADE_MODE_TEXT := ["TRADE MODE - Y to accept the deal, N to refuse"]
const NEGOCIATE_TRADE_MODE_TEXT := ["NEGOCIATE TRADE MODE - directions to start negociating with someone, ESC cancels"]
const ASK_NEGOCIATE_TEXT := ["DO YOU WANT TO NEGOCIATE TRADE WITH {0} - Y to negociate, N to cancel"]
const UPGRADE_MODE_TEXT := ["UPGRADE MODE - follow instructions in the message panel"]
const FIRE_MODE_TEXT := ["FIRE MODE - F to fire, T next target, M toggle mode, ESC cancels"]
const SWITCH_PLACE_MODE_TEXT := ["SWITCH PLACE MODE - directions to switch place with a follower, ESC cancels"]
const TAKE_LEAD_MODE_TEXT := ["TAKE LEAD MODE - directions to recruit a follower, ESC cancels"]
const PULL_MODE_TEXT := ["PULL MODE - directions to select object, ESC cancels"]
const PUSH_MODE_TEXT := ["PUSH/SHOVE MODE - directions to push/shove, ESC cancels"]
const TAG_MODE_TEXT := ["TAG MODE - directions to tag a wall or on the floor, ESC cancels"]
const SPRAY_MODE_TEXT := ["SPRAY MODE - directions to spray or wait key to spray on yourself, ESC cancels"]
const PULL_OBJECT_MODE_TEXT := "PULLING {0} - directions to walk to, ESC cancels"
const PULL_ACTOR_MODE_TEXT := "PULLING {0} - directions to walk to, ESC cancels"
const PUSH_OBJECT_MODE_TEXT := "PUSHING {0} - directions to push, ESC cancels"
const SHOVE_ACTOR_MODE_TEXT := "SHOVING {0} - directions to shove, ESC cancels"
const ORDER_MODE_TEXT := ["ORDER MODE - follow instructions in the message panel, ESC cancels"]
const GIVE_MODE_TEXT := ["GIVE MODE - directions to give item to someone, ESC cancels"]
const THROW_GRENADE_MODE_TEXT := ["THROW GRENADE MODE - directions to select, F to fire,  ESC cancels"]
const MARK_ENEMIES_MODE := ["MARK ENEMIES MODE - E to make enemy, T next actor, ESC cancels"]
const TRADING_DIALOG_MODE_TEXT := ["TRADING MODE - TAB switch mode, 0..9 select, ESC cancels"]
const MODE_TEXTCOLOR := Color.YELLOW
const MODE_BORDERCOLOR := Color.YELLOW
const MODE_FILLCOLOR := Color(0.5, 0.5, 0.5, 192 / 255.0)
const TRADE_COLOR_SELECTED_ITEM := Color.LIGHT_BLUE
const TRADE_COLOR_ACCEPT := Color.LIGHT_GREEN
const TRADE_COLOR_REFUSE := Color.DARK_RED
const TRADE_COLOR_MAYBE_SUCCESS := Color.GREEN
const TRADE_COLOR_MAYBE_FAILED := Color.RED
const SAYOREMOTE_DANGER_COLOR := Color.BROWN
const SAYOREMOTE_NORMAL_COLOR := Color.DARK_CYAN

# Common verbs (RogueGame.cs lines 375-447). C# readonly Verb fields.
var VERB_ACCEPT_THE_DEAL := Verb.new("accept the deal", "accepts the deal")
var VERB_ACTIVATE := Verb.new("activate")
var VERB_AVOID := Verb.new("avoid")
var VERB_BARRICADE := Verb.new("barricade")
var VERB_BASH := Verb.new("bash", "bashes")
var VERB_BE := Verb.new("are", "is")
var VERB_BUILD := Verb.new("build")
var VERB_BREAK := Verb.new("break")
var VERB_BUTCHER := Verb.new("butcher")
var VERB_CATCH := Verb.new("catch", "catches")
var VERB_CHAT_WITH := Verb.new("chat with", "chats with")
var VERB_CLOSE := Verb.new("close")
var VERB_COLLAPSE := Verb.new("collapse")
var VERB_CRUSH := Verb.new("crush", "crushes")
var VERB_DESACTIVATE := Verb.new("desactivate")
var VERB_DESTROY := Verb.new("destroy")
var VERB_DIE := Verb.new("die")
var VERB_DIE_FROM_STARVATION := Verb.new("die from starvation", "dies from starvation")
var VERB_DISARM := Verb.new("disarm")
var VERB_DISCARD := Verb.new("discard")
var VERB_DRAG := Verb.new("drag")
var VERB_DROP := Verb.new("drop")
var VERB_EAT := Verb.new("eat")
var VERB_ENJOY := Verb.new("enjoy")
var VERB_ENTER := Verb.new("enter")
var VERB_ESCAPE := Verb.new("escape")
var VERB_FAIL := Verb.new("fail")
var VERB_FEAST_ON := Verb.new("feast on", "feasts on")
var VERB_FEEL := Verb.new("feel")
var VERB_GET := Verb.new("get")
var VERB_GIVE := Verb.new("give")
var VERB_GRAB := Verb.new("grab")
var VERB_EQUIP := Verb.new("equip")
var VERB_HAVE := Verb.new("have", "has")
var VERB_HELP := Verb.new("help")
var VERB_HEAL_WITH := Verb.new("heal with", "heals with")
var VERB_JUMP_ON := Verb.new("jump on", "jumps on")
var VERB_KILL := Verb.new("kill")
var VERB_LEAVE := Verb.new("leave")
var VERB_MISS := Verb.new("miss", "misses")
var VERB_MURDER := Verb.new("murder")
var VERB_OFFER := Verb.new("offer")
var VERB_OPEN := Verb.new("open")
var VERB_ORDER := Verb.new("order")
var VERB_PERSUADE := Verb.new("persuade")
var VERB_PULL := Verb.new("pull", "pulls")
var VERB_PUSH := Verb.new("push", "pushes")
var VERB_RAISE_ALARM := Verb.new("raise the alarm", "raises the alarm")
var VERB_REFUSE_THE_DEAL := Verb.new("refuse the deal", "refuses the deal")
var VERB_RELOAD := Verb.new("reload")
var VERB_RECHARGE := Verb.new("recharge")
var VERB_REPAIR := Verb.new("repair")
var VERB_REVIVE := Verb.new("revive")
var VERB_SEE := Verb.new("see")
var VERB_SHOUT := Verb.new("shout")
var VERB_SHOVE := Verb.new("shove")
var VERB_SNORE := Verb.new("snore")
var VERB_SPRAY := Verb.new("spray")
var VERB_START := Verb.new("start")
var VERB_STOP := Verb.new("stop")
var VERB_STUMBLE := Verb.new("stumble")
var VERB_SWITCH := Verb.new("switch", "switches")
var VERB_SWITCH_PLACE_WITH := Verb.new("switch place with", "switches place with")
var VERB_TAKE := Verb.new("take")
var VERB_THROW := Verb.new("throw")
var VERB_TRADE := Verb.new("trade")
var VERB_TRANSFORM_INTO := Verb.new("transform into", "transforms into")
var VERB_UNEQUIP := Verb.new("unequip")
var VERB_VOMIT := Verb.new("vomit")
var VERB_WAIT := Verb.new("wait")
var VERB_WAKE_UP := Verb.new("wake up", "wakes up")


# Port of the Overlay inner classes (RogueGame.cs lines 452-644).
class Overlay:
	## true = anchored to a map position: drawn in world px (through the
	## camera) so it tracks the view; false = screen-space (HUD).
	var map_anchored := false

	func draw(_p_ui: IRogueUI, _world_origin: Vector2i) -> void:
		assert(false, "abstract method")


class OverlayImage extends Overlay:
	var screen_position: Vector2i
	var image_id: String

	func _init(p_screen_position: Vector2i, p_image_id: String) -> void:
		map_anchored = true
		screen_position = p_screen_position
		image_id = p_image_id

	func draw(p_ui: IRogueUI, p_world_origin: Vector2i) -> void:
		p_ui.ui_draw_image(image_id, screen_position.x + p_world_origin.x, screen_position.y + p_world_origin.y)


class OverlayTransparentImage extends Overlay:
	var alpha: float
	var screen_position: Vector2i
	var image_id: String

	func _init(p_alpha: float, p_screen_position: Vector2i, p_image_id: String) -> void:
		map_anchored = true
		alpha = p_alpha
		screen_position = p_screen_position
		image_id = p_image_id

	func draw(p_ui: IRogueUI, p_world_origin: Vector2i) -> void:
		p_ui.ui_draw_transparent_image(alpha, image_id, screen_position.x + p_world_origin.x, screen_position.y + p_world_origin.y)


class OverlayText extends Overlay:
	var screen_position: Vector2i
	var text: String
	var color: Color
	var shadow_color: Color = Color.TRANSPARENT

	func _init(p_screen_position: Vector2i, p_color: Color, p_text: String, p_shadow_color: Color = Color.TRANSPARENT) -> void:
		map_anchored = true
		screen_position = p_screen_position
		color = p_color
		text = p_text
		shadow_color = p_shadow_color

	func draw(p_ui: IRogueUI, p_world_origin: Vector2i) -> void:
		p_ui.ui_draw_string(color, text, screen_position.x + p_world_origin.x, screen_position.y + p_world_origin.y, shadow_color)


class OverlayLine extends Overlay:
	var screen_from: Vector2i
	var screen_to: Vector2i
	var color: Color

	func _init(p_screen_from: Vector2i, p_color: Color, p_screen_to: Vector2i) -> void:
		map_anchored = true
		screen_from = p_screen_from
		color = p_color
		screen_to = p_screen_to

	func draw(p_ui: IRogueUI, p_world_origin: Vector2i) -> void:
		p_ui.ui_draw_line(color, screen_from.x + p_world_origin.x, screen_from.y + p_world_origin.y, screen_to.x + p_world_origin.x, screen_to.y + p_world_origin.y)


class OverlayRect extends Overlay:
	var rectangle: Rect2i
	var color: Color

	## p_map_anchored: true (default) for boxes around map positions (actors,
	## map objects, tiles) — drawn in world px through the camera; false for
	## the inventory/corpse panel highlights, whose coords are canvas px.
	func _init(p_color: Color, p_rect: Rect2i, p_map_anchored: bool = true) -> void:
		color = p_color
		rectangle = p_rect
		map_anchored = p_map_anchored

	func draw(p_ui: IRogueUI, p_world_origin: Vector2i) -> void:
		p_ui.ui_draw_rect(color, Rect2(rectangle.position + p_world_origin, rectangle.size))


class OverlayPopup extends Overlay:
	var screen_position: Vector2i
	var text_color: Color
	var box_border_color: Color
	var box_fill_color: Color
	var lines: PackedStringArray

	func _init(p_lines: Array, p_text_color: Color, p_box_border_color: Color, p_box_fill_color: Color, p_screen_pos: Vector2i) -> void:
		lines = PackedStringArray(p_lines)
		text_color = p_text_color
		box_border_color = p_box_border_color
		box_fill_color = p_box_fill_color
		screen_position = p_screen_pos

	func draw(p_ui: IRogueUI, _world_origin: Vector2i) -> void:
		p_ui.ui_draw_popup(lines, text_color, box_border_color, box_fill_color, screen_position.x, screen_position.y)


class OverlayPopupTitle extends Overlay:
	var screen_position: Vector2i
	var title: String
	var title_color: Color
	var lines: PackedStringArray
	var text_color: Color
	var box_border_color: Color
	var box_fill_color: Color

	func _init(p_title: String, p_title_color: Color, p_lines: Array, p_text_color: Color, p_box_border_color: Color, p_box_fill_color: Color, p_screen_pos: Vector2i) -> void:
		title = p_title
		title_color = p_title_color
		lines = PackedStringArray(p_lines)
		text_color = p_text_color
		box_border_color = p_box_border_color
		box_fill_color = p_box_fill_color
		screen_position = p_screen_pos

	func draw(p_ui: IRogueUI, _world_origin: Vector2i) -> void:
		p_ui.ui_draw_popup_title(title, title_color, lines, text_color, box_border_color, box_fill_color, screen_position.x, screen_position.y)


class OverlayPopupTitleColors extends Overlay:
	var screen_position: Vector2i
	var title: String
	var title_color: Color
	var lines: PackedStringArray
	var colors: Array
	var box_border_color: Color
	var box_fill_color: Color

	func _init(p_title: String, p_title_color: Color, p_lines: Array, p_colors: Array, p_box_border_color: Color, p_box_fill_color: Color, p_screen_pos: Vector2i) -> void:
		title = p_title
		title_color = p_title_color
		lines = PackedStringArray(p_lines)
		colors = p_colors
		box_border_color = p_box_border_color
		box_fill_color = p_box_fill_color
		screen_position = p_screen_pos

	func draw(p_ui: IRogueUI, _world_origin: Vector2i) -> void:
		p_ui.ui_draw_popup_title_colors(title, title_color, lines, colors, box_border_color, box_fill_color, screen_position.x, screen_position.y)



## Port of RogueGame.Sayflags
enum Sayflags {
	NONE = 0,
	## If told to the player and visible will highlight pause the game.
	IS_IMPORTANT = (1 << 0),
	## Does not cost action points (emote).
	IS_FREE_ACTION = (1 << 1),
	## alpha10: a warning or menace, should be highlighted.
	IS_DANGER = (1 << 2),
}

## Port of RogueGame.SimFlags
enum SimFlags {
	NOTHING = 0,
	NOT_SIMULATING = (1 << 0),
	LODETAIL_TURN = (1 << 1),
	TURBO_TURN = (1 << 3),  # turbo: lo-detail on a waking (non-sim) turn; implies LODETAIL via the gate below
}

static var options: GameOptions = null
static var key_bindings: Keybindings = null
static var hints: GameHintsStatus = null

var ui: IRogueUI
var rules: Rules
var session: Session
var hi_score_table: HiScoreTable
var message_manager: MessageManager
var is_game_running: bool = true
var has_loaded_game: bool = false
var overlays: Array = []
var player: Actor = null
var player_fov: Dictionary = {}  # HashSet<Point> -> Dictionary[Vector2i, bool]
var map_view_rect: Rect2i

var hint_available_overlay = null  # alpha10: OverlayPopup

var town_generator = null  # BaseTownGenerator

var played_intro: bool = false
var music_manager: IMusicManager = NullMusicManager.new()

var char_gen = null  # CharGen

var manual: TextFile = null
var manual_line: int = 0

var game_factions: GameFactions
var game_actors: GameActors
var game_items: GameItems
var game_tiles: GameTiles

var is_player_long_wait: bool = false
var is_player_long_wait_forced_stop: bool = false
var player_long_wait_end: WorldTime = null

# alpha10 sim thread management is not ported: Godot's turn loop is driven
# from _process on the main thread (original used a background sim thread).

# alpha10 ai loop bug detection:
# detect cases where an ai is probably performing an infinite sequence of
# ap free actions.
var _debug_prev_ai_actor: Actor = null
var _debug_same_ai_actor_count: int = 0
const DEBUG_AI_ACTOR_LOOP_COUNT_WARNING := 10


func _init(p_ui: IRogueUI) -> void:
	ui = p_ui

	# statics first: Session.reset() reads RogueGame.options.
	options = GameOptions.new()
	options.reset_to_default_values()
	key_bindings = Keybindings.new()
	key_bindings.reset_to_defaults()
	hints = GameHintsStatus.new()
	hints.reset_all_hints()

	message_manager = MessageManager.new(RogueGame.MESSAGES_SPACING, RogueGame.MESSAGES_FADEOUT, RogueGame.MESSAGES_HISTORY)

	session = Session.get_session()
	rules = Rules.new(DiceRoller.new(session.seed))

	var gen_params: Dictionary = BaseTownGenerator.DEFAULT_PARAMS.duplicate()
	gen_params.map_width = 100
	gen_params.map_height = 100
	town_generator = StdTownGenerator.new(self, gen_params)

	game_factions = GameFactions.new()
	game_actors = GameActors.new()
	game_items = GameItems.new()
	game_tiles = GameTiles.new()


# Properties
func get_session() -> Session:
	return session


func get_rules() -> Rules:
	return rules


func get_ui() -> IRogueUI:
	return ui


func get_player() -> Actor:
	return player


# Main loop.
func run() -> void:
	# first run inits.
	init_directories()

	# load data.
	load_data()

	# load options.
	load_options()

	# load hints.
	load_hints()

	# apply options.
	apply_options(false)

	# load keys.
	load_keybindings()

	# load music & sfxs (Godot port: streamed on demand by the sound manager).
	_load_audio()

	# load and parse manual.
	load_manual()

	# load hi score table.
	load_hi_score_table()

	# loop.
	while is_game_running:
		game_loop()

	# stop & dispose music.
	music_manager.stop()
	music_manager.dispose()

	# quit.
	ui.ui_do_quit()


func _load_audio() -> void:
	music_manager.load_music(GameMusics.ARMY, GameMusics.ARMY_FILE)
	music_manager.load_music(GameMusics.BIGBEAR_THEME_SONG, GameMusics.BIGBEAR_THEME_SONG_FILE)
	music_manager.load_music(GameMusics.BIKER, GameMusics.BIKER_FILE)
	music_manager.load_music(GameMusics.CHAR_UNDERGROUND_FACILITY, GameMusics.CHAR_UNDERGROUND_FACILITY_FILE)
	music_manager.load_music(GameMusics.DUCKMAN_THEME_SONG, GameMusics.DUCKMAN_THEME_SONG_FILE)
	music_manager.load_music(GameMusics.FAMU_FATARU_THEME_SONG, GameMusics.FAMU_FATARU_THEME_SONG_FILE)
	music_manager.load_music(GameMusics.FIGHT, GameMusics.FIGHT_FILE)
	music_manager.load_music(GameMusics.GANGSTA, GameMusics.GANGSTA_FILE)
	music_manager.load_music(GameMusics.HANS_VON_HANZ_THEME_SONG, GameMusics.HANS_VON_HANZ_THEME_SONG_FILE)
	music_manager.load_music(GameMusics.HEYTHERE, GameMusics.HEYTHERE_FILE)
	music_manager.load_music(GameMusics.HOSPITAL, GameMusics.HOSPITAL_FILE)
	music_manager.load_music(GameMusics.INSANE, GameMusics.INSANE_FILE)
	music_manager.load_music(GameMusics.INTERLUDE, GameMusics.INTERLUDE_FILE)
	music_manager.load_music(GameMusics.INTRO, GameMusics.INTRO_FILE)
	music_manager.load_music(GameMusics.LIMBO, GameMusics.LIMBO_FILE)
	music_manager.load_music(GameMusics.PLAYER_DEATH, GameMusics.PLAYER_DEATH_FILE)
	music_manager.load_music(GameMusics.REINCARNATE, GameMusics.REINCARNATE_FILE)
	music_manager.load_music(GameMusics.ROGUEDJACK_THEME_SONG, GameMusics.ROGUEDJACK_THEME_SONG_FILE)
	music_manager.load_music(GameMusics.SANTAMAN_THEME_SONG, GameMusics.SANTAMAN_THEME_SONG_FILE)
	music_manager.load_music(GameMusics.SEWERS, GameMusics.SEWERS_FILE)
	music_manager.load_music(GameMusics.SLEEP, GameMusics.SLEEP_FILE)
	music_manager.load_music(GameMusics.SUBWAY, GameMusics.SUBWAY_FILE)
	music_manager.load_music(GameMusics.SURVIVORS, GameMusics.SURVIVORS_FILE)
	# alpha10
	music_manager.load_music(GameMusics.SURFACE, GameMusics.SURFACE_FILE)

	music_manager.load_sfx(GameSounds.UNDEAD_EAT, GameSounds.UNDEAD_EAT_FILE)
	music_manager.load_sfx(GameSounds.UNDEAD_RISE, GameSounds.UNDEAD_RISE_FILE)
	music_manager.load_sfx(GameSounds.NIGHTMARE, GameSounds.NIGHTMARE_FILE)


func game_loop() -> void:
	# main menu.
	handle_main_menu()

	# play until player dies or quits.
	while player != null and not player.is_dead and is_game_running:
		# alpha10: roll player charisma for this turn
		session.player_turn_charisma_roll = rules.roll(0, 100)

		# play.
		has_loaded_game = false
		advance_play_district(session.current_map.district, SimFlags.NOT_SIMULATING)

		# if quit, don't bother.
		if not is_game_running:
			break

		# alpha10: check background music every N game hours
		if session.world_time.turn_counter % RogueGame.BGMUSIC_UPDATE_TURNS == 0:
			update_bg_music()


## Port of AdvancePlay(Map, SimFlags): one actor step of the play loop.
func advance_play_map(map: Map, sim: int) -> void:
	# Turbo: waking (NOT_SIMULATING) turns run every map but the player's own
	# in lo-detail; the player's map always keeps full fidelity. Sleeping sims
	# (LODETAIL_TURN) already apply district-wide — nothing to downgrade.
	if sim == SimFlags.NOT_SIMULATING and options.turbo_sim \
			and map != session.current_map:
		sim = SimFlags.TURBO_TURN
	# 0. Secret maps: don't play the map at all, jump in time.
	if map.is_secret:
		map.local_time.turn_counter += 1
		return

	# 1. Get next actor to Act.
	var actor: Actor = rules.get_next_actor_to_act(map, map.local_time.turn_counter)

	# alpha10 ai loop bug detection
	if actor != null and not actor.is_player:
		if actor == _debug_prev_ai_actor:
			_debug_same_ai_actor_count += 1
			if _debug_same_ai_actor_count >= DEBUG_AI_ACTOR_LOOP_COUNT_WARNING:
				push_warning("WARNING: AI actor %s is probably looping!!" % actor.the_name)
				# alpha10.1: in release, instead of crashing the game force
				# the AI to spend a turn and emote.
				do_wait(actor)
				do_emote(actor, "My AI is looping, I'll wait instead of crashing your game :)", true)
		else:
			_debug_same_ai_actor_count = 0
			_debug_prev_ai_actor = actor

	# 2. If none move to next turn and return.
	if actor == null:
		next_map_turn(map, sim)
		return

	# 3. Ask actor to act. Handle player and AI differently.
	actor.previous_stamina_points = actor.stamina_points
	if actor.controller == null:
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
	elif actor.is_player:
		handle_player_actor(actor)
		# if quit, dead or loaded, don't bother.
		if not is_game_running or has_loaded_game or player.is_dead:
			return
		# Check special player events
		check_special_player_events_after_action(actor)
	else:
		handle_ai_actor(actor)
	actor.previous_hit_points = actor.hit_points
	actor.previous_food_points = actor.food_points
	actor.previous_sleep_points = actor.sleep_points
	actor.previous_sanity = actor.sanity


func spend_actor_action_points(actor: Actor, action_cost: int) -> void:
	actor.action_points -= action_cost
	actor.last_action_turn = actor.location.map.local_time.turn_counter


func spend_actor_stamina_points(actor: Actor, stamina_cost: int) -> void:
	if actor.model.abilities.can_tire:
		# night penalty?
		if actor.location.map.local_time.is_night and stamina_cost > 0:
			stamina_cost += rules.night_stamina_penalty(actor)

		# exhausted?
		if rules.is_actor_exhausted(actor):
			stamina_cost *= 2

		# apply.
		actor.stamina_points -= stamina_cost
	else:
		actor.stamina_points = Rules.STAMINA_INFINITE


func regen_actor_stamina_points(actor: Actor, stamina_regen: int) -> void:
	var ab: Abilities = actor.model.abilities if actor.model != null else Abilities.NONE
	if ab.can_tire:
		actor.stamina_points = mini(rules.actor_max_sta(actor), actor.stamina_points + stamina_regen)
	else:
		actor.stamina_points = Rules.STAMINA_INFINITE


func regen_actor_hit_points(actor: Actor, hp_regen: int) -> void:
	actor.hit_points = mini(rules.actor_max_hps(actor), actor.hit_points + hp_regen)


func regen_actor_sleep(actor: Actor, sleep_regen: int) -> void:
	actor.sleep_points = mini(rules.actor_max_sleep(actor), actor.sleep_points + sleep_regen)




# ===== Assembled part files (ported from RogueGame.cs regions) =====

# Port of RogueGame.cs lines 773-1413: Messaging & Grammar helpers, Anim Delay,
# Game flow part 1 (InitDirectories, HandleMainMenu).
# The Debug fields (773-779), constructor (781-838), Run() and GameLoop() are
# already ported in the rogue_game.gd skeleton and are not duplicated here.

# Colors from the C# constants region (RogueGame.cs lines 118-122), used by the
# messaging helpers below.
const PLAYER_ACTION_COLOR := Color.WHITE
const OTHER_ACTION_COLOR := Color.GRAY
const PLAYER_AUDIO_COLOR := Color.GREEN


# --- Messaging & Grammar helpers (RogueGame.cs lines 840-1108) ---

func add_message(msg: Message) -> void:
	# ignore empty messages
	if msg.text.is_empty():
		return

	# clear if too much messages
	if message_manager.count() >= MAX_MESSAGES:
		message_manager.clear()

	# format message: <turn> <Text>
	msg.text = "%s %s" % [session.world_time.turn_counter, capitalize(msg.text)]

	# add
	message_manager.add(msg)


## Adds the message if it is audible by the player and redraws the screen.
func add_message_if_audible_for_player(location: Location, msg: Message) -> void:
	assert(msg != null, "msg")

	# 1. Audible to player?
	if player != null:
		# if sleeping can't hear.
		if player.is_sleeping:
			return

		# can't hear if not same map.
		if location.map != player.location.map:
			return

		# can hear if close enough.
		if rules.std_distance(player.location.position, location.position) <= player.audio_range:
			# hear.
			msg.color = PLAYER_AUDIO_COLOR
			add_message(msg)

			# if waiting, interrupt.
			if is_player_long_wait:
				is_player_long_wait_forced_stop = true

			# redraw.
			redraw_play_screen()


## Make a message with the text: [eventText] DISTANCE tiles to the DIRECTION.
func make_player_centric_message(event_text: String, position: Vector2i) -> Message:
	var v_dir := Vector2i(position.x - player.location.position.x, position.y - player.location.position.y)
	var text := "%s %d tiles to the %s." % [event_text, int(rules.std_distance_vec(v_dir)), Direction.approximate_from_vector(v_dir)]
	return Message.new(text, session.world_time.turn_counter)


func make_error_message(text: String) -> Message:
	return Message.new(text, session.world_time.turn_counter, Color.RED)


func make_yes_no_message(question: String) -> Message:
	return Message.new("%s? Y to confirm, N to cancel" % question, session.world_time.turn_counter, Color.YELLOW)


## Returns "someone" if not visible to the player; TheName if visible.
func actor_visible_identity(actor: Actor) -> String:
	return actor.the_name if is_visible_to_player(actor) else "someone"


## Returns "something" if not visible to the player; TheName if visible.
func object_visible_identity(map_obj: MapObject) -> String:
	return map_obj.the_name if is_visible_to_player(map_obj) else "something"


## Merged port of the 6 C# MakeMessage overloads:
## (actor,doWhat), (actor,doWhat,color), (actor,doWhat,Actor[,phraseEnd]),
## (actor,doWhat,MapObject[,phraseEnd]), (actor,doWhat,Item[,phraseEnd]).
func make_message(actor: Actor, do_what: String, target = null, phrase_end: String = ".") -> Message:
	var text := actor_visible_identity(actor) + " " + do_what
	var msg: Message
	if target is Color:
		msg = Message.new(text, session.world_time.turn_counter)
		msg.color = PLAYER_ACTION_COLOR if actor.is_player else target
	elif target is Actor:
		text += " " + actor_visible_identity(target) + phrase_end
		msg = Message.new(text, session.world_time.turn_counter)
		msg.color = PLAYER_ACTION_COLOR if (actor.is_player or target.is_player) else OTHER_ACTION_COLOR
	elif target is MapObject:
		text += " " + object_visible_identity(target) + phrase_end
		msg = Message.new(text, session.world_time.turn_counter)
		msg.color = PLAYER_ACTION_COLOR if actor.is_player else OTHER_ACTION_COLOR
	elif target is Item:
		text += " " + target.the_name() + phrase_end
		msg = Message.new(text, session.world_time.turn_counter)
		msg.color = PLAYER_ACTION_COLOR if actor.is_player else OTHER_ACTION_COLOR
	else:
		msg = Message.new(text, session.world_time.turn_counter)
		msg.color = PLAYER_ACTION_COLOR if actor.is_player else OTHER_ACTION_COLOR
	return msg


func clear_messages() -> void:
	message_manager.clear()


func clear_messages_history() -> void:
	message_manager.clear_history()


func remove_last_message() -> void:
	message_manager.remove_last_message()


func draw_messages() -> void:
	message_manager.draw(ui, session.last_turn_player_acted, MESSAGES_X, MESSAGES_Y)


# alpha10.1 caller handle bot: check for IsBotPlayer and don't call this
func add_message_press_enter() -> void:
	add_message(Message.new("<press ENTER>", session.world_time.turn_counter, Color.YELLOW))
	redraw_play_screen()
	wait_enter()
	remove_last_message()
	redraw_play_screen()


## Merged port of the 2 C# Conjugate overloads (string verb / Verb verb).
func conjugate(actor: Actor, verb) -> String:
	if verb is Verb:
		return verb.he_form if (actor.is_proper_name and not actor.is_plural_name) else verb.you_form
	return verb + "s" if (actor.is_proper_name and not actor.is_plural_name) else verb


func capitalize(text: String) -> String:
	if text == null:
		return ""
	if text.length() == 1:
		return "%s" % text[0].to_upper()
	return "%s%s" % [text[0].to_upper(), text.substr(1)]


func his_or_her(actor: Actor) -> String:
	return "his" if actor.model.doll_body.is_male else "her"


func he_or_she(actor: Actor) -> String:
	return "he" if actor.model.doll_body.is_male else "she"


func him_or_her(actor: Actor) -> String:
	return "him" if actor.model.doll_body.is_male else "her"


# alpha10
func himself_or_herself(actor: Actor) -> String:
	return "himself" if actor.model.doll_body.is_male else "herself"


## Returns "a/an name".
func a_or_an(name: String) -> String:
	var c: String = name[0]
	return ("an " if c == "a" or c == "e" or c == "i" or c == "u" else "a ") + name


func truncate_string(s: String, max_length: int) -> String:
	return s if s.length() <= max_length else s.substr(0, max_length)


# --- Anim Delay (RogueGame.cs lines 1113-1119) ---

func anim_delay(msecs: int) -> void:
	if options.is_anim_delay_on:
		ui.ui_wait(msecs)


# --- Game flow part 1 (RogueGame.cs lines 1246-1405) ---
# Run() and GameLoop() are already ported in the rogue_game.gd skeleton.

func init_directories() -> void:
	var gy := 0
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.YELLOW, "Checking user game directories...", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()

	# create directories (C# |= is non-short-circuiting: every call runs)
	# TODO: C# passes gy by ref to check_directory; reconcile with ported signature.
	var created := false
	created = check_directory(get_user_base_path(), "base user", gy)["created"]
	created = check_directory(get_user_config_path(), "config", gy)["created"] or created
	created = check_directory(get_user_docs_path(), "docs", gy)["created"] or created
	created = check_directory(get_user_graveyard_path(), "graveyard", gy) or created
	created = check_directory(get_user_saves_path(), "saves", gy) or created
	created = check_directory(get_user_screenshots_path(), "screenshots", gy) or created

	# copying manual
	created = check_copy_of_manual() or created

	if created:
		ui.ui_draw_string_bold(Color.YELLOW, "Directories and game manual created.", 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Your game data directory is in the game folder:", 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string(Color.LIGHT_GREEN, get_user_base_path(), 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "When you uninstall the game you can delete this directory.", 0, gy)
		gy += BOLD_LINE_SPACING
		draw_footnote(Color.WHITE, "press ENTER")
		ui.ui_repaint()
		wait_enter()


func handle_main_menu() -> void:
	var loop := true
	var is_load_enabled: bool = FileAccess.file_exists(get_user_save())

	var menu_entries: Array = [
		"New Game",                                      # 0
		"Load Game" if is_load_enabled else "(Load Game)",  # 1
		"Redefine keys",                                 # 2
		"Options",                                       # 3
		"Game Manual",                                   # 4
		"All Hints",                                     # 5
		"Hi Scores",                                     # 6
		"Credits",                                       # 7
		"Quit Game",                                     # 8
	]
	var selected := 0
	while loop:
		# music.
		if not played_intro:
			music_manager.stop()
			music_manager.play(GameMusics.INTRO, MusicPriority.PRIORITY_EVENT)
			played_intro = true

		# display.
		var gx := 0
		var gy := 0
		ui.ui_clear(Color.BLACK)
		draw_header()
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Main Menu", 0, gy)
		gy += 2 * BOLD_LINE_SPACING
		# TODO: C# passes gy by ref (DrawMenuOrOptions ..., gx, ref gy)
		draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.WHITE, null, gx, gy)
		draw_footnote(Color.WHITE, "cursor to move, ENTER to select")

		# christmas special.
		var date_now := Time.get_datetime_dict_from_system()
		if date_now.month == 12 and date_now.day >= 24 and date_now.day <= 26:
			const NB_SANTAS := 10
			for i in NB_SANTAS:
				var santax := rules.roll(0, 1024)
				var santay := rules.roll(0, 768)
				ui.ui_draw_image(GameImages.ACTOR_SANTAMAN, santax, santay)
				ui.ui_draw_string_bold(Color.SNOW, "* Merry Christmas *", santax - 60, santay - 10)

		# repaint.
		ui.ui_repaint()

		# get menu action.
		var key: InputEventKey = ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ENTER:  # validate
				match selected:
					0:
						if handle_new_character():
							start_new_game()
							loop = false
					1:
						if is_load_enabled:
							gy += 2 * BOLD_LINE_SPACING
							ui.ui_draw_string_bold(Color.YELLOW, "Loading game, please wait...", gx, gy)
							ui.ui_repaint()
							load_game(get_user_save())
							loop = false
							# alpha10: original starts the background sim thread here;
							# the Godot port runs the turn loop on the main thread.
							# if options.is_sim_on and options.sim_thread: start_sim_thread()
					2:
						handle_redefine_keys()
					3:
						handle_options(false)
						apply_options(false)
					4:
						handle_help_mode()
					5:
						handle_hints_screen()
					6:
						handle_hi_scores(true)
					7:
						handle_credits()
					8:
						is_game_running = false
						loop = false
					_:
						pass


# Port of RogueGame.cs lines 1414-2176 (Character creation, Manual, HiScore).
# Helpers draw_menu_or_options / draw_footnote / draw_header / wait_yes_or_no /
# wait_enter / wait_escape / truncate_string / time_span_to_string /
# describe_skill_short / apply_options / get_user_* file paths are ported in
# other part files of RogueGame.


## Port of the CharGen struct (RogueGame.cs line 647).
class CharGen:
	var is_undead: bool = false
	var undead_model: int = GameActors.IDs.UNDEAD_MALE_ZOMBIFIED
	var is_male: bool = true
	var starting_skill: int = Skills.IDs._FIRST


func handle_new_character() -> bool:
	var roller := DiceRoller.new()
	char_gen = CharGen.new()

	# Reset session
	session.reset()

	# Game Mode
	if not handle_new_game_mode():
		return false

	# Choose living/undead
	var race := handle_new_character_race(roller)
	if not race.done:
		return false
	char_gen.is_undead = race.is_undead

	# Choose gender/undead type
	if char_gen.is_undead:
		var ut := handle_new_character_undead_type(roller)
		if not ut.done:
			return false
		char_gen.undead_model = ut.model_id
	else:
		var gender := handle_new_character_gender(roller)
		if not gender.done:
			return false
		char_gen.is_male = gender.is_male

	# Choose skill (living only)
	if not char_gen.is_undead:
		var sk := handle_new_character_skill(roller)
		if not sk.done:
			return false
		char_gen.starting_skill = sk.sk_id
		# scoring : starting skill.
		session.scoring.starting_skill = sk.sk_id
	else:
		pass  # udead.

	# done
	return true


func handle_new_game_mode() -> bool:
	var menu_entries := [
		Session.desc_game_mode(Session.GameMode.GM_STANDARD),
		Session.desc_game_mode(Session.GameMode.GM_CORPSES_INFECTION),
		Session.desc_game_mode(Session.GameMode.GM_VINTAGE),
	]
	var descs := [
		"Rogue Survivor standard game.",
		"Don't get a cold. Keep an eye on your deceased diseased friends.",
		"The classic zombies next door.",
	]

	var loop := true
	var choice_done := false
	var selected := 0
	while loop:
		# display.
		ui.ui_clear(Color.BLACK)
		var gx := 0
		var gy := 0
		ui.ui_draw_string_bold(Color.YELLOW, "New Game - Choose Game Mode", gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		# TODO: C# passes gy by ref; the ported helper is assumed to return the updated gy.
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GRAY, descs, gx, gy)
		gy += 2 * BOLD_LINE_SPACING

		var desc_mode: Array = []
		match selected:
			0:
				desc_mode = [
					"This is the standard game setting.",
					"Recommended for beginners.",
					"- All the kinds of undeads.",
					"- Undeads can evolve to stronger forms.",
					"- Livings can zombify instantly when dead.",
					"- No infection.",
					"- No corpses.",
				]
			1:
				desc_mode = [
					"This is the standard game setting plus corpses and infection.",
					"Recommended to experience all the features of the game.",
					"- All the kinds of undeads.",
					"- Undeads can evolve to stronger forms.",
					"- Infection:",
					"  - some undeads can infect livings when biting them.",
					"  - infected livings can become ill and die.",
					"  - infected corpses have more chances to rise as zombies.",
					"- Corpses:",
					"  - livings that die drop corpses that will rot away.",
					"  - corpses may rise as zombies.",
					"  - undeads can eat corpses.",
					"  - livings can eat corpses if desperate.",
				]
			2:
				desc_mode = [
					"This is the classic zombies for hardcore zombie fans.",
					"Recommended if you want classic movies zombies.",
					"- Undeads are only zombified men and women.",
					"- Undeads don't evolve to stronger forms.",
					"- Infection:",
					"  - some undeads can infect livings when biting them.",
					"  - infected livings can become ill and die.",
					"  - infected corpses have more chances to rise as zombies.",
					"- Corpses:",
					"  - livings that die drop corpses that will rot away.",
					"  - corpses may rise as zombies.",
					"  - undeads can eat corpses.",
					"  - livings can eat corpses if desperate.",
					"",
					"NOTE:",
					"This mode force some options OFF.",
					"Remember to set them back ON again when you play other modes!",
				]
		for line in desc_mode:
			ui.ui_draw_string_bold(Color.GRAY, line, gx, gy)
			gy += BOLD_LINE_SPACING

		draw_footnote(Color.WHITE, "cursor to move, ENTER to select, ESC to cancel")
		ui.ui_repaint()

		# get menu action.
		var key := ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ESCAPE:
				choice_done = false
				loop = false
			KEY_ENTER:  # validate
				match selected:
					0:  # standard
						session.game_mode = Session.GameMode.GM_STANDARD
						choice_done = true
						loop = false
					1:  # corpses & infection
						session.game_mode = Session.GameMode.GM_CORPSES_INFECTION
						choice_done = true
						loop = false
					2:  # vintage
						session.game_mode = Session.GameMode.GM_VINTAGE
						# force some options off.
						options.allow_undeads_evolution = false
						options.shamblers_upgrade = false
						options.rats_upgrade = false
						options.skeletons_upgrade = false
						apply_options(false)
						choice_done = true
						loop = false

	# done.
	return choice_done


## Out-param isUndead -> returned in the Dictionary.
func handle_new_character_race(roller: DiceRoller) -> Dictionary:
	var menu_entries := [
		"*Random*",
		"Living",
		"Undead",
	]
	var descs := [
		"(picks a race at random for you)",
		"Try to survive.",
		"Eat brains and die again.",
	]

	var is_undead := false
	var loop := true
	var choice_done := false
	var selected := 0
	while loop:
		# display.
		ui.ui_clear(Color.BLACK)
		var gx := 0
		var gy := 0
		ui.ui_draw_string_bold(Color.YELLOW, "[%s] New Character - Choose Race" % Session.desc_game_mode(session.game_mode), gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GRAY, descs, gx, gy)
		gy += 2 * BOLD_LINE_SPACING

		draw_footnote(Color.WHITE, "cursor to move, ENTER to select, ESC to cancel")
		ui.ui_repaint()

		# get menu action.
		var key := ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ESCAPE:
				choice_done = false
				loop = false
			KEY_ENTER:  # validate
				match selected:
					0:  # random
						is_undead = roller.roll_chance(50)

						gy += BOLD_LINE_SPACING
						ui.ui_draw_string_bold(Color.WHITE, "Race : %s." % ("Undead" if is_undead else "Living"), gx, gy)
						gy += BOLD_LINE_SPACING
						ui.ui_draw_string_bold(Color.YELLOW, "Is that OK? Y to confirm, N to cancel.", gx, gy)
						ui.ui_repaint()
						if wait_yes_or_no():
							choice_done = true
							loop = false
					1:  # living
						is_undead = false
						choice_done = true
						loop = false
					2:  # undead
						is_undead = true
						choice_done = true
						loop = false

	# done.
	return {"done": choice_done, "is_undead": is_undead}

## Out-param isMale -> returned in the Dictionary.
func handle_new_character_gender(roller: DiceRoller) -> Dictionary:
	var male_model := game_actors.male_civilian()
	var female_model := game_actors.female_civilian()

	var menu_entries := [
		"*Random*",
		"Male",
		"Female",
	]
	var descs := [
		"(picks a gender at random for you)",
		"HP:%02d  Def:%02d  Dmg:%d" % [male_model.starting_sheet.base_hit_points, male_model.starting_sheet.base_defence.value, male_model.starting_sheet.unarmed_attack.damage_value],
		"HP:%02d  Def:%02d  Dmg:%d" % [female_model.starting_sheet.base_hit_points, female_model.starting_sheet.base_defence.value, female_model.starting_sheet.unarmed_attack.damage_value],
	]

	var is_male := true
	var loop := true
	var choice_done := false
	var selected := 0
	while loop:
		# display.
		ui.ui_clear(Color.BLACK)
		var gx := 0
		var gy := 0
		ui.ui_draw_string_bold(Color.YELLOW, "[%s] New Living - Choose Gender" % Session.desc_game_mode(session.game_mode), gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GRAY, descs, gx, gy)
		draw_footnote(Color.WHITE, "cursor to move, ENTER to select, ESC to cancel")
		ui.ui_repaint()

		# get menu action.
		var key := ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ESCAPE:
				choice_done = false
				loop = false
			KEY_ENTER:  # validate
				match selected:
					0:  # random
						is_male = roller.roll_chance(50)

						gy += BOLD_LINE_SPACING
						ui.ui_draw_string_bold(Color.WHITE, "Gender : %s." % ("Male" if is_male else "Female"), gx, gy)
						gy += BOLD_LINE_SPACING
						ui.ui_draw_string_bold(Color.YELLOW, "Is that OK? Y to confirm, N to cancel.", gx, gy)
						ui.ui_repaint()
						if wait_yes_or_no():
							choice_done = true
							loop = false
					1:  # male
						is_male = true
						choice_done = true
						loop = false
					2:  # female
						is_male = false
						choice_done = true
						loop = false

	# done.
	return {"done": choice_done, "is_male": is_male}


func describe_undead_model_stat_line(m: ActorModel) -> String:
	return "HP:%03d  Spd:%.2f  Atk:%02d  Def:%02d  Dmg:%02d  FoV:%d  Sml:%.2f" % [
		m.starting_sheet.base_hit_points, m.doll_body.speed / 100.0,
		m.starting_sheet.unarmed_attack.hit_value, m.starting_sheet.base_defence.value, m.starting_sheet.unarmed_attack.damage_value,
		m.starting_sheet.base_view_range, m.starting_sheet.base_smell_rating]


## Out-param modelID -> returned in the Dictionary.
func handle_new_character_undead_type(roller: DiceRoller) -> Dictionary:
	var skeleton_model := game_actors.skeleton()
	var shambler_model := game_actors.zombie()
	var male_model := game_actors.male_zombified()
	var female_model := game_actors.female_zombified()
	var master_model := game_actors.zombie_master()

	var menu_entries := [
		"*Random*",
		skeleton_model.name,
		shambler_model.name,
		male_model.name,
		female_model.name,
		master_model.name,
	]
	var descs := [
		"(picks a type at random for you)",
		describe_undead_model_stat_line(skeleton_model),
		describe_undead_model_stat_line(shambler_model),
		describe_undead_model_stat_line(male_model),
		describe_undead_model_stat_line(female_model),
		describe_undead_model_stat_line(master_model),
	]

	var model_id: int = GameActors.IDs.UNDEAD_MALE_ZOMBIFIED
	var loop := true
	var choice_done := false
	var selected := 0
	while loop:
		# display.
		ui.ui_clear(Color.BLACK)
		var gx := 0
		var gy := 0
		ui.ui_draw_string_bold(Color.YELLOW, "[%s] New Undead - Choose Type" % Session.desc_game_mode(session.game_mode), gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GRAY, descs, gx, gy)
		draw_footnote(Color.WHITE, "cursor to move, ENTER to select, ESC to cancel")
		ui.ui_repaint()

		# get menu action.
		var key := ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ESCAPE:
				choice_done = false
				loop = false
			KEY_ENTER:  # validate
				match selected:
					0:  # random
						selected = roller.roll(0, 5)
						match selected:
							0: model_id = GameActors.IDs.UNDEAD_SKELETON
							1: model_id = GameActors.IDs.UNDEAD_ZOMBIE
							2: model_id = GameActors.IDs.UNDEAD_MALE_ZOMBIFIED
							3: model_id = GameActors.IDs.UNDEAD_FEMALE_ZOMBIFIED
							4: model_id = GameActors.IDs.UNDEAD_ZOMBIE_MASTER
							_: push_error("unhandled select %d" % selected)

						gy += BOLD_LINE_SPACING
						ui.ui_draw_string_bold(Color.WHITE, "Type : %s." % game_actors.get_model(model_id).name, gx, gy)
						gy += BOLD_LINE_SPACING
						ui.ui_draw_string_bold(Color.YELLOW, "Is that OK? Y to confirm, N to cancel.", gx, gy)
						ui.ui_repaint()
						if wait_yes_or_no():
							choice_done = true
							loop = false
					1:  # skeleton
						model_id = GameActors.IDs.UNDEAD_SKELETON
						choice_done = true
						loop = false
					2:  # shambler
						model_id = GameActors.IDs.UNDEAD_ZOMBIE
						choice_done = true
						loop = false
					3:  # male zombified
						model_id = GameActors.IDs.UNDEAD_MALE_ZOMBIFIED
						char_gen.is_male = true
						choice_done = true
						loop = false
					4:  # female zombified
						model_id = GameActors.IDs.UNDEAD_FEMALE_ZOMBIFIED
						char_gen.is_male = false
						choice_done = true
						loop = false
					5:  # zm
						model_id = GameActors.IDs.UNDEAD_ZOMBIE_MASTER
						choice_done = true
						loop = false

	# done.
	return {"done": choice_done, "model_id": model_id}


## Out-param skID -> returned in the Dictionary.
func handle_new_character_skill(roller: DiceRoller) -> Dictionary:
	# Make table of all skills.
	var all_skills: Array = []
	all_skills.resize(Skills.IDs._LAST_LIVING + 1)
	var menu_entries: Array = []
	var skill_desc: Array = []
	menu_entries.resize(all_skills.size() + 1)
	skill_desc.resize(all_skills.size() + 1)
	menu_entries[0] = "*Random*"
	skill_desc[0] = "(picks a skill at random for you)"
	for i in range(Skills.IDs._FIRST_LIVING, Skills.IDs._LAST_LIVING + 1):
		all_skills[i] = i
		menu_entries[i + 1] = Skills.name(all_skills[i])
		skill_desc[i + 1] = "%d max - %s" % [Skills.max_skill_level(i), describe_skill_short(all_skills[i])]

	# Loop until choice done
	var sk_id: int = Skills.IDs._FIRST
	var loop := true
	var choice_done := false
	var selected := 0
	while loop:
		# display.
		ui.ui_clear(Color.BLACK)
		var gx := 0
		var gy := 0
		ui.ui_draw_string_bold(Color.YELLOW, "[%s] New %s Character - Choose Starting Skill" % [Session.desc_game_mode(session.game_mode), "Male" if char_gen.is_male else "Female"], gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GRAY, skill_desc, gx, gy)
		draw_footnote(Color.WHITE, "cursor to move, ENTER to select, ESC to cancel")
		ui.ui_repaint()

		# get menu action.
		var key := ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ESCAPE:
				choice_done = false
				loop = false
			KEY_ENTER:  # validate
				if selected == 0:  # random
					sk_id = Skills.roll_living(roller)
				else:
					sk_id = selected - 1 + Skills.IDs._FIRST

				gy += BOLD_LINE_SPACING
				ui.ui_draw_string_bold(Color.WHITE, "Skill : %s." % Skills.name(sk_id), gx, gy)
				gy += BOLD_LINE_SPACING
				ui.ui_draw_string_bold(Color.YELLOW, "Is that OK? Y to confirm, N to cancel.", gx, gy)
				ui.ui_repaint()
				if wait_yes_or_no():
					choice_done = true
					loop = false

	# done.
	return {"done": choice_done, "sk_id": sk_id}

func load_manual() -> void:
	ui.ui_clear(Color.BLACK)
	var gy := 0
	ui.ui_draw_string_bold(Color.WHITE, "Loading game manual...", 0, 0)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()

	manual = TextFile.new()
	manual_line = 0
	if not manual.load_file(get_user_manual_file_path()):
		# error.
		ui.ui_draw_string_bold(Color.RED, "Error while loading the manual.", 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.RED, "The manual won't be available ingame.", 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_repaint()
		draw_footnote(Color.WHITE, "press ENTER")
		wait_enter()

		# delete manual.
		manual = null
		return

	ui.ui_draw_string_bold(Color.WHITE, "Parsing game manual...", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()
	manual.format_lines(TEXTFILE_CHARS_PER_LINE)

	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Game manual... done!", 0, gy)
	ui.ui_repaint()


func handle_hi_scores(save_to_textfile: bool) -> void:
	var file = null
	if save_to_textfile:
		file = TextFile.new()

	ui.ui_clear(Color.BLACK)
	var gy := 0
	draw_header()
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.YELLOW, "Hi Scores", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
	gy += BOLD_LINE_SPACING

	# display.
	ui.ui_draw_string_bold(Color.WHITE, "Rank | Name, Skills, Death       |  Score |Difficulty|Survival|  Kills |Achievm.|      Game Time | Playing time", 0, gy)
	gy += BOLD_LINE_SPACING

	# text.
	if save_to_textfile:
		# TODO: SetupConfig.GAME_VERSION ("alpha 10.1") not ported as a const yet.
		file.append("ROGUE SURVIVOR alpha 10.1")
		file.append("Hi Scores")
		file.append("Rank | Name, Skills, Death       |  Score |Difficulty|Survival|  Kills |Achievm.|      Game Time | Playing time")

	# individual entries.
	for i in hi_score_table.count:
		# display.
		var rank_color: Color
		if i == 0:
			rank_color = Color.LIGHT_YELLOW
		elif i == 1:
			rank_color = Color.LIGHT_CYAN
		elif i == 2:
			rank_color = Color.LIGHT_GREEN
		else:
			rank_color = Color.DIM_GRAY
		ui.ui_draw_string_bold(rank_color, "------------------------------------------------------------------------------------------------------------------------", 0, gy)
		gy += BOLD_LINE_SPACING
		var hi := hi_score_table.get_score(i)
		# TODO: C# TimeSpan -> GDScript float (seconds) for playing_time.
		var line := "%s. | %s | %s |     %s%% | %s | %s | %s | %s | %s" % [
			str(i + 1).lpad(3), truncate_string(hi.name, 25).rpad(25),
			str(hi.total_points).lpad(6), str(hi.difficulty_percent).lpad(3),
			str(hi.survival_points).lpad(6), str(hi.kill_points).lpad(6), str(hi.achievement_points).lpad(6),
			str(WorldTime.new(hi.turn_survived)).lpad(14), time_span_to_string(int(hi.playing_time))]
		ui.ui_draw_string_bold(rank_color, line, 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(rank_color, "     | %s." % hi.skills_description, 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(rank_color, "     | %s." % hi.death, 0, gy)
		gy += BOLD_LINE_SPACING

		# text.
		if save_to_textfile:
			file.append("------------------------------------------------------------------------------------------------------------------------")
			file.append(line)
			file.append("     | %s" % hi.skills_description)
			file.append("     | %s" % hi.death)

	# save.
	var textfile_path := get_user_hi_score_text_file_path()
	if save_to_textfile:
		file.save_file(textfile_path)

	# display.
	ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
	gy += BOLD_LINE_SPACING
	if save_to_textfile:
		ui.ui_draw_string_bold(Color.WHITE, textfile_path, 0, gy)
		gy += BOLD_LINE_SPACING
	draw_footnote(Color.WHITE, "press ESC to leave")
	ui.ui_repaint()
	wait_escape()


func load_hi_score_table() -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading hiscores table...", 0, 0)
	ui.ui_repaint()

	hi_score_table = HiScoreTable.load_table(get_user_hi_score_file_path())
	if hi_score_table == null:
		hi_score_table = HiScoreTable.new(HiScoreTable.DEFAULT_MAX_ENTRIES)
		hi_score_table.clear()

	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading hiscores table... done!", 0, 0)
	ui.ui_repaint()


func save_hi_score_table() -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Saving hiscores table...", 0, 0)
	ui.ui_repaint()

	HiScoreTable.save(hi_score_table, get_user_hi_score_file_path())

	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Saving hiscores table... done!", 0, 0)
	ui.ui_repaint()


func start_new_game() -> void:
	var is_undead: bool = char_gen.is_undead

	# generate world.
	generate_world(true, options.city_size)

	# scoring : hello there.
	session.scoring.add_visit(session.world_time.turn_counter, player.location.map)
	session.scoring.add_event(session.world_time.turn_counter, ("Rose in %s." if is_undead else "Woke up in %s.") % [player.location.map.name])

	# setup proper scoring mode.
	session.scoring.side = Scoring.DifficultySide.FOR_UNDEAD if is_undead else Scoring.DifficultySide.FOR_SURVIVOR

	# alpha10.1 schedule first autosave.
	schedule_next_auto_save()

	# advisor on? alpha10 not if undead
	if options.is_advisor_enabled:
		clear_messages()
		clear_messages_history()
		if player.model.abilities.is_undead:
			add_message(Message.new("The Advisor is enabled but you will get no hint when playing undead.", 0, Color.RED))
		else:
			add_message(Message.new("The Advisor is enabled and will give you hints during the game.", 0, Color.LIGHT_GREEN))
			add_message(Message.new("The hints help a beginner learning the basic controls.", 0, Color.LIGHT_GREEN))
			add_message(Message.new("You can disable the Advisor by going to the Options screen.", 0, Color.LIGHT_GREEN))
		add_message(Message.new("Press %s during the game to change the options." % [key_bindings.get_key(PlayerCommand.Command.OPTIONS_MODE)], 0, Color.LIGHT_GREEN))
		add_message(Message.new("<press ENTER>", 0, Color.YELLOW))
		redraw_play_screen()
		wait_enter()

	# welcome banner.
	clear_messages()
	clear_messages_history()
	add_message(Message.new("*****************************", 0, Color.LIGHT_GREEN))
	add_message(Message.new("* Welcome to Rogue Survivor *", 0, Color.LIGHT_GREEN))
	add_message(Message.new("* We hope you like Zombies  *", 0, Color.LIGHT_GREEN))
	add_message(Message.new("*****************************", 0, Color.LIGHT_GREEN))
	add_message(Message.new("Press %s for help" % [key_bindings.get_key(PlayerCommand.Command.HELP_MODE)], 0, Color.LIGHT_GREEN))
	add_message(Message.new("Press %s to redefine keys" % [key_bindings.get_key(PlayerCommand.Command.KEYBINDING_MODE)], 0, Color.LIGHT_GREEN))
	add_message(Message.new("<press ENTER>", 0, Color.YELLOW))
	refresh_player()
	redraw_play_screen()
	wait_enter()

	# wake up!
	clear_messages()
	add_message(Message.new(("%s rises..." if is_undead else "%s wakes up.") % [player.name], 0, Color.WHITE))
	redraw_play_screen()

	# alpha10.1 reset/cleanup bot from previous session (#if DEBUG block skipped)

	# start simulation thread. Godot port: sim runs on the main thread turn
	# loop, so these are no-ops kept for call-graph parity.
	stop_sim_thread(false)  # TODO sim thread not ported (main-thread loop)
	start_sim_thread()  # TODO sim thread not ported (main-thread loop)


func handle_credits() -> void:
	const left := 0
	const right := 256
	var gy := 0

	# music.
	music_manager.stop()
	music_manager.play(GameMusics.SLEEP, MusicPriority.PRIORITY_BGM)

	# draw.
	ui.ui_clear(Color.BLACK)
	draw_header()
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.YELLOW, "Credits", 0, gy)
	gy += 2 * BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Programming, Graphics & Music by Jacques Ruiz (roguedjack) 2018", 0, gy)
	gy += 2 * BOLD_LINE_SPACING

	ui.ui_draw_string_bold(Color.WHITE, "Programming", left, gy)
	ui.ui_draw_string(Color.WHITE, "- C# NET 3.5, Microsoft Visual Studio Community 2017", right, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Graphic softwares", left, gy)
	ui.ui_draw_string(Color.WHITE, "- Inkscape, Paint.NET", right, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Sound & Music softwares", left, gy)
	ui.ui_draw_string(Color.WHITE, "- GuitarPro 7, Audacity", right, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Sound samples", left, gy)
	ui.ui_draw_string(Color.WHITE, "- http://www.sound-fishing.net  http://www.soundsnap.com/", right, gy)

	gy += 2 * BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Contact", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string(Color.WHITE, "Email      : roguedjack@yahoo.fr", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string(Color.WHITE, "Blog       : http://roguesurvivor.blogspot.com/", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string(Color.WHITE, "Fans Forum : http://roguesurvivor.proboards.com/", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Thanks to the players for their feedback and eagerness to die!", 0, gy)
	gy += BOLD_LINE_SPACING

	draw_footnote(Color.WHITE, "ESC to leave")
	ui.ui_repaint()
	wait_escape()


# alpha10 removed mention of mode and mentioned which options are always off
# in certain modes (vintage)
func handle_options(_ingame: bool) -> void:
	var prev_options: GameOptions = options

	var list: Array = [
		# autosave
		GameOptions.IDs.GAME_AUTOSAVE_PERIOD,  # alpha10.1
		# display & sounds
		GameOptions.IDs.UI_MUSIC,
		GameOptions.IDs.UI_MUSIC_VOLUME,
		GameOptions.IDs.UI_ANIM_DELAY,
		GameOptions.IDs.UI_SHOW_MINIMAP,
		GameOptions.IDs.UI_SHOW_PLAYER_TAG_ON_MINIMAP,
		# helpers
		GameOptions.IDs.UI_ADVISOR,
		GameOptions.IDs.UI_COMBAT_ASSISTANT,
		GameOptions.IDs.UI_SHOW_PLAYER_TARGETS,
		GameOptions.IDs.UI_SHOW_TARGETS,
		# sim
		GameOptions.IDs.GAME_SIMULATE_DISTRICTS,
		GameOptions.IDs.GAME_SIM_THREAD,
		GameOptions.IDs.GAME_SIMULATE_SLEEP,
		GameOptions.IDs.GAME_TURBO_SIM,
		# death
		GameOptions.IDs.GAME_DEATH_SCREENSHOT,
		GameOptions.IDs.GAME_PERMADEATH,
		# maps
		GameOptions.IDs.GAME_CITY_SIZE,
		GameOptions.IDs.GAME_DISTRICT_SIZE,
		GameOptions.IDs.GAME_REVEAL_STARTING_DISTRICT,
		# living
		GameOptions.IDs.GAME_MAX_CIVILIANS,
		# GameOptions.IDs.GAME_MAX_DOGS,
		GameOptions.IDs.GAME_ZOMBIFICATION_CHANCE,
		GameOptions.IDs.GAME_AGGRESSIVE_HUNGRY_CIVILIANS,
		GameOptions.IDs.GAME_NPC_CAN_STARVE_TO_DEATH,
		GameOptions.IDs.GAME_STARVED_ZOMBIFICATION_CHANCE,
		# undeads
		GameOptions.IDs.GAME_MAX_UNDEADS,
		GameOptions.IDs.GAME_ALLOW_UNDEADS_EVOLUTION,
		GameOptions.IDs.GAME_DAY_ZERO_UNDEADS_PERCENT,
		GameOptions.IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE,
		GameOptions.IDs.GAME_UNDEADS_UPGRADE_DAYS,
		GameOptions.IDs.GAME_SHAMBLERS_UPGRADE,
		GameOptions.IDs.GAME_SKELETONS_UPGRADE,
		GameOptions.IDs.GAME_RATS_UPGRADE,
		# events
		GameOptions.IDs.GAME_NATGUARD_FACTOR,
		GameOptions.IDs.GAME_SUPPLIESDROP_FACTOR,
		# reinc
		GameOptions.IDs.GAME_MAX_REINCARNATIONS,
		GameOptions.IDs.GAME_REINC_LIVING_RESTRICTED,
		GameOptions.IDs.GAME_REINCARNATE_AS_RAT,
		GameOptions.IDs.GAME_REINCARNATE_TO_SEWERS,
	]

	var menu_entries: Array = []
	menu_entries.resize(list.size())
	var values: Array = []
	values.resize(list.size())
	for i in list.size():
		menu_entries[i] = GameOptions.name_of(list[i])
		# alpha10 special mode notes
		var id: int = list[i]
		if id == GameOptions.IDs.GAME_ALLOW_UNDEADS_EVOLUTION \
				or id == GameOptions.IDs.GAME_RATS_UPGRADE \
				or id == GameOptions.IDs.GAME_SKELETONS_UPGRADE \
				or id == GameOptions.IDs.GAME_SHAMBLERS_UPGRADE:
			menu_entries[i] += " -V"
		elif id == GameOptions.IDs.GAME_ZOMBIFICATION_CHANCE \
				or id == GameOptions.IDs.GAME_STARVED_ZOMBIFICATION_CHANCE:
			menu_entries[i] += " =S"

	var loop := true
	var selected := 0
	while loop:
		for i in list.size():
			values[i] = options.describe_value(session.game_mode, list[i])

		var gx := 0
		var gy := 0
		ui.ui_clear(Color.BLACK)
		draw_header()
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Options", 0, gy)  # alpha10 dont mention current mode
		gy += 2 * BOLD_LINE_SPACING
		# C# ref gy -> returns the new gy
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GREEN, values, gx, gy, false, 400)

		# alpha10 describe current option.
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, menu_entries[selected].lstrip(" "), gx, gy)
		gy += BOLD_LINE_SPACING
		var desc: String = GameOptions.describe(list[selected])
		for d in desc.split("\n"):
			ui.ui_draw_string(Color.WHITE, "  " + d, gx, gy)
			gy += BOLD_LINE_SPACING

		# legend.
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.RED, "* Caution : increasing these values makes the game runs slower and saving/loading longer.", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "-V : option always OFF when playing VTG-Vintage", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "=S : option used only when playing STD-Standard", gx, gy)
		gy += BOLD_LINE_SPACING

		# difficulty rating.
		gy += BOLD_LINE_SPACING
		var diff_for_survivor := int(100 * Scoring.compute_difficulty_rating(options, Scoring.DifficultySide.FOR_SURVIVOR, 0))
		var diff_for_undead := int(100 * Scoring.compute_difficulty_rating(options, Scoring.DifficultySide.FOR_UNDEAD, 0))
		ui.ui_draw_string_bold(Color.YELLOW, "Difficulty Rating : %d%% as survivor / %d%% as undead." % [diff_for_survivor, diff_for_undead], gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "Difficulty used for scoring automatically decrease with each reincarnation.", gx, gy)
		gy += 2 * BOLD_LINE_SPACING

		# footnote.
		draw_footnote(Color.WHITE, "cursor to move and change values, R to restore previous values, ESC to save and leave")
		ui.ui_repaint()

		# handle get menu action.
		var key: InputEventKey = ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_R:  # restore previous.
				options = prev_options
			KEY_ESCAPE:  # validate and leave
				loop = false
			KEY_LEFT:
				match list[selected]:
					GameOptions.IDs.GAME_DISTRICT_SIZE: options.district_size -= 5
					GameOptions.IDs.UI_MUSIC: options.play_music = not options.play_music
					GameOptions.IDs.UI_MUSIC_VOLUME: options.music_volume -= 5
					GameOptions.IDs.UI_ANIM_DELAY: options.is_anim_delay_on = not options.is_anim_delay_on
					GameOptions.IDs.UI_SHOW_MINIMAP: options.is_minimap_on = not options.is_minimap_on
					GameOptions.IDs.UI_SHOW_PLAYER_TAG_ON_MINIMAP: options.show_player_tags_on_minimap = not options.show_player_tags_on_minimap
					GameOptions.IDs.UI_ADVISOR: options.is_advisor_enabled = not options.is_advisor_enabled
					GameOptions.IDs.UI_COMBAT_ASSISTANT: options.is_combat_assistant_on = not options.is_combat_assistant_on
					GameOptions.IDs.UI_SHOW_TARGETS: options.show_targets = not options.show_targets
					GameOptions.IDs.UI_SHOW_PLAYER_TARGETS: options.show_player_targets = not options.show_player_targets
					GameOptions.IDs.GAME_MAX_CIVILIANS: options.max_civilians -= 5
					GameOptions.IDs.GAME_MAX_DOGS: options.max_dogs -= 1
					GameOptions.IDs.GAME_MAX_UNDEADS: options.max_undeads -= 10
					GameOptions.IDs.GAME_DAY_ZERO_UNDEADS_PERCENT: options.day_zero_undeads_percent -= 5
					GameOptions.IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE: options.zombie_invasion_daily_increase -= 1
					GameOptions.IDs.GAME_CITY_SIZE: options.city_size -= 1
					GameOptions.IDs.GAME_NPC_CAN_STARVE_TO_DEATH: options.npc_can_starve_to_death = not options.npc_can_starve_to_death
					GameOptions.IDs.GAME_STARVED_ZOMBIFICATION_CHANCE: options.starved_zombification_chance -= 5
					GameOptions.IDs.GAME_SIMULATE_DISTRICTS:
						if options.simulate_districts != GameOptions.SimRatio.OFF:
							options.simulate_districts -= 1
					GameOptions.IDs.GAME_SIMULATE_SLEEP: options.simulate_when_sleeping = not options.simulate_when_sleeping
					GameOptions.IDs.GAME_TURBO_SIM: options.turbo_sim = not options.turbo_sim
					GameOptions.IDs.GAME_SIM_THREAD: options.sim_thread = not options.sim_thread
					GameOptions.IDs.GAME_ZOMBIFICATION_CHANCE: options.zombification_chance -= 5
					GameOptions.IDs.GAME_REVEAL_STARTING_DISTRICT: options.reveal_starting_district = not options.reveal_starting_district
					GameOptions.IDs.GAME_ALLOW_UNDEADS_EVOLUTION: options.allow_undeads_evolution = not options.allow_undeads_evolution
					GameOptions.IDs.GAME_UNDEADS_UPGRADE_DAYS:
						if options.zombifieds_upgrade_days != GameOptions.ZupDays._FIRST:
							options.zombifieds_upgrade_days -= 1
					GameOptions.IDs.GAME_MAX_REINCARNATIONS: options.max_reincarnations -= 1
					GameOptions.IDs.GAME_REINCARNATE_AS_RAT: options.can_reincarnate_as_rat = not options.can_reincarnate_as_rat
					GameOptions.IDs.GAME_REINCARNATE_TO_SEWERS: options.can_reincarnate_to_sewers = not options.can_reincarnate_to_sewers
					GameOptions.IDs.GAME_REINC_LIVING_RESTRICTED: options.is_living_reinc_restricted = not options.is_living_reinc_restricted
					GameOptions.IDs.GAME_PERMADEATH: options.is_permadeath_on = not options.is_permadeath_on
					GameOptions.IDs.GAME_DEATH_SCREENSHOT: options.is_death_screenshot_on = not options.is_death_screenshot_on
					GameOptions.IDs.GAME_AGGRESSIVE_HUNGRY_CIVILIANS: options.is_aggressive_hungry_civilians_on = not options.is_aggressive_hungry_civilians_on
					GameOptions.IDs.GAME_NATGUARD_FACTOR: options.nat_guard_factor -= 10
					GameOptions.IDs.GAME_SUPPLIESDROP_FACTOR: options.supplies_drop_factor -= 10
					GameOptions.IDs.GAME_RATS_UPGRADE: options.rats_upgrade = not options.rats_upgrade
					GameOptions.IDs.GAME_SHAMBLERS_UPGRADE: options.shamblers_upgrade = not options.shamblers_upgrade
					GameOptions.IDs.GAME_SKELETONS_UPGRADE: options.skeletons_upgrade = not options.skeletons_upgrade
					GameOptions.IDs.GAME_AUTOSAVE_PERIOD: options.auto_save_period_in_hours -= 12  # alpha10.1
			KEY_RIGHT:
				match list[selected]:
					GameOptions.IDs.GAME_DISTRICT_SIZE: options.district_size += 5
					GameOptions.IDs.UI_MUSIC: options.play_music = not options.play_music
					GameOptions.IDs.UI_MUSIC_VOLUME: options.music_volume += 5
					GameOptions.IDs.UI_ANIM_DELAY: options.is_anim_delay_on = not options.is_anim_delay_on
					GameOptions.IDs.UI_SHOW_MINIMAP: options.is_minimap_on = not options.is_minimap_on
					GameOptions.IDs.UI_SHOW_PLAYER_TAG_ON_MINIMAP: options.show_player_tags_on_minimap = not options.show_player_tags_on_minimap
					GameOptions.IDs.UI_ADVISOR: options.is_advisor_enabled = not options.is_advisor_enabled
					GameOptions.IDs.UI_COMBAT_ASSISTANT: options.is_combat_assistant_on = not options.is_combat_assistant_on
					GameOptions.IDs.UI_SHOW_TARGETS: options.show_targets = not options.show_targets
					GameOptions.IDs.UI_SHOW_PLAYER_TARGETS: options.show_player_targets = not options.show_player_targets
					GameOptions.IDs.GAME_MAX_CIVILIANS: options.max_civilians += 5
					GameOptions.IDs.GAME_MAX_DOGS: options.max_dogs += 1
					GameOptions.IDs.GAME_MAX_UNDEADS: options.max_undeads += 10
					GameOptions.IDs.GAME_DAY_ZERO_UNDEADS_PERCENT: options.day_zero_undeads_percent += 5
					GameOptions.IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE: options.zombie_invasion_daily_increase += 1
					GameOptions.IDs.GAME_CITY_SIZE: options.city_size += 1
					GameOptions.IDs.GAME_NPC_CAN_STARVE_TO_DEATH: options.npc_can_starve_to_death = not options.npc_can_starve_to_death
					GameOptions.IDs.GAME_STARVED_ZOMBIFICATION_CHANCE: options.starved_zombification_chance += 5
					GameOptions.IDs.GAME_SIMULATE_DISTRICTS:
						if options.simulate_districts != GameOptions.SimRatio.FULL:
							options.simulate_districts += 1
					GameOptions.IDs.GAME_SIMULATE_SLEEP: options.simulate_when_sleeping = not options.simulate_when_sleeping
					GameOptions.IDs.GAME_TURBO_SIM: options.turbo_sim = not options.turbo_sim
					GameOptions.IDs.GAME_SIM_THREAD: options.sim_thread = not options.sim_thread
					GameOptions.IDs.GAME_ZOMBIFICATION_CHANCE: options.zombification_chance += 5
					GameOptions.IDs.GAME_REVEAL_STARTING_DISTRICT: options.reveal_starting_district = not options.reveal_starting_district
					GameOptions.IDs.GAME_ALLOW_UNDEADS_EVOLUTION: options.allow_undeads_evolution = not options.allow_undeads_evolution
					GameOptions.IDs.GAME_UNDEADS_UPGRADE_DAYS:
						if options.zombifieds_upgrade_days != GameOptions.ZupDays._COUNT - 1:
							options.zombifieds_upgrade_days += 1
					GameOptions.IDs.GAME_MAX_REINCARNATIONS: options.max_reincarnations += 1
					GameOptions.IDs.GAME_REINCARNATE_AS_RAT: options.can_reincarnate_as_rat = not options.can_reincarnate_as_rat
					GameOptions.IDs.GAME_REINCARNATE_TO_SEWERS: options.can_reincarnate_to_sewers = not options.can_reincarnate_to_sewers
					GameOptions.IDs.GAME_REINC_LIVING_RESTRICTED: options.is_living_reinc_restricted = not options.is_living_reinc_restricted
					GameOptions.IDs.GAME_PERMADEATH: options.is_permadeath_on = not options.is_permadeath_on
					GameOptions.IDs.GAME_DEATH_SCREENSHOT: options.is_death_screenshot_on = not options.is_death_screenshot_on
					GameOptions.IDs.GAME_AGGRESSIVE_HUNGRY_CIVILIANS: options.is_aggressive_hungry_civilians_on = not options.is_aggressive_hungry_civilians_on
					GameOptions.IDs.GAME_NATGUARD_FACTOR: options.nat_guard_factor += 10
					GameOptions.IDs.GAME_SUPPLIESDROP_FACTOR: options.supplies_drop_factor += 10
					GameOptions.IDs.GAME_RATS_UPGRADE: options.rats_upgrade = not options.rats_upgrade
					GameOptions.IDs.GAME_SHAMBLERS_UPGRADE: options.shamblers_upgrade = not options.shamblers_upgrade
					GameOptions.IDs.GAME_SKELETONS_UPGRADE: options.skeletons_upgrade = not options.skeletons_upgrade
					GameOptions.IDs.GAME_AUTOSAVE_PERIOD: options.auto_save_period_in_hours += 12  # alpha10.1

		# force some options combinations.
		if options.sim_thread:
			options.simulate_when_sleeping = false
		# apply options.
		apply_options(false)

	# save.
	save_options()


func handle_redefine_keys() -> void:
	var loop := true
	var selected := 0
	var conflict := false
	while loop:
		# check for conflict.
		conflict = key_bindings.check_for_conflict()

		# draw
		var menu_entries: Array = [
			"Move N",
			"Move NE",
			"Move E",
			"Move SE",
			"Move S",
			"Move SW",
			"Move W",
			"Move NW",
			"Wait",
			"Wait 1 hour",
			"Abandon Game",
			"Advisor Hint",
			"Barricade",
			"Break",
			"Build Large Fortification",
			"Build Small Fortification",
			"City Info",
			"Close",
			"Fire",
			"Give",
			"Help",
			"Hints screen",
			"Negociate Trade",
			"Item 1 slot",
			"Item 2 slot",
			"Item 3 slot",
			"Item 4 slot",
			"Item 5 slot",
			"Item 6 slot",
			"Item 7 slot",
			"Item 8 slot",
			"Item 9 slot",
			"Item 10 slot",
			"Lead",
			"Load Game",
			"Mark Enemies",
			"Messages Log",
			"Options",
			"Order",
			"Pull",  # alpha10
			"Push",
			"Quit Game",
			"Redefine Keys",
			"Run",
			"Save Game",
			"Screenshot",
			"Shout",
			"Sleep",
			"Switch Place",
			"Use Exit",
			"Use Spray",
		]
		const O_MOVE_N := 0
		const O_MOVE_NE := 1
		const O_MOVE_E := 2
		const O_MOVE_SE := 3
		const O_MOVE_S := 4
		const O_MOVE_SW := 5
		const O_MOVE_W := 6
		const O_MOVE_NW := 7
		const O_WAIT := 8
		const O_WAIT_LONG := 9
		const O_ABANDON := 10
		const O_ADVISOR := 11
		const O_BARRICADE := 12
		const O_BREAK := 13
		const O_BUILD_LARGE_F := 14
		const O_BUILD_SMALL_F := 15
		const O_CITYINFO := 16
		const O_CLOSE := 17
		const O_FIRE := 18
		const O_GIVE := 19
		const O_HELP := 20
		const O_HINTS_SCREEN := 21
		const O_INIT_TRADE := 22
		const O_ITEM_1 := 23
		const O_ITEM_2 := 24
		const O_ITEM_3 := 25
		const O_ITEM_4 := 26
		const O_ITEM_5 := 27
		const O_ITEM_6 := 28
		const O_ITEM_7 := 29
		const O_ITEM_8 := 30
		const O_ITEM_9 := 31
		const O_ITEM_10 := 32
		const O_LEAD := 33
		const O_LOAD := 34
		const O_MARKENEMY := 35
		const O_LOG := 36
		const O_OPTIONS := 37
		const O_ORDER := 38
		const O_PULL := 39  # alpha10 inserted and shifted all below
		const O_PUSH := 40
		const O_QUIT := 41
		const O_REDEFKEYS := 42
		const O_RUN := 43
		const O_SAVE := 44
		const O_SCREENSHOT := 45
		const O_SHOUT := 46
		const O_SLEEP := 47
		const O_SWITCH := 48
		const O_USE_EXIT := 49
		const O_USE_SPRAY := 50
		var values: Array = [
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_N)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_NE)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_E)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_SE)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_S)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_SW)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_W)),
			str(key_bindings.get_key(PlayerCommand.Command.MOVE_NW)),
			str(key_bindings.get_key(PlayerCommand.Command.WAIT_OR_SELF)),
			str(key_bindings.get_key(PlayerCommand.Command.WAIT_LONG)),
			str(key_bindings.get_key(PlayerCommand.Command.ABANDON_GAME)),
			str(key_bindings.get_key(PlayerCommand.Command.ADVISOR)),
			str(key_bindings.get_key(PlayerCommand.Command.BARRICADE_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.BREAK_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.BUILD_LARGE_FORTIFICATION)),
			str(key_bindings.get_key(PlayerCommand.Command.BUILD_SMALL_FORTIFICATION)),
			str(key_bindings.get_key(PlayerCommand.Command.CITY_INFO)),
			str(key_bindings.get_key(PlayerCommand.Command.CLOSE_DOOR)),
			str(key_bindings.get_key(PlayerCommand.Command.FIRE_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.GIVE_ITEM)),
			str(key_bindings.get_key(PlayerCommand.Command.HELP_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.HINTS_SCREEN_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.NEGOCIATE_TRADE)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_0)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_1)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_2)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_3)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_4)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_5)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_6)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_7)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_8)),
			str(key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_9)),
			str(key_bindings.get_key(PlayerCommand.Command.LEAD_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.LOAD_GAME)),
			str(key_bindings.get_key(PlayerCommand.Command.MARK_ENEMIES_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.MESSAGE_LOG)),
			str(key_bindings.get_key(PlayerCommand.Command.OPTIONS_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.ORDER_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.PULL_MODE)),  # alpha10
			str(key_bindings.get_key(PlayerCommand.Command.PUSH_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.QUIT_GAME)),
			str(key_bindings.get_key(PlayerCommand.Command.KEYBINDING_MODE)),
			str(key_bindings.get_key(PlayerCommand.Command.RUN_TOGGLE)),
			str(key_bindings.get_key(PlayerCommand.Command.SAVE_GAME)),
			str(key_bindings.get_key(PlayerCommand.Command.SCREENSHOT)),
			str(key_bindings.get_key(PlayerCommand.Command.SHOUT)),
			str(key_bindings.get_key(PlayerCommand.Command.SLEEP)),
			str(key_bindings.get_key(PlayerCommand.Command.SWITCH_PLACE)),
			str(key_bindings.get_key(PlayerCommand.Command.USE_EXIT)),
			str(key_bindings.get_key(PlayerCommand.Command.USE_SPRAY)),
		]

		var gx := 0
		var gy := 0
		ui.ui_clear(Color.BLACK)
		draw_header()
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Redefine keys", 0, gy)
		gy += BOLD_LINE_SPACING
		gy = draw_menu_or_options(selected, Color.WHITE, menu_entries, Color.LIGHT_GREEN, values, gx, gy)
		if conflict:
			ui.ui_draw_string_bold(Color.RED, "Conflicting keys. Please redefine the keys so the commands don't overlap.", gx, gy)
			gy += BOLD_LINE_SPACING
		draw_footnote(Color.WHITE, "cursor to move, ENTER to rebind a key, ESC to save and leave")
		ui.ui_repaint()

		# handle get menu action.
		var key: InputEventKey = ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = menu_entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % menu_entries.size()
			KEY_ESCAPE:  # leave.
				if not conflict:
					loop = false
			KEY_ENTER:  # rebind
				# say.
				ui.ui_draw_string_bold(Color.YELLOW, "rebinding %s, press the new key." % [menu_entries[selected]], gx, gy)
				ui.ui_repaint()

				# read new key.
				var loop_new_key := true
				var new_key_data := KEY_NONE
				while loop_new_key:
					var new_key: InputEventKey = ui.ui_wait_key()
					# ignore Shift and Control alone.
					if new_key.keycode == KEY_SHIFT or new_key.keycode == KEY_CTRL:
						continue
					# always ignore Alt.
					if new_key.alt_pressed:
						continue
					# done!
					new_key_data = new_key.keycode
					loop_new_key = false

				# get command.
				var command: PlayerCommand.Command
				match selected:
					O_MOVE_N: command = PlayerCommand.Command.MOVE_N
					O_MOVE_NE: command = PlayerCommand.Command.MOVE_NE
					O_MOVE_E: command = PlayerCommand.Command.MOVE_E
					O_MOVE_SE: command = PlayerCommand.Command.MOVE_SE
					O_MOVE_S: command = PlayerCommand.Command.MOVE_S
					O_MOVE_SW: command = PlayerCommand.Command.MOVE_SW
					O_MOVE_W: command = PlayerCommand.Command.MOVE_W
					O_MOVE_NW: command = PlayerCommand.Command.MOVE_NW
					O_WAIT: command = PlayerCommand.Command.WAIT_OR_SELF
					O_WAIT_LONG: command = PlayerCommand.Command.WAIT_LONG
					O_ABANDON: command = PlayerCommand.Command.ABANDON_GAME
					O_ADVISOR: command = PlayerCommand.Command.ADVISOR
					O_BARRICADE: command = PlayerCommand.Command.BARRICADE_MODE
					O_BREAK: command = PlayerCommand.Command.BREAK_MODE
					O_BUILD_LARGE_F: command = PlayerCommand.Command.BUILD_LARGE_FORTIFICATION
					O_BUILD_SMALL_F: command = PlayerCommand.Command.BUILD_SMALL_FORTIFICATION
					O_CITYINFO: command = PlayerCommand.Command.CITY_INFO
					O_CLOSE: command = PlayerCommand.Command.CLOSE_DOOR
					O_FIRE: command = PlayerCommand.Command.FIRE_MODE
					O_GIVE: command = PlayerCommand.Command.GIVE_ITEM
					O_HELP: command = PlayerCommand.Command.HELP_MODE
					O_HINTS_SCREEN: command = PlayerCommand.Command.HINTS_SCREEN_MODE
					O_INIT_TRADE: command = PlayerCommand.Command.NEGOCIATE_TRADE
					O_ITEM_1: command = PlayerCommand.Command.ITEM_SLOT_0
					O_ITEM_2: command = PlayerCommand.Command.ITEM_SLOT_1
					O_ITEM_3: command = PlayerCommand.Command.ITEM_SLOT_2
					O_ITEM_4: command = PlayerCommand.Command.ITEM_SLOT_3
					O_ITEM_5: command = PlayerCommand.Command.ITEM_SLOT_4
					O_ITEM_6: command = PlayerCommand.Command.ITEM_SLOT_5
					O_ITEM_7: command = PlayerCommand.Command.ITEM_SLOT_6
					O_ITEM_8: command = PlayerCommand.Command.ITEM_SLOT_7
					O_ITEM_9: command = PlayerCommand.Command.ITEM_SLOT_8
					O_ITEM_10: command = PlayerCommand.Command.ITEM_SLOT_9
					O_LEAD: command = PlayerCommand.Command.LEAD_MODE
					O_LOAD: command = PlayerCommand.Command.LOAD_GAME
					O_MARKENEMY: command = PlayerCommand.Command.MARK_ENEMIES_MODE
					O_LOG: command = PlayerCommand.Command.MESSAGE_LOG
					O_OPTIONS: command = PlayerCommand.Command.OPTIONS_MODE
					O_ORDER: command = PlayerCommand.Command.ORDER_MODE
					O_PULL: command = PlayerCommand.Command.PULL_MODE  # alpha10
					O_PUSH: command = PlayerCommand.Command.PUSH_MODE
					O_QUIT: command = PlayerCommand.Command.QUIT_GAME
					O_REDEFKEYS: command = PlayerCommand.Command.KEYBINDING_MODE
					O_RUN: command = PlayerCommand.Command.RUN_TOGGLE
					O_SAVE: command = PlayerCommand.Command.SAVE_GAME
					O_SCREENSHOT: command = PlayerCommand.Command.SCREENSHOT
					O_SHOUT: command = PlayerCommand.Command.SHOUT
					O_SLEEP: command = PlayerCommand.Command.SLEEP
					O_SWITCH: command = PlayerCommand.Command.SWITCH_PLACE
					O_USE_EXIT: command = PlayerCommand.Command.USE_EXIT
					O_USE_SPRAY: command = PlayerCommand.Command.USE_SPRAY
					_:
						push_error("unhandled selected")

				# bind it.
				key_bindings.set_binding(command, new_key_data)

	# Save.
	save_keybindings()


## Advance play in district : could be player district (live district) or
## simulated district.
## NOTE: full port of AdvancePlay(District, SimFlags); replaces the simplified
## advance_play_district() stub in the rogue_game.gd skeleton (assembler must
## drop the stub to avoid a duplicate definition).
func advance_play_district(district: District, sim: int) -> void:
	# C# lock(district) dropped: single-threaded turn loop.
	# #if DEBUG_STATS block skipped.

	# 0. Remember if current district.
	var was_night: bool = session.world_time.is_night
	var prev_phase: WorldTime.DayPhase = session.world_time.phase

	# 1. Advance all maps.
	# if player quit/loaded at any time, don't bother!
	for map in district.maps:
		var prev_local_turn: int = map.local_time.turn_counter
		while true:
			# play this map.
			advance_play_map(map, sim)
			# check for reincarnation.
			if player.is_dead:
				handle_reincarnation()
			# check stopping game.
			if not is_game_running or has_loaded_game or player.is_dead:
				return
			# loop while the map's local turn has not advanced.
			if map.local_time.turn_counter != prev_local_turn:
				break

	# 2. Advance district.
	# 2.1. Advance world time if current district.
	# alpha10 also check weather change
	if district == session.current_map.district:
		session.world_time.turn_counter += 1

		# sunrise/sunset.
		var can_see_sky: bool = rules.can_actor_see_sky(player)  # alpha10 message only if can see sky
		var is_night: bool = session.world_time.is_night
		var new_phase: WorldTime.DayPhase = session.world_time.phase
		if was_night and not is_night:
			if can_see_sky:
				add_message(Message.new("The sun is rising again for you...", session.world_time.turn_counter, DAY_COLOR))
			on_new_day()
		elif not was_night and is_night:
			if can_see_sky:
				add_message(Message.new("Night is falling upon you...", session.world_time.turn_counter, NIGHT_COLOR))
			on_new_night()
		elif prev_phase != new_phase:
			if can_see_sky:
				add_message(Message.new("Time passes, it is now %s..." % [describe_day_phase(new_phase)], session.world_time.turn_counter, NIGHT_COLOR if is_night else DAY_COLOR))

		# alpha10: if time to change weather do it and roll next change time.
		if session.world_time.turn_counter >= session.world.next_weather_check_turn:
			change_weather()
			session.world.next_weather_check_turn = session.world_time.turn_counter + rules.roll(WEATHER_MIN_DURATION, WEATHER_MAX_DURATION)

	# 2.2. Check for events.
	# Entry/Surface map
	# 1 Invasion?
	if check_for_event_zombie_invasion(district.entry_map):
		fire_event_zombie_invasion(district.entry_map)
	# 2 Refugees?
	if check_for_event_refugees_wave(district.entry_map):
		fire_event_refugees_wave(district)
	# 3 National guard?
	if check_for_event_national_guard(district.entry_map):
		fire_event_national_guard(district.entry_map)
	# 4 Army drop supplies?
	if check_for_event_army_supplies(district.entry_map):
		fire_event_army_supplies(district.entry_map)
	# 5 Bikers raid?
	if check_for_event_bikers_raid(district.entry_map):
		fire_event_bikers_raid(district.entry_map)
	# 6 Gangsta raid?
	if check_for_event_gangstas_raid(district.entry_map):
		fire_event_gangstas_raid(district.entry_map)
	# 7 Blackops raid?
	if check_for_event_black_ops_raid(district.entry_map):
		fire_event_black_ops_raid(district.entry_map)
	# 8 Band of Survivors?
	if check_for_event_band_of_survivors(district.entry_map):
		fire_event_band_of_survivors(district.entry_map)

	# Sewers
	# 1 Sewers Invasion?
	if check_for_event_sewers_invasion(district.sewers_map):
		fire_event_sewers_invasion(district.sewers_map)

	# DISABLED Subway (#if false block skipped)

	# 3. Simulate nearby districts?
	# if player is sleeping in this map and option enabled.
	if options.is_sim_on and player != null and player.is_sleeping and options.simulate_when_sleeping and player.location.map.district == district:
		simulate_nearby_districts(district)


func notify_orderables_ai(map: Map, raid: int, position: Vector2i) -> void:
	for a in map.actors_list:
		var o_ai: OrderableAI = a.controller as OrderableAI
		if o_ai == null:
			continue
		o_ai.on_raid(raid, Location.new(map, position), map.local_time.turn_counter)


# NOTE: AdvancePlay(Map, SimFlags) and the Spend/Regen actor helpers are
# already ported in the rogue_game.gd skeleton (advance_play_map,
# spend_actor_action_points, spend_actor_stamina_points,
# regen_actor_stamina_points, regen_actor_hit_points, regen_actor_sleep) and
# are NOT re-declared here.

func spend_actor_sanity(actor: Actor, san_cost: int) -> void:
	actor.sanity -= san_cost
	if actor.sanity < 0:
		actor.sanity = 0


func regen_actor_sanity(actor: Actor, san_regen: int) -> void:
	actor.sanity = mini(rules.actor_max_sanity(actor), actor.sanity + san_regen)


func next_map_turn(map: Map, sim: int) -> void:
	var is_lo_detail: bool = (sim & (SimFlags.LODETAIL_TURN | SimFlags.TURBO_TURN)) != 0

	# (the following are skipped in lodetail turns)
	# 0. Raise the deads; Check infections (non STD)
	# 1. Update odors.
	# 2. Regen actors AP & STA
	# 3. Stop tired actors from running.
	# 4. Actor gauges & states
	# 5. Check batteries : lights, trackers.
	# 6. Check explosives.
	# 7. Check fires.
	# (the following are always performed)
	# - Check timers.
	# - Advance local time.
	# - Check for NPC upgrade.

	# #if false TEST CORPSES block skipped.
	if not is_lo_detail:
		# 0. Raise the deads; Check infections (non STD)
		var has_corpses: bool = Rules.has_corpses(session.game_mode)
		var has_infection: bool = Rules.has_infection(session.game_mode)
		if has_corpses or has_infection:
			# Corpses
			if has_corpses and map.count_corpses > 0:
				# decide who zombify or rots.
				var try_zombify_corpses: Array[Corpse] = []
				var rotten_corpses: Array[Corpse] = []
				for c in map.corpses_list:
					# zombify?
					var chance_zombify: int = rules.corpse_zombify_chance(c, map.local_time)
					if rules.roll_chance(chance_zombify):
						# zombify this one.
						try_zombify_corpses.append(c)
						continue
					# or rot away?
					inflict_damage_to_corpse(c, Rules.corpse_decay_per_turn(c))
					if c.hit_points <= 0:
						rotten_corpses.append(c)
						continue
				# zombify!
				if try_zombify_corpses.size() > 0:
					var zombified_corpses: Array[Corpse] = []
					for c in try_zombify_corpses:
						# only one actor per tile!
						if map.get_actor_at(c.position) == null:
							var corpse_state: float = 0.0 if c.max_hit_points <= 0 else c.hit_points / float(c.max_hit_points)
							var _zombified_hp: int = int(corpse_state * rules.actor_max_hps(c.dead_guy))
							zombified_corpses.append(c)
							# zombified_hp computed above; Zombify side effect spawns the actor
							var _zombified: Actor = zombify(null, c.dead_guy, false)

							if is_visible_to_player(map, c.position):
								add_message(Message.new("The corpse of %s rise again!!" % [c.dead_guy.name], map.local_time.turn_counter, Color.RED))
								# FIXME -- alpha10 this will be a sfx not music
								music_manager.play(GameSounds.UNDEAD_RISE, MusicPriority.PRIORITY_EVENT)
					for c in zombified_corpses:
						destroy_corpse(c, map)
				# rot! (message only)
				if player != null and player.location.map == map:
					for c in rotten_corpses:
						destroy_corpse(c, map)
						if is_visible_to_player(map, c.position):
							add_message(Message.new("The corpse of %s turns into dust." % [c.dead_guy.name], map.local_time.turn_counter, Color.PURPLE))

			# Infection effects
			if has_infection:
				var infected_to_kill: Array[Actor] = []
				for a in map.actors_list:
					if a.infection >= Rules.INFECTION_LEVEL_1_WEAK and not a.model.abilities.is_undead:
						var infection_p: int = rules.actor_infection_percent(a)

						if rules.roll(0, 1000) < rules.infection_effect_trigger_chance1000(infection_p):
							var is_visible: bool = is_visible_to_player(a)
							var is_player: bool = a.is_player  # alpha10.1 consistency fix
							var is_bot: bool = a.is_bot_player  # alpha10.1 handle bot

							# if sleeping, wake up.
							if a.is_sleeping:
								do_wake_up(a)

							# apply effect.
							var kill_him := false
							if infection_p >= Rules.INFECTION_LEVEL_5_DEATH:
								kill_him = true
							elif infection_p >= Rules.INFECTION_LEVEL_4_BLEED:
								do_vomit(a)
								a.hit_points -= Rules.INFECTION_LEVEL_4_BLEED_HP
								if is_visible:
									if is_player:
										clear_messages()
									add_message(make_message(a, "%s blood." % [conjugate(a, VERB_VOMIT)], Color.PURPLE))
									if is_player and not is_bot:
										add_message_press_enter()
										clear_messages()
								if a.hit_points <= 0:
									kill_him = true
							elif infection_p >= Rules.INFECTION_LEVEL_3_VOMIT:
								do_vomit(a)
								if is_visible:
									if is_player:
										clear_messages()
									add_message(make_message(a, "%s." % [conjugate(a, VERB_VOMIT)], Color.PURPLE))
									if is_player and not is_bot:
										add_message_press_enter()
										clear_messages()
							elif infection_p >= Rules.INFECTION_LEVEL_2_TIRED:
								spend_actor_stamina_points(a, Rules.INFECTION_LEVEL_2_TIRED_STA)
								a.sleep_points -= Rules.INFECTION_LEVEL_2_TIRED_SLP
								if a.sleep_points < 0:
									a.sleep_points = 0
								if is_visible:
									if is_player:
										clear_messages()
									add_message(make_message(a, "%s sick and tired." % [conjugate(a, VERB_FEEL)], Color.PURPLE))
									if is_player and not is_bot:
										add_message_press_enter()
										clear_messages()
							elif infection_p >= Rules.INFECTION_LEVEL_1_WEAK:
								spend_actor_stamina_points(a, Rules.INFECTION_LEVEL_1_WEAK_STA)
								if is_visible:
									if is_player:
										clear_messages()
									add_message(make_message(a, "%s sick and weak." % [conjugate(a, VERB_FEEL)], Color.PURPLE))
									if is_player and not is_bot:
										add_message_press_enter()
										clear_messages()

							# if it kills him, remember.
							if kill_him:
								infected_to_kill.append(a)

				# kill infected to kill (duh)
				if not infected_to_kill.is_empty():
					for a in infected_to_kill:
						if is_visible_to_player(a):
							add_message(make_message(a, "%s of infection!" % [conjugate(a, VERB_DIE)]))
						kill_actor(null, a, "infection")
						# if player, force zombify NOW.
						if a.is_player:
							# remove player corpse!
							map.try_remove_corpse_of(a)
							# zombify player!
							zombify(null, a, false)

							# show
							add_message(make_message(a, conjugate(a, "turn") + " into a Zombie!"))
							redraw_play_screen()
							anim_delay(DELAY_LONG)

		# 1. Update odors.
		# alpha10 obsolete 1.1 Odor suppression/generation (commented out in C#).

		# 1.2 Odors decay.
		var scent_garbage: Array = []

		# decay map scents
		for scent in map.scents:
			# alpha10
			var decay: int = rules.odors_decay(map, scent.position, session.world.weather)

			# decay.
			map.modify_scent_at(scent.odor, -decay, scent.position)

			# garbage?
			if scent.strength < Odor.OdorScent.MIN_STRENGTH:
				scent_garbage.append(scent)
		if not scent_garbage.is_empty():
			for scent in scent_garbage:
				map.remove_scent(scent)

		# 1.3 Actors scents.
		for actor in map.actors_list:
			# alpha10
			drop_actor_scents(actor)
			decay_actor_scents(actor)

		# 2. Regen actors AP & STA
		# regen.
		for actor in map.actors_list:
			if not actor.is_sleeping:
				actor.action_points += rules.actor_speed(actor)

			if actor.stamina_points < rules.actor_max_sta(actor):
				regen_actor_stamina_points(actor, Rules.STAMINA_REGEN_PER_TURN)
		# reset actor index.
		map.check_next_actor_index = 0

		# 3. Stop tired actors from running.
		for actor in map.actors_list:
			if actor.is_running:
				if actor.stamina_points < Rules.STAMINA_MIN_FOR_ACTIVITY:
					actor.is_running = false
					if actor == player:
						add_message(make_message(actor, "%s too tired to continue running!" % [conjugate(actor, VERB_BE)]))
						redraw_play_screen()

		# 4. Actor gauges & states
		var actors_starved_to_death: Array[Actor] = []
		for actor in map.actors_list:
			# hunger && rot.
			if actor.model.abilities.has_to_eat:
				# food points loss.
				actor.food_points -= 1
				if actor.food_points < 0:
					actor.food_points = 0

				# May kill starved actors.
				if rules.is_actor_starving(actor):
					# kill him?
					if rules.roll_chance(Rules.FOOD_STARVING_DEATH_CHANCE):
						if actor.is_player or options.npc_can_starve_to_death:
							actors_starved_to_death.append(actor)
			elif actor.model.abilities.is_rotting:
				# rot.
				actor.food_points -= 1
				if actor.food_points < 0:
					actor.food_points = 0

				# rot effects.
				if rules.is_rotting_actor_starving(actor):
					# loose 1 HP.
					if rules.roll(0, 1000) < Rules.ROT_STARVING_HP_CHANCE:
						if is_visible_to_player(actor):
							add_message(make_message(actor, "is rotting away."))
						actor.hit_points -= 1
						if actor.hit_points <= 0:
								actors_starved_to_death.append(actor)
				elif rules.is_rotting_actor_hungry(actor):
					# loose a skill.
					if rules.roll(0, 1000) < Rules.ROT_HUNGRY_SKILL_CHANCE:
						do_loose_random_skill(actor)

			# sleep.
			if actor.model.abilities.has_to_sleep:
				# sleep vs sleep points loss.
				if actor.is_sleeping:
					# sleeping.
					# nightmare?
					if rules.is_actor_disturbed(actor) and rules.roll_chance(Rules.SANITY_NIGHTMARE_CHANCE):
						# wake up, shout, lose sleep and sta.
						do_wake_up(actor)
						do_shout(actor, "NO! LEAVE ME ALONE!")
						actor.sleep_points -= Rules.SANITY_NIGHTMARE_SLP_LOSS
						if actor.sleep_points < 0:
							actor.sleep_points = 0
						spend_actor_sanity(actor, Rules.SANITY_NIGHTMARE_SAN_LOSS)
						spend_actor_stamina_points(actor, Rules.SANITY_NIGHTMARE_STA_LOSS)
						# msg.
						if is_visible_to_player(actor):
							add_message(make_message(actor, "%s from a horrible nightmare!" % [conjugate(actor, VERB_WAKE_UP)]))
						# if player, sfx.
						if actor.is_player:
							# FIXME replace with sfx alpha10
							music_manager.stop()
							music_manager.play(GameSounds.NIGHTMARE, MusicPriority.PRIORITY_EVENT)
				else:
					# awake.
					actor.sleep_points -= 1
					if map.local_time.is_night:
						actor.sleep_points -= 1
					if actor.sleep_points < 0:
						actor.sleep_points = 0

				# 4.2 Handle sleeping actors.
				if actor.is_sleeping:
					var is_on_couch: bool = rules.is_on_couch(actor)
					# activity.
					actor.activity = Activity.SLEEPING

					# regen sleep pts.
					var sleep_regen: int = rules.actor_sleep_regen(actor, is_on_couch)
					actor.sleep_points += sleep_regen
					actor.sleep_points = mini(actor.sleep_points, rules.actor_max_sleep(actor))

					# heal?
					if actor.hit_points < rules.actor_max_hps(actor):
						var heal_chance: int = Rules.SLEEP_ON_COUCH_HEAL_CHANCE if is_on_couch else 0
						heal_chance += rules.actor_heal_chance_bonus(actor)
						if rules.roll_chance(heal_chance):
							regen_actor_hit_points(actor, Rules.SLEEP_HEAL_HITPOINTS)

					# wake up?
					# wake up if hungry or fully slept.
					var wake_up: bool = rules.is_actor_hungry(actor) or actor.sleep_points >= rules.actor_max_sleep(actor)
					if wake_up:
						do_wake_up(actor)
					else:
						if actor.is_player:
							# check music.
							if music_manager.music != GameMusics.SLEEP:
								music_manager.stop()
								music_manager.play_looping(GameMusics.SLEEP, MusicPriority.PRIORITY_EVENT)
							# message.
							add_message(Message.new("...zzZZZzzZ...", map.local_time.turn_counter, Color.DARK_CYAN))
							redraw_play_screen()
							# give some time to sim thread. Godot port: no background
							# sim thread, drop Thread.Sleep(10).
						elif rules.roll_chance(MESSAGE_NPC_SLEEP_SNORE_CHANCE) and is_visible_to_player(actor):
							add_message(make_message(actor, "%s." % [conjugate(actor, VERB_SNORE)]))
							redraw_play_screen()

				# 4.3 Exhausted actors might collapse.
				if rules.is_actor_exhausted(actor):
					if rules.roll_chance(Rules.SLEEP_EXHAUSTION_COLLAPSE_CHANCE):
						# do it
						do_start_sleeping(actor)

						# message.
						if is_visible_to_player(actor):
							add_message(make_message(actor, "%s from exhaustion !!" % [conjugate(actor, VERB_COLLAPSE)]))
							redraw_play_screen()

						# player?
						if actor == player:
							update_player_fov(player)
							compute_view_rect(player.location.position)
							redraw_play_screen()

			# sanity.
			if actor.model.abilities.has_sanity:
				# sanity loss.
				actor.sanity -= 1
				if actor.sanity <= 0:
					actor.sanity = 0

			# leader trust & leader/follower bond.
			if actor.has_leader:
				# trust.
				modify_actor_trust_in_leader(actor, rules.actor_trust_increase(actor.leader), false)
				# bond with leader.
				if rules.has_actor_bond_with(actor, actor.leader) and rules.roll_chance(Rules.SANITY_RECOVER_BOND_CHANCE):
					regen_actor_sanity(actor, Rules.SANITY_RECOVER_BOND)
					regen_actor_sanity(actor.leader, Rules.SANITY_RECOVER_BOND)
					if is_visible_to_player(actor):
						add_message(make_message(actor, "%s reassured knowing %s is with %s." % [conjugate(actor, VERB_FEEL), actor.leader.name, him_or_her(actor)]))
					if is_visible_to_player(actor.leader):
						add_message(make_message(actor.leader, "%s reassured knowing %s is with %s." % [conjugate(actor.leader, VERB_FEEL), actor.name, him_or_her(actor.leader)]))

		# Kill (zombify) starved actors.
		if not actors_starved_to_death.is_empty():
			for actor in actors_starved_to_death:
				# message.
				if is_visible_to_player(actor):
					add_message(make_message(actor, "%s !!" % [conjugate(actor, VERB_DIE_FROM_STARVATION)]))
					redraw_play_screen()

				# kill.
				kill_actor(null, actor, "starvation")

				# zombify?
				if not actor.model.abilities.is_undead and Rules.has_immediate_zombification(session.game_mode) and rules.roll_chance(options.starved_zombification_chance):
					# remove morpse!
					map.try_remove_corpse_of(actor)
					# zombify!
					zombify(null, actor, false)
					# show.
					if is_visible_to_player(actor):
						add_message(make_message(actor, "%s into a Zombie!" % [conjugate(actor, "turn")]))
						redraw_play_screen()
						anim_delay(DELAY_LONG)

		# 5. Check batteries : lights, trackers.
		for actor in map.actors_list:
			var left_item: Item = actor.get_equipped_item(Doll.DollPart.LEFT_HAND)
			if left_item == null:
				continue

			# light?
			var light: ItemLight = left_item as ItemLight
			if light != null:
				if light.batteries > 0:
					light.batteries -= 1
					if light.batteries <= 0:
						if is_visible_to_player(actor):
							add_message(make_message(actor, ": %s light goes off." % [light.the_name]))
				continue

			# tracker?
			var tracker: ItemTracker = left_item as ItemTracker
			if tracker != null:
				if tracker.batteries > 0:
					tracker.batteries -= 1
					if tracker.batteries <= 0:
						if is_visible_to_player(actor):
							add_message(make_message(actor, ": %s goes off." % [tracker.the_name]))
				continue

		# 6. Check explosives.
		# 6.1 Update fuses.
		var has_explosives_to_explode := false
		# on ground.
		for ground_inv in map.aux_ground_items_list:
			# update each explosive fuse there,
			# remember which should explode.
			for it in ground_inv.items:
				var primed: ItemPrimedExplosive = it as ItemPrimedExplosive
				if primed == null:
					continue

				# primed explosive, burn fuse.
				primed.fuse_time_left -= 1
				if primed.fuse_time_left <= 0:
					has_explosives_to_explode = true

		# on actors.
		for actor in map.actors_list:
			var inv: Inventory = actor.inventory
			if inv == null or inv.is_empty:
				continue

			# update each explosive fuse there,
			# remember which should explode.
			for it in inv.items:
				var primed: ItemPrimedExplosive = it as ItemPrimedExplosive
				if primed == null:
					continue

				# primed explosive, burn fuse.
				primed.fuse_time_left -= 1
				if primed.fuse_time_left <= 0:
					has_explosives_to_explode = true

		# 6.2 Explode.
		if has_explosives_to_explode:
			var has_exploded_something := false
			while true:
				# nothing exploded by default.
				has_exploded_something = false

				# on ground.
				# Iterate over snapshots: do_blast() can remove ground inventories
				# and chain-react, mutating aux_ground_items_list and inv.items.
				if not has_exploded_something:
					for ground_inv in map.aux_ground_items_list.duplicate():
						var pos: Variant = map.get_ground_inventory_position(ground_inv)
						if pos == null:
							push_error("explosives : GetGroundInventoryPosition returned null point")
							continue

						for it in ground_inv.items.duplicate():
							var primed: ItemPrimedExplosive = it as ItemPrimedExplosive
							if primed == null:
								continue

							if primed.fuse_time_left <= 0:
								# boom!
								map.remove_item_at(primed, pos)
								do_blast(Location.new(map, pos), (primed.model as ItemExplosiveModel).blast_attack)
								has_exploded_something = true
								break

						if has_exploded_something:
							break

				# on actors.
				# Iterate over a snapshot: do_blast() -> kill_actor() -> remove_actor()
				# mutates map.actors_list mid-loop.
				if not has_exploded_something:
					for actor in map.actors_list.duplicate():
						var inv: Inventory = actor.inventory
						if inv == null or inv.is_empty:
							continue

						for it in inv.items.duplicate():
							var primed: ItemPrimedExplosive = it as ItemPrimedExplosive
							if primed == null:
								continue

							if primed.fuse_time_left <= 0:
								# boom!
								actor.inventory.remove_all_quantity(primed)
								do_blast(Location.new(map, actor.location.position), (primed.model as ItemExplosiveModel).blast_attack)
								has_exploded_something = true
								break

					if not has_exploded_something:
						break

		# 7. Check fires.
		# 7.1 Rain has a chance to put out fires.
		# FIXME there still the weather bug when simulating = weather used is current world weather, not map weather.
		# Check?
		if rules.is_weather_rain(session.world.weather) and rules.roll_chance(Rules.FIRE_RAIN_TEST_CHANCE):
			# 7.1.1 Burning objects?
			for obj in map.map_objects_list:
				if obj.is_on_fire and rules.roll_chance(Rules.FIRE_RAIN_PUT_OUT_CHANCE):
					# do it.
					unapply_on_fire(obj)
					# tell.
					if is_visible_to_player(obj):
						add_message(Message.new("The rain has put out a fire.", map.local_time.turn_counter))
# skipped in lodetail turns.

	# -- Check timers.
	if map.count_timers > 0:
		var timers_garbage: Array = []
		for t in map.timers:
			t.tick(map)
			if t.is_completed():
				timers_garbage.append(t)
		if not timers_garbage.is_empty():
			for t in timers_garbage:
				map.remove_timer(t)

	# -- Advance local time.
	var was_local_night: bool = map.local_time.is_night
	map.local_time.turn_counter += 1
	var is_local_day: bool = not map.local_time.is_night

	# -- Check for NPC upgrade.
	if was_local_night and is_local_day:
		handle_living_npcs_upgrade(map)
	elif options.zombifieds_upgrade_days != GameOptions.ZupDays.OFF and not was_local_night and not is_local_day and GameOptions.is_zup_day(options.zombifieds_upgrade_days, map.local_time.day):
		handle_undead_npcs_upgrade(map)


# alpha10
func drop_actor_scents(actor: Actor) -> void:
	# alpha10 dont drop if odor suppressed
	if actor.odor_suppressor_counter > 0:
		return

	if actor.model.abilities.is_undead:
		# ZM scent?
		if actor.model.abilities.is_undead_master:
			actor.location.map.refresh_scent_at(Odor.UNDEAD_MASTER, Rules.UNDEAD_MASTER_SCENT_DROP, actor.location.position)
	else:
		# Living scent.
		actor.location.map.refresh_scent_at(Odor.LIVING, Rules.LIVING_SCENT_DROP, actor.location.position)


# alpha10
func decay_actor_scents(actor: Actor) -> void:
	# decay suppressor
	if actor.odor_suppressor_counter > 0:
		var decay: int = rules.odors_decay(actor.location.map, actor.location.position, session.world.weather)
		actor.odor_suppressor_counter -= decay
		if actor.odor_suppressor_counter < 0:
			actor.odor_suppressor_counter = 0


func modify_actor_trust_in_leader(a: Actor, mod: int, add_message_: bool) -> void:
	# do it.
	a.trust_in_leader += mod
	if a.trust_in_leader > Rules.TRUST_MAX:
		a.trust_in_leader = Rules.TRUST_MAX
	elif a.trust_in_leader < Rules.TRUST_MIN:
		a.trust_in_leader = Rules.TRUST_MIN

	# if leader is player, message.
	if add_message_ and a.leader.is_player:
		add_message(Message.new("(%d trust with %s)" % [mod, a.the_name], session.world_time.turn_counter, Color.WHITE))




# Stats region (RogueGame.cs lines 4055-4152)

func count_livings(map: Map) -> int:
	assert(map != null)
	var count := 0
	for a in map.actors_list:
		if not a.model.abilities.is_undead:
			count += 1
	return count


func count_actors(map: Map, pred_fn: Callable) -> int:
	assert(map != null)
	var count := 0
	for a in map.actors_list:
		if pred_fn.call(a):
			count += 1
	return count


func count_faction(map: Map, f: Faction) -> int:
	assert(map != null)
	var count := 0
	for a in map.actors_list:
		if a.faction == f:
			count += 1
	return count


func count_undeads(map: Map) -> int:
	assert(map != null)
	var count := 0
	for a in map.actors_list:
		if a.model.abilities.is_undead:
			count += 1
	return count


func count_food_items_nutrition(map: Map) -> int:
	assert(map != null)
	# food items on ground.
	var ground_nutrition := 0
	for inv in map.ground_items_by_position.values():
		if inv.is_empty:
			continue
		for it in inv.items:
			if it is ItemFood:
				ground_nutrition += rules.food_item_nutrition(it as ItemFood, map.local_time.turn_counter)
	# food items carried by actors.
	var carried_nutrition := 0
	for a in map.actors_list:
		var inv: Inventory = a.inventory
		if inv == null or inv.is_empty:
			continue
		for it in inv.items:
			if it is ItemFood:
				carried_nutrition += rules.food_item_nutrition(it as ItemFood, map.local_time.turn_counter)
	return ground_nutrition + carried_nutrition


func has_actor_of_model_id(map: Map, actor_model_id: int) -> bool:
	assert(map != null)
	for a in map.actors_list:
		if a.model.id == actor_model_id:
			return true
	return false


# Events region
# Zombie Invasion
func check_for_event_zombie_invasion(map: Map) -> bool:
	# when midnight strikes only.
	if not map.local_time.is_strike_of_midnight:
		return false
	# if not enough zombies only.
	var undeads := count_undeads(map)
	if undeads >= options.max_undeads:
		return false
	# clear.
	return true


func fire_event_zombie_invasion(map: Map) -> void:
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		add_message(Message.new("It is Midnight! Zombies are invading!", session.world_time.turn_counter, Color.CRIMSON))
		redraw_play_screen()
	# do it.
	var undeads := count_undeads(map)
	var invasion_ratio := minf(1.0, (map.local_time.day * options.zombie_invasion_daily_increase + options.day_zero_undeads_percent) / 100.0)
	var target_undeads_count := 1 + int(invasion_ratio * options.max_undeads)
	var undeads_to_spawn := target_undeads_count - undeads
	for i in undeads_to_spawn:
		spawn_new_undead(map, map.local_time.day)


# Sewers Invasion
func check_for_event_sewers_invasion(map: Map) -> bool:
	# check game mode.
	if not Rules.has_zombies_in_sewers(session.game_mode):
		return false
	# randomly.
	if not rules.roll_chance(SEWERS_INVASION_CHANCE):
		return false
	# if not enough zombies only.
	var undeads := count_undeads(map)
	if undeads >= options.max_undeads * SEWERS_UNDEADS_FACTOR:
		return false
	# clear.
	return true


func fire_event_sewers_invasion(map: Map) -> void:
	# do it silently.
	var undeads := count_undeads(map)
	var invasion_ratio := minf(1.0, (map.local_time.day * options.zombie_invasion_daily_increase + options.day_zero_undeads_percent) / 100.0)
	var target_undeads_count := 1 + int(invasion_ratio * options.max_undeads * SEWERS_UNDEADS_FACTOR)
	var undeads_to_spawn := target_undeads_count - undeads
	for i in undeads_to_spawn:
		spawn_new_sewers_undead(map, map.local_time.day)


# DISABLED Subway Invasion (#if false in C#: skipped)

# Refugees wave
func check_for_event_refugees_wave(map: Map) -> bool:
	# when midday strikes only.
	if not map.local_time.is_strike_of_midday:
		return false
	# if not enough civs only. (#if false // TEST: disabled in C#: skipped)
	# clear.
	return true


## Double factor on city borders, half factor in city center, normal factor in all other districts.
func refugees_event_district_factor(d: District) -> float:
	var dx: int = d.world_position.x
	var dy: int = d.world_position.y
	var border: int = session.world.size - 1
	var center: int = border / 2
	return 2.0 if dx == 0 or dy == 0 or dx == border or dy == border else (0.5 if dx == center and dy == center else 1.0)


func fire_event_refugees_wave(district: District) -> void:
	# announce.
	if district == player.location.map.district and not player.is_sleeping and not player.model.abilities.is_undead:
		add_message(Message.new("A new wave of refugees has arrived!", session.world_time.turn_counter, Color.PINK))
		redraw_play_screen()
	# Spawn most on the surface and a small number in sewers and subway.
	var civilians := count_actors(district.entry_map, func(a: Actor) -> bool: return a.faction == game_factions.the_civilians() or a.faction == game_factions.the_police())
	var size := 1 + int(REFUGEES_WAVE_SIZE * refugees_event_district_factor(district) * options.max_civilians)
	var civilians_to_spawn := mini(size, options.max_civilians - civilians)
	var spawn_map: Map = null
	for i in civilians_to_spawn:
		# map: surface or sewers/subway.
		if rules.roll_chance(REFUGEE_SURFACE_SPAWN_CHANCE):
			spawn_map = district.entry_map
		else:
			# 50% sewers and 50% subway, but some districts have no subway.
			if district.has_subway():
				spawn_map = district.subway_map if rules.roll_chance(50) else district.sewers_map
			else:
				spawn_map = district.sewers_map
		# do it.
		spawn_new_refugee(spawn_map)
	# check for uniques, always in surface.
	if rules.roll_chance(UNIQUE_REFUGEE_CHECK_CHANCE):
		var array: Array = session.unique_actors.to_array()
		var may_arrive: Array = []
		for a in array:
			if a.is_with_refugees and not a.is_spawned and not a.the_actor.is_dead:
				may_arrive.append(a)
		if not may_arrive.is_empty():
			var i_arrive := rules.roll(0, may_arrive.size())
			fire_event_unique_actor_arrive(district.entry_map, may_arrive[i_arrive])


func fire_event_unique_actor_arrive(map: Map, unique: Session.UniqueActor) -> void:
	# try to find a spot.
	var spawned := spawn_actor_on_map_border(map, unique.the_actor, SPAWN_DISTANCE_TO_PLAYER, true)
	# if failed, cancel.
	if not spawned:
		return
	# mark as spawned.
	unique.is_spawned = true
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		play_unique_actor_music_and_message(unique, true)
		# scoring event.
		session.scoring.add_event(session.world_time.turn_counter, unique.the_actor.name + " arrived.")


# alpha10
func play_unique_actor_music_and_message(unique: Session.UniqueActor, has_arrived: bool) -> void:
	if unique.event_message != "":
		var highlight_overlay = null
		if unique.event_theme_music != "":
			music_manager.stop()
			music_manager.play(unique.event_theme_music, MusicPriority.PRIORITY_EVENT)
		clear_messages()
		add_message(Message.new(unique.event_message, session.world_time.turn_counter, Color.PINK))
		if has_arrived:
			add_message(make_player_centric_message("Seems to come from", unique.the_actor.location.position))
		else:
			highlight_overlay = OverlayRect.new(Color.PINK, Rect2i(map_to_screen(unique.the_actor.location.position.x, unique.the_actor.location.position.y), Vector2i(TILE_SIZE, TILE_SIZE)))
			add_overlay(highlight_overlay)
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
		if highlight_overlay != null:
			remove_overlay(highlight_overlay)


# National guard
func check_for_event_national_guard(map: Map) -> bool:
	# if option zeroed, don't bother.
	if options.nat_guard_factor == 0:
		return false
	# during day only.
	if map.local_time.is_night:
		return false
	# date.
	if map.local_time.day < NATGUARD_DAY:
		return false
	if map.local_time.day >= NATGUARD_END_DAY:
		return false
	# check chance.
	if not rules.roll_chance(NATGUARD_INTERVENTION_CHANCE):
		return false
	# if zombies significantly outnumber livings only (army count as 2 livings).
	var livings := count_livings(map) + count_faction(map, game_factions.the_army())
	var undeads := count_undeads(map)
	var undeads_per_living := float(undeads) / float(livings)
	if undeads_per_living * (options.nat_guard_factor / 100.0) < NATGUARD_INTERVENTION_FACTOR:
		return false
	# clear.
	return true


func fire_event_national_guard(map: Map) -> void:
	# do it.
	# spawn squad leader then troopers.
	var squad_leader := spawn_new_nat_guard_leader(map)
	if squad_leader != null:
		for i in NATGUARD_SQUAD_SIZE - 1:
			# spawn trooper.
			var trooper := spawn_new_nat_guard_trooper(map, squad_leader.location.position)
			# add to leader squad.
			if trooper != null:
				squad_leader.add_follower(trooper)
	if squad_leader == null:
		return
	# notify AI.
	notify_orderables_ai(map, Session.RaidType.NATGUARD, squad_leader.location.position)
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		# music.
		music_manager.stop()
		music_manager.play(GameMusics.ARMY, MusicPriority.PRIORITY_EVENT)
		# message.
		clear_messages()
		add_message(Message.new("A National Guard squad has arrived!", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(make_player_centric_message("Soldiers seem to come from", squad_leader.location.position))
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
	# scoring event.
	if map == player.location.map:
		session.scoring.add_event(session.world_time.turn_counter, "A National Guard squad arrived.")


# Army drop supplies
func check_for_event_army_supplies(map: Map) -> bool:
	# if option zeroed, don't bother.
	if options.supplies_drop_factor == 0:
		return false
	# during day only.
	if map.local_time.is_night:
		return false
	# date.
	if map.local_time.day < ARMY_SUPPLIES_DAY:
		return false
	# check chance.
	if not rules.roll_chance(ARMY_SUPPLIES_CHANCE):
		return false
	# count food items vs livings.
	var livings_need_food := 1 + count_actors(map, func(a: Actor) -> bool: return not a.model.abilities.is_undead and a.model.abilities.has_to_eat and a.faction == game_factions.the_civilians())
	var food := 1 + count_food_items_nutrition(map)
	var food_per_living := float(food) / float(livings_need_food)
	if food_per_living >= (options.supplies_drop_factor / 100.0) * ARMY_SUPPLIES_FACTOR:
		return false
	# clear.
	return true


func fire_event_army_supplies(map: Map) -> void:
	# 1. Pick drop point.
	# 2. Drop scattered items.
	var res := find_drop_supplies_point(map)
	if not res.ok:
		return
	var drop_point: Vector2i = res.point
	# 2. Drop scattered items.
	# only outside and free of actor and objects.
	var xmin := drop_point.x - ARMY_SUPPLIES_SCATTER
	var xmax := drop_point.x + ARMY_SUPPLIES_SCATTER
	var ymin := drop_point.y - ARMY_SUPPLIES_SCATTER
	var ymax := drop_point.y + ARMY_SUPPLIES_SCATTER
	var p := map.trim_to_bounds(xmin, ymin)
	xmin = p.x
	ymin = p.y
	p = map.trim_to_bounds(xmax, ymax)
	xmax = p.x
	ymax = p.y
	for sx in range(xmin, xmax + 1):
		for sy in range(ymin, ymax + 1):
			if not is_suitable_drop_supplies_point(map, sx, sy):
				continue
			# drop stuff.
			var it: Item = town_generator.make_item_army_ration() if rules.roll_chance(80) else town_generator.make_item_medikit()
			map.drop_item_at_xy(it, sx, sy)
	# notify AI.
	notify_orderables_ai(map, Session.RaidType.ARMY_SUPLLIES, drop_point)
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		# music.
		music_manager.stop()
		music_manager.play(GameMusics.ARMY, MusicPriority.PRIORITY_EVENT)
		# message.
		clear_messages()
		add_message(Message.new("An Army chopper has dropped supplies!", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(make_player_centric_message("The drop point seems to be", drop_point))
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
	# scoring event.
	if map == player.location.map:
		session.scoring.add_event(session.world_time.turn_counter, "An army chopper dropped supplies.")


func is_suitable_drop_supplies_point(map: Map, x: int, y: int) -> bool:
	# Must be:
	# 1. In bounds.
	# 2. Outside & walkable.
	# 3. No actor nor object.
	# 4. Far enough from player.
	# 1. In bounds.
	if not map.is_in_bounds(x, y):
		return false
	# 2. Outside & walkable.
	var tile := map.get_tile_at(x, y)
	if tile.is_inside or not tile.model.is_walkable:
		return false
	# 3. No actor nor object.
	if map.get_actor_at_xy(x, y) != null or map.get_map_object_at_xy(x, y) != null:
		return false
	# 4. Far enough from player.
	if distance_to_player(map, x, y) < SPAWN_DISTANCE_TO_PLAYER:
		return false
	# all clear.
	return true


# C# out Point -> Dictionary {"ok": bool, "point": Vector2i}
func find_drop_supplies_point(map: Map) -> Dictionary:
	var drop_point := Vector2i.ZERO
	# try to find a suitable point.
	var max_attempts := 4 * map.width
	for attempt in max_attempts:
		# roll.
		drop_point = Vector2i(rules.roll_x(map), rules.roll_y(map))
		# suitable?
		if not is_suitable_drop_supplies_point(map, drop_point.x, drop_point.y):
			continue
		# we're good.
		return {"ok": true, "point": drop_point}
	# failed
	return {"ok": false, "point": drop_point}


# Timed raids
func has_raid_happened_since(raid: int, district: District, map_time: WorldTime, since_n_turns: int) -> bool:
	return session.has_raid_happened(raid, district) and map_time.turn_counter - session.last_raid_time(raid, district) < since_n_turns


# Bikers raid
func check_for_event_bikers_raid(map: Map) -> bool:
	# date.
	if map.local_time.day < BIKERS_RAID_DAY:
		return false
	if map.local_time.day >= BIKERS_END_DAY:
		return false
	# last time : at least N day
	if has_raid_happened_since(Session.RaidType.BIKERS, map.district, map.local_time, BIKERS_RAID_DAYS_GAP * WorldTime.TURNS_PER_DAY):
		return false
	# check chance.
	if not rules.roll_chance(BIKERS_RAID_CHANCE_PER_TURN):
		return false
	# if no bikers. (#if false: disabled in C#: skipped)
	# clear.
	return true


func fire_event_bikers_raid(map: Map) -> void:
	# remember time.
	session.set_last_raid_time(Session.RaidType.BIKERS, map.district, map.local_time.turn_counter)
	# roll a random gang.
	var gang_id: int = GameGangs.BIKERS[rules.roll(0, GameGangs.BIKERS.size())]
	# do it.
	# spawn raid leader then squadies.
	var raid_leader := spawn_new_biker_leader(map, gang_id)
	if raid_leader != null:
		for i in BIKERS_RAID_SIZE - 1:
			# spawn squadie.
			var squadie := spawn_new_biker(map, gang_id, raid_leader.location.position)
			# add to leader squad.
			if squadie != null:
				raid_leader.add_follower(squadie)
	if raid_leader == null:
		return
	# notify AI.
	notify_orderables_ai(map, Session.RaidType.BIKERS, raid_leader.location.position)
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		# music.
		music_manager.stop()
		music_manager.play(GameMusics.BIKER, MusicPriority.PRIORITY_EVENT)
		# message.
		clear_messages()
		add_message(Message.new("You hear the sound of roaring engines!", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(make_player_centric_message("Motorbikes seem to come from", raid_leader.location.position))
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
	# scoring event.
	if map == player.location.map:
		session.scoring.add_event(session.world_time.turn_counter, "Bikers raided the district.")


# Gangsta raid
func check_for_event_gangstas_raid(map: Map) -> bool:
	# date.
	if map.local_time.day < GANGSTAS_RAID_DAY:
		return false
	if map.local_time.day >= GANGSTAS_END_DAY:
		return false
	# last time : at least N day
	if has_raid_happened_since(Session.RaidType.GANGSTA, map.district, map.local_time, GANGSTAS_RAID_DAYS_GAP * WorldTime.TURNS_PER_DAY):
		return false
	# check chance.
	if not rules.roll_chance(GANGSTAS_RAID_CHANCE_PER_TURN):
		return false
	# if no gangsta. (#if false: disabled in C#: skipped)
	# clear.
	return true


func fire_event_gangstas_raid(map: Map) -> void:
	# remember time.
	session.set_last_raid_time(Session.RaidType.GANGSTA, map.district, map.local_time.turn_counter)
	# roll a random gang.
	var gang_id: int = GameGangs.GANGSTAS[rules.roll(0, GameGangs.GANGSTAS.size())]
	# do it.
	# spawn raid leader then squadies.
	var raid_leader := spawn_new_gangsta_leader(map, gang_id)
	if raid_leader != null:
		for i in GANGSTAS_RAID_SIZE - 1:
			# spawn squadie.
			var squadie := spawn_new_gangsta(map, gang_id, raid_leader.location.position)
			# add to leader squad.
			if squadie != null:
				raid_leader.add_follower(squadie)
	if raid_leader == null:
		return
	# notify AI.
	notify_orderables_ai(map, Session.RaidType.GANGSTA, raid_leader.location.position)
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		# music.
		music_manager.stop()
		music_manager.play(GameMusics.GANGSTA, MusicPriority.PRIORITY_EVENT)
		# message.
		clear_messages()
		add_message(Message.new("You hear obnoxious loud music!", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(make_player_centric_message("Cars seem to come from", raid_leader.location.position))
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
	# scoring event.
	if map == player.location.map:
		session.scoring.add_event(session.world_time.turn_counter, "Gangstas raided the district.")


# BlackOps raid
func check_for_event_black_ops_raid(map: Map) -> bool:
	# date.
	if map.local_time.day < BLACKOPS_RAID_DAY:
		return false
	# last time : at least N day
	if has_raid_happened_since(Session.RaidType.BLACKOPS, map.district, map.local_time, BLACKOPS_RAID_DAY_GAP * WorldTime.TURNS_PER_DAY):
		return false
	# check chance.
	if not rules.roll_chance(BLACKOPS_RAID_CHANCE_PER_TURN):
		return false
	# clear.
	return true


func fire_event_black_ops_raid(map: Map) -> void:
	# remember time.
	session.set_last_raid_time(Session.RaidType.BLACKOPS, map.district, map.local_time.turn_counter)
	# do it.
	# spawn raid leader then squadies.
	var raid_leader := spawn_new_black_ops_leader(map)
	if raid_leader != null:
		for i in BLACKOPS_RAID_SIZE - 1:
			# spawn squadie.
			var squadie := spawn_new_black_ops_trooper(map, raid_leader.location.position)
			# add to leader squad.
			if squadie != null:
				raid_leader.add_follower(squadie)
	if raid_leader == null:
		return
	# notify AI.
	notify_orderables_ai(map, Session.RaidType.BLACKOPS, raid_leader.location.position)
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		# music.
		music_manager.stop()
		music_manager.play(GameMusics.ARMY, MusicPriority.PRIORITY_EVENT)
		# message.
		clear_messages()
		add_message(Message.new("You hear a chopper flying over the city!", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(make_player_centric_message("The chopper has dropped something", raid_leader.location.position))
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
	# scoring event.
	if map == player.location.map:
		session.scoring.add_event(session.world_time.turn_counter, "BlackOps raided the district.")


# Band of Survivors
func check_for_event_band_of_survivors(map: Map) -> bool:
	# date.
	if map.local_time.day < SURVIVORS_BAND_DAY:
		return false
	# last time : at least N day
	if has_raid_happened_since(Session.RaidType.SURVIVORS, map.district, map.local_time, SURVIVORS_BAND_DAY_GAP * WorldTime.TURNS_PER_DAY):
		return false
	# check chance.
	if not rules.roll_chance(SURVIVORS_BAND_CHANCE_PER_TURN):
		return false
	# clear.
	return true


func fire_event_band_of_survivors(map: Map) -> void:
	# remember time.
	session.set_last_raid_time(Session.RaidType.SURVIVORS, map.district, map.local_time.turn_counter)
	# do it.
	# spawn dudes.
	var band_scout := spawn_new_survivor(map)
	if band_scout != null:
		for i in SURVIVORS_BAND_SIZE - 1:
			spawn_new_survivor_near(map, band_scout.location.position)
	if band_scout == null:
		return
	# notify AI.
	notify_orderables_ai(map, Session.RaidType.SURVIVORS, band_scout.location.position)
	# announce.
	if map == player.location.map and not player.is_sleeping and not player.model.abilities.is_undead:
		# music.
		music_manager.stop()
		music_manager.play(GameMusics.SURVIVORS, MusicPriority.PRIORITY_EVENT)
		# message.
		clear_messages()
		add_message(Message.new("You hear shooting and honking in the distance.", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(make_player_centric_message("A van has stopped", band_scout.location.position))
		if not player.is_bot_player:
			add_message_press_enter()
			clear_messages()
	# scoring event.
	if map == player.location.map:
		session.scoring.add_event(session.world_time.turn_counter, "A Band of Survivors entered the district.")


# Spawning new actors region (RogueGame.cs lines 4945+)
func distance_to_player(map: Map, x: int, y: int) -> int:
	if player == null or player.location.map != map:
		return 2147483647
	return rules.grid_distance(player.location.position, x, y)


func distance_to_player_pos(map: Map, pos: Vector2i) -> int:
	return distance_to_player(map, pos.x, pos.y)


func is_adjacent_to_enemy(map: Map, pos: Vector2i, actor: Actor) -> bool:
	var xmin := pos.x - 1
	var xmax := pos.x + 1
	var ymin := pos.y - 1
	var ymax := pos.y + 1
	var p := map.trim_to_bounds(xmin, ymin)
	xmin = p.x
	ymin = p.y
	p = map.trim_to_bounds(xmax, ymax)
	xmax = p.x
	ymax = p.y
	for x in range(xmin, xmax + 1):
		for y in range(ymin, ymax + 1):
			if x == pos.x and y == pos.y:
				continue
			var other := map.get_actor_at_xy(x, y)
			if other == null:
				continue
			if rules.are_enemies(actor, other):
				return true
	return false


func spawn_actor_on_map_border(map: Map, actor_to_spawn: Actor, min_dist_to_player: int, must_be_outside: bool) -> bool:
	# find a good spot.
	var max_tries := 4 * (map.width + map.height)
	var pos := Vector2i.ZERO
	for i in range(1, max_tries + 1):
		# roll a position on the border.
		var x: int = 0 if rules.roll_chance(50) else map.width - 1
		var y: int = 0 if rules.roll_chance(50) else map.height - 1
		if rules.roll_chance(50):
			x = rules.roll_x(map)
		else:
			y = rules.roll_y(map)
		# must be free, (outside), far enough to player and not adjacent to an enemy.
		pos = Vector2i(x, y)
		if must_be_outside and map.get_tile_at(pos.x, pos.y).is_inside:
			continue
		if not rules.is_walkable_for(actor_to_spawn, map, pos.x, pos.y).ok:
			continue
		if distance_to_player_pos(map, pos) < min_dist_to_player:
			continue
		if is_adjacent_to_enemy(map, pos, actor_to_spawn):
			continue
		# success!
		map.place_actor_at(actor_to_spawn, pos)
		# trigger stuff
		on_actor_enter_tile(actor_to_spawn)
		return true
	# failed.
	return false


func spawn_actor_near(map: Map, actor_to_spawn: Actor, min_dist_to_player: int, near_point: Vector2i, max_dist_to_point: int) -> bool:
	# find a good spot.
	var max_tries := 4 * (map.width + map.height)
	var pos := Vector2i.ZERO
	for i in range(1, max_tries + 1):
		# roll a position.
		var x := near_point.x + rules.roll(1, max_dist_to_point + 1) - rules.roll(1, max_dist_to_point + 1)
		var y := near_point.y + rules.roll(1, max_dist_to_point + 1) - rules.roll(1, max_dist_to_point + 1)
		# trim to map.
		pos = map.trim_point_to_bounds(Vector2i(x, y))
		# must free, outside, far enough to player and not adjacent to an enemy.
		if map.get_tile_at(pos.x, pos.y).is_inside:
			continue
		if not rules.is_walkable_for(actor_to_spawn, map, pos.x, pos.y).ok:
			continue
		if distance_to_player_pos(map, pos) < min_dist_to_player:
			continue
		if is_adjacent_to_enemy(map, pos, actor_to_spawn):
			continue
		# success!
		map.place_actor_at(actor_to_spawn, pos)
		return true
	# failed.
	return false


func spawn_new_undead(map: Map, day: int) -> void:
	# Create actor.
	var new_undead: Actor = town_generator.create_new_undead(map.local_time.turn_counter)
	# Spawn hi level?
	if options.allow_undeads_evolution and Rules.has_evolution(session.game_mode):
		# chances.
		var levelup_chance := mini(75, day * 2)  # +2% per day, max 75%.
		var do_level_up := false
		var levelup_id: int = new_undead.model.id
		if rules.roll_chance(levelup_chance):
			do_level_up = true
			levelup_id = next_undead_evolution(new_undead.model.id)
			if rules.roll_chance(levelup_chance):
				levelup_id = next_undead_evolution(levelup_id)
		# restrict some models.
		if levelup_id == GameActors.IDs.UNDEAD_ZOMBIE_LORD and day < ZOMBIE_LORD_EVOLUTION_MIN_DAY:
			do_level_up = false
		# levelup?
		if do_level_up:
			new_undead.model = game_actors.get_model(levelup_id)
	# Try to spawn it.
	spawn_actor_on_map_border(map, new_undead, SPAWN_DISTANCE_TO_PLAYER, true)


func spawn_new_sewers_undead(map: Map, _day: int) -> void:
	# Create actor.
	var new_undead: Actor = town_generator.create_new_sewers_undead(map.local_time.turn_counter)
	# Try to spawn it.
	spawn_actor_on_map_border(map, new_undead, SPAWN_DISTANCE_TO_PLAYER, false)


func spawn_new_subway_undead(map: Map, _day: int) -> void:
	# Create actor.
	var new_undead: Actor = town_generator.create_new_subway_undead(map.local_time.turn_counter)
	# Try to spawn it.
	spawn_actor_on_map_border(map, new_undead, SPAWN_DISTANCE_TO_PLAYER, false)


func spawn_new_refugee(map: Map) -> void:
	# Create actor.
	var new_civilian: Actor = town_generator.create_new_refugee(map.local_time.turn_counter, REFUGEES_WAVE_ITEMS)
	# Try to spawn it.
	spawn_actor_on_map_border(map, new_civilian, SPAWN_DISTANCE_TO_PLAYER, true)


func spawn_new_survivor(map: Map) -> Actor:
	# Create actor.
	var new_survivor: Actor = town_generator.create_new_survivor(map.local_time.turn_counter)
	# Try to spawn it.
	if spawn_actor_on_map_border(map, new_survivor, SPAWN_DISTANCE_TO_PLAYER, true):
		return new_survivor
	else:
		return null


# C# overload SpawnNewSurvivor(Map, Point bandPos)
func spawn_new_survivor_near(map: Map, band_pos: Vector2i) -> Actor:
	# Create actor.
	var new_survivor: Actor = town_generator.create_new_survivor(map.local_time.turn_counter)
	# Try to spawn it.
	if spawn_actor_near(map, new_survivor, SPAWN_DISTANCE_TO_PLAYER, band_pos, 3):
		return new_survivor
	else:
		return null


func spawn_new_nat_guard_leader(map: Map) -> Actor:
	# Create actor.
	var new_nat_leader: Actor = town_generator.create_new_army_national_guard(map.local_time.turn_counter, "Sgt")
	# skills.
	town_generator.give_starting_skill_to_actor(new_nat_leader, Skills.IDs.LEADERSHIP)
	# additional items : z-tracker.
	if map.local_time.day > NATGUARD_ZTRACKER_DAY:
		new_nat_leader.inventory.add_all(town_generator.make_item_ztracker())
	# Try to spawn it.
	var spawned := spawn_actor_on_map_border(map, new_nat_leader, SPAWN_DISTANCE_TO_PLAYER, true)
	# done.
	return new_nat_leader if spawned else null


func spawn_new_nat_guard_trooper(map: Map, leader_pos: Vector2i) -> Actor:
	# Create actor.
	var new_nat_guard: Actor = town_generator.create_new_army_national_guard(map.local_time.turn_counter, "Pvt")
	# additional items : combat knife or grenades.
	if rules.roll_chance(50):
		new_nat_guard.inventory.add_all(town_generator.make_item_combat_knife())
	else:
		new_nat_guard.inventory.add_all(town_generator.make_item_grenade())
	# Try to spawn it.
	var spawned := spawn_actor_near(map, new_nat_guard, SPAWN_DISTANCE_TO_PLAYER, leader_pos, 3)
	# done.
	return new_nat_guard if spawned else null


func spawn_new_biker_leader(map: Map, gang_id: int) -> Actor:
	# Create actor.
	var new_biker_leader: Actor = town_generator.create_new_biker_man(map.local_time.turn_counter, gang_id)
	# skills.
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.LEADERSHIP)
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.TOUGH)
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.TOUGH)
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.TOUGH)
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.STRONG)
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.STRONG)
	town_generator.give_starting_skill_to_actor(new_biker_leader, Skills.IDs.STRONG)
	# Try to spawn it.
	var spawned := spawn_actor_on_map_border(map, new_biker_leader, SPAWN_DISTANCE_TO_PLAYER, true)
	# done.
	return new_biker_leader if spawned else null


func spawn_new_biker(map: Map, gang_id: int, leader_pos: Vector2i) -> Actor:
	# Create actor.
	var new_biker: Actor = town_generator.create_new_biker_man(map.local_time.turn_counter, gang_id)
	# skils.
	town_generator.give_starting_skill_to_actor(new_biker, Skills.IDs.TOUGH)
	town_generator.give_starting_skill_to_actor(new_biker, Skills.IDs.STRONG)
	# Try to spawn it.
	var spawned := spawn_actor_near(map, new_biker, SPAWN_DISTANCE_TO_PLAYER, leader_pos, 3)
	# done.
	return new_biker if spawned else null


func spawn_new_gangsta_leader(map: Map, gang_id: int) -> Actor:
	# Create actor.
	var new_gangsta_leader: Actor = town_generator.create_new_gangsta_man(map.local_time.turn_counter, gang_id)
	# skills.
	town_generator.give_starting_skill_to_actor(new_gangsta_leader, Skills.IDs.LEADERSHIP)
	town_generator.give_starting_skill_to_actor(new_gangsta_leader, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_gangsta_leader, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_gangsta_leader, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_gangsta_leader, Skills.IDs.FIREARMS)
	# Try to spawn it.
	var spawned := spawn_actor_on_map_border(map, new_gangsta_leader, SPAWN_DISTANCE_TO_PLAYER, true)
	# done.
	return new_gangsta_leader if spawned else null


func spawn_new_gangsta(map: Map, gang_id: int, leader_pos: Vector2i) -> Actor:
	# Create actor.
	var new_gangsta: Actor = town_generator.create_new_gangsta_man(map.local_time.turn_counter, gang_id)
	# skils.
	town_generator.give_starting_skill_to_actor(new_gangsta, Skills.IDs.AGILE)
	# Try to spawn it.
	var spawned := spawn_actor_near(map, new_gangsta, SPAWN_DISTANCE_TO_PLAYER, leader_pos, 3)
	# done.
	return new_gangsta if spawned else null


func spawn_new_black_ops_leader(map: Map) -> Actor:
	# Create actor.
	var new_bo_leader: Actor = town_generator.create_new_black_ops(map.local_time.turn_counter, "Officer")
	# skills.
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.LEADERSHIP)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.FIREARMS)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.FIREARMS)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.FIREARMS)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.TOUGH)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.TOUGH)
	town_generator.give_starting_skill_to_actor(new_bo_leader, Skills.IDs.TOUGH)
	# Try to spawn it.
	var spawned := spawn_actor_on_map_border(map, new_bo_leader, SPAWN_DISTANCE_TO_PLAYER, true)
	# done.
	return new_bo_leader if spawned else null


func spawn_new_black_ops_trooper(map: Map, leader_pos: Vector2i) -> Actor:
	# Create actor.
	var new_bo: Actor = town_generator.create_new_black_ops(map.local_time.turn_counter, "Agent")
	# skills.
	town_generator.give_starting_skill_to_actor(new_bo, Skills.IDs.AGILE)
	town_generator.give_starting_skill_to_actor(new_bo, Skills.IDs.FIREARMS)
	town_generator.give_starting_skill_to_actor(new_bo, Skills.IDs.TOUGH)
	# Try to spawn it.
	var spawned := spawn_actor_near(map, new_bo, SPAWN_DISTANCE_TO_PLAYER, leader_pos, 3)
	# done.
	return new_bo if spawned else null


# Updating Player FOV region (RogueGame.cs lines 5367-5375)
func update_player_fov(player_actor: Actor) -> void:
	if player_actor == null:
		return
	player_fov = LOS.compute_fov_for(rules, player_actor, session.world_time, session.world.weather)
	player_actor.location.map.set_view_and_mark_visited(player_fov.keys())


# Port of RogueGame.cs lines 5378-5445: Experimental Bot Mode.
# C# wrapped this region in `#if DEBUG`; kept here (experimental feature).
# No threads in the Godot port, so the C# m_botLock is dropped.

var is_bot_mode: bool = false
var bot_control: BaseAI = null
const BOT_DELAY := 250  # == DELAY_SHORT (const refs to sibling consts fail standalone parse)


func bot_toggle_control() -> void:
	if is_bot_mode:
		bot_release_control()
	else:
		bot_take_control()


func bot_take_control() -> void:
	# bot restrictions check
	if player == null or player.is_dead:
		add_message(make_error_message("Bot cannot take control of null/dead player"))
		return

	if bot_control != null:
		bot_control.leave_control()

	# C# used reflection (DefaultController type + Activator); the Godot port
	# stores the controller script on the model and instantiates it directly.
	var ai_controller: ActorController = player.model.instanciate_controller()
	if ai_controller == null or not (ai_controller is BaseAI):
		clear_messages()
		add_message(make_error_message("error while creating bot ai:"))
		add_message(make_error_message("actor model has null defaultcontroller or is not BaseAI"))
		add_message_press_enter()
		return

	bot_control = ai_controller as BaseAI
	bot_control.take_control(player)
	player.is_bot_player = true
	is_bot_mode = true
	add_message(make_message(player, "is now bot controlled by %s." % bot_control.get_script().get_global_name(), Color.LIGHT_GREEN))


func bot_release_control() -> void:
	if bot_control == null:
		return
	if player != null:
		player.is_bot_player = false
	bot_control.leave_control()
	bot_control = null
	is_bot_mode = false
	if player != null:
		add_message(make_message(player, "is now human controlled.", Color.LIGHT_GREEN))


# Port of RogueGame.cs lines 5449-6113: Handling Player actor action.


func handle_player_actor(p_player: Actor) -> void:
	# Upkeep.
	update_player_fov(p_player)  # make sure LOS is up to date
	player = p_player  # remember player
	compute_view_rect(p_player.location.position)

	# Update survival scoring.
	session.scoring.turns_survived = session.world_time.turn_counter

	# Check if long wait.
	if is_player_long_wait:
		if check_player_wait_long(p_player):
			# continue waiting.
			do_wait(p_player)
			return
		else:
			# stop long wait.
			is_player_long_wait = false
			is_player_long_wait_forced_stop = false
			# wait ended or interrupted.
			if session.world_time.turn_counter >= player_long_wait_end.turn_counter:
				add_message(Message.new("Wait ended.", session.world_time.turn_counter, Color.YELLOW))
			else:
				add_message(Message.new("Wait interrupted!", session.world_time.turn_counter, Color.RED))

	# Loop until the player has made a valid choice
	var loop := true
	while loop:
		# 1. Redraw
		ui.ui_set_cursor(null)

		# alpha10.1 bot mode? (C# #if DEBUG)
		if is_bot_mode:
			ui.ui_wait(BOT_DELAY)  # C# Thread.Sleep(BOT_DELAY)
			redraw_play_screen()
			if bot_control != null:
				var bot_action: ActorAction = bot_control.get_action(self)
				if bot_action == null or not bot_action.is_legal():
					add_message(make_error_message("Bot issued %s action" % ("NULL" if bot_action == null else "illegal " + str(bot_action))))
					bot_action = ActionWait.new(p_player, self)
				bot_action.perform()
				# copy-paste is bad
				update_player_fov(p_player)
				compute_view_rect(p_player.location.position)
				session.last_turn_player_acted = session.world_time.turn_counter
				redraw_play_screen()
			return

		# hint available?
		# alpha10 no hint if undead
		if player != null and not player.is_dead and not player.model.abilities.is_undead:
			# alpha10 fix properly handle hint overlay
			var available_hint := -1
			if options.is_advisor_enabled:
				available_hint = get_advisor_first_available_hint()
			if available_hint != -1:
				var overlay_pos: Vector2i = map_to_screen(p_player.location.position.x - 3, p_player.location.position.y - 1)
				# TODO: OverlayPopup inner class is ported by the range covering RogueGame.cs lines 452-644
				if hint_available_overlay == null:
					hint_available_overlay = OverlayPopup.new(
						[],
						Color.WHITE, Color.WHITE, Color.BLACK,
						overlay_pos)
					add_overlay(hint_available_overlay)
				else:
					hint_available_overlay.screen_position = overlay_pos
					if not has_overlay(hint_available_overlay):
						add_overlay(hint_available_overlay)

				var hint_text: Dictionary = get_advisor_hint_text(available_hint)
				var hint_title: String = hint_text["title"]
				hint_available_overlay.lines = [
					"HINT AVAILABLE PRESS <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.ADVISOR)),
					hint_title]
			elif hint_available_overlay != null and has_overlay(hint_available_overlay):
				remove_overlay(hint_available_overlay)
		redraw_play_screen()

		# 2. Get input.
		# Peek keyboard & mouse until we got an event.
		ui.ui_peek_key()  # consume keys to avoid repeats
		var input_loop := true
		var has_key := false
		var in_key: InputEventKey = null
		var prev_mouse_pos: Vector2i = ui.ui_get_mouse_position()
		var mouse_pos := Vector2i(-1, -1)
		var mouse_buttons := 0  # C# MouseButtons? ; 0 == none in the Godot UI
		while input_loop:
			in_key = ui.ui_peek_key()
			if in_key != null:
				has_key = true
				input_loop = false
			else:
				mouse_pos = ui.ui_get_mouse_position()
				mouse_buttons = ui.ui_peek_mouse_buttons()
				if mouse_pos != prev_mouse_pos or mouse_buttons != 0:
					input_loop = false
				else:
					# No input yet: yield briefly instead of busy-spinning on
					# the game thread (C# UI_PeekKey pumped the WinForms
					# message loop; a 1ms sleep is the Godot equivalent).
					ui.ui_wait(1)

		# 3. Handle input
		if has_key:
			# Handle key
			var command: int = InputTranslator.key_to_command(in_key)
			if command == PlayerCommand.Command.QUIT_GAME:  # quit game
				if handle_quit_game():
					# quit asap.
					redraw_play_screen()
					is_game_running = false
					return
			else:
				match command:
					# options, menu etc...
					PlayerCommand.Command.ABANDON_GAME:
						if handle_abandon_game():
							loop = false
							kill_actor(null, player, "suicide")
					PlayerCommand.Command.HELP_MODE:
						handle_help_mode()
					PlayerCommand.Command.HINTS_SCREEN_MODE:
						handle_hints_screen()
					PlayerCommand.Command.ADVISOR:
						handle_advisor(p_player)
					PlayerCommand.Command.OPTIONS_MODE:
						handle_options(true)
						apply_options(true)
					PlayerCommand.Command.KEYBINDING_MODE:
						handle_redefine_keys()
					PlayerCommand.Command.MESSAGE_LOG:
						handle_message_log()
					PlayerCommand.Command.LOAD_GAME:
						# load.
						handle_load_game()
						# refresh player local variable!!
						p_player = player
						# stop looping.
						loop = false
						# stop the update loop!
						has_loaded_game = true
					PlayerCommand.Command.SAVE_GAME:
						handle_save_game()
					PlayerCommand.Command.SCREENSHOT:
						handle_screenshot()
					PlayerCommand.Command.CITY_INFO:
						handle_city_info()
					# actual game actions.
					PlayerCommand.Command.WAIT_OR_SELF:
						loop = false
						if not try_player_insanity():
							do_wait(p_player)
					PlayerCommand.Command.WAIT_LONG:
						loop = false
						if not try_player_insanity():
							start_player_wait_long(p_player)
					PlayerCommand.Command.MOVE_N:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.N)
					PlayerCommand.Command.MOVE_NE:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.NE)
					PlayerCommand.Command.MOVE_E:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.E)
					PlayerCommand.Command.MOVE_SE:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.SE)
					PlayerCommand.Command.MOVE_S:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.S)
					PlayerCommand.Command.MOVE_SW:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.SW)
					PlayerCommand.Command.MOVE_W:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.W)
					PlayerCommand.Command.MOVE_NW:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_bump(p_player, Direction.NW)
					PlayerCommand.Command.USE_EXIT:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_use_exit(p_player, p_player.location.position)
					PlayerCommand.Command.ITEM_SLOT_0:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 0, in_key)
					PlayerCommand.Command.ITEM_SLOT_1:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 1, in_key)
					PlayerCommand.Command.ITEM_SLOT_2:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 2, in_key)
					PlayerCommand.Command.ITEM_SLOT_3:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 3, in_key)
					PlayerCommand.Command.ITEM_SLOT_4:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 4, in_key)
					PlayerCommand.Command.ITEM_SLOT_5:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 5, in_key)
					PlayerCommand.Command.ITEM_SLOT_6:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 6, in_key)
					PlayerCommand.Command.ITEM_SLOT_7:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 7, in_key)
					PlayerCommand.Command.ITEM_SLOT_8:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 8, in_key)
					PlayerCommand.Command.ITEM_SLOT_9:
						if try_player_insanity():
							loop = false
						else:
							loop = not do_player_item_slot(p_player, 9, in_key)
					PlayerCommand.Command.RUN_TOGGLE:
						if try_player_insanity():
							loop = false
						else:
							handle_player_run_toggle(p_player)
					PlayerCommand.Command.CLOSE_DOOR:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_close_door(p_player)
					PlayerCommand.Command.BARRICADE_MODE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_barricade(p_player)
					PlayerCommand.Command.BREAK_MODE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_break(p_player)
					PlayerCommand.Command.BUILD_LARGE_FORTIFICATION:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_build_fortification(p_player, true)
					PlayerCommand.Command.BUILD_SMALL_FORTIFICATION:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_build_fortification(p_player, false)
					PlayerCommand.Command.ORDER_MODE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_order_mode(p_player)
					PlayerCommand.Command.PULL_MODE:  # alpha10
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_pull(p_player)
					PlayerCommand.Command.PUSH_MODE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_push(p_player)
					PlayerCommand.Command.FIRE_MODE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_fire_mode(p_player)
					PlayerCommand.Command.SHOUT:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_shout(p_player, "")
					PlayerCommand.Command.SLEEP:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_sleep(p_player)
					PlayerCommand.Command.SWITCH_PLACE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_switch_place(p_player)
					PlayerCommand.Command.USE_SPRAY:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_use_spray(p_player)
					PlayerCommand.Command.LEAD_MODE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_take_lead(p_player)
					PlayerCommand.Command.GIVE_ITEM:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_give_item(p_player, mouse_pos)
					PlayerCommand.Command.NEGOCIATE_TRADE:  # alpha10
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_negociate_trade(p_player)  # alpha10
					PlayerCommand.Command.MARK_ENEMIES_MODE:
						if try_player_insanity():
							loop = false
						else:
							handle_player_mark_enemies(p_player)
					PlayerCommand.Command.EAT_CORPSE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_eat_corpse(p_player, mouse_pos)
					PlayerCommand.Command.REVIVE_CORPSE:
						if try_player_insanity():
							loop = false
						else:
							loop = not handle_player_revive_corpse(p_player, mouse_pos)
					PlayerCommand.Command.NONE:
						pass
					_:
						push_error("command unhandled: %d" % command)
		else:
			# Handle mouse
			# Look?
			var is_looking: bool = handle_mouse_look(mouse_pos)
			if is_looking:
				continue

			# Inventory?
			# TODO: out-param Dictionary shape assumed {"ok", "has_done_action"}
			var inv_res: Dictionary = handle_mouse_inventory(mouse_pos, mouse_buttons)
			if inv_res["ok"]:
				if inv_res["has_done_action"]:
					loop = false
				else:
					continue

			# Corpses?
			var corpse_res: Dictionary = handle_mouse_over_corpses(mouse_pos, mouse_buttons)
			if corpse_res["ok"]:
				if corpse_res["has_done_action"]:
					loop = false
				else:
					continue

			# Neither look nor inventory nor corpses, cleanup.
			clear_overlays()

	# Upkeep.
	update_player_fov(p_player)  # make sure LOS is up to date
	compute_view_rect(p_player.location.position)
	session.last_turn_player_acted = session.world_time.turn_counter


func try_player_insanity() -> bool:
	if not rules.is_actor_insane(player):
		return false
	if not rules.roll_chance(Rules.SANITY_INSANE_ACTION_CHANCE):
		return false

	var insane_action: ActorAction = generate_insane_action(player)
	if insane_action == null:
		return false
	if not insane_action.is_legal():
		return false

	clear_messages()
	add_message(Message.new("(your insanity takes over)", player.location.map.local_time.turn_counter, Color.ORANGE))
	if not player.is_bot_player:
		add_message_press_enter()

	insane_action.perform()

	return true


# Port of RogueGame.cs lines 6096-6166: quit/abandon/screenshot.


func handle_quit_game() -> bool:
	add_message(make_yes_no_message("REALLY QUIT GAME"))
	redraw_play_screen()

	var answer: bool = wait_yes_or_no()

	if not answer:
		add_message(Message.new("Good. Keep roguing!", session.world_time.turn_counter, Color.YELLOW))
	else:
		add_message(Message.new("Bye!", session.world_time.turn_counter, Color.YELLOW))

	return answer


func handle_abandon_game() -> bool:
	add_message(make_yes_no_message("REALLY KILL YOURSELF"))
	redraw_play_screen()

	var answer: bool = wait_yes_or_no()

	if not answer:
		add_message(Message.new("Good. No reason to make the undeads life easier by removing yours!", session.world_time.turn_counter, Color.YELLOW))
	else:
		add_message(Message.new("You can't bear the horror anymore...", session.world_time.turn_counter, Color.YELLOW))

	return answer


func handle_screenshot() -> void:
	# prepare.
	add_message(Message.new("Taking screenshot...", session.world_time.turn_counter, Color.YELLOW))
	redraw_play_screen()

	# shot it!
	var shotname: String = do_take_screenshot()
	if shotname == "":
		add_message(Message.new("Could not save screenshot.", session.world_time.turn_counter, Color.RED))
	else:
		add_message(Message.new("screenshot %s saved." % shotname, session.world_time.turn_counter, Color.YELLOW))

	# refresh.
	redraw_play_screen()


func do_take_screenshot() -> String:
	var shotname: String = get_user_new_screenshot_name()
	# C# returned null on failure; the UI port returns "" instead.
	if ui.ui_save_screenshot(screenshot_file_path(shotname)) != "":
		return shotname
	else:
		return ""


# Port of RogueGame.cs lines 6168-6283: help mode (game manual viewer).


func handle_help_mode() -> void:
	if manual == null:
		ui.ui_clear(Color.BLACK)
		var gy := 0
		ui.ui_draw_string_bold(Color.RED, "Game manual not available ingame.", 0, gy)
		gy += BOLD_LINE_SPACING
		draw_footnote(Color.WHITE, "press ENTER")
		ui.ui_repaint()
		wait_enter()
		return

	var loop := true
	var lines: Array = manual.formated_lines
	while loop:
		# draw header.
		ui.ui_clear(Color.BLACK)
		var gy := 0
		draw_header()
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Game Manual", 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
		gy += BOLD_LINE_SPACING

		# draw manual.
		var i_line: int = manual_line
		while true:
			# ignore commands
			var ignore: bool = (lines[i_line] == "<SECTION>")

			if not ignore:
				ui.ui_draw_string_bold(Color.LIGHT_GRAY, lines[i_line], 0, gy)
				gy += BOLD_LINE_SPACING
			i_line += 1
			if not (i_line < lines.size() and gy < CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING):
				break

		# draw foot.
		ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
		gy += BOLD_LINE_SPACING
		draw_footnote(Color.WHITE, "cursor and PgUp/PgDn to move, numbers to jump to section, ESC to leave")

		ui.ui_repaint()

		# get command.
		var key: InputEventKey = ui.ui_wait_key()
		var choice: int = key_to_choice_number(key.keycode)

		if choice >= 0:
			if choice == 0:
				manual_line = 0
			else:
				# jump to Nth section.
				var prev_line: int = manual_line
				var section_count := 0
				manual_line = 0
				while section_count < choice and manual_line < lines.size():
					if lines[manual_line] == "<SECTION>":
						section_count += 1
					manual_line += 1

				# if section not found, don't move.
				if manual_line >= lines.size():
					manual_line = prev_line
		else:
			match key.keycode:
				KEY_ESCAPE:
					loop = false
				KEY_UP:
					manual_line -= 1
				KEY_DOWN:
					manual_line += 1
				KEY_PAGEUP:
					manual_line -= TEXTFILE_LINES_PER_PAGE
				KEY_PAGEDOWN:
					manual_line += TEXTFILE_LINES_PER_PAGE

		if manual_line < 0:
			manual_line = 0
		if manual_line + TEXTFILE_LINES_PER_PAGE >= lines.size():
			manual_line = maxi(0, lines.size() - TEXTFILE_LINES_PER_PAGE)


# Port of RogueGame.cs lines 6285-6417: Hints screen + Message log.


func handle_hints_screen() -> void:
	# draw header.
	ui.ui_clear(Color.BLACK)
	var gy := 0
	draw_header()
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.YELLOW, "Advisor Hints", 0, gy)
	gy += BOLD_LINE_SPACING

	# prepare : get all the hints text into one huuuuuge list of line :D
	ui.ui_draw_string_bold(Color.WHITE, "preparing...", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()
	var lines: Array = []
	for i in range(GameHintsStatus.AdvisorHint._FIRST, GameHintsStatus.AdvisorHint._COUNT):
		# TODO: out-params title/body returned as Dictionary {"title", "body"}
		var hint_text: Dictionary = get_advisor_hint_text(i)
		var title: String = hint_text["title"]
		var body: Array = hint_text["body"]
		if hints.is_advisor_hint_given(i):
			title += " (hint already given)"  # alpha10

		lines.append("HINT %d : %s" % [i, title])
		lines.append_array(body)
		lines.append("~~~~")
		lines.append("")

	# display & handle loop.
	var current_line := 0
	var loop := true
	while loop:
		# header.
		ui.ui_clear(Color.BLACK)
		gy = 0
		draw_header()
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Advisor Hints", 0, gy)
		gy += BOLD_LINE_SPACING

		# display currently viewed lines.
		ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
		gy += BOLD_LINE_SPACING
		var i_line: int = current_line
		while true:
			ui.ui_draw_string_bold(Color.LIGHT_GRAY, lines[i_line], 0, gy)
			gy += BOLD_LINE_SPACING
			i_line += 1
			if not (i_line < lines.size() and gy < CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING):
				break

		# draw foot.
		ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
		gy += BOLD_LINE_SPACING
		draw_footnote(Color.WHITE, "cursor and PgUp/PgDn to move, R to reset hints, ESC to leave")

		ui.ui_repaint()

		# get command.
		var key: InputEventKey = ui.ui_wait_key()
		match key.keycode:
			KEY_ESCAPE:
				loop = false
			KEY_UP:
				current_line -= 1
			KEY_DOWN:
				current_line += 1
			KEY_PAGEUP:
				current_line -= TEXTFILE_LINES_PER_PAGE
			KEY_PAGEDOWN:
				current_line += TEXTFILE_LINES_PER_PAGE
			KEY_R:
				# do it.
				hints.reset_all_hints()

				# notify.
				ui.ui_clear(Color.BLACK)
				gy = 0
				draw_header()
				gy += BOLD_LINE_SPACING
				ui.ui_draw_string_bold(Color.YELLOW, "Advisor Hints", 0, gy)
				gy += BOLD_LINE_SPACING
				ui.ui_draw_string_bold(Color.WHITE, "Hints reset done.", 0, gy)
				ui.ui_repaint()
				ui.ui_wait(DELAY_LONG)

		if current_line < 0:
			current_line = 0
		if current_line + TEXTFILE_LINES_PER_PAGE >= lines.size():
			current_line = maxi(0, lines.size() - TEXTFILE_LINES_PER_PAGE)


func handle_message_log() -> void:
	# draw header.
	ui.ui_clear(Color.BLACK)
	var gy := 0
	draw_header()
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.YELLOW, "Message Log", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
	gy += BOLD_LINE_SPACING

	# log.
	for msg in message_manager.history:
		ui.ui_draw_string(msg.color, msg.text, 0, gy)
		gy += LINE_SPACING

	# foot.
	draw_footnote(Color.WHITE, "press ESC to leave")

	# wait.
	ui.ui_repaint()
	wait_escape()


# Port of RogueGame.cs lines 6419-6618: city info screen.


func handle_city_info() -> void:
	var gx := 0
	var gy := 0
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "CITY INFORMATION", gy, gy)
	gy += 2 * BOLD_LINE_SPACING

	# Undead : no info!
	# Living : normal.
	if player.model.abilities.is_undead:
		# Undead : no info
		ui.ui_draw_string_bold(Color.RED, "You can't remember where you are...", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.RED, "Must be that rotting brain of yours...", gx, gy)
		gy += 2 * BOLD_LINE_SPACING
	else:
		# Living : show info
		# City map
		ui.ui_draw_string_bold(Color.WHITE, "> DISTRICTS LAYOUT", gx, gy)
		gy += BOLD_LINE_SPACING

		# coordinates.
		gy += BOLD_LINE_SPACING
		for y in range(session.world.size):
			var color: Color = Color.LIGHT_GREEN if y == player.location.map.district.world_position.y else Color.WHITE
			ui.ui_draw_string_bold(color, str(y), 20, gy + y * 3 * BOLD_LINE_SPACING + BOLD_LINE_SPACING)
			ui.ui_draw_string_bold(color, ".", 20, gy + y * 3 * BOLD_LINE_SPACING)
			ui.ui_draw_string_bold(color, ".", 20, gy + y * 3 * BOLD_LINE_SPACING + 2 * BOLD_LINE_SPACING)
		gy -= BOLD_LINE_SPACING
		for x in range(session.world.size):
			var color: Color = Color.LIGHT_GREEN if x == player.location.map.district.world_position.x else Color.WHITE
			ui.ui_draw_string_bold(color, "..%s.." % String.chr(65 + x), 32 + x * 48, gy)
		# districts.
		gy += BOLD_LINE_SPACING
		var mx := 32
		var my := gy
		for y in range(session.world.size):
			for x in range(session.world.size):
				var d: District = session.world.get_district(x, y)
				var d_status: String = "*" if d == session.current_map.district else ("-" if session.scoring.has_visited(d.entry_map) else "?")
				var d_color: Color
				var d_char: String
				match d.kind:
					District.DistrictKind.BUSINESS:
						d_color = Color.RED
						d_char = "Bus"
					District.DistrictKind.GENERAL:
						d_color = Color.GRAY
						d_char = "Gen"
					District.DistrictKind.GREEN:
						d_color = Color.GREEN
						d_char = "Gre"
					District.DistrictKind.RESIDENTIAL:
						d_color = Color.ORANGE
						d_char = "Res"
					District.DistrictKind.SHOPPING:
						d_color = Color.WHITE
						d_char = "Sho"
					_:
						push_error("unhandled district kind")
						d_color = Color.WHITE
						d_char = "???"

				var lchar := ""
				for i in range(5):
					lchar += d_status
				var l_color: Color = Color.LIGHT_GREEN if d == player.location.map.district else d_color

				ui.ui_draw_string_bold(l_color, lchar, mx + x * 48, my + (y * 3) * BOLD_LINE_SPACING)
				ui.ui_draw_string_bold(l_color, d_status, mx + x * 48, my + (y * 3 + 1) * BOLD_LINE_SPACING)
				ui.ui_draw_string_bold(d_color, d_char, mx + x * 48 + 8, my + (y * 3 + 1) * BOLD_LINE_SPACING)
				ui.ui_draw_string_bold(l_color, d_status, mx + x * 48 + 4 * 8, my + (y * 3 + 1) * BOLD_LINE_SPACING)
				ui.ui_draw_string_bold(l_color, lchar, mx + x * 48, my + (y * 3 + 2) * BOLD_LINE_SPACING)
		# subway line.
		var subway_char := "="
		var subway_y := session.world.size / 2
		for x in range(1, session.world.size):
			ui.ui_draw_string_bold(Color.WHITE, subway_char, mx + x * 48 - 8, my + (subway_y * 3) * BOLD_LINE_SPACING + BOLD_LINE_SPACING)

		gy += (session.world.size * 3 + 1) * BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "Legend", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string(Color.WHITE, "  *   - current     ?   - unvisited", gx, gy)
		gy += LINE_SPACING
		ui.ui_draw_string(Color.WHITE, "  Bus - Business    Gen - General    Gre - Green", gx, gy)
		gy += LINE_SPACING
		ui.ui_draw_string(Color.WHITE, "  Res - Residential Sho - Shopping", gx, gy)
		gy += LINE_SPACING
		ui.ui_draw_string(Color.WHITE, "  =   - Subway Line", gx, gy)
		gy += LINE_SPACING

		# Notable locations
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "> NOTABLE LOCATIONS", gx, gy)
		gy += BOLD_LINE_SPACING
		var buildings_y := gy
		for y in range(session.world.size):
			for x in range(session.world.size):
				var d: District = session.world.get_district(x, y)
				var map: Map = d.entry_map

				# Subway station?
				var subway_zone: Zone = map.get_zone_by_partial_name(NAME_SUBWAY_STATION)
				if subway_zone != null:
					ui.ui_draw_string_bold(Color.BLUE, "at %s : %s." % [World.coord_to_string(x, y), subway_zone.name], gx, gy)
					gy += BOLD_LINE_SPACING
					if gy >= CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING:
						gy = buildings_y
						gx += 25 * BOLD_LINE_SPACING

				# Sewers maintenance? alpha10 removed

				# Police station?
				if map == session.unique_maps.police_station_offices_level.the_map.district.entry_map:
					ui.ui_draw_string_bold(Color.CADET_BLUE, "at %s : Police Station." % World.coord_to_string(x, y), gx, gy)
					gy += BOLD_LINE_SPACING
					if gy >= CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING:
						gy = buildings_y
						gx += 25 * BOLD_LINE_SPACING

				# Hospital?
				if map == session.unique_maps.hospital_admissions.the_map.district.entry_map:
					ui.ui_draw_string_bold(Color.WHITE, "at %s : Hospital." % World.coord_to_string(x, y), gx, gy)
					gy += BOLD_LINE_SPACING
					if gy >= CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING:
						gy = buildings_y
						gx += 25 * BOLD_LINE_SPACING

				# Secrets
				# - CHAR Underground Facility?
				if session.player_knows_char_underground_facility_location and map == session.unique_maps.char_underground_facility.the_map.district.entry_map:
					ui.ui_draw_string_bold(Color.RED, "at %s : %s." % [World.coord_to_string(x, y), session.unique_maps.char_underground_facility.the_map.name], gx, gy)
					gy += BOLD_LINE_SPACING
					if gy >= CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING:
						gy = buildings_y
						gx += 25 * BOLD_LINE_SPACING
				# - The Sewers Thing?
				if session.player_knows_the_sewers_thing_location \
						and map == session.unique_actors.the_sewers_thing.the_actor.location.map.district.entry_map \
						and not session.unique_actors.the_sewers_thing.the_actor.is_dead:
					ui.ui_draw_string_bold(Color.RED, "at %s : The Sewers Thing lives down there." % World.coord_to_string(x, y), gx, gy)
					gy += BOLD_LINE_SPACING
					if gy >= CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING:
						gy = buildings_y
						gx += 25 * BOLD_LINE_SPACING

	draw_footnote(Color.WHITE, "press ESC to leave")
	ui.ui_repaint()
	wait_escape()




# Port of RogueGame.cs lines 6621-8209 (ingame mouse modes + Corpses part 1).
# Conventions: MouseButtons? -> int (-1 = none, else ui bitmask 1=left 2=right 4=middle);
# out-params -> Dictionary. IsVisibleToPlayer(map,pos) -> is_visible_to_player_at,
# IsVisibleToPlayer(actor) -> is_visible_to_player.

func handle_mouse_look(mouse_pos: Vector2i) -> bool:
	# Ignore if out of view rect.
	var mouse_map: Vector2i = mouse_to_map(mouse_pos)
	if not is_in_view_rect(mouse_map):
		return false

	# Nothing to do if out of map, but still handle the mouse.
	if not session.current_map.is_in_bounds_p(mouse_map):
		return true

	# Do look.
	clear_overlays()
	if is_visible_to_player(session.current_map, mouse_map):
		var tile_screen_pos: Vector2i = map_to_screen(mouse_map)
		var description: Array = describe_stuff_at(session.current_map, mouse_map)
		if description != null:
			var popup_pos := Vector2i(tile_screen_pos.x + TILE_SIZE, tile_screen_pos.y)
			add_overlay(OverlayPopup.new(description, Color.WHITE, Color.WHITE, POPUP_FILLCOLOR, popup_pos))
			if options.show_targets:
				var actor_there: Actor = session.current_map.get_actor_at(mouse_map)
				if actor_there != null:
					draw_actor_relations(actor_there)

	# Handled mouse.
	return true


func handle_mouse_inventory(mouse_pos: Vector2i, mouse_buttons: int) -> Dictionary:
	# mouse_buttons: -1 = none, else ui bitmask (1=left, 2=right, 4=middle)
	var res := mouse_to_inventory_item(mouse_pos)
	var inv: Inventory = res.inv
	if inv == null:
		return {"ok": false, "has_done_action": false}

	# Do inventory stuff.
	var is_player_inventory: bool = (inv == player.inventory)
	var has_done_action := false
	clear_overlays()
	# inventory panel coordinates are canvas px on the HUD: screen-space rect.
	var item_pos: Vector2i = res.item_pos
	add_overlay(OverlayRect.new(Color.CYAN, Rect2i(item_pos.x, item_pos.y, 32, 32), false))
	add_overlay(OverlayRect.new(Color.CYAN, Rect2i(item_pos.x + 1, item_pos.y + 1, 30, 30), false))
	var it: Item = res.item
	if it != null:
		var lines: Array = describe_item_long(it, is_player_inventory, res.i_slot)
		var longest_line: int = 1 + find_longest_line(lines)
		var ov_x: int = item_pos.x - 7 * longest_line
		var ov_y: int = item_pos.y + 32

		add_overlay(OverlayPopup.new(lines, Color.WHITE, Color.WHITE, POPUP_FILLCOLOR, Vector2i(ov_x, ov_y)))

		# item action?
		if mouse_buttons >= 0:
			if mouse_buttons == 1:  # left
				has_done_action = on_lmb_item(inv, it)
			elif mouse_buttons == 2:  # right
				has_done_action = on_rmb_item(inv, it)

	# Handled mouse.
	return {"ok": true, "has_done_action": has_done_action}


func mouse_to_inventory_item(screen: Vector2i) -> Dictionary:
	var inv: Inventory = null
	var item_pos := Vector2i.ZERO
	var i_slot := -1  # alpha10

	if player == null:
		return {"item": null, "inv": null, "item_pos": item_pos, "i_slot": i_slot}

	var player_inv: Inventory = player.inventory
	var player_slot: Vector2i = mouse_to_inventory_slot(INVENTORYPANEL_X, INVENTORYPANEL_Y, screen.x, screen.y)
	var player_item_index: int = player_slot.x + player_slot.y * INVENTORY_SLOTS_PER_LINE
	if player_item_index >= 0 and player_item_index < player_inv.max_capacity:
		inv = player_inv
		item_pos = inventory_slot_to_screen(INVENTORYPANEL_X, INVENTORYPANEL_Y, player_slot.x, player_slot.y)
		i_slot = player_item_index  # alpha10
		return {"item": player_inv.get_item_at(player_item_index), "inv": inv, "item_pos": item_pos, "i_slot": i_slot}

	var ground_inv: Inventory = player.location.map.get_items_at(player.location.position)
	var ground_slot: Vector2i = mouse_to_inventory_slot(INVENTORYPANEL_X, GROUNDINVENTORYPANEL_Y, screen.x, screen.y)
	item_pos = inventory_slot_to_screen(INVENTORYPANEL_X, GROUNDINVENTORYPANEL_Y, ground_slot.x, ground_slot.y)
	if ground_inv == null:
		return {"item": null, "inv": null, "item_pos": item_pos, "i_slot": i_slot}
	var ground_item_index: int = ground_slot.x + ground_slot.y * INVENTORY_SLOTS_PER_LINE
	if ground_item_index >= 0 and ground_item_index < ground_inv.max_capacity:
		inv = ground_inv
		i_slot = ground_item_index  # alpha10
		return {"item": ground_inv.get_item_at(ground_item_index), "inv": inv, "item_pos": item_pos, "i_slot": i_slot}

	return {"item": null, "inv": null, "item_pos": item_pos, "i_slot": i_slot}


func on_lmb_item(inv: Inventory, it: Item) -> bool:
	if inv == player.inventory:
		# LMB in player inv = use/equip toggle
		if it.is_equipped:
			var res := rules.can_actor_unequip_item(player, it)
			if res.ok:
				do_unequip_item(player, it)
				return false
			else:
				add_message(make_error_message("Cannot unequip %s : %s." % [it.the_name(), res.fail_reason]))
				return false
		elif it.model.is_equipable():
			var res := rules.can_actor_equip_item(player, it)
			if res.ok:
				do_equip_item(player, it)
				return false
			else:
				add_message(make_error_message("Cannot equip %s : %s." % [it.the_name(), res.fail_reason]))
				return false
		else:
			# try to use item.
			var res := rules.can_actor_use_item(player, it)
			if res.ok:
				do_use_item(player, it)
				return true
			else:
				add_message(make_error_message("Cannot use %s : %s." % [it.the_name(), res.fail_reason]))
	else:  # ground inventory
		# LMB in ground inv = take
		var res := rules.can_actor_get_item(player, it)
		if res.ok:
			do_take_item(player, player.location.position, it)
			return true
		else:
			add_message(make_error_message("Cannot take %s : %s." % [it.the_name(), res.fail_reason]))
			return false

	return false


func on_rmb_item(inv: Inventory, it: Item) -> bool:
	if inv == player.inventory:
		var res := rules.can_actor_drop_item(player, it)
		if res.ok:
			do_drop_item(player, it)
			return true
		else:
			add_message(make_error_message("Cannot drop %s : %s." % [it.the_name(), res.fail_reason]))
			return false

	return false


#region Corpses
func handle_mouse_over_corpses(mouse_pos: Vector2i, mouse_buttons: int) -> Dictionary:
	# mouse_buttons: -1 = none, else ui bitmask (1=left, 2=right, 4=middle)
	# Ignore if not on a corpse slot.
	var res := mouse_to_corpse(mouse_pos)
	var corpse: Corpse = res.corpse
	if corpse == null:
		return {"ok": false, "has_done_action": false}

	# Do corpse stuff.
	var has_done_action := false
	clear_overlays()
	# corpse panel coordinates are canvas px on the HUD: screen-space rect.
	var corpse_pos: Vector2i = res.corpse_pos
	add_overlay(OverlayRect.new(Color.CYAN, Rect2i(corpse_pos.x, corpse_pos.y, 32, 32), false))
	add_overlay(OverlayRect.new(Color.CYAN, Rect2i(corpse_pos.x + 1, corpse_pos.y + 1, 30, 30), false))

	var lines: Array = describe_corpse_long(corpse, true)
	var longest_line: int = 1 + find_longest_line(lines)
	var ov_x: int = corpse_pos.x - 7 * longest_line
	var ov_y: int = corpse_pos.y + 32

	add_overlay(OverlayPopup.new(lines, Color.WHITE, Color.WHITE, POPUP_FILLCOLOR, Vector2i(ov_x, ov_y)))

	# mouse action?
	if mouse_buttons >= 0:
		if mouse_buttons == 1:  # left
			has_done_action = on_lmb_corpse(corpse)
		elif mouse_buttons == 2:  # right
			has_done_action = on_rmb_corpse(corpse)

	# Handled mouse.
	return {"ok": true, "has_done_action": has_done_action}


func mouse_to_corpse(screen: Vector2i) -> Dictionary:
	var corpse_pos := Vector2i.ZERO

	if player == null:
		return {"corpse": null, "corpse_pos": corpse_pos}

	var corpses_list = player.location.map.get_corpses_at(player.location.position)
	if corpses_list == null:
		return {"corpse": null, "corpse_pos": corpse_pos}
	var corpse_slot: Vector2i = mouse_to_inventory_slot(INVENTORYPANEL_X, CORPSESPANEL_Y, screen.x, screen.y)
	corpse_pos = inventory_slot_to_screen(INVENTORYPANEL_X, CORPSESPANEL_Y, corpse_slot.x, corpse_slot.y)
	var corpse_index: int = corpse_slot.x + corpse_slot.y * INVENTORY_SLOTS_PER_LINE
	if corpse_index >= 0 and corpse_index < corpses_list.size():
		return {"corpse": corpses_list[corpse_index], "corpse_pos": corpse_pos}

	return {"corpse": null, "corpse_pos": corpse_pos}


func on_lmb_corpse(c: Corpse) -> bool:
	if c.is_dragged():
		var res := rules.can_actor_stop_drag_corpse(player, c)
		if res.ok:
			do_stop_drag_corpse(player, c)
			return false
		else:
			add_message(make_error_message("Cannot stop dragging %s corpse : %s." % [c.dead_guy.name, res.fail_reason]))
			return false
	else:
		var res := rules.can_actor_start_drag_corpse(player, c)
		if res.ok:
			do_start_drag_corpse(player, c)
			return false
		else:
			add_message(make_error_message("Cannot start dragging %s corpse : %s." % [c.dead_guy.name, res.fail_reason]))
			return false


func on_rmb_corpse(c: Corpse) -> bool:
	var res: Dictionary
	if player.model.abilities.is_undead:
		res = rules.can_actor_eat_corpse(player, c)
		if res.ok:
			do_eat_corpse(player, c)
			return true
		else:
			add_message(make_error_message("Cannot eat %s corpse : %s." % [c.dead_guy.name, res.fail_reason]))
			return false
	else:
		res = rules.can_actor_butcher_corpse(player, c)
		if res.ok:
			do_butcher_corpse(player, c)
			return true
		else:
			add_message(make_error_message("Cannot butcher %s corpse : %s." % [c.dead_guy.name, res.fail_reason]))
			return false


func handle_player_eat_corpse(actor: Actor, mouse_pos: Vector2i) -> bool:
	# Ignore if not on a corpse slot.
	var res := mouse_to_corpse(mouse_pos)
	var corpse: Corpse = res.corpse
	if corpse == null:
		return false

	# Check legality.
	var check := rules.can_actor_eat_corpse(actor, corpse)
	if not check.ok:
		add_message(make_error_message("Cannot eat %s corpse : %s." % [corpse.dead_guy.name, check.fail_reason]))
		return false

	# Do it.
	do_eat_corpse(actor, corpse)
	return true


func handle_player_revive_corpse(actor: Actor, mouse_pos: Vector2i) -> bool:
	# Ignore if not on a corpse slot.
	var res := mouse_to_corpse(mouse_pos)
	var corpse: Corpse = res.corpse
	if corpse == null:
		return false

	# Check legality.
	var check := rules.can_actor_revive_corpse(actor, corpse)
	if not check.ok:
		add_message(make_error_message("Cannot revive %s : %s." % [corpse.dead_guy.name, check.fail_reason]))
		return false

	# Do it.
	do_revive_corpse(actor, corpse)
	return true


func do_start_drag_corpse(a: Actor, c: Corpse) -> void:
	c.dragged_by = a
	a.dragged_corpse = c
	if is_visible_to_player(a):
		add_message(make_message(a, "%s dragging %s corpse." % [conjugate(a, VERB_START), c.dead_guy.name]))


func do_stop_drag_corpse(a: Actor, c: Corpse) -> void:
	c.dragged_by = null
	a.dragged_corpse = null
	if is_visible_to_player(a):
		add_message(make_message(a, "%s dragging %s corpse." % [conjugate(a, VERB_STOP), c.dead_guy.name]))


func do_stop_dragging_corpses(a: Actor) -> void:
	if a.dragged_corpse != null:
		do_stop_drag_corpse(a, a.dragged_corpse)


func do_butcher_corpse(a: Actor, c: Corpse) -> void:
	var is_visible: bool = is_visible_to_player(a)

	# spend ap.
	spend_actor_action_points(a, Rules.BASE_ACTION_COST)

	# cause insanity.
	seeing_cause_insanity(a, a.location, Rules.SANITY_HIT_BUTCHERING_CORPSE, "%s butchering %s" % [a.name, c.dead_guy.name])

	# damage.
	var dmg: int = rules.actor_damage_vs_corpses(a)

	if is_visible:
		add_message(make_message(a, "%s %s corpse for %d damage." % [conjugate(a, VERB_BUTCHER), c.dead_guy.name, dmg]))

	inflict_damage_to_corpse(c, dmg)

	# destroy?
	if c.hit_points <= 0:
		destroy_corpse(c, a.location.map)
		if is_visible:
			add_message(Message.new("%s corpse is no more." % c.dead_guy.name, a.location.map.local_time.turn_counter, Color.PURPLE))


func do_eat_corpse(a: Actor, c: Corpse) -> void:
	var is_visible: bool = is_visible_to_player(a)

	# spend ap.
	spend_actor_action_points(a, Rules.BASE_ACTION_COST)

	# damage.
	var dmg: int = rules.actor_damage_vs_corpses(a)

	# msg.
	if is_visible:
		# C# passes dmg as an extra, unused format argument.
		add_message(make_message(a, "%s %s corpse." % [conjugate(a, VERB_FEAST_ON), c.dead_guy.name]))
		# alpha10 replace with sfx
		music_manager.stop()
		music_manager.play(GameSounds.UNDEAD_EAT, MusicPriority.PRIORITY_EVENT)

	# dmh corpse.
	inflict_damage_to_corpse(c, dmg)

	# destroy?
	if c.hit_points <= 0:
		destroy_corpse(c, a.location.map)
		if is_visible:
			add_message(Message.new("%s corpse is no more." % c.dead_guy.name, a.location.map.local_time.turn_counter, Color.PURPLE))

	# heal if undead / food.
	if a.model.abilities.is_undead:
		regen_actor_hit_points(a, rules.actor_bite_hp_regen(a, dmg))
		a.food_points = mini(a.food_points + rules.actor_bite_nutrition_value(a, dmg), rules.actor_max_rot(a))
	else:
		# recover food points.
		a.food_points = mini(a.food_points + rules.actor_bite_nutrition_value(a, dmg), rules.actor_max_food(a))
		# infection!
		infect_actor(a, rules.corpse_eeating_infection_transmission(c.dead_guy.infection))

	# cause insanity.
	seeing_cause_insanity(a, a.location, Rules.SANITY_HIT_UNDEAD_EATING_CORPSE if a.model.abilities.is_undead else Rules.SANITY_HIT_LIVING_EATING_CORPSE,
		"%s eating %s" % [a.name, c.dead_guy.name])

#endregion

func do_revive_corpse(actor: Actor, corpse: Corpse) -> void:
	var visible: bool = is_visible_to_player(actor)

	# spend ap.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# make sure there is a walkable spot for revival.
	var map: Map = actor.location.map
	var revive_points: Array = map.filter_adjacent_in_map(actor.location.position,
		func(pt: Vector2i) -> bool:
			if map.get_actor_at(pt) != null:
				return false
			if map.get_map_object_at(pt) != null:
				return false
			return true)
	if revive_points == null:
		if visible:
			add_message(make_message(actor, "%s not enough room for reviving %s." % [conjugate(actor, VERB_HAVE), corpse.dead_guy.name]))
		return
	var revive_pt: Vector2i = revive_points[rules.roll(0, revive_points.size())]

	# spend medikit.
	var medikit: Item = actor.inventory.get_smallest_stack_by_model(game_items.medikit())  # alpha10
	actor.inventory.consume(medikit)

	# try.
	var chance: int = rules.corpse_revive_chance(actor, corpse)
	if rules.roll_chance(chance):
		# do it.
		corpse.dead_guy.is_dead = false
		corpse.dead_guy.hit_points = rules.corpse_revive_hps(actor, corpse)
		corpse.dead_guy.doll.remove_decoration(GameImages.BLOODIED)
		corpse.dead_guy.activity = Activity.IDLE
		corpse.dead_guy.target_actor = null
		map.remove_corpse(corpse)
		map.place_actor_at(corpse.dead_guy, revive_pt)
		# msg.
		if visible:
			add_message(make_message(actor, conjugate(actor, VERB_REVIVE), corpse.dead_guy))
		# thank you... or not?
		if not rules.are_enemies(actor, corpse.dead_guy):
			do_say(corpse.dead_guy, actor, "Thank you, you saved my life!", Sayflags.NONE)
	else:
		# msg.
		if visible:
			add_message(make_message(actor, "%s to revive" % conjugate(actor, VERB_FAIL), corpse.dead_guy))


func inflict_damage_to_corpse(c: Corpse, dmg: float) -> void:
	c.hit_points -= dmg


func destroy_corpse(c: Corpse, m: Map) -> void:
	if c.dragged_by != null:
		c.dragged_by.dragged_corpse = null
		c.dragged_by = null
	m.remove_corpse(c)


func do_player_item_slot(actor: Actor, slot: int, key: InputEvent) -> bool:
	# get key modifier and redirect to proper action.
	# Ctrl  -> equip/unequip/use item from player inv
	# Shift -> take item from ground inv
	# Alt -> drop item from player inv.
	if key.ctrl_pressed:
		return do_player_item_slot_use(actor, slot)
	elif key.shift_pressed:
		return do_player_item_slot_take(actor, slot)
	elif key.alt_pressed:
		return do_player_item_slot_drop(actor, slot)

	# nope.
	return false


func do_player_item_slot_use(actor: Actor, slot: int) -> bool:
	var inv: Inventory = actor.inventory
	var it: Item = inv.get_item_at(slot)

	# if no item, nothing to do.
	if it == null:
		add_message(make_error_message("No item at inventory slot %d." % (slot + 1)))
		return false

	# try to unequip/equip/use.
	# shameful copy of on_lmb_item.
	if it.is_equipped:
		var res := rules.can_actor_unequip_item(actor, it)
		if res.ok:
			do_unequip_item(actor, it)
			return false
		else:
			add_message(make_error_message("Cannot unequip %s : %s." % [it.the_name(), res.fail_reason]))
			return false
	elif it.model.is_equipable():
		var res := rules.can_actor_equip_item(actor, it)
		if res.ok:
			do_equip_item(actor, it)
			return false
		else:
			add_message(make_error_message("Cannot equip %s : %s." % [it.the_name(), res.fail_reason]))
			return false
	else:
		# try to use item.
		var res := rules.can_actor_use_item(actor, it)
		if res.ok:
			do_use_item(actor, it)
			return true
		else:
			add_message(make_error_message("Cannot use %s : %s." % [it.the_name(), res.fail_reason]))

	# nothing done.
	return false


func do_player_item_slot_take(actor: Actor, slot: int) -> bool:
	var inv: Inventory = actor.location.map.get_items_at(actor.location.position)

	# if no items on ground, nothing to do.
	if inv == null or inv.is_empty:
		add_message(make_error_message("No items on ground."))
		return false

	# if no item, nothing to do.
	var it: Item = inv.get_item_at(slot)
	if it == null:
		add_message(make_error_message("No item at ground slot %d." % (slot + 1)))
		return false

	# try to take.
	var res := rules.can_actor_get_item(actor, it)
	if res.ok:
		do_take_item(actor, actor.location.position, it)
		return true
	else:
		add_message(make_error_message("Cannot take %s : %s." % [it.the_name(), res.fail_reason]))
		return false


func do_player_item_slot_drop(actor: Actor, slot: int) -> bool:
	var inv: Inventory = actor.inventory
	var it: Item = inv.get_item_at(slot)

	# if no item, nothing to do.
	if it == null:
		add_message(make_error_message("No item at inventory slot %d." % (slot + 1)))
		return false

	# try to drop.
	var res := rules.can_actor_drop_item(actor, it)
	if res.ok:
		do_drop_item(actor, it)
		return true
	else:
		add_message(make_error_message("Cannot drop %s : %s." % [it.the_name(), res.fail_reason]))
		return false


func handle_player_shout(actor: Actor, text: String) -> bool:
	var res := rules.can_actor_shout(actor)
	if not res.ok:
		add_message(make_error_message("Can't shout : %s." % res.fail_reason))
		return false

	do_shout(actor, text)
	return true


func handle_player_give_item(actor: Actor, screen: Vector2i) -> bool:
	# get player inventory item under mouse.
	var res := mouse_to_inventory_item(screen)
	var inv: Inventory = res.inv
	var gift: Item = res.item
	if inv == null or inv != actor.inventory or gift == null:
		return false

	# handle give item.
	var loop := true
	var action_done := false
	clear_overlays()
	add_overlay(OverlayPopup.new(GIVE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	while loop:
		# 1. Redraw
		add_message(Message.new("Giving %s to..." % gift.the_name(), session.world_time.turn_counter, Color.YELLOW))
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = actor.location.position + dir.vector
			if actor.location.map.is_in_bounds_p(pos):
				var other: Actor = actor.location.map.get_actor_at(pos)
				if other != null:
					var check := rules.can_actor_give_item_to(actor, other, gift)
					if check.ok:
						# do it.
						action_done = true
						loop = false
						do_give_item_to(actor, other, gift)
					else:
						add_message(make_error_message("Can't give %s to %s : %s." % [gift.the_name(), other.the_name, check.fail_reason]))
				else:
					add_message(make_error_message("Noone there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done

# alpha10 new trade window dialog
func handle_player_trade_negociation(actor: Actor, npc: Actor) -> bool:
	var npc_ai: BaseAI = npc.controller as BaseAI
	var is_on_player_inventory := true
	var i_player_selected_item := -1
	var i_npc_selected_item := -1
	var state := 0  # 0 selecting 1st item; 1 selecting 2nd item; 2 making the offer

	# pre-compute all possible trade deals ratings
	var rating_pairs: Array = []
	for i in actor.inventory.count_items:
		rating_pairs.append([])
		var offered: Item = actor.inventory.get_item_at(i)
		for j in npc.inventory.count_items:
			rating_pairs[i].append(npc_ai.rate_trade_offer(self, actor, offered, npc.inventory.get_item_at(j)))

	# roll charisma to later accept or refuse "maybe" deal.
	var charisma_chance: int = rules.actor_charismatic_trade_chance(actor)
	var charisma_success: bool = session.player_turn_charisma_roll < charisma_chance

	# remember if player is trusted leader to notify him.
	var is_trusted_leader: bool = (npc.leader == actor) and rules.is_actor_trusting_leader(npc)

	# loop
	var loop := true
	var action_done := false
	var lines: Array = []
	var colors: Array = []

	var trade_to_color := func(r: int) -> Color:
		if r == BaseAI.TradeRating.ACCEPT:
			return TRADE_COLOR_ACCEPT
		if r == BaseAI.TradeRating.REFUSE:
			return TRADE_COLOR_REFUSE
		if charisma_success:
			return TRADE_COLOR_MAYBE_SUCCESS
		return TRADE_COLOR_MAYBE_FAILED

	while loop:
		# 1. Redraw
		lines.clear()
		colors.clear()

		if state == 2:
			lines.append("Mode: Making the offer")
		else:
			if is_on_player_inventory:
				if state == 0:
					lines.append("Mode: Proposing an item")
				else:
					lines.append("Mode: Selecting your item to exhange")
			else:
				if state == 0:
					lines.append("Mode: Asking for an item")
				else:
					lines.append("Mode: Selecting an item to exhange")
		colors.append(Color.YELLOW)

		lines.append(" ")
		colors.append(Color.BLACK)

		# header help 1: trusted leader
		if is_trusted_leader:
			lines.append(" ")
			colors.append(Color.WHITE)
			lines.append("You are %s trusted leader, will accept all trades." % his_or_her(npc))
			colors.append(Color.LIGHT_GREEN)

		# header help 2: charisma roll
		if charisma_success:
			lines.append("Charisma roll success %d/%d%%" % [session.player_turn_charisma_roll, charisma_chance])
			colors.append(Color.LIGHT_GREEN)
		else:
			lines.append("Charisma roll failed %d/%d%%" % [session.player_turn_charisma_roll, charisma_chance])
			colors.append(Color.RED)

		var list_trade_items := func(a: Actor, is_active: bool) -> void:
			lines.append("%s items" % a.the_name)
			colors.append(Color.WHITE)
			for i in a.inventory.count_items:
				var it: Item = a.inventory.get_item_at(i)
				if is_active:
					lines.append("%d. %s" % [0 if i == 9 else (i + 1), describe_item_short(it)])
					if state == 0:  # proposing item
						colors.append(Color.YELLOW)
					else:  # trading for current item
						var r: int = rating_pairs[i][i_npc_selected_item] if (a == actor and is_active) else rating_pairs[i_player_selected_item][i]
						colors.append(trade_to_color.call(r))
				else:
					lines.append("-. " + describe_item_short(it))
					colors.append(TRADE_COLOR_SELECTED_ITEM if i == (i_player_selected_item if a == actor else i_npc_selected_item) else Color.GRAY)

		# list items, player and npc
		lines.append(" ")
		colors.append(Color.BLACK)
		list_trade_items.call(actor, is_on_player_inventory and state != 2)
		lines.append(" ")
		colors.append(Color.BLACK)
		list_trade_items.call(npc, not is_on_player_inventory and state != 2)

		# footnote help: trade ratings color legend
		if state != 0 and not is_trusted_leader:
			lines.append(" ")
			colors.append(Color.WHITE)
			lines.append("Trade color legend : ")
			colors.append(Color.WHITE)
			lines.append("  asked/offered")
			colors.append(TRADE_COLOR_SELECTED_ITEM)
			lines.append("  will accept")
			colors.append(TRADE_COLOR_ACCEPT)
			lines.append("  will accept due to your charisma")
			colors.append(TRADE_COLOR_MAYBE_SUCCESS)
			lines.append("  will refuse due to failed charisma")
			colors.append(TRADE_COLOR_MAYBE_FAILED)
			lines.append("  will refuse")
			colors.append(TRADE_COLOR_REFUSE)

		# draw
		clear_overlays()
		add_overlay(OverlayPopup.new(TRADING_DIALOG_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		var ov := OverlayPopupTitleColors.new(
			"Trading with %s" % npc.the_name, Color.WHITE,
			lines, colors,
			Color.WHITE, Color.BLACK, Vector2i(32, 32))
		add_overlay(ov)
		redraw_play_screen()

		# 2. Handle state
		if state == 2:  # make offer
			clear_messages()
			var offered: Item = actor.inventory.get_item_at(i_player_selected_item)
			var asked: Item = npc.inventory.get_item_at(i_npc_selected_item)
			add_message(make_message(actor, "%s %s for %s." % [conjugate(actor, VERB_OFFER), offered.the_name(), asked.the_name()]))

			# get rating and apply charisma
			var r: int = rating_pairs[i_player_selected_item][i_npc_selected_item]
			if r == BaseAI.TradeRating.MAYBE:
				r = BaseAI.TradeRating.ACCEPT if charisma_success else BaseAI.TradeRating.REFUSE

			# npc accept or refuse
			if r == BaseAI.TradeRating.ACCEPT:
				# accept: make deal and done.
				add_message(make_message(npc, conjugate(npc, VERB_ACCEPT_THE_DEAL) + "."))
				swap_actor_items(actor, offered, npc, asked)
				loop = false
				action_done = true
				# sanity recover after player trade chat
				if actor.model.abilities.has_sanity:
					regen_actor_sanity(actor, Rules.SANITY_RECOVER_CHAT_OR_TRADE)
					add_message(make_message(actor, "%s better after chatting with" % conjugate(actor, VERB_FEEL), npc))
				if npc.model.abilities.has_sanity:
					regen_actor_sanity(npc, Rules.SANITY_RECOVER_CHAT_OR_TRADE)
					add_message(make_message(npc, "%s better after chatting with" % conjugate(npc, VERB_FEEL), actor))
			elif r == BaseAI.TradeRating.REFUSE:
				# refuse: can make another offer.
				add_message(make_message(npc, conjugate(npc, VERB_REFUSE_THE_DEAL) + "."))
				is_on_player_inventory = not is_on_player_inventory
				i_player_selected_item = -1
				i_npc_selected_item = -1
				state = 0

			# done
			add_message_press_enter()
		else:
			# Select 1st or 2nd item
			var in_key: InputEventKey = ui.ui_wait_key()

			if in_key.keycode == KEY_ESCAPE:  # back/abort
				if state == 0:
					loop = false
				else:
					state = 0
					if is_on_player_inventory:
						i_player_selected_item = -1
					else:
						i_npc_selected_item = -1
					is_on_player_inventory = not is_on_player_inventory
			elif in_key.keycode == KEY_TAB:  # switch inventory
				if state == 0:
					is_on_player_inventory = not is_on_player_inventory
					i_player_selected_item = -1
					i_npc_selected_item = -1
			else:
				var slot: int = key_to_choice_number(in_key.keycode)
				if slot != -1:  # select an item
					if slot == 0:
						slot = 9
					else:
						slot -= 1

					if is_on_player_inventory:
						if slot < actor.inventory.count_items:
							i_player_selected_item = slot
							if state == 0:  # offering item 1st
								state = 1
								is_on_player_inventory = false
							else:  # offering item 2nd
								state = 2
					else:
						if slot < npc.inventory.count_items:
							i_npc_selected_item = slot
							if state == 0:  # asking item 1st
								state = 1
								is_on_player_inventory = true
							else:  # asking item 2nd
								state = 2

	# if trade done, spend player ap.
	if action_done:
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# alpha10.1 cleanup
	clear_overlays()

	return action_done


func handle_player_negociate_trade(actor: Actor) -> bool:
	# handle select adjacent npc
	var loop := true
	var action_done := false
	clear_overlays()
	add_overlay(OverlayPopup.new(NEGOCIATE_TRADE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = actor.location.position + dir.vector
			if actor.location.map.is_in_bounds_p(pos):
				var other: Actor = actor.location.map.get_actor_at(pos)
				if other != null:
					var check := rules.can_actor_initiate_trade_with(actor, other)
					if check.ok:
						action_done = handle_player_trade_negociation(actor, other)
						loop = false
					else:
						add_message(make_error_message("Can't trade with %s : %s." % [other.the_name, check.fail_reason]))
				else:
					add_message(make_error_message("Noone there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_run_toggle(actor: Actor) -> void:
	var res := rules.can_actor_run(actor)
	if not res.ok:
		add_message(make_error_message("Cannot run now : %s." % res.fail_reason))
		return

	# ok.
	actor.is_running = not actor.is_running
	add_message(make_message(actor, "%s running." % conjugate(actor, VERB_START if actor.is_running else VERB_STOP)))


func handle_player_close_door(actor: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(CLOSE_DOOR_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = actor.location.position + dir.vector
			if actor.location.map.is_in_bounds_p(pos):
				var map_obj: MapObject = actor.location.map.get_map_object_at(pos)
				if map_obj != null and map_obj is DoorWindow:
					var door: DoorWindow = map_obj as DoorWindow
					var check := rules.is_closable_for(actor, door)
					if check.ok:
						do_close_door(actor, door)
						redraw_play_screen()
						loop = false
						action_done = true
					else:
						add_message(make_error_message("Can't close %s : %s." % [door.the_name, check.fail_reason]))
				else:
					add_message(make_error_message("Nothing to close there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_barricade(actor: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(BARRICADE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = actor.location.position + dir.vector
			if actor.location.map.is_in_bounds_p(pos):
				var map_obj: MapObject = actor.location.map.get_map_object_at(pos)
				if map_obj != null:
					# barricading a door.
					if map_obj is DoorWindow:
						var door: DoorWindow = map_obj as DoorWindow
						var check := rules.can_actor_barricade_door(actor, door)
						if check.ok:
							do_barricade_door(actor, door)
							redraw_play_screen()
							loop = false
							action_done = true
						else:
							add_message(make_error_message("Cannot barricade %s : %s." % [door.the_name, check.fail_reason]))
					# repairing a fortification.
					elif map_obj is Fortification:
						var fort: Fortification = map_obj as Fortification
						var check := rules.can_actor_repair_fortification(actor, fort)
						if check.ok:
							do_repair_fortification(actor, fort)
							redraw_play_screen()
							loop = false
							action_done = true
						else:
							add_message(make_error_message("Cannot repair %s : %s." % [fort.the_name, check.fail_reason]))
					else:
						add_message(make_error_message("%s cannot be repaired or barricaded." % map_obj.the_name))
				else:
					add_message(make_error_message("Nothing to barricade there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done

func handle_player_break(actor: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(BREAK_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		else:
			# handle neutral direction = through exit.
			if dir == Direction.NEUTRAL:
				var exit_there: Map.Exit = actor.location.map.get_exit_at(actor.location.position)
				if exit_there == null:
					add_message(make_error_message("No exit there."))
				else:
					# attack/break?
					var map_to: Map = exit_there.to_map
					var actor_to: Actor = map_to.get_actor_at(exit_there.to_position)
					if actor_to != null:
						# only if enemy.
						if rules.are_enemies(actor, actor_to):
							# check melee rule.
							var check := rules.can_actor_melee_attack(actor, actor_to)
							if check.ok:
								do_melee_attack(actor, actor_to)
								loop = false
								action_done = true
							else:
								add_message(make_error_message("Cannot attack %s : %s." % [actor_to.name, check.fail_reason]))
						else:
							add_message(make_error_message("%s is not your enemy." % actor_to.name))
					else:
						# break?
						var obj_to: MapObject = map_to.get_map_object_at(exit_there.to_position)
						if obj_to != null:
							# check break rule.
							var check := rules.is_breakable_for(actor, obj_to)
							if check.ok:
								do_break(actor, obj_to)
								loop = false
								action_done = true
							else:
								add_message(make_error_message("Cannot break %s : %s." % [obj_to.the_name, check.fail_reason]))
						else:
							add_message(make_error_message("Nothing to break or attack on the other side."))
			else:
				# adjacent direction.
				var pos: Vector2i = actor.location.position + dir.vector
				if actor.location.map.is_in_bounds_p(pos):
					var map_obj: MapObject = actor.location.map.get_map_object_at(pos)
					if map_obj != null:
						var check := rules.is_breakable_for(actor, map_obj)
						if check.ok:
							do_break(actor, map_obj)
							redraw_play_screen()
							loop = false
							action_done = true
						else:
							add_message(make_error_message("Cannot break %s : %s." % [map_obj.the_name, check.fail_reason]))
					else:
						add_message(make_error_message("Nothing to break there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_build_fortification(actor: Actor, is_large: bool) -> bool:
	# Check skill & has enough material.
	if actor.sheet.skill_table.get_skill_level(Skills.IDs.CARPENTRY) == 0:
		add_message(make_error_message("need carpentry skill."))
		return false
	var need: int = rules.actor_barricading_material_need_for_fortification(actor, is_large)
	if rules.count_barricading_material(actor) < need:
		add_message(make_error_message("not enough barricading material, need %d." % need))
		return false

	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(BUILD_LARGE_FORT_MODE_TEXT if is_large else BUILD_SMALL_FORT_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = actor.location.position + dir.vector
			if actor.location.map.is_in_bounds_p(pos):
				var check := rules.can_actor_build_fortification(actor, pos, is_large)
				if check.ok:
					do_build_fortification(actor, pos, is_large)
					redraw_play_screen()
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Cannot build here : %s." % check.fail_reason))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done

func handle_player_fire_mode(actor: Actor) -> bool:
	var loop := true
	var action_done := false

	# If grenade equipped, redirected to HandlePlayerThrowGrenade.
	var grenade: ItemGrenade = actor.get_equipped_weapon() as ItemGrenade
	var primed_grenade: ItemGrenadePrimed = actor.get_equipped_weapon() as ItemGrenadePrimed
	if grenade != null or primed_grenade != null:
		return handle_player_throw_grenade(actor)

	# Check if weapon to fire.
	var ranged_weapon: ItemRangedWeapon = actor.get_equipped_weapon() as ItemRangedWeapon
	if ranged_weapon == null:
		add_message(make_error_message("No weapon ready to fire."))
		redraw_play_screen()
		return false
	if ranged_weapon.ammo <= 0:
		add_message(make_error_message("No ammo left."))
		redraw_play_screen()
		return false

	# Get targeting data.
	var fov: Dictionary = LOS.compute_fov_for(rules, actor, session.world_time, session.world.weather)
	var potential_targets: Array = rules.get_enemies_in_fov(actor, fov)

	if potential_targets == null or potential_targets.is_empty():
		add_message(make_error_message("No targets to fire at."))
		redraw_play_screen()
		return false

	# Loop.
	var ranged_attack: Attack = rules.actor_ranged_attack(actor, actor.current_ranged_attack, 0, null)
	var i_current_target := 0
	var lof: Array[Vector2i] = []
	var mode: Attack.FireMode = session.player_current_fire_mode  # alpha10
	while loop:
		var current_target: Actor = potential_targets[i_current_target]
		lof.clear()
		var check := rules.can_actor_fire_at(actor, current_target, lof)
		var can_fire_at_target: bool = check.ok
		var reason: String = check.fail_reason
		var d_to_target: int = rules.grid_distance_points(actor.location.position, current_target.location.position)

		var mode_desc: String
		if mode == Attack.FireMode.RAPID:
			mode_desc = "RAPID fire average hit chances %d%% %d%%" % [rules.compute_chances_ranged_hit(actor, current_target, 1), rules.compute_chances_ranged_hit(actor, current_target, 2)]
		else:
			mode_desc = "Normal fire average hit chance %d%%" % rules.compute_chances_ranged_hit(actor, current_target, 0)

		# 1. Redraw
		var overlay_popup_text: Array = []
		overlay_popup_text.append_array(FIRE_MODE_TEXT)
		overlay_popup_text.append(mode_desc)
		clear_overlays()
		add_overlay(OverlayPopup.new(overlay_popup_text, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		var target_screen: Vector2i = map_to_screen(current_target.location.position)
		add_overlay(OverlayImage.new(target_screen, GameImages.ICON_TARGET))
		var line_image: String
		if can_fire_at_target:
			line_image = GameImages.ICON_LINE_CLEAR if d_to_target <= ranged_attack.efficient_range() else GameImages.ICON_LINE_BAD
		else:
			line_image = GameImages.ICON_LINE_BLOCKED
		for pt in lof:
			var screen_pt: Vector2i = map_to_screen(pt)
			add_overlay(OverlayImage.new(screen_pt, line_image))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var _command: int = InputTranslator.key_to_command(key)  # C# only uses it in a comment

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:  # command == PlayerCommand.EXIT_OR_CANCEL
			loop = false
		elif key.keycode == KEY_T:  # next target
			i_current_target = (i_current_target + 1) % potential_targets.size()
		elif key.keycode == KEY_M:  # next mode
			# switch.
			var next_mode: Variant = (mode + 1) % Attack.FireMode._COUNT
			mode = next_mode
			# tell. (C# prints the enum name; GDScript prints the value.)
			add_message(Message.new("Switched to %s fire mode." % str(mode), session.world_time.turn_counter, Color.YELLOW))
			# alpha10: save preference to session
			session.player_current_fire_mode = mode
		elif key.keycode == KEY_F:  # do fire
			if can_fire_at_target:
				do_ranged_attack(actor, current_target, lof, mode)
				redraw_play_screen()
				loop = false
				action_done = true
			else:
				add_message(make_error_message("Can't fire at %s : %s." % [current_target.the_name, reason]))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


# Mode text/color constants (RogueGame.cs constants region, lines 92-109)


func handle_player_mark_enemies(_player: Actor) -> void:
	# Pre-conditions.
	# FIXME put all that into a rule Rule.CanMakeEnemyOf()
	if _player.model.abilities.is_undead:
		add_message(make_error_message("Undeads can't have personal enemies."))
		return

	# List all visible actors.
	var map: Map = _player.location.map
	var visible_actors: Array[Actor] = []
	for p in player_fov:
		var a: Actor = map.get_actor_at(p)
		if a == null or a.is_player:
			continue
		visible_actors.append(a)
	if visible_actors.is_empty():
		add_message(make_error_message("No visible actors to mark."))
		redraw_play_screen()
		return

	# Loop.
	var loop := true
	var i_current_actor := 0
	while loop:
		var current_actor: Actor = visible_actors[i_current_actor]

		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(MARK_ENEMIES_MODE, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		var target_screen: Vector2i = map_to_screen(current_actor.location.position)
		add_overlay(OverlayImage.new(target_screen, GameImages.ICON_TARGET))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var _command: int = InputTranslator.key_to_command(key)

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:  # command == PlayerCommand.EXIT_OR_CANCEL
			loop = false
		elif key.keycode == KEY_T:  # next actor
			i_current_actor = (i_current_actor + 1) % visible_actors.size()
		elif key.keycode == KEY_E:  # toggle.
			# never make enemies of leader/follower/enemy faction.
			# FIXME put all that into a rule Rule.CanMakeEnemyOf()
			var allowed := true
			if current_actor.leader == _player:
				add_message(make_error_message("Can't make a follower your enemy."))
				allowed = false
			elif _player.leader == current_actor:
				add_message(make_error_message("Can't make your leader your enemy."))
				allowed = false
			elif rules.are_enemies(_player, current_actor):
				add_message(make_error_message("Already enemies."))
				allowed = false

			# do it?
			if allowed:
				add_message(Message.new("%s is now a personal enemy." % current_actor.the_name, session.world_time.turn_counter, Color.ORANGE))
				do_make_aggression(_player, current_actor)

	# cleanup.
	clear_overlays()


func handle_player_throw_grenade(_player: Actor) -> bool:
	var loop := true
	var action_done := false

	# Get grenade equipped.
	var unprimed_grenade: ItemGrenade = _player.get_equipped_weapon() as ItemGrenade
	var primed_grenade: ItemGrenadePrimed = _player.get_equipped_weapon() as ItemGrenadePrimed
	if unprimed_grenade == null and primed_grenade == null:
		add_message(make_error_message("No grenade to throw."))
		redraw_play_screen()
		return false
	var grenade_model: ItemGrenadeModel
	if unprimed_grenade != null:
		grenade_model = unprimed_grenade.model as ItemGrenadeModel
	else:
		grenade_model = (primed_grenade.model as ItemGrenadePrimedModel).grenade_model

	# Get data.
	var map: Map = _player.location.map
	var target_throw: Vector2i = _player.location.position
	var max_throw_dist: int = rules.actor_max_throw_range(_player, grenade_model.max_throw_distance)

	# Loop.
	var lot: Array[Vector2i] = []
	while loop:
		# get LoT.
		lot.clear()
		var throw_res: Dictionary = rules.can_actor_throw_to(_player, target_throw, lot)
		var can_throw_at_target: bool = throw_res.ok
		var reason: String = throw_res.fail_reason

		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(THROW_GRENADE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		var line_image: String = GameImages.ICON_LINE_CLEAR if can_throw_at_target else GameImages.ICON_LINE_BLOCKED
		for pt in lot:
			var screen_pt: Vector2i = map_to_screen(pt)
			add_overlay(OverlayImage.new(screen_pt, line_image))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var command: int = InputTranslator.key_to_command(key)

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:  # command == PlayerCommand.EXIT_OR_CANCEL
			loop = false
		elif key.keycode == KEY_F:  # do throw.
			if can_throw_at_target:
				var do_it := true

				# if within the blast radius, ask for confirmation...
				if rules.grid_distance_points(_player.location.position, target_throw) <= grenade_model.blast_attack.radius:
					clear_messages()
					add_message(Message.new("You are in the blast radius!", session.world_time.turn_counter, Color.YELLOW))
					add_message(make_yes_no_message("Really throw there"))
					redraw_play_screen()
					do_it = wait_yes_or_no()
					clear_messages()
					redraw_play_screen()

				if do_it:
					# fire in the hole!
					if unprimed_grenade != null:
						do_throw_grenade_unprimed(_player, target_throw)
					else:
						do_throw_grenade_primed(_player, target_throw)
					redraw_play_screen()
					loop = false
					action_done = true
			else:
				add_message(make_error_message("Can't throw there : %s." % reason))
		else:
			# direction?
			var dir: Direction = command_to_direction(command)
			if dir != null:
				var pos: Vector2i = target_throw + dir.vector
				if map.is_in_bounds_p(pos) and rules.grid_distance_points(_player.location.position, pos) <= max_throw_dist:
					target_throw = pos

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_sleep(_player: Actor) -> bool:
	# Check rule.
	var sleep_res: Dictionary = rules.can_actor_sleep(_player)
	if not sleep_res.ok:
		add_message(make_error_message("Cannot sleep now : %s." % sleep_res.fail_reason))
		return false

	# Ask for confirmation.
	add_message(make_yes_no_message("Really sleep there"))
	redraw_play_screen()
	var confirm: bool = wait_yes_or_no()
	if not confirm:
		add_message(Message.new("Good, keep those eyes wide open.", session.world_time.turn_counter, Color.YELLOW))
		return false

	# alpha10.1 check autosave before player starts to sleep
	check_auto_save_time()

	# Start sleeping.
	add_message(Message.new("Goodnight, happy nightmares!", session.world_time.turn_counter, Color.YELLOW))
	do_start_sleeping(_player)
	redraw_play_screen()
	# check music.
	music_manager.stop()
	music_manager.play_looping(GameMusics.SLEEP, MusicPriority.PRIORITY_EVENT)
	return true

func handle_player_switch_place(_player: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(SWITCH_PLACE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(pos):
				var other: Actor = _player.location.map.get_actor_at(pos)
				if other != null:
					var switch_res: Dictionary = rules.can_actor_switch_place_with(_player, other)
					if switch_res.ok:
						# switch place.
						action_done = true
						loop = false
						do_switch_place(_player, other)
					else:
						add_message(make_error_message("Can't switch place : %s" % switch_res.fail_reason))
				else:
					add_message(make_error_message("Noone there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_take_lead(_player: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(TAKE_LEAD_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(pos):
				var other: Actor = _player.location.map.get_actor_at(pos)
				if other != null:
					var lead_res: Dictionary = rules.can_actor_take_lead(_player, other)
					var reason: String = lead_res.get("fail_reason", "")
					if lead_res.ok:
						# take lead.
						action_done = true
						loop = false

						# alpha10.1 steal lead vs take lead
						if other.has_leader:
							do_steal_lead(_player, other)
						else:
							do_take_lead(_player, other)

						# scoring.
						session.scoring.add_event(session.world_time.turn_counter, "Recruited %s." % other.the_name)

						# help message.
						add_message(Message.new("(you can now set directives and orders for your new follower).", session.world_time.turn_counter, Color.WHITE))
						# C# prints the key binding via ToString(); Godot prints the keycode string.
						add_message(Message.new("(to give order : press <%s>)." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.ORDER_MODE)), session.world_time.turn_counter, Color.WHITE))
					elif other.leader == _player:
						var cancel_res: Dictionary = rules.can_actor_cancel_lead(_player, other)
						reason = cancel_res.get("fail_reason", "")
						if cancel_res.ok:
							# ask for confirmation.
							add_message(make_yes_no_message("Really ask %s to leave" % other.the_name))
							redraw_play_screen()
							var confirm: bool = wait_yes_or_no()
							if confirm:
								# cancel lead.
								action_done = true
								loop = false
								do_cancel_lead(_player, other)

								# scoring.
								session.scoring.add_event(session.world_time.turn_counter, "Fired %s." % other.the_name)
							else:
								add_message(Message.new("Good, together you are strong.", session.world_time.turn_counter, Color.YELLOW))
						else:
							add_message(make_error_message("%s can't leave : %s." % [other.the_name, reason]))
					else:
						add_message(make_error_message("Can't lead %s : %s." % [other.the_name, reason]))
				else:
					add_message(make_error_message("Noone there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_push(_player: Actor) -> bool:
	# fail immediatly for stupid cases.
	if not rules.has_actor_push_ability(_player):
		add_message(make_error_message("Cannot push objects."))
		return false
	if rules.is_actor_tired(_player):
		add_message(make_error_message("Too tired to push."))
		return false

	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(PUSH_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(pos):
				# shove actor vs push object.
				var other: Actor = _player.location.map.get_actor_at(pos)
				var map_obj: MapObject = _player.location.map.get_map_object_at(pos)
				if other != null:
					# shove.
					var shove_res: Dictionary = rules.can_actor_shove(_player, other)
					if shove_res.ok:
						if handle_player_shove_actor(_player, other):
							loop = false
							action_done = true
					else:
						add_message(make_error_message("Cannot shove %s : %s." % [other.the_name, shove_res.fail_reason]))
				elif map_obj != null:
					# push.
					var push_res: Dictionary = rules._can_actor_push(_player, map_obj)
					if push_res.ok:
						if handle_player_push_object(_player, map_obj):
							loop = false
							action_done = true
					else:
						add_message(make_error_message("Cannot move %s : %s." % [map_obj.the_name, push_res.fail_reason]))
				else:
					# nothing to push/shove.
					add_message(make_error_message("Nothing to push there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done

func handle_player_push_object(_player: Actor, map_obj: MapObject) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new([PUSH_OBJECT_MODE_TEXT % map_obj.the_name], MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(map_obj.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var move_pos: Vector2i = map_obj.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(move_pos):
				var push_res: Dictionary = rules.can_push_object_to(map_obj, move_pos)
				if push_res.ok:
					do_push(_player, map_obj, move_pos)
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Cannot move %s there : %s." % [map_obj.the_name, push_res.fail_reason]))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_shove_actor(_player: Actor, other: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new([SHOVE_ACTOR_MODE_TEXT % other.the_name], MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(other.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var move_pos: Vector2i = other.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(move_pos):
				var shove_res: Dictionary = rules.can_shove_actor_to(other, move_pos)
				if shove_res.ok:
					do_shove(_player, other, move_pos)
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Cannot shove %s there : %s." % [other.the_name, shove_res.fail_reason]))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


# alpha10
func handle_player_pull(_player: Actor) -> bool:
	# fail immediatly for stupid cases.
	if not rules.has_actor_push_ability(_player):
		add_message(make_error_message("Cannot pull objects."))
		return false
	if rules.is_actor_tired(_player):
		add_message(make_error_message("Too tired to pull."))
		return false
	var other_mobj: MapObject = _player.location.map.get_map_object_at(_player.location.position)
	if other_mobj != null:
		add_message(make_error_message("Cannot pull : %s is blocking." % other_mobj.the_name))
		return false

	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new(PULL_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(pos):
				var map_obj: MapObject = _player.location.map.get_map_object_at(pos)
				var other: Actor = _player.location.map.get_actor_at(pos)
				if other != null:
					# pull-shove.
					var shove_res: Dictionary = rules.can_actor_shove(_player, other)  # if can shove, can pull-shove.
					if shove_res.ok:
						if handle_player_pull_actor(_player, other):
							loop = false
							action_done = true
					else:
						add_message(make_error_message("Cannot pull %s : %s." % [other.the_name, shove_res.fail_reason]))
				elif map_obj != null:
					# pull.
					var push_res: Dictionary = rules._can_actor_push(_player, map_obj)  # if can push, can pull.
					if push_res.ok:
						if handle_player_pull_object(_player, map_obj):
							loop = false
							action_done = true
					else:
						add_message(make_error_message("Cannot move %s : %s." % [map_obj.the_name, push_res.fail_reason]))
				else:
					# nothing to pull.
					add_message(make_error_message("Nothing to pull there."))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done

# alpha10
func handle_player_pull_object(_player: Actor, map_obj: MapObject) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new([PULL_OBJECT_MODE_TEXT % map_obj.the_name], MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(map_obj.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var move_to_pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(move_to_pos):
				var pull_res: Dictionary = rules.can_pull_object(_player, map_obj, move_to_pos)
				if pull_res.ok:
					do_pull(_player, map_obj, move_to_pos)
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Cannot pull there : %s." % pull_res.fail_reason))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


# alpha10
func handle_player_pull_actor(_player: Actor, other: Actor) -> bool:
	var loop := true
	var action_done := false

	clear_overlays()
	add_overlay(OverlayPopup.new([PULL_ACTOR_MODE_TEXT % other.the_name], MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(other.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))

	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var move_to_pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(move_to_pos):
				var pull_res: Dictionary = rules.can_pull_actor(_player, other, move_to_pos)
				if pull_res.ok:
					do_pull_actor(_player, other, move_to_pos)
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Cannot pull there : %s." % pull_res.fail_reason))

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func handle_player_use_spray(_player: Actor) -> bool:
	# get equipped item.
	var it: Item = _player.get_equipped_item(Doll.DollPart.LEFT_HAND)
	if it == null:
		add_message(make_error_message("No spray equipped."))
		redraw_play_screen()
		return false

	# Handle concrete action depending on spray.
	# 1. Spray paint.
	# 2. Spray scent.

	# 1. Spray paint.
	var spray_paint: ItemSprayPaint = it as ItemSprayPaint
	if spray_paint != null:
		return handle_player_tag(_player)

	# 2. Spray scent.
	var spray_scent: ItemSprayScent = it as ItemSprayScent
	if spray_scent != null:
		# alpha10 new way to use stench killer
		return handle_player_spray_odor_suppressor(_player)

	# no spray equipped.
	add_message(make_error_message("No spray equipped."))
	redraw_play_screen()
	return false


func handle_player_tag(_player: Actor) -> bool:
	var loop := true
	var action_done := false

	# Check if has spray paint.
	var spray_paint: ItemSprayPaint = _player.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemSprayPaint
	if spray_paint == null:
		add_message(make_error_message("No spray paint equipped."))
		redraw_play_screen()
		return false
	if spray_paint.paint_quantity <= 0:
		add_message(make_error_message("No paint left."))
		redraw_play_screen()
		return false

	clear_overlays()
	add_overlay(OverlayPopup.new(TAG_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		elif dir != Direction.NEUTRAL:
			var pos: Vector2i = _player.location.position + dir.vector
			if _player.location.map.is_in_bounds_p(pos):
				var tag_res: Dictionary = can_tag(_player.location.map, pos)
				if tag_res.ok:
					do_tag(_player, spray_paint, pos)
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Can't tag there : %s." % tag_res.fail_reason))
					redraw_play_screen()

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func can_tag(map: Map, pos: Vector2i) -> Dictionary:
	# Can't tag if:
	# 1. Out of bounds.
	# 2. An actor there.
	# 3. An object there.

	# 1. Out of bounds.
	if not map.is_in_bounds_p(pos):
		return {"ok": false, "fail_reason": "out of map"}

	# 2. An actor there.
	var other: Actor = map.get_actor_at(pos)
	if other != null:
		return {"ok": false, "fail_reason": "someone there"}

	# 3. An object there.
	var map_obj: MapObject = map.get_map_object_at(pos)
	if map_obj != null:
		return {"ok": false, "fail_reason": "something there"}

	return {"ok": true, "fail_reason": ""}

# alpha10 new way to use stench killer
func handle_player_spray_odor_suppressor(_player: Actor) -> bool:
	var loop := true
	var action_done := false

	# Check if has odor suppressor.
	var spray: ItemSprayScent = _player.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemSprayScent
	if spray == null:
		add_message(make_error_message("No spray equipped."))
		redraw_play_screen()
		return false
	if spray.spray_quantity <= 0:
		add_message(make_error_message("No spray left."))
		redraw_play_screen()
		return false

	clear_overlays()
	add_overlay(OverlayPopup.new(SPRAY_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
	while loop:
		# 1. Redraw
		redraw_play_screen()

		# 2. Get input.
		var dir: Direction = wait_direction_or_cancel()

		# 3. Handle input
		if dir == null:
			loop = false
		else:
			var spray_on: Actor = null

			if dir == Direction.NEUTRAL:
				spray_on = _player
			else:
				var pos: Vector2i = _player.location.position + dir.vector
				if _player.location.map.is_in_bounds_p(pos):
					spray_on = _player.location.map.get_actor_at(pos)

			if spray_on == null:
				add_message(make_error_message("No one to spray on here."))
				redraw_play_screen()
			else:
				var spray_res: Dictionary = rules.can_actor_spray_odor_suppressor(_player, spray, spray_on)
				if spray_res.ok:
					do_spray_odor_suppressor(_player, spray, spray_on)
					loop = false
					action_done = true
				else:
					add_message(make_error_message("Can't spray here : %s." % spray_res.fail_reason))
					redraw_play_screen()

	# cleanup.
	clear_overlays()

	# return if we did an action.
	return action_done


func start_player_wait_long(_player: Actor) -> void:
	# alpha10.1 check autosave before player starts long wait
	check_auto_save_time()

	# start waiting.
	is_player_long_wait = true
	is_player_long_wait_forced_stop = false
	player_long_wait_end = WorldTime.new(session.world_time.turn_counter + WorldTime.TURNS_PER_HOUR)

	# message.
	add_message(make_message(_player, "%s waiting." % conjugate(_player, VERB_START)))
	redraw_play_screen()


func check_player_wait_long(_player: Actor) -> bool:
	# Stop waiting if:
	# 1. Force stop wait flag set.
	# 2. Time reached.
	# 3. Hungry or sleepy.
	# 4. Enemy.
	# 5. Sanity check

	# 1. Force stop wait flag set.
	if is_player_long_wait_forced_stop:
		return false

	# 2. Time reached.
	if session.world_time.turn_counter >= player_long_wait_end.turn_counter:
		return false

	# 3. Hungry or sleepy.
	if rules.is_actor_hungry(_player) or rules.is_actor_starving(_player) or rules.is_actor_sleepy(_player) or rules.is_actor_exhausted(_player):
		return false

	# 4. Enemy.
	for p in player_fov:
		var other: Actor = _player.location.map.get_actor_at(p)
		if other != null and rules.are_enemies(_player, other):
			return false

	# 5. Sanity check
	if try_player_insanity():
		return false

	# all clear, waiting not interrupted.
	return true

#region Ordering followers
func handle_player_order_mode(_player: Actor) -> bool:
	# check if we have followers to order.
	if _player.count_followers == 0:
		add_message(make_error_message("No followers to give orders to."))
		return false

	# get followers data.
	var followers: Array[Actor] = []
	followers.resize(_player.count_followers)
	var fovs: Array = []
	fovs.resize(_player.count_followers)
	var has_link_with: Array[bool] = []
	has_link_with.resize(_player.count_followers)
	var i_fo := 0
	for fo in _player.followers:
		followers[i_fo] = fo
		fovs[i_fo] = LOS.compute_fov_for(rules, fo, session.world_time, session.world.weather)
		var in_view: bool = _player.location.position in fovs[i_fo] and fo.location.position in player_fov
		var linked_by_phone: bool = are_linked_by_phone(_player, fo)
		has_link_with[i_fo] = in_view or linked_by_phone
		i_fo += 1

	# if one follower and he's linked, skip selection and directly go to its menu.
	if _player.count_followers == 1 and has_link_with[0]:
		var done: bool = handle_player_order_follower(_player, followers[0])
		# cleanup.
		clear_overlays()
		clear_messages()
		# done.
		return done

	# loop.
	var loop := true
	var action_done := false
	const max_fo_on_page: int = MAX_MESSAGES - 2
	var i_first_follower := 0
	while loop:
		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		clear_messages()
		add_message(Message.new("Choose a follower.", session.world_time.turn_counter, Color.YELLOW))
		var fo_shown := 0
		while fo_shown < max_fo_on_page and (i_first_follower + fo_shown < followers.size()):
			i_fo = fo_shown + i_first_follower
			var f: Actor = followers[i_fo]
			var desc: String = describe_player_follower_status(f)

			if has_link_with[i_fo]:
				add_message(Message.new("%s. %s/%s %s... %s." % [1 + fo_shown, i_fo + 1, followers.size(), f.name, desc], session.world_time.turn_counter, Color.LIGHT_GREEN))
			else:
				add_message(Message.new("%s. %s/%s (%s) %s." % [1 + fo_shown, i_fo + 1, followers.size(), f.name, desc], session.world_time.turn_counter, Color.DARK_GRAY))
			fo_shown += 1
		if fo_shown < followers.size():
			add_message(Message.new("9. next", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var choice: int = key_to_choice_number(key.keycode)

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:
			loop = false
		elif choice == 9:
			i_first_follower += max_fo_on_page
			if i_first_follower >= followers.size():
				i_first_follower = 0
		elif choice >= 1 and choice <= fo_shown:
			# Follower must be linked.
			var f: int = i_first_follower + choice - 1
			if has_link_with[f]:
				# Follower selected, select directive/order
				var selected_follower: Actor = followers[f]
				if handle_player_order_follower(_player, selected_follower):
					loop = false
					action_done = true

	# cleanup.
	clear_overlays()
	clear_messages()

	# return if we did an action.
	return action_done


func handle_player_directive_follower(_player: Actor, follower: Actor) -> bool:
	var loop := true
	var action_done := false

	# loop.
	while loop:
		var directives: ActorDirective = (follower.controller as AIController).directives

		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		clear_messages()
		add_message(Message.new("%s directives..." % follower.name, session.world_time.turn_counter, Color.YELLOW))
		add_message(Message.new("1. %s items." % ("Take" if directives.can_take_items else "Don't take"), session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("2. %s weapons." % ("Fire" if directives.can_fire_weapons else "Don't fire"), session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("3. %s grenades." % ("Throw" if directives.can_throw_grenades else "Don't throw"), session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("4. %s." % ("Sleep" if directives.can_sleep else "Don't sleep"), session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("5. %s." % ("Trade" if directives.can_trade else "Don't trade"), session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("6. %s." % ActorDirective.courage_string(directives.courage), session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var choice: int = key_to_choice_number(key.keycode)

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:
			loop = false
		elif choice >= 1 and choice <= 6:
			match choice:
				1:  # items
					directives.can_take_items = not directives.can_take_items
				2:  # weapons
					directives.can_fire_weapons = not directives.can_fire_weapons
				3:  # grenades.
					directives.can_throw_grenades = not directives.can_throw_grenades
				4:  # sleep
					directives.can_sleep = not directives.can_sleep
				5:  # trade
					directives.can_trade = not directives.can_trade
				6:  # courage: coward -> cautious -> courageous.
					match directives.courage:
						ActorDirective.ActorCourage.COWARD:
							directives.courage = ActorDirective.ActorCourage.CAUTIOUS
						ActorDirective.ActorCourage.CAUTIOUS:
							directives.courage = ActorDirective.ActorCourage.COURAGEOUS
						ActorDirective.ActorCourage.COURAGEOUS:
							directives.courage = ActorDirective.ActorCourage.COWARD

	return action_done


func handle_player_order_follower(_player: Actor, follower: Actor) -> bool:
	# check trust.
	if not rules.is_actor_trusting_leader(follower):
		# say/phone
		if is_visible_to_player(follower):
			do_say(follower, _player, "Sorry, I don't trust you enough yet.", Sayflags.IS_FREE_ACTION | Sayflags.IS_IMPORTANT)
		elif are_linked_by_phone(follower, _player):
			clear_messages()
			add_message(make_message(follower, "Sorry, I don't trust you enough yet."))
			add_message_press_enter()
		# refuse!
		return false

	# current order.
	var desc: String = describe_player_follower_status(follower)

	# compute follower fov.
	var follower_fov: Dictionary = LOS.compute_fov_for(rules, follower, session.world_time, session.world.weather)

	# loop.
	var loop := true
	var action_done := false
	while loop:
		# 1. Redraw
		var start_stop_follow: String = "Start" if (follower.controller as OrderableAI).dont_follow_leader else "Stop"
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		clear_messages()
		add_message(Message.new("Order %s to..." % follower.name, session.world_time.turn_counter, Color.YELLOW))
		add_message(Message.new("0. Cancel current order %s." % desc, session.world_time.turn_counter, Color.GREEN))
		add_message(Message.new("1. Set directives...", session.world_time.turn_counter, Color.CYAN))
		add_message(Message.new("2. Barricade (one)...    6. Drop all items.      A. Give me...", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("3. Barricade (max)...    7. Build small fort.    B. Sleep now.", session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("4. Guard...              8. Build large fort.    C. %s following me.   " % start_stop_follow, session.world_time.turn_counter, Color.LIGHT_GREEN))
		add_message(Message.new("5. Patrol...             9. Report events.       D. Where are you?", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var choice: int = key_to_choice_number(key.keycode)

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:
			loop = false
		# first set of choices 0-9
		elif choice >= 0 and choice <= 9:
			match choice:
				0:  # cancel current order
					do_cancel_order(_player, follower)
					loop = false
					action_done = true
				1:  # set directives.
					handle_player_directive_follower(_player, follower)
				2:  # barricade (one)
					if handle_player_order_follower_to_barricade(_player, follower, follower_fov, false):
						loop = false
						action_done = true
				3:  # barricade (max)
					if handle_player_order_follower_to_barricade(_player, follower, follower_fov, true):
						loop = false
						action_done = true
				4:  # guard
					if handle_player_order_follower_to_guard(_player, follower, follower_fov):
						loop = false
						action_done = true
				5:  # patrol
					if handle_player_order_follower_to_patrol(_player, follower, follower_fov):
						loop = false
						action_done = true
				6:  # drop all items
					if handle_player_order_follower_to_drop_all_items(_player, follower):
						loop = false
						action_done = true
				7:  # build small fort.
					if handle_player_order_follower_to_build_fortification(_player, follower, follower_fov, false):
						loop = false
						action_done = true
				8:  # build large fort.
					if handle_player_order_follower_to_build_fortification(_player, follower, follower_fov, true):
						loop = false
						action_done = true
				9:  # report
					if handle_player_order_follower_to_report(_player, follower):
						loop = false
						action_done = true
		# second set of choices A-xxx
		else:
			match key.keycode:
				KEY_A:  # give items...
					if handle_player_order_follower_to_give_items(_player, follower):
						loop = false
						action_done = true
				KEY_B:  # sleep now
					if handle_player_order_follower_to_sleep(_player, follower):
						loop = false
						action_done = true
				KEY_C:  # toggle follow
					if handle_player_order_follower_to_toggle_follow(_player, follower):
						loop = false
						action_done = true
				KEY_D:  # where are you?
					if handle_player_order_follower_to_report_position(_player, follower):
						loop = false
						action_done = true

	# return if we did an action.
	return action_done

func handle_player_order_follower_to_build_fortification(_player: Actor, follower: Actor, follower_fov: Dictionary, is_large: bool) -> bool:
	var loop := true
	var action_done := false
	var map: Map = _player.location.map
	var highlighted_tile: Variant = null  # Vector2i or null
	var highlight_color := Color.WHITE

	while loop:
		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		if highlighted_tile != null:
			add_overlay(OverlayRect.new(highlight_color, Rect2i(map_to_screen(highlighted_tile), Vector2i(TILE_SIZE, TILE_SIZE))))
		clear_messages()
		add_message(Message.new("Ordering %s to build %s fortification..." % [follower.name, "large" if is_large else "small"], session.world_time.turn_counter, Color.YELLOW))
		add_message(Message.new("<LMB> on a map object.", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var input: Dictionary = wait_key_or_mouse()
		var key = input.key
		var mouse_pos = input.mouse_pos
		var mouse_buttons = input.mouse_buttons

		if key != null:
			if key.keycode == KEY_ESCAPE:
				loop = false
		else:
			# Get map position in view rect.
			var map_pos: Vector2i = mouse_to_map(mouse_pos)
			if map.is_in_bounds_p(map_pos) and is_in_view_rect(map_pos):
				# must be in player & follower FoV.
				if is_visible_to_player(map, map_pos) and map_pos in follower_fov:
					# Check if can build here.
					var build_res: Dictionary = rules.can_actor_build_fortification(follower, map_pos, is_large)
					if build_res.ok:
						# highlight.
						highlighted_tile = map_pos
						highlight_color = Color.LIGHT_GREEN
						# if mouse down, give order.
						if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
							do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.BUILD_LARGE_FORTIFICATION if is_large else ActorOrder.ActorTasks.BUILD_SMALL_FORTIFICATION, Location.new(_player.location.map, map_pos)))
							loop = false
							action_done = true
					else:
						# de-hightlight.
						highlighted_tile = map_pos
						highlight_color = Color.RED

						# if mouse down, illegal.
						if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
							add_message(make_error_message("Can't build %s fortification : %s." % ["large" if is_large else "small", build_res.fail_reason]))
							add_message_press_enter()
				# visible
				else:
					# de-hightlight.
					highlighted_tile = map_pos
					highlight_color = Color.RED

	# return if we did an action.
	return action_done


func handle_player_order_follower_to_barricade(_player: Actor, follower: Actor, follower_fov: Dictionary, to_the_max: bool) -> bool:
	var loop := true
	var action_done := false
	var map: Map = _player.location.map
	var highlighted_tile: Variant = null  # Vector2i or null
	var highlight_color := Color.WHITE

	while loop:
		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		if highlighted_tile != null:
			add_overlay(OverlayRect.new(highlight_color, Rect2i(map_to_screen(highlighted_tile), Vector2i(TILE_SIZE, TILE_SIZE))))
		clear_messages()
		add_message(Message.new("Ordering %s to barricade..." % follower.name, session.world_time.turn_counter, Color.YELLOW))
		add_message(Message.new("<LMB> on a map object.", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var input: Dictionary = wait_key_or_mouse()
		var key = input.key
		var mouse_pos = input.mouse_pos
		var mouse_buttons = input.mouse_buttons

		if key != null:
			if key.keycode == KEY_ESCAPE:
				loop = false
		else:
			# Get map position in view rect.
			var map_pos: Vector2i = mouse_to_map(mouse_pos)
			if map.is_in_bounds_p(map_pos) and is_in_view_rect(map_pos):
				# must be in player & follower FoV.
				if is_visible_to_player(map, map_pos) and map_pos in follower_fov:
					# Check if something to barricade here.
					var door: DoorWindow = map.get_map_object_at(map_pos) as DoorWindow
					if door != null:
						# Check if can barricade here.
						var barricade_res: Dictionary = rules.can_actor_barricade_door(follower, door)
						if barricade_res.ok:
							# highlight.
							highlighted_tile = map_pos
							highlight_color = Color.LIGHT_GREEN
							# if mouse down, give order.
							if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
								do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.BARRICADE_MAX if to_the_max else ActorOrder.ActorTasks.BARRICADE_ONE, door.location))
								loop = false
								action_done = true
						else:
							# de-hightlight.
							highlighted_tile = map_pos
							highlight_color = Color.RED
							# if mouse down, illegal.
							if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
								add_message(make_error_message("Can't barricade %s : %s." % [door.the_name, barricade_res.fail_reason]))
								add_message_press_enter()
					else:
						# de-hightlight.
						highlighted_tile = map_pos
						highlight_color = Color.RED
				# visible
				else:
					# de-hightlight.
					highlighted_tile = map_pos
					highlight_color = Color.RED

	# return if we did an action.
	return action_done

func handle_player_order_follower_to_guard(_player: Actor, follower: Actor, follower_fov: Dictionary) -> bool:
	var loop := true
	var action_done := false
	var map: Map = _player.location.map
	var highlighted_tile: Variant = null  # Vector2i or null
	var highlight_color := Color.WHITE

	while loop:
		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		if highlighted_tile != null:
			add_overlay(OverlayRect.new(highlight_color, Rect2i(map_to_screen(highlighted_tile), Vector2i(TILE_SIZE, TILE_SIZE))))
		clear_messages()
		add_message(Message.new("Ordering %s to guard..." % follower.name, session.world_time.turn_counter, Color.YELLOW))
		add_message(Message.new("<LMB> on a map position.", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var input: Dictionary = wait_key_or_mouse()
		var key = input.key
		var mouse_pos = input.mouse_pos
		var mouse_buttons = input.mouse_buttons

		if key != null:
			if key.keycode == KEY_ESCAPE:
				loop = false
		else:
			# Get map position in view rect.
			var map_pos: Vector2i = mouse_to_map(mouse_pos)
			if map.is_in_bounds_p(map_pos) and is_in_view_rect(map_pos):
				# must be in player & follower FoV.
				if is_visible_to_player(map, map_pos) and map_pos in follower_fov:
					# Check if walkable here or same spot.
					var walk_res: Dictionary = rules.is_walkable_for(follower, map, map_pos.x, map_pos.y)
					var reason: String = walk_res.get("fail_reason", "")
					if map_pos == follower.location.position or walk_res.ok:
						# highlight.
						highlighted_tile = map_pos
						highlight_color = Color.LIGHT_GREEN
						# if mouse down, give order.
						if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
							do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.GUARD, Location.new(map, map_pos)))
							loop = false
							action_done = true
					else:
						# de-hightlight.
						highlighted_tile = map_pos
						highlight_color = Color.RED
						# if mouse down, illegal.
						if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
							add_message(make_error_message("Can't guard here : %s" % reason))
							add_message_press_enter()
				# visible
				else:
					# de-hightlight.
					highlighted_tile = map_pos
					highlight_color = Color.RED

	# return if we did an action.
	return action_done


func handle_player_order_follower_to_patrol(_player: Actor, follower: Actor, follower_fov: Dictionary) -> bool:
	var loop := true
	var action_done := false
	var map: Map = _player.location.map
	var highlighted_tile: Variant = null  # Vector2i or null
	var highlight_color := Color.WHITE

	while loop:
		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		if highlighted_tile != null:
			add_overlay(OverlayRect.new(highlight_color, Rect2i(map_to_screen(highlighted_tile), Vector2i(TILE_SIZE, TILE_SIZE))))
			var zones_here: Array[Zone] = map.get_zones_at(highlighted_tile.x, highlighted_tile.y)
			if not zones_here.is_empty():
				var zones_names: Array[String] = []
				zones_names.append("Zone(s) here :")
				for i in zones_here.size():
					zones_names.append("- %s" % zones_here[i].name)
				add_overlay(OverlayPopup.new(zones_names, Color.WHITE, Color.WHITE, POPUP_FILLCOLOR, map_to_screen(highlighted_tile + Vector2i(1, 1))))
		clear_messages()
		add_message(Message.new("Ordering %s to patrol..." % follower.name, session.world_time.turn_counter, Color.YELLOW))
		add_message(Message.new("<LMB> on a map position.", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var input: Dictionary = wait_key_or_mouse()
		var key = input.key
		var mouse_pos = input.mouse_pos
		var mouse_buttons = input.mouse_buttons

		if key != null:
			if key.keycode == KEY_ESCAPE:
				loop = false
		else:
			# Get map position in view rect.
			var map_pos: Vector2i = mouse_to_map(mouse_pos)
			if map.is_in_bounds_p(map_pos) and is_in_view_rect(map_pos):
				# must be in player & follower FoV.
				if is_visible_to_player(map, map_pos) and map_pos in follower_fov:
					var valid_patrol := true
					var reason := ""

					# Must have a zone.
					if map.get_zones_at(map_pos.x, map_pos.y).is_empty():
						valid_patrol = false
						reason = "no zone here"
					# Check if walkable here or same spot.
					else:
						var walk_res: Dictionary = rules.is_walkable_for(follower, map, map_pos.x, map_pos.y)
						reason = walk_res.get("fail_reason", "")
						if not (map_pos == follower.location.position or walk_res.ok):
							valid_patrol = false

					if valid_patrol:
						# highlight.
						highlighted_tile = map_pos
						highlight_color = Color.LIGHT_GREEN
						# if mouse down, give order.
						if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
							do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.PATROL, Location.new(map, map_pos)))
							loop = false
							action_done = true
					else:
						# de-hightlight.
						highlighted_tile = map_pos
						highlight_color = Color.RED
						# if mouse down, illegal.
						if mouse_buttons != null and mouse_buttons == MOUSE_BUTTON_LEFT:
							add_message(make_error_message("Can't patrol here : %s" % reason))
							add_message_press_enter()
				# visible
				else:
					# de-hightlight.
					highlighted_tile = map_pos
					highlight_color = Color.RED

	# return if we did an action.
	return action_done


func handle_player_order_follower_to_drop_all_items(_player: Actor, follower: Actor) -> bool:
	# if no items, nothing to drop.
	if follower.inventory.is_empty:
		return false

	# do give order.
	do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.DROP_ALL_ITEMS, follower.location))

	# emote.
	do_say(follower, _player, "Well ok...", Sayflags.IS_FREE_ACTION)

	# update trust. 1 give item penalty per items to drop.
	modify_actor_trust_in_leader(follower, follower.inventory.count_items * Rules.TRUST_GIVE_ITEM_ORDER_PENALTY, true)

	# done.
	return true


func handle_player_order_follower_to_report(_player: Actor, follower: Actor) -> bool:
	# just give the order.
	do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.REPORT_EVENTS, follower.location))

	# done.
	return true


func handle_player_order_follower_to_sleep(_player: Actor, follower: Actor) -> bool:
	# just give the order.
	do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.SLEEP_NOW, follower.location))

	# done.
	return true


func handle_player_order_follower_to_toggle_follow(_player: Actor, follower: Actor) -> bool:
	# just give the order.
	do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.FOLLOW_TOGGLE, follower.location))

	# done.
	return true


func handle_player_order_follower_to_report_position(_player: Actor, follower: Actor) -> bool:
	# just give the order.
	do_give_order_to(_player, follower, ActorOrder.new(ActorOrder.ActorTasks.WHERE_ARE_YOU, follower.location))

	# done.
	return true

func handle_player_order_follower_to_give_items(_player: Actor, follower: Actor) -> bool:
	# sanity checks.
	if follower.inventory == null or follower.inventory.is_empty:
		clear_messages()
		add_message(make_error_message("%s has no items to give." % follower.the_name))
		add_message_press_enter()
		return false
	# must be adjacent.
	if _player.location.map != follower.location.map or not rules.is_adjacent(_player.location.position, follower.location.position):
		clear_messages()
		add_message(make_error_message("%s is not next to you." % follower.the_name))
		add_message_press_enter()
		return false

	# loop.
	var loop := true
	var action_done := false

	var i_first_item := 0
	const max_it_on_page: int = MAX_MESSAGES - 2
	var fo_inventory: Inventory = follower.inventory
	while loop:
		# 1. Redraw
		clear_overlays()
		add_overlay(OverlayPopup.new(ORDER_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))
		clear_messages()
		add_message(Message.new("Ordering %s to give..." % follower.name, session.world_time.turn_counter, Color.YELLOW))

		var it_shown := 0
		while it_shown < max_it_on_page and (i_first_item + it_shown < fo_inventory.count_items):
			var i_it: int = i_first_item + it_shown
			add_message(Message.new("%s. %s/%s %s." % [1 + it_shown, i_it + 1, fo_inventory.count_items, describe_item_short(fo_inventory.get_item_at(i_it))], session.world_time.turn_counter, Color.LIGHT_GREEN))
			it_shown += 1
		if it_shown < fo_inventory.count_items:
			add_message(Message.new("9. next", session.world_time.turn_counter, Color.LIGHT_GREEN))
		redraw_play_screen()

		# 2. Get input.
		var key: InputEventKey = ui.ui_wait_key()
		var choice: int = key_to_choice_number(key.keycode)

		# 3. Handle input
		if key.keycode == KEY_ESCAPE:
			loop = false
		elif choice == 9:
			i_first_item += max_it_on_page
			if i_first_item >= fo_inventory.count_items:
				i_first_item = 0
		elif choice >= 1 and choice <= it_shown:
			# get item.
			var i: int = i_first_item + choice - 1
			var it: Item = fo_inventory.get_item_at(i)

			# try to do it.
			var give_res: Dictionary = rules.can_actor_give_item_to(follower, _player, it)
			if give_res.ok:
				do_give_item_to(follower, _player, it)
				loop = false
				action_done = true
			else:
				clear_messages()
				add_message(make_error_message("%s cannot give %s : %s." % [follower.the_name, describe_item_short(it), give_res.fail_reason]))
				add_message_press_enter()

	# done.
	return action_done
#endregion


## Budget-AI fast turn (turbo_sim). Smoke-and-mirrors approximation of the
## full action graph on maps the player cannot currently see: melee if an
## enemy is adjacent (same combat primitive, no RouteFinder/FOV), wait
## otherwise; flat gauges decay like next_map_turn's per-turn block dies;
## starvation zombification rolls through the same rules as the slow path.
func do_fast_turn(actor: Actor) -> void:
	var map: Map = actor.location.map
	# Gauges: flat per-turn decay; living actors only (undead don't hunger).
	if actor.model == null or not actor.model.abilities.is_undead:
		actor.food_points -= 1
		actor.sleep_points -= 1
		if actor.food_points <= 0:
			actor.food_points = 0
			kill_actor(actor, actor, "starved to death")
			if rules.has_immediate_zombification(session.game_mode) \
					and rules.roll_chance(options.starved_zombification_chance):
				zombify(null, actor, false)
			return
	# Melee-or-wait: any adjacent enemy, fought with the same primitive.
	for d: Direction in Direction.COMPASS:
		var enemy: Actor = map.get_actor_at(actor.location.plus(d).position)
		if enemy != null and rules.are_enemies(actor, enemy):
			do_melee_attack(actor, enemy)
			return
	do_wait(actor)


func handle_ai_actor(ai_actor: Actor) -> void:
	# Budget-AI fast turn (turbo_sim): off-screen maps fake the full action
	# graph; the player's own map always keeps full fidelity.
	if options.turbo_sim and ai_actor.location != null \
			and ai_actor.location.map != session.current_map:
		do_fast_turn(ai_actor)
		return
	# Guard: actor may have been removed from its map by a chain reaction
	# (explosion, trap) earlier this turn; skip if location is invalid.
	if ai_actor.location == null or ai_actor.location.map == null:
		spend_actor_action_points(ai_actor, Rules.BASE_ACTION_COST)
		return
	# Get and perform action from AI controler.
	var desired_action: ActorAction = ai_actor.controller.get_action(self)

	# Insane effect?
	if rules.is_actor_insane(ai_actor) and rules.roll_chance(Rules.SANITY_INSANE_ACTION_CHANCE):
		var insane_action: ActorAction = generate_insane_action(ai_actor)
		if insane_action != null and insane_action.is_legal():
			desired_action = insane_action

	# Do action.
	if desired_action != null:
		if desired_action.is_legal():
			desired_action.perform()
		else:
			# AI attempted illegal action.
			spend_actor_action_points(ai_actor, Rules.BASE_ACTION_COST)

			# alpha10.1: C# throws in DEBUG builds; release build complains and waits instead.
			do_wait(ai_actor)
			do_emote(ai_actor, "My AI attempted an illegal action, I'll  wait instead of crashing your game :)", true)
	else:
		# Safety net: BaseAI.get_action falls back to ActionWait, so this
		# should never fire; warn (not error) since the game recovers.
		push_warning("AI returned null action, forcing a wait.")
		# Spend AP so the actor doesn't get re-selected in an infinite loop.
		spend_actor_action_points(ai_actor, Rules.BASE_ACTION_COST)
		do_wait(ai_actor)


func handle_advisor(_p_player: Actor) -> void:
	# If all hints given, say so.
	if hints.has_advisor_given_all_hints():
		show_advisor_message("YOU KNOW THE BASICS!", [
			"The Advisor has given you all the hints.",
			"You can disable the advisor in the options.",
			"Read the manual or discover the rest of the game by yourself.",
			"Good luck and have fun!",
			"To REDEFINE THE KEYS : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.KEYBINDING_MODE)),
			"To CHANGE OPTIONS    : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.OPTIONS_MODE)),
			"To READ THE MANUAL   : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.HELP_MODE)),
		])
		return

	# Show the first appliable hint.
	for i in range(GameHintsStatus.AdvisorHint._FIRST, GameHintsStatus.AdvisorHint._COUNT):
		if hints.is_advisor_hint_given(i):
			continue
		if is_advisor_hint_appliable(i):
			advisor_give_hint(i)
			return

	# no hint.
	show_advisor_message("No hint available.", [
		"The Advisor has now new hint for you in this situation.",
		"You will see a popup when he has something to say.",
		"To REDEFINE THE KEYS : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.KEYBINDING_MODE)),
		"To CHANGE OPTIONS    : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.OPTIONS_MODE)),
		"To READ THE MANUAL   : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.HELP_MODE)),
	])


# alpha10
# returns -1 if none
func get_advisor_first_available_hint() -> int:
	for i in range(GameHintsStatus.AdvisorHint._FIRST, GameHintsStatus.AdvisorHint._COUNT):
		if hints.is_advisor_hint_given(i):
			continue
		if is_advisor_hint_appliable(i):
			return i
	return -1


func advisor_give_hint(hint: int) -> void:
	# Mark as given
	hints.set_advisor_hint_as_given(hint)
	# Save status.
	save_hints()
	# Show
	show_advisor_hint(hint)


func is_advisor_hint_appliable(hint: int) -> bool:
	var map: Map = player.location.map
	var pos: Vector2i = player.location.position

	match hint:
		GameHintsStatus.AdvisorHint.ACTOR_MELEE:  # adjacent to an enemy.
			return is_adjacent_to_enemy(map, pos, player)
		GameHintsStatus.AdvisorHint.BARRICADE:  # barricading.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var door := map.get_map_object_at(pt) as DoorWindow
				if door == null:
					return false
				return rules.can_actor_barricade_door(player, door)["ok"])
		GameHintsStatus.AdvisorHint.BUILD_FORTIFICATION:  # building fortifications.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				return rules.can_actor_build_fortification(player, pt, false)["ok"])
		GameHintsStatus.AdvisorHint.CELLPHONES:
			return player.inventory.get_first_by_model(game_items.cell_phone()) != null
		GameHintsStatus.AdvisorHint.CITY_INFORMATION:  # city information, wait a bit...
			return map.local_time.hour >= 12
		GameHintsStatus.AdvisorHint.CORPSE:
			return not player.model.abilities.is_undead and map.get_corpses_at(pos) != null
		GameHintsStatus.AdvisorHint.CORPSE_EAT:
			return player.model.abilities.is_undead and map.get_corpses_at(pos) != null
		GameHintsStatus.AdvisorHint.DOORWINDOW_OPEN:  # can open an adj door/window.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var door := map.get_map_object_at(pt) as DoorWindow
				if door == null:
					return false
				return rules.is_openable_for(player, door)["ok"])
		GameHintsStatus.AdvisorHint.DOORWINDOW_CLOSE:  # can close an open door/window.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var door := map.get_map_object_at(pt) as DoorWindow
				if door == null:
					return false
				return rules.is_closable_for(player, door)["ok"])
		GameHintsStatus.AdvisorHint.EXIT_STAIRS_LADDERS:  # using stairs, ladders.
			return map.get_exit_at(pos) != null
		GameHintsStatus.AdvisorHint.EXIT_LEAVING_DISTRICT:  # leaving the district.
			for d in Direction.COMPASS:
				var pt: Vector2i = pos + d.vector
				if map.is_in_bounds_p(pt):
					continue
				if map.get_exit_at(pt) != null:
					return true
			return false
		GameHintsStatus.AdvisorHint.FLASHLIGHT:
			return player.inventory.has_item_of_type(ItemLight)
		GameHintsStatus.AdvisorHint.GAME_SAVE_LOAD:  # saving/loading. wait a bit...
			return map.local_time.hour >= 7
		GameHintsStatus.AdvisorHint.GRENADE:
			var inv: Inventory = player.inventory
			if inv == null or inv.is_empty:
				return false
			return inv.has_item_of_type(ItemGrenade)
		GameHintsStatus.AdvisorHint.ITEM_GRAB_CONTAINER:  # can take an item from an adjacent container.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				return rules.can_actor_get_item_from_container(player, pt)["ok"])
		GameHintsStatus.AdvisorHint.ITEM_GRAB_FLOOR:  # can take an item from the floor.
			var inv_there: Inventory = map.get_items_at(pos)
			if inv_there == null:
				return false
			for it in inv_there.items:
				if rules.can_actor_get_item(player, it)["ok"]:
					return true
			return false
		GameHintsStatus.AdvisorHint.ITEM_EQUIP:  # equip an item.
			var inv2: Inventory = player.inventory
			if inv2 == null or inv2.is_empty:
				return false
			for it in inv2.items:
				if not it.is_equipped and rules.can_actor_equip_item(player, it)["ok"]:
					return true
			return false
		GameHintsStatus.AdvisorHint.ITEM_UNEQUIP:  # unequip an item.
			var inv3: Inventory = player.inventory
			if inv3 == null or inv3.is_empty:
				return false
			for it in inv3.items:
				if rules.can_actor_unequip_item(player, it)["ok"]:
					return true
			return false
		GameHintsStatus.AdvisorHint.ITEM_DROP:  # dropping an item.
			var inv4: Inventory = player.inventory
			if inv4 == null or inv4.is_empty:
				return false
			for it in inv4.items:
				if rules.can_actor_drop_item(player, it)["ok"]:
					return true
			return false
		GameHintsStatus.AdvisorHint.ITEM_TYPE_BARRICADING:  # barricading material.
			var inv5: Inventory = player.inventory
			if inv5 == null or inv5.is_empty:
				return false
			return inv5.has_item_of_type(ItemBarricadeMaterial)
		GameHintsStatus.AdvisorHint.ITEM_USE:  # using an item.
			var inv6: Inventory = player.inventory
			if inv6 == null or inv6.is_empty:
				return false
			for it in inv6.items:
				if rules.can_actor_use_item(player, it)["ok"]:
					return true
			return false
		GameHintsStatus.AdvisorHint.KEYS_OPTIONS:  # redefining keys & options.
			return true
		GameHintsStatus.AdvisorHint.LEADING_CAN_RECRUIT:  # can recruit follower.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return rules.can_actor_take_lead(player, other)["ok"])
		GameHintsStatus.AdvisorHint.LEADING_GIVE_ORDERS:  # give orders to followers.
			return player.count_followers > 0
		GameHintsStatus.AdvisorHint.LEADING_NEED_SKILL:  # could recruit...
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return not rules.are_enemies(player, other))
		GameHintsStatus.AdvisorHint.LEADING_SWITCH_PLACE:  # switch place.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return rules.can_actor_switch_place_with(player, other)["ok"])
		GameHintsStatus.AdvisorHint.MOUSE_LOOK:  # always!
			return map.local_time.turn_counter >= 2  # don't spam at turn 0.
		GameHintsStatus.AdvisorHint.MOVE_BASIC:  # always!
			return true
		GameHintsStatus.AdvisorHint.MOVE_JUMP:  # can jump.
			return not rules.is_actor_tired(player) and \
				map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
					var obj: MapObject = map.get_map_object_at(pt)
					if obj == null:
						return false
					return obj.is_jumpable)
		GameHintsStatus.AdvisorHint.MOVE_RUN:  # running.
			return map.local_time.turn_counter >= 5 and rules.can_actor_run(player)["ok"]  # don't spam at turn 0.
		GameHintsStatus.AdvisorHint.MOVE_RESTING:  # resting.
			return rules.is_actor_tired(player)
		GameHintsStatus.AdvisorHint.NIGHT:  # night effects, wait a bit.
			return map.local_time.turn_counter >= 1 * WorldTime.TURNS_PER_HOUR
		GameHintsStatus.AdvisorHint.NPC_TRADE:  # trading.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return rules.can_actor_initiate_trade_with(player, other)["ok"])
		GameHintsStatus.AdvisorHint.NPC_GIVING_ITEM:  # giving items.
			var inv7: Inventory = player.inventory
			if inv7 == null or inv7.is_empty:
				return false
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return not rules.are_enemies(player, other))
		GameHintsStatus.AdvisorHint.NPC_SHOUTING:  # shouting.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return other.is_sleeping and not rules.are_enemies(player, other))
		GameHintsStatus.AdvisorHint.OBJECT_BREAK:  # breaking around.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var obj: MapObject = map.get_map_object_at(pt)
				if obj == null:
					return false
				return rules.is_breakable_for(player, obj)["ok"])
		GameHintsStatus.AdvisorHint.OBJECT_PUSH:  # pushable around.
			return map.has_any_adjacent_in_map(pos, func(pt: Vector2i) -> bool:
				var obj: MapObject = map.get_map_object_at(pt)
				if obj == null:
					return false
				return rules.can_actor_push(player, obj))
		GameHintsStatus.AdvisorHint.RAIN:  # rainy weather, wait a bit.
			return rules.is_weather_rain(session.world.weather) and map.local_time.turn_counter >= 2 * WorldTime.TURNS_PER_HOUR
		GameHintsStatus.AdvisorHint.SPRAYS_PAINT:  # using spraypaint.
			return player.inventory.has_item_of_type(ItemSprayPaint)
		GameHintsStatus.AdvisorHint.SPRAYS_SCENT:  # using scent sprays.
			return player.inventory.has_item_of_type(ItemSprayScent)
		GameHintsStatus.AdvisorHint.STATE_HUNGRY:
			return rules.is_actor_hungry(player)
		GameHintsStatus.AdvisorHint.STATE_SLEEPY:
			return rules.is_actor_sleepy(player)
		GameHintsStatus.AdvisorHint.WEAPON_FIRE:  # can fire a weapon.
			var rw: ItemRangedWeapon = player.get_equipped_weapon() as ItemRangedWeapon
			if rw == null:
				return false
			return rw.ammo >= 0
		GameHintsStatus.AdvisorHint.WEAPON_RELOAD:  # reloading a weapon.
			var rw2: ItemRangedWeapon = player.get_equipped_weapon() as ItemRangedWeapon
			if rw2 == null:
				return false
			var inv8: Inventory = player.inventory
			if inv8 == null or inv8.is_empty:
				return false
			for it in inv8.items:
				if it is ItemAmmo and rules.can_actor_use_item(player, it)["ok"]:
					return true
			return false
		# alpha10 new hints
		GameHintsStatus.AdvisorHint.SANITY:  # sanity
			return player.sanity < 0.80 * rules.actor_max_sanity(player)
		GameHintsStatus.AdvisorHint.INFECTION:
			return player.infection > 0
		GameHintsStatus.AdvisorHint.TRAPS:
			return player.inventory.has_item_of_type(ItemTrap)
		_:
			push_error("unhandled hint")
			return false


# C# out params -> returned Dictionary {"title": String, "body": Array}
func get_advisor_hint_text(hint: int) -> Dictionary:
	var title := ""
	var body: Array = []
	match hint:
		GameHintsStatus.AdvisorHint.ACTOR_MELEE:
			title = "ATTACK AN ENEMY IN MELEE"
			body = [
				"You are next to an enemy.",
				"To ATTACK him, try to MOVE on him."]
		GameHintsStatus.AdvisorHint.BARRICADE:
			title = "BARRICADING A DOOR/WINDOW"
			body = [
				"You can barricade an adjacent door or window.",
				"Barricading uses material such as planks.",
				"To BARRICADE : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BARRICADE_MODE))]
		GameHintsStatus.AdvisorHint.BUILD_FORTIFICATION:
			title = "BUILDING FORTIFICATIONS"
			body = [
				"You can now build fortifications thanks to the carpentry skill.",
				"You need enough barricading materials.",
				"To BUILD SMALL FORTIFICATIONS : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BUILD_SMALL_FORTIFICATION)),
				"To BUILD LARGE FORTIFICATIONS : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BUILD_LARGE_FORTIFICATION))]
		GameHintsStatus.AdvisorHint.CELLPHONES:
			title = "CELLPHONES"
			body = [
				"You have found a cellphone.",
				"Cellphones are useful to keep contact with your follower(s).",
				"You and your follower(s) must have a cellphone equipped.",
				"You can recharge cellphones at power generators."]
		GameHintsStatus.AdvisorHint.CITY_INFORMATION:
			title = "CITY INFORMATION"
			body = [
				"You know the layout of your town.",
				"You aso know the most notable locations.",
				"To VIEW THE CITY INFORMATION : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.CITY_INFO))]
		# alpha10 merged corpses hints
		GameHintsStatus.AdvisorHint.CORPSE:
			title = "CORPSES"
			body = [
				"You are standing on a CORPSE.",
				"Corpses will slowly rot away but may resurrect as zombies.",
				"You can BUTCHER a corpse as a way to prevent that.",
				"You can also DRAG corpses to move them.",
				"You can try to REVIVE corpses if you have the medic skill and a medikit.",
				"If you are desperate and starving you can resort to cannibalism by EATING corpses.",
				"To act, hover the mouse on it in the corpse list and...",
				"TO BUTCHER the CORPSE : <RMB>",
				"TO DRAG the CORPSE : <LMB>",
				"TO REVIVE the CORPSE : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.REVIVE_CORPSE)),
				"TO EAT the CORPSE : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.EAT_CORPSE))]
		GameHintsStatus.AdvisorHint.CORPSE_EAT:
			title = "EATING CORPSES"
			body = [
				"You can eat a corpse to regain health.",
				"TO EAT A CORPSE : <RMB> on it in the corpse list."]
		GameHintsStatus.AdvisorHint.DOORWINDOW_OPEN:
			title = "OPENING A DOOR/WINDOW"
			body = [
				"You are next to a closed door or window.",
				"To OPEN it, try to MOVE on it."]
		GameHintsStatus.AdvisorHint.DOORWINDOW_CLOSE:
			title = "CLOSING A DOOR/WINDOW"
			body = [
				"You are next to an open door or window.",
				"To CLOSE : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.CLOSE_DOOR))]
		GameHintsStatus.AdvisorHint.EXIT_STAIRS_LADDERS:
			title = "USING STAIRS & LADDERS"
			body = [
				"You are standing on stairs or a ladder.",
				"You can use this exit to go on another map.",
				"To USE THE EXIT : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.USE_EXIT))]
		GameHintsStatus.AdvisorHint.FLASHLIGHT:
			title = "LIGHTING"
			body = [
				"You have found a lighting item, such as a flashlight.",
				"Equip the item to increase your view distance (FoV).",
				"Standing next to someone with a light on has the same effect.",
				"You can recharge flashlights at power generators."]
		GameHintsStatus.AdvisorHint.GAME_SAVE_LOAD:
			title = "SAVING AND LOADING GAME"
			body = [
				"Now could be a good time to save your game.",
				"You can have only one save game active.",
				"To SAVE THE GAME : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.SAVE_GAME)),
				"To LOAD THE GAME : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.LOAD_GAME)),
				"You can also load the game from the main menu.",
				"Saving or loading can take a bit of time, please be patient.",
				"Or consider turning some game options to lower settings."]
		GameHintsStatus.AdvisorHint.EXIT_LEAVING_DISTRICT:
			title = "LEAVING THE DISTRICT"
			body = [
				"You are next to a district EXIT.",
				"You can leave this district by MOVING into the exit."]
		GameHintsStatus.AdvisorHint.GRENADE:
			title = "GRENADES"
			body = [
				"You have found a grenade.",
				"To THROW a GRENADE, EQUIP it and FIRE it.",
				"To FIRE : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.FIRE_MODE))]
		GameHintsStatus.AdvisorHint.ITEM_GRAB_CONTAINER:
			title = "TAKING AN ITEM FROM A CONTAINER"
			body = [
				"You are next to a container, such as a wardrobe or a shelf.",
				"You can TAKE the item there by MOVING into the object."]
		GameHintsStatus.AdvisorHint.ITEM_GRAB_FLOOR:
			title = "TAKING AN ITEM FROM THE FLOOR"
			body = [
				"You are standing on a stack of items.",
				"The items are listed on the right panel in the ground inventory.",
				"To TAKE an item, move your mouse on the item on the ground inventory and <LMB>.",
				"Shortcut : <Ctrl-item slot number>."]
		GameHintsStatus.AdvisorHint.ITEM_DROP:
			title = "DROPPING AN ITEM"
			body = [
				"You can drop items from your inventory.",
				"To DROP an item, <RMB> on it.",
				"The item must be unequiped first."]
		GameHintsStatus.AdvisorHint.ITEM_EQUIP:
			title = "EQUIPING AN ITEM"
			body = [
				"You have an equipable item in your inventory.",
				"Typical equipable items are weapons, lights and phones.",
				"To EQUIP the item, <LMB> on it in your inventory.",
				"Shortcut : <Ctrl-item slot number>"]
		GameHintsStatus.AdvisorHint.ITEM_TYPE_BARRICADING:
			title = "ITEM - BARRICADING MATERIAL"
			body = [
				"You have some barricading materials, such as planks.",
				"Barricading material is used when you barricade doors/windows or build fortifications.",
				"To build fortifications you need the CARPENTRY skill."]
		GameHintsStatus.AdvisorHint.ITEM_UNEQUIP:
			title = "UNEQUIPING AN ITEM"
			body = [
				"You have equiped an item.",
				"The item is displayed with a green background.",
				"To UNEQUIP the item, <LMB> on it in your inventory.",
				"Shortcut: <Ctrl-item slot number>"]
		GameHintsStatus.AdvisorHint.ITEM_USE:
			title = "USING AN ITEM"
			body = [
				"You can use one of your item.",
				"Typical usable items are food, medecine and ammunition.",
				"To USE the item, <LMB> on it in your inventory.",
				"Shortcut: <Ctrl-item slot number>"]
		GameHintsStatus.AdvisorHint.KEYS_OPTIONS:
			title = "KEYS & OPTIONS"
			body = [
				"You can view and redefine the KEYS by pressing <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.KEYBINDING_MODE)),
				"You can change OPTIONS by pressing <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.OPTIONS_MODE)),
				"Some option changes will only take effect when starting a new game.",
				"Keys and Options are saved."]
		GameHintsStatus.AdvisorHint.LEADING_CAN_RECRUIT:
			title = "LEADING - RECRUITING"
			body = [
				"You can recruit a follower next to you!",
				"To RECRUIT : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.LEAD_MODE))]
		GameHintsStatus.AdvisorHint.LEADING_GIVE_ORDERS:
			title = "LEADING - GIVING ORDERS"
			body = [
				"You can give orders and directives to your follower.",
				"You can also fire your followers.",
				"To GIVE ORDERS : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.ORDER_MODE)),
				"To FIRE YOUR FOLLOWER : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.LEAD_MODE))]
		GameHintsStatus.AdvisorHint.LEADING_NEED_SKILL:
			title = "LEADING - LEADERSHIP SKILL"
			body = [
				"You can try to recruit a follower if you have the LEADERSHIP skill.",
				"The higher the skill, the more followers you can recruit."]
		GameHintsStatus.AdvisorHint.LEADING_SWITCH_PLACE:
			title = "LEADING - SWITCHING PLACE"
			body = [
				"You can switch place with followers next to you.",
				"To SWITCH PLACE : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.SWITCH_PLACE))]
		GameHintsStatus.AdvisorHint.MOUSE_LOOK:
			title = "LOOKING WITH THE MOUSE"
			body = [
				"You can LOOK at actors and objects on the map.",
				"Move the MOUSE over something interesting.",
				"You will get a detailed description of the actor or object.",
				"This is useful to learn the game or assessing the tactical situation."]
		GameHintsStatus.AdvisorHint.MOVE_BASIC:
			title = "MOVEMENT - DIRECTIONS"
			body = [
				"MOVE your character around with the movements keys.",
				"The default keys are your NUMPAD numbers.",
				"",
				"7 8 9",
				"4 - 6",
				"1 2 3",
				"",
				"5 makes you WAIT one turn.",
				"The move keys are the most important ones.",
				"When asked for a DIRECTION, press a MOVE key.",
				"Be sure to remember that!",
				"...and remember to keep NumLock on!"]
		GameHintsStatus.AdvisorHint.MOVE_JUMP:
			title = "MOVEMENT - JUMPING"
			body = [
				"You can JUMP on or over an obstacle next to you.",
				"Typical jumpable objects are cars, fences and furniture.",
				"The object is described with 'Can be jumped on'.",
				"Some enemies can't jump and won't be able to follow you.",
				"Jumping is tiring and spends stamina.",
				"To jump, just MOVE on the obstacle."]
		GameHintsStatus.AdvisorHint.MOVE_RUN:
			title = "MOVEMENT - RUNNING"
			body = [
				"You can RUN to move faster.",
				"Running is tiring and spend stamina.",
				"To TOGGLE RUNNING : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.RUN_TOGGLE))]
		GameHintsStatus.AdvisorHint.MOVE_RESTING:
			title = "MOVEMENT - RESTING"
			body = [
				"You are TIRED because you lost too much STAMINA.",
				"Being tired is bad for you!",
				"You move slowly.",
				"You can't do tiring activities such as running, fighting and jumping.",
				"You always recover a bit of stamina each turn.",
				"But you can REST to recover stamina faster.",
				"To REST/WAIT : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.WAIT_OR_SELF))]
		GameHintsStatus.AdvisorHint.NIGHT:
			title = "NIGHT TIME"
			body = [
				"It is night. Night time is penalizing for livings.",
				"They tire faster (stamina and sleep) and don't see very far.",
				"Undeads are not penalized by night at all."]
		GameHintsStatus.AdvisorHint.NPC_GIVING_ITEM:
			title = "GIVING ITEMS"
			body = [
				"You can GIVE ITEMS to other actors.",
				"To GIVE AN ITEM : move the mouse over your item and press <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.GIVE_ITEM))]
		GameHintsStatus.AdvisorHint.NPC_SHOUTING:
			title = "SHOUTING"
			body = [
				"Someone is sleeping near you.",
				"You can SHOUT to try to wake him or her up.",
				"Other actors can also shout to wake their friends up when they see danger.",
				"To SHOUT : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.SHOUT))]
		GameHintsStatus.AdvisorHint.NPC_TRADE:
			title = "TRADING"
			body = [
				"You can TRADE with an actor next to you.",
				"Actor that can trade with you have a $ icon on the map.",
				"Trading means exhanging items.",
				"To ask for a TRADE offer, just try to MOVE into the actor and accept or refuse the offer.",
				"You can also initiate a more detailled trade negociation.",
				"To NEGOCIATE A TRADE : press <%s> and select an npc with the directions." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.NEGOCIATE_TRADE))]
		GameHintsStatus.AdvisorHint.OBJECT_BREAK:
			title = "BREAKING OBJECTS"
			body = [
				"You can try to BREAK an object around you.",
				"Typical breakable objects are furnitures, doors and windows.",
				"To BREAK : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BREAK_MODE))]
		GameHintsStatus.AdvisorHint.OBJECT_PUSH:  # alpha10 also pulling and mention shoving actors
			title = "PUSHING/PULLING OBJECTS"
			body = [
				"You can PUSH/PULL an OBJECT around you.",
				"Only MOVABLE objects can be pushed/pulled.",
				"Movable objects will be described as 'Can be moved'",
				"You can also PUSH/PULL ACTORS around you.",
				"To PUSH : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.PUSH_MODE)),
				"To PULL : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.PULL_MODE))]
		GameHintsStatus.AdvisorHint.RAIN:
			title = "RAIN"
			body = [
				"It is raining. Rain has various effects.",
				"Livings vision is reduced.",
				"Firearms have more chance to jam.",
				"Scents evaporate faster."]
		GameHintsStatus.AdvisorHint.SPRAYS_PAINT:
			title = "SPRAYS - SPRAYPAINT"
			body = [
				"You have found a can of spraypaint.",
				"You can tag a symbol on walls and floors.",
				"This is useful to mark some places and locations.",
				"To SPRAY : equip the spray and press <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.USE_SPRAY))]
		GameHintsStatus.AdvisorHint.SPRAYS_SCENT:
			title = "SPRAYS - SCENT SPRAY"
			body = [
				"You have found a scent spray.",
				"You can spray some perfurme on yourself or another adjacent actor.",
				"This is useful to confuse the undeads because they hunt using their smell.",
				"To SPRAY : equip the spray and press <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.USE_SPRAY))]
		GameHintsStatus.AdvisorHint.STATE_HUNGRY:
			title = "STATE - HUNGRY"
			body = [
				"You are HUNGRY.",
				"If you become starved you can die!",
				"You should EAT soon.",
				"To eat, just USE a food item, such as groceries.",
				"Read the manual for more explanations on hunger."]
		GameHintsStatus.AdvisorHint.STATE_SLEEPY:
			title = "STATE - SLEEPY"
			body = [
				"You are SLEEPY.",
				"This is bad for you!",
				"You have a number of penalties.",
				"You should find a place to SLEEP.",
				"Couches are good places to sleep.",
				"To SLEEP : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.SLEEP)),
				"Read the manual for more explanations on sleep."]
		GameHintsStatus.AdvisorHint.WEAPON_FIRE:
			title = "FIRING A WEAPON"
			body = [
				"You can fire your equiped ranged weapon.",
				"You need to have valid targets.",
				"To fire on a target you need ammunitions and a clear line of fine.",
				"The target must be within the weapon range.",
				"The closer the target is, the easier it is to hit and it does slightly more damage.",
				"To FIRE : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.FIRE_MODE)),
				"When firing you can switch to rapid fire mode : you will shoot twice but at reduced accuracy.",
				"Remember you need to have visible enemies to fire at.",
				"Read the manual for more explanation about firing and ranged weapons."]
		GameHintsStatus.AdvisorHint.WEAPON_RELOAD:
			title = "RELOADING A WEAPON"
			body = [
				"You can reload your equiped ranged weapon.",
				"To RELOAD, just USE a compatible ammo item."]
		# alpha10 new hints
		GameHintsStatus.AdvisorHint.SANITY:  # sanity
			title = "SANITY"
			body = [
				"You should care about your SANITY.",
				"If it gets too low, you can go insane.",
				"Living in this horrible world and seing horrible things will lower your sanity.",
				"You can recover sanity by :",
				"- Talking to people.",
				"- Having followers you trust.",
				"- Killing undeads.",
				"- Using entertainment items.",
				"- Taking pills."]
		GameHintsStatus.AdvisorHint.INFECTION:
			title = "INFECTION"
			body = [
				"You are INFECTED!",
				"Most undeads bites are infectious.",
				"A low infection value will make you sick.",
				"A full infection value is death.",
				"Infection only worsen when you are biten.",
				"Cure the infection with appropriate meds."]
		GameHintsStatus.AdvisorHint.TRAPS:
			title = "TRAPS"
			body = [
				"You are carrying TRAPS.",
				"Traps are a good way to protect places.",
				"Drop activated traps on tiles.",
				"Some traps are activated by dropping them.",
				"Other traps need to be activated before being dropped.",
				"You are always safe from your own traps.",
				"Traps layed by your followers are also safe."]
		_:
			push_error("unhandled hint")
	return {"title": title, "body": body}


func show_advisor_hint(hint: int) -> void:
	var t: Dictionary = get_advisor_hint_text(hint)
	show_advisor_message(t["title"], t["body"])


func show_advisor_message(title: String, lines: Array) -> void:
	# clear.
	clear_messages()
	clear_overlays()

	# tell.
	var text: Array = []
	text.resize(lines.size() + 2)
	text[0] = "HINT : " + title
	for i in lines.size():
		text[i + 1] = lines[i]
	text[lines.size() + 1] = "(hint %d/%d)" % [hints.count_advisor_hints_given(), GameHintsStatus.AdvisorHint._COUNT]
	add_overlay(OverlayPopup.new(text, Color.WHITE, Color.WHITE, Color.BLACK, Vector2i(0, 0)))

	# wait.
	clear_messages()
	add_message(Message.new("You can disable the advisor in the options screen.", session.world_time.turn_counter, Color.WHITE))
	add_message(Message.new("To show the options screen : <%s>." % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.OPTIONS_MODE)), session.world_time.turn_counter, Color.WHITE))
	add_message_press_enter()

	# clear.
	clear_messages()
	clear_overlays()
	redraw_play_screen()


#region Input helpers

# C# out params -> returned Dictionary {"key", "mouse_pos", "mouse_buttons"}
func wait_key_or_mouse() -> Dictionary:
	# Peek keyboard & mouse until we got an event.
	ui.ui_peek_key()  # consume keys to avoid repeats.
	var prev_mouse_pos: Vector2i = ui.ui_get_mouse_position()
	var mouse_pos := Vector2i(-1, -1)
	var mouse_buttons = null
	while true:
		var in_key: InputEventKey = ui.ui_peek_key()
		if in_key != null:
			return {"key": in_key, "mouse_pos": mouse_pos, "mouse_buttons": mouse_buttons}
		else:
			mouse_pos = ui.ui_get_mouse_position()
			var buttons: int = ui.ui_peek_mouse_buttons()
			mouse_buttons = (buttons as Variant) if buttons != 0 else null
			if mouse_pos != prev_mouse_pos or mouse_buttons != null:
				return {"key": null, "mouse_pos": mouse_pos, "mouse_buttons": mouse_buttons}
	return {}


# Loop input until Exit/Cancel or a direction command is issued.
# returns null if Exit/Cancel
func wait_direction_or_cancel() -> Direction:
	while true:
		var in_key: InputEventKey = ui.ui_wait_key()
		var command: int = InputTranslator.key_to_command(in_key)
		if in_key.keycode == KEY_ESCAPE:  # command == PlayerCommand.EXIT_OR_CANCEL)
			return null
		var dir: Direction = command_to_direction(command)
		if dir != null:
			return dir
	return null


func wait_enter() -> void:
	while true:
		var in_key: InputEventKey = ui.ui_wait_key()
		if in_key.keycode == KEY_ENTER:
			return


func wait_escape() -> void:
	while true:
		var in_key: InputEventKey = ui.ui_wait_key()
		if in_key.keycode == KEY_ESCAPE:
			return


# -1 if no choice.
func key_to_choice_number(key: int) -> int:
	match key:
		KEY_KP_0, KEY_0:
			return 0
		KEY_KP_1, KEY_1:
			return 1
		KEY_KP_2, KEY_2:
			return 2
		KEY_KP_3, KEY_3:
			return 3
		KEY_KP_4, KEY_4:
			return 4
		KEY_KP_5, KEY_5:
			return 5
		KEY_KP_6, KEY_6:
			return 6
		KEY_KP_7, KEY_7:
			return 7
		KEY_KP_8, KEY_8:
			return 8
		KEY_KP_9, KEY_9:
			return 9
		_:
			return -1


func wait_yes_or_no() -> bool:
	while true:
		var in_key: InputEventKey = ui.ui_wait_key()
		if in_key.keycode == KEY_Y:
			return true
		elif in_key.keycode == KEY_N or in_key.keycode == KEY_ESCAPE:
			return false
	return false


#endregion

#region Describing a game element

func describe_stuff_at(map: Map, map_pos: Vector2i) -> Array:
	# Actor?
	var actor: Actor = map.get_actor_at(map_pos)
	if actor != null:
		return describe_actor(actor)

	# Object/Items?
	var obj: MapObject = map.get_map_object_at(map_pos)
	if obj != null:
		return describe_map_object(obj, map, map_pos)

	# Items?
	var inv: Inventory = map.get_items_at(map_pos)
	if inv != null and not inv.is_empty:
		return describe_inventory(inv)

	# Corpses?
	var corpses = map.get_corpses_at(map_pos)
	if corpses != null:
		return describe_corpses(corpses)

	# Nothing to describe!
	return []


func describe_actor(actor: Actor) -> Array:
	var lines: Array = []
	lines.resize(10)
	lines.clear()

	# 1. Name-Faction(Gang), Model, SpawnTime, Order & Leader(trust if player), (Murder counter if player law enforcer);
	#    Enemy & Self-Defence.
	if actor.faction != null:
		if actor.is_in_a_gang:
			lines.append("%s, %s-%s." % [capitalize(actor.the_name), actor.faction.member_name, GameGangs.NAMES[actor.gang_id]])
		else:
			lines.append("%s, %s." % [capitalize(actor.the_name), actor.faction.member_name])
	else:
		lines.append("%s." % capitalize(actor.the_name))
	lines.append("%s." % capitalize(actor.model.name))

	lines.append("%s since %s." % ["Undead" if actor.model.abilities.is_undead else "Staying alive", str(WorldTime.new(actor.spawn_time))])
	var ai: AIController = actor.controller as AIController
	if ai != null and ai.order != null:
		lines.append("Order : %s." % str(ai.order))
	if actor.has_leader:
		if actor.leader.is_player:
			if actor.trust_in_leader >= Rules.TRUST_BOND_THRESHOLD:
				lines.append("Trust : BOND.")
			elif actor.trust_in_leader >= Rules.TRUST_MAX:
				lines.append("Trust : MAX.")
			else:
				lines.append("Trust : %d/T:%d-B:%d." % [actor.trust_in_leader, Rules.TRUST_TRUSTING_THRESHOLD, Rules.TRUST_BOND_THRESHOLD])
			var order_ai: OrderableAI = ai as OrderableAI
			if order_ai != null:
				if order_ai.dont_follow_leader:
					lines.append("Ordered to not follow you.")
			# gauges.
			lines.append("Foo : %d %dh" % [actor.food_points, food_to_hours_until_hungry(actor.food_points)])
			lines.append("Slp : %d %dh" % [actor.sleep_points, rules.sleep_to_hours_until_sleepy(actor.sleep_points, actor.location.map.local_time.is_night)])
			lines.append("San : %d %dh" % [actor.sanity, rules.sanity_to_hours_until_unstable(actor)])
			lines.append("Inf : %d %d%%" % [actor.infection, rules.actor_infection_percent(actor)])
		else:
			lines.append("Leader : %s." % capitalize(actor.leader.the_name))

	# show murder counter if trusting follower or player is a law enforcer.
	if actor.murders_counter > 0 and player.model.abilities.is_law_enforcer:
		lines.append("WANTED FOR MURDER!")
		lines.append("%d murder%s!" % [actor.murders_counter, "s" if actor.murders_counter > 1 else ""])
	elif actor.has_leader and actor.leader.is_player and rules.is_actor_trusting_leader(actor):
		if actor.murders_counter > 0:
			lines.append("* Confess %d murder%s! *" % [actor.murders_counter, "s" if actor.murders_counter > 1 else ""])
		else:
			lines.append("Has committed no murders.")
	if actor.is_aggressor_of(player):
		lines.append("Aggressed you.")
	if player.is_self_defence_from(actor):
		lines.append("You can kill %s in self-defence." % him_or_her(actor))
	if player.is_aggressor_of(actor):
		lines.append("You aggressed %s." % him_or_her(actor))
	if actor.is_self_defence_from(player):
		lines.append("Killing you would be self-defence.")
	if not player.faction.is_enemy_of(actor.faction) and rules.are_group_enemies(player, actor):  # alpha10
		lines.append("You are enemies through groups.")

	lines.append("")

	# 2. Activity & Hunger/Sleep/Sanity
	var activity_line: String = describe_actor_activity(actor)
	if activity_line != null:
		lines.append(activity_line)
	else:
		lines.append(" ")  # blank activity line
	if actor.model.abilities.has_to_sleep:
		if rules.is_actor_exhausted(actor):
			lines.append("Exhausted!")
		elif rules.is_actor_sleepy(actor):
			lines.append("Sleepy.")
	if actor.model.abilities.has_to_eat:
		if rules.is_actor_starving(actor):
			lines.append("Starving!")
		elif rules.is_actor_hungry(actor):
			lines.append("Hungry.")
	elif actor.model.abilities.is_rotting:
		if rules.is_rotting_actor_starving(actor):
			lines.append("Starving!")
		elif rules.is_rotting_actor_hungry(actor):
			lines.append("Hungry.")
	if actor.model.abilities.has_sanity:
		if rules.is_actor_insane(actor):
			lines.append("Insane!")
		elif rules.is_actor_disturbed(actor):
			lines.append("Disturbed.")

	# 3. Speed
	lines.append("Spd : %.2f" % (float(rules.actor_speed(actor)) / float(Rules.BASE_SPEED)))

	# 4. HP & STA.
	var sb := ""
	var max_hp: int = rules.actor_max_hps(actor)
	if actor.hit_points != max_hp:
		sb += "HP  : %02d/%02d" % [actor.hit_points, max_hp]
	else:
		sb += "HP  : %02d MAX" % actor.hit_points
	if actor.model.abilities.can_tire:
		var max_sta: int = rules.actor_max_sta(actor)
		if actor.stamina_points != max_sta:
			sb += "   STA : %d/%d" % [actor.stamina_points, max_sta]
		else:
			sb += "   STA : %d MAX" % actor.stamina_points
	lines.append(sb)

	# 5. Attack, Dmg, Defence.
	var attack: Attack = rules.actor_melee_attack(actor, actor.current_melee_attack, null)
	lines.append("Atk : %02d Dmg : %02d" % [attack.hit_value, attack.damage_value])
	var defence: Defence = rules.actor_defence(actor, actor.current_defence)
	lines.append("Def : %02d" % defence.value)
	lines.append("Arm : %d/%d" % [defence.protection_hit, defence.protection_shot])
	lines.append(" ")

	# 6. Flavor
	lines.append(actor.model.flavor_description)
	lines.append(" ")

	# 7. Skills
	if actor.sheet.skill_table != null and actor.sheet.skill_table.count_skills() > 0:
		for sk in actor.sheet.skill_table.skills():
			lines.append("%d-%s" % [sk.level, Skills.name(sk.id)])
		lines.append(" ")

	# alpha10
	# 8. Unusual abilities
	# unusual abilities for undeads
	if actor.model.abilities.is_undead:
		# fov
		lines.append("- FOV : %d." % actor.model.starting_sheet.base_view_range)

		# smell rating
		var smell: int = int(100 * rules.actor_smell(actor))  # applies z-tracker skill
		if smell == 0:
			lines.append("- Has no sense of smell.")
		elif smell < 50:
			lines.append("- Has poor sense of smell.")
		elif smell < 100:
			lines.append("- Has good sense of smell.")
		else:
			lines.append("- Has excellent sense of smell.")

		# grab?
		if actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_GRAB) > 0:
			lines.append("- Z-Grab : this undead can grab its victims.")

		if actor.model.abilities.is_undead_master:
			lines.append("- Other undeads follow this undead tracks.")
		elif smell > 0:
			lines.append("- This undead will follow zombie masters tracks.")
		if actor.model.abilities.is_intelligent:
			lines.append("- This undead is intelligent.")
		if actor.model.abilities.can_disarm:
			lines.append("- This undead can disarm.")
		if actor.model.abilities.can_jump:
			if actor.model.abilities.can_jump_stumble:
				lines.append("- This undead can jump but may stumble.")
			else:
				lines.append("- This undead can jump.")
		if rules.has_actor_push_ability(actor):
			lines.append("- This undead can push.")
		if actor.model.abilities.zombie_ai_explore:
			lines.append("- This undead will explore.")

		# things some of them cannot do
		if not actor.model.abilities.is_rotting:
			lines.append("- This undead will not rot.")
		if not actor.model.abilities.can_bash_doors:
			lines.append("- This undead cannot bash doors.")
		if not actor.model.abilities.can_break_objects:
			lines.append("- This undead cannot break objects.")
		if not actor.model.abilities.can_zombify_killed:
			lines.append("- This undead cannot infect livings.")
		if not actor.model.abilities.ai_can_use_ai_exits:
			lines.append("- This undead live in this map.")
	# misc unusual abilities
	if actor.model.abilities.is_law_enforcer:
		lines.append("- Is a law enforcer.")
	if actor.model.abilities.is_small:
		lines.append("- Is small and can sneak through things.")

	# 9. Inventory.
	if actor.inventory != null and not actor.inventory.is_empty:
		lines.append("Items %d/%d : " % [actor.inventory.count_items, rules.actor_max_inv(actor)])
		lines.append_array(describe_inventory(actor.inventory))

	# done.
	return lines


func describe_actor_activity(actor: Actor) -> String:
	if actor.is_player:
		return ""

	match actor.activity:
		Activity.IDLE:
			return ""
		Activity.CHASING:
			if actor.target_actor == null:
				return "Chasing!"
			else:
				return "Chasing %s!" % actor.target_actor.the_name
		Activity.FIGHTING:
			if actor.target_actor == null:
				return "Fighting!"
			else:
				return "Fighting %s!" % actor.target_actor.the_name
		Activity.TRACKING:
			return "Tracking!"
		Activity.FLEEING:
			return "Fleeing!"
		Activity.FLEEING_FROM_EXPLOSIVE:
			return "Fleeing from explosives!"
		Activity.FOLLOWING:
			if actor.target_actor == null:
				return "Following."
			else:
				# alpha10
				if actor.leader == actor.target_actor:
					return "Following %s leader." % his_or_her(actor)
				return "Following %s." % actor.target_actor.the_name
		Activity.FOLLOWING_ORDER:
			return "Following orders."
		Activity.SLEEPING:
			return "Sleeping."
		_:
			push_error("unhandled activity " + str(actor.activity))
			return ""


func describe_player_follower_status(follower: Actor) -> String:
	var desc: String

	var fo_ai: BaseAI = follower.controller as BaseAI
	if fo_ai.order == null:
		desc = "(no orders)"
	else:
		desc = str(fo_ai.order)
	desc += "(trust:%d)" % follower.trust_in_leader

	return desc


func describe_map_object(obj: MapObject, map: Map, map_pos: Vector2i) -> Array:
	var lines: Array = []

	# 1. Name
	lines.append("%s." % obj.a_name)

	# 2. Special flags.
	if obj.is_jumpable:
		lines.append("Can be jumped on.")
	if obj.is_couch:
		lines.append("Is a couch.")
	if obj.gives_wood:
		lines.append("Can be dismantled for wood.")
	if obj.is_movable:
		lines.append("Can be moved.")
	if obj.stand_on_fov_bonus:
		lines.append("Increases view range.")

	# 3. Common Status: Break, Fire.
	#    Concrete MapObjects status.
	var sb := ""
	if obj.break_state == MapObject.Break.BROKEN:
		sb += "Broken! "
	if obj.fire_state == MapObject.Fire.ONFIRE:
		sb += "On fire! "
	elif obj.fire_state == MapObject.Fire.ASHES:
		sb += "Burnt to ashes! "
	lines.append(sb)
	if obj is PowerGenerator:
		var pow_gen: PowerGenerator = obj as PowerGenerator
		if pow_gen.is_on:
			lines.append("Currently ON.")
		else:
			lines.append("Currently OFF.")
		var power_ratio: float = rules.compute_map_power_ratio(obj.location.map)
		lines.append("The power gauge reads %d%%." % int(100 * power_ratio))
	elif obj is Board:
		lines.append("The text reads : ")
		lines.append_array((obj as Board).text)

	# 4. HitPoints & Barricade
	if obj.max_hit_points > 0:
		if obj.hit_points < obj.max_hit_points:
			lines.append("HP        : %d/%d" % [obj.hit_points, obj.max_hit_points])
		else:
			lines.append("HP        : %d MAX" % obj.hit_points)

		var door: DoorWindow = obj as DoorWindow
		if door != null:
			if door.barricade_points < Rules.BARRICADING_MAX:
				lines.append("Barricades: %d/%d" % [door.barricade_points, Rules.BARRICADING_MAX])
			else:
				lines.append("Barricades: %d MAX" % door.barricade_points)

	# 5. Weight?
	if obj.weight > 0:
		lines.append("Weight    : %d" % obj.weight)

	# 6. Items there
	var inv: Inventory = map.get_items_at(map_pos)
	if inv != null and not inv.is_empty:
		lines.append_array(describe_inventory(inv))

	return lines


func describe_inventory(inv: Inventory) -> Array:
	var lines: Array = []

	for it in inv.items:
		if it.is_equipped:
			lines.append("- %s (equipped)" % describe_item_short(it))
		else:
			lines.append("- %s" % describe_item_short(it))

	return lines


func describe_corpses(corpses: Array) -> Array:
	var lines: Array = []

	if corpses.size() > 1:
		lines.append("There are corpses there...")
	else:
		lines.append("There is a corpse here.")
	lines.append(" ")

	for c in corpses:
		lines.append("- Corpse of %s." % c.dead_guy.the_name)
	return lines


func describe_corpse_long(c: Corpse, is_in_player_tile: bool) -> Array:
	var lines: Array = []

	# 1. Corpse of XXX
	lines.append("Corpse of %s." % c.dead_guy.the_name)
	lines.append(" ")

	# 2. Necrology infos.
	var necrology: int = player.sheet.skill_table.get_skill_level(Skills.IDs.NECROLOGY)

	var dead_since := "???"
	if necrology > 0:
		dead_since = WorldTime.make_time_duration_message(session.world_time.turn_counter - c.turn)
	lines.append("Death     : %s." % dead_since)

	var infection_est := "???"
	if necrology >= Rules.SKILL_NECROLOGY_LEVEL_FOR_INFECTION:
		var infection_p: int = rules.actor_infection_percent(c.dead_guy)
		if infection_p == 0:
			infection_est = "0/7 - none"
		elif infection_p < 5:
			infection_est = "1/7 - traces"
		elif infection_p < 15:
			infection_est = "2/7 - minor"
		elif infection_p < 30:
			infection_est = "3/7 - low"
		elif infection_p < 55:
			infection_est = "4/7 - average"
		elif infection_p < 70:
			infection_est = "5/7 - important"
		elif infection_p < 99:
			infection_est = "6/7 - great"
		else:
			infection_est = "7/7 - total"
	lines.append("Infection : %s." % infection_est)

	var rise_est := "???"
	if necrology >= Rules.SKILL_NECROLOGY_LEVEL_FOR_RISE:
		var rise_p: int = 2 * rules.corpse_zombify_chance(c, c.dead_guy.location.map.local_time, false)
		if rise_p < 5:
			rise_est = "0/6 - extremely unlikely"
		elif rise_p < 20:
			rise_est = "1/6 - unlikely"
		elif rise_p < 40:
			rise_est = "2/6 - possible"
		elif rise_p < 60:
			rise_est = "3/6 - likely"
		elif rise_p < 80:
			rise_est = "4/6 - very likely"
		elif rise_p < 99:
			rise_est = "5/6 - most likely"
		else:
			rise_est = "6/6 - certain"
	lines.append("Rise      : %s." % rise_est)
	lines.append(" ")

	# 3. Decay
	var rot_level: int = rules.corpse_rot_level(c)
	match rot_level:
		5:
			lines.append("The corpse is about to crumble to dust.")
		4:
			lines.append("The corpse is almost entirely rotten.")
		3:
			lines.append("The corpse is badly damaged.")
		2:
			lines.append("The corpse is damaged.")
		1:
			lines.append("The corpse is bruised and smells.")
		0:
			lines.append("The corpse looks fresh.")
		_:
			push_error("unhandled rot level")

	# 3. Medic info.
	var revive_est := "???"
	var medic: int = player.sheet.skill_table.get_skill_level(Skills.IDs.MEDIC)
	if medic >= Rules.SKILL_MEDIC_LEVEL_FOR_REVIVE_EST:
		var revive_p: int = rules.corpse_revive_chance(player, c)
		if revive_p == 0:
			revive_est = "impossible"
		elif revive_p < 5:
			revive_est = "0/6 - extremely unlikely"
		elif revive_p < 20:
			revive_est = "1/6 - unlikely"
		elif revive_p < 40:
			revive_est = "2/6 - possible"
		elif revive_p < 60:
			revive_est = "3/6 - likely"
		elif revive_p < 80:
			revive_est = "4/6 - very likely"
		elif revive_p < 99:
			revive_est = "5/6 - most likely"
		else:
			revive_est = "6/6 - certain"
	lines.append("Revive    : %s." % revive_est)

	# 5. Special keys.
	if is_in_player_tile:
		lines.append(" ")
		lines.append("----")
		lines.append("LBM to start/stop dragging.")
		lines.append("RBM to %s." % ("eat" if player.model.abilities.is_undead else "butcher"))
		if not player.model.abilities.is_undead:
			lines.append("to eat: <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.EAT_CORPSE)))
			lines.append("to revive : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.REVIVE_CORPSE)))

	return lines


#region Items

func describe_item_short(it: Item) -> String:
	var item_name := it.model.plural_name if it.quantity > 1 else it.a_name()

	if it is ItemFood:
		var food: ItemFood = it as ItemFood
		if rules.is_food_spoiled(food, session.world_time.turn_counter):
			item_name += " (spoiled)"
		elif rules.is_food_expired(food, session.world_time.turn_counter):
			item_name += " (expired)"
	elif it is ItemRangedWeapon:
		var rw: ItemRangedWeapon = it as ItemRangedWeapon
		item_name += " (%d/%d)" % [rw.ammo, (rw.model as ItemRangedWeaponModel).max_ammo]
	elif it is ItemTrap:
		var trap: ItemTrap = it as ItemTrap
		if trap.is_activated():
			item_name += "(activated)"
		if trap.is_triggered:
			item_name += "(triggered)"
		if trap.owner == player:
			item_name += "(yours)"  # alpha10

	if it.quantity > 1:
		return "%d %s" % [it.quantity, item_name]
	else:
		return item_name


func describe_item_long(it: Item, is_player_inventory: bool, i_slot: int) -> Array:
	var lines: Array = []
	var is_default_use := true  # alpha10

	# 1. Name & stacking.
	if it.model.is_stackable:
		lines.append("%s %d/%d" % [describe_item_short(it), it.quantity, it.model.stacking_limit])
	else:
		lines.append(describe_item_short(it))

	# 2. Special flags.
	# unbreakable?
	if it.model.is_unbreakable:
		lines.append("Unbreakable.")

	# 3. Item specific stuff...
	var in_inv_additional_desc = null
	if it is ItemWeapon:
		lines.append_array(describe_item_weapon(it as ItemWeapon))
		if it is ItemRangedWeapon:
			is_default_use = false
			in_inv_additional_desc = "to fire : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.FIRE_MODE))
	elif it is ItemFood:
		lines.append_array(describe_item_food(it as ItemFood))
	elif it is ItemMedicine:
		lines.append_array(describe_item_medicine(it as ItemMedicine))
	elif it is ItemBarricadeMaterial:
		lines.append_array(describe_item_barricade_material(it as ItemBarricadeMaterial))
		is_default_use = false
		in_inv_additional_desc = "to build : <%s>/<%s>/<%s>" % [
			OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BARRICADE_MODE)),
			OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BUILD_SMALL_FORTIFICATION)),
			OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.BUILD_LARGE_FORTIFICATION))]
	elif it is ItemBodyArmor:
		lines.append_array(describe_item_body_armor(it as ItemBodyArmor))
	elif it is ItemSprayPaint:
		lines.append_array(describe_item_spray_paint(it as ItemSprayPaint))
		is_default_use = false
		in_inv_additional_desc = "to spray : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.USE_SPRAY))
	elif it is ItemSprayScent:
		lines.append_array(describe_item_spray_scent(it as ItemSprayScent))
		is_default_use = false
		in_inv_additional_desc = "to spray : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.USE_SPRAY))
	elif it is ItemLight:
		lines.append_array(describe_item_light(it as ItemLight))
	elif it is ItemTracker:
		lines.append_array(describe_item_tracker(it as ItemTracker))
	elif it is ItemAmmo:
		lines.append_array(describe_item_ammo(it as ItemAmmo))
		is_default_use = false
		in_inv_additional_desc = "to reload : <LMB> or <Ctrl-%d>" % (i_slot + 1)
	elif it is ItemExplosive:
		lines.append_array(describe_item_explosive(it as ItemExplosive))
		in_inv_additional_desc = "to throw : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.FIRE_MODE))
	elif it is ItemTrap:
		lines.append_array(describe_item_trap(it as ItemTrap))
		# alpha10
		if (it as ItemTrap).trap_model().activates_when_dropped():
			in_inv_additional_desc = "to activate trap : drop it"
		else:
			in_inv_additional_desc = "to activate trap : use it"
	elif it is ItemEntertainment:
		lines.append_array(describe_item_entertainment(it as ItemEntertainment))

	# 3. Flavor description
	lines.append(" ")
	lines.append(it.model.flavor_description)

	# 4. Special keys.
	# alpha10 added more special keys very few players know about!
	if is_player_inventory:
		lines.append(" ")
		lines.append("----")
		if it.model.is_equipable():
			lines.append("to %s : <LMB> or <Ctrl-%d>" % ["unequip" if it.is_equipped else "equip", i_slot + 1])
		elif is_default_use:
			lines.append("to use : <LMB> or <Ctrl-%d>" % (i_slot + 1))
		if not it.is_equipped:
			lines.append("to drop : <RMB>")
		lines.append("to give : <%s>" % OS.get_keycode_string(key_bindings.get_key(PlayerCommand.Command.GIVE_ITEM)))
		if in_inv_additional_desc != null:
			lines.append(in_inv_additional_desc)
	else:
		lines.append(" ")
		lines.append("----")
		lines.append("to take : <LMB> or <Shift-%d>" % (i_slot + 1))

	# done.
	return lines


func describe_item_explosive(ex: ItemExplosive) -> Array:
	var lines: Array = []

	var m: ItemExplosiveModel = ex.model as ItemExplosiveModel
	var primed: ItemPrimedExplosive = ex as ItemPrimedExplosive

	lines.append("> explosive")

	# 1. Explosive attack.
	if m.blast_attack.can_damage_objects:
		lines.append("Can damage objects.")
	if m.blast_attack.can_destroy_walls:
		lines.append("Can destroy walls.")

	if primed != null:
		lines.append("Fuse          : %d turn(s) left!" % primed.fuse_time_left)
	else:
		lines.append("Fuse          : %d turn(s)" % m.fuse_delay)
	lines.append("Blast radius  : %d" % m.blast_attack.radius)

	# 2. Damage for each distance.
	var sb := ""
	for blast_radius in range(0, m.blast_attack.radius + 1):
		sb += "%d;" % rules.blast_damage(blast_radius, m.blast_attack)
	lines.append("Blast damages : %s" % sb)

	# 3. Specialized explosives.
	# grenade?
	var grenade: ItemGrenade = ex as ItemGrenade
	if grenade != null:
		lines.append("> grenade")

		var gre_model: ItemGrenadeModel = grenade.model as ItemGrenadeModel
		var rng: int = rules.actor_max_throw_range(player, gre_model.max_throw_distance)
		if rng != gre_model.max_throw_distance:
			lines.append("Throwing rng  : %d (%d)" % [rng, gre_model.max_throw_distance])
		else:
			lines.append("Throwing rng  : %d" % rng)

	# 4. Primed?
	if primed != null:
		lines.append("PRIMED AND READY TO EXPLODE!")

	return lines


func describe_item_weapon(w: ItemWeapon) -> Array:
	var lines: Array = []

	var m: ItemWeaponModel = w.model as ItemWeaponModel

	lines.append("> weapon")

	# 1. Attack
	lines.append("Atk : +%d" % m.attack.hit_value)
	lines.append("Dmg : +%d" % m.attack.damage_value)
	# alpha10
	if m.attack.stamina_penalty != 0:
		lines.append("Sta : -%d" % m.attack.stamina_penalty)
	if m.attack.disarm_chance != 0:
		lines.append("Disarm : +%d%%" % m.attack.disarm_chance)

	# 2. Melee vs Ranged items
	var mw: ItemMeleeWeapon = w as ItemMeleeWeapon
	if mw != null:
		if mw.is_fragile():
			lines.append("Breaks easily.")
		# alpha10 tool
		if mw.is_tool():
			lines.append("Is a tool.")
			var tool_bash_dmg: int = mw.tool_bash_damage_bonus()
			if tool_bash_dmg != 0:
				lines.append("Tool Dmg   : +%d = +%d" % [tool_bash_dmg, tool_bash_dmg + m.attack.damage_value])
			var tool_build: float = mw.tool_build_bonus()
			if tool_build != 0:
				lines.append("Tool Build : +%d%%" % int(100 * tool_build))
	else:
		var rw: ItemRangedWeapon = w as ItemRangedWeapon
		if rw != null:
			var rm: ItemRangedWeaponModel = w.model as ItemRangedWeaponModel
			if rm.is_firearm():
				lines.append("> firearm")
			elif rm.is_bow():
				lines.append("> bow")
			else:
				lines.append("> ranged weapon")

			# alpha10
			lines.append("Rapid Fire Atk: %d %d" % [rm.rapid_fire_hit1_value(), rm.rapid_fire_hit2_value()])

			lines.append("Rng  : %d-%d" % [rm.attack.range_value, rm.attack.efficient_range()])
			if rw.ammo < rm.max_ammo:
				lines.append("Amo  : %d/%d" % [rw.ammo, rm.max_ammo])
			else:
				lines.append("Amo  : %d MAX" % rw.ammo)
			lines.append("Type : %s" % describe_ammo_type(rm.ammo_type))

	# done.
	return lines


func describe_ammo_type(at: int) -> String:
	match at:
		ItemAmmoModel.AmmoType.BOLT:
			return "bolts"
		ItemAmmoModel.AmmoType.HEAVY_PISTOL:
			return "heavy pistol bullets"
		ItemAmmoModel.AmmoType.HEAVY_RIFLE:
			return "heavy rifle bullets"
		ItemAmmoModel.AmmoType.LIGHT_PISTOL:
			return "light pistol bullets"
		ItemAmmoModel.AmmoType.LIGHT_RIFLE:
			return "light rifle bullets"
		ItemAmmoModel.AmmoType.SHOTGUN:
			return "shotgun cartridge"
		_:
			push_error("unhandled ammo type")
			return ""


func describe_item_ammo(am: ItemAmmo) -> Array:
	var lines: Array = []

	lines.append("> ammo")

	# 1. Ammo type
	lines.append("Type : %s" % describe_ammo_type(am.ammo_type))

	return lines


func describe_item_food(f: ItemFood) -> Array:
	var lines: Array = []

	var m: ItemFoodModel = f.model as ItemFoodModel

	lines.append("> food")

	# 1. Fresh/Expired, Best-Before
	if f.is_perishable:
		if rules.is_food_still_fresh(f, session.world_time.turn_counter):
			lines.append("Fresh.")
		elif rules.is_food_expired(f, session.world_time.turn_counter):
			lines.append("*Expired*")
		elif rules.is_food_spoiled(f, session.world_time.turn_counter):
			lines.append("**SPOILED**")
		lines.append("Best-Before : %s" % str(f.best_before))
	else:
		lines.append("Always fresh.")

	# 2. Nutrition
	var nutrition: int = rules.food_item_nutrition(f, session.world_time.turn_counter)
	var nutrition_for_player: int = nutrition if player == null else rules.actor_item_nutrition_value(player, nutrition)
	if nutrition_for_player == m.nutrition:
		lines.append("Nutrition   : +%d" % nutrition)
	else:
		lines.append("Nutrition   : +%d (+%d)" % [nutrition_for_player, nutrition])

	return lines


func describe_item_medicine(med: ItemMedicine) -> Array:
	var lines: Array = []

	var m: ItemMedicineModel = med.model as ItemMedicineModel

	lines.append("> medicine")

	# alpha10 dont add lines for zero values

	var healing_for_player: int = m.healing if player == null else rules.actor_medicine_effect(player, m.healing)
	if m.healing != 0:
		if healing_for_player == m.healing:
			lines.append("Healing : +%d" % m.healing)
		else:
			lines.append("Healing : +%d (+%d)" % [healing_for_player, m.healing])

	var stamina_for_player: int = m.stamina_boost if player == null else rules.actor_medicine_effect(player, m.stamina_boost)
	if m.stamina_boost != 0:
		if stamina_for_player == m.stamina_boost:
			lines.append("Stamina : +%d" % m.stamina_boost)
		else:
			lines.append("Stamina : +%d (+%d)" % [stamina_for_player, m.stamina_boost])

	var sleep_for_player: int = m.sleep_boost if player == null else rules.actor_medicine_effect(player, m.sleep_boost)
	if m.sleep_boost != 0:
		if sleep_for_player == m.sleep_boost:
			lines.append("Sleep   : +%d" % m.sleep_boost)
		else:
			lines.append("Sleep   : +%d (+%d)" % [sleep_for_player, m.sleep_boost])

	var san_for_player: int = m.sanity_cure if player == null else rules.actor_medicine_effect(player, m.sanity_cure)
	if m.sanity_cure != 0:
		if san_for_player == m.sanity_cure:
			lines.append("Sanity  : +%d" % m.sanity_cure)
		else:
			lines.append("Sanity  : +%d (+%d)" % [san_for_player, m.sanity_cure])

	if Rules.has_infection(session.game_mode):
		var cure_for_player: int = m.infection_cure if player == null else rules.actor_medicine_effect(player, m.infection_cure)
		if m.infection_cure != 0:
			if cure_for_player == m.infection_cure:
				lines.append("Cure    : +%d" % m.infection_cure)
			else:
				lines.append("Cure    : +%d (+%d)" % [cure_for_player, m.infection_cure])

	return lines


func describe_item_barricade_material(bm: ItemBarricadeMaterial) -> Array:
	var lines: Array = []

	var m: ItemBarricadeMaterialModel = bm.model as ItemBarricadeMaterialModel

	lines.append("> barricade material")

	# 1. Barricading value.
	var bar_for_player: int = m.barricading_value if player == null else rules.actor_barricading_points(player, m.barricading_value)
	if bar_for_player == m.barricading_value:
		lines.append("Barricading : +%d" % m.barricading_value)
	else:
		lines.append("Barricading : +%d (+%d)" % [bar_for_player, m.barricading_value])

	return lines


func describe_item_body_armor(b: ItemBodyArmor) -> Array:
	var lines: Array = []

	lines.append("> body armor")

	# 1. Protection value.
	lines.append("Protection vs Hits  : +%d" % b.protection_hit)
	lines.append("Protection vs Shots : +%d" % b.protection_shot)
	lines.append("Encumbrance         : -%d DEF" % b.encumbrance)
	lines.append("Weight              : -%.2f SPD" % (0.01 * b.weight))

	# 2. Unsuspicious effects.
	var unsuspicious: Array = []
	var suspicious: Array = []
	if b.is_friendly_for_cops():
		unsuspicious.append("Cops")
	if b.is_hostile_for_cops():
		suspicious.append("Cops")
	for gang in GameGangs.BIKERS:
		if b.is_hostile_for_biker(gang):
			suspicious.append(GameGangs.NAMES[gang])
		if b.is_friendly_for_biker(gang):
			unsuspicious.append(GameGangs.NAMES[gang])
	if unsuspicious.size() > 0:
		lines.append("Unsuspicious to:")
		for s in unsuspicious:
			lines.append("- " + s)
	if suspicious.size() > 0:
		lines.append("Suspicious to:")
		for s in suspicious:
			lines.append("- " + s)

	return lines


func describe_item_spray_paint(sp: ItemSprayPaint) -> Array:
	var lines: Array = []

	var m: ItemSprayPaintModel = sp.model as ItemSprayPaintModel

	lines.append("> spray paint")

	# 1. Paint
	if sp.paint_quantity < m.max_paint_quantity:
		lines.append("Paint : %d/%d" % [sp.paint_quantity, m.max_paint_quantity])
	else:
		lines.append("Paint : %d MAX" % sp.paint_quantity)

	return lines


func describe_item_spray_scent(sp: ItemSprayScent) -> Array:
	var lines: Array = []

	var m: ItemSprayScentModel = sp.model as ItemSprayScentModel

	lines.append("> spray scent")

	# 1. Spray.
	if sp.spray_quantity < m.max_spray_quantity:
		lines.append("Spray    : %d/%d" % [sp.spray_quantity, m.max_spray_quantity])
	else:
		lines.append("Spray    : %d MAX" % sp.spray_quantity)

	# alpha10
	# 2. Odor & Strength
	var odor_name := ""
	match sp.odor():
		Odor.LIVING:
			odor_name = "living"
		Odor.UNDEAD_MASTER:
			odor_name = "undead master"
		Odor.SUPPRESSOR:
			odor_name = "suppressor"
	lines.append("Odor     : %s" % capitalize(odor_name))
	lines.append("Strength : %dh" % (sp.strength() / WorldTime.TURNS_PER_HOUR))

	return lines


func describe_item_light(lt: ItemLight) -> Array:
	var lines: Array = []

	var m: ItemLightModel = lt.model as ItemLightModel

	lines.append("> light")

	# 1. Batteries
	lines.append(describe_batteries(lt.batteries, m.max_batteries))

	# 2. FoV
	lines.append("FOV       : +%d" % lt.fov_bonus)

	return lines


func describe_item_tracker(_tr: ItemTracker) -> Array:
	var lines: Array = []

	var m: ItemTrackerModel = _tr.model as ItemTrackerModel

	lines.append("> tracker")

	# 1. Batteries
	lines.append(describe_batteries(_tr.batteries, m.max_batteries))
	# alpha10 range if applicable
	if _tr.can_track_undeads():
		lines.append("Range: %d" % Rules.ZTRACKINGRADIUS)
	else:
		lines.append("Range: whole map")

	# alpha10
	# 2. Clock
	if _tr.has_clock():
		lines.append(" ")
		if _tr.batteries == 0:
			lines.append("Out of batteries, can't give the time.")
		elif not _tr.is_equipped:
			lines.append("Equip the item to read the time.")
		else:
			lines.append("The clock reads: %dh, %s" % [session.world_time.hour, describe_day_phase(session.world_time.phase)])

	return lines


func describe_item_trap(_tr: ItemTrap) -> Array:
	var lines: Array = []

	var m: ItemTrapModel = _tr.model as ItemTrapModel

	lines.append("> trap")

	# 1. Status
	if _tr.is_activated():
		lines.append("** Activated! **")
		# alpha10
		if rules.is_safe_from_trap(_tr, player):
			lines.append("You will safely avoid this trap.")
			if _tr.owner != null:
				lines.append("Trap setup by %s." % _tr.owner.the_name)
	elif _tr.is_triggered:
		# alpha10
		lines.append("** Triggered! **")
		if rules.is_safe_from_trap(_tr, player):
			lines.append("You will safely avoid this trap.")
			if _tr.owner != null:
				lines.append("Trap setup by %s." % _tr.owner.the_name)
	# alpha10
	lines.append("Trigger chance for you : %d%%." % rules.get_trap_trigger_chance(_tr, player))

	# 2. Flags
	if m.is_one_time_use():
		lines.append("Desactives when triggered.")
	if m.is_noisy():
		lines.append("Makes %s noise." % m.noise_name)
	if m.use_to_activate():
		lines.append("Use to activate.")

	# 3. Stats
	lines.append("Damage  : %d x%d = %d" % [m.damage, _tr.quantity, _tr.quantity * m.damage])  # alpha10
	lines.append("Trigger : %d%% x%d = %d%%" % [m.trigger_chance, _tr.quantity, _tr.quantity * m.trigger_chance])  # alpha10
	lines.append("Break   : %d%%" % m.break_chance)
	if m.block_chance > 0:
		lines.append("Block   : %d%%" % m.block_chance)
	if m.break_chance_when_escape > 0:
		lines.append("%d%% to break on escape" % m.break_chance_when_escape)

	return lines


func describe_item_entertainment(ent: ItemEntertainment) -> Array:
	var lines: Array = []

	var m: ItemEntertainmentModel = ent.entertainment_model()

	lines.append("> entertainment")

	# player bored?
	if player != null and ent.is_boring_for(player):  # alpha10 boring items item centric
		lines.append("* BORED OF IT! *")

	# San & Bore chance.
	lines.append("Sanity : +%d" % m.value)
	lines.append("Boring : %d%%" % m.bore_chance)

	return lines


func describe_batteries(batteries: int, max_batteries: int) -> String:
	var hours: int = batteries_to_hours(batteries)
	if batteries < max_batteries:
		return "Batteries : %d/%d (%dh)" % [batteries, max_batteries, hours]
	else:
		return "Batteries : %d MAX (%dh)" % [batteries, hours]
#endregion


func describe_skill_short(id: int) -> String:
	match id:
		Skills.IDs.AGILE:
			return "+%d melee ATK, +%d DEF" % [Rules.SKILL_AGILE_ATK_BONUS, Rules.SKILL_AGILE_DEF_BONUS]
		Skills.IDs.AWAKE:
			return "+%d%% max SLP, +%d%% SLP regen " % [int(100 * Rules.SKILL_AWAKE_SLEEP_BONUS), int(100 * Rules.SKILL_AWAKE_SLEEP_REGEN_BONUS)]
		Skills.IDs.BOWS:
			return "bows +%d ATK, +%d DMG" % [Rules.SKILL_BOWS_ATK_BONUS, Rules.SKILL_BOWS_DMG_BONUS]
		Skills.IDs.CARPENTRY:
			return "build, -%d mat. at lvl 3, +%d%% barricading" % [Rules.SKILL_CARPENTRY_LEVEL3_BUILD_BONUS, int(100 * Rules.SKILL_CARPENTRY_BARRICADING_BONUS)]
		Skills.IDs.CHARISMATIC:
			return "+%d trust per turn, +%d%% trade rolls, steal followers" % [Rules.SKILL_CHARISMATIC_TRUST_BONUS, Rules.SKILL_CHARISMATIC_TRADE_BONUS]  # alpha10.1 steal followers
		Skills.IDs.FIREARMS:
			return "firearms +%d ATK, +%d DMG" % [Rules.SKILL_FIREARMS_ATK_BONUS, Rules.SKILL_FIREARMS_DMG_BONUS]
		Skills.IDs.HARDY:
			return "sleeping anywhere heals, +%d%% chance to heal when sleeping" % Rules.SKILL_HARDY_HEAL_CHANCE_BONUS
		Skills.IDs.HAULER:
			return "+%d inventory slots" % Rules.SKILL_HAULER_INV_BONUS
		Skills.IDs.HIGH_STAMINA:
			return "+%d STA" % Rules.SKILL_HIGH_STAMINA_STA_BONUS
		Skills.IDs.LEADERSHIP:
			return "+%d max Followers" % Rules.SKILL_LEADERSHIP_FOLLOWER_BONUS
		Skills.IDs.LIGHT_EATER:
			return "+%d%% max FOO, +%d%% items food points" % [int(100 * Rules.SKILL_LIGHT_EATER_MAXFOOD_BONUS), int(100 * Rules.SKILL_LIGHT_EATER_FOOD_BONUS)]
		Skills.IDs.LIGHT_FEET:
			return "+%d%% to avoid and escape traps" % Rules.SKILL_LIGHT_FEET_TRAP_BONUS
		Skills.IDs.LIGHT_SLEEPER:
			return "+%d%% noise wake up chance" % Rules.SKILL_LIGHT_SLEEPER_WAKEUP_CHANCE_BONUS
		Skills.IDs.MARTIAL_ARTS:
			return "unarmed only +%d ATK, +%d DMG, +%d%% disarm" % [Rules.SKILL_MARTIAL_ARTS_ATK_BONUS, Rules.SKILL_MARTIAL_ARTS_DMG_BONUS, Rules.SKILL_MARTIAL_ARTS_DISARM_BONUS]
		Skills.IDs.MEDIC:
			return "+%d%% medicine items effects, +%d%% revive " % [int(100 * Rules.SKILL_MEDIC_BONUS), Rules.SKILL_MEDIC_REVIVE_BONUS]
		Skills.IDs.NECROLOGY:
			return "+%d/+%d DMG vs undeads/corpses, data on corpses" % [Rules.SKILL_NECROLOGY_UNDEAD_BONUS, Rules.SKILL_NECROLOGY_CORPSE_BONUS]
		Skills.IDs.STRONG:
			return "+%d melee DMG, +%d%% resist disarming, +%d throw range" % [Rules.SKILL_STRONG_DMG_BONUS, Rules.SKILL_STRONG_RESIST_DISARM_BONUS, Rules.SKILL_STRONG_THROW_BONUS]
		Skills.IDs.STRONG_PSYCHE:
			return "+%d%% SAN threshold" % int(100 * Rules.SKILL_STRONG_PSYCHE_LEVEL_BONUS)
		Skills.IDs.TOUGH:
			return "+%d HP" % Rules.SKILL_TOUGH_HP_BONUS
		Skills.IDs.UNSUSPICIOUS:
			return "+%d%% unnoticed by law enforcers and gangs" % Rules.SKILL_UNSUSPICIOUS_BONUS
		Skills.IDs.Z_AGILE:
			return "+%d melee ATK, +%d DEF, can jump" % [Rules.SKILL_ZAGILE_ATK_BONUS, Rules.SKILL_ZAGILE_DEF_BONUS]
		Skills.IDs.Z_EATER:
			return "+%d%% eating HP regen" % int(100 * Rules.SKILL_ZEATER_REGEN_BONUS)
		Skills.IDs.Z_GRAB:
			return "can grab enemies, +%d%% per level" % Rules.SKILL_ZGRAB_CHANCE
		Skills.IDs.Z_INFECTOR:
			return "+%d%% infection damage" % int(100 * Rules.SKILL_ZINFECTOR_BONUS)
		Skills.IDs.Z_LIGHT_EATER:
			return "+%d%% max ROT, +%d%% from eating" % [int(100 * Rules.SKILL_ZLIGHT_EATER_MAXFOOD_BONUS), int(100 * Rules.SKILL_ZLIGHT_EATER_FOOD_BONUS)]
		Skills.IDs.Z_LIGHT_FEET:
			return "+%d%% to avoid traps" % Rules.SKILL_ZLIGHT_FEET_TRAP_BONUS
		Skills.IDs.Z_STRONG:
			return "+%d melee DMG, can push" % Rules.SKILL_ZSTRONG_DMG_BONUS
		Skills.IDs.Z_TOUGH:
			return "+%d HP" % Rules.SKILL_ZTOUGH_HP_BONUS
		Skills.IDs.Z_TRACKER:
			return "+%d%% smell" % int(100 * Rules.SKILL_ZTRACKER_SMELL_BONUS)
		_:
			push_error("unhandled skill id")
			return ""


func describe_day_phase(phase: int) -> String:
	match phase:
		WorldTime.DayPhase.AFTERNOON:
			return "Afternoon"
		WorldTime.DayPhase.DEEP_NIGHT:
			return "Deep Night"
		WorldTime.DayPhase.EVENING:
			return "Evening"
		WorldTime.DayPhase.MIDDAY:
			return "Midday"
		WorldTime.DayPhase.MIDNIGHT:
			return "Midnight"
		WorldTime.DayPhase.MORNING:
			return "Morning"
		WorldTime.DayPhase.SUNRISE:
			return "Sunrise"
		WorldTime.DayPhase.SUNSET:
			return "Sunset"
		_:
			push_error("unhandled dayphase")
			return ""


func describe_weather(weather: int) -> String:
	match weather:
		Weather.CLOUDY:
			return "Cloudy"
		Weather.HEAVY_RAIN:
			return "Heavy rain"
		Weather.RAIN:
			return "Rain"
		Weather.CLEAR:
			return "Clear"
		_:
			push_error("unhandled weather")
			return ""


func weather_color(weather: int) -> Color:
	match weather:
		Weather.CLOUDY:
			return Color.GRAY
		Weather.HEAVY_RAIN:
			return Color.BLUE
		Weather.RAIN:
			return Color.LIGHT_BLUE
		Weather.CLEAR:
			return Color.YELLOW
		_:
			push_error("unhandled weather")
			return Color.WHITE


func batteries_to_hours(batteries: int) -> int:
	return batteries / WorldTime.TURNS_PER_HOUR


func food_to_hours_until_hungry(food: int) -> int:
	var left: int = food - Rules.FOOD_HUNGRY_LEVEL
	if left <= 0:
		return 0
	return left / WorldTime.TURNS_PER_HOUR


func food_to_hours_until_rot_hungry(food: int) -> int:
	var left: int = food - Rules.ROT_HUNGRY_LEVEL
	if left <= 0:
		return 0
	return left / WorldTime.TURNS_PER_HOUR


func is_almost_hungry(actor: Actor) -> bool:
	if not actor.model.abilities.has_to_eat:
		return false
	return food_to_hours_until_hungry(actor.food_points) <= 3


func is_almost_rot_hungry(actor: Actor) -> bool:
	if not actor.model.abilities.is_rotting:
		return false
	return food_to_hours_until_rot_hungry(actor.food_points) <= 3
#endregion

#region Translating commands

static func command_to_direction(cmd: int) -> Direction:
	match cmd:
		PlayerCommand.Command.MOVE_N:
			return Direction.N
		PlayerCommand.Command.MOVE_NE:
			return Direction.NE
		PlayerCommand.Command.MOVE_E:
			return Direction.E
		PlayerCommand.Command.MOVE_SE:
			return Direction.SE
		PlayerCommand.Command.MOVE_S:
			return Direction.S
		PlayerCommand.Command.MOVE_SW:
			return Direction.SW
		PlayerCommand.Command.MOVE_W:
			return Direction.W
		PlayerCommand.Command.MOVE_NW:
			return Direction.NW
		PlayerCommand.Command.WAIT_OR_SELF:
			return Direction.NEUTRAL
		_:
			return null
#endregion


# Verbs used by this part (C# RogueGame.cs verb table, lines 376-435; the
# skeleton does not declare them).

#region Movement (C# lines 12689-12928)

## C# overloads: DoMoveActor(Actor, Location) and DoMoveActor(Actor, Direction).
func do_move_actor(actor: Actor, new_location) -> void:
	if new_location is Direction:
		new_location = actor.location.plus(new_location)
	var old_location: Location = actor.location

	# Try to leave tile.
	if not try_actor_leave_tile(actor):
		# waste ap.
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
		return

	# Do the move.
	if old_location.map == new_location.map:
		new_location.map.place_actor_at(actor, new_location.position)
	else:
		push_error("do_move_actor : illegal to change map.")

	# If dragging corpse, move it along.
	var dragged_corpse: Corpse = actor.dragged_corpse
	if dragged_corpse != null:
		old_location.map.move_corpse_to(dragged_corpse, new_location.position)
		if is_visible_to_player(new_location) or is_visible_to_player(old_location):
			add_message(make_message(actor, "%s %s corpse." % [conjugate(actor, VERB_DRAG), dragged_corpse.dead_guy.the_name]))

	# Spend AP & STA, check for running, jumping and dragging corpse.
	var move_cost: int = Rules.BASE_ACTION_COST

	# running?
	if actor.is_running:
		# x2 faster.
		move_cost /= 2
		# cost STA.
		spend_actor_stamina_points(actor, Rules.STAMINA_COST_RUNNING)

	var is_jump: bool = false
	var map_obj: MapObject = new_location.map.get_map_object_at_xy(new_location.position.x, new_location.position.y)
	if map_obj != null and not map_obj.is_walkable and map_obj.is_jumpable:
		is_jump = true

	# jumping?
	if is_jump:
		# cost STA.
		spend_actor_stamina_points(actor, Rules.STAMINA_COST_JUMP)

		# show.
		if is_visible_to_player(actor):
			add_message(make_message(actor, conjugate(actor, VERB_JUMP_ON), map_obj))

		# if CanJumpStumble ability, has a chance to stumble.
		if actor.model.abilities.can_jump_stumble and rules.roll_chance(Rules.JUMP_STUMBLE_CHANCE):
			# stumble!
			move_cost += Rules.JUMP_STUMBLE_ACTION_COST

			# show.
			if is_visible_to_player(actor):
				add_message(make_message(actor, "%s!" % conjugate(actor, VERB_STUMBLE)))

	# dragging?
	if dragged_corpse != null:
		# cost STA.
		spend_actor_stamina_points(actor, Rules.STAMINA_COST_MOVE_DRAGGED_CORPSE)

	# spend move AP.
	spend_actor_action_points(actor, move_cost)

	# If actor can move again, make sure he drops his scent here.
	if actor.action_points > 0:  # alpha10 fix; was Rules.BASE_ACTION_COST
		drop_actor_scents(actor)

	# Screams of terror?
	if not actor.is_player \
			and (actor.activity == Activity.FLEEING or actor.activity == Activity.FLEEING_FROM_EXPLOSIVE) \
			and not actor.model.abilities.is_undead \
			and actor.model.abilities.can_talk:
		# loud noise.
		on_loud_noise(new_location.map, new_location.position, "A loud SCREAM")

		# player hears?
		if rules.roll_chance(PLAYER_HEAR_SCREAMS_CHANCE) and not is_visible_to_player(actor):
			add_message_if_audible_for_player(actor.location, make_player_centric_message("You hear screams of terror", actor.location.position))

	# Trigger stuff.
	on_actor_enter_tile(actor)


func on_actor_enter_tile(actor: Actor) -> void:
	var map: Map = actor.location.map
	var pos: Vector2i = actor.location.position

	# Check traps.
	# Don't check if there is a covering mobj there.
	if not rules.is_trap_covering_map_object_there(map, pos):
		var items_there: Inventory = map.get_items_at(pos)
		if items_there != null:
			var remove_them: Array[Item] = []
			for it in items_there.items:
				var trap: ItemTrap = it as ItemTrap
				if trap == null or not trap.is_activated():
					continue
				if try_trigger_trap(trap, actor):
					remove_them.append(it)
			for it in remove_them:
				map.remove_item_at(it, pos)
			# Kill actor?
			if actor.hit_points <= 0:
				kill_actor(null, actor, "trap")


func try_actor_leave_tile(actor: Actor) -> bool:
	var map: Map = actor.location.map
	var pos: Vector2i = actor.location.position
	var can_leave := [true]

	# Check traps.
	if not rules.is_trap_covering_map_object_there(map, pos):
		var items_there: Inventory = map.get_items_at(pos)
		if items_there != null:
			var remove_them: Array[Item] = []
			var has_triggered_traps: bool = false
			for it in items_there.items:
				var trap: ItemTrap = it as ItemTrap
				if trap == null or not trap.is_triggered:
					continue
				has_triggered_traps = true
				var escape_res: Dictionary = try_escape_trap(trap, actor)
				var is_destroyed: bool = escape_res.get("is_destroyed", false)
				if not escape_res.ok:
					can_leave[0] = false
					continue
				if is_destroyed:
					remove_them.append(it)
			for it in remove_them:
				map.remove_item_at(it, pos)
			# if can leave, force un-trigger all traps.
			if can_leave[0] and has_triggered_traps:
				untrigger_all_traps_here(actor.location)

	# Check adjacent Z-Grabs
	var visible: bool = is_visible_to_player(actor)
	map.for_each_adjacent_in_map(pos, func(adj: Vector2i) -> void:
		var grabber: Actor = map.get_actor_at(adj)
		if grabber == null:
			return
		if not grabber.model.abilities.is_undead:
			return
		if not rules.are_enemies(grabber, actor):
			return
		var chance: int = rules.zgrab_chance(grabber, actor)
		if chance == 0:
			return
		if rules.roll_chance(rules.zgrab_chance(grabber, actor)):
			# grabbed!
			if visible:
				add_message(make_message(grabber, conjugate(grabber, VERB_GRAB), actor))
			# stuck there!
			can_leave[0] = false
	)

	return can_leave[0]
#endregion

#region Traps (C# lines 12930+)

## Returns true if item must be removed (destroyed).
func try_trigger_trap(trap: ItemTrap, victim: Actor) -> bool:
	# check trigger chance.
	if rules.check_trap_triggers(trap, victim):
		do_trigger_trap(trap, victim.location.map, victim.location.position, victim, null)
	else:
		if is_visible_to_player(victim):
			add_message(make_message(victim, "safely %s %s." % [conjugate(victim, VERB_AVOID), trap.the_name()]))
	# destroy?
	return trap.quantity == 0


## C# out-param isDestroyed -> Dictionary["is_destroyed"]; "ok" = successful escape.
func try_escape_trap(trap: ItemTrap, victim: Actor) -> Dictionary:
	var is_destroyed: bool = false
	var model: ItemTrapModel = trap.trap_model()

	# no brainer.
	if model.block_chance <= 0:
		return {"ok": true, "is_destroyed": false}

	var visible: bool = is_visible_to_player(victim)
	var can_escape: bool = false

	# check escape chance.
	if rules.check_trap_escape(trap, victim):
		# un-triggered and escape.
		trap.is_triggered = false
		can_escape = true

		# tell
		if visible:
			add_message(make_message(victim, "%s %s." % [conjugate(victim, VERB_ESCAPE), trap.the_name()]))

		# then check break on escape chance.
		if rules.check_trap_escape_breaks(trap, victim):
			if visible:
				add_message(make_message(victim, "%s %s." % [conjugate(victim, VERB_BREAK), trap.the_name()]))
			trap.quantity -= 1
			is_destroyed = trap.quantity <= 0
	else:
		# tell
		if visible:
			add_message(make_message(victim, "is trapped by %s!" % trap.the_name()))

	# escape?
	return {"ok": can_escape, "is_destroyed": is_destroyed}


func untrigger_all_traps_here(loc: Location) -> void:
	var items_there: Inventory = loc.map.get_items_at(loc.position)
	if items_there == null:
		return
	for it in items_there.items:
		var trap: ItemTrap = it as ItemTrap
		if trap == null or not trap.is_triggered:
			continue
		trap.is_triggered = false


## Checks that there is a map object that triggers the traps there.
## If so, a map object triggers ALL activated the traps here.
func check_map_object_triggers_traps(map: Map, pos: Vector2i) -> void:
	if not rules.is_trap_triggering_map_object_there(map, pos):
		return

	var mobj: MapObject = map.get_map_object_at(pos)

	var items_there: Inventory = map.get_items_at(pos)
	if items_there == null:
		return

	var remove_them: Array[Item] = []
	for it in items_there.items:
		var trap: ItemTrap = it as ItemTrap
		if trap == null or not trap.is_activated():
			continue
		do_trigger_trap(trap, map, pos, null, mobj)
		if trap.quantity <= 0:
			remove_them.append(it)
	for it in remove_them:
		map.remove_item_at(it, pos)


## Trigger a trap by an actor or a map object.
func do_trigger_trap(trap: ItemTrap, map: Map, pos: Vector2i, victim: Actor, mobj: MapObject) -> void:
	var model: ItemTrapModel = trap.trap_model()
	var visible: bool = is_visible_to_player(map, pos)

	# flag.
	trap.is_triggered = true

	# effect: damage on victim? (actor)
	var damage: int = model.damage * trap.quantity
	if damage > 0 and victim != null:
		inflict_damage(victim, damage)
		if visible:
			add_message(make_message(victim, "is hurt by %s for %s damage!" % [trap.a_name(), damage]))
			add_overlay(OverlayImage.new(map_to_screen(victim.location.position), GameImages.ICON_MELEE_DAMAGE))
			add_overlay(OverlayText.new(map_to_screen(victim.location.position) + Vector2i(DAMAGE_DX, DAMAGE_DY), Color.WHITE, str(damage), Color.BLACK))
			redraw_play_screen()
			anim_delay(DELAY_NORMAL if victim.is_player else DELAY_SHORT)
			clear_overlays()
			redraw_play_screen()
	# effect: noise? (actor, mobj)
	if model.is_noisy():
		if visible:
			if victim != null:
				add_message(make_message(victim, "stepping on %s makes a bunch of noise!" % trap.a_name()))
			elif mobj != null:
				add_message(Message.new("%s makes a lot of noise!" % capitalize(trap.the_name()), map.local_time.turn_counter))
		on_loud_noise(map, pos, model.noise_name)

	# if one time trigger = desactivate.
	if model.is_one_time_use():
		trap.desactivate()  # alpha10

	# then check break chance (actor, mobj)
	if rules.check_trap_step_on_breaks(trap, mobj):
		if visible:
			if victim != null:
				add_message(make_message(victim, "%s %s." % [conjugate(victim, VERB_CRUSH), trap.the_name()]))
			elif mobj != null:
				add_message(Message.new("%s breaks the %s." % [capitalize(mobj.the_name), trap.the_name()], map.local_time.turn_counter))
		trap.quantity -= 1
#endregion

#region Leaving maps & Using exits (C# lines 13175+)

func do_leave_map(actor: Actor, exit_point: Vector2i, ask_for_confirmation: bool) -> bool:
	var is_player: bool = actor.is_player

	var from_map: Map = actor.location.map
	var from_pos: Vector2i = actor.location.position

	# get exit.
	var exit: Map.Exit = from_map.get_exit_at(exit_point)
	if exit == null:
		if is_player:
			add_message(make_error_message("There is nowhere to go there."))
		return true

	# if player, ask for a confirmation.
	if is_player and ask_for_confirmation:
		clear_messages()
		add_message(make_yes_no_message("REALLY LEAVE %s" % from_map.name))
		redraw_play_screen()
		var confirm: bool = wait_yes_or_no()
		if not confirm:
			add_message(Message.new("Let's stay here a bit longer...", session.world_time.turn_counter, Color.YELLOW))
			redraw_play_screen()
			return false

	# alpha10.1 check autosave before player leaving map
	if is_player:
		check_auto_save_time()

	# Try to leave tile.
	if not try_actor_leave_tile(actor):
		# waste ap.
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
		return false

	# spend AP **IF AI**
	if not actor.is_player:
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# if player is leaving and changing district, prepare district.
	# alpha10.1 disallow bots from leaving districts
	var player_changed_district: bool = false  # alpha10
	if is_player and not actor.is_bot_player and exit.to_map.district != from_map.district:
		player_changed_district = true  # alpha10
		before_player_enter_district(exit.to_map.district)

	# 1. If spot not available, cancel.
	# 2. Remove from previous map (+ corpse)
	# 3. Enter map (+corpse).
	# 4. Handle followers.

	# 1. If spot not available, cancel.
	var other: Actor = exit.to_map.get_actor_at(exit.to_position)
	if other != null:
		if is_player:
			add_message(make_error_message("%s is blocking your way." % other.name))
		return true
	var blocking_obj: MapObject = exit.to_map.get_map_object_at(exit.to_position)
	if blocking_obj != null:
		var can_jump: bool = blocking_obj.is_jumpable and rules.has_actor_jump_ability(actor)
		var ignore_it: bool = blocking_obj.is_couch
		if not can_jump and not ignore_it:
			if is_player:
				add_message(make_error_message("%s is blocking your way." % blocking_obj.a_name))
			return true

	# 2. Remove from previous map (+corpse)
	if is_visible_to_player(actor):
		add_message(make_message(actor, "%s %s." % [conjugate(actor, VERB_LEAVE), from_map.name]))
	from_map.remove_actor(actor)
	if actor.dragged_corpse != null:
		from_map.remove_corpse(actor.dragged_corpse)
	if is_player and exit.to_map.district != from_map.district:
		on_player_leave_district()

	# 3. Enter map (+corpse)
	exit.to_map.place_actor_at(actor, exit.to_position)
	exit.to_map.move_actor_to_first_position(actor)
	if actor.dragged_corpse != null:
		exit.to_map.add_corpse_at(actor.dragged_corpse, exit.to_position)
	if is_visible_to_player(actor) or is_player:
		add_message(make_message(actor, "%s %s." % [conjugate(actor, VERB_ENTER), exit.to_map.name]))
	if is_player:
		# scoring event.
		if from_map.district != exit.to_map.district:
			session.scoring.add_event(session.world_time.turn_counter, "Entered district %s." % exit.to_map.district.name)

		# change map.
		set_current_map(exit.to_map)
	# Trigger stuff.
	on_actor_enter_tile(actor)
	# 4. Handle followers.
	if actor.count_followers > 0:
		do_followers_enter_map(actor, from_map, from_pos, exit.to_map, exit.to_position)

	# alpha10
	# handle player changing district
	if player_changed_district:
		after_player_enter_district()

	# done.
	return true


func do_followers_enter_map(leader: Actor, from_map: Map, from_pos: Vector2i, to_map: Map, to_pos: Vector2i) -> void:
	var leave_people_behind: bool = to_map.district != from_map.district
	var is_player: bool = player == leader
	var left_behind: Array[Actor] = []

	for fo in leader.followers:
		# can follow only if was adj to leader and find free adj spot on the new map.
		var can_follow: bool = false
		var adj_list = null

		if rules.is_adjacent(from_pos, fo.location.position):
			adj_list = to_map.filter_adjacent_in_map(to_pos, func(pt: Vector2i) -> bool:
				return rules.is_walkable_for(fo, to_map, pt.x, pt.y).ok)
			if adj_list == null or adj_list.size() == 0:
				can_follow = false
			else:
				can_follow = true

		if not can_follow:
			# cannot follow.
			left_behind.append(fo)
		else:
			# can follow, do it now.
			# Try to leave tile.
			if try_actor_leave_tile(fo):
				var spot: Vector2i = adj_list[rules.roll(0, adj_list.size())]
				from_map.remove_actor(fo)
				to_map.place_actor_at(fo, spot)
				to_map.move_actor_to_first_position(fo)
				# Trigger stuff.
				on_actor_enter_tile(fo)

	# make followers left behind leave if must.
	if left_behind.size() > 0:
		for leave_me in left_behind:
			if leave_people_behind:
				leader.remove_follower(leave_me)
				if is_player:
					# scoring.
					session.scoring.add_event(session.world_time.turn_counter, "%s was left behind." % leave_me.the_name)

					# message.
					clear_messages()
					add_message(Message.new("%s could not follow you out of the district and left you!" % leave_me.the_name, session.world_time.turn_counter, Color.RED))
					add_message_press_enter()
					clear_messages()
			else:
				if leave_me.location.map == from_map:
					if is_player:
						# message.
						clear_messages()
						add_message(Message.new("%s could not follow and is still in %s." % [leave_me.the_name, from_map.name], session.world_time.turn_counter, Color.YELLOW))
						add_message_press_enter()
						clear_messages()


func do_use_exit(actor: Actor, exit_point: Vector2i) -> bool:
	# leave map.
	return do_leave_map(actor, exit_point, false)
#endregion

#region Leading (C# lines 13338+)

func do_switch_place(actor: Actor, other: Actor) -> void:
	# spend a bunch of ap.
	spend_actor_action_points(actor, 2 * Rules.BASE_ACTION_COST)

	# swap positions.
	var map: Map = other.location.map
	var actor_pos: Vector2i = actor.location.position
	map.remove_actor(other)
	map.place_actor_at(actor, other.location.position)
	map.place_actor_at(other, actor_pos)

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(other):
		add_message(make_message(actor, conjugate(actor, VERB_SWITCH_PLACE_WITH), other))


func do_take_lead(actor: Actor, other: Actor) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# take lead.
	actor.add_follower(other)

	# reset trust in leader.
	var prev_trust: int = other.get_trust_in(actor)
	other.trust_in_leader = prev_trust

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(other):
		if actor == player:
			clear_messages()
		add_message(make_message(actor, conjugate(actor, VERB_PERSUADE), other, " to join."))
		if prev_trust != 0:
			do_say(other, actor, "Ah yes I remember you.", Sayflags.IS_FREE_ACTION)


# alpha10.1
func do_steal_lead(actor: Actor, other: Actor) -> void:
	var prev_leader: Actor = other.leader

	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# remove from previous leader
	prev_leader.remove_follower(other)

	# take lead.
	actor.add_follower(other)

	# reset trust in leader.
	var prev_trust: int = other.get_trust_in(actor)
	other.trust_in_leader = prev_trust

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(other):
		if actor == player:
			clear_messages()
		add_message(make_message(actor, conjugate(actor, VERB_PERSUADE), other, " to leave %s and join." % prev_leader.name))
		if prev_trust != 0:
			do_say(other, actor, "Ah yes I remember you.", Sayflags.IS_FREE_ACTION)


func do_cancel_lead(actor: Actor, follower: Actor) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# remove lead.
	actor.remove_follower(follower)

	# reset trust in leader.
	follower.set_trust_in(actor, follower.trust_in_leader)
	follower.trust_in_leader = Rules.TRUST_NEUTRAL

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(follower):
		if actor == player:
			clear_messages()
		add_message(make_message(actor, conjugate(actor, VERB_PERSUADE), follower, " to leave."))
#endregion

#region Waiting (C# lines 13419+)

func do_wait(actor: Actor) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# message.
	if is_visible_to_player(actor):
		if actor.stamina_points < rules.actor_max_sta(actor):
			add_message(make_message(actor, "%s %s breath." % [conjugate(actor, VERB_CATCH), his_or_her(actor)]))
		else:
			add_message(make_message(actor, "%s." % conjugate(actor, VERB_WAIT)))

	# regen STA.
	regen_actor_stamina_points(actor, Rules.STAMINA_REGEN_WAIT)
#endregion

#region Bumping (C# lines 13442+)

func do_player_bump(p_player: Actor, direction: Direction) -> bool:
	var bump := ActionBump.new(p_player, self, direction)

	if bump == null:
		return false

	# special case: tearing down barricades as living.
	# alpha10.1 moved up because civs models can now bash doors as a bump
	# action; added break check and simplified test
	if (bump.concrete_action is ActionBreak or bump.concrete_action is ActionBashDoor) \
			and not p_player.model.abilities.is_undead:
		var do_what: String = "break " + (bump.concrete_action as ActionBreak).obj.the_name \
				if bump.concrete_action is ActionBreak \
				else "tear down the barricade"

		if rules.is_actor_tired(p_player):
			add_message(make_error_message("Too tired to %s." % do_what))
			redraw_play_screen()
			return false
		else:
			# ask for confirmation.
			add_message(make_yes_no_message("Really %s" % do_what))
			redraw_play_screen()
			var confirm: bool = wait_yes_or_no()

			if confirm:
				bump.concrete_action.perform()
				return true
			else:
				add_message(Message.new("Good, keep everything secure.", session.world_time.turn_counter, Color.YELLOW))
				return false

	if bump.is_legal():
		bump.perform()
		return true

	add_message(make_error_message("Cannot do that : %s." % bump.fail_reason))
	return false
#endregion

#region Making enemies & Attacking (C# lines 13515+)

func do_make_aggression(aggressor: Actor, target: Actor) -> void:
	# no need if in enemy factions.
	if aggressor.faction.is_enemy_of(target.faction):
		return

	var already_enemies: bool = aggressor.is_aggressor_of(target) or target.is_aggressor_of(aggressor)

	# if target is AI and has not aggressor as enemy, emote.
	if not target.is_player and not target.is_sleeping \
			and not aggressor.is_aggressor_of(target) and not target.is_aggressor_of(aggressor):
		do_say(target, aggressor, "BASTARD! TRAITOR!", Sayflags.IS_FREE_ACTION | Sayflags.IS_DANGER)

	# aggressor and selfdefence
	aggressor.mark_as_agressor_of(target)
	target.mark_as_self_defence_from(aggressor)

	# then handle special cases.
	# make enemy of all faction actors on maps:
	# 1. Making an enemy of cops.
	# 2. Making an enemy of soldiers.
	if not target.is_sleeping:
		var t_faction: Faction = target.faction
		# 1. Making an enemy of cops.
		if t_faction == game_factions.the_police():
			# only non-law enforcers or murderers make enemies of cops by attacking cops.
			if not aggressor.model.abilities.is_law_enforcer or rules.is_murder(aggressor, target):
				on_make_enemy_of_cop(aggressor, target, already_enemies)
		# 2. Making an enemy of soldiers.
		elif t_faction == game_factions.the_army():
			on_make_enemy_of_soldier(aggressor, target, already_enemies)


# FIXME factorize common code with on_make_enemy_of_soldier
func on_make_enemy_of_cop(aggressor: Actor, cop: Actor, was_already_enemy: bool) -> void:
	# say.
	if not was_already_enemy:
		do_say(cop, aggressor, "TO DISTRICT PATROLS : %s MUST DIE!" % aggressor.the_name, Sayflags.IS_FREE_ACTION | Sayflags.IS_DANGER)

	# make enemy of all cops in the district.
	make_enemy_of_target_faction_in_district(aggressor, cop, func(a: Actor) -> void:
		if a.is_player and a != cop and not a.is_sleeping and not rules.are_enemies(a, aggressor):
			var turn: int = session.world_time.turn_counter
			clear_messages()
			add_message(Message.new("You get a message from your police radio.", turn, Color.WHITE))
			add_message(Message.new("%s is armed and dangerous. Shoot on sight!" % aggressor.the_name, turn, Color.WHITE))
			add_message(Message.new("Current location : %s@%s,%s" % [aggressor.location.map.name, aggressor.location.position.x, aggressor.location.position.y], turn, Color.WHITE))
			if not a.is_bot_player:
				add_message_press_enter())


# FIXME factorize common code with on_make_enemy_of_cop
func on_make_enemy_of_soldier(aggressor: Actor, soldier: Actor, was_already_enemy: bool) -> void:
	# say.
	if not was_already_enemy:
		do_say(soldier, aggressor, "TO DISTRICT SQUADS : %s MUST DIE!" % aggressor.the_name, Sayflags.IS_FREE_ACTION | Sayflags.IS_DANGER)

	# make enemy of all cops in the district.
	make_enemy_of_target_faction_in_district(aggressor, soldier, func(a: Actor) -> void:
		if a.is_player and a != soldier and not a.is_sleeping and not rules.are_enemies(a, aggressor):
			var turn: int = session.world_time.turn_counter
			clear_messages()
			add_message(Message.new("You get a message from your army radio.", turn, Color.WHITE))
			add_message(Message.new("%s is armed and dangerous. Shoot on sight!" % aggressor.name, turn, Color.WHITE))
			add_message(Message.new("Current location : %s@%s,%s" % [aggressor.location.map.name, aggressor.location.position.x, aggressor.location.position.y], turn, Color.WHITE))
			if not a.is_bot_player:
				add_message_press_enter())


## fn: action to call on faction actor BEFORE making aggressor an enemy.
func make_enemy_of_target_faction_in_district(aggressor: Actor, target: Actor, fn: Callable) -> void:
	var t_faction: Faction = target.faction
	for m in target.location.map.district.maps:
		for a in m.actors_list:
			if a == aggressor or a == target:
				continue
			if a.faction != t_faction:
				continue
			if a.leader == aggressor:
				continue

			# perform additional action on actor.
			if fn != null:
				fn.call(a)

			# aggression & self defence.
			aggressor.mark_as_agressor_of(a)
			a.mark_as_self_defence_from(aggressor)


func do_melee_attack(attacker: Actor, defender: Actor) -> void:
	# set activiy & target.
	attacker.activity = Activity.FIGHTING
	attacker.target_actor = defender

	# if not already enemies, attacker is aggressor.
	if not rules.are_enemies(attacker, defender):
		do_make_aggression(attacker, defender)

	# get attack & defence.
	var attack: Attack = rules.actor_melee_attack(attacker, attacker.current_melee_attack, defender)
	var defence: Defence = rules.actor_defence(defender, defender.current_defence)

	# spend APs & STA.
	spend_actor_action_points(attacker, Rules.BASE_ACTION_COST)
	spend_actor_stamina_points(attacker, Rules.STAMINA_COST_MELEE_ATTACK + attack.stamina_penalty)

	# resolve attack.
	var hit_roll: int = rules.roll_skill(attack.hit_value)
	var def_roll: int = rules.roll_skill(defence.value)

	# loud noise.
	on_loud_noise(attacker.location.map, attacker.location.position, "Nearby fighting")

	# if defender is long waiting player, force stop.
	if is_player_long_wait and defender.is_player:
		is_player_long_wait_forced_stop = true

	# show/hear.
	var is_def_visible: bool = is_visible_to_player(defender)
	var is_att_visible: bool = is_visible_to_player(attacker)
	var is_player: bool = attacker.is_player or defender.is_player
	var is_bot: bool = attacker.is_bot_player or defender.is_bot_player  # alpha10.1 handle bot

	if not is_def_visible and not is_att_visible and not is_player \
			and rules.roll_chance(PLAYER_HEAR_FIGHT_CHANCE):
		add_message_if_audible_for_player(attacker.location, make_player_centric_message("You hear fighting", attacker.location.position))

	if is_att_visible:
		add_overlay(OverlayRect.new(Color.YELLOW, Rect2(map_to_screen(attacker.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
		add_overlay(OverlayRect.new(Color.RED, Rect2(map_to_screen(defender.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
		add_overlay(OverlayImage.new(map_to_screen(attacker.location.position), GameImages.ICON_MELEE_ATTACK))

	# Hit vs Missed
	if hit_roll > def_roll:
		# alpha10
		# roll for attacker disarming defender
		if attacker.model.abilities.can_disarm and rules.roll_chance(attack.disarm_chance):
			var disarm_it: Item = disarm(defender)
			if disarm_it != null:
				# show
				if is_def_visible:
					if is_player:
						clear_messages()
					add_message(make_message(attacker, conjugate(attacker, VERB_DISARM), defender))
					add_message(Message.new("%s is sent flying!" % disarm_it.the_name(), attacker.location.map.local_time.turn_counter))
					if is_player and not is_bot:
						add_message_press_enter()
					else:
						redraw_play_screen()
						anim_delay(DELAY_SHORT)

		# roll damage - double potential if def is sleeping.
		var dmg_roll: int = rules.roll_damage(attack.damage_value * 2 if defender.is_sleeping else attack.damage_value) - defence.protection_hit
		# damage?
		if dmg_roll > 0:
			# inflict dmg.
			inflict_damage(defender, dmg_roll)

			# regen HP/Rot and infection?
			if attacker.model.abilities.can_zombify_killed and not defender.model.abilities.is_undead:
				regen_actor_hit_points(attacker, rules.actor_bite_hp_regen(attacker, dmg_roll))
				attacker.food_points = mini(attacker.food_points + rules.actor_bite_nutrition_value(attacker, dmg_roll), rules.actor_max_rot(attacker))
				if is_att_visible:
					add_message(make_message(attacker, conjugate(attacker, VERB_FEAST_ON), defender, " flesh !"))
				infect_actor(defender, Rules.infection_for_damage(attacker, dmg_roll))

			# Killed?
			if defender.hit_points <= 0:  # def killed!
				# show.
				if is_att_visible or is_def_visible:
					var kill_verb: Verb = VERB_DESTROY if defender.model.abilities.is_undead else (VERB_MURDER if rules.is_murder(attacker, defender) else VERB_KILL)
					add_message(make_message(attacker, conjugate(attacker, kill_verb), defender, " !"))
					add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_KILLED))
					redraw_play_screen()
					anim_delay(DELAY_LONG)

				# kill.
				kill_actor(attacker, defender, "hit")

				# cause insanity?
				if attacker.model.abilities.is_undead and not defender.model.abilities.is_undead:
					seeing_cause_insanity(attacker, attacker.location, Rules.SANITY_HIT_EATEN_ALIVE, "%s eaten alive" % defender.name)

				# turn victim into zombie; always turn player into zombie NOW if
				# killed by zombifier or if was infected.
				if Rules.has_immediate_zombification(session.game_mode) or defender == player:
					if attacker.model.abilities.can_zombify_killed and not defender.model.abilities.is_undead \
							and rules.roll_chance(options.zombification_chance):
						if defender.is_player:
							# remove player corpse.
							defender.location.map.try_remove_corpse_of(defender)
						# add new zombie.
						zombify(attacker, defender, false)

						# show
						if is_def_visible:
							add_message(make_message(attacker, conjugate(attacker, "turn"), defender, " into a Zombie!"))
							redraw_play_screen()
							anim_delay(DELAY_LONG)
					elif defender == player and not defender.model.abilities.is_undead and defender.infection > 0:
						# remove player corpse.
						defender.location.map.try_remove_corpse_of(defender)
						# zombify player!
						zombify(null, defender, false)

						# show
						add_message(make_message(defender, conjugate(defender, "turn") + " into a Zombie!"))
						redraw_play_screen()
						anim_delay(DELAY_LONG)
			else:
				# show
				if is_att_visible or is_def_visible:
					add_message(make_message(attacker, conjugate(attacker, attack.verb), defender, " for %s damage." % dmg_roll))
					add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_MELEE_DAMAGE))
					add_overlay(OverlayText.new(map_to_screen(defender.location.position) + Vector2i(DAMAGE_DX, DAMAGE_DY), Color.WHITE, str(dmg_roll), Color.BLACK))
					redraw_play_screen()
					anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)
		else:
			if is_att_visible or is_def_visible:
				add_message(make_message(attacker, conjugate(attacker, attack.verb), defender, " for no effect."))
				add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_MELEE_MISS))
				redraw_play_screen()
				anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)

	else:  # miss
		# show
		if is_att_visible or is_def_visible:
			add_message(make_message(attacker, conjugate(attacker, VERB_MISS), defender))
			add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_MELEE_MISS))
			redraw_play_screen()
			anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)

	# weapon break?
	var melee_weapon: ItemMeleeWeapon = attacker.get_equipped_weapon() as ItemMeleeWeapon
	if melee_weapon != null and not (melee_weapon.model as ItemMeleeWeaponModel).is_unbreakable:
		var break_chance: int = Rules.MELEE_WEAPON_FRAGILE_BREAK_CHANCE if melee_weapon.is_fragile() else Rules.MELEE_WEAPON_BREAK_CHANCE
		if rules.roll_chance(break_chance):
			# do it.
			# stackable weapons : only break ONE.
			on_unequip_item(attacker, melee_weapon)
			if melee_weapon.quantity > 1:
				melee_weapon.quantity -= 1
			else:
				attacker.inventory.remove_all_quantity(melee_weapon)

			# message.
			if is_att_visible:
				add_message(make_message(attacker, ": %s breaks and is now useless!" % melee_weapon.the_name()))
				redraw_play_screen()
				anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)

	# alpha10 bug fix; clear overlays only if action is visible
	if is_att_visible or is_def_visible:
		clear_overlays()


func do_ranged_attack(attacker: Actor, defender: Actor, lof: Array, mode: int) -> void:
	# if not enemies, aggression.
	if not rules.are_enemies(attacker, defender):
		do_make_aggression(attacker, defender)

	# resolve, depending on mode.
	match mode:
		Attack.FireMode.DEFAULT:
			# spend AP.
			spend_actor_action_points(attacker, Rules.BASE_ACTION_COST)

			# do attack.
			do_single_ranged_attack(attacker, defender, lof, 0)
		Attack.FireMode.RAPID:
			# spend AP.
			spend_actor_action_points(attacker, Rules.BASE_ACTION_COST)

			# 1st attack
			do_single_ranged_attack(attacker, defender, lof, 1)

			# 2nd attack.
			# special cases:
			# - target was killed by 1st attack.
			# - no more ammo.
			var w: ItemRangedWeapon = attacker.get_equipped_weapon() as ItemRangedWeapon
			if defender.is_dead:
				# spend 2nd shot ammo.
				w.ammo -= 1

				# shoot at nothing.
				var attack: Attack = attacker.current_ranged_attack
				add_message(make_message(attacker, "%s at nothing." % conjugate(attacker, attack.verb)))
			elif w.ammo <= 0:
				# fail silently.
				return
			else:
				# perform attack normally.
				do_single_ranged_attack(attacker, defender, lof, 2)
		_:
			push_error("unhandled mode")


## shot_counter: 0 for normal shot, 1 for 1st rapid fire shot, 2 for 2nd rapid fire shot.
func do_single_ranged_attack(attacker: Actor, defender: Actor, lof: Array, shot_counter: int) -> void:
	# set activiy & target.
	attacker.activity = Activity.FIGHTING
	attacker.target_actor = defender

	# get attack & defence.
	var target_distance: int = rules.grid_distance_points(attacker.location.position, defender.location.position)
	var attack: Attack = rules.actor_ranged_attack(attacker, attacker.current_ranged_attack, target_distance, defender)
	var defence: Defence = rules.actor_defence(defender, defender.current_defence)

	# spend STA.
	spend_actor_stamina_points(attacker, attack.stamina_penalty)

	# Firearms weapon jam?
	if attack.kind == Attack.AttackKind.FIREARM:
		var jam_chances: int = Rules.FIREARM_JAM_CHANCE_RAIN if rules.is_weather_rain(session.world.weather) else Rules.FIREARM_JAM_CHANCE_NO_RAIN
		if rules.roll_chance(jam_chances):
			if is_visible_to_player(attacker):
				add_message(make_message(attacker, " : weapon jam!"))
				return

	# spend ammo.
	var weapon: ItemRangedWeapon = attacker.get_equipped_weapon() as ItemRangedWeapon
	if weapon == null:
		push_error("do_single_ranged_attack but no equipped ranged weapon")
		return
	weapon.ammo -= 1

	# check we are firing through something and it intercepts the attack.
	if do_check_fire_through(attacker, lof):
		return

	# if defender is long waiting player, force stop.
	if is_player_long_wait and defender.is_player:
		is_player_long_wait_forced_stop = true

	# resolve attack.
	var hit_value: int = attack.hit_value if shot_counter == 0 else (attack.hit2_value if shot_counter == 1 else attack.hit3_value)
	var hit_roll: int = rules.roll_skill(hit_value)
	var def_roll: int = rules.roll_skill(defence.value)

	# show/hear.
	var is_def_visible: bool = is_visible_to_player(defender.location)
	var is_att_visible: bool = is_visible_to_player(attacker.location)
	var is_player: bool = attacker.is_player or defender.is_player

	if not is_def_visible and not is_att_visible and not is_player \
			and rules.roll_chance(PLAYER_HEAR_FIGHT_CHANCE):
		add_message_if_audible_for_player(attacker.location, make_player_centric_message("You hear firing", attacker.location.position))

	if is_att_visible:
		add_overlay(OverlayRect.new(Color.YELLOW, Rect2(map_to_screen(attacker.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
		add_overlay(OverlayRect.new(Color.RED, Rect2(map_to_screen(defender.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
		add_overlay(OverlayImage.new(map_to_screen(attacker.location.position), GameImages.ICON_RANGED_ATTACK))

	# Hit vs Missed
	if hit_roll > def_roll:
		# roll damage - double potential if def is sleeping.
		var dmg_roll: int = rules.roll_damage(attack.damage_value * 2 if defender.is_sleeping else attack.damage_value) - defence.protection_shot
		if dmg_roll > 0:
			# inflict dmg.
			inflict_damage(defender, dmg_roll)

			# Killed?
			if defender.hit_points <= 0:  # def killed!
				# show.
				if is_def_visible:
					var kill_verb: Verb = VERB_DESTROY if defender.model.abilities.is_undead else (VERB_MURDER if rules.is_murder(attacker, defender) else VERB_KILL)
					add_message(make_message(attacker, conjugate(attacker, kill_verb), defender, " !"))
					add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_KILLED))
					redraw_play_screen()
					anim_delay(DELAY_LONG)

				# kill.
				kill_actor(attacker, defender, "shot")
			else:
				# show
				if is_def_visible:
					add_message(make_message(attacker, conjugate(attacker, attack.verb), defender, " for %s damage." % dmg_roll))
					add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_RANGED_DAMAGE))
					add_overlay(OverlayText.new(map_to_screen(defender.location.position) + Vector2i(DAMAGE_DX, DAMAGE_DY), Color.WHITE, str(dmg_roll), Color.BLACK))
					redraw_play_screen()
					anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)
		else:
			if is_def_visible:
				add_message(make_message(attacker, conjugate(attacker, attack.verb), defender, " for no effect."))
				add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_RANGED_MISS))
				redraw_play_screen()
				anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)
	else:  # miss
		# show
		if is_def_visible:
			add_message(make_message(attacker, conjugate(attacker, VERB_MISS), defender))
			add_overlay(OverlayImage.new(map_to_screen(defender.location.position), GameImages.ICON_RANGED_MISS))
			redraw_play_screen()
			anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)

	# alpha10 bug fix; clear overlays only if action is visible
	if is_att_visible or is_def_visible:
		clear_overlays()


func do_check_fire_through(attacker: Actor, lof: Array) -> bool:
	# check if we are firing through an object that blocks the LoF and breaks.
	for pt in lof:
		var map_obj: MapObject = attacker.location.map.get_map_object_at(pt)
		if map_obj == null:
			continue
		if map_obj.breaks_when_fired_through \
				and map_obj.break_state != MapObject.Break.BROKEN \
				and not map_obj.is_walkable:
			# message.
			var is_att_visible: bool = is_visible_to_player(attacker)
			var is_obj_visible: bool = is_visible_to_player(map_obj)
			if is_att_visible or is_obj_visible:
				if is_att_visible:
					add_overlay(OverlayRect.new(Color.YELLOW, Rect2(map_to_screen(attacker.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
					add_overlay(OverlayImage.new(map_to_screen(attacker.location.position), GameImages.ICON_RANGED_ATTACK))
				if is_obj_visible:
					add_overlay(OverlayRect.new(Color.RED, Rect2(map_to_screen(pt), Vector2(TILE_SIZE, TILE_SIZE))))

				anim_delay(DELAY_NORMAL if attacker.is_player else DELAY_SHORT)

			# destroy that object.
			do_destroy_object(map_obj)

			# fire intercepted.
			return true

	# Line Of Fire completly clear, process normally.
	return false


func do_throw_grenade_unprimed(actor: Actor, target_pos: Vector2i) -> void:
	# get grenade.
	var grenade: ItemGrenade = actor.get_equipped_weapon() as ItemGrenade
	if grenade == null:
		push_error("throwing grenade but no grenade equiped ")
		return

	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# consume grenade.
	actor.inventory.consume(grenade)

	# drop primed grenade at target position.
	var map: Map = actor.location.map
	var primed_grenade := ItemGrenadePrimed.new(game_items.get_model(grenade.primed_model_id))
	map.drop_item_at(primed_grenade, target_pos)

	# message about throwing.
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(actor.location.map, target_pos)
	if is_visible:
		add_overlay(OverlayRect.new(Color.YELLOW, Rect2(map_to_screen(actor.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
		add_overlay(OverlayRect.new(Color.RED, Rect2(map_to_screen(target_pos), Vector2(TILE_SIZE, TILE_SIZE))))
		add_message(make_message(actor, "%s a %s!" % [conjugate(actor, VERB_THROW), grenade.model.single_name]))
		redraw_play_screen()
		anim_delay(DELAY_LONG)
		clear_overlays()
		redraw_play_screen()


func do_throw_grenade_primed(actor: Actor, target_pos: Vector2i) -> void:
	# get grenade.
	var primed_grenade: ItemGrenadePrimed = actor.get_equipped_weapon() as ItemGrenadePrimed
	if primed_grenade == null:
		push_error("throwing primed grenade but no primed grenade equiped ")
		return

	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# remove grenade from inventory.
	actor.inventory.remove_all_quantity(primed_grenade)

	# drop primed grenade at target position.
	actor.location.map.drop_item_at(primed_grenade, target_pos)

	# message about throwing.
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(actor.location.map, target_pos)
	if is_visible:
		add_overlay(OverlayRect.new(Color.YELLOW, Rect2(map_to_screen(actor.location.position), Vector2(TILE_SIZE, TILE_SIZE))))
		add_overlay(OverlayRect.new(Color.RED, Rect2(map_to_screen(target_pos), Vector2(TILE_SIZE, TILE_SIZE))))
		add_message(make_message(actor, "%s back a %s!" % [conjugate(actor, VERB_THROW), primed_grenade.model.single_name]))
		redraw_play_screen()
		anim_delay(DELAY_LONG)
		clear_overlays()
		redraw_play_screen()


func show_blast_image(screen_pos: Vector2, attack: BlastAttack, damage: int) -> void:
	var alpha: float = 0.1 + float(damage) / float(attack.damage[0])
	if alpha > 1.0:
		alpha = 1.0
	add_overlay(OverlayTransparentImage.new(alpha, screen_pos, GameImages.ICON_BLAST))
	add_overlay(OverlayText.new(screen_pos, Color.RED, str(damage), Color.BLACK))


func do_blast(location: Location, blast_attack: BlastAttack) -> void:
	# noise.
	on_loud_noise(location.map, location.position, "A loud EXPLOSION")

	# blast icon vs audio.
	var is_visible: bool = is_visible_to_player(location)
	if is_visible:
		show_blast_image(map_to_screen(location.position), blast_attack, blast_attack.damage[0])
		redraw_play_screen()
		anim_delay(DELAY_LONG)
		redraw_play_screen()
	elif rules.roll_chance(PLAYER_HEAR_EXPLOSION_CHANCE):
		add_message_if_audible_for_player(location, make_player_centric_message("You hear an explosion", location.position))

	# ground zero explosion.
	apply_explosion_damage(location, 0, blast_attack)

	# explosion wave.
	for wave_distance in range(1, blast_attack.radius + 1):
		# do it.
		var any_visible: bool = apply_explosion_wave(location, wave_distance, blast_attack)

		# show.
		if any_visible:
			is_visible = true  # alpha10
			redraw_play_screen()
			anim_delay(DELAY_NORMAL)

	# alpha10 bug fix; clear overlays only if action is visible
	if is_visible:
		clear_overlays()


func apply_explosion_wave(center: Location, wave_distance: int, blast: BlastAttack) -> bool:
	var any_visible: bool = false
	var map: Map = center.map

	var xmin: int = center.position.x - wave_distance
	var xmax: int = center.position.x + wave_distance
	var ymin: int = center.position.y - wave_distance
	var ymax: int = center.position.y + wave_distance

	# north.
	if ymin >= 0:
		for x in range(xmin, xmax + 1):
			any_visible = any_visible or apply_explosion_wave_sub(center, Vector2i(x, ymin), wave_distance, blast)

	# south.
	if ymax < map.height:
		for x in range(xmin, xmax + 1):
			any_visible = any_visible or apply_explosion_wave_sub(center, Vector2i(x, ymax), wave_distance, blast)

	# west.
	# do dont west corners twice!
	# hence the ymin + 1 and < ymax checks.
	if xmin >= 0:
		for y in range(ymin + 1, ymax):
			any_visible = any_visible or apply_explosion_wave_sub(center, Vector2i(xmin, y), wave_distance, blast)

	# east.
	# don't do east corners twice!
	# hence the ymin + 1 and < ymax checks.
	if xmax < map.width:
		for y in range(ymin + 1, ymax):
			any_visible = any_visible or apply_explosion_wave_sub(center, Vector2i(xmax, y), wave_distance, blast)

	# return if any explosion was visible.
	return any_visible


func apply_explosion_wave_sub(blast_center: Location, pt: Vector2i, wave_distance: int, blast: BlastAttack) -> bool:
	if blast_center.map.is_in_bounds_p(pt) \
			and LOS.can_trace_fire_line(blast_center, pt, wave_distance, null):
		# do damage.
		var damage: int = apply_explosion_damage(Location.new(blast_center.map, pt), wave_distance, blast)

		# show if visible.
		if is_visible_to_player(blast_center.map, pt):
			show_blast_image(map_to_screen(pt), blast, damage)
			return true
		else:
			return false

	return false


func apply_explosion_damage(location: Location, distance_from_blast: int, blast: BlastAttack) -> int:
	var map: Map = location.map

	var modified_damage: int = rules.blast_damage(distance_from_blast, blast)

	# if no damage, don't bother.
	if modified_damage <= 0:
		return 0

	# damage actor / carried explosives chain reaction.
	var victim: Actor = map.get_actor_at(location.position)
	if victim != null:
		# carried explosives chain reaction.
		explosion_chain_reaction(victim.inventory, location)

		# damage.
		var dmg_to_victim: int = modified_damage - (victim.current_defence.protection_hit + victim.current_defence.protection_shot) / 2
		if dmg_to_victim > 0:
			# inflict.
			inflict_damage(victim, dmg_to_victim)

			# message.
			if is_visible_to_player(victim):
				add_message(Message.new("%s is hit for %s damage!" % [victim.name, dmg_to_victim], map.local_time.turn_counter, Color.CRIMSON))

			# die? do not kill someone who is already dead, this could happen
			# because of multiple explosions in a single turn.
			if victim.hit_points <= 0 and not victim.is_dead:
				# kill him.
				kill_actor(null, victim, "explosion %s damage" % dmg_to_victim)

				# message?
				if is_visible_to_player(victim):
					add_message(Message.new("%s dies in the explosion!" % victim.name, map.local_time.turn_counter, Color.CRIMSON))
		else:
			add_message(Message.new("%s is hit for no damage." % victim.name, map.local_time.turn_counter, Color.WHITE))

	# destroy items / ground explosives chain reaction.
	var ground_inv: Inventory = map.get_items_at(location.position)
	if ground_inv != null:
		# ground explosives chain reaction.
		explosion_chain_reaction(ground_inv, location)

		# pick items to destroy - don't destroy explosives ready to go, we need
		# them for the chain reaction.
		# the more damage, the more chance.
		# never destroy uniques or unbreakables.
		var destroy_chance: int = modified_damage
		var destroy_items: Array[Item] = []
		for it in ground_inv.items:
			if it.is_unique or it.model.is_unbreakable:
				continue
			if it is ItemPrimedExplosive:
				if (it as ItemPrimedExplosive).fuse_time_left <= 0:
					continue
			if not rules.roll_chance(destroy_chance):
				continue
			destroy_items.append(it)

		# do it.
		for it in destroy_items:
			map.remove_item_at(it, location.position)

	# damage objects?
	if blast.can_damage_objects:
		var obj: MapObject = map.get_map_object_at(location.position)
		if obj != null:
			var door: DoorWindow = obj as DoorWindow
			# damage only breakables or barricaded door/windows.
			if obj.is_breakable or (door != null and door.is_barricaded):
				var damage_to_object: int = modified_damage

				# barricaded doors absorb part of the damage.
				if door != null and door.is_barricaded:
					var barricade_damage: int = mini(door.barricade_points, damage_to_object)
					door.barricade_points -= barricade_damage
					damage_to_object -= barricade_damage

				# then directly damage the object.
				if damage_to_object >= 0:
					obj.hit_points -= damage_to_object
					if obj.hit_points <= 0:
						do_destroy_object(obj)

	# damage corpses?
	var corpses = map.get_corpses_at(location.position)
	if corpses != null:
		for c in corpses:
			inflict_damage_to_corpse(c, modified_damage)

	# destroy walls?
	if blast.can_destroy_walls:
		push_error("blast.destroyWalls not implemented")

	# return damage done.
	return modified_damage


func explosion_chain_reaction(inv: Inventory, location: Location) -> void:
	if inv == null or inv.is_empty:
		return

	# set each explosive item ready to explode.
	var removed_explosives: Array[ItemExplosive] = []
	var added_explosives: Array[ItemPrimedExplosive] = []
	for it in inv.items:
		# explosive?
		var explosive: ItemExplosive = it as ItemExplosive
		if explosive == null:
			continue

		# if a primed explosive, just force fuse to zero.
		var primed_explosive: ItemPrimedExplosive = explosive as ItemPrimedExplosive
		if primed_explosive != null:
			primed_explosive.fuse_time_left = 0
			continue

		# unprimed explosive, prime it, force fuse to zero and drop it at location.
		removed_explosives.append(explosive)
		# add as many primed explosives at explosive quantity (stackables explosives).
		for nb_primed_to_drop in it.quantity:
			primed_explosive = ItemPrimedExplosive.new(game_items.get_model(explosive.primed_model_id))
			primed_explosive.fuse_time_left = 0
			added_explosives.append(primed_explosive)

	# remove explosives from inventory.
	if removed_explosives.size() > 0:
		for remove_it in removed_explosives:
			inv.remove_all_quantity(remove_it)

	# drop primed explosives.
	if added_explosives.size() > 0:
		for add_it in added_explosives:
			location.map.drop_item_at(add_it, location.position)
#endregion


func do_chat(speaker: Actor, target: Actor) -> void:
	# spend APs.
	spend_actor_action_points(speaker, Rules.BASE_ACTION_COST)

	# message
	var is_speaker_visible: bool = is_visible_to_player(speaker)
	var is_target_visible: bool = is_visible_to_player(target)
	if is_speaker_visible or is_target_visible:
		add_message(make_message(speaker, conjugate(speaker, VERB_CHAT_WITH), target))

	# trade?
	if rules.can_actor_initiate_trade_with(speaker, target).ok:
		do_trade(speaker, target)

	# alpha10 recover san after "normal" chat or fast trade
	if speaker.model.abilities.has_sanity:
		regen_actor_sanity(speaker, Rules.SANITY_RECOVER_CHAT_OR_TRADE)
		if is_visible_to_player(speaker):
			add_message(make_message(speaker, "%s better after chatting with" % conjugate(speaker, VERB_FEEL), target))

	if target.model.abilities.has_sanity:
		regen_actor_sanity(target, Rules.SANITY_RECOVER_CHAT_OR_TRADE)
		if is_visible_to_player(target):
			add_message(make_message(target, "%s better after chatting with" % conjugate(speaker, VERB_FEEL), speaker))


# alpha10 "fast" trade uses new trade mechanic of rating items and trades.
# npcs will mostly only make mutually beneficial deals.
# speaker and target are also somehow reversed from how they were in rs9(!?)
# for the player should try to mimick most of trade results obtained by player negociating trade but not mandatory.
func do_trade(speaker: Actor, target: Actor) -> void:
	# clean up activities
	speaker.activity = Activity.IDLE
	target.activity = Activity.IDLE

	var is_visible: bool = is_visible_to_player(speaker) or is_visible_to_player(target)
	if is_visible:
		add_message(make_message(speaker, "wants to make a quick trade with %s." % target.the_name))

	# the basic idea is to pick an item the speaker wants from target inventory,
	# and offer an item the speaker is willing to get rid of.
	var speaker_ai: BaseAI = speaker.controller as BaseAI
	var target_ai: BaseAI = target.controller as BaseAI
	var offered: Item = null
	var asked: Item = null

	# target not willing to trade if is ordered not to
	if not target_ai.directives.can_trade and speaker != target.leader:
		if is_visible:
			add_message(make_message(target, "is not willing to trade."))
		return

	# if speaker is the player, make the npc the speaker so the npc is the one offering an item.
	# alpha10.1 but not for bot
	if speaker.is_player:
		# swap speaker and target so npc is always speaker in fast trade
		var swap: Actor = target
		target = speaker
		speaker = swap
		target_ai = null  # now player
		speaker_ai = speaker.controller as BaseAI

	# get an item the speaker would like from target inventory.
	var asked_rating := [0]
	var pick_asked_item := func() -> Item:
		# pick an item in target inventory the speaker wants, or any item if target has only junk.
		var wants: Array[Item] = target.inventory.filter(func(it: Item) -> bool:
			var r: int = speaker_ai.rate_item(self, it, false)
			# wants anything but junk.
			# don't limit to things speaker needs because the target ai is more likely to value the same item
			# as being needed for himself! also makes for more varied deals.
			return r != BaseAI.ItemRating.JUNK
		)
		if wants.size() == 0:
			# no non-junk items, extend to all items...
			wants.append_array(target.inventory.items)

		# pick one from the wanted list.
		var want_it: Item = wants[rules.roll(0, wants.size())]
		asked_rating[0] = speaker_ai.rate_item(self, want_it, false)
		return want_it

	# can return null
	# get an item the speaker is willing to exhange for the target item it wants.
	var pick_offered_item := func(asked_item: Item, asked_item_rating: int) -> Item:
		var offerables: Array[Item]

		# if target is npc:
		#   - offer any item that could pass a trade deal with this npc (read their ai mind)
		# if target is player:
		#   - cannot use rate trade offer on the npc itself...
		#   - so offer only items we rate less than the one we want (player should negociate deal instead)
		#   - accepting equal item ratings lead to bad deals for the npc, offering a need for a need (eg: a rifle for bullets!)
		# in all offers, never offer the same item model as the one asked eg: a pistol for a pistol!
		if target.is_player:
			offerables = speaker.inventory.filter(func(it: Item) -> bool:
				return it.model != asked_item.model and speaker_ai.rate_item(self, it, true) < asked_item_rating
			)
		else:
			offerables = speaker.inventory.filter(func(it: Item) -> bool:
				if it.model == asked_item.model:
					return false
				# read target ai mind...
				var _tr: int = target_ai.rate_trade_offer(self, speaker, it, asked_item)
				# accept "Maybe" items to be a bit more realistic in not always making perfect deals
				# ("hey! the ai always accept ai trades! they are cheating!")
				# and let charisma influence the final result.
				return _tr != BaseAI.TradeRating.REFUSE
			)

		if offerables.size() == 0:
			# all our items are more valuable than the one we want or only silly deals. no deal.
			return null

		var offer_it: Item = offerables[rules.roll(0, offerables.size())]
		return offer_it

	asked = pick_asked_item.call()
	offered = pick_offered_item.call(asked, asked_rating[0])

	# if no item pairs found, failed trade.
	# either the target has no interesting items for speaker,
	# or the speaker has items too valuable for a trade.
	if asked == null or offered == null:
		if asked == null:
			# speaker finds nothing interesting in target inventory
			if is_visible:
				add_message(make_message(speaker, "is not interested in any item of your items."))
		else:
			# speaker has no item to give away (should not happen if target is player)
			if is_visible:
				add_message(make_message(speaker, "would prefer to keep %s items." % his_or_her(speaker)))
		if target.is_player:
			# help confused players...
			add_message(Message.new("(maybe try negociating a deal instead)", session.world_time.turn_counter, Color.YELLOW))
		return

	# propose.
	# if player, ask.
	# if target is ai, check for it.
	# alpha10.1 handle bot player
	var accept_trade: bool
	if is_visible:
		add_message(make_message(speaker, "%s %s for %s." % [conjugate(speaker, VERB_OFFER), offered.a_name(), asked.a_name()]))
	if target.is_player and not target.is_bot_player:  # speaker always ai unless bot
		# ask player.
		add_overlay(OverlayPopup.new(TRADE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i.ZERO))
		redraw_play_screen()
		accept_trade = wait_yes_or_no()
		clear_overlays()
		redraw_play_screen()
	else:
		# ask target ai/bot (C# DEBUG branch used m_botControl; release branch kept)
		var ai: BaseAI = target_ai
		var r: int = ai.rate_trade_offer(self, speaker, offered, asked)
		if r == BaseAI.TradeRating.ACCEPT:
			accept_trade = true
		elif r == BaseAI.TradeRating.REFUSE:
			accept_trade = false
		else:
			# use charisma on "maybe" trades, similar to what we do for the player in the negociating command we the ai won't
			# exploit the game by asking several times so its ok not to store the charisma roll -_-
			# note that a duo of charismatic npcs could in theory trade back and forth ha!
			if rules.roll_chance(rules.actor_charismatic_trade_chance(speaker)):
				if is_visible:
					do_emote(target, "Okay you convinced me.")
				accept_trade = true
			else:
				accept_trade = false

	# so, deal or not?
	if accept_trade:
		if is_visible:
			add_message(make_message(target, "%s." % conjugate(target, VERB_ACCEPT_THE_DEAL)))
		if target.is_player or speaker.is_player:
			redraw_play_screen()

		# do it
		swap_actor_items(speaker, offered, target, asked)
	else:
		if is_visible:
			add_message(make_message(target, "%s." % conjugate(target, VERB_REFUSE_THE_DEAL)))
		if target.is_player or speaker.is_player:
			redraw_play_screen()

## Swap items after a succesful trade. Used in "fast" trades and player negociating trade.
func swap_actor_items(a: Actor, it_a: Item, b: Actor, it_b: Item) -> void:
	if it_a.is_equipped:
		do_unequip_item(a, it_a)
	if it_b.is_equipped:
		do_unequip_item(b, it_b)

	a.inventory.remove_all_quantity(it_a)
	b.inventory.remove_all_quantity(it_b)

	a.inventory.add_all(it_b)
	b.inventory.add_all(it_a)


func do_say(speaker: Actor, target: Actor, text: String, flags: int) -> void:
	var say_color: Color = SAYOREMOTE_DANGER_COLOR if (flags & Sayflags.IS_DANGER) != 0 else SAYOREMOTE_NORMAL_COLOR

	# spend APS?
	if (flags & Sayflags.IS_FREE_ACTION) == 0:
		spend_actor_action_points(speaker, Rules.BASE_ACTION_COST)

	# message.
	if is_visible_to_player(speaker) or (is_visible_to_player(target) and not (player.is_sleeping and target == player)):
		var is_player: bool = target.is_player
		var is_bot: bool = target.is_bot_player  # alpha10.1 handle bot
		var is_important: bool = (flags & Sayflags.IS_IMPORTANT) != 0
		if is_player and is_important:
			clear_messages()
		add_message(make_message(speaker, "to %s : " % target.the_name, say_color))
		add_message(make_message(speaker, "\"%s\"" % text, say_color))
		if is_player and is_important and not is_bot:
			add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(speaker.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))
			add_message_press_enter()
			clear_overlays()
			remove_last_message()
			redraw_play_screen()


func do_shout(speaker: Actor, text: String) -> void:
	# spend APs.
	spend_actor_action_points(speaker, Rules.BASE_ACTION_COST)

	# loud noise.
	on_loud_noise(speaker.location.map, speaker.location.position, "A SHOUT")

	# message.
	if is_visible_to_player(speaker) or are_linked_by_phone(speaker, player):
		# if player follower, alert!
		if speaker.leader == player and not player.is_bot_player:  # alpha10.1 handle bot
			clear_messages()
			add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(speaker.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))
			add_message(make_message(speaker, "%s!!" % conjugate(speaker, VERB_RAISE_ALARM)))
			if text != null:
				do_emote(speaker, text, true)
			add_message_press_enter()
			clear_overlays()
			remove_last_message()
		else:
			if text == null:
				add_message(make_message(speaker, "%s!" % conjugate(speaker, VERB_SHOUT)))
			else:
				do_emote(speaker, "%s \"%s\"" % [conjugate(speaker, VERB_SHOUT), text], true)


func do_emote(actor: Actor, text: String, is_danger: bool = false) -> void:
	if is_visible_to_player(actor):
		add_message(Message.new("%s : %s" % [actor.the_name, text], actor.location.map.local_time.turn_counter, SAYOREMOTE_DANGER_COLOR if is_danger else SAYOREMOTE_NORMAL_COLOR))


#region Items
func do_take_from_container(actor: Actor, position: Vector2i) -> void:
	var map: Map = actor.location.map

	# get topmost item.
	var it: Item = map.get_items_at(position).top_item

	# take it.
	do_take_item(actor, position, it)


func do_take_item(actor: Actor, position: Vector2i, it: Item) -> void:
	var map: Map = actor.location.map

	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# special case for traps
	if it is ItemTrap:
		var trap: ItemTrap = it as ItemTrap
		# taking a trap desactivates it.
		trap.desactivate()  # alpha10 // trap.IsActivated = false;

	# add to inventory.
	var quantity_before: int = it.quantity
	var add_result: Dictionary = actor.inventory.add_as_much_as_possible(it)
	var quantity_added: int = add_result.added
	# if added all, remove from map.
	if quantity_added == quantity_before:
		var items_there: Inventory = map.get_items_at(position)
		if items_there != null and items_there.contains(it):
			map.remove_item_at(it, position)

	# message
	if is_visible_to_player(actor) or is_visible_to_player(Location.new(map, position)):
		add_message(make_message(actor, conjugate(actor, VERB_TAKE), it))

	# automatically equip item if flags set & possible, and not already equipped something.
	if not it.model.dont_auto_equip and rules.can_actor_equip_item(actor, it).ok and actor.get_equipped_item(it.model.equipment_part) == null:
		do_equip_item(actor, it)


func do_give_item_to(actor: Actor, target: Actor, gift: Item) -> void:
	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# if leader give to follower, improve trust.
	if target.leader == actor:
		# interesting item?
		var ai: BaseAI = target.controller as BaseAI
		var is_interesting_item: bool = ai != null and ai.is_interesting_item_to_own(self, gift, BaseAI.ItemSource.ANOTHER_ACTOR)

		# emote.
		if is_interesting_item:
			do_say(target, actor, "Thank you, I really needed that!", Sayflags.IS_FREE_ACTION)
		else:
			do_say(target, actor, "Thanks I guess...", Sayflags.IS_FREE_ACTION)

		# update trust.
		modify_actor_trust_in_leader(target, Rules.TRUST_GOOD_GIFT_INCREASE if is_interesting_item else Rules.TRUST_MISC_GIFT_INCREASE, true)
	# if follower give to leader, decrease trust.
	elif actor.leader == target:
		# emote.
		do_say(target, actor, "Well, here it is...", Sayflags.IS_FREE_ACTION)

		# update trust.
		modify_actor_trust_in_leader(actor, Rules.TRUST_GIVE_ITEM_ORDER_PENALTY, true)

	# transfer item : drop then take (solves problem of partial quantities transfer).
	drop_item(actor, gift)
	do_take_item(target, actor.location.position, gift)

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(target):
		add_message(make_message(actor, "%s %s to" % [conjugate(actor, VERB_GIVE), gift.the_name()], target))


## AP free
func do_equip_item(actor: Actor, it: Item) -> void:
	# unequip previous item first.
	var previous_item: Item = actor.get_equipped_item(it.model.equipment_part)
	if previous_item != null:
		do_unequip_item(actor, previous_item)

	# equip part.
	it.equipped_part = it.model.equipment_part

	# update revelant datas.
	on_equip_item(actor, it)

	# message
	if is_visible_to_player(actor):
		add_message(make_message(actor, conjugate(actor, VERB_EQUIP), it))


## AP free
func do_unequip_item(actor: Actor, it: Item, can_message: bool = true) -> void:
	# unequip part.
	it.equipped_part = Doll.DollPart.NONE

	# update revelant datas.
	on_unequip_item(actor, it)

	# message.
	if can_message and is_visible_to_player(actor):
		add_message(make_message(actor, conjugate(actor, VERB_UNEQUIP), it))


func on_equip_item(actor: Actor, it: Item) -> void:
	#region Weapons
	if it.model is ItemWeaponModel:
		if it.model is ItemMeleeWeaponModel:
			var melee_model: ItemMeleeWeaponModel = it.model as ItemMeleeWeaponModel
			actor.current_melee_attack = Attack.melee_attack(
				melee_model.attack.verb,
				melee_model.attack.hit_value + actor.sheet.unarmed_attack.hit_value,
				melee_model.attack.damage_value + actor.sheet.unarmed_attack.damage_value,
				melee_model.attack.stamina_penalty,
				melee_model.attack.disarm_chance)
		elif it.model is ItemRangedWeaponModel:
			var ranged_model: ItemRangedWeaponModel = it.model as ItemRangedWeaponModel
			actor.current_ranged_attack = Attack.ranged_attack(
				ranged_model.attack.kind, ranged_model.attack.verb,
				ranged_model.attack.hit_value, ranged_model.attack.hit2_value, ranged_model.attack.hit3_value,
				ranged_model.attack.damage_value,
				ranged_model.attack.range_value)
	#endregion
	#region Armors
	elif it.model is ItemBodyArmorModel:
		var armor_model: ItemBodyArmorModel = it.model as ItemBodyArmorModel
		actor.current_defence = Defence.add(actor.current_defence, armor_model.to_defence())
	#endregion
	#region Batteries
	elif it.model is ItemTrackerModel:
		var tr_it: ItemTracker = it as ItemTracker
		tr_it.batteries -= 1
	elif it.model is ItemLightModel:
		var lt_it: ItemLight = it as ItemLight
		lt_it.batteries -= 1
	#endregion


func on_unequip_item(actor: Actor, it: Item) -> void:
	if it.model is ItemWeaponModel:
		if it.model is ItemMeleeWeaponModel:
			actor.current_melee_attack = actor.sheet.unarmed_attack
		elif it.model is ItemRangedWeaponModel:
			actor.current_ranged_attack = Attack.BLANK
	elif it.model is ItemBodyArmorModel:
		var armor_model: ItemBodyArmorModel = it.model as ItemBodyArmorModel
		actor.current_defence = Defence.sub(actor.current_defence, armor_model.to_defence())


func do_drop_item(actor: Actor, it: Item) -> void:
	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# which item to drop (original or a clone)
	var drop_it: Item = it
	# discard?
	var discard_me: bool = false

	# special case for traps and discared items.
	if it is ItemTrap:
		var trap: ItemTrap = it as ItemTrap

		# drop one at a time.
		var clone: ItemTrap = trap.clone()
		#alpha10 clone.IsActivated = trap.IsActivated;
		if trap.is_activated():  # alpha10
			clone.activate(actor)
		drop_it = clone

		# trap activates when dropped?
		if clone.trap_model().activates_when_dropped():
			clone.activate(actor)  # alpha10 //clone.IsActivated = true;

		# make sure source stack is desactivated (activate only activate the stack top item).
		trap.desactivate()  # alpha10  //trap.IsActivated = false;
	else:
		# drop or discard.
		if it is ItemTracker:
			discard_me = (it as ItemTracker).batteries <= 0
		elif it is ItemLight:
			discard_me = (it as ItemLight).batteries <= 0
		elif it is ItemSprayPaint:
			discard_me = (it as ItemSprayPaint).paint_quantity <= 0
		elif it is ItemSprayScent:
			discard_me = (it as ItemSprayScent).spray_quantity <= 0

	if discard_me:
		discard_item(actor, it)
		# message
		if is_visible_to_player(actor):
			add_message(make_message(actor, conjugate(actor, VERB_DISCARD), it))
	else:
		if drop_it == it:
			drop_item(actor, it)
		else:
			drop_clone_item(actor, it, drop_it)
		# message
		if is_visible_to_player(actor):
			add_message(make_message(actor, conjugate(actor, VERB_DROP), drop_it))


func discard_item(actor: Actor, it: Item) -> void:
	# remove from inventory.
	actor.inventory.remove_all_quantity(it)

	# make sure it is unequipped.
	it.equipped_part = Doll.DollPart.NONE


func drop_item(actor: Actor, it: Item) -> void:
	# remove from inventory.
	actor.inventory.remove_all_quantity(it)

	# add to ground.
	actor.location.map.drop_item_at(it, actor.location.position)

	# make sure it is unequipped.
	it.equipped_part = Doll.DollPart.NONE


func drop_clone_item(actor: Actor, it: Item, clone: Item) -> void:
	# remove one quantity from inventory.
	it.quantity -= 1
	if it.quantity <= 0:
		actor.inventory.remove_all_quantity(it)

	# add to ground.
	actor.location.map.drop_item_at(clone, actor.location.position)

	# make sure it is unequipped.
	clone.equipped_part = Doll.DollPart.NONE


func do_use_item(actor: Actor, it: Item) -> void:
	# alpha10 defrag ai inventories
	var defrag_inventory: bool = not actor.is_player and it.model.is_stackable

	# concrete use.
	if it is ItemFood:
		do_use_food_item(actor, it as ItemFood)
	elif it is ItemMedicine:
		do_use_medicine_item(actor, it as ItemMedicine)
	elif it is ItemAmmo:
		do_use_ammo_item(actor, it as ItemAmmo)
	#elif it is ItemSprayScent:  # alpha10 new way to use spray scent
	#	do_use_spray_scent_item(actor, it as ItemSprayScent)
	elif it is ItemTrap:
		do_use_trap_item(actor, it as ItemTrap)
	elif it is ItemEntertainment:
		do_use_entertainment_item(actor, it as ItemEntertainment)

	# alpha10 defrag ai inventories
	if defrag_inventory:
		actor.inventory.defrag()


func do_eat_food_from_ground(actor: Actor, it: Item) -> void:
	var food: ItemFood = it as ItemFood

	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# recover food points.
	var base_nutrition: int = rules.food_item_nutrition(food, actor.location.map.local_time.turn_counter)
	actor.food_points = mini(actor.food_points + rules.actor_item_nutrition_value(actor, base_nutrition), rules.actor_max_food(actor))

	# consume it.
	var inv: Inventory = actor.location.map.get_items_at(actor.location.position)
	inv.consume(food)

	# message.
	var is_visible: bool = is_visible_to_player(actor)
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_EAT), food))

	# vomit?
	if rules.is_food_spoiled(food, actor.location.map.local_time.turn_counter):
		if rules.roll_chance(Rules.FOOD_EXPIRED_VOMIT_CHANCE):
			do_vomit(actor)

			# message.
			if is_visible:
				add_message(make_message(actor, "%s from eating spoiled food!" % conjugate(actor, VERB_VOMIT)))


func do_use_food_item(actor: Actor, food: ItemFood) -> void:
	#--//////////////////////////////////
	# If player, prevent wasteful usage.
	#--//////////////////////////////////
	if actor == player and actor.food_points >= rules.actor_max_food(actor) - 1:
		add_message(make_error_message("Don't waste food!"))
		return

	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# recover food points.
	var base_nutrition: int = rules.food_item_nutrition(food, actor.location.map.local_time.turn_counter)
	actor.food_points = mini(actor.food_points + rules.actor_item_nutrition_value(actor, base_nutrition), rules.actor_max_food(actor))

	# consume it.
	actor.inventory.consume(food)

	# canned food drops empty cans.
	if food.model == game_items.canned_food():
		var empty_can: ItemTrap = ItemTrap.new(game_items.empty_can())  # alpha10 { IsActivated = true };
		empty_can.activate(actor)  # alpha10
		actor.location.map.drop_item_at(empty_can, actor.location.position)

	# message.
	var is_visible: bool = is_visible_to_player(actor)
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_EAT), food))

	# vomit?
	if rules.is_food_spoiled(food, actor.location.map.local_time.turn_counter):
		if rules.roll_chance(Rules.FOOD_EXPIRED_VOMIT_CHANCE):
			do_vomit(actor)

			# message.
			if is_visible:
				add_message(make_message(actor, "%s from eating spoiled food!" % conjugate(actor, VERB_VOMIT)))


func do_vomit(actor: Actor) -> void:
	# beuargh.
	actor.stamina_points -= Rules.FOOD_VOMIT_STA_COST
	actor.sleep_points = maxi(0, actor.sleep_points - WorldTime.TURNS_PER_HOUR)
	actor.food_points = maxi(0, actor.food_points - WorldTime.TURNS_PER_HOUR)

	# drop vomit ^^.
	var loc: Location = actor.location
	var map: Map = loc.map
	map.get_tile_at(loc.position.x, loc.position.y).add_decoration(GameImages.DECO_VOMIT)


func do_use_medicine_item(actor: Actor, med: ItemMedicine) -> void:
	#--//////////////////////////////////
	# If player, prevent wasteful usage.
	#--//////////////////////////////////
	if actor == player:
		var hp_need: int = rules.actor_max_hps(actor) - actor.hit_points
		var sta_need: int = rules.actor_max_sta(actor) - actor.stamina_points
		var slp_need: int = rules.actor_max_sleep(actor) - 2 - actor.sleep_points
		var cure_need: int = actor.infection
		var san_need: int = rules.actor_max_sanity(actor) - actor.sanity

		var hp_waste: bool = hp_need <= 0 or med.healing <= 0
		var sta_waste: bool = sta_need <= 0 or med.stamina_boost <= 0
		var slp_waste: bool = slp_need <= 0 or med.sleep_boost <= 0
		var cure_waste: bool = cure_need <= 0 or med.infection_cure <= 0
		var san_waste: bool = san_need <= 0 or med.sanity_cure <= 0

		if hp_waste and sta_waste and slp_waste and cure_waste and san_waste:
			add_message(make_error_message("Don't waste medicine!"))
			return

	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# recover HPs, STA, SLP, INF, SAN.
	actor.hit_points = mini(actor.hit_points + rules.actor_medicine_effect(actor, med.healing), rules.actor_max_hps(actor))
	actor.stamina_points = mini(actor.stamina_points + rules.actor_medicine_effect(actor, med.stamina_boost), rules.actor_max_sta(actor))
	actor.sleep_points = mini(actor.sleep_points + rules.actor_medicine_effect(actor, med.sleep_boost), rules.actor_max_sleep(actor))
	actor.infection = maxi(0, actor.infection - rules.actor_medicine_effect(actor, med.infection_cure))
	actor.sanity = mini(actor.sanity + rules.actor_medicine_effect(actor, med.sanity_cure), rules.actor_max_sanity(actor))

	# consume it.
	actor.inventory.consume(med)

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, conjugate(actor, VERB_HEAL_WITH), med))


func do_use_ammo_item(actor: Actor, ammo_item: ItemAmmo) -> void:
	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# get weapon.
	var ranged: ItemRangedWeapon = actor.get_equipped_weapon() as ItemRangedWeapon
	var model: ItemRangedWeaponModel = ranged.model as ItemRangedWeaponModel

	# compute ammo spent.
	var ammo_spent: int = mini(model.max_ammo - ranged.ammo, ammo_item.quantity)

	# reload.
	ranged.ammo += ammo_spent

	# spend ammo clip.
	ammo_item.quantity -= ammo_spent

	# if no ammo left, remove item.
	if ammo_item.quantity <= 0:
		actor.inventory.remove_all_quantity(ammo_item)

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, conjugate(actor, VERB_RELOAD), ranged))


# C# DoUseSprayScentItem was inside #if false: skipped.

func do_use_trap_item(actor: Actor, trap: ItemTrap) -> void:
	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# toggle activation.
	# alpha10 //trap.IsActivated = !trap.IsActivated;
	if trap.is_activated():
		trap.desactivate()
	else:
		trap.activate(actor)

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, conjugate(actor, VERB_ACTIVATE if trap.is_activated() else VERB_DESACTIVATE), trap))


func do_use_entertainment_item(actor: Actor, ent: ItemEntertainment) -> void:
	var visible: bool = is_visible_to_player(actor)

	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# recover san.
	regen_actor_sanity(actor, ent.entertainment_model().value)

	# message.
	if visible:
		add_message(make_message(actor, conjugate(actor, VERB_ENJOY), ent))

	# check boring chance.
	# 100% means discard it.
	var bore_chance: int = ent.entertainment_model().bore_chance
	var bored: bool = false
	var discarded: bool = false
	if bore_chance == 100:
		actor.inventory.consume(ent)
		discarded = true
	elif bore_chance > 0:
		if rules.roll_chance(bore_chance):
			bored = true
	if bored:
		ent.add_boring_for(actor)  # alpha10 boring items item centric

	# message.
	if visible:
		if bored:
			add_message(make_message(actor, "%s now bored of %s." % [conjugate(actor, VERB_BE), ent.the_name()]))
		if discarded:
			add_message(make_message(actor, conjugate(actor, VERB_DISCARD), ent))


func do_recharge_item_battery(actor: Actor, it: Item) -> void:
	# spend APs.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# recharge.
	if it is ItemLight:
		var light: ItemLight = it as ItemLight
		light.batteries += WorldTime.TURNS_PER_HOUR
	elif it is ItemTracker:
		var track: ItemTracker = it as ItemTracker
		track.batteries += WorldTime.TURNS_PER_HOUR

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, conjugate(actor, VERB_RECHARGE), it, " batteries."))


#region Doors
func do_open_door(actor: Actor, door: DoorWindow) -> void:
	# Do it.
	door.set_state(DoorWindow.STATE_OPEN)

	# Message.
	if is_visible_to_player(actor) or is_visible_to_player(door):
		add_message(make_message(actor, conjugate(actor, VERB_OPEN), door))
		redraw_play_screen()

	# Spend APs.
	var open_cost: int = Rules.BASE_ACTION_COST
	spend_actor_action_points(actor, open_cost)


func do_close_door(actor: Actor, door: DoorWindow) -> void:
	# Do it.
	door.set_state(DoorWindow.STATE_CLOSED)

	# Message.
	if is_visible_to_player(actor) or is_visible_to_player(door):
		add_message(make_message(actor, conjugate(actor, VERB_CLOSE), door))
		redraw_play_screen()

	# Spend APs.
	var close_cost: int = Rules.BASE_ACTION_COST
	spend_actor_action_points(actor, close_cost)


func do_barricade_door(actor: Actor, door: DoorWindow) -> void:
	# get barricading item.
	var it: ItemBarricadeMaterial = actor.inventory.get_smallest_stack_by_type(ItemBarricadeMaterial) as ItemBarricadeMaterial  # alpha10
	var m: ItemBarricadeMaterialModel = it.model as ItemBarricadeMaterialModel

	# do it.
	actor.inventory.consume(it)
	door.barricade_points = mini(door.barricade_points + rules.actor_barricading_points(actor, m.barricading_value), Rules.BARRICADING_MAX)

	# message.
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(door)
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_BARRICADE), door))

	# spend AP.
	var barricading_cost: int = Rules.BASE_ACTION_COST
	spend_actor_action_points(actor, barricading_cost)


#region Building & Repairing
func do_build_fortification(actor: Actor, build_pos: Vector2i, is_large: bool) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# consume material.
	var need: int = rules.actor_barricading_material_need_for_fortification(actor, is_large)
	for i in range(need):
		var it: Item = actor.inventory.get_smallest_stack_by_type(ItemBarricadeMaterial)  # alpha10
		#actor.inventory.get_first_by_type(ItemBarricadeMaterial);
		actor.inventory.consume(it)

	# add object.
	var fort_obj: Fortification = town_generator.make_obj_large_fortification(GameImages.OBJ_LARGE_WOODEN_FORTIFICATION) if is_large else town_generator.make_obj_small_fortification(GameImages.OBJ_SMALL_WOODEN_FORTIFICATION)
	actor.location.map.place_map_object_at(fort_obj, build_pos)

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(Location.new(actor.location.map, build_pos)):
		add_message(make_message(actor, "%s a %s fortification." % [conjugate(actor, VERB_BUILD), "large" if is_large else "small"]))

	# check traps.
	check_map_object_triggers_traps(actor.location.map, build_pos)


func do_repair_fortification(actor: Actor, fort: Fortification) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# spend material.
	var material: ItemBarricadeMaterial = actor.inventory.get_smallest_stack_by_type(ItemBarricadeMaterial) as ItemBarricadeMaterial  # alpha10
	#actor.inventory.get_first_by_type(ItemBarricadeMaterial) as ItemBarricadeMaterial;
	if material == null:
		push_error("no material")
		actor.inventory.consume(material)

	# repair HP.
	fort.hit_points = mini(fort.max_hit_points,
		fort.hit_points + rules.actor_barricading_points(actor, (material.model as ItemBarricadeMaterialModel).barricading_value))

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(fort):
		add_message(make_message(actor, conjugate(actor, VERB_REPAIR), fort))


#region Switching map object
func do_switch_power_generator(actor: Actor, pow_gen: PowerGenerator) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# switch it.
	pow_gen.toggle_power()

	# message.
	if is_visible_to_player(actor) or is_visible_to_player(pow_gen):
		add_message(make_message(actor, conjugate(actor, VERB_SWITCH), pow_gen, " on." if pow_gen.is_on else " off."))

	# check for special effects.
	on_map_power_generator_switch(actor.location, pow_gen)

	# done.


#region Breaking stuff
func do_destroy_object(map_obj: MapObject) -> void:
	var door: DoorWindow = map_obj as DoorWindow
	var is_window: bool = door != null and door.is_window

	# force HP to zero.
	map_obj.hit_points = 0

	# drop plank and improvised weapons?
	if map_obj.gives_wood:
		# drop planks.
		var nb_planks: int = 1 + map_obj.max_hit_points / DoorWindow.BASE_HITPOINTS
		while nb_planks > 0:
			var planks: Item = ItemBarricadeMaterial.new(game_items.woodenplank())
			planks.quantity = mini(game_items.woodenplank().stacking_limit, nb_planks)
			if planks.quantity < 1:
				planks.quantity = 1
			map_obj.location.map.drop_item_at(planks, map_obj.location.position)
			nb_planks -= planks.quantity

		# drop improvised weapons?
		if rules.roll_chance(Rules.IMPROVED_WEAPONS_FROM_BROKEN_WOOD_CHANCE):
			# improvised club, improvised spear.
			var imp_wpn: ItemMeleeWeapon
			if rules.roll_chance(50):
				imp_wpn = ItemMeleeWeapon.new(game_items.improvised_club())
			else:
				imp_wpn = ItemMeleeWeapon.new(game_items.improvised_spear())

			# drop it.
			map_obj.location.map.drop_item_at(imp_wpn, map_obj.location.position)

	# remove object - but not windows.
	if is_window:
		door.set_state(DoorWindow.STATE_BROKEN)
	else:
		map_obj.location.map.remove_map_object_at(map_obj.location.position.x, map_obj.location.position.y)

	# loud noise.
	on_loud_noise(map_obj.location.map, map_obj.location.position, "A loud *CRASH*")


func do_break(actor: Actor, map_obj: MapObject) -> void:
	var bash_attack: Attack = rules.actor_melee_attack(actor, actor.current_melee_attack, null, map_obj)

	#region Attacking a barricaded door.
	var door: DoorWindow = map_obj as DoorWindow
	if door != null and door.is_barricaded:
		# Spend APs & STA.
		var bash_cost: int = Rules.BASE_ACTION_COST
		spend_actor_action_points(actor, bash_cost)
		spend_actor_stamina_points(actor, Rules.STAMINA_COST_MELEE_ATTACK)

		# Bash.
		door.barricade_points -= bash_attack.damage_value

		# loud noise.
		on_loud_noise(door.location.map, door.location.position, "A loud *BASH*")

		# message.
		if is_visible_to_player(actor) or is_visible_to_player(door):
			if is_visible_to_player(door):
				# alpha10 tell & show damage
				var screen_pos: Vector2i = map_to_screen(map_obj.location.position)
				add_overlay(OverlayImage.new(screen_pos, GameImages.ICON_MELEE_DAMAGE))
				add_overlay(OverlayText.new(screen_pos + Vector2i(DAMAGE_DX, DAMAGE_DY), Color.WHITE, str(bash_attack.damage_value), Color.BLACK))  # alpha10
				add_message(make_message(actor, "%s the barricade for %d damage." % [conjugate(actor, VERB_BASH), bash_attack.damage_value]))  # alpha10
				redraw_play_screen()
				anim_delay(DELAY_NORMAL if actor.is_player else DELAY_SHORT)
				clear_overlays()
			else:
				add_message(make_message(actor, "%s the barricade." % conjugate(actor, VERB_BASH)))  # alpha10
		else:
			if rules.roll_chance(PLAYER_HEAR_BASH_CHANCE):
				add_message_if_audible_for_player(door.location, make_player_centric_message("You hear someone bashing barricades", door.location.position))

		# done.
		return
	#endregion

	#region Attacking a un-barricaded door or a normal object
	else:
		# Always hit.
		map_obj.hit_points -= bash_attack.damage_value

		# Spend APs & STA.
		var bash_cost: int = Rules.BASE_ACTION_COST
		spend_actor_action_points(actor, bash_cost)
		spend_actor_stamina_points(actor, Rules.STAMINA_COST_MELEE_ATTACK)

		# Broken?
		var is_broken: bool = false
		if map_obj.hit_points <= 0:
			# breaks.
			do_destroy_object(map_obj)
			is_broken = true

		# loud noise.
		on_loud_noise(map_obj.location.map, map_obj.location.position, "A loud *CRASH*")

		# Message.
		var is_actor_visible: bool = is_visible_to_player(actor)
		var is_door_visible: bool = is_visible_to_player(map_obj)
		var is_player: bool = actor.is_player

		if is_actor_visible or is_door_visible:
			if is_actor_visible:
				add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(actor.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))
			if is_door_visible:
				add_overlay(OverlayRect.new(Color.RED, Rect2i(map_to_screen(map_obj.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))

			if is_broken:
				add_message(make_message(actor, conjugate(actor, VERB_BREAK), map_obj))
				if is_actor_visible:
					add_overlay(OverlayImage.new(map_to_screen(actor.location.position), GameImages.ICON_MELEE_ATTACK))
				if is_door_visible:
					add_overlay(OverlayImage.new(map_to_screen(map_obj.location.position), GameImages.ICON_KILLED))
				redraw_play_screen()
				anim_delay(DELAY_LONG)
			else:
				if is_door_visible:
					add_message(make_message(actor, "%s %s for %d damage." % [conjugate(actor, VERB_BASH), map_obj.the_name, bash_attack.damage_value]))  # alpha10
					add_overlay(OverlayImage.new(map_to_screen(map_obj.location.position), GameImages.ICON_MELEE_DAMAGE))
					add_overlay(OverlayText.new(map_to_screen(map_obj.location.position) + Vector2i(DAMAGE_DX, DAMAGE_DY), Color.WHITE, str(bash_attack.damage_value), Color.BLACK))  # alpha10
				elif is_actor_visible:
					add_message(make_message(actor, "%s %s." % [conjugate(actor, VERB_BASH), map_obj.the_name]))  # alpha10

				if is_actor_visible:
					add_overlay(OverlayImage.new(map_to_screen(actor.location.position), GameImages.ICON_MELEE_ATTACK))

				redraw_play_screen()
				anim_delay(DELAY_NORMAL if is_player else DELAY_SHORT)

			# alpha10 bug fix; clear overlays only if action is visible
			clear_overlays()  # was in the wrong place!
		# any is visible
		else:
			if is_broken:
				if rules.roll_chance(PLAYER_HEAR_BREAK_CHANCE):
					add_message_if_audible_for_player(map_obj.location, make_player_centric_message("You hear someone breaking furniture", map_obj.location.position))
			else:
				if rules.roll_chance(PLAYER_HEAR_BASH_CHANCE):
					add_message_if_audible_for_player(map_obj.location, make_player_centric_message("You hear someone bashing furniture", map_obj.location.position))
	#endregion


#region Pushing/Pulling & Shoving
# alpha10. C# used 'ref int staCost'; ported as returning the (possibly shared) cost.
func do_push_pull_followers_help(actor: Actor, map_obj: MapObject, is_pulling: bool, sta_cost: int) -> int:
	var is_visible_mobj: bool = is_visible_to_player(map_obj)

	var helpers: Array[Actor] = []
	for fo: Actor in actor.followers:
		# follower can help if: not sleeping, idle and adj to map object.
		if not fo.is_sleeping and (fo.activity == Activity.IDLE or fo.activity == Activity.FOLLOWING) and rules.is_adjacent(fo.location, map_obj.location):
			helpers.append(fo)
	if not helpers.is_empty():
		# share the sta cost.
		sta_cost = map_obj.weight / (1 + helpers.size())
		for h: Actor in helpers:
			# spend fo AP & STA.
			spend_actor_action_points(h, Rules.BASE_ACTION_COST)
			spend_actor_stamina_points(h, sta_cost)
			# message.
			if is_visible_mobj or is_visible_to_player(h):
				add_message(make_message(h, "%s %s %s %s." % [conjugate(h, VERB_HELP), actor.the_name, "pulling" if is_pulling else "pushing", map_obj.the_name]))
	return sta_cost


func do_push(actor: Actor, map_obj: MapObject, to_pos: Vector2i) -> void:
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(map_obj)
	var sta_cost: int = map_obj.weight

	# followers help?
	if actor.count_followers > 0:
		sta_cost = do_push_pull_followers_help(actor, map_obj, false, sta_cost)  # alpha10

	# spend AP & STA.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
	spend_actor_stamina_points(actor, sta_cost)

	# do it : move object, then move actor if he is pushing it away and can enter the tile.
	var map: Map = map_obj.location.map
	var prev_obj_pos: Vector2i = map_obj.location.position
	map.remove_map_object_at(map_obj.location.position.x, map_obj.location.position.y)
	map.place_map_object_at(map_obj, to_pos)
	if not rules.is_adjacent(to_pos, actor.location.position) and rules.is_walkable_for(actor, map, prev_obj_pos.x, prev_obj_pos.y).ok:
		# pushing away, need to follow.
		if try_actor_leave_tile(actor):  # alpha10
			map.remove_actor(actor)
			map.place_actor_at(actor, prev_obj_pos)
			on_actor_enter_tile(actor)  # alpha10

	# noise/message.
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_PUSH), map_obj))
		redraw_play_screen()
	else:
		# loud noise.
		on_loud_noise(map, to_pos, "Something being pushed")

		# player hears?
		if rules.roll_chance(PLAYER_HEAR_PUSHPULL_CHANCE):
			add_message_if_audible_for_player(map_obj.location, make_player_centric_message("You hear something being pushed", to_pos))

	# check traps.
	check_map_object_triggers_traps(map, to_pos)


func do_shove(actor: Actor, target: Actor, to_pos: Vector2i) -> void:
	# Target try to leave tile.
	if not try_actor_leave_tile(target):
		# waste ap.
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
		return

	# spend AP & STA.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
	spend_actor_stamina_points(actor, Rules.DEFAULT_ACTOR_WEIGHT)

	# force target to stop dragging corpses.
	do_stop_dragging_corpses(target)

	# do it : move target, then move actor if he is pushing it away and can enter the tile.
	var map: Map = target.location.map
	var prev_target_pos: Vector2i = target.location.position
	map.place_actor_at(target, to_pos)
	if not rules.is_adjacent(to_pos, actor.location.position) and rules.is_walkable_for(actor, map, prev_target_pos.x, prev_target_pos.y).ok:
		# shoving away, need to follow.
		# Try to leave tile.
		if try_actor_leave_tile(actor):  # alpha10
			map.remove_actor(actor)
			map.place_actor_at(actor, prev_target_pos)
			# Trigger stuff.
			on_actor_enter_tile(actor)

	# message.
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(target) or is_visible_to_player(map, to_pos)
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_SHOVE), target))
		redraw_play_screen()

	# if target is sleeping, wakes him up!
	if target.is_sleeping:
		do_wake_up(target)

	# Trigger stuff.
	on_actor_enter_tile(target)


# alpha10
func do_pull(actor: Actor, map_obj: MapObject, move_actor_to_pos: Vector2i) -> void:
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(map_obj)
	var sta_cost: int = map_obj.weight

	# try leaving tile
	if not try_actor_leave_tile(actor):
		# waste ap.
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
		return

	# followers help?
	if actor.count_followers > 0:
		sta_cost = do_push_pull_followers_help(actor, map_obj, true, sta_cost)

	# spend AP & STA.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
	spend_actor_stamina_points(actor, sta_cost)

	# do it : move actor then move object
	var map: Map = map_obj.location.map
	# actor...
	var pull_object_to: Vector2i = actor.location.position
	map.remove_actor(actor)
	map.place_actor_at(actor, move_actor_to_pos)  # assumed to be walkable, checked by rules
	# ...object
	map.remove_map_object_at(map_obj.location.position.x, map_obj.location.position.y)
	map.place_map_object_at(map_obj, pull_object_to)

	# noise/message.
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_PULL), map_obj))
		redraw_play_screen()
	else:
		# loud noise.
		on_loud_noise(map, map_obj.location.position, "Something being pushed")

		# player hears?
		if rules.roll_chance(PLAYER_HEAR_PUSHPULL_CHANCE):
			add_message_if_audible_for_player(map_obj.location, make_player_centric_message("You hear something being pushed", map_obj.location.position))

	# check triggers
	on_actor_enter_tile(actor)
	check_map_object_triggers_traps(map, map_obj.location.position)


# alpha10
func do_pull_actor(actor: Actor, target: Actor, move_actor_to_pos: Vector2i) -> void:
	var is_visible: bool = is_visible_to_player(actor) or is_visible_to_player(target)

	# try leaving tile, both actors and target
	if not try_actor_leave_tile(actor):
		# waste ap.
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
		return
	if not try_actor_leave_tile(target):
		# waste ap.
		spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
		return

	# spend AP & STA.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)
	spend_actor_stamina_points(actor, Rules.DEFAULT_ACTOR_WEIGHT)

	# force target to stop dragging corpses.
	do_stop_dragging_corpses(target)

	# do it : move actor then move target
	var map: Map = target.location.map
	# move actor...
	var pull_target_to: Vector2i = actor.location.position
	map.remove_actor(actor)
	map.place_actor_at(actor, move_actor_to_pos)
	# ...move target
	map.remove_actor(target)
	map.place_actor_at(target, pull_target_to)

	# if target is sleeping, wakes him up!
	if target.is_sleeping:
		do_wake_up(target)

	# message
	if is_visible:
		add_message(make_message(actor, conjugate(actor, VERB_PULL), target))
		redraw_play_screen()

	# Trigger stuff.
	on_actor_enter_tile(actor)
	on_actor_enter_tile(target)


#region Sleeping & Waking up
func do_start_sleeping(actor: Actor) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# force actor to stop dragging corpses.
	do_stop_dragging_corpses(actor)

	# set activity & state.
	actor.activity = Activity.SLEEPING
	actor.is_sleeping = true


func do_wake_up(actor: Actor) -> void:
	# set activity & state.
	actor.activity = Activity.IDLE
	actor.is_sleeping = false

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, "%s." % conjugate(actor, VERB_WAKE_UP)))

	# stop sleep music if player.
	if actor.is_player and music_manager.music == GameMusics.SLEEP:
		music_manager.stop()


#region Tagging
func do_tag(actor: Actor, spray: ItemSprayPaint, pos: Vector2i) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# spend paint.
	spray.paint_quantity -= 1

	# add tag decoration.
	var map: Map = actor.location.map
	map.get_tile_at(pos.x, pos.y).add_decoration((spray.model as ItemSprayPaintModel).tag_image_id)

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, "%s a tag." % conjugate(actor, VERB_SPRAY)))


# alpha10 new way to use spray scent
#region Spray scent
func do_spray_odor_suppressor(actor: Actor, suppressor: ItemSprayScent, spray_on: Actor) -> void:
	# spend AP.
	spend_actor_action_points(actor, Rules.BASE_ACTION_COST)

	# spend spray.
	suppressor.spray_quantity -= 1

	# add odor suppressor on spray target
	spray_on.odor_suppressor_counter += suppressor.strength()

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, "%s %s." % [conjugate(actor, VERB_SPRAY),
			himself_or_herself(actor) if spray_on == actor else spray_on.the_name]))


#region Ordering
func do_give_order_to(master: Actor, slave: Actor, order: ActorOrder) -> void:
	# master spend AP.
	spend_actor_action_points(master, Rules.BASE_ACTION_COST)

	# refuse if :
	# - master is not slave leader.
	# - slave is not trusting leader.
	if master != slave.leader:
		do_say(slave, master, "Who are you to give me orders?", Sayflags.IS_FREE_ACTION)
		return
	if not rules.is_actor_trusting_leader(slave):
		do_say(slave, master, "Sorry, I don't trust you enough yet.", Sayflags.IS_FREE_ACTION | Sayflags.IS_IMPORTANT)
		return

	# get AI.
	var ai: AIController = slave.controller as AIController
	if ai == null:
		return

	# give order.
	ai.set_order(order)

	# message.
	if is_visible_to_player(master) or is_visible_to_player(slave):
		add_message(make_message(master, conjugate(master, VERB_ORDER), slave, " to %s." % str(order)))


func do_cancel_order(master: Actor, slave: Actor) -> void:
	# master spend AP.
	spend_actor_action_points(master, Rules.BASE_ACTION_COST)

	# get AI.
	var ai: AIController = slave.controller as AIController
	if ai == null:
		return

	# cancel order.
	ai.set_order(null)

	# message.
	if is_visible_to_player(master) or is_visible_to_player(slave):
		add_message(make_message(master, conjugate(master, VERB_ORDER), slave, " to forget its orders."))


func on_loud_noise(map: Map, noise_position: Vector2i, noise_name: String) -> void:
	# Check if nearby sleeping actors wake up.
	# Check long wait interruption.
	var xmin := noise_position.x - Rules.LOUD_NOISE_RADIUS
	var xmax := noise_position.x + Rules.LOUD_NOISE_RADIUS
	var ymin := noise_position.y - Rules.LOUD_NOISE_RADIUS
	var ymax := noise_position.y + Rules.LOUD_NOISE_RADIUS
	var p := map.trim_to_bounds(xmin, ymin)
	xmin = p.x
	ymin = p.y
	p = map.trim_to_bounds(xmax, ymax)
	xmax = p.x
	ymax = p.y

	# Waking up nearby actors.
	for x in range(xmin, xmax + 1):
		for y in range(ymin, ymax + 1):
			# sleeping actor?
			var actor := map.get_actor_at_xy(x, y)
			if actor == null or not actor.is_sleeping:
				continue

			# ignore if too far.
			var noise_distance := rules.grid_distance(noise_position, x, y)
			if noise_distance > Rules.LOUD_NOISE_RADIUS:
				continue

			# roll chance of waking up.
			var wakeup_chance := rules.actor_loud_noise_wakeup_chance(actor, noise_distance)
			if not rules.roll_chance(wakeup_chance):
				continue

			# wake up!
			do_wake_up(actor)
			if is_visible_to_player(actor):
				add_message(Message.new("%s wakes %s up!" % [noise_name, actor.the_name], map.local_time.turn_counter, Color.RED if actor == player else Color.WHITE))
				redraw_play_screen()

	# Interrupting long wait.
	if is_player_long_wait and map == player.location.map and is_visible_to_player(map, noise_position):
		# interrupt!
		is_player_long_wait_forced_stop = true


func inflict_damage(actor: Actor, dmg: int) -> void:
	# HP.
	actor.hit_points -= dmg

	# Stamina.
	if actor.model.abilities.can_tire:
		actor.stamina_points -= dmg

	# Body armor breaks?
	var torso_item := actor.get_equipped_item(Doll.DollPart.TORSO)
	if torso_item != null and torso_item is ItemBodyArmor:
		if rules.roll_chance(Rules.BODY_ARMOR_BREAK_CHANCE):
			# do it.
			on_unequip_item(actor, torso_item)
			actor.inventory.remove_all_quantity(torso_item)

			# message.
			if is_visible_to_player(actor):
				add_message(make_message(actor, ": %s breaks and is now useless!" % torso_item.the_name))
				redraw_play_screen()
				anim_delay(DELAY_NORMAL if actor.is_player else DELAY_SHORT)

	# If sleeping, wake up dude!
	if actor.is_sleeping:
		do_wake_up(actor)


# alpha10 drop corpse optional
func kill_actor(killer: Actor, dead_guy: Actor, reason: String, can_drop_corpse: bool = true) -> void:
	# Set dead flag.
	dead_guy.is_dead = true

	# force to stop dragging corpses.
	do_stop_dragging_corpses(dead_guy)

	# untrigger all traps here.
	untrigger_all_traps_here(dead_guy.location)

	# living killing undead = restore sanity.
	if killer != null and not killer.model.abilities.is_undead and killer.model.abilities.has_sanity and dead_guy.model.abilities.is_undead:
		regen_actor_sanity(killer, Rules.SANITY_RECOVER_KILL_UNDEAD)

	# death of bonded leader/follower hits sanity.
	if dead_guy.has_leader:
		if rules.has_actor_bond_with(dead_guy.leader, dead_guy):
			spend_actor_sanity(dead_guy.leader, Rules.SANITY_HIT_BOND_DEATH)
			if is_visible_to_player(dead_guy.leader):
				if dead_guy.leader.is_player and not dead_guy.leader.is_bot_player:
					clear_messages()
				add_message(make_message(dead_guy.leader, "%s deeply disturbed by %s sudden death!" % [conjugate(dead_guy.leader, VERB_BE), dead_guy.name]))
				if dead_guy.leader.is_player and not dead_guy.leader.is_bot_player:
					add_message_press_enter()
	else:
		if dead_guy.count_followers > 0:
			for fo in dead_guy.followers:
				if rules.has_actor_bond_with(fo, dead_guy):
					spend_actor_sanity(fo, Rules.SANITY_HIT_BOND_DEATH)
					if is_visible_to_player(fo):
						if fo.is_player and not fo.is_bot_player:
							clear_messages()
						add_message(make_message(fo, "%s deeply disturbed by %s sudden death!" % [conjugate(fo, VERB_BE), dead_guy.name]))
						if fo.is_player and not fo.is_bot_player:
							add_message_press_enter()

	# Unique actor?
	if dead_guy.is_unique:
		if killer != null:
			session.scoring.add_event(dead_guy.location.map.local_time.turn_counter,
				"* %s was killed by %s %s! *" % [dead_guy.the_name, killer.model.name, killer.the_name])
		else:
			session.scoring.add_event(dead_guy.location.map.local_time.turn_counter,
				"* %s died by %s! *" % [dead_guy.the_name, reason])

	# Player dead?
	# BEFORE removing followers & dropping items.
	if dead_guy == player:
		player_died(killer, reason)

	# Remove followers.
	dead_guy.remove_all_followers()

	# Remove from leader.
	if dead_guy.leader != null:
		# player's follower killed : scoring and message.
		if dead_guy.leader.is_player:
			var death_event: String
			if killer != null:
				death_event = "Follower %s was killed by %s %s!" % [dead_guy.the_name, killer.model.name, killer.the_name]
			else:
				death_event = "Follower %s died by %s!" % [dead_guy.the_name, reason]
			session.scoring.add_event(dead_guy.location.map.local_time.turn_counter, death_event)

		dead_guy.leader.remove_follower(dead_guy)

	# Remove aggressor & self defence relations.
	var was_murder := killer != null and rules.is_murder(killer, dead_guy)
	# C# RemoveAllAgressorSelfDefenceRelations() (not yet on Actor port): inline it.
	while dead_guy.aggressor_of != null and not dead_guy.aggressor_of.is_empty():
		var other: Actor = dead_guy.aggressor_of[0]
		dead_guy.remove_aggressor_of(other)
		other.remove_self_defence_from(dead_guy)
	while dead_guy.self_defence_from != null and not dead_guy.self_defence_from.is_empty():
		var other: Actor = dead_guy.self_defence_from[0]
		dead_guy.remove_self_defence_from(other)
		other.remove_aggressor_of(dead_guy)

	# Remove from map.
	dead_guy.location.map.remove_actor(dead_guy)

	# Drop some inventory items.
	if dead_guy.inventory != null and not dead_guy.inventory.is_empty:
		var dead_items_count := dead_guy.inventory.count_items
		var drop_them: Array[Item] = []
		drop_them.resize(dead_items_count)
		for i in dead_items_count:
			drop_them[i] = dead_guy.inventory.get_item_at(i)
		for i in dead_items_count:
			var it := drop_them[i]
			var chance := Rules.VICTIM_DROP_AMMOFOOD_ITEM_CHANCE if (it is ItemAmmo or it is ItemFood) else Rules.VICTIM_DROP_GENERIC_ITEM_CHANCE
			if it.model.is_unbreakable or it.is_unique or rules.roll_chance(chance):
				drop_item(dead_guy, it)

	# Blood splat/Remains
	if not dead_guy.model.abilities.is_undead:
		splatter_blood(dead_guy.location.map, dead_guy.location.position)

	# Corpse?
	if Rules.has_corpses(session.game_mode):
		if not dead_guy.model.abilities.is_undead and can_drop_corpse:
			drop_corpse(dead_guy)

	# One more kill
	if killer != null:
		killer.kills_count += 1

	# Player scoring
	if killer == player:
		player_kill(dead_guy)

	# Undead level up?
	if killer != null and Rules.has_evolution(session.game_mode):
		if killer.model.abilities.is_undead:
			# check for evolution.
			var level_up_model: ActorModel = check_undead_evolution(killer)
			if level_up_model != null:
				# Remember skills if any.
				var saved_skills: SkillTable = null
				if killer.sheet.skill_table != null and killer.sheet.skill_table.skills() != null:
					saved_skills = SkillTable.new(killer.sheet.skill_table.skills())

				# Do the transformation.
				killer.model = level_up_model

				# If player, make sure it is setup properly.
				if killer.is_player:
					prepare_actor_for_player_control(killer)

				# If had skills, give them back.
				if saved_skills != null:
					for s in saved_skills.skills():
						for i in s.level:
							killer.sheet.skill_table.add_or_increase_skill(s.id)
							on_skill_upgrade(killer, s.id)
					town_generator.recompute_actor_starting_stats(killer)

				# Message.
				if is_visible_to_player(killer):
					# TODO: OverlayRect inner class (RogueGame.cs lines 452-644) not ported yet
					add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(killer.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))
					add_message(make_message(killer, "%s a %s horror!" % [conjugate(killer, VERB_TRANSFORM_INTO), level_up_model.name]))
					redraw_play_screen()
					anim_delay(DELAY_LONG)
					clear_overlays()

	# Trust : leader killing a follower target or adjacent enemy.
	if killer != null and killer.count_followers > 0:
		for fo in killer.followers:
			var gain_trust := false
			if fo.target_actor == dead_guy or (rules.are_enemies(fo, dead_guy) and rules.is_adjacent(fo.location, dead_guy.location)):
				gain_trust = true

			if gain_trust:
				do_say(fo, killer, "That was close! Thanks for the help!!", Sayflags.IS_FREE_ACTION)
				modify_actor_trust_in_leader(fo, Rules.TRUST_LEADER_KILL_ENEMY, true)

	# Murder?
	if was_murder:
		# one more murder.
		killer.murders_counter += 1

		# if player, log.
		if killer.is_player:
			session.scoring.add_event(session.world_time.turn_counter, "Murdered %s a %s!" % [dead_guy.the_name, dead_guy.model.name])
		# message.
		if is_visible_to_player(killer):
			add_message(make_message(killer, "murdered %s!!" % dead_guy.name))

		# check for npcs law enforcers witnessing the murder.
		var map := killer.location.map
		var killer_pos := killer.location.position
		for a in map.actors_list:
			# check ability and state/relationship
			if not a.model.abilities.is_law_enforcer or a.is_dead or a.is_sleeping or a.is_player \
					or a == killer or a == dead_guy or a.leader == killer or killer.leader == a:
				continue

			# do as less computations as possible : we don't need all the actor f*****g fov, just the line to the murderer.

			# fov range check.
			if rules.grid_distance_points(a.location.position, killer_pos) > rules.actor_fov(a, map.local_time, session.world.weather):
				continue

			# LOS check.
			if not LOS.can_trace_view_line(a.location, killer_pos):
				continue

			# we see the murderer!
			# make enemy and emote.
			do_say(a, killer, "MURDER! %s HAS KILLED %s!" % [killer.the_name, dead_guy.the_name], Sayflags.IS_FREE_ACTION | Sayflags.IS_IMPORTANT)
			do_make_aggression(a, killer)

	# Emote: a law enforcer killing a murderer feels warm and fuzzy inside.
	if killer != null and dead_guy.murders_counter > 0 and killer.model.abilities.is_law_enforcer and not killer.faction.is_enemy_of(dead_guy.faction):
		if killer.is_player:
			add_message(Message.new("You feel like you did your duty with killing a murderer.", session.world_time.turn_counter, Color.WHITE))
		else:
			do_say(killer, dead_guy, "Good riddance, murderer!", Sayflags.IS_FREE_ACTION | Sayflags.IS_DANGER)

	#--//////////////////////////////////////////
	# Player or Player Followers Killing Uniques
	#--//////////////////////////////////////////
	# The Sewers Thing
	if dead_guy == session.unique_actors.the_sewers_thing.the_actor:
		if killer == player or killer.leader == player:
			# scoring.
			session.scoring.set_completed_achievement(Scoring.Achievement.IDs.KILLED_THE_SEWERS_THING)

			# achievement!
			show_new_achievement(Scoring.Achievement.IDs.KILLED_THE_SEWERS_THING)


# alpha10
# returns the disarmed item or null if actor had no equipped item
func disarm(actor: Actor) -> Item:
	var disarm_it: Item = null

	# pick equipped item to disarm : prefer weapon, then any right handed item(?), then left handed.
	disarm_it = actor.get_equipped_weapon()
	if disarm_it == null:
		disarm_it = actor.get_equipped_item(Doll.DollPart.RIGHT_HAND)
		if disarm_it == null:
			disarm_it = actor.get_equipped_item(Doll.DollPart.LEFT_HAND)

	if disarm_it == null:
		return null

	# unequip, remove from inv and drop item in a random adjacent tile
	# if none possible, will drop on same tile (which then has no almost no gameplay effect
	# because the actor can take it back asap at no ap cost... unless he dies)
	do_unequip_item(actor, disarm_it, false)
	actor.inventory.remove_all_quantity(disarm_it)
	var drop_tiles: Array[Vector2i] = []
	actor.location.map.for_each_adjacent_in_map(actor.location.position,
		func(pt: Vector2i) -> void:
			# checking if can drop there is eq to checking if can throw it there
			if not actor.location.map.is_blocking_throw(pt.x, pt.y):
				drop_tiles.append(pt)
	)
	var drop_on_tile: Vector2i
	if drop_tiles.size() > 0:
		drop_on_tile = drop_tiles[rules.roll(0, drop_tiles.size())]
	else:
		drop_on_tile = actor.location.position
	actor.location.map.drop_item_at(disarm_it, drop_on_tile)

	# done
	return disarm_it


#region Undeads leveling up
func check_undead_evolution(undead: Actor) -> ActorModel:
	# check option & game mode.
	if not options.allow_undeads_evolution or not Rules.has_evolution(session.game_mode):
		return null

	# evolve?
	var evolve := false
	match undead.model.id:
		# zombie master 4 kills  & Day > X -> zombie lord
		GameActors.IDs.UNDEAD_ZOMBIE_MASTER:
			if undead.kills_count < 4:
				return null
			if undead.location.map.local_time.day < ZOMBIE_LORD_EVOLUTION_MIN_DAY and not undead.is_player:
				return null
			evolve = true
		# zombie lord 8 kills -> zombie prince.
		GameActors.IDs.UNDEAD_ZOMBIE_LORD:
			if undead.kills_count < 8:
				return null
			evolve = true
		# skeleton 2 kills -> red eyed skeleton
		GameActors.IDs.UNDEAD_SKELETON:
			if undead.kills_count < 2:
				return null
			evolve = true
		# red eye skeleton 4 kills -> red skeleton
		GameActors.IDs.UNDEAD_RED_EYED_SKELETON:
			if undead.kills_count < 4:
				return null
			evolve = true
		# zombie -> dark eyed zombie
		GameActors.IDs.UNDEAD_ZOMBIE:
			evolve = true
		# dark eyed zombie -> dark zombie
		GameActors.IDs.UNDEAD_DARK_EYED_ZOMBIE:
			evolve = true
		# zombified 2 kills -> neophyte
		GameActors.IDs.UNDEAD_MALE_ZOMBIFIED, GameActors.IDs.UNDEAD_FEMALE_ZOMBIFIED:
			if undead.kills_count < 2:
				return null
			evolve = true
		# neophyte 4 kills & Day > X -> disciple
		GameActors.IDs.UNDEAD_MALE_NEOPHYTE, GameActors.IDs.UNDEAD_FEMALE_NEOPHYTE:
			if undead.kills_count < 4:
				return null
			if undead.location.map.local_time.day < DISCIPLE_EVOLUTION_MIN_DAY and not undead.is_player:
				return null
			evolve = true
		_:
			evolve = false

	# evolve vs no evolution.
	if evolve:
		var evolution_id: int = next_undead_evolution(undead.model.id)
		if evolution_id == undead.model.id:
			return null
		else:
			return game_actors.get_model(evolution_id)
	else:
		return null


func next_undead_evolution(from_model_id: int) -> int:
	match from_model_id:
		GameActors.IDs.UNDEAD_SKELETON:
			return GameActors.IDs.UNDEAD_RED_EYED_SKELETON
		GameActors.IDs.UNDEAD_RED_EYED_SKELETON:
			return GameActors.IDs.UNDEAD_RED_SKELETON
		GameActors.IDs.UNDEAD_ZOMBIE:
			return GameActors.IDs.UNDEAD_DARK_EYED_ZOMBIE
		GameActors.IDs.UNDEAD_DARK_EYED_ZOMBIE:
			return GameActors.IDs.UNDEAD_DARK_ZOMBIE
		GameActors.IDs.UNDEAD_FEMALE_ZOMBIFIED:
			return GameActors.IDs.UNDEAD_FEMALE_NEOPHYTE
		GameActors.IDs.UNDEAD_MALE_ZOMBIFIED:
			return GameActors.IDs.UNDEAD_MALE_NEOPHYTE
		GameActors.IDs.UNDEAD_FEMALE_NEOPHYTE:
			return GameActors.IDs.UNDEAD_FEMALE_DISCIPLE
		GameActors.IDs.UNDEAD_MALE_NEOPHYTE:
			return GameActors.IDs.UNDEAD_MALE_DISCIPLE
		GameActors.IDs.UNDEAD_ZOMBIE_MASTER:
			return GameActors.IDs.UNDEAD_ZOMBIE_LORD
		GameActors.IDs.UNDEAD_ZOMBIE_LORD:
			return GameActors.IDs.UNDEAD_ZOMBIE_PRINCE
		_:
			return from_model_id


#region Blood & Remains
func splatter_blood(map: Map, position: Vector2i) -> void:
	# splatter floor there.
	var tile := map.get_tile_at(position.x, position.y)
	if map.is_walkable(position.x, position.y) and not tile.has_decoration(GameImages.DECO_BLOODIED_FLOOR):
		tile.add_decoration(GameImages.DECO_BLOODIED_FLOOR)
		map.add_timer(TaskRemoveDecoration.new(WorldTime.TURNS_PER_DAY, position.x, position.y, GameImages.DECO_BLOODIED_FLOOR))

	# splatter adjacent walls.
	for d in Direction.COMPASS:
		if not rules.roll_chance(BLOOD_WALL_SPLAT_CHANCE):
			continue
		var next: Vector2i = position + d.vector
		if not map.is_in_bounds_p(next):
			continue
		var tile_next := map.get_tile_at(next.x, next.y)
		if tile_next.model.is_walkable:
			continue
		if tile_next.has_decoration(GameImages.DECO_BLOODIED_WALL):
			continue
		tile_next.add_decoration(GameImages.DECO_BLOODIED_WALL)
		map.add_timer(TaskRemoveDecoration.new(WorldTime.TURNS_PER_DAY, next.x, next.y, GameImages.DECO_BLOODIED_WALL))


func undead_remains(map: Map, position: Vector2i) -> void:
	# add deco there.
	var tile := map.get_tile_at(position.x, position.y)
	if map.is_walkable(position.x, position.y) and not tile.has_decoration(GameImages.DECO_ZOMBIE_REMAINS):
		tile.add_decoration(GameImages.DECO_ZOMBIE_REMAINS)


#region Corpses
func drop_corpse(dead_guy: Actor) -> void:
	# add blood to deadguy.
	dead_guy.doll.add_decoration(Doll.DollPart.TORSO, GameImages.BLOODIED)

	# make and add corpse.
	var corpse_hp := rules.actor_max_hps(dead_guy)
	var rotation := float(rules.roll(30, 60))
	if rules.roll_chance(50):
		rotation = -rotation
	var scale := 1.0
	var corpse := Corpse.new(dead_guy, corpse_hp, corpse_hp, dead_guy.location.map.local_time.turn_counter, rotation, scale)
	dead_guy.location.map.add_corpse_at(corpse, dead_guy.location.position)


#region Player death & Post mortem
func player_died(killer: Actor, reason: String) -> void:
	# stop sim thread.
	stop_sim_thread(true)   # alpha10 abort allowed when dying

	# mouse.
	ui.ui_set_cursor(null)

	# music.
	music_manager.stop()
	music_manager.play(GameMusics.PLAYER_DEATH, MusicPriority.PRIORITY_EVENT)

	#--///////
	# Scoring
	#--///////
	session.scoring.turns_survived = session.world_time.turn_counter
	session.scoring.set_killer(killer)
	if player.count_followers > 0:
		for fo in player.followers:
			session.scoring.add_follower_when_died(fo)

	var zone := player.location.map.get_zones_at(player.location.position.x, player.location.position.y)
	if zone == null or zone.is_empty():
		session.scoring.death_place = player.location.map.name
	else:
		var zone_name: String = zone[0].name
		session.scoring.death_place = "%s at %s" % [player.location.map.name, zone_name]
	if killer != null:
		session.scoring.death_reason = "%s by %s %s" % ["Murdered" if rules.is_murder(killer, player) else "Killed", killer.model.name, killer.the_name]
	else:
		session.scoring.death_reason = "Death by %s" % reason
	session.scoring.add_event(session.world_time.turn_counter, "Died.")

	#--/////////////////////////////////////
	# Tip, Message, screenshot & permadeath.
	#--/////////////////////////////////////
	var i_tip := rules.roll(0, GameTips.TIPS.size())
	# TODO: OverlayPopup inner class (RogueGame.cs lines 452-644) not ported yet
	add_overlay(OverlayPopup.new(PackedStringArray(["TIP OF THE DEAD", "Did you know that...", GameTips.TIPS[i_tip]]), Color.WHITE, Color.WHITE, POPUP_FILLCOLOR, Vector2i(0, 0)))

	clear_messages()
	add_message(Message.new("**** YOU DIED! ****", session.world_time.turn_counter, Color.RED))
	if killer != null:
		add_message(Message.new("Killer : %s." % killer.the_name, session.world_time.turn_counter, Color.RED))
	add_message(Message.new("Reason : %s." % reason, session.world_time.turn_counter, Color.RED))
	if player.model.abilities.is_undead:
		add_message(Message.new("You die one last time... Game over!", session.world_time.turn_counter, Color.RED))
	else:
		add_message(Message.new("You join the realm of the undeads... Game over!", session.world_time.turn_counter, Color.RED))

	# if permadeath on delete save file.
	if options.is_permadeath_on:
		delete_saved_game(get_user_save())

	# screenshot.
	if options.is_death_screenshot_on:
		redraw_play_screen()
		var shotname := do_take_screenshot()
		if shotname == null:
			add_message(make_error_message("could not save death screenshot."))
		else:
			add_message(Message.new("Death screenshot saved : %s." % shotname, session.world_time.turn_counter, Color.RED))

	add_message_press_enter()

	# post mortem.
	handle_post_mortem()

	# music.
	music_manager.stop()

	# #if DEBUG BotReleaseControl(); -- skipped (release build)


func time_span_to_string(rt_seconds: int) -> String:
	# alpha10 shortened; C# took a TimeSpan, the port stores seconds (int).
	var rt := rt_seconds
	var time_days := "" if rt / 86400 == 0 else "%d d " % (rt / 86400)
	rt -= (rt / 86400) * 86400
	var time_hours := "" if rt / 3600 == 0 else "%02d h " % (rt / 3600)
	rt -= (rt / 3600) * 3600
	var time_minutes := "" if rt / 60 == 0 else "%02d m " % (rt / 60)
	rt -= (rt / 60) * 60
	var time_seconds := "" if rt == 0 else "%02d s" % rt
	return "%s%s%s%s" % [time_days, time_hours, time_minutes, time_seconds]


func handle_post_mortem() -> void:
	#--////////////
	# Prepare data.
	#--////////////
	var death_time := WorldTime.new()
	death_time.turn_counter = session.scoring.turns_survived
	var is_male := player.model.doll_body.is_male
	var _he_or_she := "He" if is_male else "She"
	var _his_or_her := his_or_her(player)
	var _him_or_her := "him" if is_male else "her"
	var pname := player.the_name.replace("(YOU) ", "")
	var real_time_string := time_span_to_string(session.scoring.real_life_playing_time)
	session.scoring.side = Scoring.DifficultySide.FOR_UNDEAD if player.model.abilities.is_undead else Scoring.DifficultySide.FOR_SURVIVOR
	session.scoring.difficulty_rating = Scoring.compute_difficulty_rating(options, session.scoring.side, session.scoring.reincarnation_number)

	#--////////////////////////////////
	# Format scoring into a text file.
	#--///////////////////////////////
	var graveyard := TextFile.new()

	# TODO: SetupConfig.GAME_VERSION -> literal port value "alpha 10.1"
	graveyard.append("ROGUE SURVIVOR alpha 10.1")
	graveyard.append("POST MORTEM")

	#region Summary
	graveyard.append("%s was %s and %s." % [pname, a_or_an(player.model.name), a_or_an(player.faction.member_name)])
	graveyard.append("%s survived to see %s." % [_he_or_she, str(death_time)])
	graveyard.append("%s's spirit guided %s for %s." % [pname, _him_or_her, real_time_string])
	if session.scoring.reincarnation_number > 0:
		graveyard.append("%s was reincarnation %d." % [_he_or_she, session.scoring.reincarnation_number])
	graveyard.append(" ")

	graveyard.append("> SCORING")
	graveyard.append("%s scored a total of %d points." % [_he_or_she, session.scoring.total_points])
	graveyard.append("- difficulty rating of %d%%." % int(100 * session.scoring.difficulty_rating))
	graveyard.append("- %d base points for survival." % session.scoring.survival_points)
	graveyard.append("- %d base points for kills." % session.scoring.kill_points)
	graveyard.append("- %d base points for achievements." % session.scoring.achievement_points)
	graveyard.append(" ")

	graveyard.append("> ACHIEVEMENTS")
	for ach in session.scoring.achievements:
		if ach == null:
			continue
		if ach.is_done:
			graveyard.append("- %s for %d points!" % [ach.name, ach.score_value])
		else:
			graveyard.append("- Fail : %s." % ach.tease_name)
	if session.scoring.completed_achievements_count == 0:
		graveyard.append("Didn't achieve anything notable. And then died.")
		graveyard.append("(unlock all the %d achievements to win this game version)" % Scoring.Achievement.IDs._COUNT)
	else:
		graveyard.append("Total : %d/%d." % [session.scoring.completed_achievements_count, Scoring.Achievement.IDs._COUNT])
		if session.scoring.completed_achievements_count >= Scoring.Achievement.IDs._COUNT:
			graveyard.append("*** You achieved everything! You can consider having won this version of the game! CONGRATULATIONS! ***")
		else:
			graveyard.append("(unlock all the achievements to win this game version)")
		graveyard.append("(later versions of the game will feature real winning conditions and multiple endings...)")
	graveyard.append(" ")

	graveyard.append("> DEATH")
	graveyard.append("%s in %s." % [session.scoring.death_reason, session.scoring.death_place])
	graveyard.append(" ")

	graveyard.append("> KILLS")
	if session.scoring.has_no_kills:
		graveyard.append("%s was a pacifist. Or too scared to fight." % _he_or_she)
	else:
		# models kill list.
		for kill_data in session.scoring.kills:
			var model_name: String = game_actors.get_model(kill_data.actor_model_id).plural_name if kill_data.amount > 1 else game_actors.get_model(kill_data.actor_model_id).name
			graveyard.append("%4d %s." % [kill_data.amount, model_name])
	# murders? only livings.
	if not player.model.abilities.is_undead:
		if player.murders_counter > 0:
			graveyard.append("%s committed %d murder%s!" % [_he_or_she, player.murders_counter, "s" if player.murders_counter > 1 else ""])

	graveyard.append(" ")

	graveyard.append("> FUN FACTS!")
	graveyard.append("While %s has died, others are still having fun!" % pname)
	var fun_facts := compile_district_fun_facts(player.location.map.district)
	for i in fun_facts.size():
		graveyard.append(fun_facts[i])
	graveyard.append("")

	graveyard.append("> SKILLS")
	if player.sheet.skill_table.skills() == null:
		graveyard.append("%s was a jack of all trades. Or an incompetent." % _he_or_she)
	else:
		for sk in player.sheet.skill_table.skills():
			graveyard.append("%d-%s." % [sk.level, Skills.name(sk.id)])
	graveyard.append(" ")

	graveyard.append("> INVENTORY")
	if player.inventory.is_empty:
		graveyard.append("%s was humble. Or dirt poor." % _he_or_she)
	else:
		for it in player.inventory.items:
			var desc := describe_item_short(it)
			if it.is_equipped:
				graveyard.append("- %s (equipped)." % desc)
			else:
				graveyard.append("- %s." % desc)
	graveyard.append(" ")

	graveyard.append("> FOLLOWERS")
	if session.scoring.followers_when_died == null or session.scoring.followers_when_died.size() == 0:
		graveyard.append("%s was doing fine alone. Or everyone else was dead." % _he_or_she)
	else:
		# names.
		var sb := "%s was leading" % _he_or_she
		var first_fo := true
		var i := 0
		var count: int = session.scoring.followers_when_died.size()
		for fo in session.scoring.followers_when_died:
			if first_fo:
				sb += " "
			else:
				if i == count:
					sb += "."
				elif i == count - 1:
					sb += " and "
				else:
					sb += ", "
			sb += fo.the_name
			i += 1
			first_fo = false
		sb += "."
		graveyard.append(sb)

		# skills.
		for fo in session.scoring.followers_when_died:
			graveyard.append("%s skills : " % fo.name)
			if fo.sheet.skill_table != null and fo.sheet.skill_table.skills() != null:
				for sk in fo.sheet.skill_table.skills():
					graveyard.append("%d-%s." % [sk.level, Skills.name(sk.id)])
	graveyard.append(" ")

	graveyard.append("> EVENTS")
	if session.scoring.has_no_events:
		graveyard.append("%s had a quiet life. Or dull and boring." % _he_or_she)
	else:
		for ev in session.scoring.events:
			var ev_time := WorldTime.new()
			ev_time.turn_counter = ev.turn
			graveyard.append("- %13s : %s" % [str(ev_time), ev.text])
	graveyard.append(" ")

	graveyard.append("> CUSTOM OPTIONS")
	graveyard.append("- difficulty rating of %d%%." % int(100 * session.scoring.difficulty_rating))
	if options.is_permadeath_on:
		graveyard.append("- %s : yes." % GameOptions.name_of(GameOptions.IDs.GAME_PERMADEATH))
	if not options.allow_undeads_evolution and Rules.has_evolution(session.game_mode): # alpha10 only if manually disabled
		graveyard.append("- %s : %s." % [GameOptions.name_of(GameOptions.IDs.GAME_ALLOW_UNDEADS_EVOLUTION), "yes" if options.allow_undeads_evolution else "no"])
	if options.city_size != GameOptions.DEFAULT_CITY_SIZE:
		graveyard.append("- %s : %d." % [GameOptions.name_of(GameOptions.IDs.GAME_CITY_SIZE), options.city_size])
	if options.day_zero_undeads_percent != GameOptions.DEFAULT_DAY_ZERO_UNDEADS_PERCENT:
		graveyard.append("- %s : %d%%." % [GameOptions.name_of(GameOptions.IDs.GAME_DAY_ZERO_UNDEADS_PERCENT), options.day_zero_undeads_percent])
	if options.district_size != GameOptions.DEFAULT_DISTRICT_SIZE:
		graveyard.append("- %s : %d." % [GameOptions.name_of(GameOptions.IDs.GAME_DISTRICT_SIZE), options.district_size])
	if options.max_civilians != GameOptions.DEFAULT_MAX_CIVILIANS:
		graveyard.append("- %s : %d." % [GameOptions.name_of(GameOptions.IDs.GAME_MAX_CIVILIANS), options.max_civilians])
	if options.max_undeads != GameOptions.DEFAULT_MAX_UNDEADS:
		graveyard.append("- %s : %d." % [GameOptions.name_of(GameOptions.IDs.GAME_MAX_UNDEADS), options.max_undeads])
	if not options.npc_can_starve_to_death:
		graveyard.append("- %s : %s." % [GameOptions.name_of(GameOptions.IDs.GAME_NPC_CAN_STARVE_TO_DEATH), "yes" if options.npc_can_starve_to_death else "no"])
	if options.starved_zombification_chance != GameOptions.DEFAULT_STARVED_ZOMBIFICATION_CHANCE:
		graveyard.append("- %s : %d%%." % [GameOptions.name_of(GameOptions.IDs.GAME_STARVED_ZOMBIFICATION_CHANCE), options.starved_zombification_chance])
	if not options.reveal_starting_district:
		graveyard.append("- %s : %s." % [GameOptions.name_of(GameOptions.IDs.GAME_REVEAL_STARTING_DISTRICT), "yes" if options.reveal_starting_district else "no"])
	if options.simulate_districts != GameOptions.DEFAULT_SIM_DISTRICTS:
		graveyard.append("- %s : %s." % [GameOptions.name_of(GameOptions.IDs.GAME_SIMULATE_DISTRICTS), GameOptions.name_of(options.simulate_districts)])
	if options.simulate_when_sleeping:
		graveyard.append("- %s : %s." % [GameOptions.name_of(GameOptions.IDs.GAME_SIMULATE_SLEEP), "yes" if options.simulate_when_sleeping else "no"])
	if options.zombie_invasion_daily_increase != GameOptions.DEFAULT_ZOMBIE_INVASION_DAILY_INCREASE:
		graveyard.append("- %s : %d%%." % [GameOptions.name_of(GameOptions.IDs.GAME_ZOMBIE_INVASION_DAILY_INCREASE), options.zombie_invasion_daily_increase])
	if options.zombification_chance != GameOptions.DEFAULT_ZOMBIFICATION_CHANCE:
		graveyard.append("- %s : %d%%." % [GameOptions.name_of(GameOptions.IDs.GAME_ZOMBIFICATION_CHANCE), options.zombification_chance])
	if options.max_reincarnations != GameOptions.DEFAULT_MAX_REINCARNATIONS:
		graveyard.append("- %s : %d." % [GameOptions.name_of(GameOptions.IDs.GAME_MAX_REINCARNATIONS), options.max_reincarnations])
	graveyard.append(" ")

	graveyard.append("> R.I.P")
	graveyard.append("May %s soul rest in peace." % his_or_her(player))
	graveyard.append("For %s body is now a meal for evil." % his_or_her(player))
	graveyard.append("The End.")

	#--/////////////////
	# Save to graveyard
	#--/////////////////
	var gx := 0
	var gy := 0
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.YELLOW, "Saving post mortem to graveyard...", 0, 0)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()
	var grave_name := get_user_new_graveyard_name()
	var grave_file := grave_file_path(grave_name)
	if not graveyard.save_file(grave_file):
		ui.ui_draw_string_bold(Color.RED, "Could not save to graveyard.", 0, gy)
		gy += BOLD_LINE_SPACING
	else:
		ui.ui_draw_string_bold(Color.YELLOW, "Grave saved to :", 0, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string(Color.WHITE, grave_file, 0, gy)
		gy += BOLD_LINE_SPACING
	draw_footnote(Color.WHITE, "press ENTER")
	ui.ui_repaint()
	wait_enter()

	#--/////////////////////////////
	# Display grave as text file.
	#--/////////////////////////////
	graveyard.format_lines(TEXTFILE_CHARS_PER_LINE)
	var i_line := 0
	var loop := false
	while true: # C# do...while(loop)
		# header.
		ui.ui_clear(Color.BLACK)
		gx = 0
		gy = 0
		draw_header()
		gy += BOLD_LINE_SPACING

		# text.
		var lines_this_page := 0
		ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, gy)
		gy += BOLD_LINE_SPACING
		while lines_this_page < TEXTFILE_LINES_PER_PAGE and i_line < graveyard.formated_lines.size():
			var line: String = graveyard.formated_lines[i_line]
			ui.ui_draw_string_bold(Color.WHITE, line, gx, gy)
			gy += BOLD_LINE_SPACING
			i_line += 1
			lines_this_page += 1

		# foot.
		ui.ui_draw_string_bold(Color.WHITE, "---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+", 0, CANVAS_HEIGHT - 2 * BOLD_LINE_SPACING)
		if i_line < graveyard.formated_lines.size():
			draw_footnote(Color.WHITE, "press ENTER for more")
		else:
			draw_footnote(Color.WHITE, "press ENTER to leave")

		# wait.
		ui.ui_repaint()
		wait_enter()

		# loop?
		loop = i_line < graveyard.formated_lines.size()
		if not loop:
			break

	#--/////////
	# Hi Score?
	#--/////////
	var skills_sb := ""
	if player.sheet.skill_table.skills() != null:
		for sk in player.sheet.skill_table.skills():
			skills_sb += "%d-%s " % [sk.level, Skills.name(sk.id)]
	var new_hi_score: HiScoreTable.HiScore = HiScoreTable.HiScore.from_scoring(pname, session.scoring, skills_sb)
	if hi_score_table.register(new_hi_score):
		save_hi_score_table()
		handle_hi_scores(true)


#region New day/night, Scoring, Advancement
func on_new_night() -> void:
	update_player_fov(player)

	#----- Upgrade Player (undead only once every 2 nights)
	if player.model.abilities.is_undead and player.location.map.local_time.day % 2 == 1:
		# Mode.
		clear_overlays()
		# TODO: OverlayPopup inner class not ported yet
		add_overlay(OverlayPopup.new(UPGRADE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

		# music.
		music_manager.stop()
		music_manager.play(GameMusics.INTERLUDE, MusicPriority.PRIORITY_EVENT)

		# Message.
		clear_messages()
		add_message(Message.new("You will hunt another day!", session.world_time.turn_counter, Color.GREEN))
		update_player_fov(player)
		if not player.is_bot_player:
			add_message_press_enter()

		# Upgrade time!
		# alpha10.1 handle bot skill upgrade, bot followers will upgrade as npcs
		if player.is_bot_player:
			handle_npc_skill_upgrade(player)
		else:
			handle_player_decide_upgrade(player)
			handle_player_followers_upgrade()

		# Resume play.
		clear_messages()
		add_message(Message.new("Welcome to the night.", session.world_time.turn_counter, Color.WHITE))
		clear_overlays()
		redraw_play_screen()

		# music
		music_manager.stop()


func on_new_day() -> void:
	#--/////////////////////
	# Normal day processing
	#--/////////////////////

	#----- Upgrade Player (living only)
	if not player.model.abilities.is_undead:
		# Mode.
		clear_overlays()
		# TODO: OverlayPopup inner class not ported yet
		add_overlay(OverlayPopup.new(UPGRADE_MODE_TEXT, MODE_TEXTCOLOR, MODE_BORDERCOLOR, MODE_FILLCOLOR, Vector2i(0, 0)))

		# music.
		music_manager.stop()
		music_manager.play(GameMusics.INTERLUDE, MusicPriority.PRIORITY_EVENT)

		# Message.
		clear_messages()
		add_message(Message.new("You survived another night!", session.world_time.turn_counter, Color.GREEN))
		update_player_fov(player)
		if not player.is_bot_player:
			add_message_press_enter()

		# Upgrade time!
		# alpha10.1 handle bot skill upgrade, bot followers will upgrade as npcs
		if player.is_bot_player:
			handle_npc_skill_upgrade(player)
		else:
			handle_player_decide_upgrade(player)
			handle_player_followers_upgrade()

		# Resume play.
		clear_messages()
		add_message(Message.new("Welcome to tomorrow.", session.world_time.turn_counter, Color.WHITE))
		clear_overlays()
		redraw_play_screen()

		# music
		music_manager.stop()

	# alpha10 obsolete
	#-- Check weather change.
	#check_weather_change();

	#--//////////////////////////
	# New day achievements.
	# 1. Reached day X (living only)
	#--//////////////////////////
	if not player.model.abilities.is_undead:
		if session.world_time.day == 7:
			# scoring.
			session.scoring.set_completed_achievement(Scoring.Achievement.IDs.REACHED_DAY_07)

			# achievement!
			show_new_achievement(Scoring.Achievement.IDs.REACHED_DAY_07)
		elif session.world_time.day == 14:
			# scoring.
			session.scoring.set_completed_achievement(Scoring.Achievement.IDs.REACHED_DAY_14)

			# achievement!
			show_new_achievement(Scoring.Achievement.IDs.REACHED_DAY_14)
		elif session.world_time.day == 21:
			# scoring.
			session.scoring.set_completed_achievement(Scoring.Achievement.IDs.REACHED_DAY_21)

			# achievement!
			show_new_achievement(Scoring.Achievement.IDs.REACHED_DAY_21)
		elif session.world_time.day == 28:
			# scoring.
			session.scoring.set_completed_achievement(Scoring.Achievement.IDs.REACHED_DAY_28)

			# achievement!
			show_new_achievement(Scoring.Achievement.IDs.REACHED_DAY_28)


func handle_player_decide_upgrade(upgrade_actor: Actor) -> void:
	# roll N skills to updgrade.
	var upgrade_choices: Array = roll_skills_to_upgrade(upgrade_actor, 3 * 100)

	# "you" vs follower name.
	var you_name := "You" if upgrade_actor == player else upgrade_actor.name

	# loop.
	var loop := true
	while loop: # C# do...while(loop)
		var popup = null

		# 1. Redraw
		# 2. Read input
		# 3. Handle input

		# 1. Redraw
		clear_messages()
		add_message(Message.new(you_name + " can improve or learn one of these skills. Choose wisely.", session.world_time.turn_counter, Color.GREEN))

		if upgrade_choices.size() == 0:
			add_message(make_error_message(you_name + " can't learn anything new!"))
		else:
			var popup_lines: Array[String] = []
			popup_lines.append(" ")

			for i_choice in upgrade_choices.size():
				var sk: int = upgrade_choices[i_choice]
				var level := upgrade_actor.sheet.skill_table.get_skill_level(sk)
				var text := "%d. %s %d/%d" % [i_choice + 1, Skills.name(sk), level + 1, Skills.max_skill_level(sk)]
				add_message(Message.new(text, session.world_time.turn_counter, Color.LIGHT_GREEN))

				popup_lines.append(text)
				popup_lines.append("    " + describe_skill_short(sk))
				popup_lines.append(" ")

			popup_lines.append("ESC. don't upgrade")

			if upgrade_actor != player:
				popup_lines.append(" ")
				popup_lines.append(upgrade_actor.name + " current skills")
				for sk in upgrade_actor.sheet.skill_table.skills():
					popup_lines.append("%s %d" % [Skills.name(sk.id), sk.level])
				# TODO: OverlayPopupTitle inner class not ported yet
				popup = OverlayPopupTitle.new("Select skill to upgrade" if upgrade_actor == player else "Select skill to upgrade for " + upgrade_actor.name, Color.WHITE, PackedStringArray(popup_lines), Color.WHITE, Color.WHITE, Color.BLACK, Vector2i(64, 64))
				add_overlay(popup)
		add_message(Message.new("ESC if you don't want to upgrade.", session.world_time.turn_counter, Color.WHITE))
		redraw_play_screen()

		# 2. Read input
		var in_key := ui.ui_wait_key()

		# 3. Handle input
		var _command := InputTranslator.key_to_command(in_key) # == PlayerCommand.EXIT_OR_CANCEL when ESC
		if in_key.keycode == KEY_ESCAPE:
			loop = false
			if popup != null:
				remove_overlay(popup)
			redraw_play_screen()
		else:
			# get choice.
			var choice := key_to_choice_number(in_key.keycode)

			if choice >= 1 and choice <= upgrade_choices.size():
				# upgrade skill.
				var sk_id: int = upgrade_choices[choice - 1]
				var sk: SkillTable.Skill = skill_upgrade(upgrade_actor, sk_id)

				# message & scoring.
				if sk.level == 1:
					add_message(Message.new("%s learned skill %s." % [upgrade_actor.name, Skills.name(sk.id)], session.world_time.turn_counter, Color.LIGHT_GREEN))
					session.scoring.add_event(session.world_time.turn_counter, "%s learned skill %s." % [upgrade_actor.name, Skills.name(sk.id)])
				else:
					add_message(Message.new("%s improved skill %s to level %d." % [upgrade_actor.name, Skills.name(sk.id), sk.level], session.world_time.turn_counter, Color.LIGHT_GREEN))
					session.scoring.add_event(session.world_time.turn_counter, "%s improved skill %s to level %d." % [upgrade_actor.name, Skills.name(sk.id), sk.level])
				add_message_press_enter()
				if popup != null:
					remove_overlay(popup)
				redraw_play_screen()
				loop = false


func handle_player_followers_upgrade() -> void:
	# if no followers, nothing to do.
	if player.count_followers == 0:
		return

	# Message.
	clear_messages()
	add_message(Message.new("Your followers learned new skills at your side!", session.world_time.turn_counter, Color.GREEN))
	add_message_press_enter()

	# Do it.
	for follower in player.followers:
		# player pick for the follower.
		handle_player_decide_upgrade(follower)


func handle_living_npcs_upgrade(map: Map) -> void:
	for a in map.actors_list:
		# ignore player, we do it separatly.
		if a == player:
			continue
		# ignore player followers (upgraded already)
		if a.leader == player:
			continue
		# not undeads!
		if a.model.abilities.is_undead:
			continue

		# do it!
		handle_npc_skill_upgrade(a)  # alpha10.1


# alpha10.1 factorized to handle bot skill upgrade
func handle_npc_skill_upgrade(a: Actor) -> void:
	var upgrade_from: Array = roll_skills_to_upgrade(a, 3 * 100)
	var chosen_skill = npc_pick_skill_to_upgrade(a, upgrade_from)
	if chosen_skill == null:
		return
	# upgrade it!
	skill_upgrade(a, chosen_skill)


func handle_undead_npcs_upgrade(map: Map) -> void:
	for a in map.actors_list:
		# ignore player, we do it separatly.
		if a == player:
			continue
		# ignore player followers (upgraded already)
		if a.leader == player:
			continue
		# undeads only, and some branches only.
		if not a.model.abilities.is_undead:
			continue
		if not options.skeletons_upgrade and game_actors.is_skeleton_branch(a.model):
			continue
		if not options.rats_upgrade and game_actors.is_rat_branch(a.model):
			continue
		if not options.shamblers_upgrade and game_actors.is_shambler_branch(a.model):
			continue

		# do it!
		var upgrade_from: Array = roll_skills_to_upgrade(a, 3 * 100)
		var chosen_skill = npc_pick_skill_to_upgrade(a, upgrade_from)
		if chosen_skill == null:
			continue
		# upgrade it!
		skill_upgrade(a, chosen_skill)


func roll_skills_to_upgrade(actor: Actor, max_tries: int) -> Array:
	var count := Rules.UNDEAD_UPGRADE_SKILLS_TO_CHOOSE_FROM if actor.model.abilities.is_undead else Rules.UPGRADE_SKILLS_TO_CHOOSE_FROM
	var list: Array = []

	for i in count:
		var new_sk = null
		var attempt := 0
		while true: # C# do...while
			attempt += 1
			new_sk = roll_random_skill_to_upgrade(actor, max_tries)
			if new_sk == null:
				return list
			if not (list.has(new_sk) and attempt < max_tries):
				break

		list.append(new_sk)

	return list


# Returns null or a Skills.IDs value.
func npc_pick_skill_to_upgrade(npc: Actor, choose_from: Array):
	if choose_from == null or choose_from.size() == 0:
		return null

	# Compute skill utilities and get best utility.
	var n := choose_from.size()
	var utilities: Array[int] = []
	utilities.resize(n)
	var best_utility := -1
	for i in n:
		utilities[i] = npc_skill_utility(npc, choose_from[i])
		if utilities[i] > best_utility:
			best_utility = utilities[i]

	# Randomly choose on of the best.
	var best_skills: Array = []
	for i in n:
		if utilities[i] == best_utility:
			best_skills.append(choose_from[i])
	return best_skills[rules.roll(0, best_skills.size())]


func npc_skill_utility(actor: Actor, sk_id: int) -> int:
	const USELESS_UTIL := 0
	const LOW_UTIL := 1
	const AVG_UTIL := 2
	const HI_UTIL := 3

	if actor.model.abilities.is_undead:
		# undeads.
		match sk_id:
			# useful one.
			Skills.IDs.Z_GRAB, Skills.IDs.Z_INFECTOR, Skills.IDs.Z_LIGHT_EATER:
				return HI_UTIL
			# ok ones.
			Skills.IDs.Z_AGILE, Skills.IDs.Z_STRONG, Skills.IDs.Z_TOUGH, Skills.IDs.Z_TRACKER:
				return AVG_UTIL
			# meh ones.
			Skills.IDs.Z_EATER, Skills.IDs.Z_LIGHT_FEET:
				return LOW_UTIL
			_:
				return USELESS_UTIL
	else:
		match sk_id:
			Skills.IDs.AGILE:
				return AVG_UTIL
			Skills.IDs.AWAKE:
				# useful only if has to sleep.
				return HI_UTIL if actor.model.abilities.has_to_sleep else USELESS_UTIL
			Skills.IDs.BOWS:
				# useful only if has bow weapon.
				if actor.inventory != null:
					for it in actor.inventory.items:
						if it is ItemRangedWeapon:
							if (it.model as ItemRangedWeaponModel).is_bow():
								return HI_UTIL
					return USELESS_UTIL
			Skills.IDs.CARPENTRY:
				return LOW_UTIL
			Skills.IDs.CHARISMATIC:
				# useful only if leader.
				return LOW_UTIL if actor.count_followers > 0 else USELESS_UTIL
			Skills.IDs.FIREARMS:
				# useful only if has firearm weapon.
				if actor.inventory != null:
					for it in actor.inventory.items:
						if it is ItemRangedWeapon:
							if (it.model as ItemRangedWeaponModel).is_firearm():
								return HI_UTIL
					return USELESS_UTIL
			Skills.IDs.HARDY:
				# useful only if has to sleep.
				return HI_UTIL if actor.model.abilities.has_to_sleep else USELESS_UTIL
			Skills.IDs.HAULER:
				return HI_UTIL
			Skills.IDs.HIGH_STAMINA:
				return HI_UTIL  # alpha10; was previously rated as avg
			Skills.IDs.LEADERSHIP:
				# useful only if not follower.
				return USELESS_UTIL if actor.has_leader else LOW_UTIL
			Skills.IDs.LIGHT_EATER:
				# useful only if has to eat.
				return HI_UTIL if actor.model.abilities.has_to_eat else USELESS_UTIL
			Skills.IDs.LIGHT_FEET:
				return AVG_UTIL
			Skills.IDs.LIGHT_SLEEPER:
				# useful only if has to sleep.
				return AVG_UTIL if actor.model.abilities.has_to_sleep else USELESS_UTIL
			Skills.IDs.MARTIAL_ARTS:
				# useless if any weapon in inventory.
				if actor.inventory != null:
					for it in actor.inventory.items:
						if it is ItemWeapon:
							return LOW_UTIL
				return AVG_UTIL
			Skills.IDs.MEDIC:
				return LOW_UTIL
			Skills.IDs.NECROLOGY:
				return LOW_UTIL # alpha10 ; was previously rated as useless
			Skills.IDs.STRONG:
				return AVG_UTIL
			Skills.IDs.STRONG_PSYCHE:
				# useful only if has sanity.
				return HI_UTIL if actor.model.abilities.has_sanity else USELESS_UTIL
			Skills.IDs.TOUGH:
				return HI_UTIL
			Skills.IDs.UNSUSPICIOUS:
				# useful only if murderer and not law enforcer.
				return LOW_UTIL if actor.murders_counter > 0 and not actor.model.abilities.is_law_enforcer else USELESS_UTIL
			_:
				return USELESS_UTIL
	return USELESS_UTIL


# Returns null or a Skills.IDs value.
func roll_random_skill_to_upgrade(actor: Actor, max_tries: int):
	var attempt := 0
	var sk_id := 0
	var is_undead := actor.model.abilities.is_undead

	while true: # C# do...while
		attempt += 1
		sk_id = Skills.roll_undead(rules.dice_roller) if is_undead else Skills.roll_living(rules.dice_roller)
		if not (actor.sheet.skill_table.get_skill_level(sk_id) >= Skills.max_skill_level(sk_id) and attempt < max_tries):
			break

	if attempt >= max_tries:
		return null
	else:
		return sk_id


func do_loose_random_skill(actor: Actor) -> void:
	var skills = actor.sheet.skill_table.skills_list()
	if skills == null:
		return

	# pick a skill.
	var i_skill := rules.roll(0, skills.size())
	var lost_skill: int = skills[i_skill]

	# regress.
	actor.sheet.skill_table.dec_or_remove_skill(lost_skill)

	# message.
	if is_visible_to_player(actor):
		add_message(make_message(actor, "regressed in %s!" % Skills.name(lost_skill)))


func skill_upgrade(actor: Actor, id: int) -> SkillTable.Skill:
	actor.sheet.skill_table.add_or_increase_skill(id)
	var sk: SkillTable.Skill = actor.sheet.skill_table.get_skill(id)
	on_skill_upgrade(actor, id)

	return sk


func on_skill_upgrade(actor: Actor, id: int) -> void:
	match id:
		Skills.IDs.HAULER:
			if actor.inventory != null:
				actor.inventory.max_capacity = rules.actor_max_inv(actor)
		_:
			# no special upkeep to do.
			pass


func change_weather() -> void:
	var can_see_weather := rules.can_actor_see_sky(player) # alpha10

	# roll & annouce new weather.
	var desc: String
	var new_weather: int
	match session.world.weather:
		Weather.CLEAR:
			new_weather = Weather.CLOUDY
			desc = "Clouds are covering the sun."
		Weather.CLOUDY:
			if rules.roll_chance(50):
				new_weather = Weather.CLEAR
				desc = "The sky is clear again."
			else:
				new_weather = Weather.RAIN
				desc = "Rain is starting to fall."
		Weather.RAIN:
			if rules.roll_chance(50):
				new_weather = Weather.CLOUDY
				desc = "The rain has stopped."
			else:
				new_weather = Weather.HEAVY_RAIN
				desc = "The weather is getting worse!"
		Weather.HEAVY_RAIN:
			new_weather = Weather.RAIN
			desc = "The rain is less heavy."
		_:
			push_error("unhandled weather")

	# change.
	session.world.weather = new_weather

	# message.
	if can_see_weather:
		add_message(Message.new(desc, session.world_time.turn_counter, Color.WHITE))

	# scoring.
	session.scoring.add_event(session.world_time.turn_counter, "The weather changed to %s." % describe_weather(session.world.weather))


# Add kill to scoring record.
func player_kill(victim: Actor) -> void:
	# scoring.
	session.scoring.add_kill(player, victim, session.world_time.turn_counter)


#region Infection & Zombification
func infect_actor(actor: Actor, add_infection: int) -> void:
	actor.infection = mini(rules.actor_infection_hps(actor), actor.infection + add_infection)


# Zombify an actor during the game or zombify the player at game start.
func zombify(zombifier: Actor, dead_victim: Actor, is_starting_game: bool) -> Actor:
	var new_zombie: Actor = town_generator.make_zombified(zombifier, dead_victim, 0 if is_starting_game else dead_victim.location.map.local_time.turn_counter)

	# add to map.
	if not is_starting_game:
		dead_victim.location.map.place_actor_at(new_zombie, dead_victim.location.position)

	# reset AP - dont act this turn.
	new_zombie.action_points = 0

	# if zombifying player, remember it!
	if dead_victim == player or dead_victim.is_player:
		session.scoring.set_zombified_player(new_zombie)

	# keep half of the skills from living form at random.
	var living_skills := dead_victim.sheet.skill_table
	if living_skills != null and living_skills.count_skills() > 0:
		if new_zombie.sheet.skill_table == null:
			new_zombie.sheet.skill_table = SkillTable.new()
		var nb_living_skills := living_skills.count_skills()
		var nb_skills_to_keep := living_skills.count_total_skill_levels() / 2
		for i in nb_skills_to_keep:
			var keep_skill: int = living_skills.skills_list()[rules.roll(0, nb_living_skills)]
			var zombified_skill = zombify_skill(keep_skill)
			if zombified_skill != null:
				skill_upgrade(new_zombie, zombified_skill)
		town_generator.recompute_actor_starting_stats(new_zombie)

	# cause insanity.
	if not is_starting_game:
		seeing_cause_insanity(new_zombie, new_zombie.location, Rules.SANITY_HIT_ZOMBIFY, "%s turning into a zombie" % dead_victim.name)

	# done.
	return new_zombie


# Returns null or a Skills.IDs value.
func zombify_skill(skill: int):
	match skill:
		Skills.IDs.AGILE:
			return Skills.IDs.Z_AGILE
		Skills.IDs.LIGHT_EATER:
			return Skills.IDs.Z_LIGHT_EATER
		Skills.IDs.LIGHT_FEET:
			return Skills.IDs.Z_LIGHT_FEET
		Skills.IDs.MEDIC:
			return Skills.IDs.Z_INFECTOR
		Skills.IDs.STRONG:
			return Skills.IDs.Z_STRONG
		Skills.IDs.TOUGH:
			return Skills.IDs.Z_TOUGH
		_:
			return null


#region Applying/Unapplying effects: ApplyXXX/UnapplyXXX

# Put the object on fire : firestate = onfire, jump -1.
func apply_on_fire(map_obj: MapObject) -> void:
	# put object on fire.
	map_obj.fire_state = MapObject.Fire.ONFIRE
	# can't jump on it.
	map_obj.jump_level -= 1


# Unapply fire effects. FIXME: need to distinguish Unapply (burnable again) vs PutOutFire (ashes)?
func unapply_on_fire(map_obj: MapObject) -> void:
	# restore jumpability.
	map_obj.jump_level += 1
	# extinguish fire, burnable again.
	map_obj.fire_state = MapObject.Fire.BURNABLE


#region View
func compute_view_rect(map_center: Vector2i) -> void:
	var left := map_center.x - HALF_VIEW_WIDTH
	var right := map_center.x + HALF_VIEW_WIDTH
	var top := map_center.y - HALF_VIEW_HEIGHT
	var bottom := map_center.y + HALF_VIEW_HEIGHT
	map_view_rect = Rect2i(left, top, 1 + right - left, 1 + bottom - top)
	# keep the UI camera on the view-rect origin so world-space map content
	# renders exactly where the view-local UI (panels, overlays) expects it
	ui.ui_set_camera_focus(Vector2(map_view_rect.position.x * TILE_SIZE, map_view_rect.position.y * TILE_SIZE))


func is_in_view_rect(map_position: Vector2i) -> bool:
	return map_view_rect.has_point(map_position)
#endregion


func redraw_play_screen() -> void:
	# alpha10 dont display some infos
	var _can_see_sky := rules.can_actor_see_sky(player)
	var can_know_time := rules.can_actor_know_time(player)

	# Monitor.Enter/Exit(m_UI) skipped: the Godot port runs single-threaded.

	ui.ui_clear(Color.BLACK)

	# map & minimap
	var map_tint := Color.WHITE  # disabled changing brightness, bad for the eyes: tint_for_day_phase(session.world_time.phase)
	ui.ui_draw_line(Color.DARK_GRAY, RIGHTPANEL_X, 0, RIGHTPANEL_X, MESSAGES_Y)
	draw_map(session.current_map, map_tint)

	ui.ui_draw_line(Color.DARK_GRAY, RIGHTPANEL_X, MINIMAP_Y - 4, CANVAS_WIDTH, MINIMAP_Y - 4)
	draw_mini_map(session.current_map)

	# messages
	ui.ui_draw_line(Color.DARK_GRAY, MESSAGES_X, MESSAGES_Y - 1, CANVAS_WIDTH, MESSAGES_Y - 1)
	draw_messages()

	# location info.
	#    x0            x1
	# y0 <map name>
	# y1 <zone name>
	# y2 <day>        <dayphase>
	# y3 <hour>       <weather>/<lighting>
	# y4 <turn>       <scoring>@<difficulty> <mode>
	# y5 <life>/<lives>
	# y6 <murders>
	var X0 := LOCATIONPANEL_TEXT_X
	var X1 := LOCATIONPANEL_TEXT_X + 128
	var Y0 := LOCATIONPANEL_TEXT_Y
	var Y1 := Y0 + LINE_SPACING
	var Y2 := Y1 + LINE_SPACING
	var Y3 := Y2 + LINE_SPACING
	var Y4 := Y3 + LINE_SPACING
	var Y5 := Y4 + LINE_SPACING
	var Y6 := Y5 + LINE_SPACING

	ui.ui_draw_line(Color.DARK_GRAY, LOCATIONPANEL_X, LOCATIONPANEL_Y, LOCATIONPANEL_X, CANVAS_HEIGHT)
	ui.ui_draw_string(Color.WHITE, session.current_map.name, X0, Y0)
	ui.ui_draw_string(Color.WHITE, location_text(session.current_map, player), X0, Y1)
	ui.ui_draw_string(Color.WHITE, "Day  %d" % session.world_time.day, X0, Y2)
	if can_know_time:
		ui.ui_draw_string(Color.WHITE, "Hour %d" % session.world_time.hour, X0, Y3)
	else:
		ui.ui_draw_string(Color.WHITE, "Hour ??", X0, Y3)

	# alpha10 desc day fov effect, not if cant know time
	var day_phase_string: String
	if can_know_time:
		day_phase_string = describe_day_phase(session.world_time.phase)
		var time_fov_penalty := rules.night_fov_penalty(player, session.world_time)
		if time_fov_penalty != 0:
			day_phase_string += "  fov -%d" % time_fov_penalty
	else:
		day_phase_string = "???"

	ui.ui_draw_string(NIGHT_COLOR if session.world_time.is_night else DAY_COLOR, day_phase_string, X1, Y2)

	var weather_or_lighting_color: Color
	var weather_or_lighting_string: String
	match session.current_map.lighting:
		Map.Lighting.OUTSIDE:
			weather_or_lighting_color = weather_color(session.world.weather)
			# alpha10 only show weather if can see it
			if rules.can_actor_see_sky(player):
				weather_or_lighting_string = describe_weather(session.world.weather)
				# alpha10 desc weather fov effect
				var fov_penalty := rules.weather_fov_penalty(player, session.world.weather)
				if fov_penalty != 0:
					weather_or_lighting_string += "  fov -%d" % fov_penalty
			else:
				weather_or_lighting_string = "???"
		Map.Lighting.DARKNESS:
			weather_or_lighting_color = Color.BLUE
			weather_or_lighting_string = "Darkness"
			# alpha10 desc darkness fov effect
			var darkness_fov := rules.darkness_fov(player)
			if darkness_fov != player.sheet.base_view_range:
				weather_or_lighting_string += "  fov %d" % darkness_fov
		Map.Lighting.LIT:
			weather_or_lighting_color = Color.YELLOW
			weather_or_lighting_string = "Lit"
		_:
			push_error("unhandled lighting")
	ui.ui_draw_string(weather_or_lighting_color, weather_or_lighting_string, X1, Y3)
	ui.ui_draw_string(Color.WHITE, "Turn %d" % session.world_time.turn_counter, X0, Y4)
	ui.ui_draw_string(Color.WHITE, "Score   %d@%d%% %s" % [session.scoring.total_points, int(100 * Scoring.compute_difficulty_rating(options, session.scoring.side, session.scoring.reincarnation_number)), Session.desc_short_game_mode(session.game_mode)], X1, Y4)
	ui.ui_draw_string(Color.WHITE, "Avatar  %d/%d" % [1 + session.scoring.reincarnation_number, 1 + options.max_reincarnations], X1, Y5)
	if player.murders_counter > 0:
		ui.ui_draw_string(Color.WHITE, "Murders %d" % player.murders_counter, X1, Y6)

	# character status.
	if player != null:
		draw_actor_status(player, RIGHTPANEL_TEXT_X, RIGHTPANEL_TEXT_Y)

	# inventories.
	if player != null:
		if player.inventory != null and player.model.abilities.has_inventory:
			draw_inventory(player.inventory, "Inventory", true, INVENTORY_SLOTS_PER_LINE, player.inventory.max_capacity, INVENTORYPANEL_X, INVENTORYPANEL_Y)
		draw_inventory(player.location.map.get_items_at(player.location.position), "Items on ground", true, INVENTORY_SLOTS_PER_LINE, Map.GROUND_INVENTORY_SLOTS, INVENTORYPANEL_X, GROUNDINVENTORYPANEL_Y)
		draw_corpses_list(player.location.map.get_corpses_at(player.location.position) if player.location.map.get_corpses_at(player.location.position) != null else [], "Corpses on ground", INVENTORY_SLOTS_PER_LINE, INVENTORYPANEL_X, CORPSESPANEL_Y)

	# character skills.
	if player != null and player.sheet.skill_table != null and player.sheet.skill_table.count_skills() > 0:
		draw_actor_skill_table(player, RIGHTPANEL_TEXT_X, SKILLTABLE_Y)

	# overlays: map-anchored ones (target boxes, damage numbers, ...) draw in
	# world px through the camera so they track the view; popups and panel
	# highlights draw in view-local screen px on the HUD.
	var overlay_world_origin: Vector2i = map_view_rect.position * TILE_SIZE
	for o in overlays:
		if o.map_anchored:
			ui.ui_set_world_draw(true)
			o.draw(ui, overlay_world_origin)
			ui.ui_set_world_draw(false)
		else:
			o.draw(ui, Vector2i.ZERO)

	# DEV STATS (C# #if DEBUG block, kept as a runtime option check)
	if options.dev_show_actors_stats:
		var count_living := count_livings(session.current_map)
		var count_undead := count_undeads(session.current_map)
		ui.ui_draw_string(Color.WHITE, "Living %d vs %d Undead" % [count_living, count_undead], RIGHTPANEL_TEXT_X, SKILLTABLE_Y - 32)

	ui.ui_repaint()


func location_text(map: Map, actor: Actor) -> String:
	if map == null or actor == null:
		return ""

	var sb := "(%d,%d) " % [actor.location.position.x, actor.location.position.y]

	var zones := map.get_zones_at(actor.location.position.x, actor.location.position.y)
	if zones == null or zones.is_empty():
		return sb

	for z in zones:
		sb += "%s " % z.name

	return sb


## OBSOLETE
func tint_for_day_phase(phase: WorldTime.DayPhase) -> Color:
	match phase:
		WorldTime.DayPhase.MORNING, WorldTime.DayPhase.MIDDAY, WorldTime.DayPhase.AFTERNOON:
			return TINT_DAY
		WorldTime.DayPhase.SUNRISE:
			return TINT_SUNRISE
		WorldTime.DayPhase.SUNSET:
			return TINT_SUNSET
		WorldTime.DayPhase.MIDNIGHT:
			return TINT_MIDNIGHT
		WorldTime.DayPhase.DEEP_NIGHT:
			return TINT_NIGHT
		WorldTime.DayPhase.EVENING:
			return TINT_EVENING
		_:
			push_error("unhandled dayphase")
			return Color.WHITE


#region Drawing elements
func draw_map(map: Map, tint: Color) -> void:
	# map content is drawn in WORLD pixels; the UI camera maps it to screen
	ui.ui_set_world_draw(true)
	# trim to outer map bounds.
	var left := maxi(-1, map_view_rect.position.x)
	var right := mini(map.width + 1, map_view_rect.end.x)
	var top := maxi(-1, map_view_rect.position.y)
	var bottom := mini(map.height + 1, map_view_rect.end.y)

	# get weather image.
	var weather_image := ""
	match session.world.weather:
		Weather.RAIN:
			weather_image = GameImages.WEATHER_RAIN1 if session.world_time.turn_counter % 2 == 0 else GameImages.WEATHER_RAIN2
		Weather.HEAVY_RAIN:
			weather_image = GameImages.WEATHER_HEAVY_RAIN1 if session.world_time.turn_counter % 2 == 0 else GameImages.WEATHER_HEAVY_RAIN2

	# ---------------------------------------
	# Layered draw:
	# 1. Tiles.
	# 2. Corpses.
	# 3. (Target statut), Map objects.
	# 4. Scents.
	# 5. Items, Actors (if visible).
	# 6. Water cover.
	# 7. Weather (if visible and not inside).
	# ---------------------------------------
	var is_undead := player.model.abilities.is_undead
	var has_smell := player.model.starting_sheet.base_smell_rating > 0
	var player_smell_threshold := rules.actor_smell_threshold(player)
	for x in range(left, right):
		for y in range(top, bottom):
			var position := Vector2i(x, y)
			var to_screen := map_to_world(x, y)
			var is_visible := is_visible_to_player(map, position)
			var draw_water := false
			var tile: Tile = map.get_tile_at(x, y) if map.is_in_bounds(x, y) else null

			# 1. Tile
			if map.is_in_bounds(x, y):
				draw_tile(tile, to_screen, tint)
			elif map.is_map_boundary(x, y):
				if map.get_exit_at(position) != null:
					draw_exit(to_screen)
			# DrawTileDev: DEBUG-only, skipped.

			# 2. Corpses
			if is_visible:
				var corpses = map.get_corpses_at_xy(x, y)
				if corpses != null:
					for c in corpses:
						draw_corpse(c, to_screen.x, to_screen.y, tint)

			# 3. (TargetStatus), Map objects
			if options.show_player_targets and not player.is_sleeping and player.location.position == position:
				draw_player_actor_targets(player)
			var map_obj := map.get_map_object_at_xy(x, y)
			if map_obj != null:
				draw_map_object(map_obj, to_screen, tint)
				draw_water = true

			# 4. Scents
			if not player.is_sleeping and map.is_in_bounds(x, y) and rules.grid_distance(player.location.position, x, y) <= 1:
				# scents alpha is low to be able to see objects behind them (eg: scent on a door)
				# squaring alpha helps increase discrimination for player.
				if is_undead:
					# Undead can see living & zm scents.
					if has_smell:
						# living scent?
						var living_scent := map.get_scent_by_odor_at(Odor.LIVING, position)
						if living_scent >= player_smell_threshold:
							var alpha := 0.90 * float(living_scent) / float(Odor.OdorScent.MAX_STRENGTH)
							alpha *= alpha
							ui.ui_draw_transparent_image(alpha, GameImages.ICON_SCENT_LIVING, to_screen.x, to_screen.y)

						# zombie master scent?
						var master_scent := map.get_scent_by_odor_at(Odor.UNDEAD_MASTER, position)
						if master_scent >= player_smell_threshold:
							var alpha := 0.90 * float(master_scent) / float(Odor.OdorScent.MAX_STRENGTH)
							alpha *= alpha
							ui.ui_draw_transparent_image(alpha, GameImages.ICON_SCENT_ZOMBIEMASTER, to_screen.x, to_screen.y)
				# living perfume overlays: alpha10 obsolete, skipped.

			# 5. Items, Actors (if visible)
			if is_visible:
				# 5.1. Items
				var inv := map.get_items_at_xy(x, y)
				if inv != null:
					draw_items_stack(inv, to_screen.x, to_screen.y, tint)
					draw_water = true

				# 5.2. Actors
				var actor := map.get_actor_at_xy(x, y)
				if actor != null:
					draw_actor_sprite(actor, to_screen, tint)
					draw_water = true

			# 6. Water cover.
			if tile != null and tile.has_decorations():
				draw_water = true
			if draw_water and tile != null and tile.model.is_water:
				draw_tile_water_cover(tile, to_screen, tint)

			# 7. Weather (if visible and not inside).
			if is_visible and weather_image != "" and tile != null and not tile.is_inside:
				ui.ui_draw_image(weather_image, to_screen.x, to_screen.y)

	# DEV scents overlay: C# #if false block, skipped.
	ui.ui_set_world_draw(false)


func moving_water_image(model: TileModel, turn_count: int) -> String:
	if model == game_tiles.floor_sewer_water():
		var i := turn_count % 3
		match i:
			0: return GameImages.TILE_FLOOR_SEWER_WATER_ANIM1
			1: return GameImages.TILE_FLOOR_SEWER_WATER_ANIM2
			_: return GameImages.TILE_FLOOR_SEWER_WATER_ANIM3

	return ""


func draw_tile(tile: Tile, screen: Vector2i, tint: Color) -> void:
	if tile.is_in_view:  # visible
		# tile.
		ui.ui_draw_image_tint(tile.model.image_id, screen.x, screen.y, tint)

		# animation layer.
		var moving_water := moving_water_image(tile.model, session.world_time.turn_counter)
		if moving_water != "":
			ui.ui_draw_image_tint(moving_water, screen.x, screen.y, tint)

		# decorations.
		if tile.has_decorations():
			for deco in tile.get_decorations():
				ui.ui_draw_image_tint(deco, screen.x, screen.y, tint)
	elif tile.is_visited and not is_player_sleeping():  # memorized
		# tile.
		ui.ui_draw_gray_level_image(tile.model.image_id, screen.x, screen.y)

		# animation layer.
		var moving_water := moving_water_image(tile.model, session.world_time.turn_counter)
		if moving_water != "":
			ui.ui_draw_gray_level_image(moving_water, screen.x, screen.y)

		# decorations.
		if tile.has_decorations():
			for deco in tile.get_decorations():
				ui.ui_draw_gray_level_image(deco, screen.x, screen.y)


func draw_tile_water_cover(tile: Tile, screen: Vector2i, tint: Color) -> void:
	if tile.is_in_view:  # visible
		ui.ui_draw_image_tint(tile.model.water_cover_image_id, screen.x, screen.y, tint)
	elif tile.is_visited and not is_player_sleeping():  # memorized
		ui.ui_draw_gray_level_image(tile.model.water_cover_image_id, screen.x, screen.y)


func draw_exit(screen: Vector2i) -> void:
	ui.ui_draw_image(GameImages.MAP_EXIT, screen.x, screen.y)


func draw_tile_rectangle(map_position: Vector2i, color: Color) -> void:
	ui.ui_draw_rect(color, Rect2i(map_to_screen(map_position), Vector2i(TILE_SIZE, TILE_SIZE)))


func draw_map_object(map_obj: MapObject, screen: Vector2i, tint: Color) -> void:
	# pushables objects in water floating animation.
	if map_obj.is_movable and map_obj.location.map.get_tile_at(map_obj.location.position.x, map_obj.location.position.y).model.is_water:
		var y_drift := -2 if (map_obj.location.position.x + session.world_time.turn_counter) % 2 == 0 else 0
		screen.y -= y_drift

	if is_visible_to_player(map_obj):
		draw_map_object_img(map_obj, screen, map_obj.image_id, func(image_id, gx, gy): ui.ui_draw_image_tint(image_id, gx, gy, tint))

		if map_obj.hit_points < map_obj.max_hit_points and map_obj.hit_points > 0:
			draw_map_health_bar(map_obj.hit_points, map_obj.max_hit_points, screen.x, screen.y)

		var door := map_obj as DoorWindow
		if door != null and door.barricade_points > 0:
			draw_map_health_bar(door.barricade_points, Rules.BARRICADING_MAX, screen.x, screen.y, Color.GREEN)
			ui.ui_draw_image_tint(GameImages.EFFECT_BARRICADED, screen.x, screen.y, tint)
	elif is_known_to_player(map_obj) and not is_player_sleeping():
		draw_map_object_img(map_obj, screen, map_obj.hidden_image_id, func(image_id, gx, gy): ui.ui_draw_gray_level_image(image_id, gx, gy))


func draw_map_object_img(map_obj: MapObject, screen: Vector2i, image_id: String, draw_fn: Callable) -> void:
	# draw image.
	draw_fn.call(image_id, screen.x, screen.y)

	# draw effects.
	if map_obj.is_on_fire:
		draw_fn.call(GameImages.EFFECT_ONFIRE, screen.x, screen.y)


func draw_actor_sprite(actor: Actor, screen: Vector2i, tint: Color) -> void:
	var gx := screen.x
	var gy := screen.y

	# player follower?
	if actor.leader != null and actor.leader == player:
		if rules.has_actor_bond_with(actor, player):
			ui.ui_draw_image_tint(GameImages.PLAYER_FOLLOWER_BOND, gx, gy, tint)
		elif rules.is_actor_trusting_leader(actor):
			ui.ui_draw_image_tint(GameImages.PLAYER_FOLLOWER_TRUST, gx, gy, tint)
		else:
			ui.ui_draw_image_tint(GameImages.PLAYER_FOLLOWER, gx, gy, tint)

	gx += ACTOR_OFFSET
	gy += ACTOR_OFFSET

	# model
	if actor.model.image_id != "":
		ui.ui_draw_image_tint(actor.model.image_id, gx, gy, tint)

	# skinning/clothing and body equipment.
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.SKIN, tint)
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.FEET, tint)
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.LEGS, tint)
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.TORSO, tint)
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.TORSO, tint)
	if actor.get_equipped_item(Doll.DollPart.TORSO) != null:
		draw_actor_equipment(actor, gx - ACTOR_OFFSET, gy - ACTOR_OFFSET, Doll.DollPart.TORSO, tint)
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.EYES, tint)
	draw_actor_decoration(actor, gx, gy, Doll.DollPart.HEAD, tint)

	# hands equipment
	draw_actor_equipment(actor, gx - ACTOR_OFFSET, gy - ACTOR_OFFSET, Doll.DollPart.LEFT_HAND, tint)
	draw_actor_equipment(actor, gx - ACTOR_OFFSET, gy - ACTOR_OFFSET, Doll.DollPart.RIGHT_HAND, tint)

	gx -= ACTOR_OFFSET
	gy -= ACTOR_OFFSET

	# personal enemy?
	if player != null:
		var im_self_defence := player.is_self_defence_from(actor)
		var im_the_aggressor := player.is_aggressor_of(actor)
		var group_enemies := not player.faction.is_enemy_of(actor.faction) and rules.are_group_enemies(player, actor)  # alpha10
		if im_self_defence:
			ui.ui_draw_image_tint(GameImages.ICON_SELF_DEFENCE, gx, gy, tint)
		elif im_the_aggressor:
			ui.ui_draw_image_tint(GameImages.ICON_AGGRESSOR, gx, gy, tint)
		elif group_enemies:
			ui.ui_draw_image_tint(GameImages.ICON_INDIRECT_ENEMIES, gx, gy, tint)

	# activity
	match actor.activity:
		Activity.IDLE:
			pass
		Activity.CHASING, Activity.FIGHTING:
			if not actor.is_player and actor.target_actor != null:
				if actor.target_actor == player:
					ui.ui_draw_image_tint(GameImages.ACTIVITY_CHASING_PLAYER, gx, gy, tint)
				else:
					ui.ui_draw_image_tint(GameImages.ACTIVITY_CHASING, gx, gy, tint)
		Activity.TRACKING:
			if not actor.is_player:
				ui.ui_draw_image_tint(GameImages.ACTIVITY_TRACKING, gx, gy, tint)
		Activity.FLEEING:
			if not actor.is_player:
				ui.ui_draw_image_tint(GameImages.ACTIVITY_FLEEING, gx, gy, tint)
		Activity.FLEEING_FROM_EXPLOSIVE:
			if not actor.is_player:
				ui.ui_draw_image_tint(GameImages.ACTIVITY_FLEEING_FROM_EXPLOSIVE, gx, gy, tint)
		Activity.FOLLOWING:
			if not actor.is_player and actor.target_actor != null:
				if actor.target_actor.is_player:
					ui.ui_draw_image(GameImages.ACTIVITY_FOLLOWING_PLAYER, gx, gy)
				elif actor.target_actor == actor.leader:  # alpha10
					ui.ui_draw_image(GameImages.ACTIVITY_FOLLOWING_LEADER, gx, gy)
				else:
					ui.ui_draw_image(GameImages.ACTIVITY_FOLLOWING, gx, gy)
		Activity.FOLLOWING_ORDER:
			ui.ui_draw_image(GameImages.ACTIVITY_FOLLOWING_ORDER, gx, gy)
		Activity.SLEEPING:
			ui.ui_draw_image(GameImages.ACTIVITY_SLEEPING, gx, gy)
		_:
			push_error("unhandled activity " + str(actor.activity))

	# health bar.
	var max_hp := rules.actor_max_hps(actor)
	if actor.hit_points < max_hp:
		draw_map_health_bar(actor.hit_points, max_hp, gx, gy)

	# run/tired icon.
	if actor.is_running:
		ui.ui_draw_image_tint(GameImages.ICON_RUNNING, gx, gy, tint)
	elif actor.model.abilities.can_run and not rules.can_actor_run(actor)["ok"]:
		ui.ui_draw_image_tint(GameImages.ICON_CANT_RUN, gx, gy, tint)

	# sleepy, hungry & insane icons.
	if actor.model.abilities.has_to_sleep:
		if rules.is_actor_exhausted(actor):
			ui.ui_draw_image_tint(GameImages.ICON_SLEEP_EXHAUSTED, gx, gy, tint)
		elif rules.is_actor_sleepy(actor):
			ui.ui_draw_image_tint(GameImages.ICON_SLEEP_SLEEPY, gx, gy, tint)
		elif rules.is_almost_sleepy(actor):
			ui.ui_draw_image_tint(GameImages.ICON_SLEEP_ALMOST_SLEEPY, gx, gy, tint)

	if actor.model.abilities.has_to_eat:
		if rules.is_actor_starving(actor):
			ui.ui_draw_image_tint(GameImages.ICON_FOOD_STARVING, gx, gy, tint)
		elif rules.is_actor_hungry(actor):
			ui.ui_draw_image_tint(GameImages.ICON_FOOD_HUNGRY, gx, gy, tint)
		elif is_almost_hungry(actor):
			ui.ui_draw_image_tint(GameImages.ICON_FOOD_ALMOST_HUNGRY, gx, gy, tint)
	elif actor.model.abilities.is_rotting:
		if rules.is_rotting_actor_starving(actor):
			ui.ui_draw_image_tint(GameImages.ICON_ROT_STARVING, gx, gy, tint)
		elif rules.is_rotting_actor_hungry(actor):
			ui.ui_draw_image_tint(GameImages.ICON_ROT_HUNGRY, gx, gy, tint)
		elif is_almost_rot_hungry(actor):
			ui.ui_draw_image_tint(GameImages.ICON_ROT_ALMOST_HUNGRY, gx, gy, tint)

	if actor.model.abilities.has_sanity:
		if rules.is_actor_insane(actor):
			ui.ui_draw_image_tint(GameImages.ICON_SANITY_INSANE, gx, gy, tint)
		elif rules.is_actor_disturbed(actor):
			ui.ui_draw_image_tint(GameImages.ICON_SANITY_DISTURBED, gx, gy, tint)

	# can trade with player icon.
	# alpha10.1 or has needed item (not for undead player duh)
	if player != null:
		if actor != player and not player.model.abilities.is_undead and actor_has_vital_item_for_player(actor):
			ui.ui_draw_image_tint(GameImages.ICON_HAS_VITAL_ITEM, gx, gy, tint)
		elif rules.can_actor_initiate_trade_with(player, actor)["ok"]:
			ui.ui_draw_image_tint(GameImages.ICON_CAN_TRADE, gx, gy, tint)

	# alpha10 odor suppressed icon (will overlap with sleep healing but its fine)
	if actor.odor_suppressor_counter > 0:
		ui.ui_draw_image_tint(GameImages.ICON_ODOR_SUPPRESSED, gx, gy, tint)

	# sleep-healing icon.
	if actor.is_sleeping and (rules.is_on_couch(actor) or rules.actor_heal_chance_bonus(actor) > 0):
		ui.ui_draw_image_tint(GameImages.ICON_HEALING, gx, gy, tint)

	# is a leader icon.
	if actor.count_followers > 0:
		ui.ui_draw_image_tint(GameImages.ICON_LEADER, gx, gy, tint)

	# alpha10 z-grab skill warning icon
	if actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_GRAB) > 0:
		ui.ui_draw_image_tint(GameImages.ICON_ZGRAB, gx, gy, tint)

	# combat assistant helper.
	if options.is_combat_assistant_on:
		if actor != player and player != null and rules.are_enemies(actor, player):
			if rules.will_actor_act_again_before(player, actor):
				ui.ui_draw_image_tint(GameImages.ICON_THREAT_SAFE, gx, gy, tint)
			elif rules.will_other_act_twice_before(player, actor):
				ui.ui_draw_image_tint(GameImages.ICON_THREAT_HIGH_DANGER, gx, gy, tint)
			else:
				ui.ui_draw_image_tint(GameImages.ICON_THREAT_DANGER, gx, gy, tint)
#endregion

# alpha10.1
## Checks if npc has a vital item for the player:
## - Food if player is hungry
## - Anti-sleep meds if player is sleepy
## - Healing meds if player injured
## - Curing meds if player infected
func actor_has_vital_item_for_player(actor: Actor) -> bool:
	if actor.inventory == null:
		return false
	if actor.inventory.is_empty:
		return false

	# hungry -> food
	if rules.is_actor_hungry(player) and actor.inventory.has_item_of_type(ItemFood):
		return true

	# sleepy -> anti-sleep meds
	if rules.is_actor_sleepy(player) \
			and actor.inventory.has_item_matching(func(it): return it is ItemMedicine and (it as ItemMedicine).sleep_boost > 0):
		return true

	# injured -> healing meds
	if player.hit_points < rules.actor_max_hps(player) \
			and actor.inventory.has_item_matching(func(it): return it is ItemMedicine and (it as ItemMedicine).healing > 0):
		return true

	# infected -> curing meds
	if player.infection > 0 \
			and actor.inventory.has_item_matching(func(it): return it is ItemMedicine and (it as ItemMedicine).infection_cure > 0):
		return true

	# no vital items
	return false


func draw_actor_decoration(actor: Actor, gx: int, gy: int, part: Doll.DollPart, tint: Color) -> void:
	var decos = actor.doll.get_decorations(part)
	if decos == null:
		return

	for image_id in decos:
		ui.ui_draw_image_tint(image_id, gx, gy, tint)


func draw_actor_decoration_transform(actor: Actor, gx: int, gy: int, part: Doll.DollPart, rotation: float, scale: float) -> void:
	var decos = actor.doll.get_decorations(part)
	if decos == null:
		return

	for image_id in decos:
		ui.ui_draw_image_transform(image_id, gx, gy, rotation, scale)


func draw_actor_equipment(actor: Actor, gx: int, gy: int, part: Doll.DollPart, tint: Color) -> void:
	var it := actor.get_equipped_item(part)
	if it == null:
		return

	ui.ui_draw_image_tint(it.image_id(), gx, gy, tint)


func draw_corpse(c: Corpse, gx: int, gy: int, _tint: Color) -> void:
	var rotation := c.rotation
	var scale := c.scale
	var offset := 0  # TILE_SIZE / 2

	var actor := c.dead_guy

	gx += ACTOR_OFFSET + offset
	gy += ACTOR_OFFSET + offset

	# model.
	if actor.model.image_id != "":
		ui.ui_draw_image_transform(actor.model.image_id, gx, gy, rotation, scale)

	# skinning/clothing.
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.SKIN, rotation, scale)
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.FEET, rotation, scale)
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.LEGS, rotation, scale)
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.TORSO, rotation, scale)
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.TORSO, rotation, scale)
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.EYES, rotation, scale)
	draw_actor_decoration_transform(actor, gx, gy, Doll.DollPart.HEAD, rotation, scale)

	gx -= ACTOR_OFFSET + offset
	gy -= ACTOR_OFFSET + offset

	# rotting.
	var rot_level := rules.corpse_rot_level(c)
	var img := ""
	match rot_level:
		5, 4, 3, 2, 1:
			img = "rot%d_" % rot_level
		0:
			pass
		_:
			push_error("unhandled rot level")
	if img != "":
		# anim frame.
		img += str(1 + (session.world_time.turn_counter % 2))
		# a bit of offset for a nice flies movement effect.
		var rot_dx := (session.world_time.turn_counter % 5) - 2
		var rot_dy := ((session.world_time.turn_counter / 3) % 5) - 2
		ui.ui_draw_image(img, gx + rot_dx, gy + rot_dy)


func draw_corpses_list(list: Array, title: String, slots: int, gx: int, gy: int) -> void:
	var x: int
	var y: int
	var slot := 0

	# Draw title.
	var n := 0 if list == null else list.size()
	if n > 0:
		title += " : %d" % n
	gy -= BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, title, gx, gy)
	gy += BOLD_LINE_SPACING

	# Draw slots.
	x = gx
	y = gy
	slot = 0
	for i in slots:
		ui.ui_draw_image(GameImages.ITEM_SLOT, x, y)
		x += TILE_SIZE

	# Draw corpses.
	if list == null:
		return

	x = gx
	y = gy
	slot = 0
	for c in list:
		if c.is_dragged():
			ui.ui_draw_image(GameImages.CORPSE_DRAGGED, x, y)
		draw_corpse(c, x, y, Color.WHITE)
		slot += 1
		if slot >= slots:
			break
		else:
			x += TILE_SIZE


# alpha10
## Highlight with overlays which visible actors are
## - are the target of this actor
## - targeting this actor
## - in group with this actor
func draw_actor_relations(actor: Actor) -> void:
	# TODO: OverlayImage inner class (RogueGame.cs lines 452-644) is ported by another part file.
	# target of this actor
	if actor.target_actor != null and not actor.target_actor.is_dead and is_visible_to_player(actor.target_actor):
		add_overlay(OverlayImage.new(map_to_screen(actor.target_actor.location.position), GameImages.ICON_IS_TARGET))

	# actors targeting this actor or in same group
	var is_targetted_highlighted := false
	for other in actor.location.map.actors_list:
		if other == actor or other.is_dead or not is_visible_to_player(other):
			continue

		# targetting this actor
		if other.target_actor == actor and (other.activity == Activity.CHASING or other.activity == Activity.FIGHTING):
			if not is_targetted_highlighted:
				add_overlay(OverlayImage.new(map_to_screen(actor.location.position), GameImages.ICON_IS_TARGETTED))
				is_targetted_highlighted = true
			add_overlay(OverlayImage.new(map_to_screen(other.location.position), GameImages.ICON_IS_TARGETING))

		# in group with actor
		if other.is_in_group_with(actor):
			add_overlay(OverlayImage.new(map_to_screen(other.location.position), GameImages.ICON_IS_IN_GROUP))


## immediate mode
func draw_player_actor_targets(player_: Actor) -> void:
	if player_.target_actor != null and not player_.target_actor.is_dead and is_visible_to_player(player_.target_actor):
		var gpos := map_to_screen(player_.target_actor.location.position)
		ui.ui_draw_image(GameImages.ICON_IS_TARGET, gpos.x, gpos.y)
	for a in player_.location.map.actors_list:
		if a == player_ or a.is_dead or not is_visible_to_player(a):
			continue
		if a.target_actor == player_ and (a.activity == Activity.CHASING or a.activity == Activity.FIGHTING):
			var gpos := map_to_screen(player_.location.position)
			ui.ui_draw_image(GameImages.ICON_IS_TARGETTED, gpos.x, gpos.y)
			break


func draw_items_stack(inventory: Inventory, gx: int, gy: int, tint: Color) -> void:
	if inventory == null:
		return

	for it in inventory.items:
		draw_item(it, gx, gy, tint)


func draw_map_icon(position: Vector2i, image_id: String) -> void:
	ui.ui_draw_image(image_id, position.x * TILE_SIZE, position.y * TILE_SIZE)


func draw_map_health_bar(hit_points: int, max_hit_points: int, gx: int, gy: int, bar_color: Color = Color.RED) -> void:
	var hp_x := gx + 4
	var hp_y := gy + TILE_SIZE - 4
	var bar_length := 0 if max_hit_points <= 0 else int(20 * float(hit_points) / float(max_hit_points))
	ui.ui_fill_rect(Color.BLACK, Rect2i(hp_x, hp_y, 20, 4))
	if bar_length > 0:
		ui.ui_fill_rect(bar_color, Rect2i(hp_x + 1, hp_y + 1, bar_length, 2))


func draw_bar(value: int, previous_value: int, max_value: int, ref_value: int, max_width: int, height: int, gx: int, gy: int,
		fill_color: Color, loss_fill_color: Color, gain_fill_color: Color, empty_color: Color) -> void:
	ui.ui_fill_rect(empty_color, Rect2i(gx, gy, max_width, height))

	var prev_bar_length := 0
	var bar_length := 0
	if max_value > 0:
		prev_bar_length = int(max_width * float(previous_value) / float(max_value))
		bar_length = int(max_width * float(value) / float(max_value))

	if value > previous_value:
		# gain
		if bar_length > 0:
			ui.ui_fill_rect(gain_fill_color, Rect2i(gx, gy, bar_length, height))
		if prev_bar_length > 0:
			ui.ui_fill_rect(fill_color, Rect2i(gx, gy, prev_bar_length, height))
	elif value < previous_value:
		# loss
		if prev_bar_length > 0:
			ui.ui_fill_rect(loss_fill_color, Rect2i(gx, gy, prev_bar_length, height))
		if bar_length > 0:
			ui.ui_fill_rect(fill_color, Rect2i(gx, gy, bar_length, height))
	else:
		# no change.
		if bar_length > 0:
			ui.ui_fill_rect(fill_color, Rect2i(gx, gy, bar_length, height))

	# reference line.
	var ref_length := 0 if max_value <= 0 else int(max_width * float(ref_value) / float(max_value))
	ui.ui_draw_line(Color.WHITE, gx + ref_length, gy, gx + ref_length, gy + height)


func draw_mini_map(map: Map) -> void:
	# clear minimap.
	if options.is_minimap_on:
		ui.ui_clear_minimap(Color.BLACK)

	# set visited tiles color.
	if options.is_minimap_on:
		for x in range(map.width):
			for y in range(map.height):
				var pt := Vector2i(x, y)
				var tile := map.get_tile_at(x, y)
				if tile.is_visited:
					# exits override tile color.
					if map.get_exit_at(pt) != null:
						ui.ui_set_minimap_color(x, y, Color.HOT_PINK)
					else:
						ui.ui_set_minimap_color(x, y, tile.model.minimap_color)

	# show minimap.
	if options.is_minimap_on:
		ui.ui_draw_minimap(MINIMAP_X, MINIMAP_Y)

	# show view rect.
	ui.ui_draw_rect(Color.WHITE, Rect2i(MINIMAP_X + map_view_rect.position.x * MINITILE_SIZE, MINIMAP_Y + map_view_rect.position.y * MINITILE_SIZE, map_view_rect.size.x * MINITILE_SIZE, map_view_rect.size.y * MINITILE_SIZE))

	# show player tags.
	if options.show_player_tags_on_minimap:
		for x in range(map.width):
			for y in range(map.height):
				var tile := map.get_tile_at(x, y)
				if tile.is_visited:
					var minitag := ""
					if tile.has_decoration(GameImages.DECO_PLAYER_TAG1):
						minitag = GameImages.MINI_PLAYER_TAG1
					elif tile.has_decoration(GameImages.DECO_PLAYER_TAG2):
						minitag = GameImages.MINI_PLAYER_TAG2
					elif tile.has_decoration(GameImages.DECO_PLAYER_TAG3):
						minitag = GameImages.MINI_PLAYER_TAG3
					elif tile.has_decoration(GameImages.DECO_PLAYER_TAG4):
						minitag = GameImages.MINI_PLAYER_TAG4
					if minitag != "":
						var pos := Vector2i(MINIMAP_X + x * MINITILE_SIZE, MINIMAP_Y + y * MINITILE_SIZE)
						ui.ui_draw_image(minitag, pos.x - MINI_TRACKER_OFFSET, pos.y - MINI_TRACKER_OFFSET)

	# show player & tracked actors.
	# add tracked targets images out of player fov on the map.
	if player != null:
		# tracker items.
		if not player.is_sleeping:
			var tracker := player.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker

			# tracking...
			if tracker != null and tracker.batteries > 0:
				# ...followers?
				if player.count_followers > 0 and tracker.can_track_followers_or_leader:
					for fo in player.followers:
						# only track in same map.
						if fo.location.map != player.location.map:
							continue

						var fo_tracker := fo.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
						if fo_tracker != null and fo_tracker.can_track_followers_or_leader:
							# show follower position.
							var fo_mini_pos := Vector2i(MINIMAP_X + fo.location.position.x * MINITILE_SIZE, MINIMAP_Y + fo.location.position.y * MINITILE_SIZE)
							ui.ui_draw_image(GameImages.MINI_FOLLOWER_POSITION, fo_mini_pos.x - MINI_TRACKER_OFFSET, fo_mini_pos.y - MINI_TRACKER_OFFSET)

							# if out of FoV but in view, draw on map.
							if is_in_view_rect(fo.location.position) and not is_visible_to_player(fo):
								var screen_pos := map_to_screen(fo.location.position)
								ui.ui_draw_image(GameImages.TRACK_FOLLOWER_POSITION, screen_pos.x, screen_pos.y)

				# ...undeads?
				if tracker.can_track_undeads:
					for other in map.actors_list:
						if other == player:
							continue
						if not other.model.abilities.is_undead:
							continue
						# only track in same map.
						if other.location.map != player.location.map:
							continue
						if rules.grid_distance_points(other.location.position, player.location.position) > Rules.ZTRACKINGRADIUS:
							continue

						# close undead, show it.
						var undead_pos := Vector2i(MINIMAP_X + other.location.position.x * MINITILE_SIZE, MINIMAP_Y + other.location.position.y * MINITILE_SIZE)
						ui.ui_draw_image(GameImages.MINI_UNDEAD_POSITION, undead_pos.x - MINI_TRACKER_OFFSET, undead_pos.y - MINI_TRACKER_OFFSET)

						# if out of FoV but in view, draw on map.
						if is_in_view_rect(other.location.position) and not is_visible_to_player(other):
							var screen_pos := map_to_screen(other.location.position)
							ui.ui_draw_image(GameImages.TRACK_UNDEAD_POSITION, screen_pos.x, screen_pos.y)

				# ...BlackOps?
				if tracker.can_track_black_ops:
					for other in map.actors_list:
						if other == player:
							continue
						if other.faction != game_factions.the_black_ops():
							continue
						# only track in same map.
						if other.location.map != player.location.map:
							continue

						# blackop, show it.
						var bo_pos := Vector2i(MINIMAP_X + other.location.position.x * MINITILE_SIZE, MINIMAP_Y + other.location.position.y * MINITILE_SIZE)
						ui.ui_draw_image(GameImages.MINI_BLACKOPS_POSITION, bo_pos.x - MINI_TRACKER_OFFSET, bo_pos.y - MINI_TRACKER_OFFSET)

						# if out of FoV but in view, draw on map.
						if is_in_view_rect(other.location.position) and not is_visible_to_player(other):
							var screen_pos := map_to_screen(other.location.position)
							ui.ui_draw_image(GameImages.TRACK_BLACKOPS_POSITION, screen_pos.x, screen_pos.y)

				# ...Police?
				if tracker.can_track_police:
					for other in map.actors_list:
						if other == player:
							continue
						if other.faction != game_factions.the_police():
							continue
						# only track in same map.
						if other.location.map != player.location.map:
							continue

						# policeman, show it.
						var bo_pos := Vector2i(MINIMAP_X + other.location.position.x * MINITILE_SIZE, MINIMAP_Y + other.location.position.y * MINITILE_SIZE)
						ui.ui_draw_image(GameImages.MINI_POLICE_POSITION, bo_pos.x - MINI_TRACKER_OFFSET, bo_pos.y - MINI_TRACKER_OFFSET)

						# if out of FoV but in view, draw on map.
						if is_in_view_rect(other.location.position) and not is_visible_to_player(other):
							var screen_pos := map_to_screen(other.location.position)
							ui.ui_draw_image(GameImages.TRACK_POLICE_POSITION, screen_pos.x, screen_pos.y)

		# player.
		var pos := Vector2i(MINIMAP_X + player.location.position.x * MINITILE_SIZE, MINIMAP_Y + player.location.position.y * MINITILE_SIZE)
		ui.ui_draw_image(GameImages.MINI_PLAYER_POSITION, pos.x - MINI_TRACKER_OFFSET, pos.y - MINI_TRACKER_OFFSET)


func draw_actor_status(actor: Actor, gx: int, gy: int) -> void:
	# 1. Name & occupation
	ui.ui_draw_string_bold(Color.LIGHT_GREEN if actor.is_invincible else Color.WHITE, "%s, %s" % [actor.name, actor.faction.member_name], gx, gy)

	# 2. Bars: Health, Stamina, Food, Sleep, Infection.
	gy += BOLD_LINE_SPACING
	var max_hp := rules.actor_max_hps(actor)
	ui.ui_draw_string_bold(Color.WHITE, "HP  %d" % actor.hit_points, gx, gy)
	draw_bar(actor.hit_points, actor.previous_hit_points, max_hp, 0, 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.RED, Color.DARK_RED, Color.ORANGE_RED, Color.GRAY)
	ui.ui_draw_string_bold(Color.WHITE, "%d" % max_hp, gx + BOLD_LINE_SPACING * 6 + 100, gy)

	gy += BOLD_LINE_SPACING
	if actor.model.abilities.can_tire:
		var max_sta := rules.actor_max_sta(actor)
		ui.ui_draw_string_bold(Color.WHITE, "STA %d" % actor.stamina_points, gx, gy)
		draw_bar(actor.stamina_points, actor.previous_stamina_points, max_sta, Rules.STAMINA_MIN_FOR_ACTIVITY, 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.GREEN, Color.DARK_GREEN, Color.LIGHT_GREEN, Color.GRAY)
		ui.ui_draw_string_bold(Color.WHITE, "%d" % max_sta, gx + BOLD_LINE_SPACING * 6 + 100, gy)
		if actor.is_running:
			ui.ui_draw_string_bold(Color.LIGHT_GREEN, "RUNNING!", gx + BOLD_LINE_SPACING * 9 + 100, gy)
		elif rules.can_actor_run(actor)["ok"]:
			ui.ui_draw_string_bold(Color.GREEN, "can run", gx + BOLD_LINE_SPACING * 9 + 100, gy)
		elif rules.is_actor_tired(actor):
			ui.ui_draw_string_bold(Color.GRAY, "TIRED", gx + BOLD_LINE_SPACING * 9 + 100, gy)

	gy += BOLD_LINE_SPACING
	if actor.model.abilities.has_to_eat:
		var max_food := rules.actor_max_food(actor)
		ui.ui_draw_string_bold(Color.WHITE, "FOO %d" % actor.food_points, gx, gy)
		draw_bar(actor.food_points, actor.previous_food_points, max_food, Rules.FOOD_HUNGRY_LEVEL, 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.CHOCOLATE, Color.BROWN, Color.BEIGE, Color.GRAY)
		ui.ui_draw_string_bold(Color.WHITE, "%d" % max_food, gx + BOLD_LINE_SPACING * 6 + 100, gy)
		if rules.is_actor_hungry(actor):
			if rules.is_actor_starving(actor):
				ui.ui_draw_string_bold(Color.RED, "STARVING!", gx + BOLD_LINE_SPACING * 9 + 100, gy)
			else:
				ui.ui_draw_string_bold(Color.YELLOW, "Hungry", gx + BOLD_LINE_SPACING * 9 + 100, gy)
		else:
			ui.ui_draw_string_bold(Color.WHITE, "%dh" % food_to_hours_until_hungry(actor.food_points), gx + BOLD_LINE_SPACING * 9 + 100, gy)
	elif actor.model.abilities.is_rotting:
		var max_food := rules.actor_max_rot(actor)
		ui.ui_draw_string_bold(Color.WHITE, "ROT %d" % actor.food_points, gx, gy)
		draw_bar(actor.food_points, actor.previous_food_points, max_food, Rules.ROT_HUNGRY_LEVEL, 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.CHOCOLATE, Color.BROWN, Color.BEIGE, Color.GRAY)
		ui.ui_draw_string_bold(Color.WHITE, "%d" % max_food, gx + BOLD_LINE_SPACING * 6 + 100, gy)
		if rules.is_rotting_actor_hungry(actor):
			if rules.is_rotting_actor_starving(actor):
				ui.ui_draw_string_bold(Color.RED, "STARVING!", gx + BOLD_LINE_SPACING * 9 + 100, gy)
			else:
				ui.ui_draw_string_bold(Color.YELLOW, "Hungry", gx + BOLD_LINE_SPACING * 9 + 100, gy)
		else:
			ui.ui_draw_string_bold(Color.WHITE, "%dh" % food_to_hours_until_rot_hungry(actor.food_points), gx + BOLD_LINE_SPACING * 9 + 100, gy)

	gy += BOLD_LINE_SPACING
	if actor.model.abilities.has_to_sleep:
		var max_sleep := rules.actor_max_sleep(actor)
		ui.ui_draw_string_bold(Color.WHITE, "SLP %d" % actor.sleep_points, gx, gy)
		draw_bar(actor.sleep_points, actor.previous_sleep_points, max_sleep, Rules.SLEEP_SLEEPY_LEVEL, 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.BLUE, Color.DARK_BLUE, Color.LIGHT_BLUE, Color.GRAY)
		ui.ui_draw_string_bold(Color.WHITE, "%d" % max_sleep, gx + BOLD_LINE_SPACING * 6 + 100, gy)
		if rules.is_actor_sleepy(actor):
			if rules.is_actor_exhausted(actor):
				ui.ui_draw_string_bold(Color.RED, "EXHAUSTED!", gx + BOLD_LINE_SPACING * 9 + 100, gy)
			else:
				ui.ui_draw_string_bold(Color.YELLOW, "Sleepy", gx + BOLD_LINE_SPACING * 9 + 100, gy)
		else:
			ui.ui_draw_string_bold(Color.WHITE, "%dh" % rules.sleep_to_hours_until_sleepy(actor.sleep_points, session.world_time.is_night), gx + BOLD_LINE_SPACING * 9 + 100, gy)

	gy += BOLD_LINE_SPACING
	if actor.model.abilities.has_sanity:
		var max_san := rules.actor_max_sanity(actor)
		ui.ui_draw_string_bold(Color.WHITE, "SAN %d" % actor.sanity, gx, gy)
		draw_bar(actor.sanity, actor.previous_sanity, max_san, rules.actor_disturbed_level(actor), 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.ORANGE, Color.DARK_ORANGE, Color.ORANGE_RED, Color.GRAY)
		ui.ui_draw_string_bold(Color.WHITE, "%d" % max_san, gx + BOLD_LINE_SPACING * 6 + 100, gy)
		if rules.is_actor_disturbed(actor):
			if rules.is_actor_insane(actor):
				ui.ui_draw_string_bold(Color.RED, "INSANE!", gx + BOLD_LINE_SPACING * 9 + 100, gy)
			else:
				ui.ui_draw_string_bold(Color.YELLOW, "Disturbed", gx + BOLD_LINE_SPACING * 9 + 100, gy)
		else:
			ui.ui_draw_string_bold(Color.WHITE, "%dh" % rules.sanity_to_hours_until_unstable(actor), gx + BOLD_LINE_SPACING * 9 + 100, gy)

	if Rules.has_infection(session.game_mode) and not actor.model.abilities.is_undead:
		var max_inf := rules.actor_infection_hps(actor)
		var ref_inf := (Rules.INFECTION_LEVEL_1_WEAK * max_inf) / 100
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "INF %d" % actor.infection, gx, gy)
		draw_bar(actor.infection, actor.infection, max_inf, ref_inf, 100, BOLD_LINE_SPACING, gx + BOLD_LINE_SPACING * 5, gy, Color.PURPLE, Color.BLACK, Color.BLACK, Color.GRAY)
		ui.ui_draw_string_bold(Color.WHITE, "%d%%" % rules.actor_infection_percent(actor), gx + BOLD_LINE_SPACING * 6 + 100, gy)

	# 3. Melee & Ranged Attacks.
	gy += BOLD_LINE_SPACING
	var melee := rules.actor_melee_attack(actor, actor.current_melee_attack, null)
	var dmg_bonus_vs_undead := rules.actor_damage_bonus_vs_undeads(actor)
	ui.ui_draw_string_bold(Color.WHITE, "Melee  Atk %02d  Dmg %02d/%02d" % [melee.hit_value, melee.damage_value, melee.damage_value + dmg_bonus_vs_undead], gx, gy)

	gy += BOLD_LINE_SPACING
	var ranged := rules.actor_ranged_attack(actor, actor.current_ranged_attack, actor.current_ranged_attack.efficient_range(), null)
	var ranged_weapon := actor.get_equipped_weapon() as ItemRangedWeapon
	var ammo := 0
	var max_ammo := 0
	if ranged_weapon != null:
		ammo = ranged_weapon.ammo
		max_ammo = (ranged_weapon.model as ItemRangedWeaponModel).max_ammo
		ui.ui_draw_string_bold(Color.WHITE, "Ranged Atk %02d  Dmg %02d/%02d Rng %d-%d Amo %d/%d" % [
			ranged.hit_value, ranged.damage_value, ranged.damage_value + dmg_bonus_vs_undead, ranged.range_value, ranged.efficient_range(), ammo, max_ammo], gx, gy)

	# 4. (living)Def, Pro, Spd, FoV & Nb of followers / (undead)Def, Spd, Fov, Sml, Kills
	gy += BOLD_LINE_SPACING
	var defence := rules.actor_defence(actor, actor.current_defence)

	if actor.model.abilities.is_undead:
		ui.ui_draw_string_bold(Color.WHITE, "Def %02d Spd %.2f FoV %d Sml %.2f Kills %d" % [
			defence.value,
			float(rules.actor_speed(actor)) / float(Rules.BASE_SPEED),
			rules.actor_fov(actor, session.world_time, session.world.weather),
			rules.actor_smell(actor),
			actor.kills_count], gx, gy)
	else:
		ui.ui_draw_string_bold(Color.WHITE, "Def %02d Arm %d/%d Spd %.2f FoV %d/%d Fol %d/%d" % [
			defence.value, defence.protection_hit, defence.protection_shot,
			float(rules.actor_speed(actor)) / float(Rules.BASE_SPEED),
			rules.actor_fov(actor, session.world_time, session.world.weather),
			actor.sheet.base_view_range,
			actor.count_followers, rules.actor_max_followers(actor)], gx, gy)

	# 5. Odor suppressor // alpha10
	gy += BOLD_LINE_SPACING
	if actor.odor_suppressor_counter > 0:
		ui.ui_draw_string_bold(Color.LIGHT_BLUE, "Odor suppr : %d -%d" % [actor.odor_suppressor_counter, rules.odors_decay(actor.location.map, actor.location.position, session.world.weather)], gx, gy)


func draw_inventory(inventory: Inventory, title: String, draw_slots_numbers: bool, slots_per_line: int, max_slots: int, gx: int, gy: int) -> void:
	var x: int
	var y: int
	var slot := 0

	# Draw title.
	gy -= BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, title, gx, gy)
	gy += BOLD_LINE_SPACING

	# Draw slots.
	x = gx
	y = gy
	slot = 0
	for i in max_slots:
		ui.ui_draw_image(GameImages.ITEM_SLOT, x, y)
		slot += 1
		if slot >= slots_per_line:
			slot = 0
			y += TILE_SIZE
			x = gx
		else:
			x += TILE_SIZE

	# Draw items.
	if inventory == null:
		return

	x = gx
	y = gy
	slot = 0
	for it in inventory.items:
		if it.is_equipped:
			ui.ui_draw_image(GameImages.ITEM_EQUIPPED, x, y)
		if it is ItemRangedWeapon:
			var w := it as ItemRangedWeapon
			if w.ammo <= 0:
				ui.ui_draw_image(GameImages.ICON_OUT_OF_AMMO, x, y)
			draw_bar(w.ammo, w.ammo, (w.model as ItemRangedWeaponModel).max_ammo, 0, 28, 3, x + 2, y + 27, Color.BLUE, Color.BLUE, Color.BLUE, Color.DARK_GRAY)
		elif it is ItemSprayPaint:
			var sp := it as ItemSprayPaint
			draw_bar(sp.paint_quantity, sp.paint_quantity, (sp.model as ItemSprayPaintModel).max_paint_quantity, 0, 28, 3, x + 2, y + 27, Color.GOLD, Color.GOLD, Color.GOLD, Color.DARK_GRAY)
		elif it is ItemSprayScent:
			var sp := it as ItemSprayScent
			draw_bar(sp.spray_quantity, sp.spray_quantity, (sp.model as ItemSprayScentModel).max_spray_quantity, 0, 28, 3, x + 2, y + 27, Color.CYAN, Color.CYAN, Color.CYAN, Color.DARK_GRAY)
		elif it is ItemLight:
			var lt := it as ItemLight
			if lt.batteries <= 0:
				ui.ui_draw_image(GameImages.ICON_OUT_OF_BATTERIES, x, y)
			draw_bar(lt.batteries, lt.batteries, (lt.model as ItemLightModel).max_batteries, 0, 28, 3, x + 2, y + 27, Color.YELLOW, Color.YELLOW, Color.YELLOW, Color.DARK_GRAY)
		elif it is ItemTracker:
			var _tr := it as ItemTracker
			if _tr.batteries <= 0:
				ui.ui_draw_image(GameImages.ICON_OUT_OF_BATTERIES, x, y)
			draw_bar(_tr.batteries, _tr.batteries, (_tr.model as ItemTrackerModel).max_batteries, 0, 28, 3, x + 2, y + 27, Color.PINK, Color.PINK, Color.PINK, Color.DARK_GRAY)
		elif it is ItemFood:
			var food := it as ItemFood
			if rules.is_food_expired(food, session.world_time.turn_counter):
				ui.ui_draw_image(GameImages.ICON_EXPIRED_FOOD, x, y)
			elif rules.is_food_spoiled(food, session.world_time.turn_counter):
				ui.ui_draw_image(GameImages.ICON_SPOILED_FOOD, x, y)
		elif it is ItemTrap:
			var trap := it as ItemTrap
			draw_trap_item(trap, x, y)  # alpha10
		elif it is ItemEntertainment:
			if player != null and (it as ItemEntertainment).is_boring_for(player):  # alpha10 boring items item centric
				ui.ui_draw_image(GameImages.ICON_BORING_ITEM, x, y)
		draw_item(it, x, y)

		slot += 1
		if slot >= slots_per_line:
			slot = 0
			y += TILE_SIZE
			x = gx
		else:
			x += TILE_SIZE

	# Draw slots numbers.
	if draw_slots_numbers:
		x = gx + 4
		y = gy + TILE_SIZE
		for i in inventory.max_capacity:
			ui.ui_draw_string(Color.WHITE, str(i + 1), x, y)
			x += TILE_SIZE


func draw_item(it: Item, gx: int, gy: int, tint: Color = Color.WHITE) -> void:
	ui.ui_draw_image_tint(it.image_id(), gx, gy, tint)

	if it.model.is_stackable:
		var q := str(it.quantity)
		var tx := gx + TILE_SIZE - 10
		if it.quantity > 100:
			tx -= 10
		elif it.quantity > 10:
			tx -= 4
		ui.ui_draw_string(Color.DARK_GRAY, q, tx + 1, gy + 1)
		ui.ui_draw_string(Color.WHITE, q, tx, gy)
	if it is ItemTrap:
		draw_trap_item(it as ItemTrap, gx, gy)  # alpha10


# alpha10 factorized code
func draw_trap_item(trap: ItemTrap, gx: int, gy: int) -> void:
	if trap.is_triggered:
		# alpha10
		if trap.owner == player:
			ui.ui_draw_image(GameImages.ICON_TRAP_TRIGGERED_SAFE_PLAYER, gx, gy)
		elif rules.is_safe_from_trap(trap, player):
			ui.ui_draw_image(GameImages.ICON_TRAP_TRIGGERED_SAFE_GROUP, gx, gy)
		else:
			ui.ui_draw_image(GameImages.ICON_TRAP_TRIGGERED, gx, gy)
	elif trap.is_activated:
		# alpha10
		if trap.owner == player:
			ui.ui_draw_image(GameImages.ICON_TRAP_ACTIVATED_SAFE_PLAYER, gx, gy)
		elif rules.is_safe_from_trap(trap, player):
			ui.ui_draw_image(GameImages.ICON_TRAP_ACTIVATED_SAFE_GROUP, gx, gy)
		else:
			ui.ui_draw_image(GameImages.ICON_TRAP_ACTIVATED, gx, gy)


func draw_actor_skill_table(actor: Actor, gx: int, gy: int) -> void:
	gy -= BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Skills", gx, gy)
	gy += BOLD_LINE_SPACING

	var skills = actor.sheet.skill_table.skills()
	if skills == null:
		return

	var x: int
	var y: int
	var count := 0
	x = gx
	y = gy
	for sk in skills:
		var sk_color := Color.WHITE

		# alpha10 highlight if active skills are active or not
		match sk.id:
			Skills.IDs.MARTIAL_ARTS:
				sk_color = Color.LIGHT_GREEN if actor.get_equipped_weapon() == null else Color.RED
			Skills.IDs.HARDY:
				if actor.is_sleeping:
					sk_color = Color.LIGHT_GREEN

		ui.ui_draw_string(sk_color, "%d-" % sk.level, x, y)
		x += 16
		ui.ui_draw_string(sk_color, Skills.name(sk.id), x, y)
		x -= 16

		count += 1
		if count >= SKILLTABLE_LINES:
			count = 0
			y = gy
			x += 120
		else:
			y += LINE_SPACING
#endregion

#region Overlays
func add_overlay(o) -> void:
	# lock(m_Overlays) skipped: single-threaded Godot port.
	overlays.append(o)


func clear_overlays() -> void:
	overlays.clear()


func remove_overlay(o) -> void:
	overlays.erase(o)


# alpha10
func has_overlay(o) -> bool:
	return overlays.has(o)
#endregion

#region Coordinates conversion
## C# overloads MapToScreen(Point) / MapToScreen(int, int) merged into one
## dispatching function. Returns VIEW-LOCAL screen (canvas) pixels; the map
## itself is drawn in world pixels (map_to_world) and the UI Camera2D — kept
## on the view-rect origin — maps world -> screen.
func map_to_screen(a, b: int = 0) -> Vector2i:
	if a is Vector2i:
		return Vector2i((a.x - map_view_rect.position.x) * TILE_SIZE, (a.y - map_view_rect.position.y) * TILE_SIZE)
	return Vector2i((a - map_view_rect.position.x) * TILE_SIZE, (b - map_view_rect.position.y) * TILE_SIZE)


## World-space pixels of a map position (what the TileMapLayer/sprite nodes
## under the UI camera use). The camera sits on the view-rect origin, so
## world px render exactly at the old view-local screen px.
func map_to_world(a, b: int = 0) -> Vector2i:
	if a is Vector2i:
		return Vector2i(a.x * TILE_SIZE, a.y * TILE_SIZE)
	return Vector2i(a * TILE_SIZE, b * TILE_SIZE)


func screen_to_map(a, b: int = 0) -> Vector2i:
	if a is Vector2i:
		return Vector2i(map_view_rect.position.x + a.x / TILE_SIZE, map_view_rect.position.y + a.y / TILE_SIZE)
	return Vector2i(map_view_rect.position.x + a / TILE_SIZE, map_view_rect.position.y + b / TILE_SIZE)


func mouse_to_map(a, b: int = 0) -> Vector2i:
	var mouse_x: int
	var mouse_y: int
	if a is Vector2i:
		mouse_x = int(a.x / ui.ui_get_canvas_scale_x())
		mouse_y = int(a.y / ui.ui_get_canvas_scale_y())
	else:
		mouse_x = int(a / ui.ui_get_canvas_scale_x())
		mouse_y = int(b / ui.ui_get_canvas_scale_y())
	return screen_to_map(mouse_x, mouse_y)


func mouse_to_inventory_slot(inv_x: int, inv_y: int, mouse_x: int, mouse_y: int) -> Vector2i:
	mouse_x = int(mouse_x / ui.ui_get_canvas_scale_x())
	mouse_y = int(mouse_y / ui.ui_get_canvas_scale_y())

	return Vector2i((mouse_x - inv_x) / 32, (mouse_y - inv_y) / 32)


func inventory_slot_to_screen(inv_x: int, inv_y: int, slot_x: int, slot_y: int) -> Vector2i:
	return Vector2i(inv_x + slot_x * 32, inv_y + slot_y * 32)
#endregion

#region Visibility/Smell & memory helpers
## C# overloads IsVisibleToPlayer(Location/Map+Point/Actor/MapObject) merged
## into one dispatching function.
func is_visible_to_player(obj, position: Vector2i = Vector2i.ZERO) -> bool:
	if obj is Map:
		return player != null \
			and obj == player.location.map and obj.is_in_bounds(position.x, position.y) \
			and obj.get_tile_at(position.x, position.y).is_in_view
	if obj is Location:
		return is_visible_to_player(obj.map, obj.position)
	if obj is Actor:
		return obj == player or is_visible_to_player(obj.location)
	if obj is MapObject:
		return is_visible_to_player(obj.location)
	return false


## C# overloads IsKnownToPlayer(Map+Point/Location/MapObject) merged.
func is_known_to_player(obj, position: Vector2i = Vector2i.ZERO) -> bool:
	var map: Map
	var pos: Vector2i
	if obj is Map:
		map = obj
		pos = position
	elif obj is Location:
		map = obj.map
		pos = obj.position
	elif obj is MapObject:
		map = obj.location.map
		pos = obj.location.position
	else:
		return false
	return map.is_in_bounds(pos.x, pos.y) and map.get_tile_at(pos.x, pos.y).is_visited


func is_player_sleeping() -> bool:
	return player != null and player.is_sleeping
#endregion

#region Text helpers
func find_longest_line(lines: Array) -> int:
	if lines == null or lines.is_empty():
		return 0

	var max_len := -2147483648

	for s in lines:
		if s == null:  # sanity check.
			continue
		if s.length() > max_len:
			max_len = s.length()

	return max_len
#endregion


# --- Game loading & saving (RogueGame.cs ~19723) ---

func handle_save_game() -> void:
	# alpha10.1: manually saving the game delays (reschedules) the next autosave
	schedule_next_auto_save()
	do_save_game(get_user_save())


# alpha10.1
func check_auto_save_time() -> void:
	# sanity checks
	if not is_game_running or player == null or player.is_dead:
		return
	# option off?
	if options.auto_save_period_in_hours <= 0:
		return
	# not time yet?
	if session.world_time.turn_counter < session.next_auto_save_time:
		return
	# autosave now and reschedule
	schedule_next_auto_save()
	# TODO: OverlayPopup not ported yet (Overlays region ~452-644)
	# var popup := OverlayPopup.new(["AUTOSAVING..."], Color.YELLOW, Color.WHITE, Color.BLACK, map_to_screen(player.location.position.x, player.location.position.y))
	# add_overlay(popup)
	do_save_game(get_user_save(), true)
	# remove_overlay(popup)
	redraw_play_screen()


# alpha10.1
func schedule_next_auto_save() -> void:
	session.next_auto_save_time = session.world_time.turn_counter + WorldTime.TURNS_PER_HOUR * options.auto_save_period_in_hours


func handle_load_game() -> void:
	do_load_game(get_user_save())


# alpha10.1 messages modified for autosave
# alpha10.1 start & stop sim thread here instead of caller
func do_save_game(save_name: String, is_auto_save: bool = false) -> void:
	stop_sim_thread(false)  # alpha10.1 (no-op in the Godot port, no background sim thread)
	var saving_or_autosaving: String = "AUTOSAVING" if is_auto_save else "SAVING"
	clear_messages()
	add_message(Message.new("%s GAME, PLEASE WAIT..." % saving_or_autosaving, session.world_time.turn_counter, Color.YELLOW))
	redraw_play_screen()
	ui.ui_repaint()
	# save session object
	Session.save(session, save_name, Session.SaveFormat.FORMAT_BIN)
	add_message(Message.new("%s DONE." % saving_or_autosaving, session.world_time.turn_counter, Color.YELLOW))
	redraw_play_screen()
	ui.ui_repaint()
	start_sim_thread()  # alpha10.1 (no-op in the Godot port)


# alpha10.1 start & stop sim thread here instead of caller
func do_load_game(save_name: String) -> void:
	stop_sim_thread(false)  # alpha10.1 (no-op in the Godot port)
	clear_messages()
	add_message(Message.new("LOADING GAME, PLEASE WAIT...", session.world_time.turn_counter, Color.YELLOW))
	redraw_play_screen()
	ui.ui_repaint()
	if not load_game(save_name):
		add_message(Message.new("LOADING FAILED, NO GAME SAVED OR VERSION NOT COMPATIBLE.", session.world_time.turn_counter, Color.RED))
	start_sim_thread()  # alpha10.1 (no-op in the Godot port)


func delete_saved_game(save_name: String) -> void:
	# do it
	if Session.delete(save_name):
		# tell
		add_message(Message.new("PERMADEATH : SAVE GAME DELETED!", session.world_time.turn_counter, Color.RED))


func load_game(save_name: String) -> bool:
	# load session object
	var loaded: bool = Session.load(save_name, Session.SaveFormat.FORMAT_BIN)
	if not loaded:
		return false
	session = Session.get_session()
	rules = Rules.new(DiceRoller.new(session.seed))
	refresh_player()
	add_message(Message.new("LOADING DONE.", session.world_time.turn_counter, Color.YELLOW))
	add_message(Message.new("Welcome back to Rogue Survivor!", session.world_time.turn_counter, Color.LIGHT_GREEN))
	redraw_play_screen()
	ui.ui_repaint()
	# Log ;/
	session.scoring.add_event(session.world_time.turn_counter, "<Loaded game>")
	return true


# --- Options loading, saving & applying ---

func load_options() -> void:
	# load
	options = GameOptions.load_options(get_user_options_file_path())


func save_options() -> void:
	# save
	GameOptions.save(options, get_user_options_file_path())


func apply_options(_ingame: bool) -> void:
	if music_manager != null:
		music_manager.is_music_enabled = options.play_music
		music_manager.volume = options.music_volume
	# update difficulty
	if session != null and session.scoring != null:
		session.scoring.side = Scoring.DifficultySide.FOR_SURVIVOR if (player == null or not player.model.abilities.is_undead) else Scoring.DifficultySide.FOR_UNDEAD
		session.scoring.difficulty_rating = Scoring.compute_difficulty_rating(options, session.scoring.side, session.scoring.reincarnation_number)
	if music_manager != null and not music_manager.is_music_enabled:
		music_manager.stop()


# --- Keybindings loading & saving ---

func load_keybindings() -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading keybindings...", 0, 0)
	ui.ui_repaint()
	# Godot port: Keybindings uses a fixed user:// path (see keybindings.gd SAVE_PATH)
	key_bindings = Keybindings.load_bindings()
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading keybindings... done!", 0, 0)
	ui.ui_repaint()


func save_keybindings() -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Saving keybindings...", 0, 0)
	ui.ui_repaint()
	key_bindings.save()
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Saving keybindings... done!", 0, 0)
	ui.ui_repaint()


# --- Hints saving & loading ---

func load_hints() -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading hints...", 0, 0)
	ui.ui_repaint()
	hints = GameHintsStatus.load_file(get_user_config_path() + "hints.dat")
	if hints == null:
		hints = GameHintsStatus.new()
		hints.reset_all_hints()
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading hints... done!", 0, 0)
	ui.ui_repaint()


func save_hints() -> void:
	GameHintsStatus.save(hints, get_user_config_path() + "hints.dat")

# --- Menu helpers (RogueGame.cs ~19940) ---

## Draws a menu/options list. Returns the updated gy (C# ref int gy).
func draw_menu_or_options(current_choice: int, entries_color: Color, entries: PackedStringArray, values_color: Color, values, gx: int, gy: int, values_on_new_line: bool = false, right_padding: int = 256) -> int:
	var right: int = gx + right_padding
	if values != null and entries.size() != values.size():
		push_error("values length != choices length")
	# display
	var entries_shadow_color := Color(entries_color.r / 2.0, entries_color.g / 2.0, entries_color.b / 2.0, entries_color.a)
	for i in entries.size():
		var choice_str: String
		if i == current_choice:
			choice_str = "---> %s" % entries[i]
		else:
			choice_str = "     %s" % entries[i]
		ui.ui_draw_string_bold(entries_color, choice_str, gx, gy, entries_shadow_color)
		if values != null:
			var value_str: String
			if i == current_choice and not values_on_new_line:
				value_str = "%s <---" % values[i]
			else:
				value_str = values[i]
			if values_on_new_line:
				gy += BOLD_LINE_SPACING
				ui.ui_draw_string_bold(values_color, value_str, gx + right, gy)
			else:
				ui.ui_draw_string_bold(values_color, value_str, right, gy)
		gy += BOLD_LINE_SPACING
	return gy


# --- Drawing headers & footnotes ---

func draw_header() -> void:
	# TODO: SetupConfig.GAME_VERSION -> literal port value
	ui.ui_draw_string_bold(Color.RED, "ROGUE SURVIVOR - " + "alpha 10.1", 0, 0, Color.DARK_RED)


func draw_footnote(color: Color, text: String) -> void:
	var shadow_color := Color(color.r / 2.0, color.g / 2.0, color.b / 2.0, color.a)
	ui.ui_draw_string_bold(color, "<%s>" % text, 0, CANVAS_HEIGHT - BOLD_LINE_SPACING, shadow_color)


# --- Game user data paths ---

static func get_user_base_path() -> String:
	# Godot port: use the user:// data directory (C# used MyDocuments\Rogue Survivor\<version>\)
	return "user://"


static func get_user_saves_path() -> String:
	return get_user_base_path() + "Saves/"


static func get_user_save() -> String:
	return get_user_saves_path() + "save.dat"


static func get_user_docs_path() -> String:
	return get_user_base_path() + "Docs/"


static func get_user_graveyard_path() -> String:
	return get_user_base_path() + "Graveyard/"


## "grave_[id]"
func get_user_new_graveyard_name() -> String:
	var name: String
	var i: int = 0
	var is_free_id: bool = false
	while not is_free_id:
		name = "grave_%03d" % i
		is_free_id = not FileAccess.file_exists(grave_file_path(name))
		i += 1
	return name


static func grave_file_path(grave_name: String) -> String:
	return get_user_graveyard_path() + grave_name + ".txt"


static func get_user_config_path() -> String:
	return get_user_base_path() + "Config/"


static func get_user_options_file_path() -> String:
	return get_user_config_path() + "options.dat"


static func get_user_screenshots_path() -> String:
	return get_user_base_path() + "Screenshots/"


## "screenshot_[id]"
func get_user_new_screenshot_name() -> String:
	var name: String
	var i: int = 0
	var is_free_id: bool = false
	while not is_free_id:
		name = "screenshot_%03d" % i
		is_free_id = not FileAccess.file_exists(screenshot_file_path(name))
		i += 1
	return name


func screenshot_file_path(shotname: String) -> String:
	return get_user_screenshots_path() + shotname + "." + ui.ui_screenshot_extension()


func create_directory(path: String) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
		return true
	return false


## Returns {"created": bool, "gy": int} (C# ref int gy).
func check_directory(path: String, description: String, gy: int) -> Dictionary:
	ui.ui_draw_string(Color.WHITE, "%s : %s..." % [description, path], 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()
	var created: bool = create_directory(path)
	ui.ui_draw_string(Color.WHITE, "ok.", 0, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_repaint()
	return {"created": created, "gy": gy}


func check_copy_of_manual() -> bool:
	# TODO: the manual was not copied into godot/assets; expected at res://assets/Manual/RS Manual.txt
	var src_path := "res://assets/Manual/"
	var dst_path := get_user_docs_path()
	var filename := "RS Manual.txt"
	# copy file
	var copied: bool = false
	if not FileAccess.file_exists(dst_path + filename):
		copied = true
		DirAccess.copy_absolute(src_path + filename, dst_path + filename)
	return copied


func get_user_manual_file_path() -> String:
	return get_user_docs_path() + "RS Manual.txt"


func get_user_hi_score_path() -> String:
	return get_user_saves_path()


func get_user_hi_score_file_path() -> String:
	return get_user_hi_score_path() + "hiscores.dat"


func get_user_hi_score_text_file_path() -> String:
	return get_user_hi_score_path() + "hiscores.txt"


# --- Generating world (RogueGame.cs ~20160) ---

func generate_world(is_verbose: bool, size: int) -> void:
	# say so
	if is_verbose:
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.WHITE, "Generating game world...", 0, 0)
		ui.ui_repaint()
	# Create blank world
	if is_verbose:
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.WHITE, "Creating empty world...", 0, 0)
		ui.ui_repaint()
	session.world = World.new(size)
	var world: World = session.world
	# Roll initial weather
	world.weather = rules.roll(Weather._FIRST, Weather._COUNT)  # alpha10
	world.next_weather_check_turn = rules.roll(WEATHER_MIN_DURATION, WEATHER_MAX_DURATION)  # alpha10
	# Roll locations of special buildings. Only ONE special building max per district.
	var no_special_districts: Array = []
	for x in world.size:
		for y in world.size:
			no_special_districts.append(Vector2i(x, y))
	var police_station_district_pos: Vector2i = no_special_districts[rules.roll(0, no_special_districts.size())]
	no_special_districts.erase(police_station_district_pos)
	var hospital_district_pos: Vector2i = no_special_districts[rules.roll(0, no_special_districts.size())]
	no_special_districts.erase(hospital_district_pos)
	# Create districts maps: Surface, Sewers and Subways
	for x in world.size:
		for y in world.size:
			if is_verbose:
				ui.ui_clear(Color.BLACK)
				ui.ui_draw_string_bold(Color.WHITE, "Creating District@%s..." % World.coord_to_string(x, y), 0, 0)
				ui.ui_repaint()
			# create the district
			var district := District.new(Vector2i(x, y), generate_district_kind(world, x, y))
			world.set_district(x, y, district)
			# create the entry map
			district.entry_map = generate_district_entry_map(world, district, police_station_district_pos, hospital_district_pos)
			district.name = district.entry_map.name
			# create other maps: sewers
			var sewers: Map = generate_district_sewers_map(district)
			district.sewers_map = sewers
			# subway (only in the middle district line)
			if y == world.size / 2:
				var subway_map: Map = generate_district_subway_map(district)
				district.subway_map = subway_map
	# Unique maps
	if is_verbose:
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.WHITE, "Generating unique maps...", 0, 0)
		ui.ui_repaint()
	session.unique_maps.char_underground_facility = create_unique_map_char_undeground_facility(world)
	# Unique actors
	if is_verbose:
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.WHITE, "Generating unique actors...", 0, 0)
		ui.ui_repaint()
	# "Sewers Thing" - in one of the sewers
	session.unique_actors.the_sewers_thing = spawn_unique_sewers_thing(world)
	# Unique survivors NPCs
	session.unique_actors.big_bear = create_unique_big_bear(world)
	session.unique_actors.famu_fataru = create_unique_famu_fataru(world)
	session.unique_actors.santaman = create_unique_santaman(world)
	session.unique_actors.roguedjack = create_unique_roguedjack(world)
	session.unique_actors.duckman = create_unique_duckman(world)
	session.unique_actors.hans_von_hanz = create_unique_hans_von_hanz(world)
	# alpha10: make all uniques npcs invincible until spotted
	for unique_actor in session.unique_actors.to_array():
		unique_actor.the_actor.is_invincible = true
	# Unique items
	# "Subway Worker Badge" - somewhere on the subway tracks
	session.unique_items.the_subway_worker_badge = spawn_unique_subway_worker_badge(world)
	# Link districts
	for x in world.size:
		for y in world.size:
			if is_verbose:
				ui.ui_clear(Color.BLACK)
				ui.ui_draw_string_bold(Color.WHITE, "Linking District@%s..." % World.coord_to_string(x, y), 0, 0)
				ui.ui_repaint()
			# Entry maps (surface): add exits (from and to)
			var map: Map = world.get_district(x, y).entry_map
			if y > 0:
				# north
				var to_map: Map = world.get_district(x, y - 1).entry_map
				for from_x in map.width:
					var to_x: int = from_x
					if to_x >= to_map.width:
						continue
					# link?
					if rules.roll_chance(DISTRICT_EXIT_CHANCE_PER_TILE):
						var pt_map_from := Vector2i(from_x, -1)
						var pt_map_to := Vector2i(from_x, to_map.height - 1)
						var pt_from_map_from := Vector2i(from_x, to_map.height)
						var pt_from_map_to := Vector2i(from_x, 0)
						if check_if_exit_is_good(map, pt_map_from, to_map, pt_map_to) and check_if_exit_is_good(to_map, pt_from_map_from, map, pt_from_map_to):
							generate_exit(map, pt_map_from, to_map, pt_map_to)
							generate_exit(to_map, pt_from_map_from, map, pt_from_map_to)
			if x > 0:
				# west
				var to_map_w: Map = world.get_district(x - 1, y).entry_map
				for from_y in map.height:
					var to_y: int = from_y
					if to_y >= to_map_w.height:
						continue
					# link?
					if rules.roll_chance(DISTRICT_EXIT_CHANCE_PER_TILE):
						var pt_map_from := Vector2i(-1, from_y)
						var pt_map_to := Vector2i(to_map_w.width - 1, from_y)
						var pt_from_map_from := Vector2i(to_map_w.width, from_y)
						var pt_from_map_to := Vector2i(0, from_y)
						if check_if_exit_is_good(map, pt_map_from, to_map_w, pt_map_to) and check_if_exit_is_good(to_map_w, pt_from_map_from, map, pt_from_map_to):
							generate_exit(map, pt_map_from, to_map_w, pt_map_to)
							generate_exit(to_map_w, pt_from_map_from, map, pt_from_map_to)
			# Sewers
			map = world.get_district(x, y).sewers_map
			if y > 0:
				# north
				var to_map_s: Map = world.get_district(x, y - 1).sewers_map
				for from_x in map.width:
					var to_x: int = from_x
					if to_x >= to_map_s.width:
						continue
					generate_exit(map, Vector2i(from_x, -1), to_map_s, Vector2i(from_x, to_map_s.height - 1))
					generate_exit(to_map_s, Vector2i(from_x, to_map_s.height), map, Vector2i(from_x, 0))
			if x > 0:
				# west
				var to_map_sw: Map = world.get_district(x - 1, y).sewers_map
				for from_y in map.height:
					var to_y: int = from_y
					if to_y >= to_map_sw.height:
						continue
					generate_exit(map, Vector2i(-1, from_y), to_map_sw, Vector2i(to_map_sw.width - 1, from_y))
					generate_exit(to_map_sw, Vector2i(to_map_sw.width, from_y), map, Vector2i(0, from_y))
			# Subways
			map = world.get_district(x, y).subway_map
			if map != null:
				if x > 0:
					# west
					var to_map_sub: Map = world.get_district(x - 1, y).subway_map
					for from_y in map.height:
						var to_y: int = from_y
						if to_y >= to_map_sub.height:
							continue
						if not map.is_walkable(map.width - 1, from_y):
							continue
						if not to_map_sub.is_walkable(0, from_y):
							continue
						generate_exit(map, Vector2i(-1, from_y), to_map_sub, Vector2i(to_map_sub.width - 1, from_y))
						generate_exit(to_map_sub, Vector2i(to_map_sub.width, from_y), map, Vector2i(0, from_y))
	# Easter egg: "roguedjack was here" tag
	var easter_egg_tag_map: Map = world.get_district(0, 0).sewers_map
	easter_egg_tag_map.remove_map_object_at(1, 1)
	easter_egg_tag_map.get_tile_at(1, 1).remove_all_decorations()
	easter_egg_tag_map.get_tile_at(1, 1).add_decoration(GameImages.DECO_ROGUEDJACK_TAG)
	# Spawn player on center map
	if is_verbose:
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.WHITE, "Spawning player...", 0, 0)
		ui.ui_repaint()
	var grid_center: int = world.size / 2
	var start_map: Map = world.get_district(grid_center, grid_center).entry_map
	generate_player_on_map(start_map, town_generator)
	set_current_map(start_map)
	refresh_player()
	update_player_fov(player)  # to make sure we get notified of actors acting before us in turn 0
	# #if DEBUG block skipped (AddDevCheatItems/AddDevCheatSkills/AddDevMiscStuff)
	# Reveal starting map?
	if options.reveal_starting_district:
		var start_zones: Array = start_map.get_zones_at(player.location.position.x, player.location.position.y)
		if start_zones != null:
			var start_zone: Zone = start_zones[0]
			for x in start_map.width:
				for y in start_map.height:
					var reveal_this_tile: bool = false
					# reveal if starting zone (house) or outside
					var zones: Array = start_map.get_zones_at(x, y)
					if zones != null and zones[0] == start_zone:
						reveal_this_tile = true
					elif not start_map.get_tile_at(x, y).is_inside:
						reveal_this_tile = true
					if reveal_this_tile:
						start_map.get_tile_at(x, y).is_visited = true
	# Done
	if is_verbose:
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.WHITE, "Generating game world... done!", 0, 0)
		ui.ui_repaint()


func check_if_exit_is_good(_from_map: Map, _from: Vector2i, to_map: Map, to: Vector2i) -> bool:
	# don't if tile not walkable or map object there
	if not to_map.get_tile_at(to.x, to.y).model.is_walkable:
		return false
	if to_map.get_map_object_at_xy(to.x, to.y) != null:
		return false
	# good spot
	return true


func generate_exit(from_map: Map, from: Vector2i, to_map: Map, to: Vector2i) -> void:
	# add exit
	from_map.set_exit_at(from, Map.Exit.new(to_map, to))


# --- Uniques (RogueGame.cs ~20520) ---

func spawn_unique_sewers_thing(world: World) -> Session.UniqueActor:
	# 1. Pick a random sewers map
	var map: Map = world.get_district(rules.roll(0, world.size), rules.roll(0, world.size)).sewers_map
	# 2. Create Sewers Thing
	var model: ActorModel = game_actors.sewers_thing()
	var actor: Actor = model.create_named(game_factions.the_undeads(), "The Sewers Thing", false, 0)
	# 3. Spawn in sewers map
	var roller := DiceRoller.new(map.seed)
	var spawned: bool = town_generator.actor_place(roller, 10000, map, actor)
	if not spawned:
		push_error("could not spawn unique The Sewers Thing")
	# 4. Add warning board in maintenance rooms (if any)
	var maintenance_zone: Zone = map.get_zone_by_partial_name(NAME_SEWERS_MAINTENANCE)
	if maintenance_zone != null:
		town_generator.map_object_place_in_good_position_rect(map, maintenance_zone.bounds,
			func(pt: Vector2i) -> bool:
				return map.is_walkable(pt.x, pt.y) and map.get_actor_at(pt) == null and map.get_items_at(pt) == null,
			roller,
			func(_pt: Vector2i) -> Board:
				return town_generator.make_obj_board(GameImages.OBJ_BOARD, PackedStringArray([
					"TO SEWER WORKERS :",
					"- It lives here.",
					"- Do not disturb.",
					"- Approach with caution.",
					"- Watch your back.",
					"- In case of emergency, take refuge here.",
					"- Do not let other people interact with it!"])))
	# done
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = true
	return u


func create_unique_big_bear(_world: World) -> Session.UniqueActor:
	var model: ActorModel = game_actors.male_civilian()
	var actor: Actor = model.create_named(game_factions.the_civilians(), "Big Bear", false, 0)
	actor.is_unique = true
	actor.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_BIG_BEAR)
	for i in 3:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HAULER)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HARDY)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.STRONG)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.TOUGH)
	var bat := ItemMeleeWeapon.new(game_items.unique_bigbear_bat())
	bat.is_unique = true
	actor.inventory.add_all(bat)
	for i in 5:
		actor.inventory.add_all(town_generator.make_item_canned_food())
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = false
	u.is_with_refugees = true
	u.event_message = "You hear an angry man shouting 'FOOLS!'"
	u.event_theme_music = GameMusics.BIGBEAR_THEME_SONG
	return u


func create_unique_famu_fataru(_world: World) -> Session.UniqueActor:
	var model: ActorModel = game_actors.female_civilian()
	var actor: Actor = model.create_named(game_factions.the_civilians(), "Famu Fataru", false, 0)
	actor.is_unique = true
	actor.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_FAMU_FATARU)
	for i in 3:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HAULER)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HARDY)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.AGILE)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HIGH_STAMINA)
	var katana := ItemMeleeWeapon.new(game_items.unique_famu_fataru_katana())
	katana.is_unique = true
	actor.inventory.add_all(katana)
	for i in 5:
		actor.inventory.add_all(town_generator.make_item_canned_food())
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = false
	u.is_with_refugees = true
	u.event_message = "You hear a woman laughing."
	u.event_theme_music = GameMusics.FAMU_FATARU_THEME_SONG
	return u


func create_unique_santaman(_world: World) -> Session.UniqueActor:
	var model: ActorModel = game_actors.male_civilian()
	var actor: Actor = model.create_named(game_factions.the_civilians(), "Santaman", false, 0)
	actor.is_unique = true
	actor.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_SANTAMAN)
	for i in 3:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HAULER)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HARDY)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.AWAKE)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.FIREARMS)
	var shotty := ItemRangedWeapon.new(game_items.unique_santaman_shotgun())
	shotty.is_unique = true
	actor.inventory.add_all(shotty)
	for i in 3:
		actor.inventory.add_all(town_generator.make_item_shotgun_ammo())
	for i in 2:
		actor.inventory.add_all(town_generator.make_item_canned_food())
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = false
	u.is_with_refugees = true
	u.event_message = "You hear christmas music and drunken vomitting."
	u.event_theme_music = GameMusics.SANTAMAN_THEME_SONG
	return u


func create_unique_roguedjack(_world: World) -> Session.UniqueActor:
	var model: ActorModel = game_actors.male_civilian()
	var actor: Actor = model.create_named(game_factions.the_civilians(), "Roguedjack", false, 0)
	actor.is_unique = true
	actor.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_ROGUEDJACK)
	for i in 3:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HAULER)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HARDY)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.LEADERSHIP)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.CHARISMATIC)
	var basher := ItemMeleeWeapon.new(game_items.unique_roguedjack_keyboard())
	basher.is_unique = true
	actor.inventory.add_all(basher)
	for i in 5:
		actor.inventory.add_all(town_generator.make_item_canned_food())
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = false
	u.is_with_refugees = true
	u.event_message = "You hear a man shouting in French."
	u.event_theme_music = GameMusics.ROGUEDJACK_THEME_SONG
	return u


func create_unique_duckman(_world: World) -> Session.UniqueActor:
	var model: ActorModel = game_actors.male_civilian()
	var actor: Actor = model.create_named(game_factions.the_civilians(), "Duckman", false, 0)
	actor.is_unique = true
	actor.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_DUCKMAN)
	# awesome superhero!
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.CHARISMATIC)
	for i in 1:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.LEADERSHIP)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.STRONG)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HIGH_STAMINA)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.MARTIAL_ARTS)
	for i in 6:
		actor.inventory.add_all(town_generator.make_item_canned_food())
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = false
	u.is_with_refugees = true
	u.event_message = "You hear loud demented QUACKS."
	u.event_theme_music = GameMusics.DUCKMAN_THEME_SONG
	return u


func create_unique_hans_von_hanz(_world: World) -> Session.UniqueActor:
	var model: ActorModel = game_actors.male_civilian()
	var actor: Actor = model.create_named(game_factions.the_civilians(), "Hans von Hanz", false, 0)
	actor.is_unique = true
	actor.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_HANS_VON_HANZ)
	for i in 3:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.HAULER)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.FIREARMS)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.LEADERSHIP)
	for i in 5:
		town_generator.give_starting_skill_to_actor(actor, Skills.IDs.NECROLOGY)
	var pistol := ItemRangedWeapon.new(game_items.unique_hans_von_hanz_pistol())
	pistol.is_unique = true
	actor.inventory.add_all(pistol)
	for i in 5:
		actor.inventory.add_all(town_generator.make_item_canned_food())
	var u := Session.UniqueActor.new()
	u.the_actor = actor
	u.is_spawned = false
	u.is_with_refugees = true
	u.event_message = "You hear a man barking orders in German."
	u.event_theme_music = GameMusics.HANS_VON_HANZ_THEME_SONG
	return u


func spawn_unique_subway_worker_badge(world: World) -> Session.UniqueItem:
	# 1. Pick a random Subway map. Fails if not found.
	# 2. Pick a position in the rails.
	# 3. Drop it.
	var it := Item.new(game_items.unique_subway_badge())
	it.is_unique = true
	it.is_forbidden_to_ai = true
	# 1. Pick a random Subway map
	var all_subways: Array = []
	for x in world.size:
		for y in world.size:
			if world.get_district(x, y).has_subway():
				all_subways.append(world.get_district(x, y).subway_map)
	if all_subways.is_empty():
		var u0 := Session.UniqueItem.new()
		u0.the_item = it
		u0.is_spawned = false
		return u0
	var subway: Map = all_subways[rules.roll(0, all_subways.size())]
	# 2. Pick a position in the rails
	var rails_rect: Rect2i = subway.get_zone_by_partial_name(NAME_SUBWAY_RAILS).bounds
	var drop_pt := Vector2i(rules.roll(rails_rect.position.x, rails_rect.position.x + rails_rect.size.x), rules.roll(rails_rect.position.y, rails_rect.position.y + rails_rect.size.y))
	# 3. Drop it
	subway.drop_item_at(it, drop_pt)
	# blood! deceased worker.
	subway.get_tile_at(drop_pt.x, drop_pt.y).add_decoration(GameImages.DECO_BLOODIED_FLOOR)
	# done
	var u := Session.UniqueItem.new()
	u.the_item = it
	u.is_spawned = true
	return u


func create_unique_map_char_undeground_facility(world: World) -> Session.UniqueMap:
	# 1. Find all business districts with offices.
	# 2. Pick one business district at random.
	# 3. Generate underground map there.
	# 1. Find all business districts with offices
	var good_districts: Array = []
	for x in world.size:
		for y in world.size:
			if world.get_district(x, y).kind == District.DistrictKind.BUSINESS:
				var has_office: bool = false
				for z in world.get_district(x, y).entry_map.zones:
					if z.has_game_attribute(ZoneAttributes.IS_CHAR_OFFICE):
						has_office = true
						break
				if has_office:
					good_districts.append(world.get_district(x, y))
	# 2. Pick one business district at random
	if good_districts.is_empty():
		push_error("world has no business districts with offices")
	var chosen_district: District = good_districts[rules.roll(0, good_districts.size())]
	# 3. Generate underground map there
	var offices: Array = []
	for z in chosen_district.entry_map.zones:
		if z.has_game_attribute(ZoneAttributes.IS_CHAR_OFFICE):
			offices.append(z)
	var chosen_office: Zone = offices[rules.roll(0, offices.size())]
	var gen_result: Dictionary = town_generator.generate_unique_map_char_underground(chosen_district.entry_map, chosen_office)
	var map: Map = gen_result["map"]
	var base_entry_pos: Vector2i = gen_result["base_entry_pos"]  # alpha10
	map.district = chosen_district
	map.name = "CHAR Underground Facility @%d-%d" % [base_entry_pos.x, base_entry_pos.y]  # alpha10
	chosen_district.add_unique_map(map)
	var um := Session.UniqueMap.new()
	um.the_map = map
	return um


# --- District maps (RogueGame.cs ~20948) ---

func generate_district_kind(_world: World, grid_x: int, grid_y: int) -> int:
	# Decide district kind - some districts are hardcoded: (0,0) is always Business
	if grid_x == 0 and grid_y == 0:
		return District.DistrictKind.BUSINESS
	return rules.roll(District.DistrictKind._FIRST, District.DistrictKind._COUNT)


func generate_district_entry_map(world: World, district: District, police_station_district_pos: Vector2i, hospital_district_pos: Vector2i) -> Map:
	var grid_x: int = district.world_position.x
	var grid_y: int = district.world_position.y
	# 1. Compute unique seed
	var grid_seed: int = session.seed + grid_y * world.size + grid_x
	# 2. Set gen params
	var gen_params: Dictionary = BaseTownGenerator.DEFAULT_PARAMS.duplicate()
	gen_params["map_width"] = options.district_size
	gen_params["map_height"] = options.district_size
	gen_params["district"] = district
	var factor: int = 8
	var kind_name: String = "District"
	match district.kind:
		District.DistrictKind.SHOPPING:
			# more shops, less other types
			kind_name = "Shopping District"
			gen_params["char_building_chance"] /= factor
			gen_params["shop_building_chance"] *= factor
			gen_params["park_building_chance"] /= factor
		District.DistrictKind.GREEN:
			# more parks, less other types
			kind_name = "Green District"
			gen_params["char_building_chance"] /= factor
			gen_params["park_building_chance"] *= factor
			gen_params["shop_building_chance"] /= factor
		District.DistrictKind.BUSINESS:
			# more offices, less other types
			kind_name = "Business District"
			gen_params["char_building_chance"] *= factor
			gen_params["park_building_chance"] /= factor
			gen_params["shop_building_chance"] /= factor
		District.DistrictKind.RESIDENTIAL:
			# more housings, less other types
			kind_name = "Residential District"
			gen_params["char_building_chance"] /= factor
			gen_params["park_building_chance"] /= factor
			gen_params["shop_building_chance"] /= factor
		District.DistrictKind.GENERAL:
			# use default params
			kind_name = "District"
		_:
			push_error("unhandled district kind")
	# Special params
	gen_params["generate_police_station"] = district.world_position == police_station_district_pos
	gen_params["generate_hospital"] = district.world_position == hospital_district_pos
	# 3. Generate map
	var prev_params: Dictionary = town_generator.params
	town_generator.params = gen_params
	var map: Map = town_generator.generate(grid_seed)
	map.name = "%s@%s" % [kind_name, World.coord_to_string(grid_x, grid_y)]
	town_generator.params = prev_params
	return map


func generate_district_sewers_map(district: District) -> Map:
	# Compute unique seed
	var sewers_seed: int = (district.entry_map.seed << 1) ^ district.entry_map.seed
	# Generate map
	var sewers: Map = town_generator.generate_sewers_map(sewers_seed, district)
	sewers.name = "Sewers@%d-%d" % [district.world_position.x, district.world_position.y]
	return sewers


func generate_district_subway_map(district: District) -> Map:
	# Compute unique seed
	var subway_seed: int = (district.entry_map.seed << 2) ^ district.entry_map.seed
	# Generate map
	var subway: Map = town_generator.generate_subway_map(subway_seed, district)
	subway.name = "Subway@%d-%d" % [district.world_position.x, district.world_position.y]
	return subway


func generate_player_on_map(map: Map, town_gen: BaseTownGenerator) -> void:
	var roller := DiceRoller.new(map.seed)
	# Create player actor : living/undead x male/female
	var player_model: ActorModel
	var new_player: Actor
	if char_gen.is_undead:
		# Handle specific undead type
		match char_gen.undead_model:
			GameActors.IDs.UNDEAD_SKELETON:
				# Create the Skeleton
				new_player = game_actors.skeleton().create_numbered_name(game_factions.the_undeads(), 0)
			GameActors.IDs.UNDEAD_ZOMBIE:
				# Create the Zombie
				new_player = game_actors.zombie().create_numbered_name(game_factions.the_undeads(), 0)
			GameActors.IDs.UNDEAD_MALE_ZOMBIFIED, GameActors.IDs.UNDEAD_FEMALE_ZOMBIFIED:
				# First create as living
				player_model = game_actors.male_civilian() if char_gen.is_male else game_actors.female_civilian()
				new_player = player_model.create_anonymous(game_factions.the_civilians(), 0)
				town_gen.dress_civilian(roller, new_player)
				town_gen.give_name_to_actor(roller, new_player)
				# Then zombify
				new_player = zombify(null, new_player, true)
			GameActors.IDs.UNDEAD_ZOMBIE_MASTER:
				# Create the ZM
				new_player = game_actors.zombie_master().create_numbered_name(game_factions.the_undeads(), 0)
			_:
				push_error("unhandled undead_model")
		# Then make sure player related stuff are setup properly
		prepare_actor_for_player_control(new_player)
	else:
		# Create living
		player_model = game_actors.male_civilian() if char_gen.is_male else game_actors.female_civilian()
		new_player = player_model.create_anonymous(game_factions.the_civilians(), 0)
		town_gen.dress_civilian(roller, new_player)
		town_gen.give_name_to_actor(roller, new_player)
		new_player.sheet.skill_table.add_or_increase_skill(char_gen.starting_skill)
		town_gen.recompute_actor_starting_stats(new_player)
		on_skill_upgrade(new_player, char_gen.starting_skill)
		# slightly randomize Food and Sleep - 0..25%
		var food_deviation: int = int(0.25 * new_player.food_points)
		new_player.food_points = new_player.food_points - rules.roll(0, food_deviation)
		var sleep_deviation: int = int(0.25 * new_player.sleep_points)
		new_player.sleep_points = new_player.sleep_points - rules.roll(0, sleep_deviation)
	new_player.controller = PlayerController.new()
	# Spawn him: living tries inside on a couch, then anywhere inside; undead outside.
	# NEVER spawn in CHAR Office!
	var prefered_spawn_ok: bool = town_gen.actor_place(roller, 10 * map.width * map.height, map, new_player,
		func(pt: Vector2i) -> bool:
			var is_inside: bool = map.get_tile_at(pt.x, pt.y).is_inside
			if (char_gen.is_undead and is_inside) or (not char_gen.is_undead and not is_inside):
				return false
			if is_in_char_office(Location.new(map, pt)):
				return false
			var map_obj: MapObject = map.get_map_object_at(pt)
			if char_gen.is_undead:
				return map_obj == null
			return map_obj != null and map_obj.is_couch)
	if not prefered_spawn_ok:
		# no couch, try inside but never in char office
		var spawned_inside: bool = town_gen.actor_place(roller, map.width * map.height, map, new_player,
			func(pt: Vector2i) -> bool:
				return map.get_tile_at(pt.x, pt.y).is_inside and not is_in_char_office(Location.new(map, pt)))
		if not spawned_inside:
			# could not spawn inside, do it outside
			while not town_gen.actor_place(roller, 2147483647, map, new_player,
				func(pt: Vector2i) -> bool:
					return not is_in_char_office(Location.new(map, pt))):
				pass


func refresh_player() -> void:
	# get player
	for a in session.current_map.actors_list:
		if a.is_player:
			player = a
			break
	# compute view
	if player != null:
		compute_view_rect(player.location.position)


func prepare_actor_for_player_control(new_player_avatar: Actor) -> void:
	# inventory && skills
	if new_player_avatar.inventory == null:
		new_player_avatar.inventory = Inventory.new(1)
	if new_player_avatar.sheet.skill_table == null:
		new_player_avatar.sheet.skill_table = SkillTable.new()
	# if follower, leave leader
	if new_player_avatar.leader != null:
		new_player_avatar.leader.remove_follower(new_player_avatar)


# --- Changing map & district (RogueGame.cs ~21217) ---

func set_current_map(map: Map) -> void:
	# set session field
	session.current_map = map
	# alpha10 update background music
	update_bg_music()


func on_player_leave_district() -> void:
	# remember when we left the district
	session.current_map.local_time.turn_counter = session.world_time.turn_counter


func before_player_enter_district(district: District) -> void:
	# get entry map
	var entry_map: Map = district.entry_map
	# get when we left the district
	var last_time: int = entry_map.local_time.turn_counter
	# if option set, simulate to catch current turn; otherwise just jump in time
	if options.is_sim_on:
		var catchup_to: int = session.world_time.turn_counter  # alpha10
		var turns_to_catchup: int = catchup_to - entry_map.local_time.turn_counter  # alpha10
		stop_sim_thread(false)  # alpha10 (no-op in the Godot port)
		if turns_to_catchup > 0:
			# music
			music_manager.stop()
			music_manager.play_looping(GameMusics.INTERLUDE, MusicPriority.PRIORITY_EVENT)
			# force player view to darkness (so he gets no messages)
			if player != null:
				player.location.map.clear_view()
				entry_map.clear_view()
			# simulate loop
			var timer_start: float = Time.get_ticks_msec()
			var last_redraw: float = 0
			var aborted: bool = false
			while entry_map.local_time.turn_counter < catchup_to:  # alpha10 changed from <= to <
				var timer_now: float = Time.get_ticks_msec()
				# time to redraw?
				var do_redraw: bool = (entry_map.local_time.turn_counter == session.world_time.turn_counter) or \
					(entry_map.local_time.turn_counter == last_time) or \
					(timer_now >= last_redraw + 1000)
				if do_redraw:
					last_redraw = timer_now
					# show
					clear_messages()
					add_message(Message.new("Simulating district, please wait %d/%d..." % [entry_map.local_time.turn_counter, session.world_time.turn_counter], session.world_time.turn_counter, Color.WHITE))
					add_message(Message.new("(this is an option you can tune)", session.world_time.turn_counter, Color.WHITE))
					# estimate turns per seconds and time left
					var turns_done: int = entry_map.local_time.turn_counter - last_time
					if turns_done > 1:
						var turns_left: int = session.world_time.turn_counter - entry_map.local_time.turn_counter
						var turns_per_secs: float = 1000.0 * turns_done / (1 + timer_now - timer_start)
						add_message(Message.new("Turns per second    : %.2f." % turns_per_secs, session.world_time.turn_counter, Color.WHITE))
						var secs_left: int = int(turns_left / turns_per_secs)
						var mins: int = secs_left / 60
						var secs: int = secs_left % 60
						var eta_format: String = ("%d min %02d secs" % [mins, secs]) if mins > 0 else ("%d secs" % secs)
						add_message(Message.new("Estimated time left : %s." % eta_format, session.world_time.turn_counter, Color.WHITE))
					if aborted:
						add_message(Message.new("Simulation aborted!", session.world_time.turn_counter, Color.RED))
					else:
						add_message(Message.new("<keep ESC pressed to abort the simulation>", session.world_time.turn_counter, Color.YELLOW))
					redraw_play_screen()
				# aborted?
				if aborted:
					break
				# check for abort
				var key: InputEventKey = ui.ui_peek_key()
				if key != null and key.keycode == KEY_ESCAPE:
					# jump in time for each map
					for m in district.maps:
						m.local_time.turn_counter = session.world_time.turn_counter
					# abort!
					aborted = true
				# if not aborted, simulate the district
				if not aborted:
					simulate_district(district)
			# Sim ends - either aborted or normal end
			# remove "ESC" message
			remove_last_message()
			# since sim arbitrary messes with actor APs, force them back to zero to have a clean start
			for m in district.maps:
				for a in m.actors_list:
					if not a.is_sleeping:
						a.action_points = 0
			# stop music
			music_manager.stop()
	else:
		# jump in time for each map
		for m in district.maps:
			m.local_time.turn_counter = session.world_time.turn_counter


# alpha10
func after_player_enter_district() -> void:
	# restart sim thread if on (no-op in the Godot port)
	if options.is_sim_on and options.sim_thread:
		start_sim_thread()


func on_player_change_map() -> void:
	refresh_player()


# --- Simulation (RogueGame.cs ~21392) ---

func compute_sim_flags_for_turn(turn: int) -> int:
	var lo_detail: bool = false
	match options.simulate_districts:
		GameOptions.SimRatio.FULL:
			lo_detail = false
		GameOptions.SimRatio.THREE_QUARTER:  # 3/4, skip 1 out of 4
			lo_detail = turn % 4 == 3
		GameOptions.SimRatio.TWO_THIRDS:  # 2/3, skip 1 out of 3
			lo_detail = turn % 3 == 2
		GameOptions.SimRatio.HALF:  # 1/2, skip 1 out of 2
			lo_detail = turn % 2 == 1
		GameOptions.SimRatio.ONE_THIRD:  # 1/3, play 1 out of 3
			lo_detail = turn % 3 != 0
		GameOptions.SimRatio.ONE_QUARTER:  # 1/4, play 1 out of 4
			lo_detail = turn % 4 != 0
		GameOptions.SimRatio.OFF:
			lo_detail = true
		_:
			push_error("unhandled simRatio")
	# NOTE: skeleton SimFlags renamed HIDETAIL_TURN -> NOT_SIMULATING
	return SimFlags.LODETAIL_TURN if lo_detail else SimFlags.NOT_SIMULATING


func simulate_district(d: District) -> void:
	advance_play_district(d, compute_sim_flags_for_turn(d.entry_map.local_time.turn_counter))


## Returns true if simulated a district; false if didn't need to simulate.
func simulate_nearby_districts(d: District) -> bool:
	var had_to_sim: bool = false
	var xmin: int = d.world_position.x - 1
	var xmax: int = d.world_position.x + 1
	var ymin: int = d.world_position.y - 1
	var ymax: int = d.world_position.y + 1
	var t_min := session.world.trim_to_bounds(Vector2i(xmin, ymin))
	xmin = t_min.x
	ymin = t_min.y
	var t_max := session.world.trim_to_bounds(Vector2i(xmax, ymax))
	xmax = t_max.x
	ymax = t_max.y
	for dx in range(xmin, xmax + 1):
		for dy in range(ymin, ymax + 1):
			# don't sim same district!
			if dx == d.world_position.x and dy == d.world_position.y:
				continue
			var other_district: District = session.world.get_district(dx, dy)
			# don't sim if up to date!
			var d_turns: int = d.entry_map.local_time.turn_counter - other_district.entry_map.local_time.turn_counter
			if d_turns > 0:
				# simulate district
				had_to_sim = true
				simulate_district(other_district)
	return had_to_sim


# --- Simulation Thread (RogueGame.cs ~21465) ---
# Accepted deviation (HANDOFF section 7): no background sim thread in the Godot
# port; the turn loop is main-thread. These are no-op stubs kept for call sites.

func start_sim_thread() -> void:
	pass


func stop_sim_thread(_abort: bool) -> void:
	pass


# --- Achievement banner (RogueGame.cs ~21577) ---

func show_new_achievement(id: int) -> void:
	# one more achievement
	session.scoring.completed_achievements_count += 1
	# get data
	var ach: Scoring.Achievement = session.scoring.get_achievement(id)
	var music_to_play: String = ach.music_id
	var title: String = ach.name
	var text: Array = ach.text
	# add event
	session.scoring.add_event(session.world_time.turn_counter, "** Achievement : %s for %d points. **" % [title, ach.score_value])
	# music
	music_manager.stop()
	music_manager.play(music_to_play, MusicPriority.PRIORITY_EVENT)
	# prepare banner
	var longest_line: int = find_longest_line(text)
	var stars_line: String = "*".repeat(maxi(longest_line, 50))
	var lines: Array = []
	lines.append(stars_line)
	lines.append("ACHIEVEMENT : %s" % title)
	lines.append("CONGRATULATIONS!")
	for i in text.size():
		lines.append(text[i])
	lines.append("Achievements : %d/%d." % [session.scoring.completed_achievements_count, Scoring.Achievement.IDs._COUNT])
	lines.append(stars_line)
	# banner
	# TODO: OverlayPopup not ported yet (Overlays region ~452-644)
	# add_overlay(OverlayPopup.new(lines, Color.GOLD, Color.GOLD, Color.DIM_GRAY, Vector2i(0, 0)))
	clear_messages()
	if not player.is_bot_player:
		add_message_press_enter()
	clear_overlays()


# --- Special player events (RogueGame.cs ~21660) ---

func show_special_dialogue(_speaker: Actor, _text: Array) -> void:
	# music
	music_manager.stop()
	music_manager.play(GameMusics.INTERLUDE, MusicPriority.PRIORITY_EVENT)
	# overlays
	# TODO: OverlayPopup/OverlayRect not ported yet (Overlays region ~452-644)
	# add_overlay(OverlayPopup.new(text, Color.GOLD, Color.GOLD, Color.DIM_GRAY, Vector2i(0, 0)))
	# add_overlay(OverlayRect.new(Color.YELLOW, Rect2i(map_to_screen(speaker.location.position), Vector2i(TILE_SIZE, TILE_SIZE))))
	# message & wait enter
	clear_messages()
	if not player.is_bot_player:
		add_message_press_enter()
	clear_overlays()  # alpha10 fix
	music_manager.stop()


func check_special_player_events_after_action(p_player: Actor) -> void:
	# Special events - limited to some factions/actors:
	# 1. Breaking into CHAR office for the 1st time
	# 2. Visiting CHAR Underground facility for the 1st time
	# 3. Sighting The Sewers Thing
	# 4. Police Station script
	# 5. Sighting Jason Myers
	# 6. Sighting Duckman (alpha10 disabled)
	# Generic 1st time flags: 1. visiting a new map 2. sighting an actor
	# Item interactions: 1. Subway Worker Badge in Subway maps
	# 1. Breaking into CHAR office for the 1st time: !undead !char
	if not p_player.model.abilities.is_undead and p_player.faction != game_factions.the_char_corporation():
		if not session.scoring.has_completed_achievement(Scoring.Achievement.IDs.CHAR_BROKE_INTO_OFFICE):
			if is_in_char_office(p_player.location):
				# completed
				session.scoring.set_completed_achievement(Scoring.Achievement.IDs.CHAR_BROKE_INTO_OFFICE)
				# achievement!
				show_new_achievement(Scoring.Achievement.IDs.CHAR_BROKE_INTO_OFFICE)
	# 2. Visiting CHAR Underground facility for the 1st time
	if not session.scoring.has_completed_achievement(Scoring.Achievement.IDs.CHAR_FOUND_UNDERGROUND_FACILITY):
		if p_player.location.map == session.unique_maps.char_underground_facility.the_map:
			# completed
			session.scoring.set_completed_achievement(Scoring.Achievement.IDs.CHAR_FOUND_UNDERGROUND_FACILITY)
			# achievement!
			show_new_achievement(Scoring.Achievement.IDs.CHAR_FOUND_UNDERGROUND_FACILITY)
			# make sure the player knows about it now and it is activated
			session.player_knows_char_underground_facility_location = true
			session.char_underground_facility_activated = true
			session.unique_maps.char_underground_facility.the_map.is_secret = false
			# open the exit to and from surface for AIs
			var surface_map: Map = session.unique_maps.char_underground_facility.the_map.district.entry_map
			var surface_entry = surface_map.find_first_in_map(func(pt: Vector2i) -> bool:
				var e = surface_map.get_exit_at(pt)
				if e == null:
					return false
				return e.to_map == session.unique_maps.char_underground_facility.the_map)
			if surface_entry == null:
				push_error("could not find exit to CUF in surface map")
			var to_cuf = surface_map.get_exit_at(surface_entry)
			to_cuf.is_an_ai_exit = true
			var cuf_exit = session.unique_maps.char_underground_facility.the_map.find_first_in_map(func(pt: Vector2i) -> bool:
				var e = session.unique_maps.char_underground_facility.the_map.get_exit_at(pt)
				if e == null:
					return false
				return e.to_map == surface_map)
			if cuf_exit == null:
				push_error("could not find exit to surface in CUF map")
			var from_cuf = session.unique_maps.char_underground_facility.the_map.get_exit_at(cuf_exit)
			from_cuf.is_an_ai_exit = true
	# 3. Sighting The Sewers Thing
	if p_player != session.unique_actors.the_sewers_thing.the_actor:
		if not session.player_knows_the_sewers_thing_location and \
			p_player.location.map == session.unique_actors.the_sewers_thing.the_actor.location.map and \
			not session.unique_actors.the_sewers_thing.the_actor.is_dead:
			if is_visible_to_player(session.unique_actors.the_sewers_thing.the_actor):
				session.player_knows_the_sewers_thing_location = true
				# message + music, so the player notices it
				music_manager.stop()
				music_manager.play(GameMusics.FIGHT, MusicPriority.PRIORITY_EVENT)
				clear_messages()
				add_message(Message.new("Hey! What's that THING!?", session.world_time.turn_counter, Color.YELLOW))
				if not player.is_bot_player:
					add_message_press_enter()
	# 4. Police Station script
	if p_player.location.map == session.unique_maps.police_station_jails_level.the_map and \
		not session.unique_actors.police_station_prisoner.the_actor.is_dead:
		var prisoner: Actor = session.unique_actors.police_station_prisoner.the_actor
		var map: Map = p_player.location.map
		match session.script_stage_police_station_prisoner:
			Session.ScriptStage.STAGE_0:  # nothing happened yet, waiting to offer deal
				# Player is near the prisoner : offer deal
				if rules.grid_distance_points(p_player.location.position, prisoner.location.position) <= 2 and \
					not prisoner.is_sleeping and \
					is_visible_to_player(prisoner):  # alpha10 fix: and visible!
					# Offer deal
					var text: Array = [
						"\" Psssst! Hey! You over there! \"",
						"%s is discretly calling you from %s cell. You listen closely..." % [prisoner.name, his_or_her(prisoner)],
						"\" Listen! I shouldn't be here! Just drove a bit too fast!",
						"  Look, I know what's happening! I worked down there! At the CHAR facility!",
						"  They didn't want me to leave but I did! Like I'm stupid enough to stay down there uh?",
						"  Now listen! Let's make a deal...",
						"  Stupid cops won't listen to me. You look clever...",
						"  You just have to push the button at the end of the corridor to open my cell.",
						"  The cops are too busy to care about small fish like me!",
						"  Then I'll tell you where is the underground facility and just get the hell out of here.",
						"  I don't give a fuck about CHAR anymore, you can do what you want with that!",
						"  There are plenty of cool stuff to loot down there!",
						"  Do it PLEASE! I REALLY shoudn't be there! \"",
						"Looks like %s wants you to turn the generator on to open the cells..." % he_or_she(prisoner),
					]
					show_special_dialogue(prisoner, text)
					# Scoring event
					session.scoring.add_event(session.world_time.turn_counter, "%s offered a deal." % prisoner.name)
					# Next stage
					session.script_stage_police_station_prisoner = Session.ScriptStage.STAGE_1
			Session.ScriptStage.STAGE_1:  # offered deal, waiting for opened cell
				# Wait to get out of cell and next to player
				if not map.has_zone_partially_named_at(prisoner.location.position, NAME_POLICE_STATION_JAILS_CELL) and \
					rules.is_adjacent(p_player.location.position, prisoner.location.position) and \
					not prisoner.is_sleeping:
					# Thank you and give info
					var text2: Array = [
						"\" Thank you! Thank you so much!",
						"  As promised, I'll tell you the big secret!",
						"  The CHAR Underground Facility is in district %s." % World.coord_to_string(session.unique_maps.char_underground_facility.the_map.district.world_position.x, session.unique_maps.char_underground_facility.the_map.district.world_position.y),
						"  Look for a CHAR Office, a room with an iron door.",
						"  Now I must hurry! Thanks a lot for saving me!",
						"  I don't want them to... UGGH...",
						"  What's happening? NO!",
						"  NO NOT ME! aAAAAAaaaa! NOT NOW! AAAGGGGGGGRRR \"",
					]
					show_special_dialogue(prisoner, text2)
					# Scoring event
					session.scoring.add_event(session.world_time.turn_counter, "Freed %s." % prisoner.name)
					# reveal location
					session.player_knows_char_underground_facility_location = true
					# Scoring event
					session.scoring.add_event(session.world_time.turn_counter, "Learned the location of the CHAR Underground Facility.")
					# transformation: zombify, turn into a ZP, zero AP so player don't get hit asap
					kill_actor(null, prisoner, "transformation", false)  # alpha10 don't drop corpse!
					var monster: Actor = zombify(null, prisoner, false)
					monster.model = game_actors.zombie_prince()
					monster.action_points = 0
					# Scoring event
					session.scoring.add_event(session.world_time.turn_counter, "%s turned into a %s!" % [prisoner.name, monster.model.name])
					# fight music!
					music_manager.play(GameMusics.FIGHT, MusicPriority.PRIORITY_EVENT)
					# Next stage
					session.script_stage_police_station_prisoner = Session.ScriptStage.STAGE_2
			Session.ScriptStage.STAGE_2:  # monsterized!
					pass  # nothing to do
			_:
				push_error("unhandled script stage %s" % session.script_stage_police_station_prisoner)
	# 5. Sighting Jason Myers
	if p_player != session.unique_actors.jason_myers.the_actor:
		if not session.unique_actors.jason_myers.the_actor.is_dead:
			if is_visible_to_player(session.unique_actors.jason_myers.the_actor):
				# music
				if music_manager.music != GameMusics.INSANE:
					music_manager.stop()
					music_manager.play(GameMusics.INSANE, MusicPriority.PRIORITY_EVENT)
				# message if 1st time
				if not session.scoring.has_sighted(session.unique_actors.jason_myers.the_actor.model.id):
					clear_messages()
					add_message(Message.new("Nice axe you have there!", session.world_time.turn_counter, Color.YELLOW))
					if not player.is_bot_player:
						add_message_press_enter()
	# 6. Sighting Duckman -- alpha10 disabled (commented out in original)
	# Item interactions: 1. Subway Worker Badge in Subway maps
	# conditions: In Subway, Must be Equipped, Next to closed gates. effects: turn all generators on
	if session.unique_items.the_subway_worker_badge.the_item.is_equipped and \
		p_player.location.map == p_player.location.map.district.subway_map and \
		p_player.inventory.contains(session.unique_items.the_subway_worker_badge.the_item):
		# must be adjacent to closed gates
		var map2: Map = p_player.location.map
		if map2.has_any_adjacent_in_map(p_player.location.position, func(pt: Vector2i) -> bool:
			var obj: MapObject = map2.get_map_object_at(pt)
			if obj == null:
				return false
			return obj.image_id == GameImages.OBJ_GATE_CLOSED):
			# turn all power on!
			do_turn_all_generators_on(map2)
			# message
			add_message(Message.new("The gate system scanned your badge and turned the power on!", session.world_time.turn_counter, Color.GREEN))
	# Generic 1st time flags
	# 1. Visiting a new map
	if not session.scoring.has_visited(p_player.location.map):
		# visit
		session.scoring.add_visit(session.world_time.turn_counter, p_player.location.map)
		session.scoring.add_event(session.world_time.turn_counter, "Visited %s." % p_player.location.map.name)
	# 2. Sighting an actor : actor model, unique NPCs
	for p in player_fov.keys():
		var other: Actor = p_player.location.map.get_actor_at(p)
		if other == null or other == p_player:
			continue
		session.scoring.add_sighting(other.model.id, session.world_time.turn_counter)
		# alpha10 unique npcs lose their invincibility when sighted and highlight them
		if other.is_unique:
			if other.is_invincible:  # 1st sighting
				play_unique_actor_music_and_message(session.actor_to_unique_actor(other), false)
				other.is_invincible = false


# --- Reincarnation (RogueGame.cs ~22000) ---

func handle_reincarnation() -> void:
	# Reincarnate? don't bother if option set to zero
	if options.max_reincarnations <= 0 or not ask_for_reincarnation():
		music_manager.stop()
		return
	# play music
	music_manager.stop()
	music_manager.play_looping(GameMusics.LIMBO, MusicPriority.PRIORITY_EVENT)
	# Waiting screen...
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.YELLOW, "Reincarnation - Purgatory", 0, 0)
	ui.ui_draw_string_bold(Color.WHITE, "(preparing reincarnations, please wait...)", 0, 2 * BOLD_LINE_SPACING)
	ui.ui_repaint()
	# Decide available reincarnation targets
	var random_r: Dictionary = find_reincarnation_avatar(GameOptions.ReincMode.RANDOM_ACTOR)
	var living_r: Dictionary = find_reincarnation_avatar(GameOptions.ReincMode.RANDOM_LIVING)
	var undead_r: Dictionary = find_reincarnation_avatar(GameOptions.ReincMode.RANDOM_UNDEAD)
	var follower_r: Dictionary = find_reincarnation_avatar(GameOptions.ReincMode.RANDOM_FOLLOWER)
	var killer_r: Dictionary = find_reincarnation_avatar(GameOptions.ReincMode.KILLER)
	var zombified_r: Dictionary = find_reincarnation_avatar(GameOptions.ReincMode.ZOMBIFIED)
	# Get fun facts
	var fun_facts: Array = compile_district_fun_facts(player.location.map.district)
	# Reincarnate: choose avatar from a set of reincarnation modes
	var choice_made: bool = false
	var entries: PackedStringArray = PackedStringArray([
		GameOptions.reinc_mode_name(GameOptions.ReincMode.RANDOM_ACTOR),
		GameOptions.reinc_mode_name(GameOptions.ReincMode.RANDOM_LIVING),
		GameOptions.reinc_mode_name(GameOptions.ReincMode.RANDOM_UNDEAD),
		GameOptions.reinc_mode_name(GameOptions.ReincMode.RANDOM_FOLLOWER),
		GameOptions.reinc_mode_name(GameOptions.ReincMode.KILLER),
		GameOptions.reinc_mode_name(GameOptions.ReincMode.ZOMBIFIED),
	])
	var values: Array = [
		describe_avatar(random_r["avatar"]),
		"%s   (out of %d possibilities)" % [describe_avatar(living_r["avatar"]), living_r["count"]],
		"%s   (out of %d possibilities)" % [describe_avatar(undead_r["avatar"]), undead_r["count"]],
		"%s   (out of %d possibilities)" % [describe_avatar(follower_r["avatar"]), follower_r["count"]],
		describe_avatar(killer_r["avatar"]),
		describe_avatar(zombified_r["avatar"]),
	]
	var selected: int = 0
	var avatar: Actor = null
	while not choice_made:
		# show screen
		var gx: int = 0
		var gy: int = 0
		ui.ui_clear(Color.BLACK)
		ui.ui_draw_string_bold(Color.YELLOW, "Reincarnation - Choose Avatar", gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		gy = draw_menu_or_options(selected, Color.WHITE, entries, Color.LIGHT_GREEN, values, gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.PINK, ".-* District Fun Facts! *-.", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.PINK, "at current date : %s." % str(WorldTime.new(session.world_time.turn_counter)), gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		for i in fun_facts.size():
			ui.ui_draw_string_bold(Color.PINK, fun_facts[i], gx, gy)
			gy += BOLD_LINE_SPACING
		draw_footnote(Color.WHITE, "cursor to move, ENTER to select, ESC to cancel and end game")
		ui.ui_repaint()
		# get menu action
		var key: InputEventKey = ui.ui_wait_key()
		match key.keycode:
			KEY_UP:  # move up
				if selected > 0:
					selected -= 1
				else:
					selected = entries.size() - 1
			KEY_DOWN:  # move down
				selected = (selected + 1) % entries.size()
			KEY_ESCAPE:  # cancel & end game
				choice_made = true
				avatar = null
			KEY_ENTER:  # validate
				match selected:
					0: avatar = random_r["avatar"]
					1: avatar = living_r["avatar"]
					2: avatar = undead_r["avatar"]
					3: avatar = follower_r["avatar"]
					4: avatar = killer_r["avatar"]
					5: avatar = zombified_r["avatar"]
				choice_made = avatar != null
	# If canceled, stop
	if avatar == null:
		music_manager.stop()
		return
	# Perform reincarnation
	# 1. Make actor the player
	avatar.controller = PlayerController.new()
	if avatar.activity != Activity.SLEEPING:
		avatar.activity = Activity.IDLE
	prepare_actor_for_player_control(avatar)
	# 2. Update all player-centric data
	player = avatar
	session.current_map = avatar.location.map
	session.scoring.start_new_life(session.world_time.turn_counter)
	session.scoring.add_event(session.world_time.turn_counter, "(reincarnation %d)" % session.scoring.reincarnation_number)
	session.scoring.side = Scoring.DifficultySide.FOR_UNDEAD if player.model.abilities.is_undead else Scoring.DifficultySide.FOR_SURVIVOR
	session.scoring.difficulty_rating = Scoring.compute_difficulty_rating(options, session.scoring.side, session.scoring.reincarnation_number)
	# forget all maps memory
	for dx in session.world.size:
		for dy in session.world.size:
			var d: District = session.world.get_district(dx, dy)
			for m in d.maps:
				m.set_all_as_unvisited()
	# Cleanup and refresh
	music_manager.stop()
	update_player_fov(player)
	compute_view_rect(player.location.position)
	clear_messages()
	add_message(Message.new("%s feels disoriented for a second..." % player.name, session.world_time.turn_counter, Color.YELLOW))
	redraw_play_screen()
	# Play reinc sfx or special music for actor
	var music: String = GameMusics.REINCARNATE
	if player == session.unique_actors.jason_myers.the_actor:
		music = GameMusics.INSANE
	# alpha10 replaced with sfx
	music_manager.stop()
	music_manager.play(music, MusicPriority.PRIORITY_EVENT)
	# restart sim thread (no-op in the Godot port)
	stop_sim_thread(false)
	start_sim_thread()


func describe_avatar(a: Actor) -> String:
	if a == null:
		return "(N/A)"
	var is_leader: bool = a.count_followers > 0
	var is_follower: bool = a.has_leader
	return "%s, a %s%s" % [a.name, a.model.name, ", leader" if is_leader else (", follower" if is_follower else "")]


func ask_for_reincarnation() -> bool:
	# show screen
	var gx: int = 0
	var gy: int = 0
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.YELLOW, "Limbo", gx, gy)
	gy += 2 * BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Leave body %d/%d." % [1 + session.scoring.reincarnation_number, 1 + options.max_reincarnations], gx, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Remember lives.", gx, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Remember purpose.", gx, gy)
	gy += BOLD_LINE_SPACING
	ui.ui_draw_string_bold(Color.WHITE, "Clear again.", gx, gy)
	gy += BOLD_LINE_SPACING
	# ask question or no more lives left
	if session.scoring.reincarnation_number >= options.max_reincarnations:
		# no more lives left
		ui.ui_draw_string_bold(Color.LIGHT_GREEN, "Humans interesting.", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.LIGHT_GREEN, "Time to leave.", gx, gy)
		gy += BOLD_LINE_SPACING
		gy += 2 * BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "No more reincarnations left.", gx, gy)
		draw_footnote(Color.WHITE, "press ENTER")
		ui.ui_repaint()
		wait_enter()
		return false
	else:
		# one more life available
		ui.ui_draw_string_bold(Color.WHITE, "Leave?", gx, gy)
		gy += BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.WHITE, "Live?", gx, gy)
		gy += 2 * BOLD_LINE_SPACING
		ui.ui_draw_string_bold(Color.YELLOW, "Reincarnate? Y to confirm, N to cancel.", gx, gy)
		ui.ui_repaint()
		# ask question
		return wait_yes_or_no()


func is_suitable_reincarnation(a: Actor, as_living: bool) -> bool:
	if a == null:
		return false
	if a.is_dead or a.is_player:
		return false
	# same district only
	if a.location.map.district != session.current_map.district:
		return false
	# forbid some special maps
	if a.location.map == session.unique_maps.char_underground_facility.the_map:
		return false
	# forbid some special actors
	if a == session.unique_actors.police_station_prisoner.the_actor:
		return false
	# (option) not in sewers
	if a.location.map == a.location.map.district.sewers_map:
		return false
	# living vs undead checks
	if as_living:
		if a.model.abilities.is_undead:
			return false
		# (option) civilians only
		if options.is_living_reinc_restricted and a.faction != game_factions.the_civilians():
			return false
		return true
	else:
		if a.model.abilities.is_undead:
			# (option) not rats
			if not options.can_reincarnate_as_rat and a.model == game_actors.rat_zombie():
				return false
			return true
		else:
			return false


## Returns {"avatar": Actor or null, "count": int} (C# out int matchingActors).
func find_reincarnation_avatar(reinc_mode: int) -> Dictionary:
	match reinc_mode:
		GameOptions.ReincMode.RANDOM_FOLLOWER:
			if session.scoring.followers_when_died == null:
				return {"avatar": null, "count": 0}
			# list all suitable followers
			var suitable_followers: Array = []
			for fo in session.scoring.followers_when_died:
				if is_suitable_reincarnation(fo, true):
					suitable_followers.append(fo)
			# make sure we have at least one suitable!
			if suitable_followers.is_empty():
				return {"avatar": null, "count": 0}
			# random one
			return {"avatar": suitable_followers[rules.roll(0, suitable_followers.size())], "count": suitable_followers.size()}
		GameOptions.ReincMode.KILLER:
			var killer: Actor = session.scoring.killer
			if is_suitable_reincarnation(killer, true) or is_suitable_reincarnation(killer, false):
				return {"avatar": killer, "count": 1}
			return {"avatar": null, "count": 0}
		GameOptions.ReincMode.RANDOM_ACTOR, GameOptions.ReincMode.RANDOM_LIVING, GameOptions.ReincMode.RANDOM_UNDEAD:
			# get a list of all suitable actors in the world
			var as_living: bool = reinc_mode == GameOptions.ReincMode.RANDOM_LIVING or \
				(reinc_mode == GameOptions.ReincMode.RANDOM_ACTOR and rules.roll_chance(50))
			var all_suitables: Array = []
			for dx in session.world.size:
				for dy in session.world.size:
					var district: District = session.world.get_district(dx, dy)
					for map in district.maps:
						for a in map.actors_list:
							if is_suitable_reincarnation(a, as_living):
								all_suitables.append(a)
			# pick one at random
			if all_suitables.is_empty():
				return {"avatar": null, "count": 0}
			return {"avatar": all_suitables[rules.roll(0, all_suitables.size())], "count": all_suitables.size()}
		GameOptions.ReincMode.ZOMBIFIED:
			var zombie: Actor = session.scoring.zombified_player
			if is_suitable_reincarnation(zombie, false):
				return {"avatar": zombie, "count": 1}
			return {"avatar": null, "count": 0}
		_:
			push_error("unhandled reincarnation mode " + str(reinc_mode))
			return {"avatar": null, "count": 0}

func generate_insane_action(actor: Actor) -> ActorAction:
	# Let's the insanity flow...
	var roll: int = rules.roll(0, 5)
	match roll:
		0: # shout
			return ActionShout.new(actor, self, "AAAAAAAAAAA!!!")
		1: # random bump
			return ActionBump.new(actor, self, rules.roll_direction())
		2: # random bash
			var d: Direction = rules.roll_direction()
			var mobj: MapObject = actor.location.map.get_map_object_at(actor.location.position + d.vector)
			if mobj == null:
				return null
			return ActionBreak.new(actor, self, mobj)
		3: # random use/unequip-drop
			var inv: Inventory = actor.inventory
			if inv == null or inv.count_items == 0:
				return null
			var it: Item = inv.get_item_at(rules.roll(0, inv.count_items - 1))
			var use_it: ActionUseItem = ActionUseItem.new(actor, self, it)
			if use_it.is_legal():
				return use_it
			if it.is_equipped:
				return ActionUnequipItem.new(actor, self, it)
			return ActionDropItem.new(actor, self, it)
		4: # random aggression
			var fov: int = rules.actor_fov(actor, actor.location.map.local_time, session.world.weather)
			for a in actor.location.map.actors_list:
				if a == actor:
					continue
				if rules.are_enemies(actor, a):
					continue
				if not LOS.can_trace_view_line(actor.location, a.location.position, fov):
					continue
				if rules.roll_chance(50):
					# force leaving of leader
					if actor.has_leader:
						actor.leader.remove_follower(actor)
						actor.trust_in_leader = Rules.TRUST_NEUTRAL
					# agress
					do_make_aggression(actor, a)
					return ActionSay.new(actor, self, a, "YOU ARE ONE OF THEM!!", Sayflags.IS_IMPORTANT | Sayflags.IS_DANGER)
			return null
	return null

func seeing_cause_insanity(who_does_the_action: Actor, loc: Location, san_cost: int, what: String) -> void:
	for a in loc.map.actors_list:
		if not a.model.abilities.has_sanity:
			continue
		# can't see if sleeping or out of fov
		if a.is_sleeping:
			continue
		var fov: int = rules.actor_fov(a, loc.map.local_time, session.world.weather)
		if not LOS.can_trace_view_line(loc, a.location.position, fov):
			continue
		# san hit
		spend_actor_sanity(a, san_cost)
		# msg
		if who_does_the_action == a:
			if a.is_player:
				add_message(Message.new("That was a very disturbing thing to do...", loc.map.local_time.turn_counter, Color.ORANGE))
			elif is_visible_to_player(a):
				add_message(make_message(a, "%s done something very disturbing..." % conjugate(a, VERB_HAVE)))
		else:
			if a.is_player:
				add_message(Message.new("Seeing %s is very disturbing..." % what, loc.map.local_time.turn_counter, Color.ORANGE))
			elif is_visible_to_player(a):
				add_message(make_message(a, "%s something very disturbing..." % conjugate(a, VERB_SEE)))

func on_map_power_generator_switch(location: Location, _pow_gen: PowerGenerator) -> void:
	var map: Map = location.map
	#--////////////////////////////////////////////////
	# Maps:
	# 1. CHAR Underground Facility.
	# 2. Subway
	# 3. Police Station Jails.
	# 4. Hospital Power.
	#--////////////////////////////////////////////////
	# 1. CHAR Underground Facility
	# Darkness->Lit, TODO: Elevator off->on.
	if map == session.unique_maps.char_underground_facility.the_map:
		# check all power generators are on
		var all_are_on: bool = rules.compute_map_power_ratio(map) >= 1.0
		# change map lighting
		if all_are_on:
			if map.lighting != Map.Lighting.LIT:
				map.lighting = Map.Lighting.LIT
				# message
				if player.location.map == map:
					clear_messages()
					add_message(Message.new("The Facility lights turn on!", map.local_time.turn_counter, Color.GREEN))
					redraw_play_screen()
				# achievement?
				if not session.scoring.has_completed_achievement(Scoring.Achievement.IDs.CHAR_POWER_UNDERGROUND_FACILITY):
					# completed!
					session.scoring.set_completed_achievement(Scoring.Achievement.IDs.CHAR_POWER_UNDERGROUND_FACILITY)
					# achievement!
					show_new_achievement(Scoring.Achievement.IDs.CHAR_POWER_UNDERGROUND_FACILITY)
		else: # part off
			if map.lighting != Map.Lighting.DARKNESS:
				map.lighting = Map.Lighting.DARKNESS
				# message
				if player.location.map == map:
					clear_messages()
					add_message(Message.new("The Facility lights turn off!", map.local_time.turn_counter, Color.RED))
					redraw_play_screen()
	# 2. Subway
	# Darkness->Lit, Gates->open.
	if map == map.district.subway_map:
		# check all power generators are on
		var all_are_on: bool = rules.compute_map_power_ratio(map) >= 1.0
		# change map lighting, open/close fences
		if all_are_on:
			if map.lighting != Map.Lighting.LIT:
				# lit
				map.lighting = Map.Lighting.LIT
				# message
				if player.location.map == map:
					clear_messages()
					add_message(Message.new("The station power turns on!", map.local_time.turn_counter, Color.GREEN))
					add_message(Message.new("You hear the gates opening.", map.local_time.turn_counter, Color.GREEN))
					redraw_play_screen()
				# open iron gates
				do_open_subway_gates(map)
		else: # part off
			if map.lighting != Map.Lighting.DARKNESS:
				# message
				if player.location.map == map:
					clear_messages()
					add_message(Message.new("The station power turns off!", map.local_time.turn_counter, Color.RED))
					add_message(Message.new("You hear the gates closing.", map.local_time.turn_counter, Color.RED))
					redraw_play_screen()
				# darkness
				map.lighting = Map.Lighting.DARKNESS
				# close iron gates
				do_close_subway_gates(map)
	# 3. Police Station Jails
	if map == session.unique_maps.police_station_jails_level.the_map:
		# check all power generators are on
		var all_are_on: bool = rules.compute_map_power_ratio(map) >= 1.0
		# open/close cells
		if all_are_on:
			# message
			if player.location.map == map:
				clear_messages()
				add_message(Message.new("The cells are opening.", map.local_time.turn_counter, Color.GREEN))
				redraw_play_screen()
			# open cells
			do_open_police_jail_cells(map)
		else:
			# message
			if player.location.map == map:
				clear_messages()
				add_message(Message.new("The cells are closing.", map.local_time.turn_counter, Color.GREEN))
				redraw_play_screen()
			# close cells
			do_close_police_jail_cells(map)
	# 4. Hospital Power
	if map == session.unique_maps.hospital_power.the_map:
		# check all power generators are on
		var all_are_on: bool = rules.compute_map_power_ratio(map) >= 1.0
		# open/close cells
		if all_are_on:
			# message
			if player.location.map == map:
				clear_messages()
				add_message(Message.new("The lights turn on and you hear something opening upstairs.", map.local_time.turn_counter, Color.GREEN))
				redraw_play_screen()
			# turn power on
			do_hospital_power_on()
		else:
			if map.lighting != Map.Lighting.DARKNESS:
				# message
				if player.location.map == map:
					clear_messages()
					add_message(Message.new("The lights turn off and you hear something closing upstairs.", map.local_time.turn_counter, Color.GREEN))
					redraw_play_screen()
				# turn power off
				do_hospital_power_off()

# alpha10.1 common code for checking crushing closing gates.
# they do not insta-kill the actor anymore but inflict (large) damage and can't close if the actor is still there.
# returns true if the gate can close, false if it must stay open
func check_for_gate_closing_crush(gate: MapObject, crushing_damage: int) -> bool:
	var crushed_actor: Actor = gate.location.map.get_actor_at(gate.location.position)
	if crushed_actor == null:
		return true
	if crushed_actor.is_invincible:
		return false
	inflict_damage(crushed_actor, crushing_damage)
	if is_visible_to_player(crushed_actor):
		add_message(make_message(crushed_actor, "is crushed for %d damage!" % crushing_damage))
		add_overlay(OverlayImage.new(map_to_screen(crushed_actor.location.position), GameImages.ICON_MELEE_DAMAGE))
		add_overlay(OverlayText.new(map_to_screen(crushed_actor.location.position) + Vector2i(DAMAGE_DX, DAMAGE_DY), Color.WHITE, str(crushing_damage), Color.BLACK))
		redraw_play_screen()
		anim_delay(DELAY_NORMAL if crushed_actor.is_player else DELAY_SHORT)
		clear_overlays()
		redraw_play_screen()
	if crushed_actor.hit_points <= 0:
		kill_actor(null, crushed_actor, "crushed")
		return true
	return false

func do_open_subway_gates(map: Map) -> void:
	for obj in map.map_objects_list:
		if obj.image_id == GameImages.OBJ_GATE_CLOSED:
			obj.is_walkable = true
			obj.image_id = GameImages.OBJ_GATE_OPEN

func do_close_subway_gates(map: Map) -> void:
	for obj in map.map_objects_list:
		if obj.image_id == GameImages.OBJ_GATE_OPEN:
			# alpha10.1
			if check_for_gate_closing_crush(obj, Rules.CRUSHING_GATES_DAMAGE):
				obj.is_walkable = false
				obj.image_id = GameImages.OBJ_GATE_CLOSED

func do_open_police_jail_cells(map: Map) -> void:
	for obj in map.map_objects_list:
		if obj.image_id == GameImages.OBJ_GATE_CLOSED:
			obj.is_walkable = true
			obj.image_id = GameImages.OBJ_GATE_OPEN

func do_close_police_jail_cells(map: Map) -> void:
	for obj in map.map_objects_list:
		if obj.image_id == GameImages.OBJ_GATE_OPEN:
			# alpha10.1
			if check_for_gate_closing_crush(obj, Rules.CRUSHING_GATES_DAMAGE):
				obj.is_walkable = false
				obj.image_id = GameImages.OBJ_GATE_CLOSED

func do_hospital_power_on() -> void:
	# turn all hospital lights on
	session.unique_maps.hospital_admissions.the_map.lighting = Map.Lighting.LIT
	session.unique_maps.hospital_offices.the_map.lighting = Map.Lighting.LIT
	session.unique_maps.hospital_patients.the_map.lighting = Map.Lighting.LIT
	session.unique_maps.hospital_power.the_map.lighting = Map.Lighting.LIT
	session.unique_maps.hospital_storage.the_map.lighting = Map.Lighting.LIT
	# open storage gates
	for obj in session.unique_maps.hospital_storage.the_map.map_objects_list:
		if obj.image_id == GameImages.OBJ_GATE_CLOSED:
			obj.is_walkable = true
			obj.image_id = GameImages.OBJ_GATE_OPEN

func do_hospital_power_off() -> void:
	# turn all hospital lights off
	session.unique_maps.hospital_admissions.the_map.lighting = Map.Lighting.DARKNESS
	session.unique_maps.hospital_offices.the_map.lighting = Map.Lighting.DARKNESS
	session.unique_maps.hospital_patients.the_map.lighting = Map.Lighting.DARKNESS
	session.unique_maps.hospital_power.the_map.lighting = Map.Lighting.DARKNESS
	session.unique_maps.hospital_storage.the_map.lighting = Map.Lighting.DARKNESS
	# close storage gate
	var map: Map = session.unique_maps.hospital_storage.the_map
	for obj in map.map_objects_list:
		if obj.image_id == GameImages.OBJ_GATE_OPEN:
			# alpha10.1
			if check_for_gate_closing_crush(obj, Rules.CRUSHING_GATES_DAMAGE):
				obj.is_walkable = false
				obj.image_id = GameImages.OBJ_GATE_CLOSED

func do_turn_all_generators_on(map: Map) -> void:
	for obj in map.map_objects_list:
		var pow_gen: PowerGenerator = obj as PowerGenerator
		if pow_gen == null:
			continue
		if not pow_gen.is_on:
			pow_gen.toggle_power()
			on_map_power_generator_switch(pow_gen.location, pow_gen)

static func is_in_char_office(location: Location) -> bool:
	var zones: Array[Zone] = location.map.get_zones_at(location.position.x, location.position.y)
	if zones == null:
		return false
	for z in zones:
		if z.has_game_attribute(ZoneAttributes.IS_CHAR_OFFICE):
			return true
	return false

func is_in_char_property(location: Location) -> bool:
	return location.map == session.unique_maps.char_underground_facility.the_map or \
		is_in_char_office(location)

func are_linked_by_phone(speaker: Actor, target: Actor) -> bool:
	# only leader-follower
	if speaker.leader != target and target.leader != speaker:
		return false
	# check if equipped phones
	var tr_speaker: ItemTracker = speaker.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
	if tr_speaker == null or not tr_speaker.can_track_followers_or_leader():
		return false
	var tr_target: ItemTracker = target.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
	if tr_target == null or not tr_target.can_track_followers_or_leader():
		return false
	# yep!
	return true

enum MapListFlags {
	NONE = 0,
	# Exclude map with the IsSecret property.
	EXCLUDE_SECRET_MAPS = (1 << 0),
}

func list_world_actors(pred: Callable, flags: int) -> Array[Actor]:
	var list: Array[Actor] = []
	for dx in session.world.size:
		for dy in session.world.size:
			list.append_array(list_district_actors(session.world.get_district(dx, dy), flags, pred))
	return list

func list_district_actors(d: District, flags: int, pred: Callable = Callable()) -> Array[Actor]:
	var list: Array[Actor] = []
	for m in d.maps:
		if (flags & MapListFlags.EXCLUDE_SECRET_MAPS) != 0 and m.is_secret:
			continue
		for a in m.actors_list:
			if pred.is_null() or pred.call(a):
				list.append(a)
	return list

func fun_fact_actor_resume(a: Actor, info: String) -> String:
	if a == null:
		return "(N/A)"
	return "%s - %s, a %s - %s" % [info, a.the_name, a.model.name, a.location.map.name]

func compile_district_fun_facts(d: District) -> Array:
	var list: Array = []
	#--///////////////////////////////////////
	# 1. Oldest actors alive living & undead.
	# 2. Most kills living & undead.
	# 3. Most murders.
	#--///////////////////////////////////////
	# list actors
	var all_livings: Array[Actor] = list_district_actors(d, MapListFlags.EXCLUDE_SECRET_MAPS, func(a): return not a.is_dead and not a.model.abilities.is_undead)
	var all_undeads: Array[Actor] = list_district_actors(d, MapListFlags.EXCLUDE_SECRET_MAPS, func(a): return not a.is_dead and a.model.abilities.is_undead)
	var all_actors: Array[Actor] = list_district_actors(d, MapListFlags.EXCLUDE_SECRET_MAPS)
	# add player (cause he's dead now)
	if player.model.abilities.is_undead:
		all_undeads.append(player)
	else:
		all_livings.append(player)
	all_actors.append(player)
	# 1. Oldest actors alive living & undead
	if not all_livings.is_empty():
		all_livings.sort_custom(func(a, b): return a.spawn_time < b.spawn_time)
		list.append("- Oldest Livings Surviving")
		list.append("    1st %s." % fun_fact_actor_resume(all_livings[0], str(WorldTime.new(all_livings[0].spawn_time))))
		if all_livings.size() > 1:
			list.append("    2nd %s." % fun_fact_actor_resume(all_livings[1], str(WorldTime.new(all_livings[1].spawn_time))))
	else:
		list.append("    No living actors alive!")
	if not all_undeads.is_empty():
		all_undeads.sort_custom(func(a, b): return a.spawn_time < b.spawn_time)
		list.append("- Oldest Undeads Rotting Around")
		list.append("    1st %s." % fun_fact_actor_resume(all_undeads[0], str(WorldTime.new(all_undeads[0].spawn_time))))
		if all_undeads.size() > 1:
			list.append("    2nd %s." % fun_fact_actor_resume(all_undeads[1], str(WorldTime.new(all_undeads[1].spawn_time))))
	else:
		list.append("    No undeads shambling around!")
	# 2. Most kills living & undead
	if not all_livings.is_empty():
		all_livings.sort_custom(func(a, b): return a.kills_count > b.kills_count)
		list.append("- Deadliest Livings Kicking ass")
		if all_livings[0].kills_count > 0:
			list.append("    1st %s." % fun_fact_actor_resume(all_livings[0], str(all_livings[0].kills_count)))
			if all_livings.size() > 1 and all_livings[1].kills_count > 0:
				list.append("    2nd %s." % fun_fact_actor_resume(all_livings[1], str(all_livings[1].kills_count)))
		else:
			list.append("    Livings can't fight for their lives apparently.")
	if not all_undeads.is_empty():
		all_undeads.sort_custom(func(a, b): return a.kills_count > b.kills_count)
		list.append("- Deadliest Undeads Chewing Brains")
		if all_undeads[0].kills_count > 0:
			list.append("    1st %s." % fun_fact_actor_resume(all_undeads[0], str(all_undeads[0].kills_count)))
			if all_undeads.size() > 1 and all_undeads[1].kills_count > 0:
				list.append("    2nd %s." % fun_fact_actor_resume(all_undeads[1], str(all_undeads[1].kills_count)))
		else:
			list.append("    Undeads don't care for brains apparently.")
	# 3. Most murders
	if not all_livings.is_empty():
		all_livings.sort_custom(func(a, b): return a.murders_counter > b.murders_counter)
		list.append("- Most Murderous Murderer Murdering")
		if all_livings[0].murders_counter > 0:
			list.append("    1st %s." % fun_fact_actor_resume(all_livings[0], str(all_livings[0].murders_counter)))
			if all_livings.size() > 1 and all_livings[1].murders_counter > 0:
				list.append("    2nd %s." % fun_fact_actor_resume(all_livings[1], str(all_livings[1].murders_counter)))
		else:
			list.append("    No murders committed!")
	# done
	return list

func dev_toggle_show_actors_stats() -> void:
	options.dev_show_actors_stats = not options.dev_show_actors_stats

# alpha10
func dev_toggle_player_invincibility() -> void:
	if session == null or player == null:
		return
	player.is_invincible = not player.is_invincible
	add_message(Message.new("DEAR DEV, YOU ARE NOW " + ("INVINCIBLE" if player.is_invincible else "NOT INVINCIBLE"), session.world_time.turn_counter, Color.LIGHT_GREEN))

# alpha10.1
func dev_max_trust() -> void:
	if session == null or player == null:
		return
	if player.followers == null: # alpha10.1 fix
		return
	for f in player.followers:
		f.trust_in_leader = Rules.TRUST_MAX
	add_message(Message.new("DEAR DEV, FOLLOWERS TRUST MAXED.", session.world_time.turn_counter, Color.LIGHT_GREEN))

func load_data() -> void:
	load_data_skills()
	load_data_items()
	load_data_actors()

func load_data_actors() -> void:
	game_actors.load_from_csv(ui, "res://assets/Data/Actors.csv")

func load_data_items() -> void:
	# load all data
	game_items.load_medicine_from_csv(ui, "res://assets/Data/Items_Medicine.csv")
	game_items.load_food_from_csv(ui, "res://assets/Data/Items_Food.csv")
	game_items.load_melee_weapons_from_csv(ui, "res://assets/Data/Items_MeleeWeapons.csv")
	game_items.load_ranged_weapons_from_csv(ui, "res://assets/Data/Items_RangedWeapons.csv")
	game_items.load_explosives_from_csv(ui, "res://assets/Data/Items_Explosives.csv")
	game_items.load_barricading_material_from_csv(ui, "res://assets/Data/Items_Barricading.csv")
	game_items.load_armors_from_csv(ui, "res://assets/Data/Items_Armors.csv")
	game_items.load_trackers_from_csv(ui, "res://assets/Data/Items_Trackers.csv")
	game_items.load_spraypaints_from_csv(ui, "res://assets/Data/Items_Spraypaints.csv")
	game_items.load_lights_from_csv(ui, "res://assets/Data/Items_Lights.csv")
	game_items.load_scentsprays_from_csv(ui, "res://assets/Data/Items_Scentsprays.csv")
	game_items.load_traps_from_csv(ui, "res://assets/Data/Items_Traps.csv")
	game_items.load_entertainment_from_csv(ui, "res://assets/Data/Items_Entertainment.csv")
	# create
	game_items.create_models()

func load_data_skills() -> void:
	Skills.load_skills_from_csv(ui, "res://assets/Data/Skills.csv")

# alpha10
func update_bg_music() -> void:
	if not options.play_music:
		return
	if player == null:
		return
	# don't interrupt music that has higher priority than bg
	if music_manager.is_playing and music_manager.priority > MusicPriority.PRIORITY_BGM:
		return
	# get current map music and play it if not already playing it
	var map_music: String = session.current_map.bg_music
	if map_music.is_empty():
		return
	if music_manager.music == map_music and music_manager.is_playing:
		return
	music_manager.stop()
	music_manager.play(map_music, MusicPriority.PRIORITY_BGM)

# C# #if DEBUG dev cheats (bodies were commented out in the original).
func add_dev_cheat_items() -> void:
	pass

func add_dev_cheat_skills() -> void:
	pass

func add_dev_misc_stuff() -> void:
	pass

func draw_tile_dev(_m: Map, _t: Tile, _x: int, _y: int, _to_screen: Vector2i) -> void:
	pass


## Sever all references at shutdown so the game object graph can be freed
## by refcounting (the session/world part is handled by Session.shutdown_all).
func shutdown() -> void:
	ui = null
	rules = null
	session = null
	hi_score_table = null
	message_manager = null
	overlays.clear()
	player = null
	player_fov.clear()
	hint_available_overlay = null
	town_generator = null
	music_manager = NullMusicManager.new()
	char_gen = null
	manual = null
	game_factions = null
	game_actors = null
	game_items = null
	game_tiles = null
	player_long_wait_end = null
	_debug_prev_ai_actor = null
