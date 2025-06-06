extends Node3D

@export var radius: int = 300
@export var planets: int = 300
@export var planet_spread: int = 10
@export var ships: int = 1500
@export var ship_spread: int = 4
@export var probes: int = 2000
@export var probe_spread: int = 3
@export var asteroids: int = 1500
@export var asteroid_spread: int = 5

var node_positions: Array
@onready var space_nodes: Node3D = $SpaceNodes

var planet_scenes: Array[PackedScene]
var ship_scenes: Array[PackedScene]
var probe_scenes: Array[PackedScene]
var asteroid_scenes: Array[PackedScene]


func _init() -> void:
	planet_scenes = [
		load("res://scenes/planets/planet_type_a_depleted.tscn"),
		load("res://scenes/planets/planet_type_b_overpopulated.tscn"),
		load("res://scenes/planets/planet_type_c_drought.tscn")
	]
	ship_scenes = [
		load("res://scenes/ships/ship_type_a_cylinder.tscn"),
		load("res://scenes/ships/ship_type_b_cone.tscn"),
		load("res://scenes/ships/ship_type_c_saucer.tscn")
	]
	probe_scenes = [
		load("res://scenes/probes/probe_type_a_sputnik.tscn"),
		load("res://scenes/probes/probe_type_b_cubesat.tscn"),
		load("res://scenes/probes/probe_type_c_dish.tscn")
	]
	asteroid_scenes = [
		load("res://scenes/asteroids/asteroid_type_a_tick.tscn"),
		load("res://scenes/asteroids/asteroid_type_b_grabber.tscn"),
		load("res://scenes/asteroids/asteroid_type_c_geophage.tscn")
	]


func is_too_close(pos: Vector3, distance: float) -> bool:
	for planet_pos: Vector3 in node_positions:
		if pos.distance_to(planet_pos) <= distance:
			return true
	return false


func rand_pos_with_spread(spread: float) -> Vector3:
	var tries: int = 0
	var pos: Vector3
	while pos == null or is_too_close(pos, spread) and tries <= 20:
		pos = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
		tries += 1

	if tries >= 20:
		return Vector3.INF

	return pos


func spawn_node(node: PackedScene, pos: Vector3) -> SpaceNode:
	var node_instance := node.instantiate() as SpaceNode
	node_instance.set_position(pos)
	node_positions.append(pos)
	space_nodes.add_child(node_instance)
	return node_instance


func spawn_nodes(node: PackedScene) -> void:
	spawn_node(node, Vector3(0, 0, 0)).make_root(
		probe_scenes[randi_range(0, probe_scenes.size() - 1)]
	)

	for i in planets:
		var pos := rand_pos_with_spread(planet_spread)
		if pos == Vector3.INF:
			continue
		spawn_node(node, pos).make_planet(planet_scenes[randi_range(0, planet_scenes.size() - 1)])

	for i in ships:
		var pos := rand_pos_with_spread(ship_spread)
		if pos == Vector3.INF:
			continue
		spawn_node(node, pos).make_ship(ship_scenes[randi_range(0, ship_scenes.size() - 1)])

	for i in probes:
		var pos := rand_pos_with_spread(probe_spread)
		if pos == Vector3.INF:
			continue
		spawn_node(node, pos).make_probe(probe_scenes[randi_range(0, probe_scenes.size() - 1)])

	for i in asteroids:
		var pos := rand_pos_with_spread(asteroid_spread)
		if pos == Vector3.INF:
			continue
		spawn_node(node, pos).make_asteroid(
			asteroid_scenes[randi_range(0, asteroid_scenes.size() - 1)]
		)


func _ready() -> void:
	#seed(12345)
	spawn_nodes(preload("res://scenes/space_node.tscn"))
