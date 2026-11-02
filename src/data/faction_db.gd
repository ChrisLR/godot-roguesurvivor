class_name FactionDB
extends RefCounted
## Port of Data/FactionDB.cs
## Abstract base of the faction database (see Gameplay/GameFactions.cs).
## GDScript has no indexer syntax; the C# this[int id] is ported as get_model().

## Abstract. Concrete DBs override this.
func get_model(_p_id: int) -> Faction:
	assert(false, "abstract method")
	return null
