class_name DoorWindow
extends StateMapObject
## Port of Engine/MapObjects/Door.cs

const BASE_HITPOINTS := 40

const STATE_CLOSED := 1
const STATE_OPEN := 2
const STATE_BROKEN := 3

var _closed_image_id: String
var _open_image_id: String
var _broken_image_id: String
var is_window: bool = false
var _barricade_points: int = 0


var is_open: bool:
	get:
		return state == STATE_OPEN


var is_closed: bool:
	get:
		return state == STATE_CLOSED


var is_broken: bool:
	get:
		return state == STATE_BROKEN


func is_transparent() -> bool:
	if _barricade_points > 0:
		return false
	if state == STATE_OPEN:
		if fire_state == Fire.ONFIRE:
			return false
		return true
	return super.is_transparent()


var is_barricaded: bool:
	get:
		return _barricade_points > 0


var barricade_points: int:
	get:
		return _barricade_points
	set(value):
		# handle barricading-debarricading
		if value > 0 and _barricade_points <= 0:
			# barricading
			jump_level -= 1
			is_walkable = false
		elif value <= 0 and _barricade_points > 0:
			# de-barricading, restore state effects.
			set_state(state)

		_barricade_points = value
		if _barricade_points < 0:
			_barricade_points = 0


func _init(p_name: String, p_closed_image_id: String, p_open_image_id: String, p_broken_image_id: String, p_hit_points: int) -> void:
	super(p_name, p_closed_image_id, Break.BREAKABLE, Fire.BURNABLE, p_hit_points)
	_closed_image_id = p_closed_image_id
	_open_image_id = p_open_image_id
	_broken_image_id = p_broken_image_id
	_barricade_points = 0

	set_state(STATE_CLOSED)


func set_state(new_state: int) -> void:
	match new_state:
		STATE_OPEN:
			image_id = _open_image_id
			is_walkable = true

		STATE_CLOSED:
			image_id = _closed_image_id
			is_walkable = false

		STATE_BROKEN:
			image_id = _broken_image_id
			break_state = Break.BROKEN
			hit_points = 0
			_barricade_points = 0
			is_walkable = true

		_:
			push_error("newState unhandled")
			assert(false, "newState unhandled")
			return

	super(new_state)


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	super._serialize_fields(d)
	d["closed_image_id"] = _closed_image_id
	d["open_image_id"] = _open_image_id
	d["broken_image_id"] = _broken_image_id
	d["is_window"] = is_window
	d["barricade_points"] = _barricade_points


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	# Direct field assignment : the barricade_points setter has state side
	# effects that must not run during load.
	_closed_image_id = d.get("closed_image_id", _closed_image_id)
	_open_image_id = d.get("open_image_id", _open_image_id)
	_broken_image_id = d.get("broken_image_id", _broken_image_id)
	is_window = d.get("is_window", is_window)
	_barricade_points = d.get("barricade_points", _barricade_points)
