class_name GameImages
extends RefCounted
## Port of Gameplay/GameImages.cs
## Image ID constants + registrations of every game image.
##
## C# image IDs like @"Activities\chasing" are mapped to Godot resource paths
## "res://assets/Images/Activities/chasing.png" (same layout as the original
## compiled/Resources/Images tree). The constants below hold those res://
## paths directly, and register_image() loads the PNG at that path.

const GRAYLEVEL_DIM_FACTOR := 0.55

const IMAGES_ROOT := "res://assets/Images"


# region Images IDs

# region Icons
const ACTIVITY_CHASING := IMAGES_ROOT + "/Activities/chasing.png"
const ACTIVITY_CHASING_PLAYER := IMAGES_ROOT + "/Activities/chasing_player.png"
const ACTIVITY_TRACKING := IMAGES_ROOT + "/Activities/tracking.png"
const ACTIVITY_FLEEING := IMAGES_ROOT + "/Activities/fleeing.png"
const ACTIVITY_FLEEING_FROM_EXPLOSIVE := IMAGES_ROOT + "/Activities/fleeing_explosive.png"
const ACTIVITY_FOLLOWING := IMAGES_ROOT + "/Activities/following.png"
const ACTIVITY_FOLLOWING_ORDER := IMAGES_ROOT + "/Activities/following_order.png"
const ACTIVITY_FOLLOWING_PLAYER := IMAGES_ROOT + "/Activities/following_player.png"
const ACTIVITY_FOLLOWING_LEADER := IMAGES_ROOT + "/Activities/following_leader.png"  # alpha10
const ACTIVITY_SLEEPING := IMAGES_ROOT + "/Activities/sleeping.png"

const ICON_BLAST := IMAGES_ROOT + "/Icons/blast.png"
const ICON_CAN_TRADE := IMAGES_ROOT + "/Icons/can_trade.png"
const ICON_HAS_VITAL_ITEM := IMAGES_ROOT + "/Icons/has_vital_item.png"  # alpha10.1
const ICON_THREAT_SAFE := IMAGES_ROOT + "/Icons/threat_safe.png"
const ICON_THREAT_DANGER := IMAGES_ROOT + "/Icons/threat_danger.png"
const ICON_THREAT_HIGH_DANGER := IMAGES_ROOT + "/Icons/threat_high_danger.png"
const ICON_CANT_RUN := IMAGES_ROOT + "/Icons/cant_run.png"
const ICON_EXPIRED_FOOD := IMAGES_ROOT + "/Icons/expired_food.png"
const ICON_FOOD_ALMOST_HUNGRY := IMAGES_ROOT + "/Icons/food_almost_hungry.png"
const ICON_FOOD_HUNGRY := IMAGES_ROOT + "/Icons/food_hungry.png"
const ICON_FOOD_STARVING := IMAGES_ROOT + "/Icons/food_starving.png"
const ICON_HEALING := IMAGES_ROOT + "/Icons/healing.png"
const ICON_IS_TARGET := IMAGES_ROOT + "/Icons/is_target.png"
const ICON_IS_TARGETTED := IMAGES_ROOT + "/Icons/is_targetted.png"
const ICON_IS_TARGETING := IMAGES_ROOT + "/Icons/is_targeting.png"  # alpha10
const ICON_IS_IN_GROUP := IMAGES_ROOT + "/Icons/is_in_group.png"  # alpha10
const ICON_KILLED := IMAGES_ROOT + "/Icons/killed.png"
const ICON_LEADER := IMAGES_ROOT + "/Icons/leader.png"
const ICON_MELEE_ATTACK := IMAGES_ROOT + "/Icons/melee_attack.png"
const ICON_MELEE_MISS := IMAGES_ROOT + "/Icons/melee_miss.png"
const ICON_MELEE_DAMAGE := IMAGES_ROOT + "/Icons/melee_damage.png"
const ICON_ODOR_SUPPRESSED := IMAGES_ROOT + "/Icons/odor_suppressed.png"  # alpha10
const ICON_OUT_OF_AMMO := IMAGES_ROOT + "/Icons/out_of_ammo.png"
const ICON_OUT_OF_BATTERIES := IMAGES_ROOT + "/Icons/out_of_batteries.png"
const ICON_RANGED_ATTACK := IMAGES_ROOT + "/Icons/ranged_attack.png"
const ICON_RANGED_MISS := IMAGES_ROOT + "/Icons/ranged_miss.png"
const ICON_RANGED_DAMAGE := IMAGES_ROOT + "/Icons/ranged_damage.png"
const ICON_RUNNING := IMAGES_ROOT + "/Icons/running.png"
const ICON_ROT_ALMOST_HUNGRY := IMAGES_ROOT + "/Icons/rot_almost_hungry.png"
const ICON_ROT_HUNGRY := IMAGES_ROOT + "/Icons/rot_hungry.png"
const ICON_ROT_STARVING := IMAGES_ROOT + "/Icons/rot_starving.png"
const ICON_SLEEP_ALMOST_SLEEPY := IMAGES_ROOT + "/Icons/sleep_almost_sleepy.png"
const ICON_SLEEP_EXHAUSTED := IMAGES_ROOT + "/Icons/sleep_exhausted.png"
const ICON_SLEEP_SLEEPY := IMAGES_ROOT + "/Icons/sleep_sleepy.png"
const ICON_SPOILED_FOOD := IMAGES_ROOT + "/Icons/spoiled_food.png"
const ICON_TARGET := IMAGES_ROOT + "/Icons/target.png"
const ICON_LINE_BLOCKED := IMAGES_ROOT + "/Icons/line_blocked.png"
const ICON_LINE_CLEAR := IMAGES_ROOT + "/Icons/line_clear.png"
const ICON_LINE_BAD := IMAGES_ROOT + "/Icons/line_bad.png"
const ICON_SCENT_LIVING := IMAGES_ROOT + "/Icons/scent_living.png"
const ICON_SCENT_ZOMBIEMASTER := IMAGES_ROOT + "/Icons/scent_zm.png"
# alpha10 obsolete: ICON_SCENT_LIVING_SUPRESSOR
const ICON_AGGRESSOR := IMAGES_ROOT + "/Icons/enemy_you_aggressor.png"
const ICON_INDIRECT_ENEMIES := IMAGES_ROOT + "/Icons/enemy_indirect.png"
const ICON_SELF_DEFENCE := IMAGES_ROOT + "/Icons/enemy_you_self_defence.png"
const ICON_TRAP_ACTIVATED := IMAGES_ROOT + "/Icons/trap_activated.png"
const ICON_TRAP_ACTIVATED_SAFE_GROUP := IMAGES_ROOT + "/Icons/trap_activated_safe_group.png"  # alpha10
const ICON_TRAP_ACTIVATED_SAFE_PLAYER := IMAGES_ROOT + "/Icons/trap_activated_safe_player.png"  # alpha10
const ICON_TRAP_TRIGGERED := IMAGES_ROOT + "/Icons/trap_triggered.png"
const ICON_TRAP_TRIGGERED_SAFE_GROUP := IMAGES_ROOT + "/Icons/trap_triggered_safe_group.png"  # alpha10
const ICON_TRAP_TRIGGERED_SAFE_PLAYER := IMAGES_ROOT + "/Icons/trap_triggered_safe_player.png"  # alpha10
const ICON_SANITY_DISTURBED := IMAGES_ROOT + "/Icons/sanity_disturbed.png"
const ICON_SANITY_INSANE := IMAGES_ROOT + "/Icons/sanity_insane.png"
const ICON_BORING_ITEM := IMAGES_ROOT + "/Icons/boring_item.png"
const ICON_ZGRAB := IMAGES_ROOT + "/Icons/zgrab.png"  # alpha10

# endregion

# region Tiles
const TILE_FLOOR_ASPHALT := IMAGES_ROOT + "/Tiles/floor_asphalt.png"
const TILE_FLOOR_CONCRETE := IMAGES_ROOT + "/Tiles/floor_concrete.png"
const TILE_FLOOR_GRASS := IMAGES_ROOT + "/Tiles/floor_grass.png"
const TILE_FLOOR_OFFICE := IMAGES_ROOT + "/Tiles/floor_office.png"
const TILE_FLOOR_PLANKS := IMAGES_ROOT + "/Tiles/floor_planks.png"
const TILE_FLOOR_SEWER_WATER := IMAGES_ROOT + "/Tiles/floor_sewer_water.png"
const TILE_FLOOR_SEWER_WATER_ANIM1 := IMAGES_ROOT + "/Tiles/floor_sewer_water_anim1.png"
const TILE_FLOOR_SEWER_WATER_ANIM2 := IMAGES_ROOT + "/Tiles/floor_sewer_water_anim2.png"
const TILE_FLOOR_SEWER_WATER_ANIM3 := IMAGES_ROOT + "/Tiles/floor_sewer_water_anim3.png"
const TILE_FLOOR_SEWER_WATER_COVER := IMAGES_ROOT + "/Tiles/floor_sewer_water_cover.png"
const TILE_FLOOR_TILES := IMAGES_ROOT + "/Tiles/floor_tiles.png"
const TILE_FLOOR_WALKWAY := IMAGES_ROOT + "/Tiles/floor_walkway.png"

const TILE_ROAD_ASPHALT_NS := IMAGES_ROOT + "/Tiles/road_asphalt_ns.png"
const TILE_ROAD_ASPHALT_EW := IMAGES_ROOT + "/Tiles/road_asphalt_ew.png"
const TILE_RAIL_ES := IMAGES_ROOT + "/Tiles/rail_ew.png"

const TILE_WALL_BRICK := IMAGES_ROOT + "/Tiles/wall_brick.png"
const TILE_WALL_CHAR_OFFICE := IMAGES_ROOT + "/Tiles/wall_char_office.png"
const TILE_WALL_HOSPITAL := IMAGES_ROOT + "/Tiles/wall_hospital.png"
const TILE_WALL_SEWER := IMAGES_ROOT + "/Tiles/wall_sewer.png"
const TILE_WALL_STONE := IMAGES_ROOT + "/Tiles/wall_stone.png"
# endregion

# region Tile decorations
const DECO_BLOODIED_FLOOR := IMAGES_ROOT + "/Tiles/Decoration/bloodied_floor.png"
const DECO_BLOODIED_WALL := IMAGES_ROOT + "/Tiles/Decoration/bloodied_wall.png"
const DECO_ZOMBIE_REMAINS := IMAGES_ROOT + "/Tiles/Decoration/zombie_remains.png"
const DECO_VOMIT := IMAGES_ROOT + "/Tiles/Decoration/vomit.png"

const DECO_POSTERS1 := IMAGES_ROOT + "/Tiles/Decoration/posters1.png"
const DECO_POSTERS2 := IMAGES_ROOT + "/Tiles/Decoration/posters2.png"
const DECO_TAGS1 := IMAGES_ROOT + "/Tiles/Decoration/tags1.png"
const DECO_TAGS2 := IMAGES_ROOT + "/Tiles/Decoration/tags2.png"
const DECO_TAGS3 := IMAGES_ROOT + "/Tiles/Decoration/tags3.png"
const DECO_TAGS4 := IMAGES_ROOT + "/Tiles/Decoration/tags4.png"
const DECO_TAGS5 := IMAGES_ROOT + "/Tiles/Decoration/tags5.png"
const DECO_TAGS6 := IMAGES_ROOT + "/Tiles/Decoration/tags6.png"
const DECO_TAGS7 := IMAGES_ROOT + "/Tiles/Decoration/tags7.png"

const DECO_SHOP_CONSTRUCTION := IMAGES_ROOT + "/Tiles/Decoration/shop_construction.png"
const DECO_SHOP_GENERAL_STORE := IMAGES_ROOT + "/Tiles/Decoration/shop_general_store.png"
const DECO_SHOP_GROCERY := IMAGES_ROOT + "/Tiles/Decoration/shop_grocery.png"
const DECO_SHOP_GUNSHOP := IMAGES_ROOT + "/Tiles/Decoration/shop_gunshop.png"
const DECO_SHOP_PHARMACY := IMAGES_ROOT + "/Tiles/Decoration/shop_pharmacy.png"
const DECO_SHOP_SPORTSWEAR := IMAGES_ROOT + "/Tiles/Decoration/shop_sportswear.png"
const DECO_SHOP_HUNTING := IMAGES_ROOT + "/Tiles/Decoration/shop_hunting.png"

const DECO_CHAR_OFFICE := IMAGES_ROOT + "/Tiles/Decoration/char_office.png"
const DECO_CHAR_FLOOR_LOGO := IMAGES_ROOT + "/Tiles/Decoration/char_floor_logo.png"
const DECO_CHAR_POSTER1 := IMAGES_ROOT + "/Tiles/Decoration/char_poster1.png"
const DECO_CHAR_POSTER2 := IMAGES_ROOT + "/Tiles/Decoration/char_poster2.png"
const DECO_CHAR_POSTER3 := IMAGES_ROOT + "/Tiles/Decoration/char_poster3.png"

const DECO_PLAYER_TAG1 := IMAGES_ROOT + "/Tiles/Decoration/player_tag.png"
const DECO_PLAYER_TAG2 := IMAGES_ROOT + "/Tiles/Decoration/player_tag2.png"
const DECO_PLAYER_TAG3 := IMAGES_ROOT + "/Tiles/Decoration/player_tag3.png"
const DECO_PLAYER_TAG4 := IMAGES_ROOT + "/Tiles/Decoration/player_tag4.png"

const DECO_ROGUEDJACK_TAG := IMAGES_ROOT + "/Tiles/Decoration/roguedjack.png"

const DECO_SEWER_LADDER := IMAGES_ROOT + "/Tiles/Decoration/sewer_ladder.png"
const DECO_SEWER_HOLE := IMAGES_ROOT + "/Tiles/Decoration/sewer_hole.png"
const DECO_SEWERS_BUILDING := IMAGES_ROOT + "/Tiles/Decoration/sewers_building.png"

const DECO_SUBWAY_BUILDING := IMAGES_ROOT + "/Tiles/Decoration/subway_building.png"

const DECO_STAIRS_UP := IMAGES_ROOT + "/Tiles/Decoration/stairs_up.png"
const DECO_STAIRS_DOWN := IMAGES_ROOT + "/Tiles/Decoration/stairs_down.png"

const DECO_POWER_SIGN_BIG := IMAGES_ROOT + "/Tiles/Decoration/power_sign_big.png"

const DECO_POLICE_STATION := IMAGES_ROOT + "/Tiles/Decoration/police_station.png"

const DECO_HOSPITAL := IMAGES_ROOT + "/Tiles/Decoration/hospital.png"
# endregion

# region Map objects
const OBJ_TREE := IMAGES_ROOT + "/MapObjects/tree.png"

const OBJ_WOODEN_DOOR_CLOSED := IMAGES_ROOT + "/MapObjects/wooden_door_closed.png"
const OBJ_WOODEN_DOOR_OPEN := IMAGES_ROOT + "/MapObjects/wooden_door_open.png"
const OBJ_WOODEN_DOOR_BROKEN := IMAGES_ROOT + "/MapObjects/wooden_door_broken.png"

const OBJ_GLASS_DOOR_CLOSED := IMAGES_ROOT + "/MapObjects/glass_door_closed.png"
const OBJ_GLASS_DOOR_OPEN := IMAGES_ROOT + "/MapObjects/glass_door_open.png"
const OBJ_GLASS_DOOR_BROKEN := IMAGES_ROOT + "/MapObjects/glass_door_broken.png"

const OBJ_CHAR_DOOR_CLOSED := IMAGES_ROOT + "/MapObjects/dark_door_closed.png"
const OBJ_CHAR_DOOR_OPEN := IMAGES_ROOT + "/MapObjects/dark_door_open.png"
const OBJ_CHAR_DOOR_BROKEN := IMAGES_ROOT + "/MapObjects/dark_door_broken.png"

const OBJ_WINDOW_CLOSED := IMAGES_ROOT + "/MapObjects/window_closed.png"
const OBJ_WINDOW_OPEN := IMAGES_ROOT + "/MapObjects/window_open.png"
const OBJ_WINDOW_BROKEN := IMAGES_ROOT + "/MapObjects/window_broken.png"

const OBJ_BENCH := IMAGES_ROOT + "/MapObjects/bench.png"
const OBJ_FENCE := IMAGES_ROOT + "/MapObjects/fence.png"

const OBJ_CAR1 := IMAGES_ROOT + "/MapObjects/car1.png"
const OBJ_CAR2 := IMAGES_ROOT + "/MapObjects/car2.png"
const OBJ_CAR3 := IMAGES_ROOT + "/MapObjects/car3.png"
const OBJ_CAR4 := IMAGES_ROOT + "/MapObjects/car4.png"

const OBJ_SHOP_SHELF := IMAGES_ROOT + "/MapObjects/shop_shelf.png"
const OBJ_BED := IMAGES_ROOT + "/MapObjects/bed.png"
const OBJ_WARDROBE := IMAGES_ROOT + "/MapObjects/wardrobe.png"
const OBJ_TABLE := IMAGES_ROOT + "/MapObjects/table.png"
const OBJ_FRIDGE := IMAGES_ROOT + "/MapObjects/fridge.png"
const OBJ_DRAWER := IMAGES_ROOT + "/MapObjects/drawer.png"
const OBJ_CHAIR := IMAGES_ROOT + "/MapObjects/chair.png"
const OBJ_NIGHT_TABLE := IMAGES_ROOT + "/MapObjects/nighttable.png"
const OBJ_CHAR_CHAIR := IMAGES_ROOT + "/MapObjects/char_chair.png"
const OBJ_CHAR_TABLE := IMAGES_ROOT + "/MapObjects/char_table.png"

const OBJ_IRON_BENCH := IMAGES_ROOT + "/MapObjects/iron_bench.png"
const OBJ_IRON_DOOR_OPEN := IMAGES_ROOT + "/MapObjects/iron_door_open.png"
const OBJ_IRON_DOOR_CLOSED := IMAGES_ROOT + "/MapObjects/iron_door_closed.png"
const OBJ_IRON_DOOR_BROKEN := IMAGES_ROOT + "/MapObjects/iron_door_broken.png"
const OBJ_IRON_FENCE := IMAGES_ROOT + "/MapObjects/iron_fence.png"

const OBJ_BARRELS := IMAGES_ROOT + "/MapObjects/barrels.png"
const OBJ_JUNK := IMAGES_ROOT + "/MapObjects/junk.png"

const OBJ_POWERGEN_OFF := IMAGES_ROOT + "/MapObjects/power_generator_off.png"
const OBJ_POWERGEN_ON := IMAGES_ROOT + "/MapObjects/power_generator_on.png"

const OBJ_GATE_CLOSED := IMAGES_ROOT + "/MapObjects/gate_closed.png"
const OBJ_GATE_OPEN := IMAGES_ROOT + "/MapObjects/gate_open.png"

const OBJ_BOARD := IMAGES_ROOT + "/MapObjects/announcement_board.png"

const OBJ_SMALL_WOODEN_FORTIFICATION := IMAGES_ROOT + "/MapObjects/wooden_small_fortification.png"
const OBJ_LARGE_WOODEN_FORTIFICATION := IMAGES_ROOT + "/MapObjects/wooden_large_fortification.png"

const OBJ_HOSPITAL_BED := IMAGES_ROOT + "/MapObjects/hospital_bed.png"
const OBJ_HOSPITAL_CHAIR := IMAGES_ROOT + "/MapObjects/hospital_chair.png"
const OBJ_HOSPITAL_NIGHT_TABLE := IMAGES_ROOT + "/MapObjects/hospital_nighttable.png"
const OBJ_HOSPITAL_WARDROBE := IMAGES_ROOT + "/MapObjects/hospital_wardrobe.png"
const OBJ_HOSPITAL_DOOR_OPEN := IMAGES_ROOT + "/MapObjects/hospital_door_open.png"
const OBJ_HOSPITAL_DOOR_CLOSED := IMAGES_ROOT + "/MapObjects/hospital_door_closed.png"
const OBJ_HOSPITAL_DOOR_BROKEN := IMAGES_ROOT + "/MapObjects/hospital_door_broken.png"

# alpha10
const OBJ_GARDEN_FENCE := IMAGES_ROOT + "/MapObjects/garden_fence.png"
const OBJ_WIRE_FENCE := IMAGES_ROOT + "/MapObjects/wire_fence.png"
# endregion

# region Actors
const PLAYER_FOLLOWER := IMAGES_ROOT + "/Actors/player_follower.png"
const PLAYER_FOLLOWER_TRUST := IMAGES_ROOT + "/Actors/player_follower_trust.png"
const PLAYER_FOLLOWER_BOND := IMAGES_ROOT + "/Actors/player_follower_bond.png"

const ACTOR_SKELETON := IMAGES_ROOT + "/Actors/skeleton.png"
const ACTOR_RED_EYED_SKELETON := IMAGES_ROOT + "/Actors/red_eyed_skeleton.png"
const ACTOR_RED_SKELETON := IMAGES_ROOT + "/Actors/red_skeleton.png"
const ACTOR_ZOMBIE := IMAGES_ROOT + "/Actors/zombie.png"
const ACTOR_DARK_EYED_ZOMBIE := IMAGES_ROOT + "/Actors/dark_eyed_zombie.png"
const ACTOR_DARK_ZOMBIE := IMAGES_ROOT + "/Actors/dark_zombie.png"
const ACTOR_MALE_NEOPHYTE := IMAGES_ROOT + "/Actors/male_neophyte.png"
const ACTOR_FEMALE_NEOPHYTE := IMAGES_ROOT + "/Actors/female_neophyte.png"
const ACTOR_MALE_DISCIPLE := IMAGES_ROOT + "/Actors/male_disciple.png"
const ACTOR_FEMALE_DISCIPLE := IMAGES_ROOT + "/Actors/female_disciple.png"
const ACTOR_ZOMBIE_MASTER := IMAGES_ROOT + "/Actors/zombie_master.png"
const ACTOR_ZOMBIE_LORD := IMAGES_ROOT + "/Actors/zombie_lord.png"
const ACTOR_ZOMBIE_PRINCE := IMAGES_ROOT + "/Actors/zombie_prince.png"
const ACTOR_RAT_ZOMBIE := IMAGES_ROOT + "/Actors/rat_zombie.png"
const ACTOR_SEWERS_THING := IMAGES_ROOT + "/Actors/sewers_thing.png"
const ACTOR_JASON_MYERS := IMAGES_ROOT + "/Actors/jason_myers.png"
const ACTOR_BIG_BEAR := IMAGES_ROOT + "/Actors/big_bear.png"
const ACTOR_FAMU_FATARU := IMAGES_ROOT + "/Actors/famu_fataru.png"
const ACTOR_SANTAMAN := IMAGES_ROOT + "/Actors/santaman.png"
const ACTOR_ROGUEDJACK := IMAGES_ROOT + "/Actors/roguedjack.png"
const ACTOR_DUCKMAN := IMAGES_ROOT + "/Actors/duckman.png"
const ACTOR_HANS_VON_HANZ := IMAGES_ROOT + "/Actors/hans_von_hanz.png"
# endregion

# region Actor decorations
const BLOODIED := IMAGES_ROOT + "/Actors/Decoration/bloodied.png"

const MALE_SKIN1 := IMAGES_ROOT + "/Actors/Decoration/male_skin1.png"
const MALE_SKIN2 := IMAGES_ROOT + "/Actors/Decoration/male_skin2.png"
const MALE_SKIN3 := IMAGES_ROOT + "/Actors/Decoration/male_skin3.png"
const MALE_SKIN4 := IMAGES_ROOT + "/Actors/Decoration/male_skin4.png"
const MALE_SKIN5 := IMAGES_ROOT + "/Actors/Decoration/male_skin5.png"
const MALE_HAIR1 := IMAGES_ROOT + "/Actors/Decoration/male_hair1.png"
const MALE_HAIR2 := IMAGES_ROOT + "/Actors/Decoration/male_hair2.png"
const MALE_HAIR3 := IMAGES_ROOT + "/Actors/Decoration/male_hair3.png"
const MALE_HAIR4 := IMAGES_ROOT + "/Actors/Decoration/male_hair4.png"
const MALE_HAIR5 := IMAGES_ROOT + "/Actors/Decoration/male_hair5.png"
const MALE_HAIR6 := IMAGES_ROOT + "/Actors/Decoration/male_hair6.png"
const MALE_HAIR7 := IMAGES_ROOT + "/Actors/Decoration/male_hair7.png"
const MALE_HAIR8 := IMAGES_ROOT + "/Actors/Decoration/male_hair8.png"
const MALE_SHIRT1 := IMAGES_ROOT + "/Actors/Decoration/male_shirt1.png"
const MALE_SHIRT2 := IMAGES_ROOT + "/Actors/Decoration/male_shirt2.png"
const MALE_SHIRT3 := IMAGES_ROOT + "/Actors/Decoration/male_shirt3.png"
const MALE_SHIRT4 := IMAGES_ROOT + "/Actors/Decoration/male_shirt4.png"
const MALE_SHIRT5 := IMAGES_ROOT + "/Actors/Decoration/male_shirt5.png"
const MALE_PANTS1 := IMAGES_ROOT + "/Actors/Decoration/male_pants1.png"
const MALE_PANTS2 := IMAGES_ROOT + "/Actors/Decoration/male_pants2.png"
const MALE_PANTS3 := IMAGES_ROOT + "/Actors/Decoration/male_pants3.png"
const MALE_PANTS4 := IMAGES_ROOT + "/Actors/Decoration/male_pants4.png"
const MALE_PANTS5 := IMAGES_ROOT + "/Actors/Decoration/male_pants5.png"
const MALE_SHOES1 := IMAGES_ROOT + "/Actors/Decoration/male_shoes1.png"
const MALE_SHOES2 := IMAGES_ROOT + "/Actors/Decoration/male_shoes2.png"
const MALE_SHOES3 := IMAGES_ROOT + "/Actors/Decoration/male_shoes3.png"
const MALE_EYES1 := IMAGES_ROOT + "/Actors/Decoration/male_eyes1.png"
const MALE_EYES2 := IMAGES_ROOT + "/Actors/Decoration/male_eyes2.png"
const MALE_EYES3 := IMAGES_ROOT + "/Actors/Decoration/male_eyes3.png"
const MALE_EYES4 := IMAGES_ROOT + "/Actors/Decoration/male_eyes4.png"
const MALE_EYES5 := IMAGES_ROOT + "/Actors/Decoration/male_eyes5.png"
const MALE_EYES6 := IMAGES_ROOT + "/Actors/Decoration/male_eyes6.png"

const FEMALE_SKIN1 := IMAGES_ROOT + "/Actors/Decoration/female_skin1.png"
const FEMALE_SKIN2 := IMAGES_ROOT + "/Actors/Decoration/female_skin2.png"
const FEMALE_SKIN3 := IMAGES_ROOT + "/Actors/Decoration/female_skin3.png"
const FEMALE_SKIN4 := IMAGES_ROOT + "/Actors/Decoration/female_skin4.png"
const FEMALE_SKIN5 := IMAGES_ROOT + "/Actors/Decoration/female_skin5.png"
const FEMALE_HAIR1 := IMAGES_ROOT + "/Actors/Decoration/female_hair1.png"
const FEMALE_HAIR2 := IMAGES_ROOT + "/Actors/Decoration/female_hair2.png"
const FEMALE_HAIR3 := IMAGES_ROOT + "/Actors/Decoration/female_hair3.png"
const FEMALE_HAIR4 := IMAGES_ROOT + "/Actors/Decoration/female_hair4.png"
const FEMALE_HAIR5 := IMAGES_ROOT + "/Actors/Decoration/female_hair5.png"
const FEMALE_HAIR6 := IMAGES_ROOT + "/Actors/Decoration/female_hair6.png"
const FEMALE_HAIR7 := IMAGES_ROOT + "/Actors/Decoration/female_hair7.png"
const FEMALE_SHIRT1 := IMAGES_ROOT + "/Actors/Decoration/female_shirt1.png"
const FEMALE_SHIRT2 := IMAGES_ROOT + "/Actors/Decoration/female_shirt2.png"
const FEMALE_SHIRT3 := IMAGES_ROOT + "/Actors/Decoration/female_shirt3.png"
const FEMALE_SHIRT4 := IMAGES_ROOT + "/Actors/Decoration/female_shirt4.png"
const FEMALE_PANTS1 := IMAGES_ROOT + "/Actors/Decoration/female_pants1.png"
const FEMALE_PANTS2 := IMAGES_ROOT + "/Actors/Decoration/female_pants2.png"
const FEMALE_PANTS3 := IMAGES_ROOT + "/Actors/Decoration/female_pants3.png"
const FEMALE_PANTS4 := IMAGES_ROOT + "/Actors/Decoration/female_pants4.png"
const FEMALE_PANTS5 := IMAGES_ROOT + "/Actors/Decoration/female_pants5.png"
const FEMALE_SHOES1 := IMAGES_ROOT + "/Actors/Decoration/female_shoes1.png"
const FEMALE_SHOES2 := IMAGES_ROOT + "/Actors/Decoration/female_shoes2.png"
const FEMALE_SHOES3 := IMAGES_ROOT + "/Actors/Decoration/female_shoes3.png"
const FEMALE_EYES1 := IMAGES_ROOT + "/Actors/Decoration/female_eyes1.png"
const FEMALE_EYES2 := IMAGES_ROOT + "/Actors/Decoration/female_eyes2.png"
const FEMALE_EYES3 := IMAGES_ROOT + "/Actors/Decoration/female_eyes3.png"
const FEMALE_EYES4 := IMAGES_ROOT + "/Actors/Decoration/female_eyes4.png"
const FEMALE_EYES5 := IMAGES_ROOT + "/Actors/Decoration/female_eyes5.png"
const FEMALE_EYES6 := IMAGES_ROOT + "/Actors/Decoration/female_eyes6.png"

const ARMY_HELMET := IMAGES_ROOT + "/Actors/Decoration/army_helmet.png"
const ARMY_PANTS := IMAGES_ROOT + "/Actors/Decoration/army_pants.png"
const ARMY_SHIRT := IMAGES_ROOT + "/Actors/Decoration/army_shirt.png"
const ARMY_SHOES := IMAGES_ROOT + "/Actors/Decoration/army_shoes.png"

const BIKER_HAIR1 := IMAGES_ROOT + "/Actors/Decoration/biker_hair1.png"
const BIKER_HAIR2 := IMAGES_ROOT + "/Actors/Decoration/biker_hair2.png"
const BIKER_HAIR3 := IMAGES_ROOT + "/Actors/Decoration/biker_hair3.png"
const BIKER_PANTS := IMAGES_ROOT + "/Actors/Decoration/biker_pants.png"
const BIKER_SHOES := IMAGES_ROOT + "/Actors/Decoration/biker_shoes.png"

const GANGSTA_HAT := IMAGES_ROOT + "/Actors/Decoration/gangsta_hat.png"
const GANGSTA_PANTS := IMAGES_ROOT + "/Actors/Decoration/gangsta_pants.png"
const GANGSTA_SHIRT := IMAGES_ROOT + "/Actors/Decoration/gangsta_shirt.png"

const CHARGUARD_HAIR := IMAGES_ROOT + "/Actors/Decoration/charguard_hair.png"
const CHARGUARD_PANTS := IMAGES_ROOT + "/Actors/Decoration/charguard_pants.png"

const POLICE_HAT := IMAGES_ROOT + "/Actors/Decoration/police_hat.png"
const POLICE_UNIFORM := IMAGES_ROOT + "/Actors/Decoration/police_uniform.png"
const POLICE_PANTS := IMAGES_ROOT + "/Actors/Decoration/police_pants.png"
const POLICE_SHOES := IMAGES_ROOT + "/Actors/Decoration/police_shoes.png"

const BLACKOP_SUIT := IMAGES_ROOT + "/Actors/Decoration/blackop_suit.png"

const HOSPITAL_DOCTOR_UNIFORM := IMAGES_ROOT + "/Actors/Decoration/hospital_doctor_uniform.png"
const HOSPITAL_NURSE_UNIFORM := IMAGES_ROOT + "/Actors/Decoration/hospital_nurse_uniform.png"
const HOSPITAL_PATIENT_UNIFORM := IMAGES_ROOT + "/Actors/Decoration/hospital_patient_uniform.png"

const SURVIVOR_MALE_BANDANA := IMAGES_ROOT + "/Actors/Decoration/survivor_male_bandana.png"
const SURVIVOR_FEMALE_BANDANA := IMAGES_ROOT + "/Actors/Decoration/survivor_female_bandana.png"

const DOG_SKIN1 := IMAGES_ROOT + "/Actors/Decoration/dog_skin1.png"
const DOG_SKIN2 := IMAGES_ROOT + "/Actors/Decoration/dog_skin2.png"
const DOG_SKIN3 := IMAGES_ROOT + "/Actors/Decoration/dog_skin3.png"
# endregion

# region Items
const ITEM_SLOT := IMAGES_ROOT + "/Items/itemslot.png"
const ITEM_EQUIPPED := IMAGES_ROOT + "/Items/itemequipped.png"

const ITEM_AMMO_LIGHT_PISTOL := IMAGES_ROOT + "/Items/item_ammo_light_pistol.png"
const ITEM_AMMO_HEAVY_PISTOL := IMAGES_ROOT + "/Items/item_ammo_heavy_pistol.png"
const ITEM_AMMO_LIGHT_RIFLE := IMAGES_ROOT + "/Items/item_ammo_light_rifle.png"
const ITEM_AMMO_HEAVY_RIFLE := IMAGES_ROOT + "/Items/item_ammo_heavy_rifle.png"
const ITEM_AMMO_SHOTGUN := IMAGES_ROOT + "/Items/item_ammo_shotgun.png"
const ITEM_AMMO_BOLTS := IMAGES_ROOT + "/Items/item_ammo_bolts.png"

const ITEM_ARMY_BODYARMOR := IMAGES_ROOT + "/Items/item_army_bodyarmor.png"
const ITEM_ARMY_PISTOL := IMAGES_ROOT + "/Items/item_army_pistol.png"
const ITEM_ARMY_RATION := IMAGES_ROOT + "/Items/item_army_ration.png"
const ITEM_ARMY_RIFLE := IMAGES_ROOT + "/Items/item_army_rifle.png"
const ITEM_BANDAGES := IMAGES_ROOT + "/Items/item_bandages.png"
const ITEM_BARBED_WIRE := IMAGES_ROOT + "/Items/item_barbed_wire.png"
const ITEM_BEAR_TRAP := IMAGES_ROOT + "/Items/item_bear_trap.png"
const ITEM_BASEBALL_BAT := IMAGES_ROOT + "/Items/item_baseballbat.png"
const ITEM_BIGBEAR_BAT := IMAGES_ROOT + "/Items/item_bigbear_bat.png"
const ITEM_BIG_FLASHLIGHT := IMAGES_ROOT + "/Items/item_big_flashlight.png"
const ITEM_BIG_FLASHLIGHT_OUT := IMAGES_ROOT + "/Items/item_big_flashlight_out.png"
const ITEM_BOOK := IMAGES_ROOT + "/Items/item_book.png"
const ITEM_BLACKOPS_GPS := IMAGES_ROOT + "/Items/item_blackops_gps.png"
const ITEM_CANNED_FOOD := IMAGES_ROOT + "/Items/item_canned_food.png"
const ITEM_CELL_PHONE := IMAGES_ROOT + "/Items/item_cellphone.png"
const ITEM_CHAR_LIGHT_BODYARMOR := IMAGES_ROOT + "/Items/item_CHAR_light_bodyarmor.png"
const ITEM_CROWBAR := IMAGES_ROOT + "/Items/item_crowbar.png"
const ITEM_COMBAT_KNIFE := IMAGES_ROOT + "/Items/item_combat_knife.png"
const ITEM_EMPTY_CAN := IMAGES_ROOT + "/Items/item_empty_can.png"
const ITEM_FAMU_FATARU_KATANA := IMAGES_ROOT + "/Items/item_famu_fataru_katana.png"
const ITEM_FLASHLIGHT := IMAGES_ROOT + "/Items/item_flashlight.png"
const ITEM_FLASHLIGHT_OUT := IMAGES_ROOT + "/Items/item_flashlight_out.png"
const ITEM_FREE_ANGELS_JACKET := IMAGES_ROOT + "/Items/item_free_angels_jacket.png"
const ITEM_GRENADE := IMAGES_ROOT + "/Items/item_grenade.png"
const ITEM_GRENADE_PRIMED := IMAGES_ROOT + "/Items/item_grenade_primed.png"
const ITEM_JASON_MYERS_AXE := IMAGES_ROOT + "/Items/item_jason_myers_axe.png"
const ITEM_GOLF_CLUB := IMAGES_ROOT + "/Items/item_golfclub.png"
const ITEM_GROCERIES := IMAGES_ROOT + "/Items/item_groceries.png"
const ITEM_HANS_VON_HANZ_PISTOL := IMAGES_ROOT + "/Items/item_hans_von_hanz_pistol.png"
const ITEM_HELLS_SOULS_JACKET := IMAGES_ROOT + "/Items/item_hells_souls_jacket.png"
const ITEM_HUGE_HAMMER := IMAGES_ROOT + "/Items/item_huge_hammer.png"
const ITEM_HUNTER_VEST := IMAGES_ROOT + "/Items/item_hunter_vest.png"
const ITEM_HUNTING_CROSSBOW := IMAGES_ROOT + "/Items/item_hunting_crossbow.png"
const ITEM_HUNTING_RIFLE := IMAGES_ROOT + "/Items/item_hunting_rifle.png"
const ITEM_IMPROVISED_CLUB := IMAGES_ROOT + "/Items/item_improvised_club.png"
const ITEM_IMPROVISED_SPEAR := IMAGES_ROOT + "/Items/item_improvised_spear.png"
const ITEM_IRON_GOLF_CLUB := IMAGES_ROOT + "/Items/item_iron_golfclub.png"
const ITEM_KOLT_REVOLVER := IMAGES_ROOT + "/Items/item_kolt_revolver.png"
const ITEM_MAGAZINE := IMAGES_ROOT + "/Items/item_magazine.png"
const ITEM_MEDIKIT := IMAGES_ROOT + "/Items/item_medikit.png"
const ITEM_PISTOL := IMAGES_ROOT + "/Items/item_pistol.png"
const ITEM_PILLS_ANTIVIRAL := IMAGES_ROOT + "/Items/item_pills_antiviral.png"
const ITEM_PILLS_BLUE := IMAGES_ROOT + "/Items/item_pills_blue.png"
const ITEM_PILLS_GREEN := IMAGES_ROOT + "/Items/item_pills_green.png"
const ITEM_PILLS_SAN := IMAGES_ROOT + "/Items/item_pills_san.png"
const ITEM_POLICE_JACKET := IMAGES_ROOT + "/Items/item_police_jacket.png"
const ITEM_POLICE_RADIO := IMAGES_ROOT + "/Items/item_police_radio.png"
const ITEM_POLICE_RIOT_ARMOR := IMAGES_ROOT + "/Items/item_police_riot_armor.png"
const ITEM_PRECISION_RIFLE := IMAGES_ROOT + "/Items/item_precision_rifle.png"
const ITEM_ROGUEDJACK_KEYBOARD := IMAGES_ROOT + "/Items/item_roguedjack_keyboard.png"
const ITEM_SANTAMAN_SHOTGUN := IMAGES_ROOT + "/Items/item_santaman_shotgun.png"
const ITEM_SHOTGUN := IMAGES_ROOT + "/Items/item_shotgun.png"
const ITEM_SHOVEL := IMAGES_ROOT + "/Items/item_shovel.png"
const ITEM_SMALL_HAMMER := IMAGES_ROOT + "/Items/item_small_hammer.png"
const ITEM_SPIKES := IMAGES_ROOT + "/Items/item_spikes.png"
const ITEM_SHORT_SHOVEL := IMAGES_ROOT + "/Items/item_short_shovel.png"
const ITEM_SPRAYPAINT := IMAGES_ROOT + "/Items/item_spraypaint.png"
const ITEM_SPRAYPAINT2 := IMAGES_ROOT + "/Items/item_spraypaint2.png"
const ITEM_SPRAYPAINT3 := IMAGES_ROOT + "/Items/item_spraypaint3.png"
const ITEM_SPRAYPAINT4 := IMAGES_ROOT + "/Items/item_spraypaint4.png"
const ITEM_STENCH_KILLER := IMAGES_ROOT + "/Items/item_stench_killer.png"
const ITEM_SUBWAY_BADGE := IMAGES_ROOT + "/Items/item_subway_badge.png"
const ITEM_TRUNCHEON := IMAGES_ROOT + "/Items/item_truncheon.png"
const ITEM_WOODEN_PLANK := IMAGES_ROOT + "/Items/item_wooden_plank.png"
const ITEM_ZTRACKER := IMAGES_ROOT + "/Items/item_ztracker.png"
# endregion

# region Effects
const EFFECT_BARRICADED := IMAGES_ROOT + "/Effects/barricaded.png"
const EFFECT_ONFIRE := IMAGES_ROOT + "/Effects/onFire.png"
# endregion

# region Misc
# Note: unlike the C# (which loads these with a path relative to Resources\),
# the misc images live in the root of the Images folder here.
const UNDEF := IMAGES_ROOT + "/undef.png"
const MAP_EXIT := IMAGES_ROOT + "/map_exit.png"
const MINI_PLAYER_POSITION := IMAGES_ROOT + "/mini_player_position.png"
const MINI_PLAYER_TAG1 := IMAGES_ROOT + "/mini_player_tag.png"
const MINI_PLAYER_TAG2 := IMAGES_ROOT + "/mini_player_tag2.png"
const MINI_PLAYER_TAG3 := IMAGES_ROOT + "/mini_player_tag3.png"
const MINI_PLAYER_TAG4 := IMAGES_ROOT + "/mini_player_tag4.png"
const MINI_FOLLOWER_POSITION := IMAGES_ROOT + "/mini_follower_position.png"
const MINI_UNDEAD_POSITION := IMAGES_ROOT + "/mini_undead_position.png"
const MINI_BLACKOPS_POSITION := IMAGES_ROOT + "/mini_blackops_position.png"
const MINI_POLICE_POSITION := IMAGES_ROOT + "/mini_police_position.png"
const TRACK_FOLLOWER_POSITION := IMAGES_ROOT + "/track_follower_position.png"
const TRACK_UNDEAD_POSITION := IMAGES_ROOT + "/track_undead_position.png"
const TRACK_BLACKOPS_POSITION := IMAGES_ROOT + "/track_blackops_position.png"
const TRACK_POLICE_POSITION := IMAGES_ROOT + "/track_police_position.png"

const WEATHER_RAIN1 := IMAGES_ROOT + "/weather_rain1.png"
const WEATHER_RAIN2 := IMAGES_ROOT + "/weather_rain2.png"
const WEATHER_HEAVY_RAIN1 := IMAGES_ROOT + "/weather_heavy_rain1.png"
const WEATHER_HEAVY_RAIN2 := IMAGES_ROOT + "/weather_heavy_rain2.png"

const CORPSE_DRAGGED := IMAGES_ROOT + "/corpse_dragged.png"
const ROT1_1 := IMAGES_ROOT + "/rot1_1.png"
const ROT1_2 := IMAGES_ROOT + "/rot1_2.png"
const ROT2_1 := IMAGES_ROOT + "/rot2_1.png"
const ROT2_2 := IMAGES_ROOT + "/rot2_2.png"
const ROT3_1 := IMAGES_ROOT + "/rot3_1.png"
const ROT3_2 := IMAGES_ROOT + "/rot3_2.png"
const ROT4_1 := IMAGES_ROOT + "/rot4_1.png"
const ROT4_2 := IMAGES_ROOT + "/rot4_2.png"
const ROT5_1 := IMAGES_ROOT + "/rot5_1.png"
const ROT5_2 := IMAGES_ROOT + "/rot5_2.png"
# endregion

# endregion


# region Static fields
## Registered images, keyed by image ID (= res:// path here).
static var s_images: Dictionary = {}
static var s_gray_level_images: Dictionary = {}
# endregion


# region Loading resources
static func load_resources(ui: IRogueUI) -> void:
	# region Icons
	_notify(ui, "icons...")
	load_image(ACTIVITY_CHASING)
	load_image(ACTIVITY_CHASING_PLAYER)
	load_image(ACTIVITY_TRACKING)
	load_image(ACTIVITY_FLEEING)
	load_image(ACTIVITY_FLEEING_FROM_EXPLOSIVE)
	load_image(ACTIVITY_FOLLOWING)
	load_image(ACTIVITY_FOLLOWING_ORDER)
	load_image(ACTIVITY_FOLLOWING_PLAYER)
	load_image(ACTIVITY_FOLLOWING_LEADER)  # alpha10
	load_image(ACTIVITY_SLEEPING)

	load_image(ICON_EXPIRED_FOOD)
	load_image(ICON_TARGET)
	load_image(ICON_MELEE_ATTACK)
	load_image(ICON_MELEE_MISS)
	load_image(ICON_MELEE_DAMAGE)
	load_image(ICON_RANGED_ATTACK)
	load_image(ICON_RANGED_DAMAGE)
	load_image(ICON_RANGED_MISS)
	load_image(ICON_KILLED)
	load_image(ICON_LEADER)
	load_image(ICON_RUNNING)
	load_image(ICON_CANT_RUN)
	load_image(ICON_CAN_TRADE)
	load_image(ICON_HAS_VITAL_ITEM)  # alpha10.1
	load_image(ICON_OUT_OF_AMMO)
	load_image(ICON_OUT_OF_BATTERIES)
	load_image(ICON_SLEEP_ALMOST_SLEEPY)
	load_image(ICON_SLEEP_SLEEPY)
	load_image(ICON_SLEEP_EXHAUSTED)
	load_image(ICON_SPOILED_FOOD)
	load_image(ICON_FOOD_ALMOST_HUNGRY)
	load_image(ICON_FOOD_HUNGRY)
	load_image(ICON_FOOD_STARVING)
	load_image(ICON_LINE_BAD)
	load_image(ICON_LINE_BLOCKED)
	load_image(ICON_LINE_CLEAR)
	load_image(ICON_BLAST)
	load_image(ICON_HEALING)
	load_image(ICON_IS_TARGET)
	load_image(ICON_IS_TARGETTED)
	load_image(ICON_IS_TARGETING)  # alpha10
	load_image(ICON_IS_IN_GROUP)  # alpha10
	load_image(ICON_THREAT_DANGER)
	load_image(ICON_THREAT_HIGH_DANGER)
	load_image(ICON_THREAT_SAFE)
	load_image(ICON_SCENT_LIVING)
	load_image(ICON_SCENT_ZOMBIEMASTER)
	# load_image(ICON_SCENT_LIVING_SUPRESSOR)  # alpha10 obsolete
	load_image(ICON_ODOR_SUPPRESSED)  # alpha10
	load_image(ICON_SELF_DEFENCE)
	load_image(ICON_INDIRECT_ENEMIES)
	load_image(ICON_AGGRESSOR)
	load_image(ICON_TRAP_ACTIVATED)
	load_image(ICON_TRAP_ACTIVATED_SAFE_GROUP)  # alpha10
	load_image(ICON_TRAP_ACTIVATED_SAFE_PLAYER)  # alpha10
	load_image(ICON_TRAP_TRIGGERED)
	load_image(ICON_TRAP_TRIGGERED_SAFE_GROUP)  # alpha10
	load_image(ICON_TRAP_TRIGGERED_SAFE_PLAYER)  # alpha10
	load_image(ICON_ROT_ALMOST_HUNGRY)
	load_image(ICON_ROT_HUNGRY)
	load_image(ICON_ROT_STARVING)
	load_image(ICON_SANITY_INSANE)
	load_image(ICON_SANITY_DISTURBED)
	load_image(ICON_BORING_ITEM)
	load_image(ICON_ZGRAB)  # alpha10
	# endregion

	# region Tiles
	_notify(ui, "tiles...")
	load_image(TILE_FLOOR_ASPHALT)
	load_image(TILE_FLOOR_CONCRETE)
	load_image(TILE_FLOOR_GRASS)
	load_image(TILE_FLOOR_OFFICE)
	load_image(TILE_FLOOR_PLANKS)
	load_image(TILE_FLOOR_SEWER_WATER)
	load_image(TILE_FLOOR_SEWER_WATER_ANIM1)
	load_image(TILE_FLOOR_SEWER_WATER_ANIM2)
	load_image(TILE_FLOOR_SEWER_WATER_ANIM3)
	load_image(TILE_FLOOR_SEWER_WATER_COVER)
	load_image(TILE_FLOOR_TILES)
	load_image(TILE_FLOOR_WALKWAY)

	load_image(TILE_ROAD_ASPHALT_NS)
	load_image(TILE_ROAD_ASPHALT_EW)
	load_image(TILE_RAIL_ES)

	load_image(TILE_WALL_BRICK)
	load_image(TILE_WALL_CHAR_OFFICE)
	load_image(TILE_WALL_HOSPITAL)
	load_image(TILE_WALL_SEWER)
	load_image(TILE_WALL_STONE)
	# endregion

	# region Tile decorations
	_notify(ui, "tile decorations...")
	load_image(DECO_BLOODIED_FLOOR)
	load_image(DECO_BLOODIED_WALL)
	load_image(DECO_ZOMBIE_REMAINS)
	load_image(DECO_VOMIT)

	load_image(DECO_POSTERS1)
	load_image(DECO_POSTERS2)
	load_image(DECO_TAGS1)
	load_image(DECO_TAGS2)
	load_image(DECO_TAGS3)
	load_image(DECO_TAGS4)
	load_image(DECO_TAGS5)
	load_image(DECO_TAGS6)
	load_image(DECO_TAGS7)

	load_image(DECO_SHOP_CONSTRUCTION)
	load_image(DECO_SHOP_GENERAL_STORE)
	load_image(DECO_SHOP_GROCERY)
	load_image(DECO_SHOP_GUNSHOP)
	load_image(DECO_SHOP_PHARMACY)
	load_image(DECO_SHOP_SPORTSWEAR)
	load_image(DECO_SHOP_HUNTING)

	load_image(DECO_CHAR_OFFICE)
	load_image(DECO_CHAR_FLOOR_LOGO)
	load_image(DECO_CHAR_POSTER1)
	load_image(DECO_CHAR_POSTER2)
	load_image(DECO_CHAR_POSTER3)

	load_image(DECO_PLAYER_TAG1)
	load_image(DECO_PLAYER_TAG2)
	load_image(DECO_PLAYER_TAG3)
	load_image(DECO_PLAYER_TAG4)

	load_image(DECO_ROGUEDJACK_TAG)

	load_image(DECO_SEWER_LADDER)
	load_image(DECO_SEWER_HOLE)
	load_image(DECO_SEWERS_BUILDING)

	load_image(DECO_SUBWAY_BUILDING)

	load_image(DECO_STAIRS_DOWN)
	load_image(DECO_STAIRS_UP)

	load_image(DECO_POWER_SIGN_BIG)

	load_image(DECO_POLICE_STATION)

	load_image(DECO_HOSPITAL)
	# endregion

	# region Map objects
	_notify(ui, "map objects...")
	load_image(OBJ_TREE)

	load_image(OBJ_WOODEN_DOOR_CLOSED)
	load_image(OBJ_WOODEN_DOOR_OPEN)
	load_image(OBJ_WOODEN_DOOR_BROKEN)

	load_image(OBJ_GLASS_DOOR_CLOSED)
	load_image(OBJ_GLASS_DOOR_OPEN)
	load_image(OBJ_GLASS_DOOR_BROKEN)

	load_image(OBJ_CHAR_DOOR_BROKEN)
	load_image(OBJ_CHAR_DOOR_CLOSED)
	load_image(OBJ_CHAR_DOOR_OPEN)

	load_image(OBJ_WINDOW_CLOSED)
	load_image(OBJ_WINDOW_OPEN)
	load_image(OBJ_WINDOW_BROKEN)

	load_image(OBJ_BENCH)
	load_image(OBJ_FENCE)

	load_image(OBJ_CAR1)
	load_image(OBJ_CAR2)
	load_image(OBJ_CAR3)
	load_image(OBJ_CAR4)

	load_image(OBJ_SHOP_SHELF)
	load_image(OBJ_BED)
	load_image(OBJ_WARDROBE)
	load_image(OBJ_TABLE)
	load_image(OBJ_FRIDGE)
	load_image(OBJ_DRAWER)
	load_image(OBJ_CHAIR)
	load_image(OBJ_NIGHT_TABLE)

	load_image(OBJ_CHAR_CHAIR)
	load_image(OBJ_CHAR_TABLE)

	load_image(OBJ_IRON_BENCH)
	load_image(OBJ_IRON_FENCE)
	load_image(OBJ_IRON_DOOR_BROKEN)
	load_image(OBJ_IRON_DOOR_CLOSED)
	load_image(OBJ_IRON_DOOR_OPEN)

	load_image(OBJ_BARRELS)
	load_image(OBJ_JUNK)

	load_image(OBJ_POWERGEN_OFF)
	load_image(OBJ_POWERGEN_ON)

	load_image(OBJ_GATE_CLOSED)
	load_image(OBJ_GATE_OPEN)

	load_image(OBJ_BOARD)

	load_image(OBJ_SMALL_WOODEN_FORTIFICATION)
	load_image(OBJ_LARGE_WOODEN_FORTIFICATION)

	load_image(OBJ_HOSPITAL_BED)
	load_image(OBJ_HOSPITAL_CHAIR)
	load_image(OBJ_HOSPITAL_DOOR_BROKEN)
	load_image(OBJ_HOSPITAL_DOOR_CLOSED)
	load_image(OBJ_HOSPITAL_DOOR_OPEN)
	load_image(OBJ_HOSPITAL_NIGHT_TABLE)
	load_image(OBJ_HOSPITAL_WARDROBE)

	# alpha10
	load_image(OBJ_GARDEN_FENCE)
	load_image(OBJ_WIRE_FENCE)
	# endregion

	# region Actors
	_notify(ui, "actors...")
	load_image(PLAYER_FOLLOWER)
	load_image(PLAYER_FOLLOWER_TRUST)
	load_image(PLAYER_FOLLOWER_BOND)

	load_image(ACTOR_SKELETON)
	load_image(ACTOR_RED_EYED_SKELETON)
	load_image(ACTOR_RED_SKELETON)
	load_image(ACTOR_ZOMBIE)
	load_image(ACTOR_DARK_EYED_ZOMBIE)
	load_image(ACTOR_DARK_ZOMBIE)
	load_image(ACTOR_MALE_NEOPHYTE)
	load_image(ACTOR_FEMALE_NEOPHYTE)
	load_image(ACTOR_MALE_DISCIPLE)
	load_image(ACTOR_FEMALE_DISCIPLE)
	load_image(ACTOR_ZOMBIE_MASTER)
	load_image(ACTOR_ZOMBIE_LORD)
	load_image(ACTOR_ZOMBIE_PRINCE)
	load_image(ACTOR_RAT_ZOMBIE)
	load_image(ACTOR_SEWERS_THING)
	load_image(ACTOR_JASON_MYERS)
	load_image(ACTOR_BIG_BEAR)
	load_image(ACTOR_FAMU_FATARU)
	load_image(ACTOR_SANTAMAN)
	load_image(ACTOR_ROGUEDJACK)
	load_image(ACTOR_DUCKMAN)
	load_image(ACTOR_HANS_VON_HANZ)
	# endregion

	# region Actor decorations
	_notify(ui, "actor decorations...")

	load_image(BLOODIED)

	load_image(MALE_SKIN1)
	load_image(MALE_SKIN2)
	load_image(MALE_SKIN3)
	load_image(MALE_SKIN4)
	load_image(MALE_SKIN5)
	load_image(MALE_SHIRT1)
	load_image(MALE_SHIRT2)
	load_image(MALE_SHIRT3)
	load_image(MALE_SHIRT4)
	load_image(MALE_SHIRT5)
	load_image(MALE_HAIR1)
	load_image(MALE_HAIR2)
	load_image(MALE_HAIR3)
	load_image(MALE_HAIR4)
	load_image(MALE_HAIR5)
	load_image(MALE_HAIR6)
	load_image(MALE_HAIR7)
	load_image(MALE_HAIR8)
	load_image(MALE_PANTS1)
	load_image(MALE_PANTS2)
	load_image(MALE_PANTS3)
	load_image(MALE_PANTS4)
	load_image(MALE_PANTS5)
	load_image(MALE_SHOES1)
	load_image(MALE_SHOES2)
	load_image(MALE_SHOES3)
	load_image(MALE_EYES1)
	load_image(MALE_EYES2)
	load_image(MALE_EYES3)
	load_image(MALE_EYES4)
	load_image(MALE_EYES5)
	load_image(MALE_EYES6)

	load_image(FEMALE_SKIN1)
	load_image(FEMALE_SKIN2)
	load_image(FEMALE_SKIN3)
	load_image(FEMALE_SKIN4)
	load_image(FEMALE_SKIN5)
	load_image(FEMALE_SHIRT1)
	load_image(FEMALE_SHIRT2)
	load_image(FEMALE_SHIRT3)
	load_image(FEMALE_SHIRT4)
	load_image(FEMALE_HAIR1)
	load_image(FEMALE_HAIR2)
	load_image(FEMALE_HAIR3)
	load_image(FEMALE_HAIR4)
	load_image(FEMALE_HAIR5)
	load_image(FEMALE_HAIR6)
	load_image(FEMALE_HAIR7)
	load_image(FEMALE_PANTS1)
	load_image(FEMALE_PANTS2)
	load_image(FEMALE_PANTS3)
	load_image(FEMALE_PANTS4)
	load_image(FEMALE_PANTS5)
	load_image(FEMALE_SHOES1)
	load_image(FEMALE_SHOES2)
	load_image(FEMALE_SHOES3)
	load_image(FEMALE_EYES1)
	load_image(FEMALE_EYES2)
	load_image(FEMALE_EYES3)
	load_image(FEMALE_EYES4)
	load_image(FEMALE_EYES5)
	load_image(FEMALE_EYES6)

	load_image(ARMY_HELMET)
	load_image(ARMY_PANTS)
	load_image(ARMY_SHIRT)
	load_image(ARMY_SHOES)

	load_image(BIKER_HAIR1)
	load_image(BIKER_HAIR2)
	load_image(BIKER_HAIR3)
	load_image(BIKER_PANTS)
	load_image(BIKER_SHOES)

	load_image(GANGSTA_HAT)
	load_image(GANGSTA_PANTS)
	load_image(GANGSTA_SHIRT)

	load_image(CHARGUARD_HAIR)
	load_image(CHARGUARD_PANTS)

	load_image(POLICE_HAT)
	load_image(POLICE_PANTS)
	load_image(POLICE_SHOES)
	load_image(POLICE_UNIFORM)

	load_image(BLACKOP_SUIT)

	load_image(HOSPITAL_DOCTOR_UNIFORM)
	load_image(HOSPITAL_NURSE_UNIFORM)
	load_image(HOSPITAL_PATIENT_UNIFORM)

	load_image(SURVIVOR_FEMALE_BANDANA)
	load_image(SURVIVOR_MALE_BANDANA)

	load_image(DOG_SKIN1)
	load_image(DOG_SKIN2)
	load_image(DOG_SKIN3)
	# endregion

	# region Items
	_notify(ui, "items...")
	load_image(ITEM_SLOT)
	load_image(ITEM_EQUIPPED)

	load_image(ITEM_AMMO_BOLTS)
	load_image(ITEM_AMMO_HEAVY_PISTOL)
	load_image(ITEM_AMMO_HEAVY_RIFLE)
	load_image(ITEM_AMMO_LIGHT_PISTOL)
	load_image(ITEM_AMMO_LIGHT_RIFLE)
	load_image(ITEM_AMMO_SHOTGUN)
	load_image(ITEM_ARMY_BODYARMOR)
	load_image(ITEM_ARMY_PISTOL)
	load_image(ITEM_ARMY_RATION)
	load_image(ITEM_ARMY_RIFLE)
	load_image(ITEM_BANDAGES)
	load_image(ITEM_BARBED_WIRE)
	load_image(ITEM_BASEBALL_BAT)
	load_image(ITEM_BEAR_TRAP)
	load_image(ITEM_BIGBEAR_BAT)
	load_image(ITEM_BIG_FLASHLIGHT)
	load_image(ITEM_BIG_FLASHLIGHT_OUT)
	load_image(ITEM_BLACKOPS_GPS)
	load_image(ITEM_BOOK)
	load_image(ITEM_CANNED_FOOD)
	load_image(ITEM_CELL_PHONE)
	load_image(ITEM_CHAR_LIGHT_BODYARMOR)
	load_image(ITEM_COMBAT_KNIFE)
	load_image(ITEM_CROWBAR)
	load_image(ITEM_EMPTY_CAN)
	load_image(ITEM_FAMU_FATARU_KATANA)
	load_image(ITEM_FLASHLIGHT)
	load_image(ITEM_FLASHLIGHT_OUT)
	load_image(ITEM_FREE_ANGELS_JACKET)
	load_image(ITEM_GOLF_CLUB)
	load_image(ITEM_GRENADE)
	load_image(ITEM_GRENADE_PRIMED)
	load_image(ITEM_GROCERIES)
	load_image(ITEM_HELLS_SOULS_JACKET)
	load_image(ITEM_HUGE_HAMMER)
	load_image(ITEM_HUNTER_VEST)
	load_image(ITEM_HUNTING_CROSSBOW)
	load_image(ITEM_HUNTING_RIFLE)
	load_image(ITEM_IMPROVISED_CLUB)
	load_image(ITEM_IMPROVISED_SPEAR)
	load_image(ITEM_IRON_GOLF_CLUB)
	load_image(ITEM_JASON_MYERS_AXE)
	load_image(ITEM_HANS_VON_HANZ_PISTOL)
	load_image(ITEM_KOLT_REVOLVER)
	load_image(ITEM_MAGAZINE)
	load_image(ITEM_MEDIKIT)
	load_image(ITEM_PILLS_ANTIVIRAL)
	load_image(ITEM_PILLS_BLUE)
	load_image(ITEM_PILLS_GREEN)
	load_image(ITEM_PILLS_SAN)
	load_image(ITEM_PISTOL)
	load_image(ITEM_POLICE_JACKET)
	load_image(ITEM_POLICE_RADIO)
	load_image(ITEM_POLICE_RIOT_ARMOR)
	load_image(ITEM_PRECISION_RIFLE)
	load_image(ITEM_ROGUEDJACK_KEYBOARD)
	load_image(ITEM_SANTAMAN_SHOTGUN)
	load_image(ITEM_SHOTGUN)
	load_image(ITEM_SHOVEL)
	load_image(ITEM_SMALL_HAMMER)
	load_image(ITEM_SHORT_SHOVEL)
	load_image(ITEM_SPIKES)
	load_image(ITEM_SPRAYPAINT)
	load_image(ITEM_SPRAYPAINT2)
	load_image(ITEM_SPRAYPAINT3)
	load_image(ITEM_SPRAYPAINT4)
	load_image(ITEM_STENCH_KILLER)
	load_image(ITEM_SUBWAY_BADGE)
	load_image(ITEM_TRUNCHEON)
	load_image(ITEM_WOODEN_PLANK)
	load_image(ITEM_ZTRACKER)
	# endregion

	# region Effects
	_notify(ui, "effects...")

	load_image(EFFECT_BARRICADED)
	load_image(EFFECT_ONFIRE)
	# endregion

	# region Misc
	_notify(ui, "misc...")
	load_image(UNDEF)
	load_image(MAP_EXIT)
	load_image(MINI_BLACKOPS_POSITION)
	load_image(MINI_FOLLOWER_POSITION)
	load_image(MINI_PLAYER_POSITION)
	load_image(MINI_PLAYER_TAG1)
	load_image(MINI_PLAYER_TAG2)
	load_image(MINI_PLAYER_TAG3)
	load_image(MINI_PLAYER_TAG4)
	load_image(MINI_POLICE_POSITION)
	load_image(MINI_UNDEAD_POSITION)
	load_image(TRACK_BLACKOPS_POSITION)
	load_image(TRACK_FOLLOWER_POSITION)
	load_image(TRACK_POLICE_POSITION)
	load_image(TRACK_UNDEAD_POSITION)
	load_image(WEATHER_RAIN1)
	load_image(WEATHER_RAIN2)
	load_image(WEATHER_HEAVY_RAIN1)
	load_image(WEATHER_HEAVY_RAIN2)
	load_image(ROT1_1)
	load_image(ROT1_2)
	load_image(ROT2_1)
	load_image(ROT2_2)
	load_image(ROT3_1)
	load_image(ROT3_2)
	load_image(ROT4_1)
	load_image(ROT4_2)
	load_image(ROT5_1)
	load_image(ROT5_2)
	load_image(CORPSE_DRAGGED)
	# endregion

	_notify(ui, "done!")


## C# Load(string id): loads the PNG, registers the normal image and its
## gray-level (darkened) variant. Godot port: registers ImageTextures built
## from the imported texture's Image.
static func load_image(p_id: String) -> void:
	var tex := load(p_id) as Texture2D
	if tex == null:
		push_error("could not load image id=" + p_id)
		return
	var img := tex.get_image()
	# keep CPU copy accessible for pixel operations (decompose/minimap).
	if img.is_compressed():
		img.decompress()
	s_images[p_id] = ImageTexture.create_from_image(img)
	s_gray_level_images[p_id] = ImageTexture.create_from_image(make_gray_level(img))


## C# MakeGrayLevel(Bitmap): every pixel becomes a dimmed gray of its
## brightness (HSL lightness), keeping its alpha.
static func make_gray_level(p_img: Image) -> Image:
	var grayed := p_img.duplicate() as Image
	for y in grayed.get_height():
		for x in grayed.get_width():
			var pixel_color := grayed.get_pixel(x, y)
			var mx: float = maxf(pixel_color.r, maxf(pixel_color.g, pixel_color.b))
			var mn: float = minf(pixel_color.r, minf(pixel_color.g, pixel_color.b))
			var brightness := (mx + mn) / 2.0
			var rgb := int(255.0 * GRAYLEVEL_DIM_FACTOR * brightness)
			grayed.set_pixel(x, y, Color8(rgb, rgb, rgb, int(pixel_color.a * 255.0)))
	return grayed


static func _notify(ui: IRogueUI, p_stage: String) -> void:
	ui.ui_clear(Color.BLACK)
	ui.ui_draw_string_bold(Color.WHITE, "Loading resources: " + p_stage, 0, 0)
	ui.ui_repaint()
# endregion


# region Retrieving resources
static func get_image(image_id: String) -> Texture2D:
	if s_images.has(image_id):
		return s_images[image_id]
	return s_images[UNDEF]


static func get_gray_level(image_id: String) -> Texture2D:
	if s_gray_level_images.has(image_id):
		return s_gray_level_images[image_id]
	return s_gray_level_images[UNDEF]


## All registered image IDs (used by the UI to build its TileSet atlas).
static func image_ids() -> Array:
	return s_images.keys()
# endregion


# __END__


## Drop all cached textures (shutdown, frees the image resources).
static func clear_cache() -> void:
	s_images.clear()
	s_gray_level_images.clear()
