extends Control

var is_ready : bool = false

@onready var fps_label: Label = $FPSLabel

func _set_is_ready() -> void:
	is_ready = true

func _ready() -> void:
	_set_is_ready.call_deferred()

func _process(_delta: float) -> void:
	if is_ready:
		fps_label.text = "FPS: %s" % Engine.get_frames_per_second()
