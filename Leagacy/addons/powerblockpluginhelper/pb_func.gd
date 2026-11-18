@tool
extends Node

signal _resource_loaded

enum PrintTypes {info, warning, error}

var _loading_resource : bool = false
var _current_resource_loading_path : String
var _loaded_resource : Resource

var resource_loaded_status_str : String = ""
var resource_loaded_status : int

func load_in_bg(resource_path : String) -> Resource:
	if _loading_resource:
		return null
	
	_loading_resource = true
	
	_current_resource_loading_path = resource_path
	ResourceLoader.load_threaded_request(resource_path)
	await _resource_loaded
	return _loaded_resource

func _process(delta: float) -> void:
	if _loading_resource:
		var status : int = ResourceLoader.load_threaded_get_status(_current_resource_loading_path)
		resource_loaded_status = status
		
		if status == 0:
			resource_loaded_status_str = "invalid resource"
			_loaded_resource = null
			_resource_loaded.emit()
			_loading_resource = false
			return
		elif status == 1:
			resource_loaded_status_str = "loading in progress"
		elif status == 2:
			resource_loaded_status_str = "loading failed"
			_loaded_resource = null
			_resource_loaded.emit()
			_loading_resource = false
			return
		elif status == 3:
			resource_loaded_status_str = "sucessfully loaded resource"
			_loaded_resource = ResourceLoader.load_threaded_get(_current_resource_loading_path)
			_resource_loaded.emit()
			_loading_resource = false
			return

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
