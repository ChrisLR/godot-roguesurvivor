class_name GameGangs
extends RefCounted
## Port of Gameplay/GameGangs.cs

enum IDs {
	NONE,
	BIKER_HELLS_SOULS,
	BIKER_FREE_ANGELS,
	GANGSTA_CRAPS,
	GANGSTA_FLOODS,
}

static var GANGSTAS: Array[IDs] = [IDs.GANGSTA_CRAPS, IDs.GANGSTA_FLOODS]
static var BIKERS: Array[IDs] = [IDs.BIKER_HELLS_SOULS, IDs.BIKER_FREE_ANGELS]

static var NAMES: PackedStringArray = [
	"(no gang)",
	"Hell's Souls",
	"Free Angels",
	"Craps",
	"Floods",
]

# BAD_GANG_OUTFITS / GOOD_GANG_OUTFITS reference GameItems.IDs and are ported
# together with GameItems (Gameplay/GameItems.cs). Filled by game_items.gd.
static var BAD_GANG_OUTFITS: Array = []
static var GOOD_GANG_OUTFITS: Array = []
