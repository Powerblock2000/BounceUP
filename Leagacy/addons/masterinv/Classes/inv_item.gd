class_name InvItem
extends Node

@export_storage var item_id : int
@export_storage var count : int
@export_storage var max_count : int
@export_storage var inv_id : int
	
func _init(_id: int = -1, _count: int = 1, _max_count : int = 6) -> void:
	item_id = _id
	count = _count
	max_count = _max_count

func to_array() -> Array[int]: ## Returns an [Array]. Index 0 is the ID. Index 1 is the count. Index 2 is the max count
	return [item_id, count, max_count]

static func from_array(array : Array[int]) -> InvItem:
	if array.size() != 3:
		return null
	
	return InvItem.new(array[0], array[1], array[2])

func get_item() -> Item:
	#if ItemAccessor.started != true:
	#	await ItemAccessor.loaded_registry
	
	var item : Item = ItemAccessor.item_registry.items.get(item_id)
	if item != null:
		return item
	else:
		return null
