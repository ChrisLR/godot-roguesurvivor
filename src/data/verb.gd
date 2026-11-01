class_name Verb
extends RefCounted
## Port of Data/Verb.cs

var you_form: String
var he_form: String


## C# has two constructors: Verb(youForm) defaulting heForm to youForm+"s".
## GDScript default arguments must be constant, so an empty he_form selects
## the plural form.
func _init(p_you_form: String, p_he_form: String = "") -> void:
	you_form = p_you_form
	if p_he_form == "":
		he_form = p_you_form + "s"
	else:
		he_form = p_he_form


# --- save system ---
func serialize() -> Dictionary:
	return {"you_form": you_form, "he_form": he_form}


static func deserialize_data(data: Dictionary) -> Verb:
	return Verb.new(data.get("you_form", ""), data.get("he_form", ""))
