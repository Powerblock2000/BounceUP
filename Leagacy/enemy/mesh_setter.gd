extends Node

@onready var animal_cow_2: Node3D = $"../Mesh/animal-cow2"

var mesh_scenes : Dictionary[String, String] = {"dog": "res://assets/cube_pets/Models/GLB format/animal-dog.glb", "cow": "res://assets/cube_pets/Models/GLB format/animal-cow.glb", "bee": "res://assets/cube_pets/Models/GLB format/animal-bee.glb", "bunny": "res://assets/cube_pets/Models/GLB format/animal-bunny.glb", "chick": "res://assets/cube_pets/Models/GLB format/animal-chick.glb"}
@onready var mesh: Node3D = $"../Mesh"

func _ready() -> void:
	var mesh_path : String = mesh_scenes[mesh_scenes.keys()[randi_range(0, mesh_scenes.size() - 1)]]
	print(mesh_path)
	set_mesh.call_deferred(mesh_path)

func set_mesh(mesh_path : String) -> void:
	animal_cow_2.queue_free()
	var mesh_node : Node3D = (load(mesh_path) as PackedScene).instantiate()
	mesh.add_child(mesh_node)
	mesh_node.position = Vector3(0, -.75, 0)
