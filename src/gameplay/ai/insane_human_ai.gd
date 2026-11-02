class_name InsaneHumanAI
extends BaseAI
## Port of Gameplay/AI/InsaneHumanAI.cs
## InsaneHumanAI, used by Unique Enraged Patient & Asylum patients.
## Extremely simple : attack anyone in sight or shout insanities, wander.

# Constants

const SHOUT_CHANCE: int = 80
const USE_EXIT_CHANCE: int = 50

static var INSANITIES: Array[String] = [
	"WHY WALK THERE?",
	"WHAT MAKES YOU FUN?",
	"YOU WEAR TOO MUCH COLORS!",
	"YOU HAVE BAD HABITS!",
	"MOM DIDN'T HANG ME!",
	"LUCIE! LUCIA!",
	"WHAT EGGS AND PASTA?",
	"TURTLE CATS!",
	"I REMEMBER THE CRABS!",
	"IT WAS AFTER THAT NOW!",
	"CUT IT! CUT IT NOW!",
	"DECEASED TOES!",
	"ICE-CREAM COPS!",
	"I SAW THAT FUCKING TWICE! TWICE! TWICE!",
	"FUCK BASTARD SAUSAGE!",
	"HEY YOU! STOP MOVING THE FLOOR!",
	"DROP THE FUCKING EGGS NOW!",
	"YOU GO FIRST AFTER ME!",
	"IT HURTS BUT ITS OK!",
	"LAST TIME WAS OK...",
	"SHE ISN'T NOT YET!",
	"I WAS CRAWLING HAHA!",
	"ROLLING LIKE AN EGG!",
	"THAT IS NOT DECENT!",
	"JUMP LIKE A FLOWER!",
	"CHEESE LIKE THESE...",
	"ILL-ADVISED LOBSTER!",
	"SSSHHHH! SILENCE... DO YOU SMELL?",
	"NOTHING BEATS. NOTHING!",
	"GROWN-UP MEN DON'T DO THAT!",
	"BARN BUSTER!",
	"SUPER SUPER?",
	"ONE MORE PASTA CRAP!",
	"LAZY LADY!",
	"I HATE TAP WATER!",
	"STILL WANKING FOR FOOD?",
	"LOOK! IT FITS LIKE A HOLE!",
	"PESKY POLAR PRANKS!",
	"LITTLE BY LITTLE YOU DIE...",
	"PLEASE TIE YOUR NECK PROPERLY!",
	"I SEE WHAT I SHIT ALL THE TIME!",
	"THAT'S FUCKING ANNOYING!",
	"I UNLOCK THE WALLS!",
	"I'M NOT SO SURE NOW!?",
	"RUSTY BUT TRUSTY!",
	"CHEESE LICKER!",
	"LAUNDRY TIME AGAIN AND AGAIN!",
	"DON'T YOU SEE I'M ASSEMBLED?",
	"MEXICAN MIDGETS!",
	"RAZOR RASCALS!",
	"PUNCH MY BALLS!",
	"STUCK IN A VICIOUS SQUARE!",
	"HORSE HOLSTER!",
	"THAT WAS COMPLETLY UNCALLED FOR!",
	"ROBOTS WON'T FOOL ME!",
]

# Fields

var _los_sensor: LOSSensor = null


# BaseAI

func create_sensors() -> void:
	_los_sensor = LOSSensor.new(LOSSensor.SensingFilter.ACTORS)


func update_sensors(game: RogueGame) -> Array[Percept]:
	var list: Array[Percept] = _los_sensor.sense(game, _actor)
	return list


func select_action(game: RogueGame, percepts: Array[Percept]) -> ActorAction:
	if not has_valid_location():
		return null
	var _fov = _los_sensor.fov
	var map_percepts = filter_same_map(game, percepts)

	#####################################################################
	# alpha10 OBSOLETE 1 equip weapon
	# alpha10 1 equip best items
	# 2 (chance) move closer to an enemy, nearest & visible enemies first
	# 3 (chance) shout insanities.
	# 4 (chance) use exit.
	# 5 wander
	#####################################################################

	# alpha10
	_actor.is_running = false

	# 1 equip best items
	var best_equip: ActorAction = behavior_equip_best_items(game, false, false)
	if best_equip != null:
		return best_equip

	# 2 (chance) move closer to an enemy, nearest & visible enemies first
	# alpha10.1 always try to attack if (game.Rules.RollChance(ATTACK_CHANCE))
	var enemies = filter_enemies(game, map_percepts)
	if enemies != null:
		# try visible enemies first, the closer the best.
		var turn_counter: int = _actor.location.map.local_time.turn_counter
		var visible_enemies = filter(game, enemies,
			func(p: Percept) -> bool: return p.turn == turn_counter)
		if visible_enemies != null:
			var best_enemy_percept: Percept = null
			var best_bump_action: ActorAction = null
			var closest: int = 2147483647

			for enemy_p: Percept in visible_enemies:
				var distance: int = game.rules.grid_distance_points(_actor.location.position, enemy_p.location.position)
				if distance < closest:
					var bump_action: ActorAction = behavior_stupid_bump_toward(game, enemy_p.location.position, true, true)
					if bump_action != null:
						closest = distance
						best_enemy_percept = enemy_p
						best_bump_action = bump_action

			if best_bump_action != null:
				_actor.activity = Activity.CHASING
				_actor.target_actor = best_enemy_percept.percepted as Actor
				return best_bump_action

		# then try rest, the closer the best.
		var old_enemies = filter(game, enemies,
			func(p: Percept) -> bool: return p.turn != turn_counter)
		if old_enemies != null:
			var best_enemy_percept: Percept = null
			var best_bump_action: ActorAction = null
			var closest: int = 2147483647

			for enemy_p: Percept in old_enemies:
				var distance: int = game.rules.grid_distance_points(_actor.location.position, enemy_p.location.position)
				if distance < closest:
					var bump_action: ActorAction = behavior_stupid_bump_toward(game, enemy_p.location.position, true, true)
					if bump_action != null:
						closest = distance
						best_enemy_percept = enemy_p
						best_bump_action = bump_action

			if best_bump_action != null:
				_actor.activity = Activity.CHASING
				_actor.target_actor = best_enemy_percept.percepted as Actor
				return best_bump_action

	# 3 (chance) shout insanities.
	if game.rules.roll_chance(SHOUT_CHANCE):
		var insanity: String = INSANITIES[game.rules.roll(0, INSANITIES.size())]
		_actor.activity = Activity.IDLE
		game.do_emote(_actor, insanity, true)

	# 4 (chance) use exit.
	if game.rules.roll_chance(USE_EXIT_CHANCE):
		var use_exit: ActorAction = behavior_use_exit(game,
			UseExitFlags.ATTACK_BLOCKING_ENEMIES | UseExitFlags.BREAK_BLOCKING_OBJECTS)
		if use_exit != null:
			_actor.activity = Activity.IDLE
			return use_exit

	# 5 wander
	_actor.activity = Activity.IDLE
	return behavior_wander(game, null)
