class_name ItemModelDB
extends RefCounted
## Port of Data/ItemModelDB.cs
## Abstract base of the item model database (see Gameplay/GameItems.cs).
## GDScript has no indexer syntax; the C# this[int id] is ported as get_model().

## Abstract. Concrete DBs override this.
func get_model(p_id: int) -> ItemModel:
	assert(false, "abstract method")
	return null
