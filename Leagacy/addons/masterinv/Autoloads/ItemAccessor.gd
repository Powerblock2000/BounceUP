@tool
class_name ItemAccessorClass
extends Node

signal loaded_registry

var item_registry : ItemRegistry
var registry_loaded : bool = false

var started : bool = false

const path_prfx : String = "res://addons/masterinv/ItemRegistry/"

func _ready() -> void:
	print("Ready %s" % self)
	
	start()

func start() -> void:
	#PBFuncs.debug_print("Start")
	if not FileAccess.file_exists("%sItemRegistry.tres" % path_prfx):
		var ia : ItemRegistry = ItemRegistry.new()
		ResourceSaver.save(ia, "%sItemRegistry.tres" % path_prfx)
	
	#PBFuncs.debug_print("Loading reg")
	item_registry = ResourceLoader.load("%sItemRegistry.tres" % path_prfx)
	registry_loaded = true
	loaded_registry.emit()
	#PBFuncs.debug_print("Reg loaded")

#func _process(delta: float) -> void:
	#while ProjectSettings.get_setting("master_inventory/items/registered_items_save_path") == null:
		#await get_tree().process_frame
	#if ProjectSettings.get_setting("master_inventory/items/registered_items_save_path") != null and not started:
		#started = true
		#PBFuncs.debug_print("Path prfx found!")
		#path_prfx = ProjectSettings.get_setting("master_inventory/items/registered_items_save_path")

func refresh() -> void:
	#PBFuncs.debug_print("New prefx at: %sItemRegistry.tres" % path_prfx)
	
	if not FileAccess.file_exists("%sItemRegistry.tres" % path_prfx):
		#PBFuncs.debug_print("Saving...")
		var ia : ItemRegistry = ItemRegistry.new()
		ResourceSaver.save(ia, "%sItemRegistry.tres" % path_prfx)
	
	item_registry = ResourceLoader.load("%sItemRegistry.tres" % path_prfx)

func save_registry() -> void:
	#PBFuncs.debug_print("Saving")
	var err : Error = ResourceSaver.save(item_registry, "%sItemRegistry.tres" % path_prfx, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	if err != OK:
		push_warning("Couldnt save Item Reg: %s" % error_string(err))
