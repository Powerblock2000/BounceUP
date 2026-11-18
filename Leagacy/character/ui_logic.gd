extends Node

@onready var in_game_ui: CenterContainer = $"../../InGameUi"
@onready var timer_l: Label = $"../../Time/Label"
@onready var death_logic: Node = $"../DeathLogic"
@onready var components: ComponentsManager = %Components

func resume() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	timer_l.timer_on = true
	get_tree().paused = false
	
	in_game_ui.hide()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("KY_escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		timer_l.timer_on = false
		in_game_ui.show()
		get_tree().paused = true

func _on_resume_pressed() -> void:
	resume()

func _on_reset_pressed() -> void:
	death_logic.death_func()
	
	get_tree().get_first_node_in_group("minor_audio").play()
	get_tree().get_first_node_in_group("major_audio").stop()
	
	for e in get_tree().get_nodes_in_group("TestingEnemies"):
		e.reset_pos()
	
	resume()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
