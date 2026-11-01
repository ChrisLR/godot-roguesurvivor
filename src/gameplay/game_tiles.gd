class_name GameTiles
extends TileModelDB
## Port of Gameplay/GameTiles.cs
## The tile content database. Unlike items/factions, tile models are built
## directly in the constructor (no CSV); GameImages registers the image IDs.
## GDScript has no indexer syntax; the C# this[IDs id] is ported as set/get
## helpers on the models array.

# Colors (C# System.Drawing.Color -> Godot Color).
static var LIT_GRAY1 := Color8(128, 128, 128)  # Color.Gray
static var LIT_GRAY2 := Color(0.698, 0.698, 0.698)  # Color.DarkGray
static var LIT_GRAY3 := Color8(230, 230, 230)
static var LIT_BROWN := Color(0.871, 0.722, 0.529)  # Color.BurlyWood
static var DRK_GRAY1 := Color(0.412, 0.412, 0.412)  # Color.DimGray
static var DRK_GRAY2 := Color(0.545, 0.545, 0.545)  # Color.DarkGray (unused, kept for parity)
static var DRK_RED := Color8(128, 0, 0)


enum IDs {
	_FIRST = 0,

	UNDEF = _FIRST,

	FLOOR_ASPHALT,
	FLOOR_CONCRETE,
	FLOOR_GRASS,
	FLOOR_OFFICE,
	FLOOR_PLANKS,
	FLOOR_SEWER_WATER,
	FLOOR_TILES,
	FLOOR_WALKWAY,

	ROAD_ASPHALT_EW,
	ROAD_ASPHALT_NS,
	RAIL_EW,

	WALL_BRICK,
	WALL_CHAR_OFFICE,
	WALL_HOSPITAL,
	WALL_POLICE_STATION,
	WALL_SEWER,
	WALL_STONE,
	WALL_SUBWAY,

	_COUNT,
}


var models: Array = []


func _init() -> void:
	models.resize(IDs._COUNT)

	# bind.
	Models.tiles = self

	this_set(IDs.UNDEF, TileModel.UNDEF)

	# region Floors
	this_set(IDs.FLOOR_ASPHALT, TileModel.new(GameImages.TILE_FLOOR_ASPHALT, LIT_GRAY1, true, true))
	this_set(IDs.FLOOR_CONCRETE, TileModel.new(GameImages.TILE_FLOOR_CONCRETE, LIT_GRAY2, true, true))
	this_set(IDs.FLOOR_GRASS, TileModel.new(GameImages.TILE_FLOOR_GRASS, Color.GREEN, true, true))
	this_set(IDs.FLOOR_OFFICE, TileModel.new(GameImages.TILE_FLOOR_OFFICE, LIT_GRAY3, true, true))
	this_set(IDs.FLOOR_PLANKS, TileModel.new(GameImages.TILE_FLOOR_PLANKS, LIT_BROWN, true, true))
	var sewer_water := TileModel.new(GameImages.TILE_FLOOR_SEWER_WATER, Color.BLUE, true, true)
	sewer_water.is_water = true
	sewer_water.water_cover_image_id = GameImages.TILE_FLOOR_SEWER_WATER_COVER
	this_set(IDs.FLOOR_SEWER_WATER, sewer_water)
	this_set(IDs.FLOOR_TILES, TileModel.new(GameImages.TILE_FLOOR_TILES, LIT_GRAY2, true, true))
	this_set(IDs.FLOOR_WALKWAY, TileModel.new(GameImages.TILE_FLOOR_WALKWAY, LIT_GRAY2, true, true))
	this_set(IDs.ROAD_ASPHALT_EW, TileModel.new(GameImages.TILE_ROAD_ASPHALT_EW, LIT_GRAY1, true, true))
	this_set(IDs.ROAD_ASPHALT_NS, TileModel.new(GameImages.TILE_ROAD_ASPHALT_NS, LIT_GRAY1, true, true))
	this_set(IDs.RAIL_EW, TileModel.new(GameImages.TILE_RAIL_ES, LIT_GRAY1, true, true))
	# endregion

	# region Walls
	this_set(IDs.WALL_BRICK, TileModel.new(GameImages.TILE_WALL_BRICK, DRK_GRAY1, false, false))
	this_set(IDs.WALL_CHAR_OFFICE, TileModel.new(GameImages.TILE_WALL_CHAR_OFFICE, DRK_RED, false, false))
	this_set(IDs.WALL_HOSPITAL, TileModel.new(GameImages.TILE_WALL_HOSPITAL, Color.WHITE, false, false))
	this_set(IDs.WALL_POLICE_STATION, TileModel.new(GameImages.TILE_WALL_STONE, Color.CADET_BLUE, false, false))
	this_set(IDs.WALL_SEWER, TileModel.new(GameImages.TILE_WALL_SEWER, Color.DARK_GREEN, false, false))
	this_set(IDs.WALL_STONE, TileModel.new(GameImages.TILE_WALL_STONE, DRK_GRAY1, false, false))
	this_set(IDs.WALL_SUBWAY, TileModel.new(GameImages.TILE_WALL_STONE, Color.BLUE, false, false))
	# endregion


func get_model(p_id: int) -> TileModel:
	return models[p_id]


## C# this[IDs id] setter (assigning a model binds its ID).
func this_set(p_id: int, p_model: TileModel) -> void:
	models[p_id] = p_model
	models[p_id].id = p_id


# region Properties (C# public properties -> accessor methods)

func floor_asphalt() -> TileModel:
	return get_model(IDs.FLOOR_ASPHALT)

func floor_concrete() -> TileModel:
	return get_model(IDs.FLOOR_CONCRETE)

func floor_grass() -> TileModel:
	return get_model(IDs.FLOOR_GRASS)

func floor_office() -> TileModel:
	return get_model(IDs.FLOOR_OFFICE)

func floor_planks() -> TileModel:
	return get_model(IDs.FLOOR_PLANKS)

func floor_sewer_water() -> TileModel:
	return get_model(IDs.FLOOR_SEWER_WATER)

func floor_tiles() -> TileModel:
	return get_model(IDs.FLOOR_TILES)

func floor_walkway() -> TileModel:
	return get_model(IDs.FLOOR_WALKWAY)

func road_asphalt_ew() -> TileModel:
	return get_model(IDs.ROAD_ASPHALT_EW)

func road_asphalt_ns() -> TileModel:
	return get_model(IDs.ROAD_ASPHALT_NS)

func rail_ew() -> TileModel:
	return get_model(IDs.RAIL_EW)

func wall_brick() -> TileModel:
	return get_model(IDs.WALL_BRICK)

func wall_char_office() -> TileModel:
	return get_model(IDs.WALL_CHAR_OFFICE)

func wall_hospital() -> TileModel:
	return get_model(IDs.WALL_HOSPITAL)

func wall_police_station() -> TileModel:
	return get_model(IDs.WALL_POLICE_STATION)

func wall_sewer() -> TileModel:
	return get_model(IDs.WALL_SEWER)

func wall_stone() -> TileModel:
	return get_model(IDs.WALL_STONE)

func wall_subway() -> TileModel:
	return get_model(IDs.WALL_SUBWAY)

# endregion


# region Helpers
func is_road_model(model: TileModel) -> bool:
	return model == get_model(IDs.ROAD_ASPHALT_EW) or model == get_model(IDs.ROAD_ASPHALT_NS)
# endregion


# __END__
