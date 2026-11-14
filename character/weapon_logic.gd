extends Node

@onready var space_gun: Node3D = %SpaceGun
@onready var ray_cast_3d: RayCast3D = $"../../Camera3D/RayCast3D"

var _use_weapon : bool = false

var cooldown_active : bool = false

var cooldown_timer : Timer = Timer.new()

func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.autostart = false
	add_child(cooldown_timer)
	cooldown_timer.timeout.connect(cooldown_finished)

func cooldown_finished() -> void:
	cooldown_active = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("PL_shoot") and cooldown_active != true and _use_weapon:
		var ray_cast_collider : Object = ray_cast_3d.get_collider()
		if ray_cast_collider != null:
			if ray_cast_collider is Enemy:
				ray_cast_collider.health -= 10
		cooldown_active = true
		cooldown_timer.start(5)

func _process(_delta: float) -> void:
	space_gun.visible = _use_weapon
