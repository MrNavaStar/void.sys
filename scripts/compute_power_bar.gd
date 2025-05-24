extends ProgressBar


func _ready() -> void:
	Hacker.compute_power_updated.connect(_update_compute_power)


func _update_compute_power(usage_map: Dictionary[Hacker.PowerUses, float]) -> void:
	var total_usage: float = 0
	for use: Hacker.PowerUses in usage_map:
		print("%s using %f points" % [Hacker.get_poweruse_as_string(use), usage_map[use]])
		total_usage += usage_map[use]
	value = total_usage / Hacker.total_compute_power
