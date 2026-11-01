class_name Message
extends RefCounted
## Port of Data/Message.cs

var text: String
var color: Color
var turn: int


func _init(p_text: String, p_turn: int, p_color: Color = Color.WHITE) -> void:
	assert(p_text != null, "text")

	text = p_text
	color = p_color
	turn = p_turn
