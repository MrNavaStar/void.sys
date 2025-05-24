extends Node3D

@export var radius = 300
@export var planets = 300
@export var planet_spread = 20
@export var ships = 1500
@export var ship_spread = 3

var node_positions: Array

func is_too_close(pos: Vector3, distance: float) -> bool:
	for planet_pos in node_positions:
		if pos.distance_to(planet_pos) <= distance:
			return true
	return false

func rand_pos_with_spread(spread: float):
	var tries = 0
	var pos: Vector3
	while pos == null or is_too_close(pos, spread) and tries <= 20:
		pos = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
		tries += 1
	
	if tries >= 20:
		return null
	
	return pos

func spawn_node(node: Resource, pos: Vector3) -> SpaceNode:
	var instance = node.instantiate() as SpaceNode
	instance.set_position(pos)
	node_positions.append(pos)
	add_child(instance)
	return instance

func spawn_nodes(node: Resource):
	spawn_node(node, Vector3(0, 0, 0)).make_root()
	
	for i in planets:
		var pos = rand_pos_with_spread(planet_spread)
		if pos == null:
			continue
		spawn_node(node, pos).make_planet()
		
	for i in ships:
		var pos = rand_pos_with_spread(ship_spread)
		if pos == null:
			continue
		spawn_node(node, pos).make_ship()
	
func _ready() -> void:
	#seed(12345)
	spawn_nodes(preload("res://scenes/space_node.tscn"))
