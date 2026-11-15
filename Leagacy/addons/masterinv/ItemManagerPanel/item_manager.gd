@tool
extends VBoxContainer

@onready var item_grid: GridContainer = %ItemGrid
@onready var save: Button = $HBoxContainer/Save
@onready var new_item_b: Button = $HBoxContainer/NewItem
@onready var search_item: LineEdit = $HBoxContainer/SearchItem
@onready var error: RichTextLabel = $Error

var item_display_packed : PackedScene = preload("res://addons/masterinv/ItemManagerPanel/ItemDisplay/item_display.tscn")

var item_accessor : GDScript = load("res://addons/masterinv/Autoloads/ItemAccessor.gd")
var ia_instance : ItemAccessorClass

var is_plugin : bool = false

var unsaved_changes : bool = false

func _process(delta: float) -> void:
	if unsaved_changes:
		save.disabled = false
		save.text = "*Save Channges"
	else:
		save.text = "Saved"
		save.disabled = true

func _ready() -> void:
	new_item_b.pressed.connect(new_item_pressed)
	
	if not Engine.has_singleton("ItemAccessor"):
		ia_instance = item_accessor.new()
		add_child(ia_instance)
		is_plugin = true
	else:
		ia_instance = ItemAccessor
	
	if not ia_instance.registry_loaded:
		await ia_instance.loaded_registry
	
	#PBFuncs.debug_print("Getting items")
	for i in ia_instance.item_registry.items:
		add_item_display(i, ia_instance.item_registry.items.get(i))
	
	save.pressed.connect(save_items)

func save_items() -> void:
	unsaved_changes = false
	ia_instance.save_registry()

func remove_item_displays() -> void:
	for i in item_grid.get_children():
		i.queue_free()

func add_item_display(id : int, item: Item) -> void:
	PBFuncs.debug_print("ID: %s" % type_string(typeof(id)))
	var item_display : ItemDisplay = item_display_packed.instantiate()
	item_grid.add_child(item_display)
	item_display.name = str(id)
	item_display.item_id = id
	item_display.edit_pressed.connect(func():
			EditorInterface.inspect_object(item)
			unsaved_changes = true
			)
	item_display.deleted_pressed.connect(func(): delete_item(id))

func delete_item(item_id : int) -> void:
	ia_instance.item_registry.items.erase(item_id)

func new_item_pressed() -> void:
	var id : int = 0
	
	while ia_instance.item_registry.items.keys().has(id):
		id += 1
	
	var fd : FileDialog = FileDialog.new()
	add_child(fd)
	
	fd.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fd.access = FileDialog.ACCESS_RESOURCES
	
	fd.filters = ["*.gd ; GDScript Files"]
	fd.popup_centered(Vector2i(700, 500))
	
	var file_path : String = await fd.file_selected
	
	var script : Script = ResourceLoader.load(file_path)
	
	if not script:
		error.show()
		error.text = "[img=0x24]res://addons/masterinv/ItemManagerPanel/StatusError.svg[color=ff5f5f] Error: Could not load script."
		return
	
	var temp_item : Variant = script.new()
	
	if not temp_item is Item:
		error.show()
		error.text = "[img=0x24]res://addons/masterinv/ItemManagerPanel/StatusError.svg[color=ff5f5f] Error: Script does not extend item."
		return
	
	var new_item : Item = temp_item
	
	new_item.id = id
	if script.get_global_name() != "":
		new_item.display_name = script.get_global_name()
	else:
		new_item.display_name = "Item"
	ia_instance.item_registry.items[id] = new_item
	add_item_display(id, new_item)
	unsaved_changes = true

class SearchItem extends Resource: ## TODO Put in PBUtils
	var string : String
	var id : int
	
	func _init(str: String, _id: int) -> void:
		string = str
		id = _id

func find_closest_strings(search_term: String, array: Array[SearchItem], top_n: int = 1) -> Array[SearchItem]: ## TODO Put in PBUtils
	var keys = array
	
	keys.sort_custom(func(a : SearchItem, b : SearchItem): 
		return search_term.similarity(a.string) > search_term.similarity(b.string)
	)
	
	return keys.slice(0, top_n)

func _on_search_item_text_changed(new_text: String) -> void:
	remove_item_displays()
	var item_name_array : Array[SearchItem]
	
	for i in ia_instance.item_registry.items:
		var item : Item = ia_instance.item_registry.items[i]
		item_name_array.append(SearchItem.new(item.display_name, item.id))
	
	var searched_array : Array[SearchItem] = find_closest_strings(new_text, item_name_array, 13)
	
	var item_sorted_array: Array[Item]
	
	for i in searched_array:
		item_sorted_array.append(ia_instance.item_registry.items.get(i.id))
	
	for i in item_sorted_array:
		add_item_display(i.id, i)
