class_name WorldTime
extends RefCounted
## Port of Data/WorldTime.cs
## In-game calendar derived from the global turn counter.

enum DayPhase {
	## 18h
	SUNSET,
	## 19h-20h-21h-22h-23h
	EVENING,
	## 24h
	MIDNIGHT,
	## 1h - 2h- 3h- 4h- 5h
	DEEP_NIGHT,

	## 6h
	SUNRISE,
	## 7h - 8h- 9h-10h-11h
	MORNING,
	## 12h
	MIDDAY,
	## 13h-14h-15h-16h-17h
	AFTERNOON,
}

const TURNS_PER_HOUR: int = 30
const TURNS_PER_DAY: int = TURNS_PER_HOUR * 24

var _turn_counter: int = 0
var _day: int = 0
var _hour: int = 0
var _phase: DayPhase = DayPhase.SUNSET
var _is_night: bool = false
var _is_strike_of_midnight: bool = false
var _is_strike_of_midday: bool = false

var turn_counter: int:
	get:
		return _turn_counter
	set(value):
		var prev_phase: DayPhase = _phase
		_turn_counter = value
		_recompute_date()
		var new_phase: DayPhase = _phase

		_is_strike_of_midnight = (new_phase == DayPhase.MIDNIGHT) and (prev_phase != DayPhase.MIDNIGHT)
		_is_strike_of_midday = (new_phase == DayPhase.MIDDAY) and (prev_phase != DayPhase.MIDDAY)

var day: int:
	get:
		return _day

var hour: int:
	get:
		return _hour

var is_night: bool:
	get:
		return _is_night

var phase: DayPhase:
	get:
		return _phase

## Checks if it is just midnight.
var is_strike_of_midnight: bool:
	get:
		return _is_strike_of_midnight

## Checks if it is just midday.
var is_strike_of_midday: bool:
	get:
		return _is_strike_of_midday


func _init(turn_counter: int = 0) -> void:
	assert(turn_counter >= 0, "turnCounter < 0")
	_turn_counter = turn_counter
	_recompute_date()


## C# copy constructor WorldTime(WorldTime src).
static func from_world_time(src: WorldTime) -> WorldTime:
	return WorldTime.new(src.turn_counter)


func _recompute_date() -> void:
	var counter := _turn_counter

	_day = counter / TURNS_PER_DAY
	counter -= _day * TURNS_PER_DAY

	_hour = counter / TURNS_PER_HOUR
	counter -= _hour * TURNS_PER_HOUR

	match _hour:
		0:
			_phase = DayPhase.MIDNIGHT
			_is_night = true
		1, 2, 3, 4, 5:
			_phase = DayPhase.DEEP_NIGHT
			_is_night = true
		6:
			_phase = DayPhase.SUNRISE
			_is_night = false
		7, 8, 9, 10, 11:
			_phase = DayPhase.MORNING
			_is_night = false
		12:
			_phase = DayPhase.MIDDAY
			_is_night = false
		13, 14, 15, 16, 17:
			_phase = DayPhase.AFTERNOON
			_is_night = false
		18:
			_phase = DayPhase.SUNSET
			_is_night = true
		19, 20, 21, 22, 23:
			_phase = DayPhase.EVENING
			_is_night = true
		_:
			assert(false, "unhandled hour")


func _to_string() -> String:
	return "day %d hour %02d" % [day, hour]


static func make_time_duration_message(turns: int) -> String:
	# less than a hour?
	if turns < TURNS_PER_HOUR:
		return "less than a hour"

	# less than a day?
	if turns < TURNS_PER_DAY:
		var hours := turns / TURNS_PER_HOUR
		if hours == 1:
			return "about 1 hour"
		return "about %d hours" % hours

	# day(s).
	var time := WorldTime.new(turns)
	if time.day == 1:
		return "about 1 day"
	return "about %d days" % time.day


# --- save system ---
func serialize() -> Dictionary:
	return {"turn_counter": _turn_counter}


static func deserialize_data(data: Dictionary) -> WorldTime:
	return WorldTime.new(data.get("turn_counter", 0))
