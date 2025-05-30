class_name SpaceNode
extends Node3D

@onready var info: Label3D = $Info
@onready var hack_timer: Timer = $"Hack Timer"
@onready var virtual_cursor: VirtualCursor = get_node("../../Virtual Cursor") as VirtualCursor
@onready var neighbours_hitbox: Area3D = $Object/NeighboursHitbox as Area3D

var connected_nodes: Dictionary[SpaceNode, Edge] = {}

var is_hacked: bool = false
var allocated_compute_power: float = 0
var hack_cost: float = 0
var hack_time: float = 0
var unhack_strength: float = 0
var closest_node: SpaceNode
var range_ring: MeshInstance3D


func _ready() -> void:
	hack_timer.timeout.connect(_on_hack_finish)


func _process(_delta: float) -> void:
	if is_hacked and allocated_compute_power >= unhack_strength:
		hack_timer.stop()


#=== INITIALIZATION ===


func make_root() -> void:
	($Object/MeshInstance3D as MeshInstance3D).mesh = BoxMesh.new()
	Hacker.hacked_nodes.append(self)
	allocated_compute_power = 8
	is_hacked = true
	_update_label()


func make_planet() -> void:
	var planet_scene: PackedScene = load("res://scenes/planets/planet_type_a_depleted.tscn")
	var planet: Node3D = planet_scene.instantiate()
	planet.rotation.x = randf_range(1, 2 * PI)
	planet.rotation.y = randf_range(0, 2 * PI)
	planet.rotation.z = randf_range(0, 2 * PI)
	$Object.add_child(planet)
	hack_cost = [32, 48, 64][randi_range(0, 2)]
	hack_time = randi_range(8, 16)
	_update_label()


func make_ship() -> void:
	var meshinstance3D: MeshInstance3D = $Object/MeshInstance3D
	meshinstance3D.mesh = CylinderMesh.new()
	meshinstance3D.scale = Vector3(0.2, 0.2, 0.2)
	meshinstance3D.rotation = Vector3(0, 0, PI / 2)
	hack_cost = [8, 16, 24][randi_range(0, 2)]
	hack_time = randi_range(3, 6)
	_update_label()


#=== LOGIC ===


func hack() -> void:
	closest_node = virtual_cursor.get_closest_node_in_range()
	if closest_node == null:
		return
	if !is_hacked and Hacker.can_compute_action(hack_cost):
		allocated_compute_power = hack_cost
		unhack_strength = 0
		hack_timer.start(hack_time)


func unhack(strength: float) -> void:
	if is_hacked:
		unhack_strength = strength
		hack_timer.start(hack_time)


func generate_ring(radius: float, difference: float) -> void:
	range_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.material = load("res://assets/materials/emission_material.tres")
	torus.inner_radius = radius
	torus.outer_radius = radius + difference
	range_ring.mesh = torus
	$Object.add_child(range_ring)


func delete_ring() -> void:
	range_ring.queue_free()
	range_ring = null


func highlight_nearby(hack_range: float) -> void:
	var nearby_nodes := _get_nearby_unhacked_nodes().filter(
		func(node: SpaceNode) -> bool: return position.distance_to(node.position) < hack_range
	)
	for node: SpaceNode in nearby_nodes:
		node.highlight_self()


func stop_highlight_nearby() -> void:
	var nearby_nodes := _get_nearby_unhacked_nodes()
	for node: SpaceNode in nearby_nodes:
		node.stop_highlight_self()


func _get_nearby_unhacked_nodes() -> Array[SpaceNode]:
	var nearby_areas := neighbours_hitbox.get_overlapping_areas()
	var nearby_nodes: Array[SpaceNode]
	nearby_nodes.assign(
		(
			nearby_areas
			. map(
				func(area: Area3D) -> SpaceNode: return area.get_parent().get_parent() as SpaceNode
			)
			. filter(func(node: SpaceNode) -> bool: return !node.is_hacked)
		)
	)
	return nearby_nodes as Array[SpaceNode]


func highlight_self() -> void:
	($Object/SelectableIndicator as Node3D).visible = true


func stop_highlight_self() -> void:
	($Object/SelectableIndicator as Node3D).visible = false


func _update_label() -> void:
	if is_hacked:
		info.text = "Hacked"
	else:
		info.text = "Hack Cost: %s Hack Time: %s" % [hack_cost, hack_time]


#=== CALLBACKS ===


func _on_hack_finish() -> void:
	if !is_hacked:
		Hacker.hacked_nodes.append(self)
		allocated_compute_power = round(allocated_compute_power / 2)
		is_hacked = true
		var edge: Edge = (get_node("../../Edges") as Edger).create_edge(self, closest_node)
		closest_node.connected_nodes[self] = edge
		connected_nodes[closest_node] = edge
	else:
		Hacker.hacked_nodes.erase(self)
		allocated_compute_power = 0
		is_hacked = false
		hack_cost *= 2
		hack_time *= 2
		for neighbour: SpaceNode in connected_nodes:
			neighbour.connected_nodes[self].queue_free()
			neighbour.connected_nodes.erase(self)
		connected_nodes.clear()

	Hacker.update_idle_node_compute_power_use()
	_update_label()
	virtual_cursor.update_closest_node()


func _on_area_3d_input_event(
	_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event.is_action_pressed("select"):
		hack()
