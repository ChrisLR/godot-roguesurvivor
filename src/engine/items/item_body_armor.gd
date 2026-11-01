class_name ItemBodyArmor
extends Item
## Port of Engine/Items/ItemBodyArmor.cs
## A concrete body armor item instance.

var protection_hit: int
var protection_shot: int
var encumbrance: int
var weight: int


func _init(p_model: ItemModel) -> void:
	super._init(p_model)
	assert(p_model is ItemBodyArmorModel, "model is not a BodyArmorModel")

	var m: ItemBodyArmorModel = p_model
	protection_hit = m.protection_hit
	protection_shot = m.protection_shot
	encumbrance = m.encumbrance
	weight = m.weight


func is_hostile_for_cops() -> bool:
	return _police_outfits(false).has(model_id)


func is_friendly_for_cops() -> bool:
	return _police_outfits(true).has(model_id)


func is_hostile_for_biker(gang_id: int) -> bool:
	return GameGangs.BAD_GANG_OUTFITS[gang_id].has(model_id)


func is_friendly_for_biker(gang_id: int) -> bool:
	return GameGangs.GOOD_GANG_OUTFITS[gang_id].has(model_id)


## GameFactions (Gameplay/GameFactions.cs) is ported in a later batch. The
## police outfit arrays are resolved from it at call time so this script
## compiles before that batch lands; returns an empty array until then.
static func _police_outfits(p_good: bool) -> Array:
	const GAME_FACTIONS_PATH := "res://src/gameplay/game_factions.gd"
	if not ResourceLoader.exists(GAME_FACTIONS_PATH):
		return []
	var game_factions: GDScript = load(GAME_FACTIONS_PATH)
	return game_factions.GOOD_POLICE_OUTFITS if p_good else game_factions.BAD_POLICE_OUTFITS


# --- save system ---
func _serialize_fields(d: Dictionary) -> void:
	d["protection_hit"] = protection_hit
	d["protection_shot"] = protection_shot
	d["encumbrance"] = encumbrance
	d["weight"] = weight


func _deserialize_fields(d: Dictionary) -> void:
	super._deserialize_fields(d)
	protection_hit = d.get("protection_hit", protection_hit)
	protection_shot = d.get("protection_shot", protection_shot)
	encumbrance = d.get("encumbrance", encumbrance)
	weight = d.get("weight", weight)
