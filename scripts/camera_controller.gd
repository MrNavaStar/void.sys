extends Node3D

@export var speed = 0.2
@export var zoom_speed = 1
@export var zoom_min = -12
@export var zoom_max = 30

@export var rot_zoom_start = -40
@export var rot_zoom_end = -70

@onready var pivot = $ZoomPivot
@onready var camera = $ZoomPivot/Camera3D

var pos_target: Vector3
var zoom_target: float
var rot_target: float

func _ready() -> void:
	pos_target = position
	_update_zoom_target()
	_update_rot_target()
	pivot.rotation.x = rot_target

func _update_pos_target():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	pos_target += (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized() * speed

func _update_zoom_target():
	var zoom_direction = int(Input.is_action_just_released("zoom_out")) - int(Input.is_action_just_released("zoom_in"))
	zoom_target = clamp(zoom_target + zoom_direction * zoom_speed, zoom_min, zoom_max)
	
func _update_rot_target():
	var t = clamp((zoom_target - zoom_min) / float(zoom_max - zoom_min), 0.0, 1.0)
	rot_target = deg_to_rad(lerp(rot_zoom_start, rot_zoom_end, t))

func _process(delta: float) -> void:
	_update_pos_target()
	_update_zoom_target()
	_update_rot_target()
	
	position = lerp(position, pos_target, 0.05)
	camera.position.z = lerp(camera.position.z, zoom_target, 0.1)
	pivot.rotation.x = lerp(pivot.rotation.x, rot_target, 0.1)
