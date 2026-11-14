extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("BossIntro")
	await $AnimationPlayer.animation_finished
	IntersceneSaveManager.has_gun = true
	get_tree().change_scene_to_file("res://testing/testing.tscn")
