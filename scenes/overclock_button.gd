extends Button


func _ready() -> void:
	Hacker.overclock_used.connect(_overclock_used)
	Hacker.overclock_ready.connect(_overclock_ready)


func _overclock() -> void:
	if not Hacker.is_overclocked:
		Hacker.prime_overclock()
		text = "CANCEL OVERCLOCK"
	else:
		Hacker.unprime_overclock()
		text = "OVERCLOCK"


func _overclock_used() -> void:
	disabled = true
	text = "COOLING DOWN..."


func _overclock_ready() -> void:
	disabled = false
	text = "OVERCLOCK"
