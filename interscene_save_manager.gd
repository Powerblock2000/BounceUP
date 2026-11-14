extends Node

@onready var time : float = TIME_RESET
@onready var player_pos : Vector3 = PLAYER_POS_RESET
@onready var has_gun : bool = HAS_GUN_RESET

const TIME_RESET = 0.0
const PLAYER_POS_RESET = Vector3(0, 1, 0)
const HAS_GUN_RESET = false

func reset() -> void:
	time = TIME_RESET
	player_pos = PLAYER_POS_RESET
	has_gun = HAS_GUN_RESET
