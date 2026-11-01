class_name LOSSensor
extends Sensor
## Port of Gameplay/AI/Sensors/LOSSensor.cs

enum SensingFilter {
	ACTORS = (1 << 0),
	ITEMS = (1 << 1),
	CORPSES = (1 << 2),
}

## HashSet<Point> ported as Dictionary (keys are the visible positions).
var fov: Dictionary = {}
var filters: int


func _init(p_filters: int) -> void:
	filters = p_filters


func sense(game: RogueGame, actor: Actor) -> Array[Percept]:
	# compute FOV.
	fov = LOS.compute_fov_for(game.rules, actor, actor.location.map.local_time, game.session.world.weather)
	var max_range: int = game.rules.actor_fov(actor, actor.location.map.local_time, game.session.world.weather)

	# compute percepts.
	var list: Array[Percept] = []

	# Actors.
	if (filters & SensingFilter.ACTORS) != 0:
		# roughly estimate time for two sensing methods.
		var search_fov_method_time: int = max_range * max_range
		var search_actors_list_method_time: int = actor.location.map.count_actors

		# choose method which seems less costly in time.
		if search_fov_method_time < search_actors_list_method_time:
			# FOV check : bad when few actors, good when many actors.
			for p in fov:
				var other: Actor = actor.location.map.get_actor_at(p)
				if other != null and other != actor:
					list.append(Percept.new(other, actor.location.map.local_time.turn_counter, other.location))
		else:
			# Actors list check : good when few actors, bad when many actors.
			for other: Actor in actor.location.map.actors_list:
				if other == actor:
					continue
				if game.rules.los_distance(actor.location.position, other.location.position) > max_range:
					continue
				if fov.has(other.location.position):
					list.append(Percept.new(other, actor.location.map.local_time.turn_counter, other.location))

	# Items.
	if (filters & SensingFilter.ITEMS) != 0:
		for p in fov:
			var inv: Inventory = actor.location.map.get_items_at(p)
			if inv == null or inv.is_empty:
				continue
			list.append(Percept.new(inv, actor.location.map.local_time.turn_counter, Location.new(actor.location.map, p)))

	# Corpses.
	if (filters & SensingFilter.CORPSES) != 0:
		for p in fov:
			var corpses = actor.location.map.get_corpses_at(p)
			if corpses != null and not corpses.is_empty():
				list.append(Percept.new(corpses, actor.location.map.local_time.turn_counter, Location.new(actor.location.map, p)))

	# done.
	return list
