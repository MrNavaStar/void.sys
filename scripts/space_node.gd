class_name SpaceNode
extends Node3D

@onready var info: Label3D = $Info

@export var connected_nodes: Dictionary[SpaceNode, Edge] = {}

var allocated_compute: int = 0
var hack_cost: int = 0
var is_hacked: bool = false
var hack_timer: Timer = Timer.new()
var hack_time: int = 0


func _ready() -> void:
	info.billboard = BaseMaterial3D.BILLBOARD_ENABLED

	hack_timer.one_shot = true
	hack_timer.timeout.connect(_on_hack_finish)
	add_child(hack_timer)


func _update_label() -> void:
	if is_hacked:
		info.text = "Hacked"
	else:
		info.text = "Hack Cost: %s Hack Time: %s" % [hack_cost, hack_time]


func make_root() -> void:
	($Object/MeshInstance3D as MeshInstance3D).mesh = BoxMesh.new()
	allocated_compute = 8
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
	hack_cost = [8, 16, 32][randi_range(0, 2)]
	hack_time = randi_range(3, 6)
	_update_label()


func hack() -> void:
	if is_hacked or !Hacker.can_compute_action(hack_cost):
		return
	allocated_compute = hack_cost
	hack_timer.start(hack_time)


func _on_hack_finish() -> void:
	Hacker.hacked_nodes.append(self)
	allocated_compute = allocated_compute / 2
	is_hacked = true
	_update_label()


func _on_area_3d_input_event(
	_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event.is_action_pressed("select"):
		hack()
