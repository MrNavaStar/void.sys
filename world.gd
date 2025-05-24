extends Node3D

@export var planets = 100
@export var ships = 100
@export var radius = 30

func spawn_nodes(planet: Resource) -> void:
	for i in planets:
		var x = randi() % radius
		var z = randi() % radius
		var instance = planet.instantiate()
		instance.set_position(Vector3(x, 0, z))
		add_child(instance)
	
func _on_ready() -> void:
	#seed(12345)
	var planet = preload("res://planet.tscn")
	
	spawn_nodes(planet)
