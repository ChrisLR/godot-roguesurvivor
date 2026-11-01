extends SceneTree
## Per-file validation: prints "FILE <path>" before each load so parse
## errors printed by the engine can be attributed to a file.

func _init() -> void:
	var scripts := _collect_gd("res://src")
	scripts.sort()
	for path: String in scripts:
		print("FILE ", path)
		var s: Script = load(path)
		if s == null:
			print("LOAD_NULL ", path)
	print("DONE")
	quit(0)


func _collect_gd(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		var full := dir_path + "/" + f
		if dir.current_is_dir():
			if not f.begins_with("."):
				out.append_array(_collect_gd(full))
		elif f.ends_with(".gd"):
			out.append(full)
		f = dir.get_next()
	return out
