class_name AudioPlayOnHoverComponenet
extends FancyUIComponent

@export var audio_file : AudioStream
@export_range(-80, 24, .01, "prefer_slider", "or_greater", "or_less") var volume : float = 0.0
@export_custom(PROPERTY_HINT_AUDIO_BUS, "") var bus : StringName = &"Master"

func _init() -> void:
	trigger.connect(triggered)

func triggered(c_node: Control, _context : Dictionary) -> void:
	play_audio(c_node)

func play_audio(c_node : Control) -> void:
	var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
	c_node.add_child(audio_player)
	audio_player.stream = audio_file
	audio_player.bus = bus
	audio_player.volume_db = volume
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()
