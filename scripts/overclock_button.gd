extends Button

var timer: Timer = null


func _ready() -> void:
	Hacker.overclock_used.connect(_overclock_used)
	Hacker.overclock_ready.connect(_overclock_ready)


func _process(_delta: float) -> void:
	if timer != null:
		var value: float = 100 * (timer.wait_time - timer.time_left) / timer.wait_time
		(get_node("../ProgressBar") as ProgressBar).value = value


func _overclock() -> void:
	if not Hacker.is_overclocked:
		Hacker.prime_overclock()
		text = "CANCEL"
	else:
		Hacker.unprime_overclock()
		text = "OVERCLOCK"


func _overclock_used() -> void:
	disabled = true
	text = "COOLING DOWN"
	(get_node("../ProgressBar") as ProgressBar).visible = true
	_start_progress_bar()


func _overclock_ready() -> void:
	disabled = false
	text = "OVERCLOCK"
	(get_node("../ProgressBar") as ProgressBar).visible = false


func _start_progress_bar() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(
		func() -> void:
			if timer != null:
				timer.queue_free()
				timer = null
	)
	timer.start(Hacker.overclock_cooldown)
