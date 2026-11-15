class_name CameraSwapSidesComponent

extends BaseComponent

## Input action required to be pressed to toggle camera locations
@export var input : StringName = "PL_swap_camera"

## Defualt position of the camera
@export var side_one : Vector3
## Alternate position of the camera
@export var side_two : Vector3

## The [Camera3D] node
@export var camera : Camera3D

## The time it takes for the camera to switch
@export var time : float = .1

var _current_side : bool = true
var _swapping : bool = false

var _camera_pos : Vector3

func _physics_process(delta: float) -> void:
	if not _swapping: return
	
	var err : Dictionary = component_manager.get_component("PBMovementComponent")
	if err["error"] == "none":
		var component : BaseComponent = err["BaseComponent"]
		if component is PBMovementComponent:
			component.camera_original_pos = _camera_pos

func swap_camera() -> void:
	
	if _swapping: return
	var next_side : Vector3 = side_one
	if _current_side == true:
		next_side = side_two
	
	if _current_side == false:
		_camera_pos = side_two
	else:
		_camera_pos = side_one
	
	_current_side = !_current_side
	
	_swapping = true
	var tween : Tween = player_node.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "_camera_pos", next_side, .1)
	await tween.finished
	_swapping = false
	return

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(input):
		swap_camera()
