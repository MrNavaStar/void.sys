extends Camera3D

@export var move_speed = 10

func _process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
