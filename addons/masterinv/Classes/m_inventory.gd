class_name Inventory
extends Resource

## General change in the inventory.[br][br][code]"RM_item"[/code] is used when an 
## ITEM is FULLY removed from the inventory (count is 0).
## [code]"RM_count"[/code] is used when and items COUNT decreases but the it IS NOT removed.
## [code]"ADD_count"[/code] and [code]"ADD_item"[/code] are used the same way but when an item is added
signal inventory_changed(change: StringName, item_id: int)

@export var size : int = 6

@export_storage var _inventory : Array[InvItem] = []

class InvReturn extends Resource:
	var success : bool
	var inv_id : int
	
	func _init(_success : bool, _inv_id : int = 0) -> void:
		success = _success
		inv_id = _inv_id

func _init(inventory_size : int = 6) -> void:
	size = inventory_size

## Returns an [Array] of [InvItem]s
func get_all_items() -> Array[InvItem]:
	return _inventory.duplicate(true)

## Atempts to remove a item to the inventory. If the inventory doesnt have this
## item, this function returns [code]false[/code]
## [br][br]Passing an Item ID will remove the first item it finds, passing
## a inv_id will remove the specific item and is reccomended. [br][br]
## To call without an item_id pass -1 as the item_id and put in your inv_id: [code]remove_item(-1, 5)[/code]
func remove_item(item_id : int = -1, inv_id : int = -1) -> bool:
	var item : InvItem
	if item_id != -1:
		for i in _inventory:
			if i.item_id == item_id:
				item = i
				break
	if not item and inv_id != -1 and _inventory.size() - 1 >= inv_id:
		item = _inventory[inv_id]
	elif not item:
		return false
	
	if item.count == 1:
		_inventory.erase(item)
		inventory_changed.emit(&"RM_item", item_id)
		return true
	else:
		item.count -= 1
		inventory_changed.emit(&"RM_count", item_id)
		return true
	
	return false

## Atempts to add a item to the inventory. If the inventory doesnt have enough room, this function returns [code]false[/code]
func add_item(item_id: int) -> InvReturn:
	var idx : int = 0
	for i in _inventory:
		if i.item_id == item_id:
			if i.count < i.max_count or i.max_count == -1:
				i.count += 1
				inventory_changed.emit(&"ADD_count", item_id)
				return InvReturn.new(true, idx)
		idx += 1
	if _inventory.size() < size or _inventory.size() == -1:
		var count : int = 1
		var max_size : int = (ItemAccessor.item_registry.items.get(item_id) as Item).max_stack_size
		
		var inv_item : InvItem = InvItem.new(item_id, count, max_size)
		inv_item.inv_id = _inventory.size()
		_inventory.append(inv_item)
		inventory_changed.emit(&"ADD_item", item_id)
		return InvReturn.new(true, _inventory.size() - 1)

	return InvReturn.new(false)

#func _test() -> void:
	#var inv_ids : Array[int]
	#for i in range(10):
		#var inv_return : InvReturn = add_item(0)
		#if inv_return.success != true:
			#push_error("~ERROR~")
		#PBFuncs.debug_print("New item id: %s" % inv_return.inv_id)
		#inv_ids.append(inv_return.inv_id)
	#
	#for i in range(3):
		#PBFuncs.debug_print("Removing...")
		#remove_item(-1, inv_ids[-1])
	#
	#var idx : int = 0
	#PBFuncs.debug_print("Inventory:")
	#for i in _inventory:
		#var i_item : Item = i.get_item()
		#PBFuncs.debug_print("Item: %s, Count: %s, inv_id: %s" % [i_item.display_name, i.count, i.inv_id])
		#idx += 1
	#
	#PBFuncs.debug_print("Expected output: 2 items, 1 with a count of 1 and a item id of 1, the other with a count of 6 and it")
