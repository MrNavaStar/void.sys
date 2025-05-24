extends Node3D

@export var speed: float = 0.2
@export var zoom_speed: float = 1
@export var zoom_min: float = -10
@export var zoom_max: float = 15

@onready var camera: Camera3D = $ZoomPivot/Camera3D
var target: Vector3
var zoom_target: float


func _ready() -> void:
	target = position
	zoom_target = camera.position.z


func _process(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	target += (
		(transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized() * speed
	)
	position = lerp(position, target, 0.05)

	var zoom_direction: int = (
		int(Input.is_action_just_released("zoom_out"))
		- int(Input.is_action_just_released("zoom_in"))
	)
	zoom_target = clamp(zoom_target + zoom_direction * zoom_speed, zoom_min, zoom_max)
	camera.position.z = lerp(camera.position.z, zoom_target, 0.1)
