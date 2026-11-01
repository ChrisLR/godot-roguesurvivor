class_name InputTranslator
extends RefCounted
## Port of Engine/InputTranslator.cs
## Translates a Godot InputEventKey to a PlayerCommand using the
## RogueGame keybindings. The C# version took a WinForms KeyEventArgs
## (KeyData = key code | modifier flags); here we build the same packed
## int (Godot Key | KeyModifierMask bits) expected by Keybindings.


## Port of InputTranslator.KeyToCommand(KeyEventArgs).
static func key_to_command(event: InputEventKey) -> int:
	var packed_key := _packed_key(event)

	var command: int = RogueGame.key_bindings.get_command(packed_key)
	if command != PlayerCommand.Command.NONE:
		return command

	# check special case for item slot keys.
	# slots keys are always used with Ctrl, Shift or Alt modifiers so they are unbound in keybindings.
	if event.shift_pressed || event.ctrl_pressed || event.alt_pressed:
		# clear modifiers.
		var unmodified_key := packed_key
		if event.ctrl_pressed:
			unmodified_key ^= KEY_MASK_CTRL
		if event.shift_pressed:
			unmodified_key ^= KEY_MASK_SHIFT
		if event.alt_pressed:
			unmodified_key ^= KEY_MASK_ALT

		# slot key?
		for i: int in 10:
			if unmodified_key == RogueGame.key_bindings.get_key(PlayerCommand.Command.ITEM_SLOT_0 + i):
				return PlayerCommand.Command.ITEM_SLOT_0 + i

	# no command.
	return PlayerCommand.Command.NONE


static func _packed_key(event: InputEventKey) -> int:
	var packed: int = event.keycode
	if event.shift_pressed:
		packed |= KEY_MASK_SHIFT
	if event.ctrl_pressed:
		packed |= KEY_MASK_CTRL
	if event.alt_pressed:
		packed |= KEY_MASK_ALT
	if event.meta_pressed:
		packed |= KEY_MASK_META
	return packed
