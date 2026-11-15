class_name BounceComponent
extends BaseComponent

@export var mesh_node : Node3D
## VERY finiky, reccomend staying from [code].01 - .1[/code]
@export_range(0, 1, .001, "or_greater") var intensity : float = .05

func _ready() -> void:
	_set_up.call_deferred()

func _set_up() -> void:
	if not get_tree().root.has_node("PBFuncs"):
		push_error("[Player-Bounce] - please install the helper function")
		return
	
	if not PBFuncs.class_exists("MovementModifier"):
		PBFuncs.debug_print("please add the movement modifier", true, PBFuncs.PrintTypes.error, "Player-Bounce")
		return
	
	if mesh_node == null:
		PBFuncs.debug_print("please add a mesh_node", true, PBFuncs.PrintTypes.error, "Player-Bounce")
	
	PBFuncs.debug_print("Set up", true, PBFuncs.PrintTypes.info, "Player-Bounce")

func _physics_process(_delta: float) -> void:
	if player_node.velocity.y < 0:
		mesh_node.scale = lerp(mesh_node.scale,Vector3(1, abs(player_node.velocity.y * intensity) + 1, 1), .5)
	elif player_node.velocity.y > 0:
		mesh_node.scale = lerp(mesh_node.scale, Vector3(1, -abs(player_node.velocity.y * (intensity * 2)) + 1, 1), .5)
	else:
		mesh_node.scale = lerp(mesh_node.scale,Vector3(1, abs(player_node.velocity.y * intensity) + 1, 1), .5)
