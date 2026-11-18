extends Node

@onready var animation_player: AnimationPlayer = $"../../Lose/AnimationPlayer"
@onready var play: FancyButton = $"../../Lose/Play"
@onready var player_3d: Player3D = $"../.."
@onready var timer: Label = $"../../Time/Label"
@onready var lose: Control = $"../../Lose"
@onready var camera_3d: Camera3D = $"../../Camera3D"

@onready var player_original_transform : Transform3D = player_3d.transform
@onready var camera_original_transform : Transform3D = camera_3d.transform

func kill_player() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	animation_player.play("Lose")
	play.disabled = true
	await animation_player.animation_finished
	play.disabled = false
	await play.pressed
	death_func()

func death_func() -> void:
	player_3d.global_position = player_original_transform.origin
	player_3d.velocity = Vector3.ZERO
	player_3d.rotation = player_original_transform.basis.get_euler()
	camera_3d.rotation = camera_original_transform.basis.get_euler()
	lose.hide()
	timer.reset()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
