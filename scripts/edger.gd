extends Node3D

@onready var edges: Node3D = $Edges
@onready var space_nodes: Node3D = $SpaceNodes


func _ready() -> void:
	draw_edges()


func _create_edge(node1: SpaceNode, node2: SpaceNode):
	print("edge_created between %s and %s" % [node1.name, node2.name])


func draw_edges():
	for node: SpaceNode in space_nodes.get_children():
		var node_id := node.get_instance_id()
		for neighbour: SpaceNode in node.connected_nodes:
			if node_id < neighbour.get_instance_id():
				_create_edge(node, neighbour)
