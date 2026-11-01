class_name CSVParser
extends RefCounted
## Port of Engine/CSVParser.cs (contains CSVField, CSVLine, CSVTable, CSVParser)


class CSVField:
	var _raw_string: String

	func _init(raw_string: String) -> void:
		_raw_string = raw_string

	func parse_int() -> int:
		return _raw_string.to_int()

	func parse_float() -> float:
		return _raw_string.to_float()

	func parse_text() -> String:
		return _raw_string.trim_prefix('"').trim_suffix('"')

	func parse_bool() -> bool:
		return parse_int() > 0


class CSVLine:
	var fields: Array[CSVField] = []

	func _init(nb_fields: int) -> void:
		fields.resize(nb_fields)

	func get_field(field: int) -> CSVField:
		return fields[field]

	func set_field(field: int, value: CSVField) -> void:
		fields[field] = value

	func fields_count() -> int:
		return fields.size()


class CSVTable:
	var nb_fields: int
	var lines: Array[CSVLine] = []

	func _init(p_nb_fields: int) -> void:
		nb_fields = p_nb_fields

	func get_field(field: int, line: int) -> CSVField:
		return lines[line].fields[field]

	func count_lines() -> int:
		return lines.size()

	func add_line(line: CSVLine) -> void:
		if line.fields_count() != nb_fields:
			push_error("line fields count %d does not match with table fields count %d" % [line.fields_count(), nb_fields])
			return
		lines.append(line)


var delimiter := ","


func parse(line: String) -> PackedStringArray:
	if line.is_empty():
		return PackedStringArray()

	# split with delimiter.
	line = line.strip_edges(false, true)
	var fields: PackedStringArray = line.split(delimiter)

	# glue back quoted strings that were wrongly split (contained a delimiter).
	var i_field := 0
	while i_field < fields.size() - 1:
		var f := fields[i_field]
		if f.length() > 0 and f[0] == '"' and f[f.length() - 1] != '"':
			# find the next field ending with a quote and glue everything back.
			var quoted_field := f
			var i_glue := i_field + 1
			while true:
				if i_glue >= fields.size():
					break
				var glue_me := fields[i_glue]
				quoted_field += delimiter + glue_me
				fields.remove_at(i_glue)
				if glue_me.length() > 0 and glue_me[glue_me.length() - 1] == '"':
					break
			fields[i_field] = quoted_field
		else:
			i_field += 1

	return fields


func parse_lines(lines: PackedStringArray) -> Array[PackedStringArray]:
	var list: Array[PackedStringArray] = []
	for l: String in lines:
		list.append(parse(l))
	return list


func parse_to_table(lines: PackedStringArray, nb_fields: int) -> CSVTable:
	var table := CSVTable.new(nb_fields)
	for l: PackedStringArray in parse_lines(lines):
		if l.is_empty():
			continue  # trailing blank line
		var new_table_line := CSVLine.new(l.size())
		for i_field: int in l.size():
			new_table_line.set_field(i_field, CSVField.new(l[i_field]))
		table.add_line(new_table_line)
	return table


## Read a text file as lines, decoding bytes as Windows-1252 (the original
## game's CSV/text files are ANSI, not UTF-8). High bytes 0xA0-0xFF map to the
## same Unicode codepoints; 0x80-0x9F use the CP1252 specials table.
static func read_lines_cp1252(path: String) -> PackedStringArray:
	# CP1252 bytes 0x80-0x9F as Unicode codepoints.
	const CP1252_HIGH := "€‚ƒ„…†‡ˆ‰Š‹Œ\u017DŽ‘’“”•–—˜™š›œ\u017EŸ"
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("cannot open file %s" % path)
		return PackedStringArray()
	var bytes := f.get_buffer(f.get_length())
	f.close()
	var text := ""
	for b in bytes:
		if b < 0x80:
			text += char(b)
		elif b >= 0xA0:
			text += char(b)  # latin-1 supplement == CP1252 here
		else:
			text += CP1252_HIGH[b - 0x80]
	var out := PackedStringArray()
	for l: String in text.split("\n"):
		out.append(l.trim_suffix("\r"))
	return out


func format(fields: PackedStringArray) -> String:
	if fields.is_empty():
		return delimiter
	var sb := ""
	for f: String in fields:
		sb += f
		sb += delimiter
	return sb
