class_name Edger
extends Node3D

@onready var edges: Node3D = self
@onready var space_nodes: Node3D = get_node("../SpaceNodes") as Node3D
@onready var edge_prefab: PackedScene = preload("res://scenes/edge.tscn")


func create_edge(node1: SpaceNode, node2: SpaceNode) -> Edge:
	var edge_length := node1.position.distance_to(node2.position)
	var edge_scene := edge_prefab.instantiate() as Edge

	node1.connected_nodes[node2] = edge_scene
	node2.connected_nodes[node1] = edge_scene

	var ribbon_trail := RibbonTrailMesh.new()
	ribbon_trail.size = 0.3
	ribbon_trail.shape = RibbonTrailMesh.SHAPE_FLAT
	ribbon_trail.sections = 3
	ribbon_trail.section_length = edge_length / ribbon_trail.sections - 1.2
	ribbon_trail.material = load("res://assets/vfx/edge_shader.tres")

	var edge := MeshInstance3D.new()
	edge.mesh = ribbon_trail
	edge.position = node1.position + (node2.position - node1.position) / 2
	edge.set_instance_shader_parameter("line_length", ribbon_trail.section_length / 2)

	edge_scene.add_child(edge)
	edges.add_child(edge_scene)
	edge.look_at(node2.position)
	edge.rotation_degrees.x = -90
	return edge_scene
