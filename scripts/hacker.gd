extends Node

enum PowerUses { IDLE_NODES, HACKING }
var total_compute_power: float = 64
var compute_power_usage: Dictionary[PowerUses, float] = {
	PowerUses.IDLE_NODES: 0, PowerUses.HACKING: 0
}
var hacked_nodes: Array[SpaceNode]

signal compute_power_updated(power: float)


func get_compute_power_usage() -> float:
	var total_usage: float = 0
	for use: PowerUses in compute_power_usage:
		total_usage += compute_power_usage[use]
	return total_usage


# TODO: must be manually run when node count is updated, is a fix possible?
func update_idle_node_compute_power_use() -> void:
	var usage: float = 0
	for node in hacked_nodes:
		usage += node.allocated_compute_power
	compute_power_usage[PowerUses.IDLE_NODES] = usage
	compute_power_updated.emit(compute_power_usage)


func can_compute_action(cost: float) -> bool:
	return total_compute_power >= get_compute_power_usage() + cost


func get_poweruse_as_string(use: PowerUses) -> String:
	match use:
		PowerUses.IDLE_NODES:
			return "[[PROCESS: IDLE NODES]]"
		PowerUses.HACKING:
			return "[[PROCESS: HACKING]]"
		_:
			printerr("Unknown poweruses enum")
			return "ERROR: Unknown PowerUse"
