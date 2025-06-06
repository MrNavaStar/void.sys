extends Node

enum PowerUses { IDLE_NODES, HACKING, DESTROYED, DEFENDING }

@export var idle_node_cost: float = 5
@export var destroyed_node_cost: float = 10
@export var defense_cost: float = 5
@export var selection_range: float = 8

var total_compute_power: float = 64
var compute_power_usage: Dictionary[PowerUses, float] = {
	PowerUses.IDLE_NODES: 0,
	PowerUses.HACKING: 0,
	PowerUses.DESTROYED: 0,
	PowerUses.DEFENDING: 0,
}
var _hacked_nodes: Array[SpaceNode]

signal compute_power_updated(power: float)
signal message(text: String)
signal node_attack(node: SpaceNode)
signal node_defended(node: SpaceNode)


func get_compute_power_usage() -> float:
	var total_usage: float = 0
	for use: PowerUses in compute_power_usage:
		total_usage += compute_power_usage[use]
	return total_usage


func is_computer_power_critical() -> bool:
	return total_compute_power - get_compute_power_usage() <= 8


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


func deregister_hack(cost: float) -> void:
	compute_power_usage[PowerUses.HACKING] -= cost
	assert(compute_power_usage[PowerUses.HACKING] >= 0)


func add_hacked_node(node: SpaceNode) -> void:
	_hacked_nodes.append(node)
	compute_power_usage[PowerUses.IDLE_NODES] += idle_node_cost


func remove_hacked_node(node: SpaceNode) -> void:
	compute_power_usage[PowerUses.DESTROYED] += destroyed_node_cost
	remove_hacked_node_free(node)


func remove_hacked_node_free(node: SpaceNode) -> void:
	_hacked_nodes.erase(node)
	compute_power_usage[PowerUses.IDLE_NODES] -= idle_node_cost
	assert(compute_power_usage[PowerUses.IDLE_NODES] >= 0)
	message.emit("CONNECTION TO NODE LOST")
	if _hacked_nodes.size() == 0:
		print("GAME OVER")


func register_attack(node: SpaceNode) -> void:
	compute_power_usage[PowerUses.DEFENDING] += defense_cost
	node_attack.emit(node)


func deregister_attack(node: SpaceNode) -> void:
	compute_power_usage[PowerUses.DEFENDING] -= defense_cost
	assert(compute_power_usage[PowerUses.DEFENDING] >= 0)
	node_defended.emit(node)


func increase_ram_total(amount: float) -> void:
	total_compute_power += amount


func decrease_ram_total(amount: float) -> void:
	total_compute_power -= amount


func update_ram_display() -> void:
	compute_power_updated.emit(compute_power_usage)


func send_message(text: String) -> void:
	message.emit(text)
