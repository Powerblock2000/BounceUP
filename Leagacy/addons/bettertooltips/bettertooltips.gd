@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("TooltipManager", "res://addons/bettertooltips/UI/better_tooltips.tscn")

func _disable_plugin() -> void:
	remove_autoload_singleton("TooltipManager")
