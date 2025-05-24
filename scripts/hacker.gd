extends Node

var total_compute: int = 64
var hacked_nodes: Array[SpaceNode]

func get_compute_usage() -> int:
	var usage = 0
	for node in hacked_nodes:
		usage += node.allocated_compute
	return usage
	
func can_compute_action(cost: int) -> bool:
	return total_compute >= get_compute_usage() + cost
