extends Control

@onready var settings: CenterContainer = $Settings
@onready var volume: HSlider = $Settings/PanelContainer/MarginContainer/TabContainer/Audio/Volume
@onready var window_mode: OptionButton = $Settings/PanelContainer/MarginContainer/TabContainer/Graphics/OptionButton
@onready var skip_cutscenes: CheckBox = $Settings/PanelContainer/MarginContainer/TabContainer/Cutscenes/SkipCutscenes
@onready var loading: ColorRect = $Loading
@onready var loading_status: Label = $Loading/Status

func _ready() -> void:
	load_settings.call_deferred()

func _play() -> void:
	#get_tree().change_scene_to_file("res://testing/testing.tscn")
	loading.show()
	var scene : PackedScene = await PBFuncs.load_in_bg("res://testing/testing.tscn")
	if scene == null:
		await get_tree().create_timer(2).timeout
		loading.hide()
	
	get_tree().change_scene_to_packed(scene)

func _leave() -> void:
	get_tree().quit()

func _on_volume_drag_ended(_value_changed: bool) -> void:
	IntersceneSaveManager.volume = volume.value

func _on_skip_cutscenes_toggled(toggled_on: bool) -> void:
	IntersceneSaveManager.skip_cutscenes = toggled_on

func _on_close_pressed() -> void:
	settings.hide()
	
	save_settings()

func load_settings() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		var cfg : ConfigFile = ConfigFile.new()
		cfg.load("user://settings.cfg")
		IntersceneSaveManager.skip_cutscenes = cfg.get_value("settings", "skip_cutscenes")
		IntersceneSaveManager.volume = cfg.get_value("settings", "volume")
		if cfg.has_section_key("settings", "window_mode"):
			DisplayServer.window_set_mode(cfg.get_value("settings", "window_mode"))
		
		volume.value = IntersceneSaveManager.volume
		skip_cutscenes.button_pressed = IntersceneSaveManager.skip_cutscenes
		
		if DisplayServer.window_get_mode() == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			window_mode.selected = 1
		else:
			window_mode.selected = 0

func save_settings() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	cfg.set_value("settings", "skip_cutscenes", IntersceneSaveManager.skip_cutscenes)
	cfg.set_value("settings", "volume", IntersceneSaveManager.volume)
	cfg.set_value("settings", "window_mode", DisplayServer.window_get_mode())
	cfg.save("user://settings.cfg")

func _on_settings_pressed() -> void:
	settings.show()

func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
