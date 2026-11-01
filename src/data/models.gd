class_name Models
extends RefCounted
## Port of Data/Models.cs
## Static accessors for the content databases (set up at game start).

static var actors: ActorModelDB = null
static var factions: FactionDB = null
static var items: ItemModelDB = null
static var tiles: TileModelDB = null
