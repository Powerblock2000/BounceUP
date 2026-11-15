class_name PBMovementComponent
## Customized, easily expandable movement that can be modified using [MovementModifier]s
##
## [i][color=yellow]DISCLAIMER[/color] the base movement code is modified from MajikayoGames SimpleFPSController (CC0). Github repo is linked below[/i]
##
## @tutorial(MajikayoGames SimpleFPSController Github Repo): https://github.com/majikayogames/SimpleFPSController/

extends BaseComponent

@export_group("Input Settings")
## [b]DO NOT REARRANGE[/b] Set these to the equivalent InputAction names or add these to your settings.
@export var input : Array[StringName] = [&"MV_forward", &"MV_left", &"MV_backward", &"MV_right", &"MV_jump"]

@export_group("Model Settings")
@export var smoothly_rotate_model : bool = true
@export var rotation_speed : float = 10.0

@export_group("Camera Settings")
## Camera sensitivity on mouse
@export var mouse_look_sensitivity : float = 0.006
## Camera sensitivity on controller
@export var controller_look_sensitivity := 0.05

## If enabled, this hides the mesh_node for the specified camera. Recommended for FPS games.
@export var hide_mesh_nodes : bool = false
## Bobs the camera up and down
@export var headbob_effect : bool = false
## The [method clamp] of degrees that the camera cannot pass on the bottom
@export_range(0, 90, 1, "or_greater", "or_less") var bottom_degree_cap : float = 60
## The [method clamp] of degrees that the camera cannot pass on the top
@export_range(-90, 0, 1, "or_greater", "or_less") var top_degree_cap : float = -60
## The weight of the [method lerp] for the cameras position
@export_range(.01, 1, .01, "or_greater", "or_less") var camera_smoothing : float = .1
## How much the camera moves while headbobing
@export_range(0, 1, .01, "or_greater", "or_less") var headbob_move_amount = 0.03
## How fast the head moves while headbobing
@export_range(0, 5, .1, "or_greater", "or_less") var headbob_frequency = 2.4
var camera_original_pos : Vector3

@export_subgroup("Camera Node Settings")
## This node is all visual nodes of the player
@export var mesh_node : Node3D
## Camera node
@export var camera_node : Camera3D
## The node the camera pivots arround. Set this to the Camera for a first person game or a [Node3D] where you want the Camera to pivot for 3rd person
@export var pivot_node : Node3D
var _headbob_time := 0.0
var _headbobing : bool = false

@export_group("Movement Settings")
@export_subgroup("Jump Settings")
## Applies this velocity to the player when jumping
@export var jump_velocity := 6.0
## Automatically gain speed when jumping by holding spcace. Recommended OFF.
@export var auto_bhop := false

# Ground movement settings
@export_subgroup("Ground Settings")
## Speed at which the player walks
@export var walk_speed := 7.0
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0
@export var crouch_friction := 3.0

# Air movement settings.
@export_subgroup("Air Settings")
## Can surf steeper ramps if this is higher, makes it easier to stick and bhop
@export var air_cap := 0.85
@export var air_accel := 800.0
@export var air_move_speed := 500.0

var _wish_dir := Vector3.ZERO

## Project gravity is multiplied by this.
var gravity_intensity : float = 1.0

func trigger_modifier(modifier: MovementModifier) -> void:
	modifier.trigger(self)

func _ready() -> void:
	camera_original_pos = camera_node.transform.origin
	
	_set_up.call_deferred()
	
	for child in mesh_node.get_children():
		if child is VisualInstance3D and hide_mesh_nodes:
			child.set_layer_mask_value(1, false)
			child.set_layer_mask_value(2, true)

func _set_up() -> void:
	if not get_tree().root.has_node("PBFuncs"):
		push_error("[Player] - please install the helper function")
		return
	
	if not PBFuncs.class_exists("MovementModifier"):
		PBFuncs.debug_print("please add the movement modifier", true, PBFuncs.PrintTypes.error, "Player")
		return
	
	PBFuncs.debug_print("Set up", true, PBFuncs.PrintTypes.info, "Player")

func get_move_speed() -> float:
	return walk_speed

func _unhandled_input(event):
	if event is InputEventMouseButton: # TODO Remove for UI
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # TODO Remove for UI
	elif event.is_action_pressed("ui_cancel"): # TODO Remove for UI
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # TODO Remove for UI
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			player_node.rotate_y(-event.relative.x * mouse_look_sensitivity)
			#mesh_node.rotate_y(event.relative.x * mouse_look_sensitivity)
			pivot_node.rotate_x(-event.relative.y * mouse_look_sensitivity)
			pivot_node.rotation.x = clamp(pivot_node.rotation.x, deg_to_rad(top_degree_cap), deg_to_rad(bottom_degree_cap))

func camera_processing(delta):
	if not headbob_effect or not _headbobing:
		camera_node.transform.origin = lerp(camera_node.transform.origin, camera_original_pos, camera_smoothing)
		return
	_headbob_time += delta * player_node.velocity.length()
	camera_node.transform.origin = lerp(camera_node.transform.origin, Vector3(
		cos(_headbob_time * headbob_frequency * 0.5) * headbob_move_amount,
		sin(_headbob_time * headbob_frequency) * headbob_move_amount,
		0
	) + camera_original_pos, camera_smoothing)
# Smoothly interpolated controller look with acceleration and deceleration
var _cur_controller_look = Vector2()
func _handle_controller_look_input(delta):
	pass
	#var target_look = Input.get_vector("look_left", "look_right", "look_down", "look_up").normalized()
	#
	#if target_look.length() < _cur_controller_look.length():
	#	_cur_controller_look = target_look
	#else:
	#	_cur_controller_look = _cur_controller_look.lerp(target_look, 5.0 * delta)
	#
	#player_node.rotate_y(-_cur_controller_look.x * controller_look_sensitivity) # turn left and right
	#camera_node.rotate_x(_cur_controller_look.y * controller_look_sensitivity) # look up and down
	#camera_node.rotation.x = clamp(camera_node.rotation.x, deg_to_rad(-90), deg_to_rad(90)) # clamp up and down range

func _process(delta):
	_handle_controller_look_input(delta)

func clip_velocity(normal: Vector3, overbounce : float, delta : float) -> void:
	# When strafing into wall, + gravity, velocity will be pointing much in the opposite direction of the normal
	# So with this code, we will back up and off of the wall, cancelling out our strafe + gravity, allowing surf.
	var backoff := player_node.velocity.dot(normal) * overbounce
	# Not in original recipe. Maybe because of the ordering of the loop, in original source it
	# shouldn't be the case that velocity can be away away from plane while also colliding.
	# Without this, it's possible to get stuck in ceilings
	if backoff >= 0: return
	
	var change := normal * backoff
	player_node.velocity -= change
	
	# Second iteration to make sure not still moving through plane
	# Not sure why this is necessary but it was in the original recipe so keeping it.
	var adjust := player_node.velocity.dot(normal)
	if adjust < 0.0:
		player_node.velocity -= normal * adjust

func is_surface_too_steep(normal : Vector3) -> bool:
	var max_slope_ang_dot = Vector3(0,1,0).rotated(Vector3(1.0,0,0), player_node.floor_max_angle).dot(Vector3(0,1,0))
	if normal.dot(Vector3(0,1,0)) < max_slope_ang_dot:
		return true
	return false

func _handle_air_physics(delta) -> void:
	player_node.velocity.y -= (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_intensity) * delta
	
	# Classic battle tested & fan favorite source/quake air movement recipe.
	# CSS players gonna feel their gamer instincts kick in with this one
	var cur_speed_in_wish_dir = player_node.velocity.dot(_wish_dir)
	# Wish speed (if wish_dir > 0 length) capped to air_cap
	var capped_speed = min((air_move_speed * _wish_dir).length(), air_cap)
	# How much to get to the speed the player wishes (in the new dir)
	# Notice this allows for infinite speed. If wish_dir is perpendicular, we always need to add velocity
	#  no matter how fast we're going. This is what allows for things like bhop in CSS & Quake.
	# Also happens to just give some very nice feeling movement & responsiveness when in the air.
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta # Usually is adding this one.
		accel_speed = min(accel_speed, add_speed_till_cap) # Works ok without this but sticking to the recipe
		player_node.velocity += accel_speed * _wish_dir
	
	if player_node.is_on_wall():
		# The floating mode is much better and less jittery for surf
		# This bit of code is tricky. Will toggle floating mode in air
		# is_on_floor() never triggers in floating mode, and instead is_on_wall() does.
		if is_surface_too_steep(player_node.get_wall_normal()):
			player_node.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			player_node.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		clip_velocity(player_node.get_wall_normal(), 1, delta) # Allows surf

func _handle_ground_physics(delta) -> void:
	# Similar to the air movement. Acceleration and friction on ground.
	var cur_speed_in_wish_dir = player_node.velocity.dot(_wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		player_node.velocity += accel_speed * _wish_dir
	
	# Apply friction
	var control = max(player_node.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(player_node.velocity.length() - drop, 0.0)
	if player_node.velocity.length() > 0:
		new_speed /= player_node.velocity.length()
	player_node.velocity *= new_speed
	
	# Make Model look
	
	#var dir : Vector3 = Vector3(player_node.velocity.x, 0, 0)
	#if dir.length_squared() > 0.01 and smoothly_rotate_model:
	#	var target_angle : float = atan2(-dir.x, -dir.z)
	#	
	#	var diff = angle_difference(mesh_node.rotation.y, target_angle)
	#	#if rad_to_deg(diff) >= 160 or rad_to_deg(diff) <= 160:
	#	#	diff = deg_to_rad(-2)
	#	print(rad_to_deg(diff))
	#	
	#	mesh_node.rotation.y += diff * (1.0 - exp(-rotation_speed * delta))

func _physics_process(delta):
	var input_dir = Input.get_vector(input[1], input[3], input[0], input[2]).normalized()
	# Depending on which way you have you character facing, you may have to negate the input directions
	_wish_dir = player_node.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	
	if player_node.is_on_floor():
		if Input.is_action_just_pressed(input[4]) or (auto_bhop and Input.is_action_pressed(input[4])):
			player_node.velocity.y = jump_velocity
		_handle_ground_physics(delta)
		_headbobing = true
	else:
		_handle_air_physics(delta)
		_headbobing = false
	camera_processing(delta)
	
	player_node.move_and_slide()
