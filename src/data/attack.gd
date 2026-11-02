class_name Attack
extends RefCounted
## Port of Data/Attack.cs
## One attack roll (melee, firearm or bow). Immutable after creation.

enum AttackKind {
	PHYSICAL,
	FIREARM,
	BOW,
}

enum FireMode {
	DEFAULT = 0,
	RAPID,
	_COUNT,
}


## Blank attack.
static var BLANK: Attack = Attack.new(
		AttackKind.PHYSICAL, Verb.new("<blank>"), 0, 0, 0, 0, 0, 0, 0)

# Hit roll value.
var hit_value: int
# Damage roll value.
var damage_value: int
# Additional stamina cost for performing the attack.
var stamina_penalty: int
# alpha10: disarm chance.
var disarm_chance: int
# Renamed from C# "Range" (shadows a GDScript built-in function).
var range_value: int
## Secondary hit roll value. Eg: rapid fire 1st shot.
var hit2_value: int
## Tertiary hit roll value. Eg: rapid fire 2nd shot.
var hit3_value: int

var kind: AttackKind
var verb: Verb


func _init(p_kind: AttackKind, p_verb: Verb, p_hit_value: int, p_hit2_value: int,
		p_hit3_value: int, p_damage_value: int, p_stamina_penalty: int,
		p_disarm_chance: int, p_range_value: int) -> void:
	assert(p_verb != null)
	kind = p_kind
	verb = p_verb
	hit_value = p_hit_value
	hit2_value = p_hit2_value
	hit3_value = p_hit3_value
	damage_value = p_damage_value
	stamina_penalty = p_stamina_penalty
	disarm_chance = p_disarm_chance
	range_value = p_range_value


func efficient_range() -> int:
	return range_value / 2


## Constructor for actor base melee attacks
## (C# overload Attack(kind, verb, hitValue, damageValue)).
static func new_base_melee(p_kind: AttackKind, p_verb: Verb, p_hit_value: int,
		p_damage_value: int) -> Attack:
	return Attack.new(p_kind, p_verb, p_hit_value, p_hit_value, p_hit_value,
			p_damage_value, 0, 0, 0)


static func melee_attack(p_verb: Verb, p_hit_value: int, p_damage_value: int,
		p_stamina_penalty: int, p_disarm_chance: int) -> Attack:
	return Attack.new(AttackKind.PHYSICAL, p_verb, p_hit_value, p_hit_value,
			p_hit_value, p_damage_value, p_stamina_penalty, p_disarm_chance, 0)


static func ranged_attack(p_kind: AttackKind, p_verb: Verb,
		p_normal_hit_value: int, p_rapid_fire1_hit_value: int,
		p_rapid_fire2_hit_value: int, p_damage_value: int, p_range_value: int) -> Attack:
	return Attack.new(p_kind, p_verb, p_normal_hit_value, p_rapid_fire1_hit_value,
			p_rapid_fire2_hit_value, p_damage_value, 0, 0, p_range_value)


# --- save system ---
func serialize() -> Dictionary:
	return {
		"hit_value": hit_value,
		"damage_value": damage_value,
		"stamina_penalty": stamina_penalty,
		"disarm_chance": disarm_chance,
		"range_value": range_value,
		"hit2_value": hit2_value,
		"hit3_value": hit3_value,
		"kind": kind,
		"verb": (verb.serialize() as Variant) if verb != null else null,
	}


static func deserialize_data(data: Dictionary) -> Attack:
	var verb_data = data.get("verb")
	var _verb: Verb = Verb.deserialize_data(verb_data) if verb_data != null else Verb.new("hit")
	return Attack.new(data.get("kind", AttackKind.PHYSICAL), _verb,
		data.get("hit_value", 0), data.get("hit2_value", 0), data.get("hit3_value", 0),
		data.get("damage_value", 0), data.get("stamina_penalty", 0),
		data.get("disarm_chance", 0), data.get("range_value", 0))
