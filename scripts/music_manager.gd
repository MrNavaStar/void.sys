class_name MusicManager extends Node

var MUTE: float = -60
var UNMUTE: float = 0 
var fade_speed: float = 0.05

@onready var intro: AudioStreamPlayer2D = $Intro
@onready var main_high: AudioStreamPlayer2D = $MainHigh
@onready var main_low: AudioStreamPlayer2D = $MainLow

@onready var hacking: AudioStreamPlayer2D = $Hacking
@onready var critical_ram: AudioStreamPlayer2D = $CriticalRam

func _ready() -> void:
	intro.finished.connect(_start_loop)

func _process(delta: float) -> void:
	if Hacker.compute_power_usage[Hacker.PowerUses.HACKING] != 0:
		hacking.volume_db = lerp(hacking.volume_db, UNMUTE, fade_speed)
	else:
		hacking.volume_db = lerp(hacking.volume_db, MUTE, fade_speed)
		
	if Hacker.is_computer_power_critical():
		critical_ram.volume_db = lerp(critical_ram.volume_db, UNMUTE, fade_speed)
		main_low.volume_db = lerp(main_low.volume_db, MUTE, fade_speed)
	else:
		critical_ram.volume_db = lerp(critical_ram.volume_db, MUTE, fade_speed)
		main_low.volume_db = lerp(main_low.volume_db, UNMUTE, fade_speed)
	
func _start_loop() -> void:
	main_high.play()
	main_low.play()
	hacking.play()
	critical_ram.play()
