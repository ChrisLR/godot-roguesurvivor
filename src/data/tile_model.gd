class_name TileModel
extends RefCounted
## Port of Data/TileModel.cs

## Blank tile model.
static var UNDEF: TileModel = TileModel.new("", Color.PINK, false, true)

var id: int = 0
var image_id: String
var is_walkable: bool
var is_transparent: bool
var minimap_color: Color
var is_water: bool = false
var water_cover_image_id: String = ""


func _init(p_image_id: String, p_minimap_color: Color, p_is_walkable: bool,
		p_is_transparent: bool) -> void:
	image_id = p_image_id
	is_walkable = p_is_walkable
	is_transparent = p_is_transparent
	minimap_color = p_minimap_color
