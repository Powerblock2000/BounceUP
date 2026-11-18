extends Node3D

@onready var player_3d: Player3D = $Player3D
@onready var boss_audio: AudioStreamPlayer = $BossAudio
@onready var level_audio: AudioStreamPlayer = $LevelAudio

var enable_cutscene : bool = true

func setup_player() -> void:
	if IntersceneSaveManager.has_gun != true:
		level_audio.play()
	else:
		boss_audio.play()
	
	player_3d.global_position = IntersceneSaveManager.player_pos
	for c in player_3d.get_logic().get_children():
		if c.name == "DeathLogic":
			c.timer.time_elapsed = IntersceneSaveManager.time
		if c.name == "WeaponLogic":
			c.space_gun.visible = IntersceneSaveManager.has_gun

func _ready() -> void:
	if IntersceneSaveManager.has_gun:
		enable_cutscene = false
	
	
	if player_3d:
		setup_player.call_deferred()
	#pass

func _on_death_zone_body_entered(body: Node3D) -> void:
	if body is Player3D:
		for c in body.get_logic().get_children():
			if c.name == "DeathLogic":
				c.kill_player()
		for e in get_tree().get_nodes_in_group("TestingEnemies"):
			e.reset_pos()

func _on_cut_scene_zone_body_entered(body: Node3D) -> void:
	if body is Player3D and enable_cutscene:
		IntersceneSaveManager.player_pos = body.global_position
		
		for c in player_3d.get_logic().get_children():
			if c.name == "DeathLogic":
				IntersceneSaveManager.time = c.timer.time_elapsed
		get_tree().change_scene_to_file.call_deferred("res://enemy/boss_cutscene.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player3D:
		for c in player_3d.get_logic().get_children():
			if c.name == "DeathLogic":
				IntersceneSaveManager.time = c.timer.time_elapsed
		get_tree().change_scene_to_file.call_deferred("res://enemy/credits.tscn")
