@tool
class_name ItemDisplay
extends PanelContainer

signal edit_pressed
signal deleted_pressed

@onready var item_texture: TextureRect = $MarginContainer/VBoxContainer/ItemTexture
@onready var item_name: Label = $MarginContainer/VBoxContainer/ItemName
@onready var edit_item: Button = $MarginContainer/VBoxContainer/ItemTexture/EditItem
@onready var edit: MarginContainer = $Edit
@onready var delete: Button = $Delete/Delete

var id_real : bool = false

var item_id : int:
	set(value):
		item_id = value
		edit_item.tooltip_text = "ID: %s" % str(item_id)
		item_name.tooltip_text = "ID: %s" % str(item_id)
		id_change()

func id_change() -> void:
	id_real = true

func _process(delta: float) -> void:
	if id_real and ItemAccessor.item_registry.items.has(item_id):
		var item : Item = ItemAccessor.item_registry.items.get(item_id)
		item_name.text = item.display_name
		if ResourceUID.has_id(item.item_icon_uid_int):
			item_texture.texture = load(item.item_icon_uid)
		else:
			item_texture.texture = load("res://addons/masterinv/ItemManagerPanel/ImageNotFound.svg")

func _ready() -> void:
	edit_item.pressed.connect(func(): edit_pressed.emit())
	delete.pressed.connect(func(): deleted_pressed.emit(); queue_free())
