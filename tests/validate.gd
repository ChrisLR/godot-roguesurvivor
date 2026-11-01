extends SceneTree
## Headless validation: load every .gd under res://src and report parse errors.
## Run: godot --headless --script tests/validate.gd

func _init() -> void:
	var failures: Array[String] = []
	var scripts := _collect_gd("res://src")
	for path: String in scripts:
		var s: Script = load(path)
		if s == null:
			failures.append(path)
			continue
	if failures.is_empty():
		print("VALIDATE_OK %d scripts" % scripts.size())
		quit(0)
	else:
		for f: String in failures:
			print("PARSE_FAIL ", f)
		print("VALIDATE_FAILED %d of %d" % [failures.size(), scripts.size()])
		quit(1)


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
