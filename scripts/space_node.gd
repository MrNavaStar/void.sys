class_name SpaceNode
extends Node3D

@onready var info: Label3D = $Info
@onready var hack_timer: Timer = $"Hack Timer"

var connected_nodes: Dictionary[SpaceNode, Edge] = {}

var is_hacked: bool = false
var allocated_compute_power: float = 0
var hack_cost: float = 0
var hack_time: float = 0
var unhack_strength: float = 0
var closest_node: SpaceNode


func _ready() -> void:
	hack_timer.timeout.connect(_on_hack_finish)


func _process(_delta: float) -> void:
	if is_hacked and allocated_compute_power >= unhack_strength:
		hack_timer.stop()


func _update_label() -> void:
	if is_hacked:
		info.text = "Hacked"
	else:
		info.text = "Hack Cost: %s Hack Time: %s" % [hack_cost, hack_time]


func make_root() -> void:
	($Object/MeshInstance3D as MeshInstance3D).mesh = BoxMesh.new()
	Hacker.hacked_nodes.append(self)
	allocated_compute_power = 8
	is_hacked = true
	_update_label()


func make_planet() -> void:
	($Object/MeshInstance3D as MeshInstance3D).mesh = SphereMesh.new()
	hack_cost = [32, 48, 64][randi_range(0, 2)]
	hack_time = randi_range(8, 16)
	_update_label()


func make_ship() -> void:
	var meshinstance3D: MeshInstance3D = $Object/MeshInstance3D
	meshinstance3D.mesh = CylinderMesh.new()
	meshinstance3D.scale = Vector3(0.2, 0.2, 0.2)
	hack_cost = [8, 16, 24][randi_range(0, 2)]
	hack_time = randi_range(3, 6)
	_update_label()


func hack() -> void:
	closest_node = ((get_node("../../Virtual Cursor") as VirtualCursor).get_closest_node())
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


func _on_area_3d_input_event(
	_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event.is_action_pressed("select"):
		hack()
