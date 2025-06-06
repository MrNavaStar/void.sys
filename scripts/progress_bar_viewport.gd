class_name ProgressViewport
extends Node3D

@onready var hack_bar: ProgressBar = $SubViewport/ProgressBar
@onready var hack_label: Label = $SubViewport/Label
@onready var progress_mesh: MeshInstance3D = $ProgressBar

var hack_timer: Timer = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if hack_timer == null:
		return
	var percent: float = (
		((hack_timer.wait_time - hack_timer.time_left) / hack_timer.wait_time) * 100
	)
	hack_bar.value = percent
	hack_label.text = "%%%f" % percent


func start_timer(hack_time: float) -> void:
	hack_timer = Timer.new()
	add_child(hack_timer)
	hack_timer.one_shot = true
	hack_timer.timeout.connect(_on_time_over)
	hack_timer.start(hack_time)


func _on_time_over() -> void:
	hack_timer = null
	progress_mesh.visible = false
	queue_free()
