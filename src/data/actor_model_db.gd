class_name ActorModelDB
extends RefCounted
## Port of Data/ActorModelDB.cs
## Abstract base of the actor model database (see Gameplay/GameActors.cs).
## GDScript has no indexer syntax; the C# this[int id] is ported as get_model().

## Abstract. Concrete DBs override this.
func get_model(p_id: int) -> ActorModel:
	assert(false, "abstract method")
	return null
