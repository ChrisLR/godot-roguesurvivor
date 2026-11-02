class_name BaseTownGenerator
extends BaseMapGenerator
## Port of Gameplay/Generators/BaseTownGenerator.cs
## Base class for town map generators : the city surface (blocks, buildings,
## parks), sewers and subway networks, and their population.
##
## Port notes :
## - C# struct Parameters -> Dictionary (see DEFAULT_PARAMS). C# property
##   setters validated ranges; dictionaries cannot, so validation happens in
##   _init instead. NOTE: the C# MapHeight setter compared against
##   MAP_MAX_WIDTH (original quirk, kept).
## - C# System.Drawing.Rectangle -> Godot Rect2i, Point -> Vector2i.

# region Types

## C# struct Parameters -> Dictionary with keys :
##   district                  : District the map is currently generated in (or null).
##   generate_police_station   : do we need to generate the Police Station in this district?
##   generate_hospital         : do we need to generate the Hospital in this district?
##   map_width, map_height     : map size, [1..MAP_MAX_*]
##   min_block_size            : [4..32]
##   wrecked_car_chance, shop_building_chance, park_building_chance,
##   char_building_chance, posters_chance, tags_chance,
##   item_in_shop_shelf_chance, policeman_chance : chances in [0..100]

const DEFAULT_PARAMS: Dictionary = {
	"district": null,
	"generate_police_station": false,
	"generate_hospital": false,
	"map_width": RogueGame.MAP_MAX_WIDTH,
	"map_height": RogueGame.MAP_MAX_HEIGHT,
	"min_block_size": 11,  # 12 for 75x75 map size; 10 gives to many small buildings.
	"wrecked_car_chance": 10,
	"shop_building_chance": 10,
	"park_building_chance": 10,
	"char_building_chance": 10,
	"posters_chance": 2,
	"tags_chance": 2,
	"item_in_shop_shelf_chance": 100,
	"policeman_chance": 15,
}


## Fresh mutable copy of the default parameters.
static func default_params() -> Dictionary:
	return DEFAULT_PARAMS.duplicate()


## C# class Block : a city block and its nested building rectangles.
class Block:
	## Rectangle enclosing the whole block.
	var rectangle: Rect2i
	## Rectangle enclosing the building : the blocks minus the walkway ring.
	var building_rect: Rect2i
	## Rectangle enclosing the inside of the building : the building minus the walls ring.
	var inside_rect: Rect2i


	## C# Block(Rectangle) and Block(Block) merged : pass a Rect2i or a Block.
	func _init(rect) -> void:
		if rect is Block:
			rectangle = rect.rectangle
			building_rect = rect.building_rect
			inside_rect = rect.inside_rect
		else:
			reset_rectangle(rect)


	func reset_rectangle(rect: Rect2i) -> void:
		rectangle = rect
		building_rect = Rect2i(rect.position.x + 1, rect.position.y + 1, rect.size.x - 2, rect.size.y - 2)
		inside_rect = Rect2i(building_rect.position.x + 1, building_rect.position.y + 1, building_rect.size.x - 2, building_rect.size.y - 2)


enum ShopType {
	_FIRST = 0,

	GENERAL_STORE = _FIRST,
	GROCERY,
	SPORTSWEAR,
	PHARMACY,
	CONSTRUCTION,
	GUNSHOP,
	HUNTING,

	_COUNT
}

enum CHARBuildingType {
	NONE,
	AGENCY,
	OFFICE
}

# alpha10
enum HouseOutsideRoomType {
	_FIRST = 0,

	GARDEN = _FIRST,
	PARKING_LOT,

	_COUNT
}

# endregion

# region Constants

const PARK_TREE_CHANCE: int = 25
const PARK_BENCH_CHANCE: int = 5
const PARK_ITEM_CHANCE: int = 5
const PARK_SHED_CHANCE: int = 75  # alpha10.1
const PARK_SHED_WIDTH: int = 5  # alpha10
const PARK_SHED_HEIGHT: int = 5  # alpha10

const MAX_CHAR_GUARDS_PER_OFFICE: int = 3

const SEWERS_ITEM_CHANCE: int = 1
const SEWERS_JUNK_CHANCE: int = 10
const SEWERS_TAG_CHANCE: int = 10
const SEWERS_IRON_FENCE_PER_BLOCK_CHANCE: int = 50  # 8 fences average on std maps size 75x75.
const SEWERS_ROOM_CHANCE: int = 20

const SUBWAY_TAGS_POSTERS_CHANCE: int = 20

const HOUSE_LIVINGROOM_ITEMS_ON_TABLE: int = 2
const HOUSE_KITCHEN_ITEMS_ON_TABLE: int = 2
const HOUSE_KITCHEN_ITEMS_IN_FRIDGE: int = 3
const HOUSE_BASEMENT_CHANCE: int = 30
const HOUSE_BASEMENT_OBJECT_CHANCE_PER_TILE: int = 10
const HOUSE_BASEMENT_PILAR_CHANCE: int = 20
const HOUSE_BASEMENT_WEAPONS_CACHE_CHANCE: int = 20
const HOUSE_BASEMENT_ZOMBIE_RAT_CHANCE: int = 5  # per tile.
# alpha10 new house stuff
const HOUSE_OUTSIDE_ROOM_NEED_MIN_ROOMS: int = 4
const HOUSE_OUTSIDE_ROOM_CHANCE: int = 75
const HOUSE_GARDEN_TREE_CHANCE: int = 10  # per tile
const HOUSE_PARKING_LOT_CAR_CHANCE: int = 10  # per tile
# alpha10.1 new house floorplan: apartements
const HOUSE_IS_APARTMENTS_CHANCE: int = 50

const SHOP_BASEMENT_CHANCE: int = 30
const SHOP_BASEMENT_SHELF_CHANCE_PER_TILE: int = 5
const SHOP_BASEMENT_ITEM_CHANCE_PER_SHELF: int = 33
const SHOP_WINDOW_CHANCE: int = 30
const SHOP_BASEMENT_ZOMBIE_RAT_CHANCE: int = 5  # per tile.

# endregion

# region Fields

var _params: Dictionary = DEFAULT_PARAMS.duplicate()
var _dice_roller: DiceRoller

## Blocks on surface map since during current generation.
var _surface_blocks = null  # Array[Block]

# endregion

# region Properties

var params: Dictionary:
	get:
		return _params
	set(value):
		_params = value

# endregion


func _init(p_game, p_params: Dictionary = DEFAULT_PARAMS) -> void:
	super(p_game)
	# C# Parameters setters threw ArgumentOutOfRangeException; dictionaries
	# cannot, so validate here instead. Same bounds; NOTE the C# MapHeight
	# setter compared against MAP_MAX_WIDTH (quirk kept).
	if p_params.map_width <= 0 || p_params.map_width > RogueGame.MAP_MAX_WIDTH:
		push_error("BaseTownGenerator : MapWidth")
	if p_params.map_height <= 0 || p_params.map_height > RogueGame.MAP_MAX_WIDTH:
		push_error("BaseTownGenerator : MapHeight")
	if p_params.min_block_size < 4 || p_params.min_block_size > 32:
		push_error("BaseTownGenerator : MinBlockSize must be [4..32]")
	for chance_key in ["wrecked_car_chance", "shop_building_chance", "park_building_chance", "char_building_chance", "posters_chance", "tags_chance", "item_in_shop_shelf_chance", "policeman_chance"]:
		if p_params[chance_key] < 0 || p_params[chance_key] > 100:
			push_error("BaseTownGenerator : %s must be [0..100]" % chance_key)
	_params = p_params
	_dice_roller = DiceRoller.new()

# endregion

# region Entry Map (Surface)

func generate(_seed: int) -> Map:
	_dice_roller = DiceRoller.new(_seed)
	var map := Map.new(_seed, "Base City", _params.map_width, _params.map_height)

	###################
	# Init with grass
	###################
	tile_fill_all(map, game.game_tiles.floor_grass())

	##############
	# Cut blocks
	##############
	var blocks: Array[Block] = []
	var city_rectangle := Rect2i(0, 0, map.width, map.height)
	make_blocks(map, true, blocks, city_rectangle)

	#######################################
	# Make concrete buildings from blocks
	#######################################
	var empty_blocks: Array = blocks.duplicate()
	var completed_blocks: Array = []

	# remember blocks.
	_surface_blocks = []
	for b in blocks:
		_surface_blocks.append(Block.new(b))

	# Special buildings.
	# Police Station?
	if _params.generate_police_station:
		var police_block: Block = make_police_station(map, blocks)
		empty_blocks.erase(police_block)
	# Hospital?
	if _params.generate_hospital:
		var hospital_block: Block = make_hospital(map, blocks)
		empty_blocks.erase(hospital_block)

	# shops.
	completed_blocks.clear()
	for b in empty_blocks:
		if _dice_roller.roll_chance(_params.shop_building_chance) \
				&& make_shop_building(map, b):
			completed_blocks.append(b)
	for b in completed_blocks:
		empty_blocks.erase(b)

	# CHAR buildings..
	completed_blocks.clear()
	var char_offices_count: int = 0
	for b in empty_blocks:
		if (_params.district.kind == District.DistrictKind.BUSINESS && char_offices_count == 0) \
				|| _dice_roller.roll_chance(_params.char_building_chance):
			var btype: CHARBuildingType = make_char_building(map, b)
			if btype == CHARBuildingType.OFFICE:
				char_offices_count += 1
				populate_char_office_building(map, b)
			if btype != CHARBuildingType.NONE:
				completed_blocks.append(b)
	for b in completed_blocks:
		empty_blocks.erase(b)

	# parks.
	completed_blocks.clear()
	for b in empty_blocks:
		if _dice_roller.roll_chance(_params.park_building_chance) \
				&& make_park_building(map, b):
			completed_blocks.append(b)
	for b in completed_blocks:
		empty_blocks.erase(b)

	# all the rest is housings.
	completed_blocks.clear()
	for b in empty_blocks:
		make_housing_building(map, b)
		completed_blocks.append(b)
	for b in completed_blocks:
		empty_blocks.erase(b)

	############
	# Decorate
	############
	add_wrecked_cars_outside(map, city_rectangle)
	decorate_outside_walls_with_posters(map, city_rectangle, _params.posters_chance)
	decorate_outside_walls_with_tags(map, city_rectangle, _params.tags_chance)

	# alpha10
	#########
	# Music
	#########
	map.bg_music = GameMusics.SURFACE

	######
	# Done
	######
	return map

# endregion

# region Sewers Map

func generate_sewers_map(_seed: int, district: District) -> Map:
	# Create.
	_dice_roller = DiceRoller.new(_seed)
	var sewers := Map.new(_seed, "sewers", district.entry_map.width, district.entry_map.height)
	sewers.lighting = Map.Lighting.DARKNESS
	sewers.add_zone(make_unique_zone("sewers", sewers.rect))
	tile_fill_all(sewers, game.game_tiles.wall_sewer())

	###################################################
	# 1. Make blocks.
	# 2. Make tunnels.
	# 3. Link with surface.
	# 4. Additional jobs.
	# 5. Sewers Maintenance Room & Building(surface).
	# 6. Some rooms.
	# 7. Objects.
	# 8. Items.
	# 9. Tags.
	# alpha10
	# 10. Music.
	###################################################
	var surface: Map = district.entry_map

	# 1. Make blocks.
	var blocks: Array[Block] = []
	make_blocks(sewers, false, blocks, Rect2i(0, 0, sewers.width, sewers.height))

	# 2. Make tunnels.
	# Carve tunnels.
	for b in blocks:
		tile_rectangle(sewers, game.game_tiles.floor_sewer_water(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	# Iron Fences blocking some tunnels.
	for b in blocks:
		# chance?
		if !_dice_roller.roll_chance(SEWERS_IRON_FENCE_PER_BLOCK_CHANCE):
			continue

		# fences on a side.
		var fx1: int
		var fy1: int
		var fx2: int
		var fy2: int
		var good_fence_pos := false
		while !good_fence_pos:
			# roll side.
			var side_roll: int = _dice_roller.roll(0, 4)
			match side_roll:
				0, 1:  # north, south.
					fx1 = _dice_roller.roll(b.rectangle.position.x, b.rectangle.end.x - 1)
					fy1 = (b.rectangle.position.y if side_roll == 0 else b.rectangle.end.y - 1)

					fx2 = fx1
					fy2 = (fy1 - 1 if side_roll == 0 else fy1 + 1)
				2, 3:  # east, west.
					fx1 = (b.rectangle.position.x if side_roll == 2 else b.rectangle.end.x - 1)
					fy1 = _dice_roller.roll(b.rectangle.position.y, b.rectangle.end.y - 1)

					fx2 = (fx1 - 1 if side_roll == 2 else fx1 + 1)
					fy2 = fy1
				_:
					# C# threw ArgumentOutOfRangeException.
					push_error("BaseTownGenerator : unhandled roll")
					continue

			# never on border.
			if sewers.is_on_map_border(fx1, fy1) || sewers.is_on_map_border(fx2, fy2):
				continue

			# must have walls.
			if count_adj_walls_xy(sewers, fx1, fy1) != 3:
				continue
			if count_adj_walls_xy(sewers, fx2, fy2) != 3:
				continue

			# found!
			good_fence_pos = true

		# add (both of them)
		map_object_place(sewers, fx1, fy1, make_obj_iron_fence(GameImages.OBJ_IRON_FENCE))
		map_object_place(sewers, fx2, fy2, make_obj_iron_fence(GameImages.OBJ_IRON_FENCE))

	# 3. Link with surface.
	# loop until we got at least one link.
	var count_links: int = 0
	while count_links < 1:
		for x in sewers.width:
			for y in sewers.height:
				# link? roll chance. 3%
				var do_link: bool = _dice_roller.roll_chance(3)
				if !do_link:
					continue

				# both surface and sewer tile must be walkable.
				var tile_sewer: Tile = sewers.get_tile_at(x, y)
				if !tile_sewer.model.is_walkable:
					continue
				var tile_surface: Tile = surface.get_tile_at(x, y)
				if !tile_surface.model.is_walkable:
					continue

				# no blocking object.
				if sewers.get_map_object_at_xy(x, y) != null:
					continue

				# surface tile must be outside.
				if tile_surface.is_inside:
					continue
				# surface tile must be walkway or grass.
				if tile_surface.model != game.game_tiles.floor_walkway() \
						&& tile_surface.model != game.game_tiles.floor_grass():
					continue
				# surface tile must not be obstructed by an object.
				if surface.get_map_object_at_xy(x, y) != null:
					continue

				# must not be adjacent to another exit.
				var pt := Vector2i(x, y)
				if sewers.has_any_adjacent_in_map(pt, func(p): return sewers.get_exit_at(p) != null):
					continue
				if surface.has_any_adjacent_in_map(pt, func(p): return surface.get_exit_at(p) != null):
					continue

				# link with ladder and sewer hole.
				add_exit(sewers, pt, surface, pt, GameImages.DECO_SEWER_LADDER, true)
				add_exit(surface, pt, sewers, pt, GameImages.DECO_SEWER_HOLE, true)

				# - one more link.
				count_links += 1

	# 4. Additional jobs.
	# Mark all the map as inside.
	for x in sewers.width:
		for y in sewers.height:
			sewers.get_tile_at(x, y).is_inside = true

	# 5. Sewers Maintenance Room & Building(surface).
	# search a suitable surface blocks.
	var good_blocks = null  # Array[Block]
	for b in _surface_blocks:
		# surface building must be of minimal size.
		if b.building_rect.size.x > _params.min_block_size + 2 || b.building_rect.size.y > _params.min_block_size + 2:
			continue

		# must not be a special building or have an exit (eg: houses with basements)
		if is_there_a_special_building(surface, b.inside_rect):
			continue

		# we must carve a room in the sewers.
		var has_room := true
		for x in range(b.rectangle.position.x, b.rectangle.end.x):
			if !has_room:
				break
			for y in range(b.rectangle.position.y, b.rectangle.end.y):
				if sewers.get_tile_at(x, y).model.is_walkable:
					has_room = false
					break
		if !has_room:
			continue

		# found one.
		if good_blocks == null:
			good_blocks = []
		good_blocks.append(b)
		break

	# if found, make maintenance room in sewers and building on surface.
	if good_blocks != null:
		# pick one at random.
		var surface_block: Block = good_blocks[_dice_roller.roll(0, good_blocks.size())]

		# clear surface building.
		clear_rectangle(surface, surface_block.building_rect)
		tile_fill_rect(surface, game.game_tiles.floor_concrete(), surface_block.building_rect)
		_surface_blocks.erase(surface_block)

		# make maintenance building on the surface & room in the sewers.
		var new_surface_block := Block.new(surface_block.rectangle)
		var ladder_hole_pos := Vector2i(new_surface_block.building_rect.position.x + new_surface_block.building_rect.size.x / 2, new_surface_block.building_rect.position.y + new_surface_block.building_rect.size.y / 2)
		make_sewers_maintenance_building(surface, true, new_surface_block, sewers, ladder_hole_pos)
		var sewers_room := Block.new(surface_block.rectangle)
		make_sewers_maintenance_building(sewers, false, sewers_room, surface, ladder_hole_pos)

	# 6. Some rooms.
	for b in blocks:
		# chance?
		if !_dice_roller.roll_chance(SEWERS_ROOM_CHANCE):
			continue

		# must be all walls = not already assigned as a room.
		if !check_for_each_tile(sewers, b.building_rect, func(pt): return !sewers.get_tile_at_p(pt).model.is_walkable):
			continue

		# carve a room.
		tile_fill_rect(sewers, game.game_tiles.floor_concrete(), b.inside_rect)

		# 4 entries.
		sewers.set_tile_model_at(b.building_rect.position.x + b.building_rect.size.x / 2, b.building_rect.position.y, game.game_tiles.floor_concrete())
		sewers.set_tile_model_at(b.building_rect.position.x + b.building_rect.size.x / 2, b.building_rect.end.y - 1, game.game_tiles.floor_concrete())
		sewers.set_tile_model_at(b.building_rect.position.x, b.building_rect.position.y + b.building_rect.size.y / 2, game.game_tiles.floor_concrete())
		sewers.set_tile_model_at(b.building_rect.end.x - 1, b.building_rect.position.y + b.building_rect.size.y / 2, game.game_tiles.floor_concrete())

		# zone.
		sewers.add_zone(make_unique_zone("room", b.inside_rect))

	# 7. Objects.
	# junk.
	var junk_fn := func(pt):
		if !_dice_roller.roll_chance(SEWERS_JUNK_CHANCE):
			return null
		if !sewers.is_walkable(pt.x, pt.y):
			return null

		return make_obj_junk(GameImages.OBJ_JUNK)
	map_object_fill_rect(sewers, Rect2i(0, 0, sewers.width, sewers.height), junk_fn)

	# 8. Items.
	for x in sewers.width:
		for y in sewers.height:
			if !_dice_roller.roll_chance(SEWERS_ITEM_CHANCE):
				continue
			if !sewers.is_walkable(x, y):
				continue

			# drop item.
			var it: Item
			var roll: int = _dice_roller.roll(0, 3)
			match roll:
				0:
					it = make_item_big_flashlight()
				1:
					it = make_item_crowbar()
				2:
					it = make_item_spray_paint()
				_:
					# C# threw ArgumentOutOfRangeException.
					push_error("BaseTownGenerator : unhandled roll")
					continue
			sewers.drop_item_at_xy(it, x, y)

	# 9. Tags.
	for x in sewers.width:
		for y in sewers.height:
			if _dice_roller.roll_chance(SEWERS_TAG_CHANCE):
				# must be a wall with walkables around.
				var t: Tile = sewers.get_tile_at(x, y)
				if t.model.is_walkable:
					continue
				if count_adj_walkables(sewers, x, y) < 2:
					continue

				# tag.
				t.add_decoration(TAGS[_dice_roller.roll(0, TAGS.size())])

	# alpha10
	# 10. Music.
	sewers.bg_music = GameMusics.SEWERS

	# Done.
	return sewers

# endregion

# region Subway Map

func generate_subway_map(_seed: int, district: District) -> Map:
	# Create.
	_dice_roller = DiceRoller.new(_seed)
	var subway := Map.new(_seed, "subway", district.entry_map.width, district.entry_map.height)
	subway.lighting = Map.Lighting.DARKNESS
	tile_fill_all(subway, game.game_tiles.wall_brick())

	#####################################
	# 1. Trace rail line.
	# 2. Make station linked to surface?
	# 3. Small tools room.
	# 4. Tags & Posters almost everywhere.
	# 5. Additional jobs.
	# alpha10
	# 6. Music
	#####################################
	var surface: Map = district.entry_map

	# 1. Trace rail line.
	var rail_start_x: int = 0
	var rail_end_x: int = subway.width - 1
	var rail_y: int = subway.width / 2 - 1
	var rail_size: int = 4

	for x in range(rail_start_x, rail_end_x + 1):
		for y in range(rail_y, rail_y + rail_size):
			subway.set_tile_model_at(x, y, game.game_tiles.rail_ew())
	subway.add_zone(make_unique_zone(RogueGame.NAME_SUBWAY_RAILS, Rect2i(rail_start_x, rail_y, rail_end_x - rail_start_x + 1, rail_size)))

	# 2. Make station linked to surface.
	# search a suitable surface blocks.
	var good_blocks = null  # Array[Block]
	for b in _surface_blocks:
		# surface building must be of minimal size.
		if b.building_rect.size.x > _params.min_block_size + 2 || b.building_rect.size.y > _params.min_block_size + 2:
			continue

		# must not be a special building or have an exit (eg: houses with basements)
		if is_there_a_special_building(surface, b.inside_rect):
			continue

		# we must carve a room in the subway and must not be to close to rails.
		var has_room := true
		var min_dist_to_rails: int = 8
		for x in range(b.rectangle.position.x - min_dist_to_rails, b.rectangle.end.x + min_dist_to_rails):
			if !has_room:
				break
			for y in range(b.rectangle.position.y - min_dist_to_rails, b.rectangle.end.y + min_dist_to_rails):
				if !subway.is_in_bounds(x, y):
					continue
				if subway.get_tile_at(x, y).model.is_walkable:
					has_room = false
					break
		if !has_room:
			continue

		# found one.
		if good_blocks == null:
			good_blocks = []
		good_blocks.append(b)
		break

	# if found, make station room and building.
	if good_blocks != null:
		# pick one at random.
		var surface_block: Block = good_blocks[_dice_roller.roll(0, good_blocks.size())]

		# clear surface building.
		clear_rectangle(surface, surface_block.building_rect)
		tile_fill_rect(surface, game.game_tiles.floor_concrete(), surface_block.building_rect)
		_surface_blocks.erase(surface_block)

		# make station building on the surface & room in the subway.
		var new_surface_block := Block.new(surface_block.rectangle)
		var stairs_pos := Vector2i(new_surface_block.building_rect.position.x + new_surface_block.building_rect.size.x / 2, new_surface_block.inside_rect.position.y)
		make_subway_station_building(surface, true, new_surface_block, subway, stairs_pos)
		var subway_room := Block.new(surface_block.rectangle)
		make_subway_station_building(subway, false, subway_room, surface, stairs_pos)

	# 3. Small tools room.
	var tools_room_width: int = 5
	var tools_room_height: int = 5
	var tools_room_dir: Direction = Direction.N if _dice_roller.roll_chance(50) else Direction.S
	var tools_room := Rect2i()  # Rectangle.Empty
	var found_tools_room := false
	var tools_room_attempt: int = 0
	while tools_room_attempt < subway.width * subway.height && !found_tools_room:
		var x: int = _dice_roller.roll(10, subway.width - 10)
		var y: int = (rail_y - 1 if tools_room_dir == Direction.N else rail_y + rail_size)

		if !subway.get_tile_at(x, y).model.is_walkable:
			# make room rectangle.
			if tools_room_dir == Direction.N:
				tools_room = Rect2i(x, y - tools_room_height + 1, tools_room_width, tools_room_height)
			else:
				tools_room = Rect2i(x, y, tools_room_width, tools_room_height)
			# check room rect is all walls (do not overlap with platform or other rooms)
			var walls_only_fn := func(pt): return !subway.get_tile_at_p(pt).model.is_walkable
			found_tools_room = check_for_each_tile(subway, tools_room, walls_only_fn)
		tools_room_attempt += 1

	if found_tools_room:
		# room.
		tile_fill_rect(subway, game.game_tiles.floor_concrete(), tools_room)
		tile_rectangle(subway, game.game_tiles.wall_brick(), tools_room.position.x, tools_room.position.y, tools_room.size.x, tools_room.size.y)
		place_door(subway, tools_room.position.x + tools_room_width / 2, (tools_room.end.y - 1 if tools_room_dir == Direction.N else tools_room.position.y), game.game_tiles.floor_concrete(), make_obj_iron_door())
		subway.add_zone(make_unique_zone("tools room", tools_room))

		# shelves on walls with construction items.
		var shelf_fn := func(pt):
			if !subway.is_walkable(pt.x, pt.y):
				return
			if count_adj_walls_xy(subway, pt.x, pt.y) == 0 || count_adj_doors(subway, pt.x, pt.y) > 0:
				return

			subway.place_map_object_at(make_obj_shelf(GameImages.OBJ_SHOP_SHELF), pt)
			subway.drop_item_at(make_shop_construction_item(), pt)
		do_for_each_tile(subway, tools_room, shelf_fn)

	# 4. Tags & Posters almost everywhere.
	for x in subway.width:
		for y in subway.height:
			if _dice_roller.roll_chance(SUBWAY_TAGS_POSTERS_CHANCE):
				# must be a wall with walkables around.
				var t: Tile = subway.get_tile_at(x, y)
				if t.model.is_walkable:
					continue
				if count_adj_walkables(subway, x, y) < 2:
					continue

				# poster?
				if _dice_roller.roll_chance(50):
					t.add_decoration(POSTERS[_dice_roller.roll(0, POSTERS.size())])

				# tag?
				if _dice_roller.roll_chance(50):
					t.add_decoration(TAGS[_dice_roller.roll(0, TAGS.size())])

	# 5. Additional jobs.
	# Mark all the map as inside.
	for x in subway.width:
		for y in subway.height:
			subway.get_tile_at(x, y).is_inside = true

	# alpha10
	# 6. Music.
	subway.bg_music = GameMusics.SUBWAY

	# Done.
	return subway

# endregion

# region Blocks generation

## C# QuadSplit used out parameters; returns a Dictionary with keys
## split_x, split_y, top_left, top_right, bottom_left, bottom_right
## (empty Rect2i for quads that are not split).
func quad_split(rect: Rect2i, min_width: int, min_height: int) -> Dictionary:
	# Choose a random split point.
	var left_width_split: int = _dice_roller.roll(rect.size.x / 3, (2 * rect.size.x) / 3)
	var top_height_split: int = _dice_roller.roll(rect.size.y / 3, (2 * rect.size.y) / 3)

	# Ensure splitting does not produce rects below minima.
	if left_width_split < min_width:
		left_width_split = min_width
	if top_height_split < min_height:
		top_height_split = min_height

	var right_width_split: int = rect.size.x - left_width_split
	var bottom_height_split: int = rect.size.y - top_height_split

	var do_split_x := true
	var do_split_y := true

	if right_width_split < min_width:
		left_width_split = rect.size.x
		right_width_split = 0
		do_split_x = false
	if bottom_height_split < min_height:
		top_height_split = rect.size.y
		bottom_height_split = 0
		do_split_y = false

	# Split point.
	var split_x: int = rect.position.x + left_width_split
	var split_y: int = rect.position.y + top_height_split

	# Make the quads.
	var top_left := Rect2i(rect.position.x, rect.position.y, left_width_split, top_height_split)

	var top_right := Rect2i()
	if do_split_x:
		top_right = Rect2i(split_x, rect.position.y, right_width_split, top_height_split)

	var bottom_left := Rect2i()
	if do_split_y:
		bottom_left = Rect2i(rect.position.x, split_y, left_width_split, bottom_height_split)

	var bottom_right := Rect2i()
	if do_split_x && do_split_y:
		bottom_right = Rect2i(split_x, split_y, right_width_split, bottom_height_split)

	return {
		"split_x": split_x,
		"split_y": split_y,
		"top_left": top_left,
		"top_right": top_right,
		"bottom_left": bottom_left,
		"bottom_right": bottom_right,
	}


func make_blocks(map: Map, make_roads: bool, list: Array, rect: Rect2i) -> void:
	const ring: int = 1  # dont change, keep to 1 (0=no roads, >1 = out of map)

	############
	# 1. Split
	############
	# +N to account for the road ring.
	var quads := quad_split(rect, _params.min_block_size + ring, _params.min_block_size + ring)
	var _split_x: int = quads.split_x
	var _split_y: int = quads.split_y
	var top_left: Rect2i = quads.top_left
	var top_right: Rect2i = quads.top_right
	var bottom_left: Rect2i = quads.bottom_left
	var bottom_right: Rect2i = quads.bottom_right

	####################
	# 2. Termination?
	####################
	if _rect_is_empty(top_right) && _rect_is_empty(bottom_left) && _rect_is_empty(bottom_right):
		# Make road ring?
		if make_roads:
			make_road(map, game.game_tiles.get_model(GameTiles.IDs.ROAD_ASPHALT_EW), Rect2i(rect.position.x, rect.position.y, rect.size.x, ring))        # north side
			make_road(map, game.game_tiles.get_model(GameTiles.IDs.ROAD_ASPHALT_EW), Rect2i(rect.position.x, rect.end.y - 1, rect.size.x, ring))  # south side
			make_road(map, game.game_tiles.get_model(GameTiles.IDs.ROAD_ASPHALT_NS), Rect2i(rect.position.x, rect.position.y, ring, rect.size.y))       # west side
			make_road(map, game.game_tiles.get_model(GameTiles.IDs.ROAD_ASPHALT_NS), Rect2i(rect.end.x - 1, rect.position.y, ring, rect.size.y))       # east side

			# Adjust rect.
			top_left.size.x -= 2 * ring
			top_left.size.y -= 2 * ring
			top_left.position += Vector2i(ring, ring)

		# Add block.
		list.append(Block.new(top_left))
		return

	#############
	# 3. Recurse
	#############
	# always top left.
	make_blocks(map, make_roads, list, top_left)
	# then recurse in non empty quads.
	if !_rect_is_empty(top_right):
		make_blocks(map, make_roads, list, top_right)
	if !_rect_is_empty(bottom_left):
		make_blocks(map, make_roads, list, bottom_left)
	if !_rect_is_empty(bottom_right):
		make_blocks(map, make_roads, list, bottom_right)


## C# Rectangle.IsEmpty (all zero values).
static func _rect_is_empty(r: Rect2i) -> bool:
	return r.size.x <= 0 || r.size.y <= 0


func make_road(map: Map, road_model: TileModel, rect: Rect2i) -> void:
	var keep_roads_fn := func(_tile, prevmodel, x, y):
		# don't overwrite roads!
		if game.game_tiles.is_road_model(prevmodel):
			map.set_tile_model_at(x, y, prevmodel)
	tile_fill_rect(map, road_model, rect, keep_roads_fn)
	map.add_zone(make_unique_zone("road", rect))

# endregion

# region Door/Window placement

func place_door(map: Map, x: int, y: int, floor_model: TileModel, door: DoorWindow) -> void:
	map.set_tile_model_at(x, y, floor_model)
	map_object_place(map, x, y, door)


## Bounds-safe decoration add: silently skips out-of-bounds positions.
## Use this instead of map.get_tile_at(x, y).add_decoration(...) when x/y
## may be at the map edge (e.g. door_x - 1, entry_fence_y + 1).
func _safe_add_decoration(map: Map, x: int, y: int, deco: String) -> void:
	var tile: Tile = map.get_tile_at(x, y)
	if tile != null:
		tile.add_decoration(deco)


func place_door_if_no_object(map: Map, x: int, y: int, floor_model: TileModel, door: DoorWindow) -> void:
	if map.get_map_object_at_xy(x, y) != null:
		return
	place_door(map, x, y, floor_model, door)


func place_door_if_accessible(map: Map, x: int, y: int, floor_model: TileModel, min_accessibility: int, door: DoorWindow) -> bool:
	var count_walkable: int = 0

	var p := Vector2i(x, y)
	for d in Direction.COMPASS:
		var next: Vector2i = p + d.vector
		if map.is_walkable(next.x, next.y):
			count_walkable += 1

	if count_walkable >= min_accessibility:
		place_door_if_no_object(map, x, y, floor_model, door)
		return true
	else:
		return false


func place_door_if_accessible_and_not_adjacent(map: Map, x: int, y: int, floor_model: TileModel, min_accessibility: int, door: DoorWindow) -> bool:
	var count_walkable: int = 0

	var p := Vector2i(x, y)
	for d in Direction.COMPASS:
		var next: Vector2i = p + d.vector
		if map.is_walkable(next.x, next.y):
			count_walkable += 1
		if map.get_map_object_at(next) is DoorWindow:
			return false

	if count_walkable >= min_accessibility:
		place_door_if_no_object(map, x, y, floor_model, door)
		return true
	else:
		return false

# endregion

# region Cars

func add_wrecked_cars_outside(map: Map, rect: Rect2i) -> void:
	#####################################
	# Add random cars (+ on fire effect)
	#####################################
	var car_fn := func(pt):
		if _dice_roller.roll_chance(_params.wrecked_car_chance):
			var tile: Tile = map.get_tile_at_p(pt)
			if !tile.is_inside && tile.model.is_walkable && tile.model != game.game_tiles.floor_grass():
				var car: MapObject = make_obj_wrecked_car(_dice_roller)
				if _dice_roller.roll_chance(50):
					game.apply_on_fire(car)
				return car
		return null
	map_object_fill_rect(map, rect, car_fn)

# endregion

# region Concrete buildings

func is_there_a_special_building(map: Map, rect: Rect2i) -> bool:
	# must not be a special building.
	var zones_up_there: Array[Zone] = map.get_zones_at(rect.position.x, rect.position.y)
	if zones_up_there != null:
		var special := false
		for z in zones_up_there:
			if z.name.contains(RogueGame.NAME_SEWERS_MAINTENANCE) || z.name.contains(RogueGame.NAME_SUBWAY_STATION) || z.name.contains("office") || z.name.contains("shop"):
				special = true
				break
		if special:
			return true

	# must not have an exit.
	if map.has_an_exit_in(rect):
		return true

	# all clear.
	return false


func make_shop_building(map: Map, b: Block) -> bool:
	#######################
	# 0. Check suitability
	#######################
	if b.inside_rect.size.x < 5 || b.inside_rect.size.y < 5:
		return false

	############################
	# 1. Walkway, floor & walls
	############################
	tile_rectangle(map, game.game_tiles.floor_walkway(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	tile_rectangle(map, game.game_tiles.wall_stone(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	var inside_fn := func(tile, _prevmodel, _x, _y): tile.is_inside = true
	tile_fill_rect(map, game.game_tiles.floor_tiles(), b.inside_rect, inside_fn)

	#######################
	# 2. Decide shop type
	#######################
	var shop_type: ShopType = _dice_roller.roll(ShopType.GENERAL_STORE, ShopType._COUNT) as ShopType

	################################################
	# 3. Make sections alleys with displays.
	################################################
	var alleys_start_x: int = b.inside_rect.position.x
	var alleys_start_y: int = b.inside_rect.position.y
	var alleys_end_x: int = b.inside_rect.end.x
	var alleys_end_y: int = b.inside_rect.end.y
	var horizontal_alleys: bool = b.rectangle.size.x >= b.rectangle.size.y
	var central_alley: int

	if horizontal_alleys:
		alleys_start_x += 1
		alleys_end_x -= 1
		central_alley = b.inside_rect.position.x + b.inside_rect.size.x / 2
	else:
		alleys_start_y += 1
		alleys_end_y -= 1
		central_alley = b.inside_rect.position.y + b.inside_rect.size.y / 2
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var alleys_rect := Rect2i(alleys_start_x, alleys_start_y, alleys_end_x - alleys_start_x, alleys_end_y - alleys_start_y)

	var alley_shelf_fn := func(pt):
		var add_shelf: bool

		if horizontal_alleys:
			add_shelf = ((pt.y - alleys_rect.position.y) % 2 == 1) && pt.x != central_alley
		else:
			add_shelf = ((pt.x - alleys_rect.position.x) % 2 == 1) && pt.y != central_alley

		if add_shelf:
			return make_obj_shelf(GameImages.OBJ_SHOP_SHELF)
		else:
			return null
	map_object_fill_rect(map, alleys_rect, alley_shelf_fn)

	###############################
	# 4. Entry door with shop ids
	#    Might add window(s).
	###############################
	var mid_x: int = b.rectangle.position.x + b.rectangle.size.x / 2
	var mid_y: int = b.rectangle.position.y + b.rectangle.size.y / 2

	# make doors on one side.
	if horizontal_alleys:
		var west: bool = _dice_roller.roll_chance(50)

		if west:
			# west
			place_door(map, b.building_rect.position.x, mid_y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.y >= 8:
				place_door(map, b.building_rect.position.x, mid_y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.y >= 12:
					place_door(map, b.building_rect.position.x, mid_y + 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
		else:
			# east
			place_door(map, b.building_rect.end.x - 1, mid_y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.y >= 8:
				place_door(map, b.building_rect.end.x - 1, mid_y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.y >= 12:
					place_door(map, b.building_rect.end.x - 1, mid_y + 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
	else:
		var north: bool = _dice_roller.roll_chance(50)

		if north:
			# north
			place_door(map, mid_x, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.x >= 8:
				place_door(map, mid_x - 1, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.x >= 12:
					place_door(map, mid_x + 1, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
		else:
			# south
			place_door(map, mid_x, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.x >= 8:
				place_door(map, mid_x - 1, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.x >= 12:
					place_door(map, mid_x + 1, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())

	# add shop image next to doors.
	var shop_image: String
	var shop_name: String
	match shop_type:
		ShopType.CONSTRUCTION:
			shop_image = GameImages.DECO_SHOP_CONSTRUCTION
			shop_name = "Construction"
		ShopType.GENERAL_STORE:
			shop_image = GameImages.DECO_SHOP_GENERAL_STORE
			shop_name = "GeneralStore"
		ShopType.GROCERY:
			shop_image = GameImages.DECO_SHOP_GROCERY
			shop_name = "Grocery"
		ShopType.GUNSHOP:
			shop_image = GameImages.DECO_SHOP_GUNSHOP
			shop_name = "Gunshop"
		ShopType.PHARMACY:
			shop_image = GameImages.DECO_SHOP_PHARMACY
			shop_name = "Pharmacy"
		ShopType.SPORTSWEAR:
			shop_image = GameImages.DECO_SHOP_SPORTSWEAR
			shop_name = "Sportswear"
		ShopType.HUNTING:
			shop_image = GameImages.DECO_SHOP_HUNTING
			shop_name = "Hunting Shop"
		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled shoptype")
			return false
	var shop_deco_fn := func(x, y): return (shop_image as Variant) if (map.get_map_object_at_xy(x, y) == null && count_adj_doors(map, x, y) >= 1) else null
	decorate_outside_walls(map, b.building_rect, shop_deco_fn)

	# window?
	if _dice_roller.roll_chance(SHOP_WINDOW_CHANCE):
		# pick a random side.
		var side: int = _dice_roller.roll(0, 4)
		var wx: int
		var wy: int
		match side:
			0:
				wx = b.building_rect.position.x + b.building_rect.size.x / 2
				wy = b.building_rect.position.y
			1:
				wx = b.building_rect.position.x + b.building_rect.size.x / 2
				wy = b.building_rect.end.y - 1
			2:
				wx = b.building_rect.position.x
				wy = b.building_rect.position.y + b.building_rect.size.y / 2
			3:
				wx = b.building_rect.end.x - 1
				wy = b.building_rect.position.y + b.building_rect.size.y / 2
			_:
				# C# threw ArgumentOutOfRangeException.
				push_error("BaseTownGenerator : unhandled side")
				return false
		# check it is ok to make a window there.
		var is_good_window_pos := true
		var window_tile: Tile = map.get_tile_at(wx, wy)
		if window_tile == null or window_tile.model.is_walkable:
			is_good_window_pos = false
		# do it?
		if is_good_window_pos:
			place_door(map, wx, wy, game.game_tiles.floor_tiles(), make_obj_window())

	# barricade certain shops types.
	if shop_type == ShopType.GUNSHOP:
		barricade_doors(map, b.building_rect, Rules.BARRICADING_MAX)

	##########################
	# 5. Add items to shelves.
	##########################
	var shelf_pos_fn := func(pt):
		var map_obj: MapObject = map.get_map_object_at(pt)
		if map_obj == null:
			return false
		return map_obj.image_id == GameImages.OBJ_SHOP_SHELF \
			&& _dice_roller.roll_chance(_params.item_in_shop_shelf_chance)
	var shop_item_fn := func(_pt): return make_random_shop_item(shop_type)
	items_drop(map, b.inside_rect, shelf_pos_fn, shop_item_fn)

	#########
	# 6. Zone
	#########
	# shop building.
	map.add_zone(make_unique_zone(shop_name, b.building_rect))
	# walkway zones.
	make_walkway_zones(map, b)

	################
	# 7. Basement?
	################
	if _dice_roller.roll_chance(SHOP_BASEMENT_CHANCE):
		# shop basement map:
		# - a single dark room.
		# - some shop items.

		# - a single dark room.
		var shop_basement := Map.new((map.seed << 1) ^ hash(shop_name), "basement-" + shop_name, b.building_rect.size.x, b.building_rect.size.y)
		shop_basement.lighting = Map.Lighting.DARKNESS
		var inside_all_fn := func(pt): shop_basement.get_tile_at_p(pt).is_inside = true
		do_for_each_tile(shop_basement, shop_basement.rect, inside_all_fn)
		tile_fill_all(shop_basement, game.game_tiles.floor_concrete())
		tile_rectangle(shop_basement, game.game_tiles.wall_brick(), shop_basement.rect.position.x, shop_basement.rect.position.y, shop_basement.rect.size.x, shop_basement.rect.size.y)
		shop_basement.add_zone(make_unique_zone("basement", shop_basement.rect))

		# - some shelves with shop items.
		# - some rats.
		var basement_fill_fn := func(pt):
			if !shop_basement.is_walkable(pt.x, pt.y):
				return
			if shop_basement.get_exit_at(pt) != null:
				return

			if _dice_roller.roll_chance(SHOP_BASEMENT_SHELF_CHANCE_PER_TILE):
				shop_basement.place_map_object_at(make_obj_shelf(GameImages.OBJ_SHOP_SHELF), pt)
				if _dice_roller.roll_chance(SHOP_BASEMENT_ITEM_CHANCE_PER_SHELF):
					var it: Item = make_random_shop_item(shop_type)
					if it != null:
						shop_basement.drop_item_at(it, pt)

			if Rules.has_zombies_in_basements(game.session.game_mode):
				if _dice_roller.roll_chance(SHOP_BASEMENT_ZOMBIE_RAT_CHANCE):
					shop_basement.place_actor_at(create_new_basement_rat_zombie(0), pt)
		do_for_each_tile(shop_basement, shop_basement.rect, basement_fill_fn)

		# alpha10 music
		shop_basement.bg_music = GameMusics.SEWERS

		# link maps, stairs in one corner.
		var basement_corner := Vector2i.ZERO
		basement_corner.x = 1 if _dice_roller.roll_chance(50) else shop_basement.width - 2
		basement_corner.y = 1 if _dice_roller.roll_chance(50) else shop_basement.height - 2
		var shop_corner := Vector2i(basement_corner.x - 1 + b.inside_rect.position.x, basement_corner.y - 1 + b.inside_rect.position.y)
		add_exit(shop_basement, basement_corner, map, shop_corner, GameImages.DECO_STAIRS_UP, true)
		add_exit(map, shop_corner, shop_basement, basement_corner, GameImages.DECO_STAIRS_DOWN, true)

		# remove any blocking object in the shop.
		var blocker: MapObject = map.get_map_object_at(shop_corner)
		if blocker != null:
			map.remove_map_object_at(shop_corner.x, shop_corner.y)

		# add map.
		_params.district.add_unique_map(shop_basement)

	# Done
	return true


## Either an Office (for large enough buildings) or an Agency (for small buildings).
func make_char_building(map: Map, b: Block) -> CHARBuildingType:
	################################
	# Offices are large buildings.
	# Agency are small ones.
	################################
	if b.inside_rect.size.x < 8 || b.inside_rect.size.y < 8:
		# small, make it an Agency.
		if make_char_agency(map, b):
			return CHARBuildingType.AGENCY
		else:
			return CHARBuildingType.NONE
	else:
		if make_char_office(map, b):
			return CHARBuildingType.OFFICE
		else:
			return CHARBuildingType.NONE


static var CHAR_POSTERS: Array = [GameImages.DECO_CHAR_POSTER1, GameImages.DECO_CHAR_POSTER2, GameImages.DECO_CHAR_POSTER3]


func make_char_agency(map: Map, b: Block) -> bool:
	############################
	# 1. Walkway, floor & walls
	############################
	tile_rectangle(map, game.game_tiles.floor_walkway(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	tile_rectangle(map, game.game_tiles.wall_char_office(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	var inside_logo_fn := func(tile, _prevmodel, _x, _y):
		tile.is_inside = true
		tile.add_decoration(GameImages.DECO_CHAR_FLOOR_LOGO)
	tile_fill_rect(map, game.game_tiles.floor_office(), b.inside_rect, inside_logo_fn)

	#########################
	# 2. Decide orientation.
	#########################
	var horizontal_corridor: bool = (b.inside_rect.size.x >= b.inside_rect.size.y)

	################
	# 3. Entry door
	################
	var mid_x: int = b.rectangle.position.x + b.rectangle.size.x / 2
	var mid_y: int = b.rectangle.position.y + b.rectangle.size.y / 2

	# make doors on one side.
	if horizontal_corridor:
		var west: bool = _dice_roller.roll_chance(50)

		if west:
			# west
			place_door(map, b.building_rect.position.x, mid_y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.y >= 8:
				place_door(map, b.building_rect.position.x, mid_y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.y >= 12:
					place_door(map, b.building_rect.position.x, mid_y + 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
		else:
			# east
			place_door(map, b.building_rect.end.x - 1, mid_y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.y >= 8:
				place_door(map, b.building_rect.end.x - 1, mid_y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.y >= 12:
					place_door(map, b.building_rect.end.x - 1, mid_y + 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
	else:
		var north: bool = _dice_roller.roll_chance(50)

		if north:
			# north
			place_door(map, mid_x, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.x >= 8:
				place_door(map, mid_x - 1, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.x >= 12:
					place_door(map, mid_x + 1, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
		else:
			# south
			place_door(map, mid_x, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.x >= 8:
				place_door(map, mid_x - 1, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.x >= 12:
					place_door(map, mid_x + 1, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())

	# add office image next to doors.
	var office_image: String = GameImages.DECO_CHAR_OFFICE
	var office_deco_fn := func(x, y): return (office_image as Variant) if (map.get_map_object_at_xy(x, y) == null && count_adj_doors(map, x, y) >= 1) else null
	decorate_outside_walls(map, b.building_rect, office_deco_fn)

	###############
	# 4. Furniture
	###############
	# chairs on the sides.
	# alpha10.1 chance to add book/magazines
	var agency_chair_fn := func(pt):
		if count_adj_walls_xy(map, pt.x, pt.y) < 3:
			return null

		# alpha10.1 book/magazines on chair?
		if _dice_roller.roll_chance(25):
			map.drop_item_at((make_item_book() if _dice_roller.roll_chance(20) else make_item_magazines()), pt)

		return make_obj_chair(GameImages.OBJ_CHAR_CHAIR)
	map_object_fill_rect(map, b.inside_rect, agency_chair_fn)
	# walls/pilars in the middle.
	var poster_fn := func(tile, _model, _x, _y):
		tile.add_decoration(CHAR_POSTERS[_dice_roller.roll(0, CHAR_POSTERS.size())])
	tile_fill_rect(map, game.game_tiles.wall_char_office(), Rect2i(b.inside_rect.position.x + b.inside_rect.size.x / 2 - 1, b.inside_rect.position.y + b.inside_rect.size.y / 2 - 1, 3, 2), poster_fn)

	#############
	# 5. Posters
	#############
	# outside.
	var agency_poster_fn := func(x, y):
		if count_adj_doors(map, x, y) > 0:
			return null
		else:
			if _dice_roller.roll_chance(25):
				return CHAR_POSTERS[_dice_roller.roll(0, CHAR_POSTERS.size())]
			else:
				return null
	decorate_outside_walls(map, b.building_rect, agency_poster_fn)

	###########
	# 6. Zones.
	###########
	map.add_zone(make_unique_zone("CHAR Agency", b.building_rect))
	make_walkway_zones(map, b)

	# Done
	return true


func make_char_office(map: Map, b: Block) -> bool:
	############################
	# 1. Walkway, floor & walls
	############################
	tile_rectangle(map, game.game_tiles.floor_walkway(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	tile_rectangle(map, game.game_tiles.wall_char_office(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	var inside_fn := func(tile, _prevmodel, _x, _y): tile.is_inside = true
	tile_fill_rect(map, game.game_tiles.floor_office(), b.inside_rect, inside_fn)

	#########################
	# 2. Decide orientation.
	#########################
	var horizontal_corridor: bool = (b.inside_rect.size.x >= b.inside_rect.size.y)

	################
	# 3. Entry door
	################
	var mid_x: int = b.rectangle.position.x + b.rectangle.size.x / 2
	var mid_y: int = b.rectangle.position.y + b.rectangle.size.y / 2
	var door_side: Direction

	# make doors on one side.
	if horizontal_corridor:
		var west: bool = _dice_roller.roll_chance(50)

		if west:
			door_side = Direction.W
			# west
			place_door(map, b.building_rect.position.x, mid_y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.y >= 8:
				place_door(map, b.building_rect.position.x, mid_y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.y >= 12:
					place_door(map, b.building_rect.position.x, mid_y + 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
		else:
			door_side = Direction.E
			# east
			place_door(map, b.building_rect.end.x - 1, mid_y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.y >= 8:
				place_door(map, b.building_rect.end.x - 1, mid_y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.y >= 12:
					place_door(map, b.building_rect.end.x - 1, mid_y + 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
	else:
		var north: bool = _dice_roller.roll_chance(50)

		if north:
			door_side = Direction.N
			# north
			place_door(map, mid_x, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.x >= 8:
				place_door(map, mid_x - 1, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.x >= 12:
					place_door(map, mid_x + 1, b.building_rect.position.y, game.game_tiles.floor_walkway(), make_obj_glass_door())
		else:
			door_side = Direction.S
			# south
			place_door(map, mid_x, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
			if b.inside_rect.size.x >= 8:
				place_door(map, mid_x - 1, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())
				if b.inside_rect.size.x >= 12:
					place_door(map, mid_x + 1, b.building_rect.end.y - 1, game.game_tiles.floor_walkway(), make_obj_glass_door())

	# add office image next to doors.
	var office_image: String = GameImages.DECO_CHAR_OFFICE
	var office_deco_fn := func(x, y): return (office_image as Variant) if (map.get_map_object_at_xy(x, y) == null && count_adj_doors(map, x, y) >= 1) else null
	decorate_outside_walls(map, b.building_rect, office_deco_fn)

	# barricade entry doors.
	barricade_doors(map, b.building_rect, Rules.BARRICADING_MAX)

	######################
	# 4. Make entry hall.
	######################
	const hall_depth: int = 3
	if door_side == Direction.N:
		tile_h_line(map, game.game_tiles.wall_char_office(), b.inside_rect.position.x, b.inside_rect.position.y + hall_depth, b.inside_rect.size.x)
	elif door_side == Direction.S:
		tile_h_line(map, game.game_tiles.wall_char_office(), b.inside_rect.position.x, b.inside_rect.end.y - 1 - hall_depth, b.inside_rect.size.x)
	elif door_side == Direction.E:
		tile_v_line(map, game.game_tiles.wall_char_office(), b.inside_rect.end.x - 1 - hall_depth, b.inside_rect.position.y, b.inside_rect.size.y)
	elif door_side == Direction.W:
		tile_v_line(map, game.game_tiles.wall_char_office(), b.inside_rect.position.x + hall_depth, b.inside_rect.position.y, b.inside_rect.size.y)
	else:
		# C# threw InvalidOperationException.
		push_error("BaseTownGenerator : unhandled door side")

	####################################
	# 5. Make central corridor & wings
	####################################
	var corridor_rect: Rect2i
	var corridor_door: Vector2i
	if door_side == Direction.N:
		corridor_rect = Rect2i(mid_x - 1, b.inside_rect.position.y + hall_depth, 3, b.building_rect.size.y - 1 - hall_depth)
		corridor_door = Vector2i(corridor_rect.position.x + 1, corridor_rect.position.y)
	elif door_side == Direction.S:
		corridor_rect = Rect2i(mid_x - 1, b.building_rect.position.y, 3, b.building_rect.size.y - 1 - hall_depth)
		corridor_door = Vector2i(corridor_rect.position.x + 1, corridor_rect.end.y - 1)
	elif door_side == Direction.E:
		corridor_rect = Rect2i(b.building_rect.position.x, mid_y - 1, b.building_rect.size.x - 1 - hall_depth, 3)
		corridor_door = Vector2i(corridor_rect.end.x - 1, corridor_rect.position.y + 1)
	elif door_side == Direction.W:
		corridor_rect = Rect2i(b.inside_rect.position.x + hall_depth, mid_y - 1, b.building_rect.size.x - 1 - hall_depth, 3)
		corridor_door = Vector2i(corridor_rect.position.x, corridor_rect.position.y + 1)
	else:
		# C# threw InvalidOperationException.
		push_error("BaseTownGenerator : unhandled door side")

	tile_rectangle(map, game.game_tiles.wall_char_office(), corridor_rect.position.x, corridor_rect.position.y, corridor_rect.size.x, corridor_rect.size.y)
	place_door(map, corridor_door.x, corridor_door.y, game.game_tiles.floor_office(), make_obj_char_door())

	########################
	# 6. Make office rooms.
	########################
	# make wings.
	var wing_one: Rect2i
	var wing_two: Rect2i
	if horizontal_corridor:
		# top side.
		wing_one = Rect2i(corridor_rect.position.x, b.building_rect.position.y, corridor_rect.size.x, 1 + corridor_rect.position.y - b.building_rect.position.y)
		# bottom side.
		wing_two = Rect2i(corridor_rect.position.x, corridor_rect.end.y - 1, corridor_rect.size.x, 1 + b.building_rect.end.y - corridor_rect.end.y)
	else:
		# left side
		wing_one = Rect2i(b.building_rect.position.x, corridor_rect.position.y, 1 + corridor_rect.position.x - b.building_rect.position.x, corridor_rect.size.y)
		# right side
		wing_two = Rect2i(corridor_rect.end.x - 1, corridor_rect.position.y, 1 + b.building_rect.end.x - corridor_rect.end.x, corridor_rect.size.y)

	# make rooms in each wing with doors leaving toward corridor.
	const office_rooms_size: int = 4

	var offices_one: Array = []
	make_rooms_plan(map, offices_one, wing_one, office_rooms_size, office_rooms_size)

	var offices_two: Array = []
	make_rooms_plan(map, offices_two, wing_two, office_rooms_size, office_rooms_size)

	var all_offices: Array = []
	all_offices.append_array(offices_one)
	all_offices.append_array(offices_two)

	for room_rect in offices_one:
		tile_rectangle(map, game.game_tiles.wall_char_office(), room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y)
		map.add_zone(make_unique_zone("Office room", room_rect))
	for room_rect in offices_two:
		tile_rectangle(map, game.game_tiles.wall_char_office(), room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y)
		map.add_zone(make_unique_zone("Office room", room_rect))

	for room_rect in offices_one:
		if horizontal_corridor:
			place_door(map, room_rect.position.x + room_rect.size.x / 2, room_rect.end.y - 1, game.game_tiles.floor_office(), make_obj_char_door())
		else:
			place_door(map, room_rect.end.x - 1, room_rect.position.y + room_rect.size.y / 2, game.game_tiles.floor_office(), make_obj_char_door())
	for room_rect in offices_two:
		if horizontal_corridor:
			place_door(map, room_rect.position.x + room_rect.size.x / 2, room_rect.position.y, game.game_tiles.floor_office(), make_obj_char_door())
		else:
			place_door(map, room_rect.position.x, room_rect.position.y + room_rect.size.y / 2, game.game_tiles.floor_office(), make_obj_char_door())

	# tables with chairs.
	for room_rect in all_offices:
		# table.
		var table_pos := Vector2i(room_rect.position.x + room_rect.size.x / 2, room_rect.position.y + room_rect.size.y / 2)
		map.place_map_object_at(make_obj_table(GameImages.OBJ_CHAR_TABLE), table_pos)

		# try to put chairs around.
		var nb_chairs: int = 2
		var inside_room := Rect2i(room_rect.position.x + 1, room_rect.position.y + 1, room_rect.size.x - 2, room_rect.size.y - 2)
		if !_rect_is_empty(inside_room):
			for i in nb_chairs:
				var adj_table_rect := Rect2i(table_pos.x - 1, table_pos.y - 1, 3, 3)
				adj_table_rect = adj_table_rect.intersection(inside_room)
				var not_table_fn := func(pt): return pt != table_pos
				var chair_fn := func(_pt): return make_obj_chair(GameImages.OBJ_CHAR_CHAIR)
				map_object_place_in_good_position_rect(map, adj_table_rect, not_table_fn, _dice_roller, chair_fn)

	###############
	# 7. Add items.
	###############
	# drop goodies in rooms.
	for room_rect in all_offices:
		var office_floor_fn := func(pt):
			var tile: Tile = map.get_tile_at_p(pt)
			if tile.model != game.game_tiles.floor_office():
				return false
			var map_obj: MapObject = map.get_map_object_at(pt)
			if map_obj != null:
				return false
			return true
		var char_item_fn := func(_pt): return make_random_char_office_item()
		items_drop(map, room_rect, office_floor_fn, char_item_fn)

	#########
	# 8. Zone
	#########
	var zone: Zone = make_unique_zone("CHAR Office", b.building_rect)
	zone.set_game_attribute(ZoneAttributes.IS_CHAR_OFFICE, true)
	map.add_zone(zone)
	make_walkway_zones(map, b)

	# Done
	return true


func make_park_building(map: Map, b: Block) -> bool:
	#######################
	# 0. Check suitability
	#######################
	if b.inside_rect.size.x < 3 || b.inside_rect.size.y < 3:
		return false

	############################
	# 1. Grass, walkway & fence
	############################
	tile_rectangle(map, game.game_tiles.floor_walkway(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	tile_fill_rect(map, game.game_tiles.floor_grass(), b.inside_rect)
	var park_fence_fn := func(pt):
		var place_fence: bool = (pt.x == b.building_rect.position.x || pt.x == b.building_rect.end.x - 1 || pt.y == b.building_rect.position.y || pt.y == b.building_rect.end.y - 1)
		if place_fence:
			return make_obj_fence(GameImages.OBJ_FENCE)
		else:
			return null
	map_object_fill_rect(map, b.building_rect, park_fence_fn)

	##############################
	# 2. Random trees and benches
	##############################
	var park_tree_fn := func(_pt):
		var place_tree: bool = _dice_roller.roll_chance(PARK_TREE_CHANCE)
		if place_tree:
			return make_obj_tree(GameImages.OBJ_TREE)
		else:
			return null
	map_object_fill_rect(map, b.inside_rect, park_tree_fn)

	var park_bench_fn := func(_pt):
		var place_bench: bool = _dice_roller.roll_chance(PARK_BENCH_CHANCE)
		if place_bench:
			return make_obj_bench(GameImages.OBJ_BENCH)
		else:
			return null
	map_object_fill_rect(map, b.inside_rect, park_bench_fn)

	#############
	# 3. Entrance
	#############
	var entrance_face: int = _dice_roller.roll(0, 4)
	var ex: int
	var ey: int
	match entrance_face:
		0:  # west
			ex = b.building_rect.position.x
			ey = b.building_rect.position.y + b.building_rect.size.y / 2
		1:  # east
			ex = b.building_rect.end.x - 1
			ey = b.building_rect.position.y + b.building_rect.size.y / 2
		3:  # north
			ex = b.building_rect.position.x + b.building_rect.size.x / 2
			ey = b.building_rect.position.y
		_:  # south
			ex = b.building_rect.position.x + b.building_rect.size.x / 2
			ey = b.building_rect.end.y - 1
	map.remove_map_object_at(ex, ey)
	map.set_tile_model_at(ex, ey, game.game_tiles.floor_walkway())

	###########
	# 4. Items
	###########
	var park_item_pos_fn := func(pt): return map.get_map_object_at(pt) == null && _dice_roller.roll_chance(PARK_ITEM_CHANCE)
	var park_item_fn := func(_pt): return make_random_park_item()
	items_drop(map, b.inside_rect, park_item_pos_fn, park_item_fn)

	#########
	# 5. Zone
	#########
	var park_zone: Zone = make_unique_zone("Park", b.building_rect)
	map.add_zone(park_zone)
	make_walkway_zones(map, b)

	# alpha10
	##########
	# 5. Shed?
	##########
	if b.inside_rect.size.x > PARK_SHED_WIDTH + 2 && b.inside_rect.size.y > PARK_SHED_HEIGHT + 2:
		if _dice_roller.roll_chance(PARK_SHED_CHANCE):
			# roll shed pos - dont put next to park fences!
			var shed_x: int = _dice_roller.roll(b.inside_rect.position.x + 1, b.inside_rect.end.x - PARK_SHED_WIDTH)
			var shed_y: int = _dice_roller.roll(b.inside_rect.position.y + 1, b.inside_rect.end.y - PARK_SHED_HEIGHT)
			var shed_rect := Rect2i(shed_x, shed_y, PARK_SHED_WIDTH, PARK_SHED_HEIGHT)
			var _shed_inside_rect := Rect2i(shed_x + 1, shed_y + 1, PARK_SHED_WIDTH - 2, PARK_SHED_HEIGHT - 2)

			# clear everything but zones in shed location
			clear_rectangle(map, shed_rect, false)

			# build it
			make_park_shed_building(map, "Shed", shed_rect)

	# Done.
	return true


func make_park_shed_building(map: Map, base_zone_name: String, shed_building_rect: Rect2i) -> void:
	var shed_inside_rect := Rect2i(shed_building_rect.position.x + 1, shed_building_rect.position.y + 1, shed_building_rect.size.x - 2, shed_building_rect.size.y - 2)

	# build building & zone
	tile_rectangle(map, game.game_tiles.wall_brick(), shed_building_rect.position.x, shed_building_rect.position.y, shed_building_rect.size.x, shed_building_rect.size.y)
	var inside_fn := func(tile, _prev_tile_model, _x, _y): tile.is_inside = true
	tile_fill_rect(map, game.game_tiles.floor_planks(), shed_inside_rect, inside_fn)
	map.add_zone(make_unique_zone(base_zone_name, shed_building_rect))

	# place shed door and make sure door front is cleared of objects (trees).
	var door_dir: int = _dice_roller.roll(0, 4)
	var door_x: int
	var door_y: int
	var door_front_x: int
	var door_front_y: int
	match door_dir:
		0:  # west
			door_x = shed_building_rect.position.x
			door_y = shed_building_rect.position.y + shed_building_rect.size.y / 2
			door_front_x = door_x - 1
			door_front_y = door_y
		1:  # east
			door_x = shed_building_rect.end.x - 1
			door_y = shed_building_rect.position.y + shed_building_rect.size.y / 2
			door_front_x = door_x + 1
			door_front_y = door_y
		3:  # north
			door_x = shed_building_rect.position.x + shed_building_rect.size.x / 2
			door_y = shed_building_rect.position.y
			door_front_x = door_x
			door_front_y = door_y - 1
		_:  # south
			door_x = shed_building_rect.position.x + shed_building_rect.size.x / 2
			door_y = shed_building_rect.end.y - 1
			door_front_x = door_x
			door_front_y = door_y + 1
	place_door(map, door_x, door_y, game.game_tiles.floor_tiles(), make_obj_wooden_door())
	map.remove_map_object_at(door_front_x, door_front_y)

	# mark as inside and add shelves with tools
	var shed_fill_fn := func(pt):
		if !map.is_walkable_p(pt):
			return

		if count_adj_doors(map, pt.x, pt.y) > 0:
			return

		if count_adj_walls_xy(map, pt.x, pt.y) == 0:
			return

		# shelf.
		map.place_map_object_at(make_obj_shelf(GameImages.OBJ_SHOP_SHELF), pt)

		# construction item (tools, lights)
		var it: Item = make_shop_construction_item()
		if it.model.is_stackable:
			it.quantity = it.model.stacking_limit
		map.drop_item_at(it, pt)
	do_for_each_tile(map, shed_inside_rect, shed_fill_fn)


# alpha10.1 makes apartements or vanilla house
func make_housing_building(map: Map, b: Block) -> bool:
	# alpha10.1 decide floorplan
	# apartment?
	if _dice_roller.roll_chance(HOUSE_IS_APARTMENTS_CHANCE):
		if make_apartments_building(map, b):
			return true

	# vanilla house?
	return make_vanilla_housing_building(map, b)


# alpha10.1 apartment houses
func make_apartments_building(map: Map, b: Block) -> bool:
	#######################
	# 0. Check suitability
	#######################
	if b.inside_rect.size.x < 9 || b.inside_rect.size.y < 9:
		return false
	if b.inside_rect.size.x > 17 || b.inside_rect.size.y > 17:
		return false

	# I pretty much copied and edited the char office algorithm. lame but i'm lazy.

	############################
	# 1. Walkway, floor & walls
	############################
	tile_rectangle(map, game.game_tiles.floor_walkway(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	tile_rectangle(map, game.game_tiles.wall_brick(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	var inside_fn := func(tile, _prevmodel, _x, _y): tile.is_inside = true
	tile_fill_rect(map, game.game_tiles.floor_planks(), b.inside_rect, inside_fn)

	#########################
	# 2. Decide orientation.
	#########################
	var horizontal_corridor: bool = (b.inside_rect.size.x >= b.inside_rect.size.y)

	##################################
	# 3. Entry door and opposite window
	##################################
	var mid_x: int = b.rectangle.position.x + b.rectangle.size.x / 2
	var mid_y: int = b.rectangle.position.y + b.rectangle.size.y / 2
	var door_side: Direction

	if horizontal_corridor:
		var west: bool = _dice_roller.roll_chance(50)

		if west:
			door_side = Direction.W
			# west
			place_door(map, b.building_rect.position.x, mid_y, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, b.building_rect.end.x - 1, mid_y, game.game_tiles.floor_planks(), make_obj_window())
		else:
			door_side = Direction.E
			# east
			place_door(map, b.building_rect.end.x - 1, mid_y, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, b.building_rect.position.x, mid_y, game.game_tiles.floor_planks(), make_obj_window())
	else:
		var north: bool = _dice_roller.roll_chance(50)

		if north:
			door_side = Direction.N
			# north
			place_door(map, mid_x, b.building_rect.position.y, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, mid_x, b.building_rect.end.y - 1, game.game_tiles.floor_planks(), make_obj_window())
		else:
			door_side = Direction.S
			# south
			place_door(map, mid_x, b.building_rect.end.y - 1, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, mid_x, b.building_rect.position.y, game.game_tiles.floor_planks(), make_obj_window())

	##########################################
	# 4. Make central corridor & side apartments
	##########################################
	var corridor_rect: Rect2i
	if door_side == Direction.N:
		corridor_rect = Rect2i(mid_x, b.building_rect.position.y, 1, b.building_rect.size.y - 1)
	elif door_side == Direction.S:
		corridor_rect = Rect2i(mid_x, b.building_rect.position.y, 1, b.building_rect.size.y - 1)
	elif door_side == Direction.E:
		corridor_rect = Rect2i(b.building_rect.position.x, mid_y, b.building_rect.size.x - 1, 1)
	elif door_side == Direction.W:
		corridor_rect = Rect2i(b.inside_rect.position.x, mid_y, b.building_rect.size.x - 1, 1)
	else:
		# C# threw InvalidOperationException.
		push_error("BaseTownGenerator : apartment: unhandled door side")

	######################
	# 5. Make apartments
	######################
	# make wings.
	var wing_one: Rect2i
	var wing_two: Rect2i
	if horizontal_corridor:
		# top side.
		# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
		wing_one = Rect2i(b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, corridor_rect.position.y - b.building_rect.position.y)
		# bottom side.
		wing_two = Rect2i(b.building_rect.position.x, corridor_rect.end.y, b.building_rect.size.x, b.building_rect.end.y - corridor_rect.end.y)
	else:
		# left side
		wing_one = Rect2i(b.building_rect.position.x, b.building_rect.position.y, corridor_rect.position.x - b.building_rect.position.x, b.building_rect.size.y)
		# right side
		wing_two = Rect2i(corridor_rect.end.x, b.building_rect.position.y, b.building_rect.end.x - corridor_rect.end.x, b.building_rect.size.y)

	# make apartements in each wing with doors leaving toward corridor and windows to the outside
	# pick sizes so the apartements are not cut into multiple rooms by MakeRoomsPlan
	var apartment_min_x_size: int
	var apartment_min_y_size: int
	if horizontal_corridor:
		apartment_min_x_size = 4
		apartment_min_y_size = b.building_rect.size.y / 2
	else:
		apartment_min_x_size = b.building_rect.size.x / 2
		apartment_min_y_size = 4

	var apartements_wing_one: Array = []
	make_rooms_plan(map, apartements_wing_one, wing_one, apartment_min_x_size, apartment_min_y_size)
	var apartements_wing_two: Array = []
	make_rooms_plan(map, apartements_wing_two, wing_two, apartment_min_x_size, apartment_min_y_size)

	var all_apartments: Array = []
	all_apartments.append_array(apartements_wing_one)
	all_apartments.append_array(apartements_wing_two)

	for apart_rect in apartements_wing_one:
		tile_rectangle(map, game.game_tiles.wall_brick(), apart_rect.position.x, apart_rect.position.y, apart_rect.size.x, apart_rect.size.y)
	for room_rect in apartements_wing_two:
		tile_rectangle(map, game.game_tiles.wall_brick(), room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y)

	# put door leading to corridor; and an opposite window if outer wall / a door if inside
	for apart_rect in apartements_wing_one:
		if horizontal_corridor:
			place_door(map, apart_rect.position.x + apart_rect.size.x / 2, apart_rect.end.y - 1, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, apart_rect.position.x + apart_rect.size.x / 2, apart_rect.position.y, game.game_tiles.floor_planks(), make_obj_window())
		else:
			place_door(map, apart_rect.end.x - 1, apart_rect.position.y + apart_rect.size.y / 2, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, apart_rect.position.x, apart_rect.position.y + apart_rect.size.y / 2, game.game_tiles.floor_planks(), make_obj_window())
	for apart_rect in apartements_wing_two:
		if horizontal_corridor:
			place_door(map, apart_rect.position.x + apart_rect.size.x / 2, apart_rect.position.y, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, apart_rect.position.x + apart_rect.size.x / 2, apart_rect.end.y - 1, game.game_tiles.floor_planks(), make_obj_window())
		else:
			place_door(map, apart_rect.position.x, apart_rect.position.y + apart_rect.size.y / 2, game.game_tiles.floor_planks(), make_obj_wooden_door())
			place_door(map, apart_rect.end.x - 1, apart_rect.position.y + apart_rect.size.y / 2, game.game_tiles.floor_planks(), make_obj_window())

	# fill appartements with furniture and items
	# an "apartement" is one big room that fits all the housing roles: bedroom, kitchen and living room.
	for apart_rect in all_apartments:
		# bedroom
		fill_housing_room_contents(map, apart_rect, 0)
		# kitchen
		fill_housing_room_contents(map, apart_rect, 8)
		# living room
		fill_housing_room_contents(map, apart_rect, 5)

	#########
	# 6. Zone
	#########
	var zone: Zone = make_unique_zone("Apartements", b.building_rect)
	map.add_zone(zone)
	make_walkway_zones(map, b)

	# done
	return true


# alpha10.1 pre alpha10.1 regular houses
func make_vanilla_housing_building(map: Map, b: Block) -> bool:
	#######################
	# 0. Check suitability
	#######################
	if b.inside_rect.size.x < 4 || b.inside_rect.size.y < 4:
		return false

	############################
	# 1. Walkway, floor & walls
	############################
	tile_rectangle(map, game.game_tiles.floor_walkway(), b.rectangle.position.x, b.rectangle.position.y, b.rectangle.size.x, b.rectangle.size.y)
	tile_rectangle(map, game.game_tiles.wall_brick(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	var inside_fn := func(tile, _prevmodel, _x, _y): tile.is_inside = true
	tile_fill_rect(map, game.game_tiles.floor_planks(), b.inside_rect, inside_fn)

	######################
	# 2. Rooms floor plan
	######################
	var rooms_list: Array = []
	make_rooms_plan(map, rooms_list, b.building_rect, 5, 5)

	################
	# 3. Make rooms
	################
	# alpha10 make some housings floor plan non rectangular by randomly chosing not to place one border room
	# and replace it with a special "outside" room : a garden, a parking lot.

	var i_outside_room: int = -1
	var outside_room: HouseOutsideRoomType = HouseOutsideRoomType.GARDEN  # C# init to _FIRST
	if rooms_list.size() >= HOUSE_OUTSIDE_ROOM_NEED_MIN_ROOMS && _dice_roller.roll_chance(HOUSE_OUTSIDE_ROOM_CHANCE):
		var outside_tries: int = 0
		while outside_tries < 100:
			outside_tries += 1
			i_outside_room = _dice_roller.roll(0, rooms_list.size())
			var r: Rect2i = rooms_list[i_outside_room]
			if r.position.x == b.building_rect.position.x || r.end.x == b.building_rect.end.x \
					|| r.position.y == b.building_rect.position.y || r.end.y == b.building_rect.end.y:
				break
		outside_room = _dice_roller.roll(HouseOutsideRoomType.GARDEN, HouseOutsideRoomType._COUNT) as HouseOutsideRoomType

	for i in rooms_list.size():
		var room_rect: Rect2i = rooms_list[i]
		if i_outside_room == i:
			# make sure all tiles are marked as outside
			var outside_fn := func(pt): map.get_tile_at_p(pt).is_inside = false
			do_for_each_tile(map, room_rect, outside_fn)

			# then shrink it properly so we dont overlap with tiles from other rooms and mess things up.
			if room_rect.position.x != b.building_rect.position.x:
				room_rect.position.x += 1
				room_rect.size.x -= 1
			if room_rect.end.x != b.building_rect.end.x:
				room_rect.size.x -= 1
			if room_rect.position.y != b.building_rect.position.y:
				room_rect.position.y += 1
				room_rect.size.y -= 1
			if room_rect.end.y != b.building_rect.end.y:
				room_rect.size.y -= 1

			# then fill the outside room
			match outside_room:
				HouseOutsideRoomType.GARDEN:
					tile_fill_rect(map, game.game_tiles.floor_grass(), room_rect)
					var garden_tree_fn := func(pos):
						if map.get_tile_at_p(pos).model == game.game_tiles.floor_grass() && _dice_roller.roll_chance(HOUSE_GARDEN_TREE_CHANCE):
							map.place_map_object_at(make_obj_tree(GameImages.OBJ_TREE), pos)
					do_for_each_tile(map, room_rect, garden_tree_fn)

				HouseOutsideRoomType.PARKING_LOT:
					tile_fill_rect(map, game.game_tiles.floor_asphalt(), room_rect)
					var lot_car_fn := func(pos):
						if map.get_tile_at_p(pos).model == game.game_tiles.floor_asphalt() && _dice_roller.roll_chance(HOUSE_PARKING_LOT_CAR_CHANCE):
							map.place_map_object_at(make_obj_wrecked_car(_dice_roller), pos)
					do_for_each_tile(map, room_rect, lot_car_fn)
		else:
			make_housing_room(map, room_rect, game.game_tiles.floor_planks(), game.game_tiles.wall_brick())
			fill_housing_room_contents(map, room_rect)

	# once all rooms are done, enclose the outside room
	if i_outside_room != -1:
		var room_rect: Rect2i = rooms_list[i_outside_room]
		match outside_room:
			HouseOutsideRoomType.GARDEN:
				var garden_fence_fn := func(pos):
					if (pos.x == room_rect.position.x || pos.x == room_rect.end.x - 1 || pos.y == room_rect.position.y || pos.y == room_rect.end.y - 1) \
							&& map.get_tile_at_p(pos).model == game.game_tiles.floor_grass():
						map.remove_map_object_at(pos.x, pos.y)  # make sure trees are removed
						map.place_map_object_at(make_obj_fence(GameImages.OBJ_GARDEN_FENCE, MapObject.Fire.BURNABLE, DoorWindow.BASE_HITPOINTS / 2), pos)
				do_for_each_tile(map, room_rect, garden_fence_fn)

			HouseOutsideRoomType.PARKING_LOT:
				var wire_fence_fn := func(pos):
					var is_lot_entry: bool = (pos.x == room_rect.position.x + room_rect.size.x / 2) || (pos.y == room_rect.position.y + room_rect.size.y / 2)
					if !is_lot_entry && ((pos.x == room_rect.position.x || pos.x == room_rect.end.x - 1 || pos.y == room_rect.position.y || pos.y == room_rect.end.y - 1) \
							&& map.get_tile_at_p(pos).model == game.game_tiles.floor_asphalt()):
						map.remove_map_object_at(pos.x, pos.y)  # make sure cars are removed
						map.place_map_object_at(make_obj_wire_fence(GameImages.OBJ_WIRE_FENCE), pos)
				do_for_each_tile(map, room_rect, wire_fence_fn)

	#######################################
	# 5. Fix buildings with no door exits
	#######################################
	var has_outside_door := false
	for x in range(b.building_rect.position.x, b.building_rect.end.x):
		if has_outside_door:
			break
		for y in range(b.building_rect.position.y, b.building_rect.end.y):
			if !map.get_tile_at(x, y).is_inside:
				var door: DoorWindow = map.get_map_object_at_xy(x, y) as DoorWindow
				if door != null && !door.is_window:
					has_outside_door = true
					break
	if !has_outside_door:
		# replace a random window with a door.
		# alpha10 list all the exit windows, pick one and replace with a door.

		# list all exit windows
		var building_exits: Array = []
		for x in range(b.building_rect.position.x, b.building_rect.end.x):
			for y in range(b.building_rect.position.y, b.building_rect.end.y):
				if !map.get_tile_at(x, y).is_inside:
					var window: DoorWindow = map.get_map_object_at_xy(x, y) as DoorWindow
					if window != null && window.is_window:
						building_exits.append(Vector2i(x, y))

		# replace an exit window with a door
		if building_exits.size() > 0:
			var new_door_pos: Vector2i = building_exits[_dice_roller.roll(0, building_exits.size())]
			map.remove_map_object_at(new_door_pos.x, new_door_pos.y)
			map.place_map_object_at(make_obj_wooden_door(), new_door_pos)
			has_outside_door = true

		# if we did not found an exit window to replace this is a bug, it should never happen.
		# i'm lazy and assume this never happens and throw an exception.
		# C# threw Exception (aborts generation); here we report and abort the house.
		if has_outside_door == false:
			push_error("ERROR: house has no exit, should never happen; sector@%s house@%s" % [map.district.world_position, b.building_rect])
			return false

	###############
	# 6. Basement?
	###############
	if _dice_roller.roll_chance(HOUSE_BASEMENT_CHANCE):
		var basement_map: Map = generate_house_basement_map(map, b)
		_params.district.add_unique_map(basement_map)

	#########
	# 7. Zone
	#########
	map.add_zone(make_unique_zone("Housing", b.building_rect))
	make_walkway_zones(map, b)

	# Done
	return true


func make_sewers_maintenance_building(map: Map, is_surface: bool, b: Block, linked_map: Map, exit_position: Vector2i) -> void:
	###############
	# Outer walls.
	###############
	# if sewers dig room.
	if !is_surface:
		tile_fill_rect(map, game.game_tiles.floor_concrete(), b.inside_rect)
	# outer walls.
	tile_rectangle(map, game.game_tiles.wall_sewer(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	# make sure its marked as inside (in case we replace a park for instance)
	for x in range(b.inside_rect.position.x, b.inside_rect.end.x):
		for y in range(b.inside_rect.position.y, b.inside_rect.end.y):
			map.get_tile_at(x, y).is_inside = true

	###################
	# Entrance door.
	###################
	# pick door side and put tags.
	var door_x: int
	var door_y: int
	var dig_direction: Direction
	var side_roll: int = _dice_roller.roll(0, 4)
	match side_roll:
		0:  # north.
			dig_direction = Direction.N
			door_x = b.building_rect.position.x + b.building_rect.size.x / 2
			door_y = b.building_rect.position.y

			_safe_add_decoration(map, door_x - 1, door_y, GameImages.DECO_SEWERS_BUILDING)
			_safe_add_decoration(map, door_x + 1, door_y, GameImages.DECO_SEWERS_BUILDING)

		1:  # south.
			dig_direction = Direction.S
			door_x = b.building_rect.position.x + b.building_rect.size.x / 2
			door_y = b.building_rect.end.y - 1

			_safe_add_decoration(map, door_x - 1, door_y, GameImages.DECO_SEWERS_BUILDING)
			_safe_add_decoration(map, door_x + 1, door_y, GameImages.DECO_SEWERS_BUILDING)

		2:  # west.
			dig_direction = Direction.W
			door_x = b.building_rect.position.x
			door_y = b.building_rect.position.y + b.building_rect.size.y / 2

			_safe_add_decoration(map, door_x, door_y - 1, GameImages.DECO_SEWERS_BUILDING)
			_safe_add_decoration(map, door_x, door_y + 1, GameImages.DECO_SEWERS_BUILDING)

		3:  # east.
			dig_direction = Direction.E
			door_x = b.building_rect.end.x - 1
			door_y = b.building_rect.position.y + b.building_rect.size.y / 2

			_safe_add_decoration(map, door_x, door_y - 1, GameImages.DECO_SEWERS_BUILDING)
			_safe_add_decoration(map, door_x, door_y + 1, GameImages.DECO_SEWERS_BUILDING)

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
	# add the door.
	place_door(map, door_x, door_y, game.game_tiles.floor_concrete(), make_obj_iron_door())
	barricade_doors(map, b.building_rect, Rules.BARRICADING_MAX)

	##################################
	# Hole/Ladder to sewers/surface.
	##################################
	# add exit.
	_safe_add_decoration(map, exit_position.x, exit_position.y, GameImages.DECO_SEWER_HOLE if is_surface else GameImages.DECO_SEWER_LADDER)
	var exit := Map.Exit.new(linked_map, exit_position)
	exit.is_an_ai_exit = true
	map.set_exit_at(exit_position, exit)

	###################################################
	# If sewers, dig corridor until we reach a tunnel.
	###################################################
	if !is_surface:
		var dig_pos: Vector2i = Vector2i(door_x, door_y) + dig_direction.vector
		while map.is_in_bounds_p(dig_pos) && !map.get_tile_at_p(dig_pos).model.is_walkable:
			# corridor.
			map.set_tile_model_at(dig_pos.x, dig_pos.y, game.game_tiles.floor_concrete())
			# continue digging.
			dig_pos += dig_direction.vector

	####################
	# Furniture & Items.
	####################
	# bunch of tables near walls with construction items on them.
	var nb_tables: int = _dice_roller.roll(maxi(b.inside_rect.size.x, b.inside_rect.size.y), 2 * maxi(b.inside_rect.size.x, b.inside_rect.size.y))
	for i in nb_tables:
		var table_walls_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) >= 3 && count_adj_doors(map, pt.x, pt.y) == 0
		var maintenance_table_fn := func(pt):
			# add item.
			map.drop_item_at(make_shop_construction_item(), pt)

			# add table.
			return make_obj_table(GameImages.OBJ_TABLE)
		map_object_place_in_good_position_rect(map, b.inside_rect, table_walls_fn, _dice_roller, maintenance_table_fn)
	# a bed and a fridge with food if lucky.
	if _dice_roller.roll_chance(33):
		var furniture_walls_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) >= 3 && count_adj_doors(map, pt.x, pt.y) == 0
		# bed.
		var bed_fn := func(_pt): return make_obj_bed(GameImages.OBJ_BED)
		map_object_place_in_good_position_rect(map, b.inside_rect, furniture_walls_fn, _dice_roller, bed_fn)

		# fridge + food.
		var fridge_fn := func(pt):
			# add food.
			map.drop_item_at(make_item_canned_food(), pt)

			# add fridge.
			return make_obj_fridge(GameImages.OBJ_FRIDGE)
		map_object_place_in_good_position_rect(map, b.inside_rect, furniture_walls_fn, _dice_roller, fridge_fn)

	##################################
	# Add the poor maintenance guy/gal.
	##################################
	var poor_guy: Actor = create_new_civilian(0, 3, 1)
	actor_place_in(_dice_roller, b.rectangle.size.x * b.rectangle.size.y, map, poor_guy, b.inside_rect.position.x, b.inside_rect.position.y, b.inside_rect.size.x, b.inside_rect.size.y)

	#############
	# Make zone.
	#############
	map.add_zone(make_unique_zone(RogueGame.NAME_SEWERS_MAINTENANCE, b.building_rect))

	# Done...


func make_subway_station_building(map: Map, is_surface: bool, b: Block, linked_map: Map, exit_position: Vector2i) -> void:
	###############
	# Outer walls.
	###############
	# if sewers dig room.
	if !is_surface:
		tile_fill_rect(map, game.game_tiles.floor_concrete(), b.inside_rect)
	# outer walls.
	tile_rectangle(map, game.game_tiles.wall_subway(), b.building_rect.position.x, b.building_rect.position.y, b.building_rect.size.x, b.building_rect.size.y)
	# make sure its marked as inside (in case we replace a park for instance)
	for x in range(b.inside_rect.position.x, b.inside_rect.end.x):
		for y in range(b.inside_rect.position.y, b.inside_rect.end.y):
			map.get_tile_at(x, y).is_inside = true

	###########
	# Entrance
	###########
	# pick door/corridor side and put tags.
	# if not surface, we must dig toward the rails.
	var entry_fence_x: int
	var entry_fence_y: int
	var dig_direction: Direction
	var side_roll: int
	if is_surface:
		side_roll = _dice_roller.roll(0, 4)
	else:
		side_roll = 1 if b.rectangle.end.y < map.width / 2 else 0
	match side_roll:
		0:  # north.
			dig_direction = Direction.N
			entry_fence_x = b.building_rect.position.x + b.building_rect.size.x / 2
			entry_fence_y = b.building_rect.position.y

			if is_surface:
				_safe_add_decoration(map, entry_fence_x - 1, entry_fence_y, GameImages.DECO_SUBWAY_BUILDING)
				_safe_add_decoration(map, entry_fence_x + 1, entry_fence_y, GameImages.DECO_SUBWAY_BUILDING)

		1:  # south.
			dig_direction = Direction.S
			entry_fence_x = b.building_rect.position.x + b.building_rect.size.x / 2
			entry_fence_y = b.building_rect.end.y - 1

			if is_surface:
				_safe_add_decoration(map, entry_fence_x - 1, entry_fence_y, GameImages.DECO_SUBWAY_BUILDING)
				_safe_add_decoration(map, entry_fence_x + 1, entry_fence_y, GameImages.DECO_SUBWAY_BUILDING)

		2:  # west.
			dig_direction = Direction.W
			entry_fence_x = b.building_rect.position.x
			entry_fence_y = b.building_rect.position.y + b.building_rect.size.y / 2

			if is_surface:
				_safe_add_decoration(map, entry_fence_x, entry_fence_y - 1, GameImages.DECO_SUBWAY_BUILDING)
				_safe_add_decoration(map, entry_fence_x, entry_fence_y + 1, GameImages.DECO_SUBWAY_BUILDING)

		3:  # east.
			dig_direction = Direction.E
			entry_fence_x = b.building_rect.end.x - 1
			entry_fence_y = b.building_rect.position.y + b.building_rect.size.y / 2

			if is_surface:
				_safe_add_decoration(map, entry_fence_x, entry_fence_y - 1, GameImages.DECO_SUBWAY_BUILDING)
				_safe_add_decoration(map, entry_fence_x, entry_fence_y + 1, GameImages.DECO_SUBWAY_BUILDING)

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
	# add door if surface.
	if is_surface:
		map.set_tile_model_at(entry_fence_x, entry_fence_y, game.game_tiles.floor_concrete())
		map.place_map_object_at(make_obj_glass_door(), Vector2i(entry_fence_x, entry_fence_y))

	##############################
	# Stairs to the other map.
	##############################
	# add exits.
	for ex in range(exit_position.x - 1, exit_position.x + 2):
		var this_exit_pos := Vector2i(ex, exit_position.y)
		_safe_add_decoration(map, this_exit_pos.x, this_exit_pos.y, GameImages.DECO_STAIRS_DOWN if is_surface else GameImages.DECO_STAIRS_UP)
		var exit := Map.Exit.new(linked_map, this_exit_pos)
		exit.is_an_ai_exit = true
		map.set_exit_at(this_exit_pos, exit)

	###################################################
	# If subway :
	# - dig corridor until we reach the rails.
	# - dig platform and make corridor zone.
	# - add closed iron fences between corridor and platform.
	# - make power room.
	###################################################
	if !is_surface:
		# - dig corridor until we reach the rails.
		map.set_tile_model_at(entry_fence_x, entry_fence_y, game.game_tiles.floor_concrete())
		map.set_tile_model_at(entry_fence_x + 1, entry_fence_y, game.game_tiles.floor_concrete())
		map.set_tile_model_at(entry_fence_x - 1, entry_fence_y, game.game_tiles.floor_concrete())
		map.set_tile_model_at(entry_fence_x - 2, entry_fence_y, game.game_tiles.wall_stone())
		map.set_tile_model_at(entry_fence_x + 2, entry_fence_y, game.game_tiles.wall_stone())

		var dig_pos: Vector2i = Vector2i(entry_fence_x, entry_fence_y) + dig_direction.vector
		while map.is_in_bounds_p(dig_pos) && !map.get_tile_at_p(dig_pos).model.is_walkable:
			# corridor.
			map.set_tile_model_at(dig_pos.x, dig_pos.y, game.game_tiles.floor_concrete())
			map.set_tile_model_at(dig_pos.x - 1, dig_pos.y, game.game_tiles.floor_concrete())
			map.set_tile_model_at(dig_pos.x + 1, dig_pos.y, game.game_tiles.floor_concrete())
			map.set_tile_model_at(dig_pos.x - 2, dig_pos.y, game.game_tiles.wall_stone())
			map.set_tile_model_at(dig_pos.x + 2, dig_pos.y, game.game_tiles.wall_stone())

			# continue digging.
			dig_pos += dig_direction.vector

		# - dig platform and make corridor zone.
		const platform_extend: int = 10
		const platform_width: int = 3
		var platform_rect: Rect2i
		var platform_left: int = max(0, b.building_rect.position.x - platform_extend)
		var platform_right: int = min(map.width - 1, b.building_rect.end.x + platform_extend)
		var benches_line: int
		if dig_direction == Direction.S:
			platform_rect = Rect2i(platform_left, dig_pos.y - platform_width, platform_right - platform_left, platform_width)
			benches_line = platform_rect.position.y
			map.add_zone(make_unique_zone("corridor", Rect2i(entry_fence_x - 1, entry_fence_y, entry_fence_x + 2 - (entry_fence_x - 1), platform_rect.position.y - entry_fence_y)))
		else:
			platform_rect = Rect2i(platform_left, dig_pos.y + 1, platform_right - platform_left, platform_width)
			benches_line = platform_rect.end.y - 1
			map.add_zone(make_unique_zone("corridor", Rect2i(entry_fence_x - 1, platform_rect.end.y, entry_fence_x + 2 - (entry_fence_x - 1), entry_fence_y + 1 - platform_rect.end.y)))
		tile_fill_rect(map, game.game_tiles.floor_concrete(), platform_rect)

		# - iron benches in platform.
		for bx in range(platform_rect.position.x, platform_rect.end.x):
			if count_adj_walls_xy(map, bx, benches_line) < 3:
				continue
			map.place_map_object_at(make_obj_iron_bench(GameImages.OBJ_IRON_BENCH), Vector2i(bx, benches_line))

		# - platform zone.
		map.add_zone(make_unique_zone("platform", platform_rect))

		# - add closed iron gates between corridor and platform.
		var iron_fence_pos: Vector2i
		if dig_direction == Direction.S:
			iron_fence_pos = Vector2i(entry_fence_x, platform_rect.position.y - 1)
		else:
			iron_fence_pos = Vector2i(entry_fence_x, platform_rect.end.y)
		map.place_map_object_at(make_obj_iron_gate(GameImages.OBJ_GATE_CLOSED), iron_fence_pos)
		map.place_map_object_at(make_obj_iron_gate(GameImages.OBJ_GATE_CLOSED), Vector2i(iron_fence_pos.x + 1, iron_fence_pos.y))
		map.place_map_object_at(make_obj_iron_gate(GameImages.OBJ_GATE_CLOSED), Vector2i(iron_fence_pos.x - 1, iron_fence_pos.y))

		# - make power room.
		# access in the corridor, going toward the center of the map.
		var power_room_entry: Vector2i
		var power_room_rect: Rect2i
		const power_room_width: int = 4
		const power_room_half_height: int = 2
		if entry_fence_x > map.width / 2:
			# west.
			power_room_entry = Vector2i(entry_fence_x - 2, entry_fence_y + power_room_half_height * dig_direction.vector.y)
			power_room_rect = Rect2i(power_room_entry.x - power_room_width, power_room_entry.y - power_room_half_height, power_room_width + 1, 2 * power_room_half_height + 1)
		else:
			# east.
			power_room_entry = Vector2i(entry_fence_x + 2, entry_fence_y + power_room_half_height * dig_direction.vector.y)
			power_room_rect = Rect2i(power_room_entry.x, power_room_entry.y - power_room_half_height, power_room_width, 2 * power_room_half_height + 1)

		# carve power room.
		tile_fill_rect(map, game.game_tiles.floor_concrete(), power_room_rect)
		tile_rectangle(map, game.game_tiles.wall_stone(), power_room_rect.position.x, power_room_rect.position.y, power_room_rect.size.x, power_room_rect.size.y)

		# add door with signs.
		place_door(map, power_room_entry.x, power_room_entry.y, game.game_tiles.floor_concrete(), make_obj_iron_door())
		_safe_add_decoration(map, power_room_entry.x, power_room_entry.y - 1, GameImages.DECO_POWER_SIGN_BIG)
		_safe_add_decoration(map, power_room_entry.x, power_room_entry.y + 1, GameImages.DECO_POWER_SIGN_BIG)

		# add power generators along wall.
		var powergen_fn := func(pt):
			if !map.get_tile_at_p(pt).model.is_walkable:
				return null
			if count_adj_walls_xy(map, pt.x, pt.y) < 3 || count_adj_doors(map, pt.x, pt.y) > 0:
				return null
			return make_obj_power_generator(GameImages.OBJ_POWERGEN_OFF, GameImages.OBJ_POWERGEN_ON)
		map_object_fill_rect(map, power_room_rect, powergen_fn)

	####################
	# Furniture & Items.
	####################
	# iron benches in station.
	for bx in range(b.inside_rect.position.x, b.inside_rect.end.x):
		for by in range(b.inside_rect.position.y + 1, b.inside_rect.end.y - 1):
			# next to walls and no doors.
			if count_adj_walls_xy(map, bx, by) < 2 || count_adj_doors(map, bx, by) > 0:
				continue

			# not next to stairs.
			if game.rules.grid_distance_points(Vector2i(bx, by), Vector2i(entry_fence_x, entry_fence_y)) < 2:
				continue

			# bench.
			map.place_map_object_at(make_obj_iron_bench(GameImages.OBJ_IRON_BENCH), Vector2i(bx, by))

	#####################################
	# Add subway police guy on surface.
	#####################################
	if is_surface:
		var police_man: Actor = create_new_policeman(0)
		actor_place_in(_dice_roller, b.rectangle.size.x * b.rectangle.size.y, map, police_man, b.inside_rect.position.x, b.inside_rect.position.y, b.inside_rect.size.x, b.inside_rect.size.y)

	#############
	# Make zone.
	#############
	map.add_zone(make_unique_zone(RogueGame.NAME_SUBWAY_STATION, b.building_rect))


# region Rooms
# alpha10.1 allow different x and y min size
func make_rooms_plan(map: Map, list: Array, rect: Rect2i, min_rooms_x_size: int, min_rooms_y_size: int) -> void:
	############
	# 1. Split
	############
	# +N to account for the road ring.
	var quads := quad_split(rect, min_rooms_x_size, min_rooms_y_size)
	var _split_x: int = quads.split_x
	var _split_y: int = quads.split_y
	var top_left: Rect2i = quads.top_left
	var top_right: Rect2i = quads.top_right
	var bottom_left: Rect2i = quads.bottom_left
	var bottom_right: Rect2i = quads.bottom_right

	####################
	# 2. Termination?
	####################
	if _rect_is_empty(top_right) && _rect_is_empty(bottom_left) && _rect_is_empty(bottom_right):
		list.append(rect)
		return

	#############
	# 3. Recurse
	#############
	# always top left.
	make_rooms_plan(map, list, top_left, min_rooms_x_size, min_rooms_y_size)
	# then recurse in non empty quads.
	# we shift and inflante the quads cause we want rooms walls and doors to overlap.
	if !_rect_is_empty(top_right):
		top_right.position += Vector2i(-1, 0)
		top_right.size.x += 1
		make_rooms_plan(map, list, top_right, min_rooms_x_size, min_rooms_y_size)
	if !_rect_is_empty(bottom_left):
		bottom_left.position += Vector2i(0, -1)
		bottom_left.size.y += 1
		make_rooms_plan(map, list, bottom_left, min_rooms_x_size, min_rooms_y_size)
	if !_rect_is_empty(bottom_right):
		bottom_right.position += Vector2i(-1, -1)
		bottom_right.size.x += 1
		bottom_right.size.y += 1
		make_rooms_plan(map, list, bottom_right, min_rooms_x_size, min_rooms_y_size)


func make_housing_room(map: Map, room_rect: Rect2i, floor_model: TileModel, wall_model: TileModel) -> void:
	###################
	# 1. Floor & Walls
	###################
	tile_fill_rect(map, floor_model, room_rect)
	var keep_doors_fn := func(_tile, _prevmodel, x, y):
		# if we have a door there, don't put a wall!
		if map.get_map_object_at_xy(x, y) != null:
			map.set_tile_model_at(x, y, floor_model)
	tile_rectangle(map, wall_model, room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y, keep_doors_fn)

	######################
	# 2. Doors & Windows
	######################
	var mid_x: int = room_rect.position.x + room_rect.size.x / 2
	var mid_y: int = room_rect.position.y + room_rect.size.y / 2
	const outside_door_chance: int = 25

	var door_pos_fn := func(x, y): return has_no_object_at(map, x, y) && is_accessible(map, x, y) && count_adj_doors(map, x, y) == 0
	var door_or_window_fn := func(x, y): return make_obj_wooden_door() if (is_inside(map, x, y) || _dice_roller.roll_chance(outside_door_chance)) else make_obj_window()
	place_if(map, mid_x, room_rect.position.y, floor_model, door_pos_fn, door_or_window_fn)
	place_if(map, mid_x, room_rect.end.y - 1, floor_model, door_pos_fn, door_or_window_fn)
	place_if(map, room_rect.position.x, mid_y, floor_model, door_pos_fn, door_or_window_fn)
	place_if(map, room_rect.end.x - 1, mid_y, floor_model, door_pos_fn, door_or_window_fn)


# alpha10.1 can force room role (optional param)
# FIXME -- room role should be an enum and not hardcoded numbers -_-
## role : -1 roll at random; 0-4 bedroom, 5-7 living room, 8-9 kitchen
func fill_housing_room_contents(map: Map, room_rect: Rect2i, role: int = -1) -> void:
	var inside_room := Rect2i(room_rect.position.x + 1, room_rect.position.y + 1, room_rect.size.x - 2, room_rect.size.y - 2)

	# alpha10.1 roll room role if not set
	if role == -1:
		role = _dice_roller.roll(0, 10)

	# alpha10.1 added restriction to not place a mapobj if adj to at least 5 mapobj as to not cramp apartements

	match role:
		# 1. Bedroom? 0-4 = 50%
		0, 1, 2, 3, 4:
			# beds with night tables.
			var nb_beds: int = _dice_roller.roll(1, 3)
			for i in nb_beds:
				var bed_walls_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) >= 3 && count_adj_doors(map, pt.x, pt.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped
				var bed_fn := func(pt):
					# one night table around with item.
					var adj_bed_rect := Rect2i(pt.x - 1, pt.y - 1, 3, 3)
					adj_bed_rect = adj_bed_rect.intersection(inside_room)
					var night_table_pos_fn := func(pt2): return pt2 != pt && count_adj_doors(map, pt2.x, pt2.y) == 0 && count_adj_walls_xy(map, pt2.x, pt2.y) > 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
					var night_table_fn := func(pt2):
						# item.
						var it: Item = make_random_bedroom_item()
						if it != null:
							map.drop_item_at(it, pt2)

						# night table.
						return make_obj_night_table(GameImages.OBJ_NIGHT_TABLE)
					map_object_place_in_good_position_rect(map, adj_bed_rect, night_table_pos_fn, _dice_roller, night_table_fn)

					# bed.
					var bed: MapObject = make_obj_bed(GameImages.OBJ_BED)
					return bed
				map_object_place_in_good_position_rect(map, inside_room, bed_walls_fn, _dice_roller, bed_fn)

			# wardrobe/drawer with items
			var nb_wardrobe_or_drawer: int = _dice_roller.roll(1, 4)
			for i in nb_wardrobe_or_drawer:
				var wardrobe_walls_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) >= 2 && count_adj_doors(map, pt.x, pt.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
				var wardrobe_fn := func(pt):
					# item.
					var it: Item = make_random_bedroom_item()
					if it != null:
						map.drop_item_at(it, pt)

					# wardrobe or drawer
					if _dice_roller.roll_chance(50):
						return make_obj_wardrobe(GameImages.OBJ_WARDROBE)
					else:
						return make_obj_drawer(GameImages.OBJ_DRAWER)
				map_object_place_in_good_position_rect(map, inside_room, wardrobe_walls_fn, _dice_roller, wardrobe_fn)

		# 2. Living room? 5-6-7 = 30%
		5, 6, 7:
			# tables with chairs.
			var nb_tables: int = _dice_roller.roll(1, 3)

			for i in nb_tables:
				var table_open_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) == 0 && count_adj_doors(map, pt.x, pt.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
				var living_table_fn := func(pt):
					# items.
					for ii in HOUSE_LIVINGROOM_ITEMS_ON_TABLE:
						var it: Item = make_random_kitchen_item()
						if it != null:
							map.drop_item_at(it, pt)

					# one chair around.
					var adj_table_rect := Rect2i(pt.x - 1, pt.y - 1, 3, 3)
					adj_table_rect = adj_table_rect.intersection(inside_room)
					var chair_pos_fn := func(pt2): return pt2 != pt && count_adj_doors(map, pt2.x, pt2.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
					var chair_fn := func(_pt2): return make_obj_chair(GameImages.OBJ_CHAIR)
					map_object_place_in_good_position_rect(map, adj_table_rect, chair_pos_fn, _dice_roller, chair_fn)

					# table.
					var table: MapObject = make_obj_table(GameImages.OBJ_TABLE)
					return table
				map_object_place_in_good_position_rect(map, inside_room, table_open_fn, _dice_roller, living_table_fn)

			# drawers.
			var nb_drawers: int = _dice_roller.roll(1, 3)
			for i in nb_drawers:
				var drawer_walls_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) >= 2 && count_adj_doors(map, pt.x, pt.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
				var drawer_fn := func(_pt): return make_obj_drawer(GameImages.OBJ_DRAWER)
				map_object_place_in_good_position_rect(map, inside_room, drawer_walls_fn, _dice_roller, drawer_fn)

		# 3. Kitchen? 8-9 = 20%
		8, 9:
			# table with item & chair.
			var kitchen_table_open_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) == 0 && count_adj_doors(map, pt.x, pt.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
			var kitchen_table_fn := func(pt):
				# items.
				for ii in HOUSE_KITCHEN_ITEMS_ON_TABLE:
					var it: Item = make_random_kitchen_item()
					if it != null:
						map.drop_item_at(it, pt)

				# one chair around.
				var adj_table_rect := Rect2i(pt.x - 1, pt.y - 1, 3, 3)
				var kitchen_chair_pos_fn := func(pt2): return pt2 != pt && count_adj_doors(map, pt2.x, pt2.y) == 0
				var kitchen_chair_fn := func(_pt2): return make_obj_chair(GameImages.OBJ_CHAIR)
				map_object_place_in_good_position_rect(map, adj_table_rect, kitchen_chair_pos_fn, _dice_roller, kitchen_chair_fn)

				# table.
				return make_obj_table(GameImages.OBJ_TABLE)
			map_object_place_in_good_position_rect(map, inside_room, kitchen_table_open_fn, _dice_roller, kitchen_table_fn)

			# fridge with items
			var fridge_walls_fn := func(pt): return count_adj_walls_xy(map, pt.x, pt.y) >= 2 && count_adj_doors(map, pt.x, pt.y) == 0 && count_adj_map_objects(map, pt.x, pt.y) < 5  # alpha10.1 not cramped,
			var kitchen_fridge_fn := func(pt):
				# items.
				for ii in HOUSE_KITCHEN_ITEMS_IN_FRIDGE:
					var it: Item = make_random_kitchen_item()
					if it != null:
						map.drop_item_at(it, pt)

				# fridge
				return make_obj_fridge(GameImages.OBJ_FRIDGE)
			map_object_place_in_good_position_rect(map, inside_room, fridge_walls_fn, _dice_roller, kitchen_fridge_fn)

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")


# endregion

# region Items
func make_random_shop_item(shop: ShopType) -> Item:
	match shop:
		ShopType.CONSTRUCTION:
			return make_shop_construction_item()
		ShopType.GENERAL_STORE:
			return make_shop_general_item()
		ShopType.GROCERY:
			return make_shop_grocery_item()
		ShopType.GUNSHOP:
			return make_shop_gunshop_item()
		ShopType.PHARMACY:
			return make_shop_pharmacy_item()
		ShopType.SPORTSWEAR:
			return make_shop_sports_wear_item()
		ShopType.HUNTING:
			return make_hunting_shop_item()
		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled shoptype")
			return null


func make_shop_grocery_item() -> Item:
	if _dice_roller.roll_chance(50):
		return make_item_canned_food()
	else:
		return make_item_groceries()


func make_shop_pharmacy_item() -> Item:
	var random_item: int = _dice_roller.roll(0, 6)
	match random_item:
		0:
			return make_item_bandages()
		1:
			return make_item_medikit()
		2:
			return make_item_pills_slp()
		3:
			return make_item_pills_sta()
		4:
			return make_item_pills_san()
		5:
			return make_item_stench_killer()

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
			return null


func make_shop_sports_wear_item() -> Item:
	var roll: int = _dice_roller.roll(0, 10)

	match roll:
		0:
			if _dice_roller.roll_chance(30):
				return make_item_hunting_rifle()
			else:
				return make_item_light_rifle_ammo()
		1:
			if _dice_roller.roll_chance(30):
				return make_item_hunting_crossbow()
			else:
				return make_item_bolts_ammo()
		2, 3, 4, 5:
			return make_item_baseball_bat()  # 40%

		6, 7:
			return make_item_iron_golf_club()  # 20%

		8, 9:
			return make_item_golf_club()  # 20%
		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
			return null


func make_shop_construction_item() -> Item:
	var roll: int = _dice_roller.roll(0, 24)
	match roll:
		0, 1, 2:
			return make_item_shovel() if _dice_roller.roll_chance(50) else make_item_short_shovel()

		3, 4, 5:
			return make_item_crowbar()

		6, 7, 8:
			return make_item_huge_hammer() if _dice_roller.roll_chance(50) else make_item_small_hammer()

		9, 10, 11:
			return make_item_wooden_plank()

		12, 13, 14:
			return make_item_flashlight()

		15, 16, 17:
			return make_item_big_flashlight()

		18, 19, 20:
			return make_item_spikes()

		21, 22, 23:
			return make_item_barbed_wire()

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
			return null


func make_shop_gunshop_item() -> Item:
	# Weapons (40%) vs Ammo (60%)
	if _dice_roller.roll_chance(40):
		var roll: int = _dice_roller.roll(0, 4)

		match roll:
			0:
				return make_item_random_pistol()
			1:
				return make_item_shotgun()
			2:
				return make_item_hunting_rifle()
			3:
				return make_item_hunting_crossbow()

			_:
				return null
	else:
		var roll: int = _dice_roller.roll(0, 4)

		match roll:
			0:
				return make_item_light_pistol_ammo()
			1:
				return make_item_shotgun_ammo()
			2:
				return make_item_light_rifle_ammo()
			3:
				return make_item_bolts_ammo()

			_:
				return null


func make_hunting_shop_item() -> Item:
	# Weapons/Ammo (50%) Outfits&Traps (50%)
	if _dice_roller.roll_chance(50):
		# Weapons(40) Ammo(60)
		if _dice_roller.roll_chance(40):
			var roll: int = _dice_roller.roll(0, 2)

			match roll:
				0:
					return make_item_hunting_rifle()
				1:
					return make_item_hunting_crossbow()
				_:
					return null
		else:
			var roll: int = _dice_roller.roll(0, 2)

			match roll:
				0:
					return make_item_light_rifle_ammo()
				1:
					return make_item_bolts_ammo()
				_:
					return null
	else:
		# Outfits&Traps
		var roll: int = _dice_roller.roll(0, 2)
		match roll:
			0:
				return make_item_hunter_vest()
			1:
				return make_item_bear_trap()
			_:
				return null


func make_shop_general_item() -> Item:
	var roll: int = _dice_roller.roll(0, 6)
	match roll:
		0:
			return make_shop_pharmacy_item()
		1:
			return make_shop_sports_wear_item()
		2:
			return make_shop_construction_item()
		3:
			return make_shop_grocery_item()
		4:
			return make_hunting_shop_item()
		5:
			return make_random_bedroom_item()
		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
			return null


func make_hospital_item() -> Item:
	var random_item: int = _dice_roller.roll(0, 7)
	match random_item:
		0:
			return make_item_bandages()
		1:
			return make_item_medikit()
		2:
			return make_item_pills_slp()
		3:
			return make_item_pills_sta()
		4:
			return make_item_pills_san()
		5:
			return make_item_stench_killer()
		6:
			return make_item_pills_antiviral()

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
			return null


func make_random_bedroom_item() -> Item:
	var random_item: int = _dice_roller.roll(0, 24)

	match random_item:
		0, 1:
			return make_item_bandages()
		2:
			return make_item_pills_sta()
		3:
			return make_item_pills_slp()
		4:
			return make_item_pills_san()

		5, 6, 7, 8:
			return make_item_baseball_bat()

		9:
			return make_item_random_pistol()

		10:  # rare fire weapon
			if _dice_roller.roll_chance(30):
				if _dice_roller.roll_chance(50):
					return make_item_shotgun()
				else:
					return make_item_hunting_rifle()
			else:
				if _dice_roller.roll_chance(50):
					return make_item_shotgun_ammo()
				else:
					return make_item_light_rifle_ammo()
		11, 12, 13:
			return make_item_cell_phone()

		14, 15:
			return make_item_flashlight()

		16, 17:
			return make_item_light_pistol_ammo()

		18, 19:
			return make_item_stench_killer()

		20:
			return make_item_hunter_vest()

		21, 22, 23:
			if _dice_roller.roll_chance(50):
				return make_item_book()
			else:
				return make_item_magazines()

		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled roll")
			return null


func make_random_kitchen_item() -> Item:
	if _dice_roller.roll_chance(50):
		return make_item_canned_food()
	else:
		return make_item_groceries()


func make_random_char_office_item() -> Item:
	var random_item: int = _dice_roller.roll(0, 10)
	match random_item:
		0:
			# weapons:
			# - grenade (rare).
			# - shotgun/ammo
			if _dice_roller.roll_chance(10):
				# grenade!
				return make_item_grenade()
			else:
				# shotgun/ammo
				if _dice_roller.roll_chance(30):
					return make_item_shotgun()
				else:
					return make_item_shotgun_ammo()

		1, 2:
			if _dice_roller.roll_chance(50):
				return make_item_bandages()
			else:
				return make_item_medikit()

		3:
			return make_item_canned_food()

		4:  # rare tracker items
			if _dice_roller.roll_chance(50):
				if _dice_roller.roll_chance(50):
					return make_item_ztracker()
				else:
					return make_item_blackops_gps()
			else:
				return null

		_:
			return null  # 50% chance to find nothing.


func make_random_park_item() -> Item:
	var random_item: int = _dice_roller.roll(0, 8)
	match random_item:
		0:
			return make_item_spray_paint()
		1:
			return make_item_baseball_bat()
		2:
			return make_item_pills_slp()
		3:
			return make_item_pills_sta()
		4:
			return make_item_pills_san()
		5:
			return make_item_flashlight()
		6:
			return make_item_cell_phone()
		7:
			return make_item_wooden_plank()
		_:
			# C# threw ArgumentOutOfRangeException.
			push_error("BaseTownGenerator : unhandled item roll")
			return null


# endregion

# region Decorations

static var POSTERS: Array = [GameImages.DECO_POSTERS1, GameImages.DECO_POSTERS2]


func decorate_outside_walls_with_posters(map: Map, rect: Rect2i, chance_per_wall: int) -> void:
	var poster_fn := func(_x, _y):
		if _dice_roller.roll_chance(chance_per_wall):
			return POSTERS[_dice_roller.roll(0, POSTERS.size())]
		else:
			return null
	decorate_outside_walls(map, rect, poster_fn)


static var TAGS: Array = [GameImages.DECO_TAGS1, GameImages.DECO_TAGS2, GameImages.DECO_TAGS3, GameImages.DECO_TAGS4, GameImages.DECO_TAGS5, GameImages.DECO_TAGS6, GameImages.DECO_TAGS7]


func decorate_outside_walls_with_tags(map: Map, rect: Rect2i, chance_per_wall: int) -> void:
	var tag_fn := func(_x, _y):
		if _dice_roller.roll_chance(chance_per_wall):
			return TAGS[_dice_roller.roll(0, TAGS.size())]
		else:
			return null
	decorate_outside_walls(map, rect, tag_fn)

# endregion

# region Populating buildings

func populate_char_office_building(map: Map, b: Block) -> void:
	##########
	# Guards
	##########
	for i in MAX_CHAR_GUARDS_PER_OFFICE:
		var new_guard: Actor = create_new_char_guard(0)
		actor_place_in(_dice_roller, 100, map, new_guard, b.inside_rect.position.x, b.inside_rect.position.y, b.inside_rect.size.x, b.inside_rect.size.y)


# endregion

# region Special Locations

# region House Basement
func generate_house_basement_map(map: Map, house_block: Block) -> Map:
	# make map.
	var rect: Rect2i = house_block.building_rect
	# NOTE: C# `map.Seed << 1 + rect.Left * map.Height + rect.Top` parses as
	# `map.Seed << (1 + rect.Left * map.Height + rect.Top)` (shift has lower
	# precedence than + in C#); GDScript has the same precedence, kept as-is.
	var _seed: int = map.seed << 1 + rect.position.x * map.height + rect.position.y
	var basement := Map.new(_seed, "basement%d%d@%d-%d" % [_params.district.world_position.x, _params.district.world_position.y, rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y / 2], rect.size.x, rect.size.y)
	basement.lighting = Map.Lighting.DARKNESS
	basement.add_zone(make_unique_zone("basement", basement.rect))

	# enclose.
	var inside_fn := func(tile, _model, _x, _y): tile.is_inside = true
	tile_fill_all(basement, game.game_tiles.floor_concrete(), inside_fn)
	tile_rectangle(basement, game.game_tiles.wall_brick(), 0, 0, basement.width, basement.height)

	# link to house with stairs.
	var surface_stairs := Vector2i.ZERO
	var stairs_tries: int = 0
	while stairs_tries < 200:
		stairs_tries += 1
		# roll.
		surface_stairs.x = _dice_roller.roll(rect.position.x, rect.end.x)
		surface_stairs.y = _dice_roller.roll(rect.position.y, rect.end.y)

		# valid if walkable & no blocking object.
		# alpha10 and inside
		if !map.get_tile_at_p(surface_stairs).model.is_walkable:
			continue
		if map.get_map_object_at(surface_stairs) != null:
			continue
		if !map.get_tile_at_p(surface_stairs).is_inside:
			continue

		# good post.
		break
	var basement_stairs := Vector2i(surface_stairs.x - rect.position.x, surface_stairs.y - rect.position.y)
	add_exit(map, surface_stairs, basement, basement_stairs, GameImages.DECO_STAIRS_DOWN, true)
	add_exit(basement, basement_stairs, map, surface_stairs, GameImages.DECO_STAIRS_UP, true)

	# random pilars/walls.
	var pilar_fn := func(pt):
		if !_dice_roller.roll_chance(HOUSE_BASEMENT_PILAR_CHANCE):
			return
		if pt == basement_stairs:
			return
		basement.set_tile_model_at(pt.x, pt.y, game.game_tiles.wall_brick())
	do_for_each_tile(basement, basement.rect, pilar_fn)

	# fill with ome furniture/crap and items.
	var basement_obj_fn := func(pt):
		if !_dice_roller.roll_chance(HOUSE_BASEMENT_OBJECT_CHANCE_PER_TILE):
			return null

		if basement.get_exit_at(pt) != null:
			return null
		if !basement.is_walkable(pt.x, pt.y):
			return null

		var roll: int = _dice_roller.roll(0, 5)
		match roll:
			0:  # junk
				return make_obj_junk(GameImages.OBJ_JUNK)
			1:  # barrels.
				return make_obj_barrels(GameImages.OBJ_BARRELS)
			2:  # table with random item.
				var it: Item = make_shop_construction_item()
				basement.drop_item_at(it, pt)
				return make_obj_table(GameImages.OBJ_TABLE)
			3:  # drawer with random item.
				var it: Item = make_shop_construction_item()
				basement.drop_item_at(it, pt)
				return make_obj_drawer(GameImages.OBJ_DRAWER)
			4:  # bed.
				return make_obj_bed(GameImages.OBJ_BED)

			_:
				# C# threw ArgumentOutOfRangeException.
				push_error("BaseTownGenerator : unhandled roll")
				return null
	map_object_fill_rect(basement, basement.rect, basement_obj_fn)

	# rats!
	if Rules.has_zombies_in_basements(game.session.game_mode):
		var rat_fn := func(pt):
			if !basement.is_walkable(pt.x, pt.y):
				return

			if basement.get_exit_at(pt) != null:
				return

			if _dice_roller.roll_chance(SHOP_BASEMENT_ZOMBIE_RAT_CHANCE):
				basement.place_actor_at(create_new_basement_rat_zombie(0), pt)
		do_for_each_tile(basement, basement.rect, rat_fn)

	# weapons cache?
	if _dice_roller.roll_chance(HOUSE_BASEMENT_WEAPONS_CACHE_CHANCE):
		var cache_pos_fn := func(pt):
			if basement.get_exit_at(pt) != null:
				return false
			if !basement.is_walkable(pt.x, pt.y):
				return false
			if basement.get_map_object_at(pt) != null:
				return false
			if basement.get_items_at(pt) != null:
				return false
			return true
		var cache_fn := func(pt):
			# two grenades...
			basement.drop_item_at(make_item_grenade(), pt)
			basement.drop_item_at(make_item_grenade(), pt)

			# and a handfull of gunshop items.
			for i in 5:
				var it: Item = make_shop_gunshop_item()
				basement.drop_item_at(it, pt)

			# shelf.
			var shelf: MapObject = make_obj_shelf(GameImages.OBJ_SHOP_SHELF)
			return shelf
		map_object_place_in_good_position_rect(basement, basement.rect, cache_pos_fn, _dice_roller, cache_fn)

	# alpha10
	# music.
	basement.bg_music = GameMusics.SEWERS

	# done.
	return basement

# endregion

# region CHAR Underground Facility

# alpha10 added entry pos
## C# used an out parameter for baseEntryPos; returns a Dictionary with keys
## "map" and "base_entry_pos".
func generate_unique_map_char_underground(surface_map: Map, office_zone: Zone) -> Dictionary:
	#########################
	# 1. Create basic secret map.
	# 2. Link to office.
	# 3. Create rooms.
	# 4. Furniture & Items.
	# 5. Posters & Blood.
	# 6. Populate.
	# 7. Add uniques.
	# alpha10
	# 8. Music
	#########################

	# 1. Create basic secret map.
	# huge map.
	var underground := Map.new((surface_map.seed << 3) ^ surface_map.seed, "CHAR Underground Facility", RogueGame.MAP_MAX_WIDTH, RogueGame.MAP_MAX_HEIGHT)
	underground.lighting = Map.Lighting.DARKNESS
	underground.is_secret = true
	# fill & enclose.
	var inside_fn := func(tile, _model, _x, _y): tile.is_inside = true
	tile_fill_all(underground, game.game_tiles.floor_office(), inside_fn)
	tile_rectangle(underground, game.game_tiles.wall_char_office(), 0, 0, underground.width, underground.height)

	# 2. Link to office.
	# find surface point in office:
	# - in a random office room.
	# - set exit somewhere walkable inside.
	# - iron door, barricade the door.
	var room_zone = null  # Zone
	var surface_exit := Vector2i.ZERO
	var outer_tries: int = 0
	while outer_tries < 100:  # loop until found.
		outer_tries += 1
		# find a random room.
		var room_tries: int = 0
		while room_zone == null and room_tries < 200:
			room_tries += 1
			var x: int = _dice_roller.roll(office_zone.bounds.position.x, office_zone.bounds.end.x)
			var y: int = _dice_roller.roll(office_zone.bounds.position.y, office_zone.bounds.end.y)
			var zones_here: Array[Zone] = surface_map.get_zones_at(x, y)
			if zones_here == null || zones_here.is_empty():
				continue
			for z in zones_here:
				if z.name.contains("room"):
					room_zone = z
					break
		if room_zone == null:
			continue

		# find somewhere walkable inside.
		var found_surface_exit := false
		var attempts: int = 0
		while attempts < 100 && !found_surface_exit:
			surface_exit.x = _dice_roller.roll(room_zone.bounds.position.x, room_zone.bounds.end.x)
			surface_exit.y = _dice_roller.roll(room_zone.bounds.position.y, room_zone.bounds.end.y)
			found_surface_exit = surface_map.is_walkable(surface_exit.x, surface_exit.y)
			attempts += 1

		# failed?
		if found_surface_exit == false:
			continue

		# found everything, good!
		break

	# alpha10
	# remember position
	var base_entry_pos: Vector2i = surface_exit

	# barricade the rooms door.
	var barricade_fn := func(pt):
		var door: DoorWindow = surface_map.get_map_object_at(pt) as DoorWindow
		if door == null:
			return
		surface_map.remove_map_object_at(pt.x, pt.y)
		door = make_obj_iron_door()
		door.barricade_points = Rules.BARRICADING_MAX
		surface_map.place_map_object_at(door, pt)
	do_for_each_tile(surface_map, room_zone.bounds, barricade_fn)

	# stairs.
	# underground : in the middle of the map.
	var underground_stairs := Vector2i(underground.width / 2, underground.height / 2)
	underground.set_exit_at(underground_stairs, Map.Exit.new(surface_map, surface_exit))
	underground.get_tile_at_p(underground_stairs).add_decoration(GameImages.DECO_STAIRS_UP)
	surface_map.set_exit_at(surface_exit, Map.Exit.new(underground, underground_stairs))
	surface_map.get_tile_at_p(surface_exit).add_decoration(GameImages.DECO_STAIRS_DOWN)
	# floor logo.
	for_each_adjacent(underground, underground_stairs.x, underground_stairs.y, func(pt): underground.get_tile_at_p(pt).add_decoration(GameImages.DECO_CHAR_FLOOR_LOGO))

	# 3. Create floorplan & rooms.
	# make 4 quarters, splitted by a crossed corridor.
	const corridor_half_width: int = 1
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var q_top_left := Rect2i(0, 0, underground.width / 2 - corridor_half_width, underground.height / 2 - corridor_half_width)
	var q_top_right := Rect2i(underground.width / 2 + 1 + corridor_half_width, 0, underground.width - (underground.width / 2 + 1 + corridor_half_width), q_top_left.end.y)
	var q_bot_left := Rect2i(0, underground.height / 2 + 1 + corridor_half_width, q_top_left.end.x, underground.height - (underground.height / 2 + 1 + corridor_half_width))
	var q_bot_right := Rect2i(q_top_right.position.x, q_bot_left.position.y, underground.width - q_top_right.position.x, underground.height - q_bot_left.position.y)

	# split all the map in rooms.
	const min_room_size: int = 6
	var rooms_list: Array = []
	make_rooms_plan(underground, rooms_list, q_bot_left, min_room_size, min_room_size)
	make_rooms_plan(underground, rooms_list, q_bot_right, min_room_size, min_room_size)
	make_rooms_plan(underground, rooms_list, q_top_left, min_room_size, min_room_size)
	make_rooms_plan(underground, rooms_list, q_top_right, min_room_size, min_room_size)

	# make the rooms walls.
	for room_rect in rooms_list:
		tile_rectangle(underground, game.game_tiles.wall_char_office(), room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y)

	# add room doors.
	# quarters have door side preferences to lead toward the central corridors.
	for room_rect in rooms_list:
		var west_east_door_pos := Vector2i(room_rect.end.x - 1, room_rect.position.y + room_rect.size.y / 2) \
				if room_rect.position.x < underground.width / 2 \
				else Vector2i(room_rect.position.x, room_rect.position.y + room_rect.size.y / 2)
		if underground.get_map_object_at(west_east_door_pos) == null:
			var door: DoorWindow = make_obj_char_door()
			place_door_if_accessible_and_not_adjacent(underground, west_east_door_pos.x, west_east_door_pos.y, game.game_tiles.floor_office(), 6, door)

		var north_south_door_pos := Vector2i(room_rect.position.x + room_rect.size.x / 2, room_rect.end.y - 1) \
				if room_rect.position.y < underground.height / 2 \
				else Vector2i(room_rect.position.x + room_rect.size.x / 2, room_rect.position.y)
		if underground.get_map_object_at(north_south_door_pos) == null:
			var door: DoorWindow = make_obj_char_door()
			place_door_if_accessible_and_not_adjacent(underground, north_south_door_pos.x, north_south_door_pos.y, game.game_tiles.floor_office(), 6, door)

	# add iron doors closing each corridor.
	for x in range(q_top_left.end.x, q_bot_right.position.x):
		place_door(underground, x, q_top_left.end.y - 1, game.game_tiles.floor_office(), make_obj_iron_door())
		place_door(underground, x, q_bot_left.position.y, game.game_tiles.floor_office(), make_obj_iron_door())
	for y in range(q_top_left.end.y, q_bot_left.position.y):
		place_door(underground, q_top_left.end.x - 1, y, game.game_tiles.floor_office(), make_obj_iron_door())
		place_door(underground, q_top_right.position.x, y, game.game_tiles.floor_office(), make_obj_iron_door())

	# 4. Rooms, furniture & items.
	# furniture + items in rooms.
	# room roles with zones:
	# - corners room : Power Room.
	# - top left quarter : armory.
	# - top right quarter : storage.
	# - bottom left quarter : living.
	# - bottom right quarter : pharmacy.
	for room_rect in rooms_list:
		var inside_room_rect := Rect2i(room_rect.position.x + 1, room_rect.position.y + 1, room_rect.size.x - 2, room_rect.size.y - 2)
		var room_name: String = "<noname>"

		# special room?
		# one power room in each corner.
		var is_power_room: bool = (room_rect.position.x == 0 && room_rect.position.y == 0) \
			|| (room_rect.position.x == 0 && room_rect.end.y == underground.height) \
			|| (room_rect.end.x == underground.width && room_rect.position.y == 0) \
			|| (room_rect.end.x == underground.width && room_rect.end.y == underground.height)
		if is_power_room:
			room_name = "Power Room"
			make_char_power_room(underground, room_rect, inside_room_rect)
		else:
			# common room.
			var room_role: int = 0 if (room_rect.position.x < underground.width / 2 && room_rect.position.y < underground.height / 2) \
				else (1 if (room_rect.position.x >= underground.width / 2 && room_rect.position.y < underground.height / 2) \
				else (2 if (room_rect.position.x < underground.width / 2 && room_rect.position.y >= underground.height / 2) \
				else 3))
			match room_role:
				0:  # armory room.
					room_name = "Armory"
					make_char_armory_room(underground, inside_room_rect)
				1:  # storage room.
					room_name = "Storage"
					make_char_storage_room(underground, inside_room_rect)
				2:  # living room.
					room_name = "Living"
					make_char_living_room(underground, inside_room_rect)
				3:  # pharmacy.
					room_name = "Pharmacy"
					make_char_pharmacy_room(underground, inside_room_rect)
				_:
					# C# threw ArgumentOutOfRangeException.
					push_error("BaseTownGenerator : unhandled role")

			underground.add_zone(make_unique_zone(room_name, inside_room_rect))

	# 5. Posters & Blood.
	# char propaganda posters & blood almost everywhere.
	for x in underground.width:
		for y in underground.height:
			# poster on wall?
			if _dice_roller.roll_chance(25):
				var tile: Tile = underground.get_tile_at(x, y)
				if tile.model.is_walkable:
					continue
				tile.add_decoration(CHAR_POSTERS[_dice_roller.roll(0, CHAR_POSTERS.size())])

			# blood?
			if _dice_roller.roll_chance(20):
				var blood_tile: Tile = underground.get_tile_at(x, y)
				if blood_tile.model.is_walkable:
					blood_tile.add_decoration(GameImages.DECO_BLOODIED_FLOOR)
				else:
					blood_tile.add_decoration(GameImages.DECO_BLOODIED_WALL)

	# 6. Populate.
	# don't block exits!
	# leveled up undeads!
	var nb_zombies: int = underground.width  # 100 for 100.
	for i in nb_zombies:
		var undead: Actor = create_new_undead(0)
		while true:
			var up_id: int = game.next_undead_evolution(undead.model_id)
			if up_id == undead.model_id:
				break
			undead.model = game.game_actors.get_model(up_id)
		var not_exit_fn := func(pt): return underground.get_exit_at(pt) == null
		actor_place(_dice_roller, underground.width * underground.height, underground, undead, not_exit_fn)

	# CHAR Guards.
	var nb_guards: int = underground.width / 10  # 10 for 100.
	for i in nb_guards:
		var guard: Actor = create_new_char_guard(0)
		var not_exit_fn2 := func(pt): return underground.get_exit_at(pt) == null
		actor_place(_dice_roller, underground.width * underground.height, underground, guard, not_exit_fn2)

	# 7. Add uniques.
	# TODO...

	# alpha10
	# 8. Music
	underground.bg_music = GameMusics.CHAR_UNDERGROUND_FACILITY

	# done.
	return {"map": underground, "base_entry_pos": base_entry_pos}


func make_char_armory_room(map: Map, room_rect: Rect2i) -> void:
	# Shelves with weapons/ammo along walls.
	var armory_fn := func(pt):
		if count_adj_walls_xy(map, pt.x, pt.y) < 3:
			return null
		# dont block exits!
		if map.get_exit_at(pt) != null:
			return null

		# table + tracker/armor/weapon.
		if _dice_roller.roll_chance(20):
			var it: Item
			if _dice_roller.roll_chance(20):
				it = make_item_char_light_body_armor()
			elif _dice_roller.roll_chance(20):
				it = make_item_ztracker() if _dice_roller.roll_chance(50) else make_item_blackops_gps()
			else:
				# rare grenades.
				if _dice_roller.roll_chance(20):
					it = make_item_grenade()
				else:
					# weapon vs ammo.
					if _dice_roller.roll_chance(30):
						it = make_item_shotgun() if _dice_roller.roll_chance(50) else make_item_hunting_rifle()
					else:
						it = make_item_shotgun_ammo() if _dice_roller.roll_chance(50) else make_item_light_rifle_ammo()
			map.drop_item_at(it, pt)

			var shelf: MapObject = make_obj_shelf(GameImages.OBJ_SHOP_SHELF)
			return shelf
		else:
			return null
	map_object_fill_rect(map, room_rect, armory_fn)


func make_char_storage_room(map: Map, room_rect: Rect2i) -> void:
	# Replace floor with concrete.
	tile_fill_rect(map, game.game_tiles.floor_concrete(), room_rect)

	# Objects.
	# Barrels & Junk in the middle of the room.
	var storage_fn := func(pt):
		if count_adj_walls_xy(map, pt.x, pt.y) > 0:
			return null
		# dont block exits!
		if map.get_exit_at(pt) != null:
			return null

		# barrels/junk?
		if _dice_roller.roll_chance(50):
			return make_obj_junk(GameImages.OBJ_JUNK) if _dice_roller.roll_chance(50) else make_obj_barrels(GameImages.OBJ_BARRELS)
		else:
			return null
	map_object_fill_rect(map, room_rect, storage_fn)

	# Items.
	# Construction items in this mess.
	for x in range(room_rect.position.x, room_rect.end.x):
		for y in range(room_rect.position.y, room_rect.end.y):
			if count_adj_walls_xy(map, x, y) > 0:
				continue
			if map.get_map_object_at_xy(x, y) != null:
				continue

			map.drop_item_at_xy(make_shop_construction_item(), x, y)


func make_char_living_room(map: Map, room_rect: Rect2i) -> void:
	# Replace floor with wood with painted logo.
	var logo_fn := func(tile, _model, _x, _y): tile.add_decoration(GameImages.DECO_CHAR_FLOOR_LOGO)
	tile_fill_rect(map, game.game_tiles.floor_planks(), room_rect, logo_fn)

	# Objects.
	# Beds/Fridges along walls.
	var living_bed_fn := func(pt):
		if count_adj_walls_xy(map, pt.x, pt.y) < 3:
			return null
		# dont block exits!
		if map.get_exit_at(pt) != null:
			return null

		# bed/fridge?
		if _dice_roller.roll_chance(30):
			if _dice_roller.roll_chance(50):
				return make_obj_bed(GameImages.OBJ_BED)
			else:
				return make_obj_fridge(GameImages.OBJ_FRIDGE)
		else:
			return null
	map_object_fill_rect(map, room_rect, living_bed_fn)
	# Tables(with canned food) & Chairs in the middle.
	var living_table_fn := func(pt):
		if count_adj_walls_xy(map, pt.x, pt.y) > 0:
			return null
		# dont block exits!
		if map.get_exit_at(pt) != null:
			return null

		# tables/chairs.
		if _dice_roller.roll_chance(30):
			if _dice_roller.roll_chance(30):
				var table: MapObject = make_obj_table(GameImages.OBJ_CHAR_TABLE)
				map.drop_item_at(make_item_canned_food(), pt)
				return table
			else:
				return make_obj_chair(GameImages.OBJ_CHAR_CHAIR)
		else:
			return null
	map_object_fill_rect(map, room_rect, living_table_fn)


func make_char_pharmacy_room(map: Map, room_rect: Rect2i) -> void:
	# Shelves with medicine along walls.
	var pharmacy_fn := func(pt):
		if count_adj_walls_xy(map, pt.x, pt.y) < 3:
			return null
		# dont block exits!
		if map.get_exit_at(pt) != null:
			return null

		# table + meds.
		if _dice_roller.roll_chance(20):
			var it: Item = make_hospital_item()
			map.drop_item_at(it, pt)

			var shelf: MapObject = make_obj_shelf(GameImages.OBJ_SHOP_SHELF)
			return shelf
		else:
			return null
	map_object_fill_rect(map, room_rect, pharmacy_fn)


func make_char_power_room(map: Map, walls_rect: Rect2i, room_rect: Rect2i) -> void:
	# Replace floor with concrete.
	tile_fill_rect(map, game.game_tiles.floor_concrete(), room_rect)

	# add deco power sign next to doors.
	var power_sign_fn := func(pt):
		if !(map.get_map_object_at(pt) is DoorWindow):
			return
		var sign_fn := func(pt_adj):
			var tile: Tile = map.get_tile_at_p(pt_adj)
			if tile.model.is_walkable:
				return
			tile.remove_all_decorations()
			tile.add_decoration(GameImages.DECO_POWER_SIGN_BIG)
		do_for_each_adjacent_in_map(map, pt, sign_fn)
	do_for_each_tile(map, walls_rect, power_sign_fn)

	# add power generators along walls.
	var powergen_fn := func(pt):
		if !map.get_tile_at_p(pt).model.is_walkable:
			return
		if map.get_exit_at(pt) != null:
			return
		if count_adj_walls_xy(map, pt.x, pt.y) < 3:
			return

		var pow_gen: PowerGenerator = make_obj_power_generator(GameImages.OBJ_POWERGEN_OFF, GameImages.OBJ_POWERGEN_ON)
		map.place_map_object_at(pow_gen, pt)
	do_for_each_tile(map, room_rect, powergen_fn)

# endregion

# region Police Station

## C# MakePoliceStation(map, freeBlocks, out policeBlock) : returns the chosen
## block (or null).
func make_police_station(map: Map, free_blocks: Array) -> Block:
	################################
	# 1. Pick a block.
	# 2. Generate surface station.
	# 3. Generate level -1.
	# 4. Generate level -2.
	# 5. Link maps.
	# 6. Add maps to district.
	# 7. Set unique maps.
	################################

	# 1. Pick a block.
	# any random block will do.
	var police_block: Block = free_blocks[_dice_roller.roll(0, free_blocks.size())]

	# 2. Generate surface station.
	var surface_stairs_pos: Vector2i = generate_police_station(map, police_block)

	# 3. Generate Offices level (-1).
	var offices_level: Map = generate_police_station_offices_level(map, police_block, surface_stairs_pos)

	# 4. Generate Jails level (-2).
	var jails_level: Map = generate_police_station_jails_level(offices_level)

	# alpha10 music
	offices_level.bg_music = GameMusics.SURFACE
	jails_level.bg_music = GameMusics.SURFACE

	# 5. Link maps.
	# surface <-> offices level
	add_exit(map, surface_stairs_pos, offices_level, Vector2i(1, 1), GameImages.DECO_STAIRS_DOWN, true)
	add_exit(offices_level, Vector2i(1, 1), map, surface_stairs_pos, GameImages.DECO_STAIRS_UP, true)

	# offices <-> jails
	add_exit(offices_level, Vector2i(1, offices_level.height - 2), jails_level, Vector2i(1, 1), GameImages.DECO_STAIRS_DOWN, true)
	add_exit(jails_level, Vector2i(1, 1), offices_level, Vector2i(1, offices_level.height - 2), GameImages.DECO_STAIRS_UP, true)

	# 6. Add maps to district.
	_params.district.add_unique_map(offices_level)
	_params.district.add_unique_map(jails_level)

	# 7. Set unique maps.
	game.session.unique_maps.police_station_offices_level = Session.UniqueMap.new()
	game.session.unique_maps.police_station_offices_level.the_map = offices_level
	game.session.unique_maps.police_station_jails_level = Session.UniqueMap.new()
	game.session.unique_maps.police_station_jails_level.the_map = jails_level

	# done!
	return police_block


## C# GeneratePoliceStation(surfaceMap, policeBlock, out stairsToLevel1) :
## returns the stairs position.
func generate_police_station(surface_map: Map, police_block: Block) -> Vector2i:
	# Fill & Enclose Building.
	tile_fill_rect(surface_map, game.game_tiles.floor_tiles(), police_block.inside_rect)
	tile_rectangle(surface_map, game.game_tiles.wall_police_station(), police_block.building_rect.position.x, police_block.building_rect.position.y, police_block.building_rect.size.x, police_block.building_rect.size.y)
	tile_rectangle(surface_map, game.game_tiles.floor_walkway(), police_block.rectangle.position.x, police_block.rectangle.position.y, police_block.rectangle.size.x, police_block.rectangle.size.y)
	var inside_fn := func(pt): surface_map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(surface_map, police_block.inside_rect, inside_fn)

	# Entrance to the south with police signs.
	var entry_door_pos := Vector2i(police_block.building_rect.position.x + police_block.building_rect.size.x / 2, police_block.building_rect.end.y - 1)
	_safe_add_decoration(surface_map, entry_door_pos.x - 1, entry_door_pos.y, GameImages.DECO_POLICE_STATION)
	_safe_add_decoration(surface_map, entry_door_pos.x + 1, entry_door_pos.y, GameImages.DECO_POLICE_STATION)

	# Entry hall.
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var entry_hall := Rect2i(police_block.building_rect.position.x, police_block.building_rect.position.y + 2, police_block.building_rect.size.x, police_block.building_rect.end.y - (police_block.building_rect.position.y + 2))
	tile_rectangle(surface_map, game.game_tiles.wall_police_station(), entry_hall.position.x, entry_hall.position.y, entry_hall.size.x, entry_hall.size.y)
	place_door(surface_map, entry_hall.position.x + entry_hall.size.x / 2, entry_hall.position.y, game.game_tiles.floor_tiles(), make_obj_iron_door())
	place_door(surface_map, entry_door_pos.x, entry_door_pos.y, game.game_tiles.floor_tiles(), make_obj_glass_door())
	var bench_fn := func(pt):
		if !surface_map.is_walkable(pt.x, pt.y):
			return
		if count_adj_walls_xy(surface_map, pt.x, pt.y) == 0 || count_adj_doors(surface_map, pt.x, pt.y) > 0:
			return
		surface_map.place_map_object_at(make_obj_bench(GameImages.OBJ_BENCH), pt)
	do_for_each_tile(surface_map, entry_hall, bench_fn)

	# Place stairs, north side.
	var stairs_to_level1 := Vector2i(entry_door_pos.x, police_block.inside_rect.position.y)

	# Zone.
	surface_map.add_zone(make_unique_zone("Police Station", police_block.building_rect))
	make_walkway_zones(surface_map, police_block)

	return stairs_to_level1


func generate_police_station_offices_level(surface_map: Map, _police_block: Block, _exit_pos: Vector2i) -> Map:
	################
	# 1. Create map.
	# 2. Floor plan.
	# 3. Populate.
	################

	# 1. Create map.
	var _seed: int = (surface_map.seed << 1) ^ surface_map.seed
	var map := Map.new(_seed, "Police Station - Offices", 20, 20)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)

	# 2. Floor plan.
	tile_fill_all(map, game.game_tiles.floor_tiles())
	tile_rectangle(map, game.game_tiles.wall_police_station(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)
	# - offices rooms on the east side, doors leading west.
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var offices_rect := Rect2i(3, 0, map.width - 3, map.height)
	var rooms_list: Array = []
	make_rooms_plan(map, rooms_list, offices_rect, 5, 5)
	for room_rect in rooms_list:
		# C# FromLTRB(Left+1, Top+1, Right-1, Bottom-1) -> Rect2i(Left+1, Top+1, Width-2, Height-2)
		var in_room_rect := Rect2i(room_rect.position.x + 1, room_rect.position.y + 1, room_rect.size.x - 2, room_rect.size.y - 2)
		# 2 kind of rooms.
		# - farthest east from corridor : security.
		# - others : offices.
		if room_rect.end.x == map.width:
			# Police Security Room.
			# make room with door.
			tile_rectangle(map, game.game_tiles.wall_police_station(), room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y)
			place_door(map, room_rect.position.x, room_rect.position.y + room_rect.size.y / 2, game.game_tiles.floor_concrete(), make_obj_iron_door())

			# shelves with weaponry & armor next to the walls.
			var security_shelf_fn := func(pt):
				if !map.is_walkable_p(pt) || count_adj_walls_xy(map, pt.x, pt.y) == 0 || count_adj_doors(map, pt.x, pt.y) > 0:
					return

				# shelf.
				map.place_map_object_at(make_obj_shelf(GameImages.OBJ_SHOP_SHELF), pt)

				# weaponry/armor/radios.
				var it = null  # Item (untyped : can be null)
				var roll: int = _dice_roller.roll(0, 10)
				match roll:
					# 20% armors
					0, 1:
						it = make_item_police_jacket() if _dice_roller.roll_chance(50) else make_item_police_riot_armor()

					# 20% light/radio
					2, 3:
						it = (make_item_flashlight() if _dice_roller.roll_chance(50) else make_item_big_flashlight()) if _dice_roller.roll_chance(50) else make_item_police_radio()

					# 20% truncheon
					4, 5:
						it = make_item_truncheon()

					# 20% pistol/ammo - 30% pistol 70% amo
					6, 7:
						it = make_item_pistol() if _dice_roller.roll_chance(30) else make_item_light_pistol_ammo()

					# 20% shotgun/ammo - 30% shotgun 70% amo
					8, 9:
						it = make_item_shotgun() if _dice_roller.roll_chance(30) else make_item_shotgun_ammo()

					_:
						# C# threw ArgumentOutOfRangeException.
						push_error("BaseTownGenerator : unhandled roll")
						it = null

				map.drop_item_at(it, pt)
			do_for_each_tile(map, in_room_rect, security_shelf_fn)

			# zone.
			map.add_zone(make_unique_zone("security", in_room_rect))
		else:
			# Police Office Room.
			# make room with door.
			tile_fill_rect(map, game.game_tiles.floor_planks(), room_rect)
			tile_rectangle(map, game.game_tiles.wall_police_station(), room_rect.position.x, room_rect.position.y, room_rect.size.x, room_rect.size.y)
			place_door(map, room_rect.position.x, room_rect.position.y + room_rect.size.y / 2, game.game_tiles.floor_planks(), make_obj_wooden_door())

			# add furniture : 1 table, 2 chairs.
			var office_walk_fn := func(pt): return map.is_walkable(pt.x, pt.y) && count_adj_doors(map, pt.x, pt.y) == 0
			var table_fn := func(_pt): return make_obj_table(GameImages.OBJ_TABLE)
			map_object_place_in_good_position_rect(map, in_room_rect, office_walk_fn, _dice_roller, table_fn)
			var chair_fn := func(_pt): return make_obj_chair(GameImages.OBJ_CHAIR)
			map_object_place_in_good_position_rect(map, in_room_rect, office_walk_fn, _dice_roller, chair_fn)
			var chair_fn2 := func(_pt): return make_obj_chair(GameImages.OBJ_CHAIR)
			map_object_place_in_good_position_rect(map, in_room_rect, office_walk_fn, _dice_roller, chair_fn2)

			# zone.
			map.add_zone(make_unique_zone("office", in_room_rect))

	# - benches in corridor.
	var corridor_bench_fn := func(pt):
		if pt.y % 2 == 1:
			return
		if !map.is_walkable_p(pt):
			return
		if count_adj_walls_p(map, pt) != 3:
			return

		map.place_map_object_at(make_obj_iron_bench(GameImages.OBJ_IRON_BENCH), pt)
	do_for_each_tile(map, Rect2i(1, 1, 1, map.height - 2), corridor_bench_fn)

	# 3. Populate.
	# - cops.
	const nb_cops: int = 5
	for i in nb_cops:
		var cop: Actor = create_new_policeman(0)
		actor_place(_dice_roller, map.width * map.height, map, cop)

	# done.
	return map


func generate_police_station_jails_level(surface_map: Map) -> Map:
	##################
	# 1. Create map.
	# 2. Floor plan.
	# 3. Populate.
	##################

	# 1. Create map.
	var _seed: int = (surface_map.seed << 1) ^ surface_map.seed
	var map := Map.new(_seed, "Police Station - Jails", 22, 6)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)

	# 2. Floor plan.
	tile_fill_all(map, game.game_tiles.floor_tiles())
	tile_rectangle(map, game.game_tiles.wall_police_station(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)
	# - small cells.
	const cell_width: int = 3
	const cell_height: int = 3
	const y_cells: int = 3
	var cells: Array = []
	var x: int = 0
	while x + cell_width <= map.width:
		# room.
		var cell_room := Rect2i(x, y_cells, cell_width, cell_height)
		cells.append(cell_room)
		tile_fill_rect(map, game.game_tiles.floor_concrete(), cell_room)
		tile_rectangle(map, game.game_tiles.wall_police_station(), cell_room.position.x, cell_room.position.y, cell_room.size.x, cell_room.size.y)

		# couch.
		var couch_pos := Vector2i(x + 1, y_cells + 1)
		map.place_map_object_at(make_obj_iron_bench(GameImages.OBJ_IRON_BENCH), couch_pos)

		# gate.
		var gate_pos := Vector2i(x + 1, y_cells)
		map.set_tile_model_at(gate_pos.x, gate_pos.y, game.game_tiles.floor_concrete())
		map.place_map_object_at(make_obj_iron_gate(GameImages.OBJ_GATE_CLOSED, false), gate_pos)  # alpha10.1 made unbreakable because civ ai can now bash their way out when trapped :p
		# zone.
		map.add_zone(make_unique_zone(RogueGame.NAME_POLICE_STATION_JAILS_CELL, cell_room))
		x += cell_width - 1
	# - corridor.
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var corridor := Rect2i(1, 1, map.width - 1, y_cells - 1)
	map.add_zone(make_unique_zone("cells corridor", corridor))
	# - the switch to open/close the cells.
	map.place_map_object_at(make_obj_power_generator(GameImages.OBJ_POWERGEN_OFF, GameImages.OBJ_POWERGEN_ON), Vector2i(map.width - 2, 1))

	# 3. Populate.
	# a prisoner in each cell.
	# alph10.1 the prisoner who should not be is now in one of the cell at random instead of always the last one
	var prisonner_cell: int = _dice_roller.roll(0, cells.size())
	for i in cells.size():
		var cell: Rect2i = cells[i]

		# prisonner who should not be or regular civilian
		var prisoner: Actor
		if i == prisonner_cell:
			# prisoner who should not be
			prisoner = create_new_civilian(0, 0, 1)
			prisoner.name = "The Prisoner Who Should Not Be"

			# plenty of food
			for j in prisoner.inventory.max_capacity:
				prisoner.inventory.add_all(make_item_army_ration())

			# register unique
			game.session.unique_actors.police_station_prisoner = Session.UniqueActor.new()
			game.session.unique_actors.police_station_prisoner.the_actor = prisoner
			game.session.unique_actors.police_station_prisoner.is_spawned = true
		else:
			# jailed. Civilian.
			prisoner = create_new_civilian(0, 0, 1)

			# make sure he is stripped of all default items!
			while !prisoner.inventory.is_empty:
				prisoner.inventory.remove_all_quantity(prisoner.inventory.get_item_at(0))

			# give him some food.
			prisoner.inventory.add_all(make_item_groceries())

		# drop him.
		map.place_actor_at(prisoner, Vector2i(cell.position.x + 1, cell.position.y + 1))

	# done.
	return map

# endregion

# region Hospital

## Layout :
##  0 floor: Entry Hall.
## -1 floor: Admissions (short term patients).
## -2 floor: Offices. (doctors)
## -3 floor: Patients. (nurses, injured patients)
## -4 floor: Storage. (bunch of meds & pills; blocked by closed gates, need power on)
## -5 floor: Power. (restore power to the whole building = lights, open storage gates)
##
## C# MakeHospital(map, freeBlocks, out hospitalBlock) : returns the chosen block.
func make_hospital(map: Map, free_blocks: Array) -> Block:
	################################
	# 1. Pick a block.
	# 2. Generate surface building.
	# 3. Generate other levels maps.
	# 5. Link maps.
	# 6. Add maps to district.
	# 7. Set unique maps.
	################################

	# 1. Pick a block.
	# any random block will do.
	var hospital_block: Block = free_blocks[_dice_roller.roll(0, free_blocks.size())]

	# 2. Generate surface.
	generate_hospital_entry_hall(map, hospital_block)

	# 3. Generate other levels maps.
	var admissions: Map = generate_hospital_admissions((map.seed << 1) ^ map.seed)
	var offices: Map = generate_hospital_offices((map.seed << 2) ^ map.seed)
	var patients: Map = generate_hospital_patients((map.seed << 3) ^ map.seed)
	var storage: Map = generate_hospital_storage((map.seed << 4) ^ map.seed)
	var power: Map = generate_hospital_power((map.seed << 5) ^ map.seed)

	# alpha10 music
	admissions.bg_music = GameMusics.HOSPITAL
	offices.bg_music = GameMusics.HOSPITAL
	patients.bg_music = GameMusics.HOSPITAL
	storage.bg_music = GameMusics.HOSPITAL
	power.bg_music = GameMusics.HOSPITAL

	# 5. Link maps.
	# entry <-> admissions
	var entry_stairs := Vector2i(hospital_block.inside_rect.position.x + hospital_block.inside_rect.size.x / 2, hospital_block.inside_rect.position.y)
	var admissions_up_stairs := Vector2i(admissions.width / 2, 1)
	add_exit(map, entry_stairs, admissions, admissions_up_stairs, GameImages.DECO_STAIRS_DOWN, true)
	add_exit(admissions, admissions_up_stairs, map, entry_stairs, GameImages.DECO_STAIRS_UP, true)

	# admissions <-> offices
	var admissions_down_stairs := Vector2i(admissions.width / 2, admissions.height - 2)
	var offices_up_stairs := Vector2i(offices.width / 2, 1)
	add_exit(admissions, admissions_down_stairs, offices, offices_up_stairs, GameImages.DECO_STAIRS_DOWN, true)
	add_exit(offices, offices_up_stairs, admissions, admissions_down_stairs, GameImages.DECO_STAIRS_UP, true)

	# offices <-> patients
	var offices_down_stairs := Vector2i(offices.width / 2, offices.height - 2)
	var patients_up_stairs := Vector2i(patients.width / 2, 1)
	add_exit(offices, offices_down_stairs, patients, patients_up_stairs, GameImages.DECO_STAIRS_DOWN, true)
	add_exit(patients, patients_up_stairs, offices, offices_down_stairs, GameImages.DECO_STAIRS_UP, true)

	# patients <-> storage
	var patients_down_stairs := Vector2i(patients.width / 2, patients.height - 2)
	var storage_up_stairs := Vector2i(1, 1)
	add_exit(patients, patients_down_stairs, storage, storage_up_stairs, GameImages.DECO_STAIRS_DOWN, true)
	add_exit(storage, storage_up_stairs, patients, patients_down_stairs, GameImages.DECO_STAIRS_UP, true)

	# storage <-> power
	var storage_down_stairs := Vector2i(storage.width - 2, 1)
	var power_up_stairs := Vector2i(1, 1)
	add_exit(storage, storage_down_stairs, power, power_up_stairs, GameImages.DECO_STAIRS_DOWN, true)
	add_exit(power, power_up_stairs, storage, storage_down_stairs, GameImages.DECO_STAIRS_UP, true)

	# 6. Add maps to district.
	_params.district.add_unique_map(admissions)
	_params.district.add_unique_map(offices)
	_params.district.add_unique_map(patients)
	_params.district.add_unique_map(storage)
	_params.district.add_unique_map(power)

	# 7. Set unique maps.
	game.session.unique_maps.hospital_admissions = Session.UniqueMap.new()
	game.session.unique_maps.hospital_admissions.the_map = admissions
	game.session.unique_maps.hospital_offices = Session.UniqueMap.new()
	game.session.unique_maps.hospital_offices.the_map = offices
	game.session.unique_maps.hospital_patients = Session.UniqueMap.new()
	game.session.unique_maps.hospital_patients.the_map = patients
	game.session.unique_maps.hospital_storage = Session.UniqueMap.new()
	game.session.unique_maps.hospital_storage.the_map = storage
	game.session.unique_maps.hospital_power = Session.UniqueMap.new()
	game.session.unique_maps.hospital_power.the_map = power

	# done!
	return hospital_block


func generate_hospital_entry_hall(surface_map: Map, block: Block) -> void:
	# Fill & Enclose Building.
	tile_fill_rect(surface_map, game.game_tiles.floor_tiles(), block.inside_rect)
	tile_rectangle(surface_map, game.game_tiles.wall_hospital(), block.building_rect.position.x, block.building_rect.position.y, block.building_rect.size.x, block.building_rect.size.y)
	tile_rectangle(surface_map, game.game_tiles.floor_walkway(), block.rectangle.position.x, block.rectangle.position.y, block.rectangle.size.x, block.rectangle.size.y)
	var inside_fn := func(pt): surface_map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(surface_map, block.inside_rect, inside_fn)

	# 2 entrances to the south with signs.
	var entry_right_door_pos := Vector2i(block.building_rect.position.x + block.building_rect.size.x / 2, block.building_rect.end.y - 1)
	var entry_left_door_pos := Vector2i(entry_right_door_pos.x - 1, entry_right_door_pos.y)
	_safe_add_decoration(surface_map, entry_left_door_pos.x - 1, entry_left_door_pos.y, GameImages.DECO_HOSPITAL)
	_safe_add_decoration(surface_map, entry_right_door_pos.x + 1, entry_right_door_pos.y, GameImages.DECO_HOSPITAL)

	# Entry hall = whole building.
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var entry_hall := Rect2i(block.building_rect.position.x, block.building_rect.position.y, block.building_rect.size.x, block.building_rect.size.y)
	place_door(surface_map, entry_right_door_pos.x, entry_right_door_pos.y, game.game_tiles.floor_tiles(), make_obj_glass_door())
	place_door(surface_map, entry_left_door_pos.x, entry_left_door_pos.y, game.game_tiles.floor_tiles(), make_obj_glass_door())
	var bench_fn := func(pt):
		# benches only on west & east sides.
		if pt.y == block.inside_rect.position.y || pt.y == block.inside_rect.end.y - 1:
			return
		if !surface_map.is_walkable(pt.x, pt.y):
			return
		if count_adj_walls_xy(surface_map, pt.x, pt.y) == 0 || count_adj_doors(surface_map, pt.x, pt.y) > 0:
			return
		surface_map.place_map_object_at(make_obj_iron_bench(GameImages.OBJ_IRON_BENCH), pt)
	do_for_each_tile(surface_map, entry_hall, bench_fn)

	# Zone.
	surface_map.add_zone(make_unique_zone("Hospital", block.building_rect))
	make_walkway_zones(surface_map, block)


func generate_hospital_admissions(_seed: int) -> Map:
	################
	# 1. Create map.
	# 2. Floor plan.
	# 3. Populate.
	################

	# 1. Create map.
	var map := Map.new(_seed, "Hospital - Admissions", 13, 33)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)
	tile_fill_all(map, game.game_tiles.floor_tiles())
	tile_rectangle(map, game.game_tiles.wall_hospital(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)

	# 2. Floor plan.
	# One central south->north corridor with admission rooms on each sides.
	const room_size: int = 5

	# 1. Central corridor.
	var corridor := Rect2i(room_size - 1, 0, 5, map.height)
	tile_rectangle(map, game.game_tiles.wall_hospital(), corridor.position.x, corridor.position.y, corridor.size.x, corridor.size.y)
	map.add_zone(make_unique_zone("corridor", corridor))

	# 2. Admission rooms, all similar 5x5 rooms (3x3 inside)
	var left_wing := Rect2i(0, 0, room_size, map.height)
	for room_y in range(0, map.height - room_size + 1, room_size - 1):
		var room := Rect2i(left_wing.position.x, room_y, room_size, room_size)
		make_hospital_patient_room(map, "patient room", room, true)

	var right_wing := Rect2i(map.rect.end.x - room_size, 0, room_size, map.height)
	for room_y in range(0, map.height - room_size + 1, room_size - 1):
		var room := Rect2i(right_wing.position.x, room_y, room_size, room_size)
		make_hospital_patient_room(map, "patient room", room, false)

	# 3. Populate.
	# patients in rooms.
	const nb_patients: int = 10
	for i in nb_patients:
		# create.
		var patient: Actor = create_new_hospital_patient(0)
		# place.
		var patient_room_fn := func(pt): return map.has_zone_partially_named_at(pt, "patient room")
		actor_place(_dice_roller, map.width * map.height, map, patient, patient_room_fn)

	# nurses & doctor in corridor.
	const nb_nurses: int = 4
	for i in nb_nurses:
		# create.
		var nurse: Actor = create_new_hospital_nurse(0)
		# place.
		var corridor_fn := func(pt): return map.has_zone_partially_named_at(pt, "corridor")
		actor_place(_dice_roller, map.width * map.height, map, nurse, corridor_fn)
	const nb_doctor: int = 1
	for i in nb_doctor:
		# create.
		var nurse: Actor = create_new_hospital_doctor(0)
		# place.
		var corridor_fn2 := func(pt): return map.has_zone_partially_named_at(pt, "corridor")
		actor_place(_dice_roller, map.width * map.height, map, nurse, corridor_fn2)

	# done.
	return map


func generate_hospital_offices(_seed: int) -> Map:
	################
	# 1. Create map.
	# 2. Floor plan.
	# 3. Populate.
	################

	# 1. Create map.
	var map := Map.new(_seed, "Hospital - Offices", 13, 33)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)
	tile_fill_all(map, game.game_tiles.floor_tiles())
	tile_rectangle(map, game.game_tiles.wall_hospital(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)

	# 2. Floor plan.
	# One central south->north corridor with offices rooms on each sides.
	const room_size: int = 5

	# 1. Central corridor.
	var corridor := Rect2i(room_size - 1, 0, 5, map.height)
	tile_rectangle(map, game.game_tiles.wall_hospital(), corridor.position.x, corridor.position.y, corridor.size.x, corridor.size.y)
	map.add_zone(make_unique_zone("corridor", corridor))

	# 2. Offices rooms, all similar 5x5 rooms (3x3 inside)
	var left_wing := Rect2i(0, 0, room_size, map.height)
	for room_y in range(0, map.height - room_size + 1, room_size - 1):
		var room := Rect2i(left_wing.position.x, room_y, room_size, room_size)
		make_hospital_office_room(map, "office", room, true)

	var right_wing := Rect2i(map.rect.end.x - room_size, 0, room_size, map.height)
	for room_y in range(0, map.height - room_size + 1, room_size - 1):
		var room := Rect2i(right_wing.position.x, room_y, room_size, room_size)
		make_hospital_office_room(map, "office", room, false)

	# 3. Populate.
	# nurses & doctor in offices.
	const nb_nurses: int = 5
	for i in nb_nurses:
		# create.
		var nurse: Actor = create_new_hospital_nurse(0)
		# place.
		var office_fn := func(pt): return map.has_zone_partially_named_at(pt, "office")
		actor_place(_dice_roller, map.width * map.height, map, nurse, office_fn)
	const nb_doctor: int = 2
	for i in nb_doctor:
		# create.
		var nurse: Actor = create_new_hospital_doctor(0)
		# place.
		var office_fn2 := func(pt): return map.has_zone_partially_named_at(pt, "office")
		actor_place(_dice_roller, map.width * map.height, map, nurse, office_fn2)

	# done.
	return map


func generate_hospital_patients(_seed: int) -> Map:
	################
	# 1. Create map.
	# 2. Floor plan.
	# 3. Populate.
	################

	# 1. Create map.
	var map := Map.new(_seed, "Hospital - Patients", 13, 49)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)
	tile_fill_all(map, game.game_tiles.floor_tiles())
	tile_rectangle(map, game.game_tiles.wall_hospital(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)

	# 2. Floor plan.
	# One central south->north corridor with admission rooms on each sides.
	const room_size: int = 5

	# 1. Central corridor.
	var corridor := Rect2i(room_size - 1, 0, 5, map.height)
	tile_rectangle(map, game.game_tiles.wall_hospital(), corridor.position.x, corridor.position.y, corridor.size.x, corridor.size.y)
	map.add_zone(make_unique_zone("corridor", corridor))

	# 2. Patients rooms, all similar 5x5 rooms (3x3 inside)
	var left_wing := Rect2i(0, 0, room_size, map.height)
	for room_y in range(0, map.height - room_size + 1, room_size - 1):
		var room := Rect2i(left_wing.position.x, room_y, room_size, room_size)
		make_hospital_patient_room(map, "patient room", room, true)

	var right_wing := Rect2i(map.rect.end.x - room_size, 0, room_size, map.height)
	for room_y in range(0, map.height - room_size + 1, room_size - 1):
		var room := Rect2i(right_wing.position.x, room_y, room_size, room_size)
		make_hospital_patient_room(map, "patient room", room, false)

	# 3. Populate.
	# patients in rooms.
	const nb_patients: int = 20
	for i in nb_patients:
		# create.
		var patient: Actor = create_new_hospital_patient(0)
		# place.
		var patient_room_fn := func(pt): return map.has_zone_partially_named_at(pt, "patient room")
		actor_place(_dice_roller, map.width * map.height, map, patient, patient_room_fn)

	# nurses & doctor in corridor.
	const nb_nurses: int = 8
	for i in nb_nurses:
		# create.
		var nurse: Actor = create_new_hospital_nurse(0)
		# place.
		var corridor_fn := func(pt): return map.has_zone_partially_named_at(pt, "corridor")
		actor_place(_dice_roller, map.width * map.height, map, nurse, corridor_fn)
	const nb_doctor: int = 2
	for i in nb_doctor:
		# create.
		var nurse: Actor = create_new_hospital_doctor(0)
		# place.
		var corridor_fn2 := func(pt): return map.has_zone_partially_named_at(pt, "corridor")
		actor_place(_dice_roller, map.width * map.height, map, nurse, corridor_fn2)

	# done.
	return map


func generate_hospital_storage(_seed: int) -> Map:
	##################
	# 1. Create map.
	# 2. Floor plan.
	##################

	# 1. Create map.
	var map := Map.new(_seed, "Hospital - Storage", 51, 16)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)
	tile_fill_all(map, game.game_tiles.floor_tiles())
	tile_rectangle(map, game.game_tiles.wall_hospital(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)

	# 2. Floor plan.
	# 1 north corridor linking stairs.
	# 1 central corridor to storage rooms, locked by an iron gate.
	# 1 south corridor to other storage rooms.

	# 1 north corridor linking stairs.
	const north_corridor_height: int = 4
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var north_corridor_rect := Rect2i(0, 0, map.width, north_corridor_height)
	tile_rectangle(map, game.game_tiles.wall_hospital(), north_corridor_rect.position.x, north_corridor_rect.position.y, north_corridor_rect.size.x, north_corridor_rect.size.y)
	map.add_zone(make_unique_zone("north corridor", north_corridor_rect))

	# 1 corridor to storage rooms, locked by an iron gate.
	const corridor_height: int = 4
	var central_corridor_rect := Rect2i(0, north_corridor_rect.end.y - 1, map.width, corridor_height)
	tile_rectangle(map, game.game_tiles.wall_hospital(), central_corridor_rect.position.x, central_corridor_rect.position.y, central_corridor_rect.size.x, central_corridor_rect.size.y)
	map.set_tile_model_at(1, central_corridor_rect.position.y, game.game_tiles.floor_tiles())
	map.place_map_object_at(make_obj_iron_gate(GameImages.OBJ_GATE_CLOSED), Vector2i(1, central_corridor_rect.position.y))
	map.add_zone(make_unique_zone("central corridor", central_corridor_rect))
	# storage rooms.
	const storage_width: int = 5
	const storage_height: int = 4
	var storage_central := Rect2i(2, central_corridor_rect.end.y - 1, map.width - 2, storage_height)
	for room_x in range(storage_central.position.x, map.width - storage_width + 1, storage_width - 1):
		var room := Rect2i(room_x, storage_central.position.y, storage_width, storage_height)
		make_hospital_storage_room(map, "storage", room)
	map.set_tile_model_at(1, storage_central.position.y, game.game_tiles.floor_tiles())

	# 1 south corridor to other storage rooms.
	var south_corridor_rect := Rect2i(0, storage_central.end.y - 1, map.width, corridor_height)
	tile_rectangle(map, game.game_tiles.wall_hospital(), south_corridor_rect.position.x, south_corridor_rect.position.y, south_corridor_rect.size.x, south_corridor_rect.size.y)
	map.set_tile_model_at(1, south_corridor_rect.position.y, game.game_tiles.floor_tiles())
	map.add_zone(make_unique_zone("south corridor", south_corridor_rect))
	# storage rooms.
	var storage_south := Rect2i(2, south_corridor_rect.end.y - 1, map.width - 2, storage_height)
	for room_x in range(storage_south.position.x, map.width - storage_width + 1, storage_width - 1):
		var room := Rect2i(room_x, storage_south.position.y, storage_width, storage_height)
		make_hospital_storage_room(map, "storage", room)
	map.set_tile_model_at(1, storage_south.position.y, game.game_tiles.floor_tiles())

	# alpha10.1 moved Jason Myers out of power room to storage north corridor
	# also upped high stamina to 5 (was 3).
	# Jason Myers
	var model: ActorModel = game.game_actors.jason_myers()
	var jason: Actor = model.create_named(game.game_factions.the_psychopaths(), "Jason Myers", false, 0)
	jason.is_unique = true
	jason.doll.add_decoration(Doll.DollPart.SKIN, GameImages.ACTOR_JASON_MYERS)
	give_starting_skill_to_actor(jason, Skills.IDs.TOUGH)
	give_starting_skill_to_actor(jason, Skills.IDs.TOUGH)
	give_starting_skill_to_actor(jason, Skills.IDs.TOUGH)
	give_starting_skill_to_actor(jason, Skills.IDs.STRONG)
	give_starting_skill_to_actor(jason, Skills.IDs.STRONG)
	give_starting_skill_to_actor(jason, Skills.IDs.STRONG)
	give_starting_skill_to_actor(jason, Skills.IDs.AGILE)
	give_starting_skill_to_actor(jason, Skills.IDs.AGILE)
	give_starting_skill_to_actor(jason, Skills.IDs.AGILE)
	give_starting_skill_to_actor(jason, Skills.IDs.HIGH_STAMINA)
	give_starting_skill_to_actor(jason, Skills.IDs.HIGH_STAMINA)
	give_starting_skill_to_actor(jason, Skills.IDs.HIGH_STAMINA)
	give_starting_skill_to_actor(jason, Skills.IDs.HIGH_STAMINA)
	give_starting_skill_to_actor(jason, Skills.IDs.HIGH_STAMINA)
	jason.inventory.add_all(make_item_jason_myers_axe())
	map.place_actor_at(jason, Vector2i(map.width / 2, 1))
	game.session.unique_actors.jason_myers = Session.UniqueActor.new()
	game.session.unique_actors.jason_myers.the_actor = jason
	game.session.unique_actors.jason_myers.is_spawned = true

	# done.
	return map


func generate_hospital_power(_seed: int) -> Map:
	################
	# 1. Create map.
	# 2. Floor plan.
	# 3. Populate.
	################

	# 1. Create map.
	var map := Map.new(_seed, "Hospital - Power", 10, 10)
	map.lighting = Map.Lighting.DARKNESS
	var inside_fn := func(pt): map.get_tile_at_p(pt).is_inside = true
	do_for_each_tile(map, map.rect, inside_fn)
	tile_fill_all(map, game.game_tiles.floor_concrete())
	tile_rectangle(map, game.game_tiles.wall_brick(), map.rect.position.x, map.rect.position.y, map.rect.size.x, map.rect.size.y)

	# 2. Floor plan.
	# one narrow corridor separated from the power gen room by iron fences.
	# barricade room for the Enraged Patient.

	# corridor with fences.
	# C# Rectangle.FromLTRB(left, top, right, bottom) -> Rect2i(left, top, right-left, bottom-top)
	var corridor := Rect2i(1, 1, 2, map.height - 1)
	map.add_zone(make_unique_zone("corridor", corridor))
	for y_fence in range(1, map.height - 2):
		map.place_map_object_at(make_obj_iron_fence(GameImages.OBJ_IRON_FENCE), Vector2i(2, y_fence))

	# power room.
	var room := Rect2i(3, 0, map.width - 3, map.height)
	map.add_zone(make_unique_zone("power room", room))

	# power generators.
	var powergen_fn := func(pt):
		if pt.x == room.position.x:
			return
		if !map.is_walkable_p(pt):
			return
		if count_adj_walls_p(map, pt) < 3:
			return

		map.place_map_object_at(make_obj_power_generator(GameImages.OBJ_POWERGEN_OFF, GameImages.OBJ_POWERGEN_ON), pt)
	do_for_each_tile(map, room, powergen_fn)

	# alpha10.1 moved Jason Myers out of power room to storage north corridor
	# (the old Jason Myers population code is commented out in the C# original too)

	# done.
	return map


func create_new_hospital_patient(_spawn_time: int) -> Actor:
	# decide model.
	var model: ActorModel = game.game_actors.male_civilian() if rules.roll(0, 2) == 0 else game.game_actors.female_civilian()

	# create.
	var patient: Actor = model.create_numbered_name(game.game_factions.the_civilians(), 0)
	skin_naked_human(_dice_roller, patient)
	give_name_to_actor(_dice_roller, patient)
	patient.name = "Patient " + patient.name
	#patient.Controller = new CivilianAI();  # alpha10.1 defined by model like other actors

	# skills.
	give_random_skills_to_actor(_dice_roller, patient, 1)

	# add patient uniform.
	patient.doll.add_decoration(Doll.DollPart.TORSO, GameImages.HOSPITAL_PATIENT_UNIFORM)

	# done.
	return patient


func create_new_hospital_nurse(_spawn_time: int) -> Actor:
	# create.
	var nurse: Actor = game.game_actors.female_civilian().create_numbered_name(game.game_factions.the_civilians(), 0)
	skin_naked_human(_dice_roller, nurse)
	give_name_to_actor(_dice_roller, nurse)
	nurse.name = "Nurse " + nurse.name
	#nurse.Controller = new CivilianAI()  # alpha10.1 defined by model like other actors

	# add uniform.
	nurse.doll.add_decoration(Doll.DollPart.TORSO, GameImages.HOSPITAL_NURSE_UNIFORM)

	# skills : 1 + 1-Medic.
	give_random_skills_to_actor(_dice_roller, nurse, 1)
	give_starting_skill_to_actor(nurse, Skills.IDs.MEDIC)

	# items : bandages.
	nurse.inventory.add_all(make_item_bandages())

	# done.
	return nurse


func create_new_hospital_doctor(_spawn_time: int) -> Actor:
	# create.
	var doctor: Actor = game.game_actors.male_civilian().create_numbered_name(game.game_factions.the_civilians(), 0)
	skin_naked_human(_dice_roller, doctor)
	give_name_to_actor(_dice_roller, doctor)
	doctor.name = "Doctor " + doctor.name
	#doctor.Controller = new CivilianAI()  # alpha10.1 defined by model like other actors

	# add uniform.
	doctor.doll.add_decoration(Doll.DollPart.TORSO, GameImages.HOSPITAL_DOCTOR_UNIFORM)

	# skills : 1 + 3-Medic + 1-Leadership.
	give_random_skills_to_actor(_dice_roller, doctor, 1)
	give_starting_skill_to_actor(doctor, Skills.IDs.MEDIC)
	give_starting_skill_to_actor(doctor, Skills.IDs.MEDIC)
	give_starting_skill_to_actor(doctor, Skills.IDs.MEDIC)
	give_starting_skill_to_actor(doctor, Skills.IDs.LEADERSHIP)

	# items : medikit + bandages.
	doctor.inventory.add_all(make_item_medikit())
	doctor.inventory.add_all(make_item_bandages())

	# done.
	return doctor


func make_hospital_patient_room(map: Map, base_zone_name: String, room: Rect2i, is_facing_east: bool) -> void:
	tile_rectangle(map, game.game_tiles.wall_hospital(), room.position.x, room.position.y, room.size.x, room.size.y)
	map.add_zone(make_unique_zone(base_zone_name, room))

	var x_door: int = (room.end.x - 1 if is_facing_east else room.position.x)

	# door in the corner.
	place_door(map, x_door, room.position.y + 1, game.game_tiles.floor_tiles(), make_obj_hospital_door())

	# bed in the middle in the south.
	var bed_pos := Vector2i(room.position.x + room.size.x / 2, room.end.y - 2)
	map.place_map_object_at(make_obj_bed(GameImages.OBJ_HOSPITAL_BED), bed_pos)

	# chair and nighttable on either side of the bed.
	map.place_map_object_at(make_obj_chair(GameImages.OBJ_HOSPITAL_CHAIR), Vector2i(bed_pos.x + 1 if is_facing_east else bed_pos.x - 1, bed_pos.y))
	var table_pos := Vector2i(bed_pos.x - 1 if is_facing_east else bed_pos.x + 1, bed_pos.y)
	map.place_map_object_at(make_obj_night_table(GameImages.OBJ_HOSPITAL_NIGHT_TABLE), table_pos)

	# chance of some meds/food/book on nightable.
	if _dice_roller.roll_chance(50):
		var roll: int = _dice_roller.roll(0, 3)
		var it = null  # Item (untyped : can be null)
		match roll:
			0:
				it = make_shop_pharmacy_item()
			1:
				it = make_item_groceries()
			2:
				it = make_item_book()
		if it != null:
			map.drop_item_at(it, table_pos)

	# wardrobe in the corner.
	map.place_map_object_at(make_obj_wardrobe(GameImages.OBJ_HOSPITAL_WARDROBE), Vector2i(room.position.x + 1 if is_facing_east else room.end.x - 2, room.position.y + 1))


func make_hospital_office_room(map: Map, base_zone_name: String, room: Rect2i, is_facing_east: bool) -> void:
	tile_fill_rect(map, game.game_tiles.floor_planks(), room)
	tile_rectangle(map, game.game_tiles.wall_hospital(), room.position.x, room.position.y, room.size.x, room.size.y)
	map.add_zone(make_unique_zone(base_zone_name, room))

	var x_door: int = (room.end.x - 1 if is_facing_east else room.position.x)
	var y_door: int = room.position.y + 2

	# door in the middle.
	place_door(map, x_door, y_door, game.game_tiles.floor_tiles(), make_obj_wooden_door())

	# chairs and table facing the door.
	var x_table: int = (room.position.x + 2 if is_facing_east else room.end.x - 3)
	map.place_map_object_at(make_obj_table(GameImages.OBJ_TABLE), Vector2i(x_table, y_door))
	map.place_map_object_at(make_obj_chair(GameImages.OBJ_CHAIR), Vector2i(x_table - 1, y_door))
	map.place_map_object_at(make_obj_chair(GameImages.OBJ_CHAIR), Vector2i(x_table + 1, y_door))


func make_hospital_storage_room(map: Map, base_zone_name: String, room: Rect2i) -> void:
	tile_rectangle(map, game.game_tiles.wall_hospital(), room.position.x, room.position.y, room.size.x, room.size.y)
	map.add_zone(make_unique_zone(base_zone_name, room))

	# door.
	place_door(map, room.position.x + 2, room.position.y, game.game_tiles.floor_tiles(), make_obj_hospital_door())

	# shelves with meds or food.
	var storage_shelf_fn := func(pt):
		if !map.is_walkable_p(pt):
			return

		if count_adj_doors(map, pt.x, pt.y) > 0:
			return

		# shelf.
		map.place_map_object_at(make_obj_shelf(GameImages.OBJ_SHOP_SHELF), pt)

		# full stacks of meds or canned food.
		var it: Item = make_hospital_item() if _dice_roller.roll_chance(80) else make_item_canned_food()
		if it.model.is_stackable:
			it.quantity = it.model.stacking_limit
		map.drop_item_at(it, pt)
	do_for_each_tile(map, room, storage_shelf_fn)

	# alpha10
	# chance to spawn a nurse
	if _dice_roller.roll_chance(20):  # alpha10.1 increased to 20% (avg 5 nurses for 24 storage rooms)
		# NOTE: captured in a Dictionary because GDScript lambdas capture
		# locals by value, and the C# closure mutates spawnedActor.
		var spawn_state := {"spawned_actor": false}
		var nurse_fn := func(pt):
			if spawn_state.spawned_actor:
				return
			if !map.is_walkable_p(pt):
				return
			if map.get_map_object_at(pt) != null:
				return
			map.place_actor_at(create_new_hospital_nurse(0), pt)
			spawn_state.spawned_actor = true
		do_for_each_tile(map, room, nurse_fn)


# endregion
# endregion

# region Actors

func give_random_item_to_actor(roller: DiceRoller, actor: Actor, spawn_time: int) -> void:
	var it = null  # Item (untyped : can be null)

	# rare item chance after Day X
	var day: int = WorldTime.new(spawn_time).day
	if day > Rules.GIVE_RARE_ITEM_DAY && roller.roll_chance(Rules.GIVE_RARE_ITEM_CHANCE):
		var roll: int = roller.roll(0, 6)
		match roll:
			0:
				it = make_item_grenade()
			1:
				it = make_item_army_body_armor()
			2:
				it = make_item_heavy_pistol_ammo()
			3:
				it = make_item_heavy_rifle_ammo()
			4:
				it = make_item_pills_antiviral()
			5:
				it = make_item_combat_knife()
			_:
				it = null
	else:
		# standard item.
		var roll: int = roller.roll(0, 10)
		match roll:
			0:
				it = make_random_shop_item(ShopType.CONSTRUCTION)
			1:
				it = make_random_shop_item(ShopType.GENERAL_STORE)
			2:
				it = make_random_shop_item(ShopType.GROCERY)
			3:
				it = make_random_shop_item(ShopType.GUNSHOP)
			4:
				it = make_random_shop_item(ShopType.PHARMACY)
			5:
				it = make_random_shop_item(ShopType.SPORTSWEAR)
			6:
				it = make_random_shop_item(ShopType.HUNTING)
			7:
				it = make_random_park_item()
			8:
				it = make_random_bedroom_item()
			9:
				it = make_random_kitchen_item()
			_:
				it = null

	if it != null:
		actor.inventory.add_all(it)


func create_new_refugee(spawn_time: int, items_to_carry: int) -> Actor:
	var new_refugee: Actor

	# civilian, policeman?
	if _dice_roller.roll_chance(_params.policeman_chance):
		new_refugee = create_new_policeman(spawn_time)
		# add random items.
		var i: int = 0
		while i < items_to_carry && new_refugee.inventory.count_items < new_refugee.inventory.max_capacity:
			give_random_item_to_actor(_dice_roller, new_refugee, spawn_time)
			i += 1
	else:
		new_refugee = create_new_civilian(spawn_time, items_to_carry, 1)

	# give skills : 1 per day + 1 for starting.
	var nb_skills: int = 1 + WorldTime.new(spawn_time).day
	give_random_skills_to_actor(_dice_roller, new_refugee, nb_skills)

	# done.
	return new_refugee


func create_new_survivor(spawn_time: int) -> Actor:
	# decide model.
	var is_male: bool = rules.roll(0, 2) == 0
	var model: ActorModel = game.game_actors.male_civilian() if is_male else game.game_actors.female_civilian()

	# create.
	var survivor: Actor = model.create_numbered_name(game.game_factions.the_survivors(), spawn_time)

	# setup.
	give_name_to_actor(_dice_roller, survivor)
	dress_civilian(_dice_roller, survivor)
	survivor.doll.add_decoration(Doll.DollPart.HEAD, GameImages.SURVIVOR_MALE_BANDANA if is_male else GameImages.SURVIVOR_FEMALE_BANDANA)

	# give items, good survival gear (7 items).
	# 1,2   1 can of food, 1 amr.
	survivor.inventory.add_all(make_item_canned_food())
	survivor.inventory.add_all(make_item_army_ration())
	# 3,4. 1 fire weapon with 1 ammo box or grenade.
	if _dice_roller.roll_chance(50):
		survivor.inventory.add_all(make_item_army_rifle())
		if _dice_roller.roll_chance(50):
			survivor.inventory.add_all(make_item_heavy_rifle_ammo())
		else:
			survivor.inventory.add_all(make_item_grenade())
	else:
		survivor.inventory.add_all(make_item_shotgun())
		if _dice_roller.roll_chance(50):
			survivor.inventory.add_all(make_item_shotgun_ammo())
		else:
			survivor.inventory.add_all(make_item_grenade())
	# 5    1 healing item.
	survivor.inventory.add_all(make_item_medikit())

	# 6    1 pill item.
	match _dice_roller.roll(0, 3):
		0:
			survivor.inventory.add_all(make_item_pills_slp())
		1:
			survivor.inventory.add_all(make_item_pills_sta())
		2:
			survivor.inventory.add_all(make_item_pills_san())
	# 7    1 armor.
	survivor.inventory.add_all(make_item_army_body_armor())

	# give skills : 1 per day + 5 as bonus.
	var nb_skills: int = 3 + WorldTime.new(spawn_time).day
	give_random_skills_to_actor(_dice_roller, survivor, nb_skills)

	# AI.
	#survivor.Controller = new CivilianAI()  # alpha10.1 defined by model like other actors

	# slightly randomize Food and Sleep - 0..25%.
	var food_deviation: int = int(0.25 * survivor.food_points)
	survivor.food_points = survivor.food_points - rules.roll(0, food_deviation)
	var sleep_deviation: int = int(0.25 * survivor.sleep_points)
	survivor.sleep_points = survivor.sleep_points - rules.roll(0, sleep_deviation)

	# done.
	return survivor


func create_new_naked_human(spawn_time: int, _items_to_carry: int, _skills: int) -> Actor:
	# decide model.
	var model: ActorModel = game.game_actors.male_civilian() if rules.roll(0, 2) == 0 else game.game_actors.female_civilian()

	# create.
	var civilian: Actor = model.create_numbered_name(game.game_factions.the_civilians(), spawn_time)

	# done.
	return civilian


func create_new_civilian(spawn_time: int, items_to_carry: int, skills: int) -> Actor:
	# decide model.
	var model: ActorModel = game.game_actors.male_civilian() if rules.roll(0, 2) == 0 else game.game_actors.female_civilian()

	# create.
	var civilian: Actor = model.create_numbered_name(game.game_factions.the_civilians(), spawn_time)

	# setup.
	dress_civilian(_dice_roller, civilian)
	give_name_to_actor(_dice_roller, civilian)
	for i in items_to_carry:
		give_random_item_to_actor(_dice_roller, civilian, spawn_time)
	give_random_skills_to_actor(_dice_roller, civilian, skills)
	#civilian.Controller = new CivilianAI()  # alpha10.1 defined by model like other actors

	# slightly randomize Food and Sleep - 0..25%.
	var food_deviation: int = int(0.25 * civilian.food_points)
	civilian.food_points = civilian.food_points - rules.roll(0, food_deviation)
	var sleep_deviation: int = int(0.25 * civilian.sleep_points)
	civilian.sleep_points = civilian.sleep_points - rules.roll(0, sleep_deviation)

	# done.
	return civilian


func create_new_policeman(spawn_time: int) -> Actor:
	# model.
	var model: ActorModel = game.game_actors.policeman()

	# create.
	var new_cop: Actor = model.create_numbered_name(game.game_factions.the_police(), spawn_time)

	# setup.
	dress_police(_dice_roller, new_cop)
	give_name_to_actor(_dice_roller, new_cop)
	new_cop.name = "Cop " + new_cop.name
	give_random_skills_to_actor(_dice_roller, new_cop, 1)
	give_starting_skill_to_actor(new_cop, Skills.IDs.FIREARMS)
	give_starting_skill_to_actor(new_cop, Skills.IDs.LEADERSHIP)
	#newCop.Controller = new CivilianAI()  # alpha10.1 defined by model like other actors

	# give items.
	if _dice_roller.roll_chance(50):
		# pistol
		new_cop.inventory.add_all(make_item_pistol())
		new_cop.inventory.add_all(make_item_light_pistol_ammo())
	else:
		# shoty
		new_cop.inventory.add_all(make_item_shotgun())
		new_cop.inventory.add_all(make_item_shotgun_ammo())
	new_cop.inventory.add_all(make_item_truncheon())
	new_cop.inventory.add_all(make_item_flashlight())
	new_cop.inventory.add_all(make_item_police_radio())
	if _dice_roller.roll_chance(50):
		if _dice_roller.roll_chance(80):
			new_cop.inventory.add_all(make_item_police_jacket())
		else:
			new_cop.inventory.add_all(make_item_police_riot_armor())

	# done.
	return new_cop


func create_new_undead(spawn_time: int) -> Actor:
	var new_undead: Actor

	if Rules.has_all_zombies(game.session.game_mode):
		# decide model.
		var chance: int = rules.roll(0, 100)
		var undead_model: ActorModel
		if chance < RogueGame.options.spawn_skeleton_chance:
			undead_model = game.game_actors.skeleton()
		elif chance < RogueGame.options.spawn_skeleton_chance + RogueGame.options.spawn_zombie_chance:
			undead_model = game.game_actors.zombie()
		elif chance < RogueGame.options.spawn_skeleton_chance + RogueGame.options.spawn_zombie_chance + RogueGame.options.spawn_zombie_master_chance:
			undead_model = game.game_actors.zombie_master()
		else:
			undead_model = game.game_actors.skeleton()

		# create.
		new_undead = undead_model.create_numbered_name(game.game_factions.the_undeads(), spawn_time)
	else:
		# zombified.
		new_undead = make_zombified(null, create_new_civilian(spawn_time, 0, 0), spawn_time)
		# skills?
		var time := WorldTime.new(spawn_time)
		var nb_skills: int = time.day / 2
		if nb_skills > 0:
			for i in nb_skills:
				# C# Skills.IDs? (nullable) : parallel port may use null or a
				# negative sentinel for "none"; both handled here.
				var zombified_skill = game.zombify_skill(rules.roll(0, Skills.IDs._COUNT))
				if zombified_skill != null && zombified_skill >= 0:
					game.skill_upgrade(new_undead, zombified_skill)
			recompute_actor_starting_stats(new_undead)

	# done.
	return new_undead


func make_zombified(zombifier: Actor, dead_victim: Actor, turn: int) -> Actor:
	# create actor.
	var zombiefied_name: String = "%s's zombie" % dead_victim.unmodified_name
	var zombiefied_model: ActorModel = game.game_actors.male_zombified() if dead_victim.doll.body.is_male else game.game_actors.female_zombified()
	var zombie_faction: Faction = game.game_factions.the_undeads() if zombifier == null else zombifier.faction
	var new_zombie: Actor = zombiefied_model.create_named(zombie_faction, zombiefied_name, dead_victim.is_plural_name, turn)

	# dress as victim.
	for p in range(Doll.DollPart._FIRST, Doll.DollPart._COUNT):
		var part_decos = dead_victim.doll.get_decorations(p)
		if part_decos != null:
			for deco in part_decos:
				new_zombie.doll.add_decoration(p, deco)

	# add blood.
	new_zombie.doll.add_decoration(Doll.DollPart.TORSO, GameImages.BLOODIED)

	return new_zombie


func create_new_sewers_undead(spawn_time: int) -> Actor:
	if !Rules.has_all_zombies(game.session.game_mode):
		return create_new_undead(spawn_time)

	# decide model.
	var undead_model: ActorModel = game.game_actors.rat_zombie() if _dice_roller.roll_chance(80) else game.game_actors.zombie()

	# create.
	var new_undead: Actor = undead_model.create_numbered_name(game.game_factions.the_undeads(), spawn_time)

	# done.
	return new_undead


func create_new_basement_rat_zombie(spawn_time: int) -> Actor:
	if !Rules.has_all_zombies(game.session.game_mode):
		return create_new_undead(spawn_time)

	return game.game_actors.rat_zombie().create_numbered_name(game.game_factions.the_undeads(), spawn_time)


func create_new_subway_undead(spawn_time: int) -> Actor:
	if !Rules.has_all_zombies(game.session.game_mode):
		return create_new_undead(spawn_time)

	# standard zombies.
	var undead_model: ActorModel = game.game_actors.zombie()

	# create.
	var new_undead: Actor = undead_model.create_numbered_name(game.game_factions.the_undeads(), spawn_time)

	# done.
	return new_undead


func create_new_char_guard(spawn_time: int) -> Actor:
	# model.
	var model: ActorModel = game.game_actors.char_guard()

	# create.
	var new_guard: Actor = model.create_numbered_name(game.game_factions.the_char_corporation(), spawn_time)

	# setup.
	dress_char_guard(_dice_roller, new_guard)
	give_name_to_actor(_dice_roller, new_guard)
	new_guard.name = "Gd. " + new_guard.name

	# give items.
	new_guard.inventory.add_all(make_item_shotgun())
	new_guard.inventory.add_all(make_item_shotgun_ammo())
	new_guard.inventory.add_all(make_item_char_light_body_armor())

	# done.
	return new_guard


func create_new_army_national_guard(spawn_time: int, rank_name: String) -> Actor:
	# model.
	var model: ActorModel = game.game_actors.national_guard()

	# create.
	var new_nat: Actor = model.create_numbered_name(game.game_factions.the_army(), spawn_time)

	# setup.
	dress_army(_dice_roller, new_nat)
	give_name_to_actor(_dice_roller, new_nat)
	new_nat.name = rank_name + " " + new_nat.name

	# give items 6/7.
	new_nat.inventory.add_all(make_item_army_rifle())
	new_nat.inventory.add_all(make_item_heavy_rifle_ammo())
	new_nat.inventory.add_all(make_item_army_pistol())
	new_nat.inventory.add_all(make_item_heavy_pistol_ammo())
	new_nat.inventory.add_all(make_item_army_body_armor())
	var planks: ItemBarricadeMaterial = make_item_wooden_plank()
	planks.quantity = game.game_items.woodenplank().stacking_limit
	new_nat.inventory.add_all(planks)

	# skills : carpentry for building small barricades.
	# alpha10 and firearms
	give_starting_skill_to_actor(new_nat, Skills.IDs.CARPENTRY)
	give_starting_skill_to_actor(new_nat, Skills.IDs.FIREARMS)

	# give skills : 1 per day after min arrival date.
	var nb_skills: int = WorldTime.new(spawn_time).day - RogueGame.NATGUARD_DAY
	if nb_skills > 0:
		give_random_skills_to_actor(_dice_roller, new_nat, nb_skills)

	# done.
	return new_nat


func create_new_biker_man(spawn_time: int, gang_id: int) -> Actor:
	# decide model.
	var model: ActorModel = game.game_actors.biker_man()

	# create.
	var new_biker: Actor = model.create_numbered_name(game.game_factions.the_bikers(), spawn_time)

	# setup.
	new_biker.gang_id = gang_id
	dress_biker(_dice_roller, new_biker)
	give_name_to_actor(_dice_roller, new_biker)
	new_biker.controller = GangAI.new()

	# give items.
	new_biker.inventory.add_all(make_item_crowbar() if _dice_roller.roll_chance(50) else make_item_baseball_bat())
	new_biker.inventory.add_all(make_item_biker_gang_jacket(gang_id))

	# give skills : 1 per day after min arrival date.
	var nb_skills: int = WorldTime.new(spawn_time).day - RogueGame.BIKERS_RAID_DAY
	if nb_skills > 0:
		give_random_skills_to_actor(_dice_roller, new_biker, nb_skills)

	# done.
	return new_biker


func create_new_gangsta_man(spawn_time: int, gang_id: int) -> Actor:
	# decide model.
	var model: ActorModel = game.game_actors.gangsta_man()

	# create.
	var new_gangsta: Actor = model.create_numbered_name(game.game_factions.the_gangstas(), spawn_time)

	# setup.
	new_gangsta.gang_id = gang_id
	dress_gangsta(_dice_roller, new_gangsta)
	give_name_to_actor(_dice_roller, new_gangsta)
	new_gangsta.controller = GangAI.new()

	# give items.
	new_gangsta.inventory.add_all(make_item_random_pistol() if _dice_roller.roll_chance(50) else make_item_baseball_bat())

	# give skills : 1 per day after min arrival date.
	var nb_skills: int = WorldTime.new(spawn_time).day - RogueGame.GANGSTAS_RAID_DAY
	if nb_skills > 0:
		give_random_skills_to_actor(_dice_roller, new_gangsta, nb_skills)

	# done.
	return new_gangsta


func create_new_black_ops(spawn_time: int, rank_name: String) -> Actor:
	# model.
	var model: ActorModel = game.game_actors.black_ops()

	# create.
	var new_bo: Actor = model.create_numbered_name(game.game_factions.the_black_ops(), spawn_time)

	# setup.
	dress_black_ops(_dice_roller, new_bo)
	give_name_to_actor(_dice_roller, new_bo)
	new_bo.name = rank_name + " " + new_bo.name

	# give items.
	new_bo.inventory.add_all(make_item_precision_rifle())
	new_bo.inventory.add_all(make_item_heavy_rifle_ammo())
	new_bo.inventory.add_all(make_item_army_pistol())
	new_bo.inventory.add_all(make_item_heavy_pistol_ammo())
	new_bo.inventory.add_all(make_item_blackops_gps())

	# done.
	return new_bo


func create_new_feral_dog(spawn_time: int) -> Actor:
	var new_dog: Actor

	# model
	new_dog = game.game_actors.feral_dog().create_numbered_name(game.game_factions.the_ferals(), spawn_time)

	# skin
	skin_dog(_dice_roller, new_dog)

	# done.
	return new_dog
# endregion

# region Exits

## Add the Exit with the decoration.
func add_exit(from_map: Map, from_position: Vector2i, to_map: Map, to_position: Vector2i, exit_image_id: String, is_an_ai_exit: bool) -> void:
	var exit := Map.Exit.new(to_map, to_position)
	exit.is_an_ai_exit = is_an_ai_exit
	from_map.set_exit_at(from_position, exit)
	from_map.get_tile_at_p(from_position).add_decoration(exit_image_id)

# endregion

# region Zones
func make_walkway_zones(map: Map, b: Block) -> void:
	##
	##  NNNE
	##  W  E
	##  W  E
	##  WSSS
	##
	var r: Rect2i = b.rectangle

	# N
	map.add_zone(make_unique_zone("walkway", Rect2i(r.position.x, r.position.y, r.size.x - 1, 1)))
	# S
	map.add_zone(make_unique_zone("walkway", Rect2i(r.position.x + 1, r.end.y - 1, r.size.x - 1, 1)))
	# E
	map.add_zone(make_unique_zone("walkway", Rect2i(r.end.x - 1, r.position.y, 1, r.size.y - 1)))
	# W
	map.add_zone(make_unique_zone("walkway", Rect2i(r.position.x, r.position.y + 1, 1, r.size.y - 1)))
# endregion
