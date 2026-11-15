extends Control

@onready var settings: CenterContainer = $Settings
@onready var volume: HSlider = $Settings/PanelContainer/MarginContainer/TabContainer/Audio/Volume
@onready var option_button: OptionButton = $Settings/PanelContainer/MarginContainer/TabContainer/Graphics/OptionButton

func _ready() -> void:
	load_settings.call_deferred()

func _play() -> void:
	get_tree().change_scene_to_file("res://testing/testing.tscn")

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
