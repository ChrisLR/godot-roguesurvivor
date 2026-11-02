class_name TileModelDB
extends RefCounted
## Port of Data/TileModelDB.cs
## Abstract base of the tile model database (see Gameplay/GameTiles.cs).
## GDScript has no indexer syntax; the C# this[int id] is ported as get_model().

## Abstract. Concrete DBs override this.
func get_model(_p_id: int) -> TileModel:
	assert(false, "abstract method")
	return null
