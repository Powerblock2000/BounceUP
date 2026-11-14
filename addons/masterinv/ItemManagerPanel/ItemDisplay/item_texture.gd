@tool
extends TextureRect

@onready var edit_item: Button = $EditItem

func _ready() -> void:
	mouse_entered.connect(func(): edit_item.show())
	edit_item.mouse_exited.connect(func(): edit_item.hide())
