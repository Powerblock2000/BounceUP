extends Control

func _play() -> void:
	get_tree().change_scene_to_file("res://testing/testing.tscn")

func _leave() -> void:
	get_tree().quit()
