class_name VirtCursor
extends Node3D

@export var mesh_offset: float = 0

@onready var camera: Camera3D = get_node("../CameraRig/ZoomPivot/Camera3D")
@onready var cursor_pivot: Node3D = $CursorPivot
@onready var cursor_mesh: MeshInstance3D = $CursorPivot/MeshInstance3D

var close_space_nodes: Array[SpaceNode]


func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var intersect: Variant = Plane.PLANE_XZ.intersects_ray(
		camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)
	)
	position = intersect
	update_model()


func update_model() -> void:
	var target_node := get_closest_node()
	if target_node == null:
		cursor_pivot.visible = false
		return
	cursor_pivot.visible = true
	cursor_pivot.look_at(target_node.position)
	var ribbon_mesh := cursor_mesh.mesh as RibbonTrailMesh
	var distance := position.distance_to(target_node.position)
	ribbon_mesh.section_length = ((distance - mesh_offset) / ribbon_mesh.sections)
	cursor_mesh.position.z = -(distance - mesh_offset) / 2


func _on_area_3d_area_entered(area: Area3D) -> void:
	var node: SpaceNode = area.get_parent().get_parent() as SpaceNode
	close_space_nodes.append(node)


func _on_area_3d_area_exited(area: Area3D) -> void:
	close_space_nodes.erase(area.get_parent().get_parent() as SpaceNode)


func get_closest_node() -> SpaceNode:
	var closest: SpaceNode = null
	var distance: float = INF
	for node in close_space_nodes:
		if node.is_hacked:
			var test_distance := position.distance_to(node.position)
			if test_distance < distance:
				distance = test_distance
				closest = node
	return closest
