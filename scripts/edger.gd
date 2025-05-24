extends Node3D

@onready var edges: Node3D = $Edges
@onready var space_nodes: Node3D = $SpaceNodes


func _ready() -> void:
	draw_edges()


func _create_edge(node1: SpaceNode, node2: SpaceNode):
	print("edge_created between %s and %s" % [node1.name, node2.name])
	var edge_length := node1.position.distance_to(node2.position)
	# var edge_rotation := node1.position.direction_to(node2.position)
	var edge := MeshInstance3D.new()
	var ribbon_trail := RibbonTrailMesh.new()
	ribbon_trail.size = 0.3
	ribbon_trail.shape = RibbonTrailMesh.SHAPE_FLAT
	ribbon_trail.sections = 0
	ribbon_trail.section_length = edge_length / ribbon_trail.sections - 0.4
	edge.mesh = ribbon_trail
	# WARN: this may need to use global_position if parent nodes get modified
	edge.position = node1.position + (node2.position - node1.position) / 2
	edges.add_child(edge)
	edge.look_at(node2.position)
	edge.rotation_degrees.x = -90


func draw_edges():
	for node: SpaceNode in space_nodes.get_children():
		var node_id := node.get_instance_id()
		for neighbour: SpaceNode in node.connected_nodes:
			if node_id < neighbour.get_instance_id():
				_create_edge(node, neighbour)

# skeleton code for using a dedicated edge.tscn scene

# @onready var edge_scene := preload("res://scenes/edge.tscn")
# func _create_edge(node1: SpaceNode, node2: SpaceNode):
# 	print("edge_created between %s and %s" % [node1.name, node2.name])
# 	var edge_length := node1.position.distance_to(node2.position)
# 	var edge_rotation := node1.position.direction_to(node2.position)
# 	var edge := edge_scene.instantiate() as Edge
# 	var edge_model: MeshInstance3D = edge.find_child("MeshInstance3D")
# 	var ribbon_trail: RibbonTrailMesh = edge_model.mesh
# 	ribbon_trail.shape = RibbonTrailMesh.SHAPE_FLAT
# 	ribbon_trail.section_length = edge_length
# 	edge_model.rotation_degrees = Vector3(-90, edge_rotation.y, 0)
# 	edge.position = node1.position
# 	edges.add_child(edge)
