class_name Enemy
extends CharacterBody3D

@export var player_node : Player3D
@export var speed : float = 5.0
@export var intensity : float = 20
@export var follow_area : Area3D
@export var mesh : Node3D

@onready var bounce_area: Area3D = $BounceArea
@onready var original_pos : Vector3 = global_position
@onready var original_rotation : Vector3 = rotation

var active : bool = false
var _follow_player : bool = false

func reset_pos():
	mesh.global_position = original_pos
	global_position = original_pos
	mesh.rotation = original_rotation
	rotation = original_rotation

func _ready() -> void:
	var ba_has_cs : bool = false
	
	for c in bounce_area.get_children():
		if c is CollisionShape3D:
			ba_has_cs = true
			break
	
	if player_node == null or not ba_has_cs or follow_area == null or mesh == null:
		print("SET YOUR PLAYER AND MESH AND PLAYER ENTER AREA NODE ON %s!!!!" % self)
		return
	
	follow_area.body_entered.connect(body_entered_player_area)
	follow_area.body_exited.connect(body_exited_player_area)
	
	active = true

func set_up_def() -> void:
	mesh.top_level = true

func body_exited_player_area(body : Node3D) -> void:
	if body is Player3D:
		_follow_player = false

func body_entered_player_area(body : Node3D) -> void:
	if body is Player3D:
		_follow_player = true

var hit_player_when_in_this_area : bool = false
func _physics_process(_delta: float) -> void:
	if active:
		
		if not follow_area.get_overlapping_bodies().has(player_node):
			global_position.y = original_pos.y
		
		mesh.global_position = Vector3(global_position.x, original_pos.y, global_position.z)
		
		var dir : Vector3 = global_position.direction_to(player_node.global_position)
		if _follow_player:
			
			look_at(player_node.global_position, Vector3(0, 1, 0), true)
			
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			
			move_and_slide()
		
		var hit_player : bool = false
		if bounce_area.has_overlapping_bodies():
			#print(bounce_area.get_overlapping_bodies())
			for b in bounce_area.get_overlapping_bodies():
				if b is Player3D:
					if not hit_player_when_in_this_area:
						(b as Player3D).velocity = dir * intensity
						#(b as Player3D).velocity = dir * (b as Player3D).velocity.
						hit_player_when_in_this_area = true
					hit_player = true
			
			if not hit_player:
				hit_player_when_in_this_area = false
