class_name BasicScaleComponent
extends FancyUIComponent

@export var large_value : Vector2 = Vector2(1.1, 1.1)
@export var small_value  : Vector2 = Vector2(1, 1)
@export var time : float = .1
@export var tween_process_mode : Tween.TweenPauseMode

func _init() -> void:
	trigger.connect(triggered)

var original_z : int = 0
func triggered(_node : Control, _context: Dictionary) -> void:
	if _node.get_parent() is Container:
		_node.offset_transform_enabled
		prefix = "offset_transform_"
	else:
		prefix = ""
	
	if _context.has("signal"):
		if _context.get("signal") == &"mouse_entered":
			scale_up(_node)
		elif _context.get("signal") == &"mouse_exited":
			scale_down(_node)

var prefix : String = ""

func scale_up(c_node : Control) -> void:
	c_node.z_index = 5
	var tween : Tween = c_node.create_tween()
	tween.set_pause_mode(tween_process_mode)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(c_node, "%sscale" % prefix, large_value, time)

func scale_down(c_node : Control) -> void:
	c_node.z_index = original_z
	var tween : Tween = c_node.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(c_node, "%sscale" % prefix, small_value, time)
