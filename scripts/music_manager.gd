class_name MusicManager extends Node

var MUTE: float = -60
var UNMUTE: float = 0
var fade_speed: float = 0.05

@export var mid_threat_level_breakpoint: int = 5
@export var high_threat_level_breakpoint: int = 10

@onready var enemy_manager: EnemyManager = get_node("../EnemyManager")

@onready var intro: AudioStreamPlayer = $Intro
@onready var main_low: AudioStreamPlayer = $MainLow

@onready var main_high1: AudioStreamPlayer = $MainHighLVL1
@onready var main_high2: AudioStreamPlayer = $MainHighLVL2
@onready var main_high3: AudioStreamPlayer = $MainHighLVL3

@onready var hacking: AudioStreamPlayer = $Hacking
@onready var critical_ram: AudioStreamPlayer = $CriticalRam

# var at_breakpoint =


func _ready() -> void:
	intro.finished.connect(_start_loop)


func _process(_delta: float) -> void:
	_hacking_music()
	_critical_music()
	_threat_level_music()


func _hacking_music() -> void:
	if Hacker.compute_power_usage[Hacker.PowerUses.HACKING] != 0:
		hacking.volume_db = lerp(hacking.volume_db, UNMUTE, fade_speed)
	else:
		hacking.volume_db = lerp(hacking.volume_db, MUTE, fade_speed)


func _critical_music() -> void:
	if Hacker.is_computer_power_critical():
		critical_ram.volume_db = lerp(critical_ram.volume_db, UNMUTE, fade_speed)
		main_low.volume_db = lerp(main_low.volume_db, MUTE, fade_speed)
	else:
		critical_ram.volume_db = lerp(critical_ram.volume_db, MUTE, fade_speed)
		main_low.volume_db = lerp(main_low.volume_db, UNMUTE, fade_speed)


func _threat_level_music() -> void:
	if enemy_manager.current_level >= high_threat_level_breakpoint:
		main_high1.volume_db = lerp(main_high1.volume_db, MUTE, fade_speed)
		main_high2.volume_db = lerp(main_high2.volume_db, MUTE, fade_speed)
		main_high3.volume_db = lerp(main_high3.volume_db, UNMUTE, fade_speed)
	elif enemy_manager.current_level >= mid_threat_level_breakpoint:
		main_high1.volume_db = lerp(main_high1.volume_db, MUTE, fade_speed)
		main_high2.volume_db = lerp(main_high2.volume_db, UNMUTE, fade_speed)
		main_high3.volume_db = lerp(main_high3.volume_db, MUTE, fade_speed)
	else:
		main_high1.volume_db = lerp(main_high1.volume_db, UNMUTE, fade_speed)
		main_high2.volume_db = lerp(main_high2.volume_db, MUTE, fade_speed)
		main_high3.volume_db = lerp(main_high3.volume_db, MUTE, fade_speed)


func _start_loop() -> void:
	main_high1.play()
	main_high2.play()
	main_high3.play()
	main_low.play()
	hacking.play()
	critical_ram.play()
