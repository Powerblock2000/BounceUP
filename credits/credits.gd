extends Control

@onready var time_l: Label = $Time
@onready var button: Button = $Button

func format_time(seconds : float) -> String:
	var mins : int = int(seconds) / 60
	var secs : int = int(seconds) % 60
	var msec : int = int((seconds - int(seconds)) * 100)
	
	return "%02d:%02d:%02d" % [mins, secs, msec]

func start_credits(time : float) -> void:
	$RichTextLabel.visible_ratio = 0
	$AudioStreamPlayer.play()
	var tw : Tween = create_tween()
	tw.tween_property($RichTextLabel, "visible_ratio", 1, time)
	if not IntersceneSaveManager.skip_cutscenes:
		await tw.finished
		await get_tree().create_timer(1).timeout
	time_l.text = "Your time was: %s" % format_time(IntersceneSaveManager.time)
	button.disabled = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	start_credits.call_deferred(44.3)

func _on_button_pressed() -> void:
	IntersceneSaveManager.reset()
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
