class_name RuntimeItemDisplay

extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var margin_container : MarginContainer = $MarginContainer

@export var margin : int = 3

@export var item_id : int = -1:
	set(id):
		item_id = id
		set_texture.call_deferred(id)

func _ready() -> void:
	set_margin.call_deferred(margin)

func set_margin(_margin : int) -> void:
	print("seting margin")
	margin_container.add_theme_constant_override("margin_bottom", _margin)
	margin_container.add_theme_constant_override("margin_left", _margin)
	margin_container.add_theme_constant_override("margin_right", _margin)
	margin_container.add_theme_constant_override("margin_top", _margin)

func set_texture(id: int) -> void:
	if id == -1:
		texture_rect.texture = null
	
	var inv_item : InvItem = InvItem.new(id)
	var item : Item = inv_item.get_item()
	
	texture_rect.texture = load(item.item_icon)
