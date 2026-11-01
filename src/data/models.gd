class_name Models
extends RefCounted
## Port of Data/Models.cs
## Static accessors for the content databases (set up at game start).

static var actors: ActorModelDB = null
static var factions: FactionDB = null
static var items: ItemModelDB = null
static var tiles: TileModelDB = null


## Drop the global content DB references (shutdown).
static func clear_statics() -> void:
	# Break intra-DB cycles (faction <-> faction enemies) before dropping.
	var fdb: GameFactions = factions as GameFactions
	if fdb != null:
		for f in fdb.factions:
			f.shutdown()
	actors = null
	factions = null
	items = null
	tiles = null
