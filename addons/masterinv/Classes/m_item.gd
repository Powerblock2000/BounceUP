class_name Item

extends Resource

var id : int

@export var display_name :  String
@export var max_stack_size : int = 12 ## Set to -1 to ignore.
@export_storage var item_icon_uid_int : int = ResourceUID.INVALID_ID:
	set(value):
		item_icon_uid_int = value
		item_icon_uid = ResourceUID.id_to_text(item_icon_uid_int)
@export_storage var item_icon_uid : String = ""
@export_file_path(".png", ".svg") var item_icon : String:
	set(value):
		item_icon = value
		if Engine.is_editor_hint() and not item_icon.is_empty():
			item_icon_uid_int = ResourceLoader.get_resource_uid(item_icon)

func _init(_id: int = 0) -> void:
	id = _id
