extends Node

var skip_cutscenes : bool = false
var volume : float = 100.0:
	set(value):
		print(volume)
		
		volume = value
		
		print(slider_to_db(volume))
		
		AudioServer.set_bus_volume_db(_bus_index, slider_to_db(volume))

var _bus_index : int

@onready var time : float = TIME_RESET
@onready var player_pos : Vector3 = PLAYER_POS_RESET
@onready var has_gun : bool = HAS_GUN_RESET

const TIME_RESET = 0.0
const PLAYER_POS_RESET = Vector3(0, 1, 0)
const HAS_GUN_RESET = false

func slider_to_db(slider_value: float) -> float:
	if slider_value <= 0.0:
		return -80.0 # Mute
		
	var t = slider_value / 100.0 # 0.0 to 1.0
	
	var db = 78.0 * pow(t, 2.0) - 72.0
	
	return db

func _ready() -> void:
	_bus_index = AudioServer.get_bus_index("Master")

func reset() -> void:
	time = TIME_RESET
	player_pos = PLAYER_POS_RESET
	has_gun = HAS_GUN_RESET
