extends Label

func _process(_delta: float) -> void:
	if PBFuncs._loading_resource:
		text = PBFuncs.resource_loaded_status_str
