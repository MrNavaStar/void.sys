extends Node

enum PowerUses { IDLE_NODES, HACKING, DESTROYED, DEFENDING }

@export var idle_node_cost: float = 5
@export var destroyed_node_cost: float = 10

var total_compute_power: float = 64
var compute_power_usage: Dictionary[PowerUses, float] = {
	PowerUses.IDLE_NODES: 0,
	PowerUses.HACKING: 0,
	PowerUses.DESTROYED: 0,
	PowerUses.DEFENDING: 0,
}

var _hacked_nodes: Array[SpaceNode]

signal compute_power_updated(power: float)


func get_compute_power_usage() -> float:
	var total_usage: float = 0
	for use: PowerUses in compute_power_usage:
		total_usage += compute_power_usage[use]
	return total_usage


func can_compute_action(cost: float) -> bool:
	return total_compute_power >= get_compute_power_usage() + cost


func get_poweruse_as_string(use: PowerUses) -> String:
	match use:
		PowerUses.IDLE_NODES:
			return "[[ STORAGE: IDLE NODES ]]"
		PowerUses.HACKING:
			return "[[ PROCESS: HACKING ]]"
		PowerUses.DESTROYED:
			return "[[ ERROR: DESTROYED NODES ]]"
		PowerUses.DEFENDING:
			return "[[ PROCESS: FIREWALL ]]"
		_:
			printerr("Unknown poweruses enum string")
			return "error unknown power use"


func get_poweruse_as_color(use: PowerUses) -> Color:
	match use:
		PowerUses.IDLE_NODES:
			return Color("#E0C429")
		PowerUses.HACKING:
			return Color("#2FE0A2")
		PowerUses.DESTROYED:
			return Color("#E05D59")
		PowerUses.DEFENDING:
			return Color("#99BBF3")
		_:
			printerr("Unknown poweruses enum color")
			return Color("#ffffff")


func register_hack(cost: float) -> void:
	compute_power_usage[PowerUses.HACKING] += cost
	assert(get_compute_power_usage() <= total_compute_power)
	compute_power_updated.emit(compute_power_usage)


func deregister_hack(cost: float) -> void:
	compute_power_usage[PowerUses.HACKING] -= cost
	assert(get_compute_power_usage() >= 0)
	compute_power_updated.emit(compute_power_usage)


func add_hacked_node(node: SpaceNode) -> void:
	_hacked_nodes.append(node)
	compute_power_usage[PowerUses.IDLE_NODES] += idle_node_cost
	compute_power_updated.emit(compute_power_usage)


func remove_hacked_node(node: SpaceNode) -> void:
	_hacked_nodes.erase(node)
	compute_power_usage[PowerUses.IDLE_NODES] -= idle_node_cost
	compute_power_usage[PowerUses.DESTROYED] += destroyed_node_cost
	compute_power_updated.emit(compute_power_usage)
