class_name Rules
extends RefCounted
## Port of Engine/Rules.cs
## Mostly static rule methods : dice rolls, stats queries, combat resolution,
## condition checks. Methods reference Session / RogueGame / GameImages which
## are ported separately; they are called as-is.

# Constants

const BASE_ACTION_COST: int = 100
const BASE_SPEED: int = BASE_ACTION_COST

# Stamina

## Marker for infinite stamina, value doesnt matter since !Abilities.CanTire is checked instead.
const STAMINA_INFINITE: int = 99

## Minimum stamina for doing tiring actions (melee, running, jumping...)
const STAMINA_MIN_FOR_ACTIVITY: int = 10

## Stamina cost for running.
const STAMINA_COST_RUNNING: int = 4

## Bonus to stamina when waiting.
const STAMINA_REGEN_WAIT: int = 2

## Bonus to stamina each turn.
const STAMINA_REGEN_PER_TURN: int = 2

## Stamina cost for jumping.
const STAMINA_COST_JUMP: int = 8

## Stamina cost for melee fighting.
const STAMINA_COST_MELEE_ATTACK: int = 8

## Stamina cost for moving with a dragged corpse.
const STAMINA_COST_MOVE_DRAGGED_CORPSE: int = 8

# Stumbling

const JUMP_STUMBLE_CHANCE: int = 25
const JUMP_STUMBLE_ACTION_COST: int = BASE_ACTION_COST

# Scents

## How much scent living actors drop on their tile.
static var LIVING_SCENT_DROP: int = Odor.OdorScent.MAX_STRENGTH

## How much scent undead masters drop on their tile.
static var UNDEAD_MASTER_SCENT_DROP: int = Odor.OdorScent.MAX_STRENGTH

# Barricading

static var BARRICADING_MAX: int = 2 * DoorWindow.BASE_HITPOINTS

# FOV

const MINIMAL_FOV: int = 2

# Day/Night and Weather effects

const FOV_PENALTY_SUNSET: int = 1
const FOV_PENALTY_EVENING: int = 2
const FOV_PENALTY_MIDNIGHT: int = 3
const FOV_PENALTY_DEEP_NIGHT: int = 4
const FOV_PENALTY_SUNRISE: int = 2
const NIGHT_STA_PENALTY: int = 2

const FOV_PENALTY_RAIN: int = 1
const FOV_PENALTY_HEAVY_RAIN: int = 2

# Weapons & Firing

const MELEE_WEAPON_BREAK_CHANCE: int = 1
const MELEE_WEAPON_FRAGILE_BREAK_CHANCE: int = 3
const MELEE_DISARM_BASE_CHANCE: int = 5  # alpha10
const FIREARM_JAM_CHANCE_NO_RAIN: int = 1
const FIREARM_JAM_CHANCE_RAIN: int = 3
const FIRING_WHEN_STA_TIRED: float = 0.75     # -25%
const FIRING_WHEN_STA_NOT_FULL: float = 0.90  # -10%
# alpha10 made into constants
const FIRING_WHEN_SLP_EXHAUSTED: float = 0.50  # -50%
const FIRING_WHEN_SLP_SLEEPY: float = 0.75     # -25%

# Body armors

const BODY_ARMOR_BREAK_CHANCE: int = 2

# Hunger/Rot & Sleep & Sanity

static var FOOD_BASE_POINTS: int = WorldTime.TURNS_PER_HOUR * 48
static var FOOD_HUNGRY_LEVEL: int = FOOD_BASE_POINTS / 2

static var ROT_BASE_POINTS: int = WorldTime.TURNS_PER_DAY * 4
static var ROT_HUNGRY_LEVEL: int = ROT_BASE_POINTS / 2

static var SLEEP_BASE_POINTS: int = WorldTime.TURNS_PER_HOUR * 60  # 60 = starting game at midnight => sleepy in late evening.
static var SLEEP_SLEEPY_LEVEL: int = SLEEP_BASE_POINTS / 2

static var SANITY_BASE_POINTS: int = WorldTime.TURNS_PER_DAY * 4
static var SANITY_UNSTABLE_LEVEL: int = SANITY_BASE_POINTS / 2
const SANITY_NIGHTMARE_CHANCE: int = 2
static var SANITY_NIGHTMARE_SLP_LOSS: int = 2 * WorldTime.TURNS_PER_HOUR
static var SANITY_NIGHTMARE_SAN_LOSS: int = WorldTime.TURNS_PER_HOUR
static var SANITY_NIGHTMARE_STA_LOSS: int = 10 * STAMINA_COST_RUNNING  # alpha10 -- worth running for 10 turns
const SANITY_INSANE_ACTION_CHANCE: int = 5

static var SANITY_HIT_BUTCHERING_CORPSE: int = WorldTime.TURNS_PER_HOUR
static var SANITY_HIT_UNDEAD_EATING_CORPSE: int = 2 * WorldTime.TURNS_PER_HOUR
static var SANITY_HIT_LIVING_EATING_CORPSE: int = 4 * WorldTime.TURNS_PER_HOUR
static var SANITY_HIT_EATEN_ALIVE: int = 4 * WorldTime.TURNS_PER_HOUR
static var SANITY_HIT_ZOMBIFY: int = 2 * WorldTime.TURNS_PER_HOUR
static var SANITY_HIT_BOND_DEATH: int = 8 * WorldTime.TURNS_PER_HOUR

# alpha10 increased san recovery; chating & trading also recover san
static var SANITY_RECOVER_KILL_UNDEAD: int = 3 * WorldTime.TURNS_PER_HOUR  # was 2h
const SANITY_RECOVER_BOND_CHANCE: int = 5
static var SANITY_RECOVER_BOND: int = 4 * WorldTime.TURNS_PER_HOUR  # was 1h
static var SANITY_RECOVER_CHAT_OR_TRADE: int = 3 * WorldTime.TURNS_PER_HOUR

## When starving, chance of dying from starvation each turn.
const FOOD_STARVING_DEATH_CHANCE: int = 5

## When eating expired food, chances of vomitting.
const FOOD_EXPIRED_VOMIT_CHANCE: int = 25

## Stamina lost for vomitting.
const FOOD_VOMIT_STA_COST: int = 100

## When rot-starving % chance to loose an HP.
const ROT_STARVING_HP_CHANCE: int = 5

## When rot-hungry % chance to loose a skill.
const ROT_HUNGRY_SKILL_CHANCE: int = 5

## When exhausted, chance of collapsing each turn.
const SLEEP_EXHAUSTION_COLLAPSE_CHANCE: int = 5

## When sleeping on a couch, how many sleep points per turn are regenerated.
static var SLEEP_COUCH_SLEEPING_REGEN: int = 1 + SLEEP_BASE_POINTS / (12 * WorldTime.TURNS_PER_HOUR)

## When sleeping out of a couch, how many sleep points per turn are regenerated.
static var SLEEP_NOCOUCH_SLEEPING_REGEN: int = (2 * SLEEP_COUCH_SLEEPING_REGEN) / 3

## When sleeping on a couch, chance to heal per turn.
const SLEEP_ON_COUCH_HEAL_CHANCE: int = 5

## When sleeping and healing, how many HPs regained.
const SLEEP_HEAL_HITPOINTS: int = 2

# Loud noises

const LOUD_NOISE_RADIUS: int = 5
const LOUD_NOISE_BASE_WAKEUP_CHANCE: int = 10
const LOUD_NOISE_DISTANCE_BONUS: int = 10

# Victims dropping items.

const VICTIM_DROP_GENERIC_ITEM_CHANCE: int = 50
const VICTIM_DROP_AMMOFOOD_ITEM_CHANCE: int = 100

# Improvised weapons

const IMPROVED_WEAPONS_FROM_BROKEN_WOOD_CHANCE: int = 25

# alpha10 replaced with rapid fire attacks property of ranged weapons

# Trackers

const ZTRACKINGRADIUS: int = 6

# Actor weight

const DEFAULT_ACTOR_WEIGHT: int = 10

# Things on fire

## When raining, chance per turn to test effects on fire on the map.
## 100 = will check every rain turn. Not recommended as it eats CPU.
const FIRE_RAIN_TEST_CHANCE: int = 1

## Chance for rain to put out a fire.
const FIRE_RAIN_PUT_OUT_CHANCE: int = 10

# Trust & Bond

const TRUST_NEUTRAL: int = 0
static var TRUST_TRUSTING_THRESHOLD: int = 12 * WorldTime.TURNS_PER_HOUR  # 12h of sticking together.
static var TRUST_MIN: int = -TRUST_TRUSTING_THRESHOLD
static var TRUST_MAX: int = 4 * TRUST_TRUSTING_THRESHOLD
static var TRUST_BOND_THRESHOLD: int = TRUST_MAX
const TRUST_BASE_INCREASE: int = 1                                        # 1pt per turn.
static var TRUST_GOOD_GIFT_INCREASE: int = 3 * WorldTime.TURNS_PER_HOUR   # 3 trust-hours gained.
static var TRUST_MISC_GIFT_INCREASE: int = TRUST_BASE_INCREASE + TRUST_GOOD_GIFT_INCREASE / 10
static var TRUST_GIVE_ITEM_ORDER_PENALTY: int = -WorldTime.TURNS_PER_HOUR  # 1 trust-hours lost.
static var TRUST_LEADER_KILL_ENEMY: int = 3 * WorldTime.TURNS_PER_HOUR     # 3 trust-hours gain.

# Murder

const MURDERER_SPOTTING_BASE_CHANCE: int = 5
const MURDERER_SPOTTING_DISTANCE_PENALTY: int = 1
const MURDER_SPOTTING_MURDERCOUNTER_BONUS: int = 5

# Infection & Corpses

const INFECTION_BASE_FACTOR: float = 1.0

static var INFECTION_LEVEL_1_WEAK: int = 10
static var INFECTION_LEVEL_2_TIRED: int = 30
static var INFECTION_LEVEL_3_VOMIT: int = 50
static var INFECTION_LEVEL_4_BLEED: int = 75
static var INFECTION_LEVEL_5_DEATH: int = 100

static var INFECTION_LEVEL_1_WEAK_STA: int = 24  # 16;
static var INFECTION_LEVEL_2_TIRED_STA: int = 24  # 16;
static var INFECTION_LEVEL_2_TIRED_SLP: int = 3 * WorldTime.TURNS_PER_HOUR  # 2 * WorldTime.TURNS_PER_HOUR;
static var INFECTION_LEVEL_4_BLEED_HP: int = 6  # 4;

static var INFECTION_EFFECT_TRIGGER_CHANCE_1000: int = int(1000 * 2.0 / WorldTime.TURNS_PER_DAY)

const CORPSE_ZOMBIFY_BASE_CHANCE: int = 0
static var CORPSE_ZOMBIFY_DELAY: int = 6 * WorldTime.TURNS_PER_HOUR
const CORPSE_ZOMBIFY_INFECTIONP_FACTOR: float = 1.0  # 1% infection = X% to raise when checked.
const CORPSE_ZOMBIFY_NIGHT_FACTOR: float = 2.0
const CORPSE_ZOMBIFY_DAY_FACTOR: float = 0.01
const CORPSE_ZOMBIFY_TIME_FACTOR: float = 1.0 / WorldTime.TURNS_PER_DAY  # -1% per day
const CORPSE_EATING_NUTRITION_FACTOR: float = 10.0
const CORPSE_EATING_INFECTION_FACTOR: float = 0.1

const CORPSE_DECAY_PER_TURN: float = 4.0 / WorldTime.TURNS_PER_DAY  # -1 HP per day ~ 1 week to rot at 30 HP.

# Refugees

const GIVE_RARE_ITEM_DAY: int = 7
const GIVE_RARE_ITEM_CHANCE: int = 5

# alpha10
# Traps

const TRAP_UNDEAD_ACTOR_TRIGGER_PENALTY: int = 30
const TRAP_SMALL_ACTOR_AVOID_BONUS: int = 90
const CRUSHING_GATES_DAMAGE: int = 60  # alpha10.1

# Skills limits & bonuses per level

const UPGRADE_SKILLS_TO_CHOOSE_FROM: int = 5
const UNDEAD_UPGRADE_SKILLS_TO_CHOOSE_FROM: int = 2

## Actual skill values will be read from Skills.csv so they are not const.

# Livings
# alpha10 updated default values to their current values in Skills.csv, was confusing.

static var SKILL_AGILE_ATK_BONUS: int = 2
static var SKILL_AGILE_DEF_BONUS: int = 4

static var SKILL_AWAKE_SLEEP_BONUS: float = 0.10
static var SKILL_AWAKE_SLEEP_REGEN_BONUS: float = 0.15

static var SKILL_BOWS_ATK_BONUS: int = 10
static var SKILL_BOWS_DMG_BONUS: int = 4

static var SKILL_CARPENTRY_BARRICADING_BONUS: float = 0.15
static var SKILL_CARPENTRY_LEVEL3_BUILD_BONUS: int = 1

static var SKILL_CHARISMATIC_TRUST_BONUS: int = 2
static var SKILL_CHARISMATIC_TRADE_BONUS: int = 10

static var SKILL_FIREARMS_ATK_BONUS: int = 10
static var SKILL_FIREARMS_DMG_BONUS: int = 2

static var SKILL_HARDY_HEAL_CHANCE_BONUS: int = 1

static var SKILL_HAULER_INV_BONUS: int = 1

static var SKILL_HIGH_STAMINA_STA_BONUS: int = 8

static var SKILL_LEADERSHIP_FOLLOWER_BONUS: int = 1

static var SKILL_LIGHT_EATER_MAXFOOD_BONUS: float = 0.10
static var SKILL_LIGHT_EATER_FOOD_BONUS: float = 0.15

static var SKILL_LIGHT_FEET_TRAP_BONUS: int = 15  # alpha10 prev value was 5

static var SKILL_LIGHT_SLEEPER_WAKEUP_CHANCE_BONUS: int = 20  # alpha10 prev value was 10

static var SKILL_MARTIAL_ARTS_ATK_BONUS: int = 6
static var SKILL_MARTIAL_ARTS_DMG_BONUS: int = 2
static var SKILL_MARTIAL_ARTS_DISARM_BONUS: int = 10  # alpha10

static var SKILL_MEDIC_BONUS: float = 0.15
static var SKILL_MEDIC_REVIVE_BONUS: int = 10
static var SKILL_MEDIC_LEVEL_FOR_REVIVE_EST: int = 1

static var SKILL_NECROLOGY_UNDEAD_BONUS: int = 2
static var SKILL_NECROLOGY_CORPSE_BONUS: int = 4
static var SKILL_NECROLOGY_LEVEL_FOR_INFECTION: int = 3
static var SKILL_NECROLOGY_LEVEL_FOR_RISE: int = 5

static var SKILL_STRONG_PSYCHE_LEVEL_BONUS: float = 0.15

static var SKILL_STRONG_DMG_BONUS: int = 2
static var SKILL_STRONG_THROW_BONUS: int = 1
static var SKILL_STRONG_RESIST_DISARM_BONUS: int = 5  # alpha10

static var SKILL_TOUGH_HP_BONUS: int = 6

static var SKILL_UNSUSPICIOUS_BONUS: int = 20  # alpha10

static var UNSUSPICIOUS_BAD_OUTFIT_PENALTY: int = 75  # alpha10 ; prev was 50
static var UNSUSPICIOUS_GOOD_OUTFIT_BONUS: int = 75   # alpha10 ; prev was 50

# Undeads

static var SKILL_ZAGILE_ATK_BONUS: int = 1
static var SKILL_ZAGILE_DEF_BONUS: int = 2

static var SKILL_ZSTRONG_DMG_BONUS: int = 2

static var SKILL_ZTOUGH_HP_BONUS: int = 4

static var SKILL_ZEATER_REGEN_BONUS: float = 0.20

static var SKILL_ZTRACKER_SMELL_BONUS: float = 0.10

static var SKILL_ZLIGHT_FEET_TRAP_BONUS: int = 3

static var SKILL_ZGRAB_CHANCE: int = 4  # alpha10 prev was 2

static var SKILL_ZINFECTOR_BONUS: float = 0.15

static var SKILL_ZLIGHT_EATER_MAXFOOD_BONUS: float = 0.15
static var SKILL_ZLIGHT_EATER_FOOD_BONUS: float = 0.10

# Fields

var _dice_roller: DiceRoller


# Properties

var dice_roller: DiceRoller:
	get:
		return _dice_roller


# Init

func _init(dice_roller: DiceRoller) -> void:
	assert(dice_roller != null, "diceRoller")
	_dice_roller = dice_roller


# Rolling & Random choices

## Roll in range [min, max[.
func roll(p_min: int, p_max: int) -> int:
	return _dice_roller.roll(p_min, p_max)


func roll_chance(chance: int) -> bool:
	return _dice_roller.roll_chance(chance)


func roll_float() -> float:
	return _dice_roller.roll_float()


## Apply a random deviation to a value.
## deviation : amount (not percentage!) of deviation from value
func randomize_value(value: float, deviation: float) -> float:
	var half_deviation := deviation / 2.0
	return value - half_deviation * _dice_roller.roll_float() + half_deviation * _dice_roller.roll_float()


func roll_x(map: Map) -> int:
	assert(map != null, "map")
	return _dice_roller.roll(0, map.width)


func roll_y(map: Map) -> int:
	assert(map != null, "map")
	return _dice_roller.roll(0, map.height)


func roll_direction() -> Direction:
	return Direction.COMPASS[_dice_roller.roll(0, 8)]


## [0, skillValue]
func roll_skill(skill_value: int) -> int:
	if skill_value <= 0:
		return 0
	# bell curve results = less extremes => favor higher skill vs lower skill
	return (_dice_roller.roll(0, skill_value + 1) + _dice_roller.roll(0, skill_value + 1)) / 2


## [damageValue/2, damageValue]
func roll_damage(damage_value: int) -> int:
	if damage_value <= 0:
		return 0
	return _dice_roller.roll(damage_value / 2, damage_value + 1)


func roll_neighbour_in_map(from: Location) -> Location:
	while true:
		var next: Location = from.plus(roll_direction())

		if next.map != from.map:
			continue

		if from.map.is_in_bounds(next.position.x, next.position.y):
			return next
	return null


## C# out param nextLocation -> returns {"ok": bool, "location": Location}.
func roll_valid_move_in_map(actor: Actor, max_tries: int) -> Dictionary:
	assert(actor != null, "actor")

	for i in max_tries:
		var next_location: Location = roll_neighbour_in_map(actor.location)

		if is_walkable_for(actor, next_location.map, next_location.position.x, next_location.position.y)["ok"]:
			return {"ok": true, "location": next_location}

	return {"ok": false, "location": actor.location}


## C# out param direction -> returns {"ok": bool, "direction": Direction}.
func roll_valid_move_direction(actor: Actor, max_tries: int) -> Dictionary:
	assert(actor != null, "actor")

	for i in max_tries:
		var direction: Direction = roll_direction()
		var next_location: Location = actor.location.plus(direction)
		if next_location.map != actor.location.map:
			continue
		if is_walkable_for_at(actor, next_location)["ok"]:
			return {"ok": true, "direction": direction}

	return {"ok": false, "direction": null}


## C# out param direction -> returns {"ok": bool, "direction": Direction}.
func roll_valid_bump_direction(actor: Actor, max_tries: int) -> Dictionary:
	assert(actor != null, "actor")

	for i in max_tries:
		var direction: Direction = roll_direction()
		var next_location: Location = actor.location.plus(direction)
		if next_location.map != actor.location.map:
			continue
		return {"ok": true, "direction": direction}

	return {"ok": false, "direction": null}

# Rules checking

## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_get_item_from_container(actor: Actor, position: Vector2i) -> Dictionary:
	# 1. Map object is not a container.
	var map_obj: MapObject = actor.location.map.get_map_object_at(position)
	if map_obj == null || not map_obj.is_container:
		return {"ok": false, "fail_reason": "object is not a container"}

	# 2. There is no items there.
	var inv_there: Inventory = actor.location.map.get_items_at(position)
	if inv_there == null || inv_there.is_empty:
		return {"ok": false, "fail_reason": "nothing to take there"}

	# 3. Actor cannot take the item.
	if not actor.model.abilities.has_inventory || \
			not actor.model.abilities.can_use_map_objects || \
			actor.inventory == null || \
			not can_actor_get_item(actor, inv_there.top_item)["ok"]:
		return {"ok": false, "fail_reason": "cannot take an item"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_get_item(actor: Actor, it: Item) -> Dictionary:
	# 1. Actor cannot take items.
	if not actor.model.abilities.has_inventory || \
			not actor.model.abilities.can_use_map_objects || \
			actor.inventory == null:
		return {"ok": false, "fail_reason": "no inventory"}
	if actor.inventory.is_full && not actor.inventory.can_add_at_least_one(it):
		return {"ok": false, "fail_reason": "inventory is full"}
	if it is ItemTrap && (it as ItemTrap).is_triggered:
		return {"ok": false, "fail_reason": "triggered trap"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_equip_item(actor: Actor, it: Item) -> Dictionary:
	# 1. Actor cant use items.
	if not actor.model.abilities.can_use_items:
		return {"ok": false, "fail_reason": "no ability to use items"}

	# 2. Item not equipable.
	if not it.model.is_equipable():
		return {"ok": false, "fail_reason": "this item cannot be equipped"}

	# (DISABLED 3. No free slot on doll.)
	# reason: equipping automatically unequip other first.

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_unequip_item(actor: Actor, it: Item) -> Dictionary:
	# 1. Not equipped.
	if not it.is_equipped:
		return {"ok": false, "fail_reason": "not equipped"}

	# 2. Not in inventory.
	var inv: Inventory = actor.inventory
	if inv == null || not inv.contains(it):
		return {"ok": false, "fail_reason": "not in inventory"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_drop_item(actor: Actor, it: Item) -> Dictionary:
	# 1. Equipped.
	if it.is_equipped:
		return {"ok": false, "fail_reason": "unequip first"}

	# 2. Not in inventory.
	var inv: Inventory = actor.inventory
	if inv == null || not inv.contains(it):
		return {"ok": false, "fail_reason": "not in inventory"}

	# all clear.
	return {"ok": true, "fail_reason": ""}

## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_use_item(actor: Actor, it: Item) -> Dictionary:
	# 1. Actor cant use items.
	if not actor.model.abilities.can_use_items:
		return {"ok": false, "fail_reason": "no ability to use items"}

	# 2. Actor cant use this specific kind of items.
	if it is ItemWeapon:
		return {"ok": false, "fail_reason": "to use a weapon, equip it"}
	elif it is ItemFood && not actor.model.abilities.has_to_eat:
		return {"ok": false, "fail_reason": "no ability to eat"}
	elif it is ItemAmmo:
		var ammo_it: ItemAmmo = it
		# Can't use ammo if
		# 1. No compatible weapon equipped.
		# 2. Weapon fully loaded.
		# 1. No compatible weapon equipped.
		var eq_ranged: ItemRangedWeapon = actor.get_equipped_weapon() as ItemRangedWeapon
		if eq_ranged == null || eq_ranged.ammo_type != ammo_it.ammo_type:
			return {"ok": false, "fail_reason": "no compatible ranged weapon equipped"}
		# 2. Weapon fully loaded.
		if eq_ranged.ammo >= (eq_ranged.model as ItemRangedWeaponModel).max_ammo:
			return {"ok": false, "fail_reason": "weapon already fully loaded"}
		# fine!
	# alpha10 new way to use spray scent
	# else if (it is ItemSprayScent) { ... }
	elif it is ItemTrap:
		var trap: ItemTrap = it
		if not trap.trap_model().use_to_activate():
			return {"ok": false, "fail_reason": "does not activate manually"}
	elif it is ItemEntertainment:
		if not actor.model.abilities.is_intelligent:
			return {"ok": false, "fail_reason": "not intelligent"}
		if (it as ItemEntertainment).is_boring_for(actor):  # alpha10 boring items item centric
			return {"ok": false, "fail_reason": "bored by this"}

	# (3. Actor cant use item in his present state.)
	# todo if needed.

	# 4. Not in inventory.
	var inv: Inventory = actor.inventory
	if inv == null || not inv.contains(it):
		return {"ok": false, "fail_reason": "not in inventory"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_eat_food_on_ground(actor: Actor, it: Item) -> Dictionary:
	# 1. Item not food.
	if not (it is ItemFood):
		return {"ok": false, "fail_reason": "not food"}

	# 2. Item not in actor tile.
	var stack_here: Inventory = actor.location.map.get_items_at(actor.location.position)
	if stack_here == null || not stack_here.contains(it):
		return {"ok": false, "fail_reason": "item not here"}

	# ok
	return {"ok": true, "fail_reason": ""}


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_recharge_item_battery(actor: Actor, it: Item) -> Dictionary:
	# 1. Actor cant use items.
	if not actor.model.abilities.can_use_items:
		return {"ok": false, "fail_reason": "no ability to use items"}

	# 2. Item not equipped.
	if not it.is_equipped || not actor.inventory.contains(it):
		return {"ok": false, "fail_reason": "item not equipped"}

	# 3. Not a battery powered item.
	if not is_item_battery_powered(it):
		return {"ok": false, "fail_reason": "not a battery powered item"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


func is_item_battery_powered(it: Item) -> bool:
	if it == null:
		return false
	return it is ItemLight || it is ItemTracker


func is_item_battery_full(it: Item) -> bool:
	if it == null:
		return true
	var light := it as ItemLight
	if light != null && light.is_fully_charged:
		return true
	var tracker := it as ItemTracker
	if tracker != null && tracker.is_fully_charged:
		return true
	return false


## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_give_item_to(actor: Actor, target: Actor, gift: Item) -> Dictionary:
	# 1. Target is enemy.
	if are_enemies(actor, target):
		return {"ok": false, "fail_reason": "enemy"}

	# 2. Item is equipped.
	if gift.is_equipped:
		return {"ok": false, "fail_reason": "equipped"}

	# 3. Target is sleeping.
	if target.is_sleeping:
		return {"ok": false, "fail_reason": "sleeping"}

	# 4. Target can't receive item.
	var r: Dictionary = can_actor_get_item(target, gift)
	if not r["ok"]:
		return r

	# all clear.
	return {"ok": true, "fail_reason": ""}


# alpha10
## C# out param reason -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_spray_odor_suppressor(actor: Actor, suppressor: ItemSprayScent, spray_on: Actor) -> Dictionary:
	# 1. Actor cannot use items
	if not actor.model.abilities.can_use_items:
		return {"ok": false, "fail_reason": "cannot use items"}

	# 2. Not an odor suppressor
	if suppressor.odor() != Odor.SUPPRESSOR:
		return {"ok": false, "fail_reason": "not an odor suppressor"}

	# 2. Spray is not equiped by actor or has no spray left.
	if suppressor.spray_quantity <= 0:
		return {"ok": false, "fail_reason": "no spray left"}
	if not (suppressor.is_equipped && (actor.inventory != null && actor.inventory.contains(suppressor))):
		return {"ok": false, "fail_reason": "spray not equipped"}

	# 3. SprayOn is not self or adjacent.
	if spray_on != actor:
		if not (actor.location.map == spray_on.location.map && is_adjacent(actor.location.position, spray_on.location.position)):
			return {"ok": false, "fail_reason": "not adjacent"}

	# all clear.
	return {"ok": true, "fail_reason": ""}

## C# CanActorRun(actor, out reason) -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_run(actor: Actor) -> Dictionary:
	# 1. Has not CanRun ability.
	if not actor.model.abilities.can_run:
		return {"ok": false, "fail_reason": "no ability to run"}

	# 2. Stamina below min level.
	if actor.stamina_points < STAMINA_MIN_FOR_ACTIVITY:
		return {"ok": false, "fail_reason": "not enough stamina to run"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


func is_actor_tired(actor: Actor) -> bool:
	return actor.model.abilities.can_tire && actor.stamina_points < STAMINA_MIN_FOR_ACTIVITY


## C# CanActorMeleeAttack(actor, target, out reason) -> Dictionary {"ok": bool, "fail_reason": String}.
func can_actor_melee_attack(actor: Actor, target: Actor) -> Dictionary:
	# 1. Target not adjacent in map or not sharing an exit.
	if actor.location.map == target.location.map:
		if not is_adjacent(actor.location.position, target.location.position):
			return {"ok": false, "fail_reason": "not adjacent"}
	else:
		# check there is an exit at both positions.
		var from_exit: Map.Exit = actor.location.map.get_exit_at(actor.location.position)
		if from_exit == null:
			return {"ok": false, "fail_reason": "not reachable"}
		var to_exit: Map.Exit = target.location.map.get_exit_at(target.location.position)
		if to_exit == null:
			return {"ok": false, "fail_reason": "not reachable"}
		# check the target stands on the exit.
		if from_exit.to_map != target.location.map || from_exit.to_position != target.location.position:
			return {"ok": false, "fail_reason": "not reachable"}

	# 2. Stamina below min level.
	if actor.stamina_points < STAMINA_MIN_FOR_ACTIVITY:
		return {"ok": false, "fail_reason": "not enough stamina to attack"}

	# 3. Target is dead (doh!).
	# oddly this can happen for the AI when simulating... not clear why...
	# so this is a lame fix to prevent KillingActor from throwing an exception :-)
	if target.is_dead:
		return {"ok": false, "fail_reason": "already dead!"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


func has_actor_jump_ability(actor: Actor) -> bool:
	return actor.model.abilities.can_jump || \
		actor.sheet.skill_table.get_skill_level(Skills.IDs.AGILE) > 0 || \
		actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_AGILE) > 0


## C# IsWalkableFor(actor, map, x, y, out reason) and the Location overload,
## merged into one function (GDScript has no overloads):
## - is_walkable_for(actor, map, x, y)
## - is_walkable_for(actor, location)
## Returns Dictionary {"ok": bool, "fail_reason": String}.
func is_walkable_for(actor: Actor, map_or_loc, x = null, y = null) -> Dictionary:
	if map_or_loc is Location:
		return _is_walkable_for_xy(actor, map_or_loc.map, map_or_loc.position.x, map_or_loc.position.y)
	return _is_walkable_for_xy(actor, map_or_loc, x, y)


## C# IsWalkableFor(actor, location, out reason) -> same Dictionary.
func is_walkable_for_at(actor: Actor, location: Location) -> Dictionary:
	return _is_walkable_for_xy(actor, location.map, location.position.x, location.position.y)


func _is_walkable_for_xy(actor: Actor, map: Map, x: int, y: int) -> Dictionary:
	############################
	# Not walkable if any is true:
	# 1. Out of map.
	# 2. Tile not walkable.
	# 3. Map object not passable.
	# 4. An actor already there.
	# 5. Dragging a corpse when tired.
	############################
	# 1. Out of map.
	if not map.is_in_bounds(x, y):
		return {"ok": false, "fail_reason": "out of map"}

	# 2. Tile not walkable.
	if not map.get_tile_at(x, y).model.is_walkable:
		return {"ok": false, "fail_reason": "blocked"}

	# 3. Map object not passable.
	var map_obj: MapObject = map.get_map_object_at_xy(x, y)
	if map_obj != null:
		if not map_obj.is_walkable:
			# jump?
			if map_obj.is_jumpable:
				if not has_actor_jump_ability(actor):
					return {"ok": false, "fail_reason": "cannot jump"}
				if actor.stamina_points < STAMINA_COST_JUMP:
					return {"ok": false, "fail_reason": "not enough stamina to jump"}
			# small actor blocked only by closed doors.
			elif actor.model.abilities.is_small:
				var door := map_obj as DoorWindow
				if door != null && door.is_closed:
					return {"ok": false, "fail_reason": "cannot slip through closed door"}
			else:
				# nope, blocking object.
				return {"ok": false, "fail_reason": "blocked by object"}

	# 4. An actor already there.
	if map.get_actor_at_xy(x, y) != null:
		return {"ok": false, "fail_reason": "someone is there"}

	# 5. Dragging a corpse when tired.
	if actor.dragged_corpse != null && is_actor_tired(actor):
		return {"ok": false, "fail_reason": "dragging a corpse when tired"}

	# all checks clear.
	return {"ok": true, "fail_reason": ""}


## C# IsBumpableFor(actor, game, map, x, y, out reason) and the Location
## overload, merged (GDScript has no overloads):
## - is_bumpable_for(actor, game, map, x, y)
## - is_bumpable_for(actor, game, location)
## Returns Dictionary {"ok": bool, "action": ActorAction, "fail_reason": String}.
func is_bumpable_for(actor: Actor, game, map_or_loc, x = null, y = null) -> Dictionary:
	if map_or_loc is Location:
		return _is_bumpable_for_xy(actor, game, map_or_loc.map, map_or_loc.position.x, map_or_loc.position.y)
	return _is_bumpable_for_xy(actor, game, map_or_loc, x, y)


func _is_bumpable_for_xy(actor: Actor, game, map: Map, x: int, y: int) -> Dictionary:
	var reason := ""

	# Out of map : leave district?
	if not map.is_in_bounds(x, y):
		var r: Dictionary = can_actor_leave_map(actor)
		if r["ok"]:
			return {"ok": true, "action": ActionLeaveMap.new(actor, game, Vector2i(x, y)), "fail_reason": ""}
		else:
			return {"ok": false, "action": null, "fail_reason": r["fail_reason"]}

	# 1. Movement?
	# 2. Actor interact: fight or chat?
	# 3. Object interact?
	# 4. No action possible.
	var to := Vector2i(x, y)

	# 1. Move?
	var move_action: ActionMoveStep = ActionMoveStep.new_to(actor, game, to)
	if move_action.is_legal():
		return {"ok": true, "action": move_action, "fail_reason": ""}
	else:
		reason = move_action.fail_reason

	# 2. Actor interact: fight/chat/(AI:switch place)
	var target_actor: Actor = map.get_actor_at(to)
	if target_actor != null:
		# attacking?
		if are_enemies(actor, target_actor):
			var r2: Dictionary = can_actor_melee_attack(actor, target_actor)
			if r2["ok"]:
				return {"ok": true, "action": ActionMeleeAttack.new(actor, game, target_actor), "fail_reason": ""}
			else:
				return {"ok": false, "action": null, "fail_reason": r2["fail_reason"]}

		# AI: switching place  # alpha10.1 handle bot like it was an AI
		if (not actor.is_player || actor.is_bot_player) && \
				not target_actor.is_player:
			var r3: Dictionary = can_actor_switch_place_with(actor, target_actor)
			if r3["ok"]:
				return {"ok": true, "action": ActionSwitchPlace.new(actor, game, target_actor), "fail_reason": ""}
			else:
				reason = r3["fail_reason"]

		# chatting?
		var r4: Dictionary = can_actor_chat_with(actor, target_actor)
		if r4["ok"]:
			return {"ok": true, "action": ActionChat.new(actor, game, target_actor), "fail_reason": ""}
		else:
			reason = r4["fail_reason"]

		# nope, blocked.
		return {"ok": false, "action": null, "fail_reason": reason}

	# 3. Object interact?
	var map_obj: MapObject = map.get_map_object_at(to)
	if map_obj != null:
		# 3.1 Door?
		var door := map_obj as DoorWindow
		if door != null:
			if door.is_closed:  # closed: open/bash/barricade
				var r5: Dictionary = is_openable_for(actor, door)
				if r5["ok"]:
					return {"ok": true, "action": ActionOpenDoor.new(actor, game, door), "fail_reason": ""}
				var r6: Dictionary = is_bashable_for(actor, door)
				if r6["ok"]:
					return {"ok": true, "action": ActionBashDoor.new(actor, game, door), "fail_reason": ""}
				else:
					return {"ok": false, "action": null, "fail_reason": r6["fail_reason"]}
			if door.barricade_points > 0:  # barricaded: bash
				var r7: Dictionary = is_bashable_for(actor, door)
				if r7["ok"]:
					return {"ok": true, "action": ActionBashDoor.new(actor, game, door), "fail_reason": ""}
				else:
					return {"ok": false, "action": null, "fail_reason": "cannot bash the barricade"}

		# 3.2 Container?
		var r8: Dictionary = can_actor_get_item_from_container(actor, to)
		if r8["ok"]:
			return {"ok": true, "action": ActionGetFromContainer.new(actor, game, to), "fail_reason": ""}

		# alpha10.1 removed break restriction, made civs ai get stuck in some rare cases but we punish break actions in baseai wander.
		# 3.3 Break?
		var r9: Dictionary = is_breakable_for(actor, map_obj)
		if r9["ok"]:
			return {"ok": true, "action": ActionBreak.new(actor, game, map_obj), "fail_reason": ""}
		# 3.3 Break? Only allow bashing actors to do that (don't want Civilians to bash stuff on their way)
		#if actor.Model.Abilities.CanBashDoors && IsBreakableFor(actor, mapObj, out reason))
		#    return new ActionBreak(actor, game, mapObj);

		# 3.4 Power Generator?
		var pow_gen := map_obj as PowerGenerator
		if pow_gen != null:
			# Recharge battery powered item?
			if pow_gen.is_on:
				var left_item: Item = actor.get_equipped_item(Doll.DollPart.LEFT_HAND)
				if left_item != null && can_actor_recharge_item_battery(actor, left_item)["ok"]:
					return {"ok": true, "action": ActionRechargeItemBattery.new(actor, game, left_item), "fail_reason": ""}
				var right_item: Item = actor.get_equipped_item(Doll.DollPart.RIGHT_HAND)
				if right_item != null && can_actor_recharge_item_battery(actor, right_item)["ok"]:
					return {"ok": true, "action": ActionRechargeItemBattery.new(actor, game, right_item), "fail_reason": ""}

			# Switch?
			var r10: Dictionary = is_switchable_for(actor, pow_gen)
			if r10["ok"]:
				# switch it.
				return {"ok": true, "action": ActionSwitchPowerGenerator.new(actor, game, pow_gen), "fail_reason": ""}

			# Can do nothing by bumping.
			return {"ok": false, "action": null, "fail_reason": r10["fail_reason"]}

	# 4. No action possible?
	# reason = "blocked"
	return {"ok": false, "action": null, "fail_reason": reason}


## C# IsBumpableFor(actor, game, location, out reason) -> same Dictionary as above.
func is_bumpable_for_at(actor: Actor, game, location: Location) -> Dictionary:
	return is_bumpable_for(actor, game, location.map, location.position.x, location.position.y)


# Switching Map Objects

## C# IsSwitchableFor(actor, powGen, out reason) -> Dictionary.
func is_switchable_for(actor: Actor, pow_gen: PowerGenerator) -> Dictionary:
	# 1. Actor has ability.
	if not actor.model.abilities.can_use_map_objects:
		return {"ok": false, "fail_reason": "cannot use map objects"}

	# 2. Is not sleeping.
	if actor.is_sleeping:
		return {"ok": false, "fail_reason": "is sleeping"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Leaving maps

## C# CanActorLeaveMap(actor, out reason) -> Dictionary.
func can_actor_leave_map(actor: Actor) -> Dictionary:
	# 1. Player and not bot # alpha10.1
	if not actor.is_player || actor.is_bot_player:
		return {"ok": false, "fail_reason": "can't leave maps"}

	return {"ok": true, "fail_reason": ""}


# Using exits

## C# CanActorUseExit(actor, exitPoint, out reason) -> Dictionary.
func can_actor_use_exit(actor: Actor, exit_point: Vector2i) -> Dictionary:
	# 1. No exit there.
	if actor.location.map.get_exit_at(exit_point) == null:
		return {"ok": false, "fail_reason": "no exit there"}

	# 2. AI: can't use AI exits.
	# alpha10.1 handle bots
	if (not actor.is_player || actor.is_bot_player) && not actor.model.abilities.ai_can_use_ai_exits:
		return {"ok": false, "fail_reason": "this AI can't use exits"}

	# 3. Is sleeping.
	if actor.is_sleeping:
		return {"ok": false, "fail_reason": "is sleeping"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Chatting & Trading

## C# CanActorChatWith(speaker, target, out reason) -> Dictionary.
func can_actor_chat_with(speaker: Actor, target: Actor) -> Dictionary:
	# 1. One of them can't talk.
	if not speaker.model.abilities.can_talk:
		return {"ok": false, "fail_reason": "can't talk"}
	if not target.model.abilities.can_talk:
		return {"ok": false, "fail_reason": "%s can't talk" % target.the_name}

	# 2. One of them is sleeping.
	if speaker.is_sleeping:
		return {"ok": false, "fail_reason": "sleeping"}
	if target.is_sleeping:
		return {"ok": false, "fail_reason": "%s is sleeping" % target.the_name}

	# all clear.
	return {"ok": true, "fail_reason": ""}

## C# CanActorInitiateTradeWith(speaker, target, out reason) -> Dictionary.
func can_actor_initiate_trade_with(speaker: Actor, target: Actor) -> Dictionary:
	# 1. Target is player.
	if target.is_player:
		return {"ok": false, "fail_reason": "target is player"}

	# 2. Actors are not traders and not leader->follower relationship.
	if not speaker.model.abilities.can_trade && target.leader != speaker:
		return {"ok": false, "fail_reason": "can't trade"}
	if not target.model.abilities.can_trade && target.leader != speaker:
		return {"ok": false, "fail_reason": "target can't trade"}

	if are_enemies(speaker, target):
		return {"ok": false, "fail_reason": "is an enemy"}

	# 3. Target is sleeping.
	if target.is_sleeping:
		return {"ok": false, "fail_reason": "is sleeping"}

	# 4. No item to trade.
	if speaker.inventory == null || speaker.inventory.is_empty:
		return {"ok": false, "fail_reason": "nothing to offer"}
	if target.inventory == null || target.inventory.is_empty:
		return {"ok": false, "fail_reason": "has nothing to trade"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# CanActorShout(speaker, out reason) -> Dictionary.
func can_actor_shout(speaker: Actor) -> Dictionary:
	# 1. Actor is sleeping.
	if speaker.is_sleeping:
		return {"ok": false, "fail_reason": "sleeping"}

	# 2. Actor can't talk
	if not speaker.model.abilities.can_talk:
		return {"ok": false, "fail_reason": "can't talk"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Doors

## C# IsOpenableFor(actor, door, out reason) -> Dictionary.
func is_openable_for(actor: Actor, door: DoorWindow) -> Dictionary:
	# 1. Actor cannot use map objects.
	if not actor.model.abilities.can_use_map_objects:
		return {"ok": false, "fail_reason": "no ability to open"}

	# 2. Door is not closed nor barricaded.
	if not door.is_closed || door.barricade_points > 0:
		return {"ok": false, "fail_reason": "not closed nor barricaded"}

	# all clear
	return {"ok": true, "fail_reason": ""}


## C# IsClosableFor(actor, door, out reason) -> Dictionary.
func is_closable_for(actor: Actor, door: DoorWindow) -> Dictionary:
	# 1. Actor cannot use map objects.
	if not actor.model.abilities.can_use_map_objects:
		return {"ok": false, "fail_reason": "can't use objects"}

	# 2. Door is not open.
	if not door.is_open:
		return {"ok": false, "fail_reason": "not open"}

	# 3. Another actor here.
	if door.location.map.get_actor_at(door.location.position) != null:
		return {"ok": false, "fail_reason": "someone is there"}

	# all clear
	return {"ok": true, "fail_reason": ""}


## C# CanActorBarricadeDoor(actor, door, out reason) -> Dictionary.
func can_actor_barricade_door(actor: Actor, door: DoorWindow) -> Dictionary:
	# 1. Actor cannot barricade doors.
	if not actor.model.abilities.can_barricade:
		return {"ok": false, "fail_reason": "no ability to barricade"}

	# 2. Door is not closed or broken.
	if door.state != DoorWindow.STATE_CLOSED && door.state != DoorWindow.STATE_BROKEN:
		return {"ok": false, "fail_reason": "not closed or broken"}  # alpha10 typo fix

	# 3. Barricading limit reached.
	if door.barricade_points >= BARRICADING_MAX:
		return {"ok": false, "fail_reason": "barricade limit reached"}

	# 4. An actor is there.
	if door.location.map.get_actor_at(door.location.position) != null:
		return {"ok": false, "fail_reason": "someone is there"}

	# 5. No barricading material.
	if actor.inventory == null || actor.inventory.is_empty:
		return {"ok": false, "fail_reason": "no items"}
	if not actor.inventory.has_item_of_type(ItemBarricadeMaterial):
		return {"ok": false, "fail_reason": "no barricading material"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Bashing doors & Breaking stuff

## C# IsBashableFor(actor, door, out reason) -> Dictionary.
func is_bashable_for(actor: Actor, door: DoorWindow) -> Dictionary:
	# 1. Actor cannot bash doors.
	if not actor.model.abilities.can_bash_doors:
		return {"ok": false, "fail_reason": "can't bash doors"}

	# 2. Actor is tired.
	if is_actor_tired(actor):
		return {"ok": false, "fail_reason": "tired"}

	# 2. Door is not breakable.
	if door.break_state != MapObject.Break.BREAKABLE && not door.is_barricaded:
		return {"ok": false, "fail_reason": "can't break this object"}

	# all clear
	return {"ok": true, "fail_reason": ""}

## C# IsBreakableFor(actor, mapObj, out reason) -> Dictionary.
func is_breakable_for(actor: Actor, map_obj: MapObject) -> Dictionary:
	# 1. Actor cannot break.
	if not actor.model.abilities.can_break_objects:
		return {"ok": false, "fail_reason": "cannot break objects"}

	# 2. Actor is tired.
	if is_actor_tired(actor):
		return {"ok": false, "fail_reason": "tired"}

	# 3. Map object is not breakable.
	var door := map_obj as DoorWindow
	var is_barricaded_door := (door != null && door.is_barricaded)
	if map_obj.break_state != MapObject.Break.BREAKABLE && not is_barricaded_door:
		return {"ok": false, "fail_reason": "can't break this object"}

	# 4. Another actor there.
	if map_obj.location.map.get_actor_at(map_obj.location.position) != null:
		return {"ok": false, "fail_reason": "someone is there"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Pushing/Pulling objects & Shoving actors

func has_actor_push_ability(actor: Actor) -> bool:
	return actor.model.abilities.can_push || \
		actor.sheet.skill_table.get_skill_level(Skills.IDs.STRONG) > 0 || \
		actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_STRONG) > 0


## C# CanActorPush(actor, mapObj, out reason) -> Dictionary.
func _can_actor_push(actor: Actor, map_obj: MapObject) -> Dictionary:
	# 1. Actor cannot push/pull.
	if not has_actor_push_ability(actor):
		return {"ok": false, "fail_reason": "cannot push objects"}

	# 2. Actor is tired.
	if is_actor_tired(actor):
		return {"ok": false, "fail_reason": "tired"}

	# 3. Map obj is not movable.
	if not map_obj.is_movable:
		return {"ok": false, "fail_reason": "cannot be moved"}

	# 4. Another actor there.
	if map_obj.location.map.get_actor_at(map_obj.location.position) != null:
		return {"ok": false, "fail_reason": "someone is there"}

	# 5. Map obj is on fire.
	if map_obj.is_on_fire:
		return {"ok": false, "fail_reason": "on fire"}

	# 6. Actor is dragging a corpse.  # alpha10
	if actor.dragged_corpse != null:
		return {"ok": false, "fail_reason": "dragging a corpse"}

	# all clear
	return {"ok": true, "fail_reason": ""}


## C# CanActorPush(actor, mapObj) bool overload; existing action code calls it
## in boolean context. Full reason-aware version is _can_actor_push().
func can_actor_push(actor: Actor, map_obj: MapObject) -> bool:
	return _can_actor_push(actor, map_obj)["ok"]


## C# CanPushObjectTo(mapObj, toPos, out reason) -> Dictionary.
func can_push_object_to(map_obj: MapObject, to_pos: Vector2i) -> Dictionary:
	# 1. Out of bounds.
	if not map_obj.location.map.is_in_bounds_p(to_pos):
		return {"ok": false, "fail_reason": "out of map"}

	# 2. Not walkable.
	if not map_obj.location.map.get_tile_at(to_pos.x, to_pos.y).model.is_walkable:
		return {"ok": false, "fail_reason": "blocked by an obstacle"}

	# 3. Another object there.
	if map_obj.location.map.get_map_object_at(to_pos) != null:
		return {"ok": false, "fail_reason": "blocked by an object"}

	# 4. An actor there.
	if map_obj.location.map.get_actor_at(to_pos) != null:
		return {"ok": false, "fail_reason": "blocked by someone"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# alpha10
## C# CanPullObject(actor, mapObj, moveToPos, out reason) -> Dictionary.
func can_pull_object(actor: Actor, map_obj: MapObject, move_to_pos: Vector2i) -> Dictionary:
	# Basically check if can push and can walk.
	# 1. Actor cannot push this object.
	var r: Dictionary = _can_actor_push(actor, map_obj)
	if not r["ok"]:
		return r

	# 2. Another object already there. eg: actor standing on a bed.
	var other_mobj: MapObject = actor.location.map.get_map_object_at(actor.location.position)
	if other_mobj != null:
		return {"ok": false, "fail_reason": "%s is blocking" % other_mobj.the_name}

	# 3. Actor cannot walk to pos.
	if not is_walkable_for_at(actor, Location.new(actor.location.map, move_to_pos))["ok"]:
		return {"ok": false, "fail_reason": "cannot walk there"}

	# all clear
	return {"ok": true, "fail_reason": ""}


# alpha10
## C# CanPullActor(actor, other, moveToPos, out reason) -> Dictionary.
func can_pull_actor(actor: Actor, other: Actor, move_to_pos: Vector2i) -> Dictionary:
	# Basically check if can push and can walk.
	# 1. Actor cannot shove.
	var r: Dictionary = can_actor_shove(actor, other)
	if not r["ok"]:
		return r

	# 3. Actor cannot walk to pos.
	if not is_walkable_for_at(actor, Location.new(actor.location.map, move_to_pos))["ok"]:
		return {"ok": false, "fail_reason": "cannot walk there"}

	# all clear
	return {"ok": true, "fail_reason": ""}


## C# CanActorShove(actor, other, out reason) -> Dictionary.
func can_actor_shove(actor: Actor, other: Actor) -> Dictionary:
	# 1. Actor cannot push/pull.
	if not has_actor_push_ability(actor):
		return {"ok": false, "fail_reason": "cannot shove people"}

	# 2. Actor is tired.
	if is_actor_tired(actor):
		return {"ok": false, "fail_reason": "tired"}

	# 3. Actor is dragging corpse  # alpha10
	if actor.dragged_corpse != null:
		return {"ok": false, "fail_reason": "dragging a corpse"}

	# FIXME: in theory, should test if tile is walkable for the pusher. in practice, assume if other can walk here, we can too...
	#        this will cause problems in zombie mode (eg: undead player pushing living down from a car = move on the car...)

	# all clear
	return {"ok": true, "fail_reason": ""}


## C# CanShoveActorTo(actor, toPos, out reason) -> Dictionary.
func can_shove_actor_to(actor: Actor, to_pos: Vector2i) -> Dictionary:
	var map: Map = actor.location.map

	# 1. Out of bounds.
	if not map.is_in_bounds_p(to_pos):
		return {"ok": false, "fail_reason": "out of map"}

	# 2. Not walkable.
	if not map.get_tile_at(to_pos.x, to_pos.y).model.is_walkable:
		return {"ok": false, "fail_reason": "blocked"}

	# 3. Unwalkable object.
	var obj: MapObject = map.get_map_object_at(to_pos)
	if obj != null && not obj.is_walkable:
		return {"ok": false, "fail_reason": "blocked by an object"}

	# 4. An actor there.
	if map.get_actor_at(to_pos) != null:
		return {"ok": false, "fail_reason": "blocked by someone"}

	# 5. Actor is dragging corpse  # alpha10
	if actor.dragged_corpse != null:
		return {"ok": false, "fail_reason": "dragging a corpse"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Targeting, Firing and Throwing

## List enemies in fov, sorted by distance (closest first).
## Returns an Array of Actor or null if none.
func get_enemies_in_fov(actor: Actor, fov) -> Array:
	var list = null

	for pt in fov:
		var other: Actor = actor.location.map.get_actor_at(pt)
		if other == null:
			continue
		if other == actor:
			continue
		if not are_enemies(actor, other):
			continue

		if list == null:
			list = []
		list.append(other)

	if list != null:
		var actor_pos: Vector2i = actor.location.position
		var by_distance := func(a, b) -> bool:
			var d_a := std_distance(a.location.position, actor_pos)
			var d_b := std_distance(b.location.position, actor_pos)
			return d_a < d_b
		list.sort_custom(by_distance)

	return list


## C# CanActorFireAt(actor, target, out reason) and the LoF overloads
## -> Dictionary {"ok": bool, "fail_reason": String}; lof is an optional
## Array cleared and filled with the line of fire points.
func can_actor_fire_at(actor: Actor, target: Actor, lof = null) -> Dictionary:
	# 1. No ranged weapon or out of range.
	# 2. No ammo.
	# 3. No LoF.
	# 4. Target is dead (doh!).
	if lof != null:
		lof.clear()

	# 1. No ranged weapon or out of range.
	var ranged_weapon: ItemRangedWeapon = actor.get_equipped_weapon() as ItemRangedWeapon
	if ranged_weapon == null:
		return {"ok": false, "fail_reason": "no ranged weapon equipped"}
	if actor.current_ranged_attack.range_value < grid_distance_points(actor.location.position, target.location.position):
		return {"ok": false, "fail_reason": "out of range"}

	# 2. No ammo.
	if ranged_weapon.ammo <= 0:
		return {"ok": false, "fail_reason": "no ammo left"}

	# 3. No LoF.
	if not LOS.can_trace_fire_line(actor.location, target.location.position, actor.current_ranged_attack.range_value, lof):
		return {"ok": false, "fail_reason": "no line of fire"}

	# 4. Target is dead (doh!).
	# oddly this can happen for the AI when simulating... not clear why...
	# so this is a lame fix to prevent KillingActor from throwing an exception :-)
	if target.is_dead:
		return {"ok": false, "fail_reason": "already dead!"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# CanActorThrowTo(actor, pos, LoF, out reason) -> Dictionary.
func can_actor_throw_to(actor: Actor, pos: Vector2i, lof = null) -> Dictionary:
	# 1. No throwable item or out of range.
	# 2. No LoT.
	if lof != null:
		lof.clear()

	# 1. No throwable item or out of range.
	var unprimed_grenade: ItemGrenade = actor.get_equipped_weapon() as ItemGrenade
	var primed_grenade: ItemGrenadePrimed = actor.get_equipped_weapon() as ItemGrenadePrimed
	if unprimed_grenade == null && primed_grenade == null:
		return {"ok": false, "fail_reason": "no grenade equiped"}
	var model: ItemGrenadeModel
	if unprimed_grenade != null:
		model = unprimed_grenade.model as ItemGrenadeModel
	else:
		model = (primed_grenade.model as ItemGrenadePrimedModel).grenade_model
	var max_throw_dist := actor_max_throw_range(actor, model.max_throw_distance)
	if grid_distance_points(actor.location.position, pos) > max_throw_dist:
		return {"ok": false, "fail_reason": "out of throwing range"}

	# 2. No LoT.
	if not LOS.can_trace_throw_line(actor.location, pos, max_throw_dist, lof):
		return {"ok": false, "fail_reason": "no line of throwing"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Hunger/Rot & Sleep & Sanity

func is_actor_hungry(a: Actor) -> bool:
	return a.model.abilities.has_to_eat && a.food_points <= FOOD_HUNGRY_LEVEL


func is_actor_starving(a: Actor) -> bool:
	return a.model.abilities.has_to_eat && a.food_points <= 0


func is_rotting_actor_hungry(a: Actor) -> bool:
	return a.model.abilities.is_rotting && a.food_points <= ROT_HUNGRY_LEVEL


func is_rotting_actor_starving(a: Actor) -> bool:
	return a.model.abilities.is_rotting && a.food_points <= 0


func is_food_still_fresh(food: ItemFood, turn_counter: int) -> bool:
	if not food.is_perishable:
		return true
	return turn_counter < food.best_before.turn_counter


func is_food_expired(food: ItemFood, turn_counter: int) -> bool:
	return food.is_perishable && turn_counter >= food.best_before.turn_counter && turn_counter < 2 * food.best_before.turn_counter


func is_food_spoiled(food: ItemFood, turn_counter: int) -> bool:
	return food.is_perishable && turn_counter >= 2 * food.best_before.turn_counter

func food_item_nutrition(food: ItemFood, turn_counter: int) -> int:
	if is_food_still_fresh(food, turn_counter):
		return food.nutrition
	elif is_food_expired(food, turn_counter):
		return 2 * food.nutrition / 3
	else:
		return food.nutrition / 3


func is_actor_sleepy(a: Actor) -> bool:
	return a.model.abilities.has_to_sleep && a.sleep_points <= SLEEP_SLEEPY_LEVEL


func is_actor_exhausted(a: Actor) -> bool:
	return a.model.abilities.has_to_sleep && a.sleep_points <= 0


func sleep_to_hours_until_sleepy(sleep: int, is_night: bool) -> int:
	var left := sleep - SLEEP_SLEEPY_LEVEL
	if is_night:
		left = left / 2
	if left <= 0:
		return 0
	return left / WorldTime.TURNS_PER_HOUR


func is_almost_sleepy(actor: Actor) -> bool:
	if not actor.model.abilities.has_to_sleep:
		return false
	return sleep_to_hours_until_sleepy(actor.sleep_points, actor.location.map.local_time.is_night) <= 3


## C# CanActorSleep(actor, out reason) -> Dictionary.
func can_actor_sleep(actor: Actor) -> Dictionary:
	# 1. Already sleeping.
	if actor.is_sleeping:
		return {"ok": false, "fail_reason": "already sleeping"}

	# 2. Has not to sleep.
	if not actor.model.abilities.has_to_sleep:
		return {"ok": false, "fail_reason": "no ability to sleep"}

	# 3. Is hungry or worse.
	if is_actor_hungry(actor) || is_actor_starving(actor):
		return {"ok": false, "fail_reason": "hungry"}

	# 4. No need to sleep.
	if actor.sleep_points >= actor_max_sleep(actor) - WorldTime.TURNS_PER_HOUR:
		return {"ok": false, "fail_reason": "not sleepy at all"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


func is_on_couch(actor: Actor) -> bool:
	var map_obj: MapObject = actor.location.map.get_map_object_at(actor.location.position)
	if map_obj == null:
		return false

	return map_obj.is_couch


func is_actor_disturbed(a: Actor) -> bool:
	return a.model.abilities.has_sanity && a.sanity <= actor_disturbed_level(a)


func is_actor_insane(a: Actor) -> bool:
	return a.model.abilities.has_sanity && a.sanity <= 0


func sanity_to_hours_until_unstable(a: Actor) -> int:
	var left := a.sanity - actor_disturbed_level(a)
	if left <= 0:
		return 0
	return left / WorldTime.TURNS_PER_HOUR


# Leading

## C# CanActorTakeLead(actor, target, out reason) -> Dictionary.
func can_actor_take_lead(actor: Actor, target: Actor) -> Dictionary:
	# 1. Target is undead or an enemy.
	if target.model.abilities.is_undead:
		return {"ok": false, "fail_reason": "undead"}
	if are_enemies(actor, target):
		return {"ok": false, "fail_reason": "enemy"}

	# 2. Target is sleeping.
	if target.is_sleeping:
		return {"ok": false, "fail_reason": "sleeping"}

	# 3. Target has already a leader and can't steal the follower.  alpha10.1
	if target.has_leader:
		# alpha10.1
		# can "steal" followers only if actor has better charismatic skill than current leader
		var actor_charism: int = actor.sheet.skill_table.get_skill_level(Skills.IDs.CHARISMATIC)
		var leader_charism: int = target.leader.sheet.skill_table.get_skill_level(Skills.IDs.CHARISMATIC)
		if actor_charism <= leader_charism:
			return {"ok": false, "fail_reason": "has already a leader at least as charismatic as you"}

	# 4. Target is a leader.
	if target.count_followers > 0:
		return {"ok": false, "fail_reason": "is a leader"}

	# 5. Actor has reached max followers.
	var max_followers := actor_max_followers(actor)
	if max_followers == 0:
		return {"ok": false, "fail_reason": "can't lead"}
	if actor.count_followers >= max_followers:
		return {"ok": false, "fail_reason": "too many followers"}

	# 6. Target is player!
	if target.is_player:
		return {"ok": false, "fail_reason": "is player"}

	# 7. Faction restrictions.
	if actor.faction != target.faction && target.faction.lead_only_by_same_faction:
		return {"ok": false, "fail_reason": "%s can't lead %s" % [actor.faction.name, target.faction.name]}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# CanActorCancelLead(actor, target, out reason) -> Dictionary.
func can_actor_cancel_lead(actor: Actor, target: Actor) -> Dictionary:
	# 1. Target not a actor follower.
	if target.leader != actor:
		return {"ok": false, "fail_reason": "not your follower"}

	# 2. Target is sleeping.
	if target.is_sleeping:
		return {"ok": false, "fail_reason": "sleeping"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# CanActorSwitchPlaceWith(actor, target, out reason) -> Dictionary.
func can_actor_switch_place_with(actor: Actor, target: Actor) -> Dictionary:
	# 1. Target not a actor follower.
	if target.leader != actor:
		return {"ok": false, "fail_reason": "not your follower"}

	# 2. Target is sleeping.
	if target.is_sleeping:
		return {"ok": false, "fail_reason": "sleeping"}

	# all clear.
	return {"ok": true, "fail_reason": ""}

# Trust

func is_actor_trusting_leader(actor: Actor) -> bool:
	if not actor.has_leader:
		return false

	return actor.trust_in_leader >= TRUST_TRUSTING_THRESHOLD


func has_actor_bond_with(actor: Actor, target: Actor) -> bool:
	if actor.leader == target:
		return actor.trust_in_leader >= TRUST_BOND_THRESHOLD
	elif target.leader == actor:
		return target.trust_in_leader >= TRUST_BOND_THRESHOLD
	else:
		return false


# Building & Repairing

func count_barricading_material(actor: Actor) -> int:
	if actor.inventory == null || actor.inventory.is_empty:
		return 0

	var count := 0
	for it: Item in actor.inventory.items:
		if it is ItemBarricadeMaterial:
			count += it.quantity
	return count


## C# CanActorBuildFortification(actor, pos, isLarge, out reason) -> Dictionary.
func can_actor_build_fortification(actor: Actor, pos: Vector2i, is_large: bool) -> Dictionary:
	# 1. No carpentry skill.
	if actor.sheet.skill_table.get_skill_level(Skills.IDs.CARPENTRY) == 0:
		return {"ok": false, "fail_reason": "no skill in carpentry"}

	# 2. Not walkable.
	var map: Map = actor.location.map
	if not map.get_tile_at_p(pos).model.is_walkable:
		return {"ok": false, "fail_reason": "cannot build on walls"}

	# 3. Not enough material.
	var need := actor_barricading_material_need_for_fortification(actor, is_large)
	if count_barricading_material(actor) < need:
		return {"ok": false, "fail_reason": "not enough barricading material, need %d." % need}

	# 4. Tile occupied.
	if map.get_map_object_at(pos) != null || map.get_actor_at(pos) != null:
		return {"ok": false, "fail_reason": "blocked"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


## C# CanActorRepairFortification(actor, fort, out reason) -> Dictionary.
func can_actor_repair_fortification(actor: Actor, fort: Fortification) -> Dictionary:
	# 1. Cannot use map objects.
	if not actor.model.abilities.can_use_map_objects:
		return {"ok": false, "fail_reason": "cannot use map objects"}

	# 2. No material.
	var material := count_barricading_material(actor)
	if material <= 0:
		return {"ok": false, "fail_reason": "no barricading material"}

	# all clear.
	return {"ok": true, "fail_reason": ""}


# Corpses

func actor_damage_vs_corpses(a: Actor) -> int:
	# base = melee HALVED.
	var dmg := a.current_melee_attack.damage_value / 2

	# Necrology.
	dmg += SKILL_NECROLOGY_CORPSE_BONUS * a.sheet.skill_table.get_skill_level(Skills.IDs.NECROLOGY)

	return dmg


## C# CanActorEatCorpse(actor, corpse, out reason) -> Dictionary.
func can_actor_eat_corpse(actor: Actor, corpse: Corpse) -> Dictionary:
	# 1. Actor is not undead or a starving living.
	if not actor.model.abilities.is_undead:
		if not is_actor_starving(actor) && not is_actor_insane(actor):
			return {"ok": false, "fail_reason": "not starving or insane"}

	# ok
	return {"ok": true, "fail_reason": ""}


## C# CanActorButcherCorpse(actor, corpse, out reason) -> Dictionary.
func can_actor_butcher_corpse(actor: Actor, corpse: Corpse) -> Dictionary:
	# 1. Actor tired.
	if is_actor_tired(actor):
		return {"ok": false, "fail_reason": "tired"}
	# 2. Corpse not in same tile as actor.
	if corpse.position != actor.location.position || not actor.location.map.has_corpse(corpse):
		return {"ok": false, "fail_reason": "not in same location"}

	# ok
	return {"ok": true, "fail_reason": ""}


## C# CanActorStartDragCorpse(actor, corpse, out reason) -> Dictionary.
func can_actor_start_drag_corpse(actor: Actor, corpse: Corpse) -> Dictionary:
	# 1. Corpse already dragged.
	if corpse.is_dragged:
		return {"ok": false, "fail_reason": "corpse is already being dragged"}
	# 2. Actor tired.
	if is_actor_tired(actor):
		return {"ok": false, "fail_reason": "tired"}
	# 3. Corpse not in same tile as actor.
	if corpse.position != actor.location.position || not actor.location.map.has_corpse(corpse):
		return {"ok": false, "fail_reason": "not in same location"}
	# 4. Actor already dragging a corpse.
	if actor.dragged_corpse != null:
		return {"ok": false, "fail_reason": "already dragging a corpse"}

	# ok
	return {"ok": true, "fail_reason": ""}


## C# CanActorStopDragCorpse(actor, corpse, out reason) -> Dictionary.
func can_actor_stop_drag_corpse(actor: Actor, corpse: Corpse) -> Dictionary:
	# Can't if Corpse not being dragged by actor.
	if corpse.dragged_by != actor:
		return {"ok": false, "fail_reason": "not dragging this corpse"}

	# ok
	return {"ok": true, "fail_reason": ""}

## C# CanActorReviveCorpse(actor, corpse, out reason) -> Dictionary.
func can_actor_revive_corpse(actor: Actor, corpse: Corpse) -> Dictionary:
	# 1. No medic skill.
	if actor.sheet.skill_table.get_skill_level(Skills.IDs.MEDIC) == 0:
		return {"ok": false, "fail_reason": "lack medic skill"}

	# 2. Not on same tile.
	if corpse.position != actor.location.position:
		return {"ok": false, "fail_reason": "not there"}

	# 3. Corpse not fresh.
	if corpse_rot_level(corpse) > 0:
		return {"ok": false, "fail_reason": "corpse not fresh"}

	# 4. No medikit.
	if not actor.inventory.has_item_matching(func(it): return it.model.id == GameItems.IDs.MEDICINE_MEDIKIT):
		return {"ok": false, "fail_reason": "no medikit"}

	# ok
	return {"ok": true, "fail_reason": ""}


# Distances

func is_adjacent(a, b) -> bool:
	if a is Location:
		if a.map != b.map:
			return false
		return is_adjacent(a.position, b.position)
	return absi(a.x - b.x) < 2 && absi(a.y - b.y) < 2


func grid_distance(p_a: Vector2i, b_x: int, b_y: int) -> int:
	return maxi(absi(p_a.x - b_x), absi(p_a.y - b_y))


## C# GridDistance(Point, Point) -> grid_distance_points to avoid overloading.
func grid_distance_points(p_a: Vector2i, p_b: Vector2i) -> int:
	return maxi(absi(p_a.x - p_b.x), absi(p_a.y - p_b.y))


## Standard distance formula: square root of summed squares.
func std_distance(from: Vector2i, to: Vector2i) -> float:
	var d_x := to.x - from.x
	var d_y := to.y - from.y
	var square := d_x * d_x + d_y * d_y
	return sqrt(float(square))


## C# StdDistance(Point) -> std_distance_vec to avoid overloading.
func std_distance_vec(v: Vector2i) -> float:
	return sqrt(float(v.x * v.x + v.y * v.y))


## Distance to use in LOS computing. Based on standard distance and modified to have a nice circle FOV.
func los_distance(from: Vector2i, to: Vector2i) -> float:
	var d_x := to.x - from.x
	var d_y := to.y - from.y
	var square := d_x * d_x + d_y * d_y
	return sqrt(0.75 * square)  # nice factor to have a smooth circle (0.90: too rough)


# Actor turn ordering

func get_next_actor_to_act(map: Map, turn_counter: int) -> Actor:
	if map == null:
		return null

	var n := map.count_actors
	for i in range(map.check_next_actor_index, n):
		var a: Actor = map.get_actor(i)
		if a.action_points > 0 && not a.is_sleeping:
			map.check_next_actor_index = i
			return a

	return null


func is_actor_before_in_map_list(map: Map, actor: Actor, other: Actor) -> bool:
	for a: Actor in map.actors_list:
		if a == actor:
			return true
		if a == other:
			return false

	# by default, assume yes.
	return true


func can_actor_act_this_turn(actor: Actor) -> bool:
	if actor == null:
		return false

	return actor.action_points > 0


func can_actor_act_next_turn(actor: Actor) -> bool:
	if actor == null:
		return false

	return actor.action_points + actor_speed(actor) > 0


## If actor spend a turn now, will actor get the chance to act before other?
func will_actor_act_again_before(actor: Actor, other: Actor) -> bool:
	# if other can still act, nope.
	if other.action_points > 0:
		return false

	# if other will be able to act next turn BEFORE actor, nope.
	if other.action_points + actor_speed(other) > 0 && is_actor_before_in_map_list(actor.location.map, other, actor):
		return false

	# safe!
	return true


func will_other_act_twice_before(actor: Actor, other: Actor) -> bool:
	if is_actor_before_in_map_list(actor.location.map, actor, other):
		if other.action_points > BASE_ACTION_COST:
			return true
		else:
			return false
	else:
		if other.action_points + actor_speed(other) > BASE_ACTION_COST:
			return true
		else:
			return false


# Actors relations
# alpha10 refactored and rewrote

## Check if both actors are enemies.
## - enemy factions
## - enemy gangs
## - personal enemies
## - group enemies (if check_groups)
## Symetrical, don't need to call for actorB,actorA.
func are_enemies(actor_a: Actor, actor_b: Actor, check_groups: bool = true) -> bool:
	if actor_a == null || actor_b == null:
		return false
	if actor_a == actor_b:  # alpha10 silly fix
		return false

	# Enemy factions? (symetrical)
	if actor_a.faction.is_enemy_of(actor_b.faction):
		return true

	# Enemy gangs? (symetrical)
	if actor_a.faction == actor_b.faction && actor_a.is_in_a_gang && actor_b.is_in_a_gang && actor_a.gang_id != actor_b.gang_id:
		return true

	# alpha10
	# Personal enemies? (symetrical)
	if are_personal_enemies(actor_a, actor_b):
		return true

	# alpha10
	# Enemy of groups (symetrical)
	if check_groups && are_group_enemies(actor_a, actor_b):
		return true

	# Not enemies.
	return false


# alpha10
## Check if they are in an agressor-selfdefence reliation.
## Symetrical, don't need to call for actorB,actorA.
func are_personal_enemies(actor_a: Actor, actor_b: Actor) -> bool:
	if actor_a == null || actor_b == null:
		return false
	if actor_a == actor_b:
		return false

	if actor_a.is_aggressor_of(actor_b):
		return true

	if actor_a.is_self_defence_from(actor_b):
		return true

	# doesnt need to check for target as the relation is symetrical (aggressor of <-> self defence from)
	return false

# alpha10
## Check if they are enmemies through group relations :
## - my leader enemies are my enemies
## - my mates enemies are my enemies.
## - my follower enemies are my enemies.
## Symetrical, don't need to call for actorB,actorA.
func are_group_enemies(actor_a: Actor, actor_b: Actor) -> bool:
	if actor_a == null || actor_b == null:
		return false
	if actor_a == actor_b:
		return false

	# my leader enemies are my enemies.
	# my mates enemies are my enemies.
	if actor_a.has_leader:
		if _is_enemy_of_my_leader_or_mates(actor_a, actor_b):
			return true
	if actor_a.count_followers > 0:
		if _is_enemy_of_my_followers(actor_a, actor_b):
			return true

	# check B group
	if actor_b.has_leader:
		if _is_enemy_of_my_leader_or_mates(actor_b, actor_a):
			return true
	if actor_b.count_followers > 0:
		if _is_enemy_of_my_followers(actor_b, actor_a):
			return true

	# nope
	return false


## C# local function of AreGroupEnemies.
func _is_enemy_of_my_leader_or_mates(group_actor: Actor, target: Actor) -> bool:
	if are_enemies(group_actor.leader, target, false):
		return true
	for mate: Actor in group_actor.leader.followers:
		if mate != group_actor && are_enemies(mate, target, false):
			return true
	return false


## C# local function of AreGroupEnemies.
func _is_enemy_of_my_followers(group_actor: Actor, target: Actor) -> bool:
	for follower: Actor in group_actor.followers:
		if are_enemies(follower, target, false):
			return true
	return false


func is_murder(killer: Actor, victim: Actor) -> bool:
	if killer == null || victim == null:
		return false

	# killing an undead is never a murder (doh!)
	if victim.model.abilities.is_undead:
		return false

	# a law enforcer killing a murderer is not a murder.
	if killer.model.abilities.is_law_enforcer && victim.murders_counter > 0:
		return false

	# killing between enemy factions is allowed.
	if killer.faction.is_enemy_of(victim.faction):
		return false

	# killing in self defence is not a murder.
	if killer.is_self_defence_from(victim):
		return false

	# all other cases are murders!
	return true


# Stats affected by Skills & Status effects

func actor_speed(actor: Actor) -> int:
	var speed := float(actor.doll.body.speed)

	# stamina.
	if is_actor_tired(actor):
		speed *= 2.0 / 3.0

	# sleep.
	if is_actor_exhausted(actor):
		speed /= 2.0
	elif is_actor_sleepy(actor):
		speed *= 2.0 / 3.0

	# wearing armor.
	var armor := actor.get_equipped_item(Doll.DollPart.TORSO) as ItemBodyArmor
	if armor != null:
		speed -= armor.weight

	# dragging corpses.
	if actor.dragged_corpse != null:
		speed /= 2.0

	# done, speed must be >= 0.
	return maxi(int(speed), 0)


func actor_max_hps(actor: Actor) -> int:
	var skill_bonus := (SKILL_TOUGH_HP_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.TOUGH)) \
		+ (SKILL_ZTOUGH_HP_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_TOUGH))

	return actor.sheet.base_hit_points + skill_bonus


func actor_max_sta(actor: Actor) -> int:
	var skill_bonus := SKILL_HIGH_STAMINA_STA_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.HIGH_STAMINA)

	return actor.sheet.base_stamina_points + skill_bonus


func actor_item_nutrition_value(actor: Actor, base_value: int) -> int:
	var skill_bonus := int(base_value * SKILL_LIGHT_EATER_FOOD_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.LIGHT_EATER))

	return base_value + skill_bonus


func actor_max_food(actor: Actor) -> int:
	var skill_bonus := int(actor.sheet.base_food_points * SKILL_LIGHT_EATER_MAXFOOD_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.LIGHT_EATER))

	return actor.sheet.base_food_points + skill_bonus


func actor_max_rot(actor: Actor) -> int:
	var skill_bonus := int(actor.sheet.base_food_points * SKILL_ZLIGHT_EATER_MAXFOOD_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_LIGHT_EATER))

	return actor.sheet.base_food_points + skill_bonus


func actor_max_sleep(actor: Actor) -> int:
	var skill_bonus := int(actor.sheet.base_sleep_points * SKILL_AWAKE_SLEEP_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.AWAKE))

	return actor.sheet.base_sleep_points + skill_bonus


func actor_sleep_regen(actor: Actor, is_on_couch: bool) -> int:
	var base_regen := SLEEP_COUCH_SLEEPING_REGEN if is_on_couch else SLEEP_NOCOUCH_SLEEPING_REGEN
	var skill_bonus := int(base_regen * SKILL_AWAKE_SLEEP_REGEN_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.AWAKE))

	return base_regen + skill_bonus


func actor_max_sanity(actor: Actor) -> int:
	return actor.sheet.base_sanity


func actor_disturbed_level(actor: Actor) -> int:
	var factor := 1.0 - SKILL_STRONG_PSYCHE_LEVEL_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.STRONG_PSYCHE)
	return int(SANITY_UNSTABLE_LEVEL * factor)


func actor_max_inv(actor: Actor) -> int:
	var skill_bonus := SKILL_HAULER_INV_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.HAULER)

	return actor.sheet.base_inventory_capacity + skill_bonus


func actor_damage_bonus_vs_undeads(actor: Actor) -> int:
	return SKILL_NECROLOGY_UNDEAD_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.NECROLOGY)


# alpha10 added mapobject param
func actor_melee_attack(actor: Actor, base_attack: Attack, target: Actor, obj_to_break: MapObject = null) -> Attack:
	var hit := float(base_attack.hit_value)
	var dmg := float(base_attack.damage_value)
	var disarm_bonus := 0  # alpha10

	# skills bonuses.
	var hit_bonus := SKILL_AGILE_ATK_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.AGILE) \
		+ SKILL_ZAGILE_ATK_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_AGILE)
	var dmg_bonus := SKILL_STRONG_DMG_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.STRONG) \
		+ SKILL_ZSTRONG_DMG_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_STRONG)
	# martial arts apply only if no weapon equipped.
	if actor.get_equipped_weapon() == null:
		var ma := actor.sheet.skill_table.get_skill_level(Skills.IDs.MARTIAL_ARTS)
		if ma > 0:
			hit_bonus += SKILL_MARTIAL_ARTS_ATK_BONUS * ma
			dmg_bonus += SKILL_MARTIAL_ARTS_DMG_BONUS * ma
			disarm_bonus += SKILL_MARTIAL_ARTS_DISARM_BONUS * ma

	# necrology vs undeads.
	if target != null && target.model.abilities.is_undead:
		dmg_bonus += actor_damage_bonus_vs_undeads(actor)

	# alpha10
	# add tool damage bonus vs map objects
	if obj_to_break != null:
		var eq_mw: ItemMeleeWeapon = actor.get_equipped_melee_weapon()
		if eq_mw != null:
			dmg_bonus += eq_mw.tool_bash_damage_bonus()

	hit += hit_bonus
	dmg += dmg_bonus

	# alpha10
	# disarm chance.
	var disarm_chance := float(MELEE_DISARM_BASE_CHANCE)
	disarm_chance += disarm_bonus
	# defender strong resist disarm
	if target != null:
		disarm_chance -= SKILL_STRONG_RESIST_DISARM_BONUS * target.sheet.skill_table.get_skill_level(Skills.IDs.STRONG)

	# sleepiness penalties.
	if is_actor_exhausted(actor):
		hit /= 2.0
		disarm_chance /= 2.0
	elif is_actor_sleepy(actor):
		hit *= 3.0 / 4.0
		disarm_chance *= 3.0 / 4.0

	# done.
	return Attack.melee_attack(base_attack.verb, int(hit), int(dmg), base_attack.stamina_penalty, int(disarm_chance))


func actor_ranged_attack(actor: Actor, base_attack: Attack, distance: int, target: Actor) -> Attack:
	var hit_mod := 0
	var dmg_bonus := 0

	# skill bonuses.
	match base_attack.kind:
		Attack.AttackKind.BOW:
			hit_mod = SKILL_BOWS_ATK_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.BOWS)
			dmg_bonus = SKILL_BOWS_DMG_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.BOWS)
		Attack.AttackKind.FIREARM:
			hit_mod = SKILL_FIREARMS_ATK_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.FIREARMS)
			dmg_bonus = SKILL_FIREARMS_DMG_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.FIREARMS)

	if target != null && target.model.abilities.is_undead:
		dmg_bonus += actor_damage_bonus_vs_undeads(actor)

	# distance vs range penalties/bonus.
	var efficient_range: int = base_attack.efficient_range()
	# alpha10 distance as % modifier instead of flat bonus
	var distance_mod := 1.0
	if distance != efficient_range:
		var distance_scale := (efficient_range - distance) / float(base_attack.range_value)
		# bigger effect (penalty) beyond efficient range
		if distance > efficient_range:
			distance_scale *= 2

		distance_mod = 1 + distance_scale
	var hit := (base_attack.hit_value + hit_mod) * distance_mod
	var rapid_hit1 := (base_attack.hit2_value + hit_mod) * distance_mod
	var rapid_hit2 := (base_attack.hit3_value + hit_mod) * distance_mod

	var dmg := float(base_attack.damage_value + dmg_bonus)

	# sleep penalty.
	if is_actor_exhausted(actor):
		hit *= FIRING_WHEN_SLP_EXHAUSTED
		rapid_hit1 *= FIRING_WHEN_SLP_EXHAUSTED
		rapid_hit2 *= FIRING_WHEN_SLP_EXHAUSTED
	elif is_actor_sleepy(actor):
		hit *= FIRING_WHEN_SLP_SLEEPY
		rapid_hit1 *= FIRING_WHEN_SLP_SLEEPY
		rapid_hit2 *= FIRING_WHEN_SLP_SLEEPY

	# stamina penalty.
	if is_actor_tired(actor):
		hit *= FIRING_WHEN_STA_TIRED
		rapid_hit1 *= FIRING_WHEN_STA_TIRED
		rapid_hit2 *= FIRING_WHEN_STA_TIRED
	elif actor.stamina_points < actor_max_sta(actor):
		hit *= FIRING_WHEN_STA_NOT_FULL
		rapid_hit1 *= FIRING_WHEN_STA_NOT_FULL
		rapid_hit2 *= FIRING_WHEN_STA_NOT_FULL

	# return attack.
	return Attack.ranged_attack(base_attack.kind, base_attack.verb, int(hit), int(rapid_hit1), int(rapid_hit2), int(dmg), base_attack.range_value)

## Estimate chances to hit with a ranged attack.
## Simulate a large number of rolls attack vs defence and returns % of hits.
## shot_counter : 0 for normal shot, 1 for 1st rapid fire shot, 2 for 2nd rapid fire shot.
## Returns [0..100].
func compute_chances_ranged_hit(actor: Actor, target: Actor, shot_counter: int) -> int:
	var attack: Attack = actor_ranged_attack(actor, actor.current_ranged_attack, grid_distance_points(actor.location.position, target.location.position), target)
	var defence: Defence = actor_defence(target, target.current_defence)

	var hit_value := attack.hit_value if shot_counter == 0 else (attack.hit2_value if shot_counter == 1 else attack.hit3_value)
	var def_value: int = defence.value

	const ROLLS := 1000
	var hits := 0
	for i in ROLLS:
		var atk_roll := roll_skill(hit_value)
		var def_roll := roll_skill(def_value)
		if atk_roll > def_roll:
			hits += 1

	var percent := (100 * hits) / ROLLS
	return percent


func actor_max_throw_range(actor: Actor, base_range: int) -> int:
	var bonus := SKILL_STRONG_THROW_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.STRONG)

	return base_range + bonus


func actor_defence(actor: Actor, base_defence: Defence) -> Defence:
	# Sleeping actors are defenceless.
	if actor.is_sleeping:
		return Defence.new(0, 0, 0)

	# Base value + skill.
	var def_bonus := SKILL_AGILE_DEF_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.AGILE) \
		+ SKILL_ZAGILE_DEF_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_AGILE)
	var def := float(base_defence.value + def_bonus)

	# Sleepy effect.
	if is_actor_exhausted(actor):
		def /= 2.0
	elif is_actor_sleepy(actor):
		def *= 3.0 / 4.0

	# done.
	return Defence.new(int(def), base_defence.protection_hit, base_defence.protection_shot)


func actor_medicine_effect(actor: Actor, base_effect: int) -> int:
	var effect_bonus := int(ceil(SKILL_MEDIC_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.MEDIC) * base_effect))
	return base_effect + effect_bonus


func actor_heal_chance_bonus(actor: Actor) -> int:
	var chance_bonus := SKILL_HARDY_HEAL_CHANCE_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.HARDY)
	return chance_bonus


func actor_barricading_points(actor: Actor, base_barricading_points: int) -> int:
	var bar_bonus := 0

	# carpentry skill
	bar_bonus += int(base_barricading_points * SKILL_CARPENTRY_BARRICADING_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.CARPENTRY))

	# alpha10
	# tool build bonus
	var eq_mw: ItemMeleeWeapon = actor.get_equipped_melee_weapon()
	if eq_mw != null && eq_mw.tool_build_bonus() != 0:
		bar_bonus += int(base_barricading_points * eq_mw.tool_build_bonus())

	return base_barricading_points + bar_bonus


func actor_max_followers(actor: Actor) -> int:
	return SKILL_LEADERSHIP_FOLLOWER_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.LEADERSHIP)


func actor_fov(actor: Actor, time: WorldTime, weather: int) -> int:
	# Sleeping actors have no FOV.
	if actor.is_sleeping:
		return 0

	# base value.
	var fov := actor.sheet.base_view_range

	# lighting/weather
	var light: Map.Lighting = actor.location.map.lighting
	match light:
		Map.Lighting.DARKNESS:
			# FoV in darkness depends on actor.
			fov = darkness_fov(actor)
		Map.Lighting.LIT:
			# nothing to do, unmodified base FOV.
			pass
		Map.Lighting.OUTSIDE:
			# night & weather penalty
			fov -= night_fov_penalty(actor, time)
			fov -= weather_fov_penalty(actor, weather)
		_:
			assert(false, "unhandled lighting")

	# sleep penalty.
	if is_actor_exhausted(actor):
		fov -= 2
	elif is_actor_sleepy(actor):
		fov -= 1

	# light equipped or standing next to someone with light.
	# works only in darkness or during the night.
	if light == Map.Lighting.DARKNESS || (light == Map.Lighting.OUTSIDE && time.is_night):
		var light_bonus := get_light_bonus_equipped(actor)
		if light_bonus == 0:
			var map: Map = actor.location.map
			var adjacent_has_light := func(pt) -> bool:
				var other: Actor = map.get_actor_at(pt)
				if other == null:
					return false
				return has_light_on_equipped(other)
			if map.has_any_adjacent_in_map(actor.location.position, adjacent_has_light):
				light_bonus = 1
		fov += light_bonus

	# standing on some map objects.
	var mobj: MapObject = actor.location.map.get_map_object_at(actor.location.position)
	if mobj != null && mobj.stand_on_fov_bonus:
		fov += 1

	# done.
	fov = maxi(MINIMAL_FOV, fov)
	return fov


func actor_smell(actor: Actor) -> float:
	return (1.0 + SKILL_ZTRACKER_SMELL_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_TRACKER)) * actor.model.starting_sheet.base_smell_rating


func actor_smell_threshold(actor: Actor) -> int:
	# sleeping actors can't smell.
	if actor.is_sleeping:
		return -1

	# actor model base value.
	var smell_rating := actor_smell(actor)
	var min_smell := 1 + Odor.OdorScent.MAX_STRENGTH - int(smell_rating * Odor.OdorScent.MAX_STRENGTH)
	return min_smell


func has_light_on_equipped(actor: Actor) -> bool:
	var light := actor.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemLight
	return light != null && light.batteries > 0


func get_light_bonus_equipped(actor: Actor) -> int:
	var light := actor.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemLight
	return 0 if light == null || light.batteries <= 0 else light.fov_bonus


func actor_loud_noise_wakeup_chance(actor: Actor, noise_distance: int) -> int:
	var base_chance := LOUD_NOISE_BASE_WAKEUP_CHANCE
	var skill_bonus := SKILL_LIGHT_SLEEPER_WAKEUP_CHANCE_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.LIGHT_SLEEPER)
	var dist_bonus := maxi(0, (LOUD_NOISE_RADIUS - noise_distance) * LOUD_NOISE_DISTANCE_BONUS)

	return base_chance + skill_bonus + dist_bonus


func actor_barricading_material_need_for_fortification(builder: Actor, is_large: bool) -> int:
	var base_cost := 4 if is_large else 2
	var skill_bonus := (SKILL_CARPENTRY_LEVEL3_BUILD_BONUS if builder.sheet.skill_table.get_skill_level(Skills.IDs.CARPENTRY) >= 3 else 0)
	return maxi(1, base_cost - skill_bonus)


func actor_trust_increase(actor: Actor) -> int:
	var skill_bonus := SKILL_CHARISMATIC_TRUST_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.CHARISMATIC)

	return TRUST_BASE_INCREASE + skill_bonus


func actor_charismatic_trade_chance(actor: Actor) -> int:
	return SKILL_CHARISMATIC_TRADE_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.CHARISMATIC)


func actor_unsuspicous_chance(observer: Actor, actor: Actor) -> int:
	# base = unsuspicious skill.
	var base_chance := SKILL_UNSUSPICIOUS_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.UNSUSPICIOUS)

	# bonus.
	var bonus := 0

	# wearing some outfit.
	var armor := actor.get_equipped_item(Doll.DollPart.TORSO) as ItemBodyArmor
	if armor != null:
		if observer.faction.id == GameFactions.IDs.ThePolice:
			if armor.is_hostile_for_cops():
				bonus -= UNSUSPICIOUS_BAD_OUTFIT_PENALTY
			elif armor.is_friendly_for_cops():
				bonus += UNSUSPICIOUS_GOOD_OUTFIT_BONUS
		elif observer.faction.id == GameFactions.IDs.TheBikers:
			if armor.is_hostile_for_biker(observer.gang_id):
				bonus -= UNSUSPICIOUS_BAD_OUTFIT_PENALTY
			elif armor.is_friendly_for_biker(observer.gang_id):
				bonus += UNSUSPICIOUS_GOOD_OUTFIT_BONUS

	return base_chance + bonus


func actor_spot_murderer_chance(spotter: Actor, murderer: Actor) -> int:
	var spotter_bonus := MURDER_SPOTTING_MURDERCOUNTER_BONUS * murderer.murders_counter
	var distance_penalty := MURDERER_SPOTTING_DISTANCE_PENALTY * grid_distance_points(spotter.location.position, murderer.location.position)

	return MURDERER_SPOTTING_BASE_CHANCE + spotter_bonus - distance_penalty

## C# NightFovPenalty(actor, time) -> penalty as number > 0.
func night_fov_penalty(actor: Actor, time: WorldTime) -> int:
	if actor.model.abilities.is_undead:
		return 0
	else:
		match time.phase:
			WorldTime.DayPhase.SUNSET: return FOV_PENALTY_SUNSET
			WorldTime.DayPhase.EVENING: return FOV_PENALTY_EVENING
			WorldTime.DayPhase.MIDNIGHT: return FOV_PENALTY_MIDNIGHT
			WorldTime.DayPhase.DEEP_NIGHT: return FOV_PENALTY_DEEP_NIGHT
			WorldTime.DayPhase.SUNRISE: return FOV_PENALTY_SUNRISE
			_: return 0


func night_stamina_penalty(actor: Actor) -> int:
	if actor.model.abilities.is_undead:
		return 0
	else:
		return NIGHT_STA_PENALTY


## C# WeatherFovPenalty(actor, weather) -> penalty as number > 0.
func weather_fov_penalty(actor: Actor, weather: int) -> int:
	if actor.model.abilities.is_undead:
		return 0
	else:
		match weather:
			Weather.RAIN: return FOV_PENALTY_RAIN
			Weather.HEAVY_RAIN: return FOV_PENALTY_HEAVY_RAIN
			_: return 0


func is_weather_rain(weather: int) -> bool:
	match weather:
		Weather.CLEAR, Weather.CLOUDY:
			return false
		Weather.HEAVY_RAIN, Weather.RAIN:
			return true
		_:
			assert(false, "unhandled weather")
	return false


func darkness_fov(actor: Actor) -> int:
	if actor.model.abilities.is_undead:
		return actor.sheet.base_view_range
	else:
		return MINIMAL_FOV


# alpha10
func odors_decay(map: Map, pos: Vector2i, weather: int) -> int:
	var decay := 0

	# base decay
	decay = 1

	# sewers?
	if map == map.district.sewers_map:
		decay += 2
	# outside? = weather affected.
	elif not map.get_tile_at_p(pos).is_inside:  # alpha10 weather affect only outside tiles
		match weather:
			Weather.CLEAR, Weather.CLOUDY:
				# default decay.
				pass
			Weather.RAIN:
				decay += 1
			Weather.HEAVY_RAIN:
				decay += 2
			_:
				assert(false, "unhandled weather")

	return decay


# alpha10
func can_actor_see_sky(actor: Actor) -> bool:
	if actor.is_dead:
		return false
	if actor.is_sleeping:
		return false
	return actor.location.map.lighting == Map.Lighting.OUTSIDE


func can_actor_know_time(actor: Actor) -> bool:
	if actor.is_dead:
		return false
	if actor.is_sleeping:
		return false
	if actor.location.map.lighting == Map.Lighting.OUTSIDE:
		return true

	var eq_tracker := actor.get_equipped_item(Doll.DollPart.LEFT_HAND) as ItemTracker
	if eq_tracker != null && eq_tracker.has_clock() && eq_tracker.batteries > 0:
		return true

	return false


# Map Power rating

## Compute normalized % of power level on the map. Each activated PowerGenerator
## map object count for one power unit.
## Returns 0.0 = not powered at all to 1.0 = 100% power.
func compute_map_power_ratio(map: Map) -> float:
	var total_on := 0
	var total_off := 0

	for obj: MapObject in map.map_objects_list:
		var pow_gen := obj as PowerGenerator
		if pow_gen == null:
			continue

		if pow_gen.is_on:
			total_on += 1
		else:
			total_off += 1

	var total_count := total_on + total_off
	if total_count == 0:
		return 0.0

	var ratio := float(total_on) / float(total_count)
	return ratio


# Explosions

func blast_damage(distance: int, attack: BlastAttack) -> int:
	assert(distance >= 0 && distance <= attack.radius, "blast distance %d out of range" % distance)

	return attack.damage[distance]


# Undead Regen/Food, Infection and Corpses

func actor_bite_hp_regen(a: Actor, dmg: int) -> int:
	var bonus := int(SKILL_ZEATER_REGEN_BONUS * a.sheet.skill_table.get_skill_level(Skills.IDs.Z_EATER) * dmg)
	return dmg + bonus


func actor_bite_nutrition_value(actor: Actor, base_value: int) -> int:
	var zskill_factor := SKILL_ZLIGHT_EATER_FOOD_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.Z_LIGHT_EATER)
	var skill_factor := SKILL_LIGHT_EATER_FOOD_BONUS * actor.sheet.skill_table.get_skill_level(Skills.IDs.LIGHT_EATER)

	return int(CORPSE_EATING_NUTRITION_FACTOR + zskill_factor + skill_factor) * base_value


func corpse_eeating_infection_transmission(infection: int) -> int:
	return int(CORPSE_EATING_INFECTION_FACTOR * infection)


func actor_infection_hps(a: Actor) -> int:
	return actor_max_hps(a) + actor_max_sta(a)


## C# static InfectionForDamage(infector, dmg).
static func infection_for_damage(infector: Actor, dmg: int) -> int:
	var factor := INFECTION_BASE_FACTOR + infector.sheet.skill_table.get_skill_level(Skills.IDs.Z_INFECTOR) * SKILL_ZINFECTOR_BONUS
	return int(factor * dmg)


func actor_infection_percent(a: Actor) -> int:
	return int(100 * a.infection / actor_infection_hps(a))


func infection_effect_trigger_chance_1000(infection_percent: int) -> int:
	return INFECTION_EFFECT_TRIGGER_CHANCE_1000 + infection_percent / 5


func corpse_freshness_percent(c: Corpse) -> int:
	return int(100 * c.hit_points / actor_max_hps(c.dead_guy))


## Returns [0..5].
func corpse_rot_level(c: Corpse) -> int:
	var fresh_p := corpse_freshness_percent(c)
	if fresh_p < 5:
		return 5
	if fresh_p < 25:
		return 4
	if fresh_p < 50:
		return 3
	if fresh_p < 75:
		return 2
	if fresh_p < 90:
		return 1
	return 0


## C# static CorpseDecayPerTurn(corpse).
static func corpse_decay_per_turn(c: Corpse) -> float:
	return CORPSE_DECAY_PER_TURN


func corpse_zombify_chance(c: Corpse, time_now: WorldTime, check_delay: bool = true) -> int:
	# delay zombification.
	var d_t: int = time_now.turn_counter - c.turn
	if check_delay && d_t < CORPSE_ZOMBIFY_DELAY:
		return 0

	# compute infection P
	var inf_p := actor_infection_percent(c.dead_guy)

	# check only every X turns, higher frequency as infP rise.
	if check_delay:
		var freq := (1 if inf_p >= 100 else 100 / (1 + inf_p))
		if time_now.turn_counter % freq != 0:
			return 0

	# base chance.
	var chance := float(CORPSE_ZOMBIFY_BASE_CHANCE)

	# living infection
	chance += CORPSE_ZOMBIFY_INFECTIONP_FACTOR * inf_p

	# less likey as time passes.
	chance -= int(CORPSE_ZOMBIFY_TIME_FACTOR * d_t)

	# factor day & night.
	if time_now.is_night:
		chance *= CORPSE_ZOMBIFY_NIGHT_FACTOR
	else:
		chance *= CORPSE_ZOMBIFY_DAY_FACTOR

	# ok.
	var int_chance := clampi(int(chance), 0, 100)
	return int_chance


func corpse_revive_chance(actor: Actor, corpse: Corpse) -> int:
	if not can_actor_revive_corpse(actor, corpse)["ok"]:
		return 0
	var base_chance := corpse_freshness_percent(corpse) / 4
	var skill_bonus := actor.sheet.skill_table.get_skill_level(Skills.IDs.MEDIC) * SKILL_MEDIC_REVIVE_BONUS
	return base_chance + skill_bonus


func corpse_revive_hps(actor: Actor, corpse: Corpse) -> int:
	var base_hps := 5
	var skill_bonus := actor.sheet.skill_table.get_skill_level(Skills.IDs.MEDIC)
	return base_hps + skill_bonus

# Traps
# alpha10

## C# GetTrapTriggerChance(trap, a).
func get_trap_trigger_chance(trap: ItemTrap, a: Actor) -> int:
	# alpha10.1 bugfix - correctly has 0 chance to trigger safe traps (eg: followers traps etc...)
	if is_safe_from_trap(trap, a):
		return 0

	var base_chance := 0
	var avoid_bonus := 0

	base_chance = trap.trap_model().trigger_chance * trap.quantity

	avoid_bonus = 0
	if a.model.abilities.is_undead:
		avoid_bonus -= TRAP_UNDEAD_ACTOR_TRIGGER_PENALTY
	if a.model.abilities.is_small:
		avoid_bonus += TRAP_SMALL_ACTOR_AVOID_BONUS
	avoid_bonus += a.sheet.skill_table.get_skill_level(Skills.IDs.LIGHT_FEET) * SKILL_LIGHT_FEET_TRAP_BONUS
	avoid_bonus += a.sheet.skill_table.get_skill_level(Skills.IDs.Z_LIGHT_FEET) * SKILL_ZLIGHT_FEET_TRAP_BONUS

	return base_chance - avoid_bonus


## C# CheckTrapTriggers(trap, actor) -> true if trap triggers.
func check_trap_triggers(trap: ItemTrap, a: Actor) -> bool:
	# alpha10 extracted and modified trigger chance formula
	var chance := get_trap_trigger_chance(trap, a)
	return roll_chance(chance) if chance > 0 else false


## C# CheckTrapTriggers(trap, mobj) overload -> check_trap_triggers_on_object.
func check_trap_triggers_on_object(trap: ItemTrap, mobj: MapObject) -> bool:
	return roll_chance(trap.trap_model().trigger_chance * mobj.weight)


## mobj can be null.
func check_trap_step_on_breaks(trap: ItemTrap, mobj: MapObject = null) -> bool:
	var chance: int = trap.trap_model().break_chance
	if mobj != null:
		chance *= mobj.weight
	return roll_chance(chance)


func check_trap_escape_breaks(trap: ItemTrap, a: Actor) -> bool:
	return roll_chance(trap.trap_model().break_chance_when_escape)


# alpha10
func is_safe_from_trap(trap: ItemTrap, a: Actor) -> bool:
	if trap.owner == null:
		return false
	if trap.owner == a:
		return true
	return a.is_in_group_with(trap.owner)


func check_trap_escape(trap: ItemTrap, a: Actor) -> bool:
	# alpha10
	if is_safe_from_trap(trap, a):
		return true

	var escape_bonus := 0

	escape_bonus += a.sheet.skill_table.get_skill_level(Skills.IDs.LIGHT_FEET) * SKILL_LIGHT_FEET_TRAP_BONUS \
		+ a.sheet.skill_table.get_skill_level(Skills.IDs.Z_LIGHT_FEET) * SKILL_ZLIGHT_FEET_TRAP_BONUS

	return roll_chance(escape_bonus + (100 - trap.trap_model().block_chance * trap.quantity))


func is_trap_covering_map_object_there(map: Map, pos: Vector2i) -> bool:
	var mobj: MapObject = map.get_map_object_at(pos)
	if mobj == null:
		return false
	# mobj is either walkable and not a door (eg:bed) or jumpable (eg:table,car...)
	return mobj.is_jumpable || (mobj.is_walkable && not (mobj is DoorWindow))


func is_trap_triggering_map_object_there(map: Map, pos: Vector2i) -> bool:
	var mobj: MapObject = map.get_map_object_at(pos)
	if mobj == null:
		return false
	# mobj is NOT walkable and a door and NOT jumpable (eg:shelves,large fort)
	return not mobj.is_walkable && not mobj.is_jumpable && not (mobj is DoorWindow)


# Grabbing

func zgrab_chance(grabber: Actor, victim: Actor) -> int:
	var zgrab_level := grabber.sheet.skill_table.get_skill_level(Skills.IDs.Z_GRAB)
	return zgrab_level * SKILL_ZGRAB_CHANCE


# Game modes

static func has_immediate_zombification(mode) -> bool:
	return mode == Session.GameMode.GM_STANDARD


static func has_infection(mode) -> bool:
	return mode != Session.GameMode.GM_STANDARD


static func has_corpses(mode) -> bool:
	return mode != Session.GameMode.GM_STANDARD


static func has_evolution(mode) -> bool:
	return mode != Session.GameMode.GM_VINTAGE


static func has_all_zombies(mode) -> bool:
	return mode != Session.GameMode.GM_VINTAGE


static func has_zombies_in_basements(mode) -> bool:
	return mode != Session.GameMode.GM_VINTAGE


static func has_zombies_in_sewers(mode) -> bool:
	return mode != Session.GameMode.GM_VINTAGE
