class_name SpaceNode
extends Node3D

@onready var info: Label3D = $Info
@onready var hack_timer: Timer = $"Hack Timer"

@export var connected_nodes: Array[SpaceNode] = []

var is_hacked: bool = false
var allocated_compute: int = 0
var hack_cost: int = 0
var hack_time: int = 0
var unhack_strength: int = 0

func _ready():
	hack_timer.timeout.connect(_on_hack_finish)

func _process(delta: float) -> void:
	if is_hacked and allocated_compute >= unhack_strength:
		hack_timer.stop()

func _update_label():
	if is_hacked:
		info.text = "Hacked"
	else:
		info.text = "Hack Cost: %s Hack Time: %s" % [hack_cost, hack_time]

func make_root():
	$Object/MeshInstance3D.mesh = BoxMesh.new()
	Hacker.hacked_nodes.append(self)
	allocated_compute = 8
	is_hacked = true
	_update_label()

func make_planet():
	$Object/MeshInstance3D.mesh = SphereMesh.new()
	hack_cost = [32, 48, 64][randi_range(0, 2)] 
	hack_time = randi_range(8, 16)
	_update_label()
	
func make_ship():
	$Object/MeshInstance3D.mesh = CylinderMesh.new()
	$Object/MeshInstance3D.scale = Vector3(0.2, 0.2, 0.2)
	hack_cost = [8, 16, 24][randi_range(0, 2)] 
	hack_time = randi_range(3, 6)
	_update_label()
	
func hack():
	if !is_hacked and Hacker.can_compute_action(hack_cost):
		allocated_compute = hack_cost
		unhack_strength = 0
		hack_timer.start(hack_time)
	
func unhack(strength: int):
	if is_hacked:
		unhack_strength = strength
		hack_timer.start(hack_time)
	
func _on_hack_finish():
	if !is_hacked:
		Hacker.hacked_nodes.append(self)
		allocated_compute = round(allocated_compute / 2)
		is_hacked = true
	else:
		Hacker.hacked_nodes.erase(self)
		allocated_compute = 0
		is_hacked = false
		hack_cost *= 2
		hack_time *= 2
		
	_update_label()

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		hack()
