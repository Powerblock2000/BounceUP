extends Node

@onready var animation_player: AnimationPlayer = $"../../Lose/AnimationPlayer"
@onready var play: FancyButton = $"../../Lose/Play"
@onready var player_3d: Player3D = $"../.."
@onready var timer: Label = $"../../Time/Label"

func kill_player() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	animation_player.play("Lose")
	play.disabled = true
	await animation_player.animation_finished
	play.disabled = false
	await play.pressed
	player_3d.global_position = Vector3(0, 1, 0)
	animation_player.play_backwards("Lose")
	await animation_player.animation_finished
	timer.reset()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
