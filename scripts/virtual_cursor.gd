class_name VirtualCursor
extends Node3D

@export var mesh_offset: float = 2
@export var ring_inner_size: float = 0.1

@onready var camera: Camera3D = get_node("../CameraRig/ZoomPivot/Camera3D")
@onready var cursor_pivot: Node3D = $CursorPivot
@onready var cursor_mesh: MeshInstance3D = $CursorPivot/MeshInstance3D

var close_space_nodes: Array[SpaceNode]
var current_closest: SpaceNode = null


func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var intersect: Variant = Plane.PLANE_XZ.intersects_ray(
		camera.project_ray_origin(mouse_pos), camera.project_ray_normal(mouse_pos)
	)

	if intersect:
		position = intersect
		update_model()
		update_closest_node()


func update_model() -> void:
	var target_node := get_closest_hacked_node_in_range()
	if target_node == null:
		cursor_pivot.visible = false
		return
	cursor_pivot.visible = true
	cursor_pivot.look_at(target_node.position)
	var ribbon_mesh := cursor_mesh.mesh as RibbonTrailMesh
	var distance := position.distance_to(target_node.position)
	ribbon_mesh.section_length = ((distance - mesh_offset) / ribbon_mesh.sections)
	cursor_mesh.position.z = -(distance - mesh_offset) / 2
	cursor_mesh.set_instance_shader_parameter("line_length", ribbon_mesh.section_length)


func _on_area_3d_area_entered(area: Area3D) -> void:
	var node: SpaceNode = area.get_parent().get_parent() as SpaceNode
	close_space_nodes.append(node)


func _on_area_3d_area_exited(area: Area3D) -> void:
	close_space_nodes.erase(area.get_parent().get_parent() as SpaceNode)


func get_closest_node() -> SpaceNode:
	var closest: SpaceNode = null
	var distance: float = INF
	for node: SpaceNode in close_space_nodes:
		if node.is_hacked:
			var test_distance := position.distance_to(node.position)
			if test_distance < distance:
				distance = test_distance
				closest = node
	return closest


func get_closest_hacked_node_in_range() -> SpaceNode:
	var closest: SpaceNode = null
	var distance: float = INF
	for node in close_space_nodes:
		if node.is_hacked and not node.is_being_hacked:
			var test_distance := position.distance_to(node.position)
			if test_distance < distance:
				distance = test_distance
				closest = node
	return closest if distance < Hacker.selection_range else null


func update_closest_node() -> void:
	var closest := get_closest_node()
	if closest == current_closest:
		return
	if current_closest != null:
		current_closest.delete_ring()
		current_closest.stop_highlight_nearby()
	current_closest = closest
	if current_closest != null:
		current_closest.generate_ring(Hacker.selection_range, ring_inner_size)
		current_closest.highlight_nearby(Hacker.selection_range)
