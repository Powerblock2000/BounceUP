class_name InventoryComponent

extends BaseComponent

var inventory : Inventory

@export_range(0, 20, 1, "or_greater") var inventory_size : int = 6

func _ready() -> void:
	inventory = Inventory.new(inventory_size)
