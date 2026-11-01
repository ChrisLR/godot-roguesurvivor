class_name GameFactions
extends FactionDB
## Port of Gameplay/GameFactions.cs
## The faction content database: IDs enum + constructor-built factions and
## their (symmetrized) enmity relations. GDScript has no indexer syntax; the
## C# this[IDs id] is ported as this_set() on the factions array.

enum IDs {
	_FIRST = 0,

	TheCHARCorporation = _FIRST,
	TheCivilians,
	TheUndeads,
	TheArmy,
	TheBikers,
	TheGangstas,
	ThePolice,
	TheBlackOps,
	ThePsychopaths,
	TheSurvivors,
	TheFerals,

	_COUNT,
}


## C# static readonly GameItems.IDs[] arrays.
static var BAD_POLICE_OUTFITS: Array = [
	GameItems.IDs.ARMOR_FREE_ANGELS_JACKET,
	GameItems.IDs.ARMOR_HELLS_SOULS_JACKET,
]
static var GOOD_POLICE_OUTFITS: Array = [
	GameItems.IDs.ARMOR_POLICE_JACKET,
	GameItems.IDs.ARMOR_POLICE_RIOT,
]


var factions: Array = []


func _init() -> void:
	factions.resize(IDs._COUNT)

	# bind
	Models.factions = self

	# factions
	var army := Faction.new("Army", "soldier")
	army.lead_only_by_same_faction = true
	this_set(IDs.TheArmy, army)
	var bikers := Faction.new("Bikers", "biker")
	bikers.lead_only_by_same_faction = true
	this_set(IDs.TheBikers, bikers)
	var black_ops := Faction.new("BlackOps", "blackOp")
	black_ops.lead_only_by_same_faction = true
	this_set(IDs.TheBlackOps, black_ops)
	var char_corp := Faction.new("CHAR Corp.", "CHAR employee")
	char_corp.lead_only_by_same_faction = true
	this_set(IDs.TheCHARCorporation, char_corp)
	this_set(IDs.TheCivilians, Faction.new("Civilians", "civilian"))
	var gangstas := Faction.new("Gangstas", "gangsta")
	gangstas.lead_only_by_same_faction = true
	this_set(IDs.TheGangstas, gangstas)
	var police := Faction.new("Police", "police officer")
	police.lead_only_by_same_faction = true
	this_set(IDs.ThePolice, police)
	this_set(IDs.TheUndeads, Faction.new("Undeads", "undead"))
	this_set(IDs.ThePsychopaths, Faction.new("Psychopaths", "psychopath"))
	this_set(IDs.TheSurvivors, Faction.new("Survivors", "survivor"))
	var ferals := Faction.new("Ferals", "feral")
	ferals.lead_only_by_same_faction = true
	this_set(IDs.TheFerals, ferals)

	# relations.
	this_get(IDs.TheArmy).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.TheArmy).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheArmy).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.TheArmy).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheArmy).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.TheBikers).add_enemy(this_get(IDs.TheArmy))
	this_get(IDs.TheBikers).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheBikers).add_enemy(this_get(IDs.TheCHARCorporation))
	this_get(IDs.TheBikers).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.TheBikers).add_enemy(this_get(IDs.ThePolice))
	this_get(IDs.TheBikers).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheBikers).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheArmy))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheCHARCorporation))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheCivilians))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.ThePolice))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.ThePsychopaths))
	this_get(IDs.TheBlackOps).add_enemy(this_get(IDs.TheSurvivors))

	this_get(IDs.TheCHARCorporation).add_enemy(this_get(IDs.TheArmy))
	this_get(IDs.TheCHARCorporation).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheCHARCorporation).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.TheCHARCorporation).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.TheCHARCorporation).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheCHARCorporation).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.TheCivilians).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheCivilians).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheCivilians).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.TheArmy))
	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.TheCHARCorporation))
	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.ThePolice))
	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheGangstas).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.ThePolice).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.ThePolice).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.ThePolice).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.ThePolice).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.ThePolice).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheArmy))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheCHARCorporation))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheCivilians))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.ThePolice))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.ThePsychopaths))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheSurvivors))
	this_get(IDs.TheUndeads).add_enemy(this_get(IDs.TheFerals))

	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheArmy))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheBikers))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheCHARCorporation))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheCivilians))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheGangstas))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.ThePolice))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.ThePsychopaths).add_enemy(this_get(IDs.TheSurvivors))

	this_get(IDs.TheSurvivors).add_enemy(this_get(IDs.TheBlackOps))
	this_get(IDs.TheSurvivors).add_enemy(this_get(IDs.TheUndeads))
	this_get(IDs.TheSurvivors).add_enemy(this_get(IDs.ThePsychopaths))

	this_get(IDs.TheFerals).add_enemy(this_get(IDs.TheUndeads))

	# make sure relations are symmetric!
	# (quirk kept from C#: the check is fe.IsEnemyOf(fe), which is always
	# false, so f is always added to each enemy fe's enemy list.)
	for f: Faction in factions:
		for fe: Faction in f.enemies:
			if not fe.is_enemy_of(fe):
				fe.add_enemy(f)


func get_model(p_id: int) -> Faction:
	return factions[p_id]


## C# this[IDs id] getter.
func this_get(p_id: int) -> Faction:
	return get_model(p_id)


## C# this[IDs id] setter (assigning a faction binds its ID).
func this_set(p_id: int, p_faction: Faction) -> void:
	factions[p_id] = p_faction
	factions[p_id].id = p_id


# region Properties (C# public properties -> accessor methods)

func the_army() -> Faction:
	return this_get(IDs.TheArmy)

func the_bikers() -> Faction:
	return this_get(IDs.TheBikers)

func the_black_ops() -> Faction:
	return this_get(IDs.TheBlackOps)

func the_char_corporation() -> Faction:
	return this_get(IDs.TheCHARCorporation)

func the_civilians() -> Faction:
	return this_get(IDs.TheCivilians)

func the_gangstas() -> Faction:
	return this_get(IDs.TheGangstas)

func the_police() -> Faction:
	return this_get(IDs.ThePolice)

func the_undeads() -> Faction:
	return this_get(IDs.TheUndeads)

func the_psychopaths() -> Faction:
	return this_get(IDs.ThePsychopaths)

func the_survivors() -> Faction:
	return this_get(IDs.TheSurvivors)

func the_ferals() -> Faction:
	return this_get(IDs.TheFerals)

# endregion


# __END__
