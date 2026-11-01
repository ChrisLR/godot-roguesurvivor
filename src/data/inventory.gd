class_name Inventory
extends RefCounted
## Port of Data/Inventory.cs
## A list of items with stack handling and a max capacity.

var _items: Array[Item] = []
var max_capacity: int


func _init(p_max_capacity: int) -> void:
	assert(p_max_capacity >= 0, "maxCapacity < 0")

	max_capacity = p_max_capacity
	#_items = []
	_items = []


var items: Array[Item]:
	get:
		return _items


var count_items: int:
	get:
		return _items.size()


## C# indexer this[int] : null when out of range.
func get_item_at(index: int) -> Item:
	if index < 0 || index >= _items.size():
		return null

	return _items[index]


var is_empty: bool:
	get:
		return _items.is_empty()


var is_full: bool:
	get:
		return _items.size() >= max_capacity


var top_item: Item:
	get:
		if _items.is_empty():
			return null
		return _items[_items.size() - 1]


var bottom_item: Item:
	get:
		if _items.is_empty():
			return null
		return _items[0]


# Managing

## Try to add all the item quantity.
func add_all(it: Item) -> bool:
	assert(it != null, "it")

	# Try stacking.
	var stack_result: Dictionary = _get_items_stackable_with(it)
	var stack_list = stack_result.stack_list
	var stacked_quantity: int = stack_result.stacked_quantity

	# If can stack all, do it and success.
	if stacked_quantity == it.quantity:
		var quantity_left: int = it.quantity
		for other: Item in stack_list:
			var can_stack_other: int = other.model.stacking_limit - other.quantity
			var stack_other: int = min(can_stack_other, quantity_left)
			_add_to_stack(it, stack_other, other)
			quantity_left -= stack_other
			if quantity_left <= 0:
				break
		return true

	# We cannot stack all.
	# If inventory full, fail.
	if is_full:
		return false

	# One slot free, add.
	_items.append(it)
	return true


## Try to add as much item quantity as possible.
## Changes item quantity.
## GDScript has no out parameters : the C# (bool, out int) couple is returned
## as a Dictionary { "ok": bool, "added": int }.
func add_as_much_as_possible(it: Item) -> Dictionary:
	assert(it != null, "it")

	var start_quantity: int = it.quantity

	# Try stacking.
	var stack_result: Dictionary = _get_items_stackable_with(it)
	var stack_list = stack_result.stack_list

	if stack_list != null:
		# Stack as much as possible.
		var quantity_added: int = 0
		for other: Item in stack_list:
			var added: int = _add_to_stack(it, it.quantity - quantity_added, other)
			quantity_added += added
		# If quantity left, try to add rest in free slot.
		if quantity_added < it.quantity:
			# we could stack this much.
			it.quantity -= quantity_added
			# if slot free, add rest to free slot.
			if not is_full:
				# we stacked or added evertyhing.
				_items.append(it)
				quantity_added = start_quantity
		else:
			# we stacked everything, item should die.
			it.quantity = 0

		# Done.
		return { "ok": true, "added": quantity_added }

	# Cannot stack, need a free slot.
	if is_full:
		return { "ok": false, "added": 0 }

	# Add to free slot.
	_items.append(it)
	return { "ok": true, "added": it.quantity }


## Checks if can add at least one quantity of item.
func can_add_at_least_one(it: Item) -> bool:
	assert(it != null, "it")

	# If free slot, sure!
	if not is_full:
		return true

	# Inventory full.
	# Can we stack at least one?
	return _has_at_least_one_stackable_with(it) # alpha10 small speed improvement


## Remove completly the item (all its quantity).
func remove_all_quantity(it: Item) -> void:
	_items.erase(it)


## Decrease quantity by 1, if no more quantity remove item.
func consume(it: Item) -> void:
	it.quantity -= 1
	if it.quantity <= 0:
		_items.erase(it)


func _add_to_stack(from: Item, add_this: int, to: Item) -> int:
	var added: int = 0
	while add_this > 0 && to.quantity < to.model.stacking_limit:
		to.quantity += 1
		added += 1
		add_this -= 1
	return added


## Gets items in inventory with which item can be stacked with and quantity of
## item stacked this way.
## GDScript has no out parameters : the C# (List, out int) couple is returned
## as a Dictionary { "stack_list": Array or null, "stacked_quantity": int }.
func _get_items_stackable_with(it: Item) -> Dictionary:
	var stacked_quantity: int = 0

	if not it.model.is_stackable:
		return { "stack_list": null, "stacked_quantity": 0 }

	var stack_list = null
	for other: Item in _items:
		# other same model, other not full, other not equiped
		if other.model == it.model and other.can_stack_more and not other.is_equipped:
			# can stack with this one.
			if stack_list == null:
				stack_list = []
			stack_list.append(other)

			# how many can we stack there?
			var stack_on_other: int = other.model.stacking_limit - other.quantity

			# how many do we want to stack here.
			var want_to_stack: int = min(it.quantity - stacked_quantity, stack_on_other)

			# we stack this much here.
			stacked_quantity += want_to_stack

			# if enough, done.
			if stacked_quantity == it.quantity:
				break

	return { "stack_list": stack_list, "stacked_quantity": stacked_quantity }


# alpha10
func _has_at_least_one_stackable_with(it: Item) -> bool:
	if not it.model.is_stackable:
		return false

	for other: Item in _items:
		# other != it, same model, other not full, other not equiped
		if other != it and other.model == it.model and other.can_stack_more and not other.is_equipped:
			return true

	return false


## Gets smallest stack this item can be destacked from.
func _get_best_destackable(it: Item) -> Item:
	if not it.model.is_stackable:
		return null

	var smallest_stack: Item = null
	for other: Item in _items:
		if other.model == it.model:
			if smallest_stack == null || other.quantity < smallest_stack.quantity:
				smallest_stack = other

	return smallest_stack


func contains(it: Item) -> bool:
	return _items.has(it)


# alpha10
## Defragment the inventory : consolidate smaller stacks into bigger ones.
## Improves AI inventory management, not meant for the player as it can change
## the inventory and confuses him.
## Don't abuse it, nice O^2...
func defrag() -> void:
	var count_empty_stacks_to_remove: int

	# iterate over all stackable items to see if we can "steal" quantity from other stacks.
	# since we iterate from left to right and steal from the right, the leftmost stacks will always be
	# the biggest one.
	count_empty_stacks_to_remove = 0
	var n: int = _items.size()
	for i in n:
		var merge_with: Item = _items[i]
		if merge_with.quantity > 0 && merge_with.can_stack_more:
			var j: int = i + 1
			while j < n && merge_with.can_stack_more:
				var steal_from: Item = _items[j]
				if steal_from.model == merge_with.model && steal_from.quantity > 0:
					var steal: int = min(merge_with.model.stacking_limit - merge_with.quantity, steal_from.quantity)
					merge_with.quantity += steal
					steal_from.quantity -= steal
					if steal_from.quantity <= 0:
						count_empty_stacks_to_remove += 1
				j += 1

	# some smaller stacks might now be empty, delete them now.
	if count_empty_stacks_to_remove > 0:
		var i: int = 0
		while true:
			if _items[i].quantity <= 0:
				count_empty_stacks_to_remove -= 1
				_items.remove_at(i)
			else:
				i += 1
			if not (i < _items.size() && count_empty_stacks_to_remove > 0):
				break


# Helpers

func get_first_by_model(model: ItemModel) -> Item:
	for it: Item in _items:
		if it.model == model:
			return it
	return null


## GDScript has no System.Type : pass the item subclass script, e.g.
## `has_item_of_type(ItemFood)`. Matches the C# exact-type (GetType()==tt)
## semantics via script identity.
func has_item_of_type(tt: GDScript) -> bool:
	return get_first_by_type(tt) != null


## C# exact type test (GetType() == tt).
func get_first_by_type(tt: GDScript) -> Item:
	for it: Item in _items:
		if it.get_script() == tt:
			return it
	return null


## C# generic GetItemsByType<_T_>() -> pass the item subclass script.
func get_items_by_type(tt: GDScript):
	var list = null

	for it: Item in _items:
		if it.get_script() == tt:
			if list == null:
				list = []
			list.append(it)

	return list


func get_first_matching(fn: Callable) -> Item:
	for it: Item in _items:
		if fn.call(it):
			return it
	return null


func count_items_matching(fn: Callable) -> int:
	var count: int = 0
	for it: Item in _items:
		if fn.call(it):
			count += 1
	return count


func has_item_matching(fn: Callable) -> bool:
	for it: Item in _items:
		if fn.call(it):
			return true
	return false


# alpha10

func get_smallest_stack_by_type(tt: GDScript, allow_zero_quantity: bool = false) -> Item:
	var smallest: Item = null
	var smallest_quantity: int = 0

	for it: Item in _items:
		if it.get_script() == tt:
			var q: int = it.quantity
			if smallest == null || (q < smallest_quantity && (allow_zero_quantity || q > 0)):
				smallest = it
				smallest_quantity = q

	return smallest


func get_smallest_stack_by_model(m: ItemModel, allow_zero_quantity: bool = false) -> Item:
	var smallest: Item = null
	var smallest_quantity: int = 0

	for it: Item in _items:
		if it.model == m:
			var q: int = it.quantity
			if smallest == null || (q < smallest_quantity && (allow_zero_quantity || q > 0)):
				smallest = it
				smallest_quantity = q

	return smallest


## Returns never null.
func filter(fn: Callable) -> Array[Item]:
	var list: Array[Item] = []
	for it: Item in _items:
		if fn.call(it):
			list.append(it)
	return list


func for_each(fn: Callable) -> void:
	for it: Item in _items:
		fn.call(it)


# alpha10
# Pre-saving

func optimize_before_saving() -> void:
	for it: Item in _items:
		it.optimize_before_saving()


# --- save system ---
func serialize() -> Dictionary:
	var items := []
	for it in _items:
		items.append(it.serialize())
	return {"max_capacity": max_capacity, "items": items}


static func deserialize_data(data: Dictionary) -> Inventory:
	var inv := Inventory.new(data.get("max_capacity", 0))
	for it_data in data.get("items", []):
		inv._items.append(Item.deserialize_data(it_data))
	return inv


func resolve_refs(world: World) -> void:
	for it in _items:
		it.resolve_refs(world)
