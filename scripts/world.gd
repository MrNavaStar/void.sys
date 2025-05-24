extends Node3D

@export var radius = 300
@export var planets = 300
@export var planet_spread = 20
@export var ships = 1000
@export var ship_spread = 3

var node_positions: Array

func is_too_close(pos: Vector3, distance: float) -> bool:
	for planet_pos in node_positions:
		if pos.distance_to(planet_pos) <= distance:
			return true
	return false

func rand_pos() -> Vector3:
	return Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))

func rand_pos_with_spread(spread: float) -> Vector3:
	var tries = 0
	var pos: Vector3
	while pos == null or is_too_close(pos, spread) or tries < 20:
		pos = rand_pos()
		tries += 1
	return pos

func spawn_nodes(planet: Resource, ship: Resource) -> void:
	for i in planets:
		var pos = rand_pos_with_spread(planet_spread)
		node_positions.append(pos)
		
		var instance = planet.instantiate()
		instance.set_position(pos)
		add_child(instance)
		
	for i in ships:
		var pos = rand_pos_with_spread(ship_spread)
		node_positions.append(pos)
		
		var instance = ship.instantiate()
		instance.set_position(pos)
		add_child(instance)
	
func _ready() -> void:
	#seed(12345)
	var planet = preload("res://scenes/planet.tscn")
	var ship = preload("res://scenes/ship.tscn")
	
	spawn_nodes(planet, ship)
