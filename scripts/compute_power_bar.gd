extends HBoxContainer


func _ready() -> void:
	Hacker.compute_power_updated.connect(_update_compute_power)


func _update_compute_power(usage_map: Dictionary[Hacker.PowerUses, float]) -> void:
	for node: Node in self.get_children():
		node.queue_free()
	var percent_use: float = 0
	for use: Hacker.PowerUses in usage_map:
		# print("%s - %f" % [Hacker.get_poweruse_as_string(use), usage_map[use]])
		var percent: float = minf(usage_map[use] / Hacker.total_compute_power, 1 - percent_use)
		percent_use += percent
		if percent_use == 1:
			print("debt %s" % Hacker.get_poweruse_as_string(use))
		_create_sub_bar(
			percent,
			Hacker.get_poweruse_as_color(use),
			Hacker.get_poweruse_as_string(use),
		)
	if percent_use < 1:
		_create_empty_space()
	if Hacker.get_compute_power_usage() > Hacker.total_compute_power:
		print("in debt!")
		(get_node("../DebtWarning") as Control).visible = true
	else:
		(get_node("../DebtWarning") as Control).visible = false


func _create_sub_bar(percent: float, color: Color, title: String) -> void:
	var bar_width: float = size.x * percent
	var bar: SubBar = SubBar.new()
	bar.title = title
	bar.color = color
	bar.custom_minimum_size = Vector2(bar_width, 0)
	self.add_child(bar)


func _create_empty_space() -> void:
	var bar: SubBar = SubBar.new()
	bar.title = "[[ ALLOCATION: UNASSIGNED ]]"
	bar.color = Color("#ffffff44")
	bar.text_color = Color("#ffffff")
	bar.size_flags_horizontal = SizeFlags.SIZE_EXPAND_FILL
	self.add_child(bar)
