class_name TextFile
extends RefCounted
## Port of Engine/TextFile.cs
## A text file loaded in memory, with hard line-wrapping support.


var _raw_lines: Array = []
var _formated_lines: Array = []


var raw_lines: Array:
	get:
		return _raw_lines


var formated_lines: Array:
	get:
		return _formated_lines


# Init

func _init() -> void:
	_raw_lines = []


# Loading & Saving

func load_file(file_name: String) -> bool:
	if not FileAccess.file_exists(file_name):
		push_error("TextFile loading exception: %s (%s)" % [file_name, FileAccess.get_open_error()])
		return false

	# original text files are ANSI (Windows-1252), not UTF-8.
	_raw_lines = CSVParser.read_lines_cp1252(file_name)
	return true


func save_file(file_name: String) -> bool:
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	if file == null:
		push_error("TextFile saving exception: %s (%s)" % [file_name, FileAccess.get_open_error()])
		return false

	for line: String in _raw_lines:
		file.store_line(line)
	file.close()
	return true


# Raw Editing

func append(line: String) -> void:
	_raw_lines.append(line)


# Parsing and Formatting

## Hard-wraps raw lines to at most chars_per_line characters per
## formatted line (the C# original splits mid-word, without spaces).
func format_lines(chars_per_line: int) -> void:
	if _raw_lines == null || _raw_lines.is_empty():
		return

	_formated_lines = []
	for raw_line: String in _raw_lines:
		while raw_line.length() > chars_per_line:
			var head := raw_line.substr(0, chars_per_line)
			var rest := raw_line.substr(chars_per_line)
			_formated_lines.append(head)
			raw_line = rest
		_formated_lines.append(raw_line)
