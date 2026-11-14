@tool
extends EditorPlugin

var dock : EditorDock 

func _enable_plugin() -> void:
	add_autoload_singleton("ItemAccessor", "res://addons/masterinv/Autoloads/ItemAccessor.gd")
	#add_custom_type("Inventory", "Resource", load("res://addons/masterinv/Classes/m_inventory.gd"), load("res://icon.svg"))

func _disable_plugin() -> void:
	remove_autoload_singleton("ItemAccessor")
	#remove_custom_type("Inventory")

func _enter_tree() -> void:
	var item_manager_dock : VBoxContainer = preload("res://addons/masterinv/ItemManagerPanel/ItemManager.tscn").instantiate()
	dock = EditorDock.new()
	dock.add_child(item_manager_dock)
	
	dock.title = "Item Manager"
	
	dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	dock.available_layouts = EditorDock.DOCK_LAYOUT_FLOATING
	
	add_dock(dock)
	
	ProjectSettings.set_setting("master_inventory/items/registered_items_save_path", "res://addons/masterinv/ItemRegistry/")
	
	ProjectSettings.add_property_info({
		"name": "master_inventory/items/registered_items_save_path",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR,
		"hint_string": ""
	})
	
	ProjectSettings.set_initial_value("master_inventory/items/registered_items_save_path", "res://addons/masterinv/ItemRegistry/")
	
	ProjectSettings.save()

func _exit_tree() -> void:
	remove_dock(dock)
	dock.queue_free()
