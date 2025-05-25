extends Node3D

@onready var camera: Camera3D = get_node("../CameraRig/ZoomPivot/Camera3D")

var close_space_nodes: Array[SpaceNode]

func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var intersect : Variant = Plane.PLANE_XZ.intersects_ray(
		camera.project_ray_origin(mouse_pos),
		camera.project_ray_normal(mouse_pos)
	)
	position = intersect


func _on_area_3d_area_entered(area: Area3D) -> void:
	var node: SpaceNode = area.get_parent().get_parent() as SpaceNode
	if node.is_hacked:
		close_space_nodes.append(node)


func _on_area_3d_area_exited(area: Area3D) -> void:
	close_space_nodes.erase(area.get_parent().get_parent() as SpaceNode)


func get_closest_node() -> SpaceNode:
	var closest: SpaceNode = close_space_nodes[0]
	for node in close_space_nodes:
		if node.position.direction_to(position) < closest.position:
			closest = node
	return closest
