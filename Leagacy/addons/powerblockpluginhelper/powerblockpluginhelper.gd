@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("PBFuncs", "res://addons/powerblockpluginhelper/pb_func.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("PBFuncs")

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
