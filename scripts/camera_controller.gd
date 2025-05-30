extends Node3D

@export var speed: float = 0.2
@export var zoom_speed: float = 1
@export var zoom_min: float = -10
@export var zoom_max: float = 15

@export var rot_zoom_start: float = -40
@export var rot_zoom_end: float = -70

@onready var pivot: Node3D = $ZoomPivot
@onready var camera: Camera3D = $ZoomPivot/Camera3D

var pos_target: Vector3
var zoom_target: float
var rot_target: float


func _ready() -> void:
	pos_target = position
	_update_zoom_target()
	_update_rot_target()
	pivot.rotation.x = rot_target


# TODO: scale movement speed relative to current zoom (closer = slower)
func _update_pos_target() -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	pos_target += (
		(transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized() * speed
	)


func _update_zoom_target() -> void:
	var zoom_direction := (
		int(Input.is_action_just_released("zoom_out"))
		- int(Input.is_action_just_released("zoom_in"))
	)
	zoom_target = clamp(zoom_target + zoom_direction * zoom_speed, zoom_min, zoom_max)


func _update_rot_target() -> void:
	var t: float = clamp((zoom_target - zoom_min) / float(zoom_max - zoom_min), 0.0, 1.0)
	rot_target = deg_to_rad(lerpf(rot_zoom_start, rot_zoom_end, t))


func _process(_delta: float) -> void:
	_update_pos_target()
	_update_zoom_target()
	_update_rot_target()

	position = lerp(position, pos_target, 0.05)
	camera.position.z = lerp(camera.position.z, zoom_target, 0.1)
	pivot.rotation.x = lerp(pivot.rotation.x, rot_target, 0.1)
