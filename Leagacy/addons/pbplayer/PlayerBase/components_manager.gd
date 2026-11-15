class_name ComponentsManager
extends Node

func has_component(c_name: StringName) -> bool:
	for c in get_children():
		if c is BaseComponent and c.name == c_name:
			return true
	return false

func disable_component(c_name: StringName) -> bool: ## Disable a component. Pass in the componets name to disable. Returns [code]true[/code] if found, [code]false[/code] if not
	for c in get_children():
		if c is BaseComponent and c.name == c_name:
			c.process_mode = Node.PROCESS_MODE_DISABLED
			return true
	return false

func get_component(c_name : StringName) -> Dictionary: ## Returns a dictionary with [code]"BaseComponent"[/code] as either the Component requested or [code]null[/code][br][br]Returns [code]error[/code] as [code]"none"[/code] or an error as a [String].
	for c in get_children():
		if c is BaseComponent and c.name == c_name:
			return {"BaseComponent": c, "error": "none"}
		elif c.name == c_name:
			return {"BaseComponent": null, "error": "Couldnt find component with name: %s; only found a non-component node." % c_name}
	return {"BaseComponent": null, "error": "Couldnt find component with name: %s" % c_name}

func _ready() -> void:
	if not get_parent() is Player3D:
		push_warning("Node: %s must be a direct child of %s" % [self, "Player3D"])
		if OS.is_debug_build():
			PBFuncs.debug_print("Canceling component execution...")
		_stop_components()
		return
	
	var idx : int = 0
	for c in get_children():
		if c is BaseComponent:
			c.player_node = get_parent()
			c.component_manager = self
			idx += 1
	if OS.is_debug_build():
		PBFuncs.debug_print("Enabled %s components." % idx)

func _stop_components() -> void:
	for c in get_children():
		if c is BaseComponent:
			c.process_mode = Node.PROCESS_MODE_DISABLED
