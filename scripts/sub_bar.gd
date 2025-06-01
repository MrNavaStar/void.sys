class_name SubBar
extends ColorRect

var title: String
var text_color: Color = Color("#123123")

@onready var use_label: Label = get_node("../../RamUseLabel") as Label


func _ready() -> void:
	mouse_entered.connect(_show_hover)
	mouse_exited.connect(_hide_hover)
	if text_color == Color("#123123"):
		text_color = color


func _show_hover() -> void:
	use_label.text = (
		"%s - %d/%d" % [title, Hacker.get_compute_power_usage(), Hacker.total_compute_power]
	)
	use_label.begin_bulk_theme_override()
	use_label.add_theme_color_override("font_color", text_color)
	use_label.add_theme_color_override("border_color", text_color)
	use_label.end_bulk_theme_override()
	use_label.visible = true


func _hide_hover() -> void:
	use_label.visible = false
