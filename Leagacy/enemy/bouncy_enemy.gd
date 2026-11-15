class_name Enemy
extends CharacterBody3D

signal killed

@export var player_node : Player3D
@export var collision_shape : CollisionShape3D
@export var speed : float = 5.0
@export var intensity : float = 20
@export var player_enter_area : Area3D
@export var mesh : Node3D ## NOT REQUIRED

@onready var bounce_area: Area3D = $BounceArea

func tint_3d_node(node : Node, color : Color) -> void:
	if node is MeshInstance3D and node.mesh:
		for i in range((node as MeshInstance3D).mesh.get_surface_count()):
			var mat : Material = (node as MeshInstance3D).get_surface_override_material(i)
			if not mat:
				mat = (node as MeshInstance3D).mesh.surface_get_material(i)
			
			if mat and mat is StandardMaterial3D:
				var new_mat : StandardMaterial3D = mat.duplicate() as StandardMaterial3D
				new_mat.albedo_color = color
				(node as MeshInstance3D).set_surface_override_material(i, new_mat)
	
	for child in node.get_children():
		tint_3d_node(child, color)

var health : int = 100:
	set(value):
		if value < health:
			if mesh != null:
				tint_3d_node(mesh, Color.RED)
				var tw : Tween = create_tween()
				tw.tween_method(tint_3d_node, Color.RED, Color.WHITE, .5)
		health = value

var do_stuff : bool = false
var _follow_player : bool = false

func _ready() -> void:
	var ba_has_cs : bool = false
	
	for c in bounce_area.get_children():
		if c is CollisionShape3D:
			ba_has_cs = true
			break
	
	if player_node == null or collision_shape == null or not ba_has_cs or player_enter_area == null:
		print("SET YOUR PLAYER AND COLLISION AND PLAYER ENTER AREA NODE ON %s!!!!" % self)
		return
	
	player_enter_area.body_entered.connect(body_entered_player_area)
	player_enter_area.body_exited.connect(body_exited_player_area)
	
	do_stuff = true

func body_exited_player_area(body : Node3D) -> void:
	if body is Player3D:
		_follow_player = false

func body_entered_player_area(body : Node3D) -> void:
	if body is Player3D:
		_follow_player = true

var hit_player_when_in_this_area : bool = false
func _physics_process(_delta: float) -> void:
	if do_stuff:
		if health <= 0:
			killed.emit()
			queue_free()
		
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
						(b as Player3D).velocity += dir * intensity
						hit_player_when_in_this_area = true
					hit_player = true
			
			if not hit_player:
				hit_player_when_in_this_area = false
