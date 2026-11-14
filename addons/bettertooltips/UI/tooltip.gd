extends PanelContainer

func _process(_delta: float) -> void:
	size = Vector2.ZERO
	global_position = get_viewport().get_mouse_position()
