extends Node3D

@export var planets = 300
@export var min_planet_spread = 20
@export var ships = 100
@export var radius = 300

var planet_positions: Array

func is_too_close(pos: Vector3) -> bool:
	for planet_pos in planet_positions:
		if pos.distance_to(planet_pos) <= min_planet_spread:
			return true
	return false

func rand_pos() -> Vector3:
	return Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))

func spawn_nodes(planet: Resource) -> void:
	
	for i in planets:
		
		var tries = 0
		var pos = rand_pos()
		while pos == null or is_too_close(pos) or tries < 20:
			pos = rand_pos()
			tries += 1
		
		planet_positions.append(pos)
		
		var instance = planet.instantiate()
		instance.set_position(pos)
		add_child(instance)
	
func _ready() -> void:
	#seed(12345)
	var planet = preload("res://scenes/planet.tscn")
	
	spawn_nodes(planet)
