class_name SpaceNode
extends Node3D

var is_owned_by_user: bool = false
@export var connected_nodes: Array[SpaceNode] = []

func make_planet(pos: Vector3):
	position = pos
	$Object/MeshInstance3D.mesh = SphereMesh.new()
	pass
	
func make_ship(pos: Vector3):
	position = pos
	$Object/MeshInstance3D.mesh = CylinderMesh.new()
	$Object/MeshInstance3D.scale = Vector3(0.2, 0.2, 0.2)
	pass
