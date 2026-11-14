@tool
extends Node

enum PrintTypes {info, warning, error}

#func open_window() -> Browser:
#	return (load("res://addons/powerblockpluginhelper/browser/browser.tscn") as PackedScene).instantiate()

func _ready() -> void:
	if OS.has_feature("debug"):
		print_rich("[color=yellow]Logs from powertools plugins are removed when running without the debug feature[/color]")

func class_exists(n_class : StringName) -> bool:
	for c in ProjectSettings.get_global_class_list():
		if c["class"] == n_class:
			return true
	return false

func debug_print(
		message : String,
		require_debug : bool = true,
		type : PrintTypes = PrintTypes.info,
		prefix : String = "Deubg",
	) -> void:
	if require_debug and not OS.has_feature("debug"): return
	
	if type == PrintTypes.info:
		print("[%s] - %s" % [prefix, message])
	elif type == PrintTypes.warning:
		push_warning("[%s] - %s" % [prefix, message])
	else:
		push_error("[%s] - %s" % [prefix, message])
