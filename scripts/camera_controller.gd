extends Camera3D

@export var speed = 0.5
@export var height = 2
var target: Vector3

func _process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	target += direction * speed
	position = lerp(position, target, 0.05)
