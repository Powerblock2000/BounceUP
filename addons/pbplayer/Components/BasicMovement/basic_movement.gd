class_name BasicMovementComponent
extends BaseComponent

@export var jump_velocity : float = 4.5
@export var speed : float = 5.0
@export var input : Array[StringName] = [&"MV_forward", &"MV_left", &"MV_backward", &"MV_right", &"MV_jump"]

var _has_input_actions : bool = false

func _ready() -> void:
	var _missing_input_actions : Array[StringName] = []
	for i in input:
		if not InputMap.has_action(i):
			_missing_input_actions.append(i)
	
	if _missing_input_actions.size() != 0:
		var _input_actions_string : String = ""
		var _idx : int = 0
		for i in _missing_input_actions:
			var _suffix : String = ", "
			if _idx == _missing_input_actions.size() - 1:
				_suffix = ""
			elif _idx == _missing_input_actions.size() - 2:
				_suffix = ", and"
			
			#print(i)
			
			_input_actions_string += "%s%s" % [i, _suffix]
			#print(_input_actions_string)
			_idx += 1
		
		PBFuncs.debug_print("Please add Input Action(s): %s" % _input_actions_string, true, PBFuncs.PrintTypes.error, "Player - BasicMovement")
		return
	
	_has_input_actions = true

func _physics_process(delta: float) -> void:
	if not player_node or not _has_input_actions:
		#print("Disabled")
		return
	
	#print("Enabled")
	
	# Add the gravity.
	if not player_node.is_on_floor():
		player_node.velocity += player_node.get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(input[4]) and player_node.is_on_floor():
		player_node.velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(input[1], input[3], input[0], input[2])
	var direction := (player_node.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player_node.velocity.x = direction.x * speed
		player_node.velocity.z = direction.z * speed
	else:
		player_node.velocity.x = move_toward(player_node.velocity.x, 0, speed)
		player_node.velocity.z = move_toward(player_node.velocity.z, 0, speed)

	player_node.move_and_slide()
