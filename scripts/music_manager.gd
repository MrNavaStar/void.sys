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

var done_lerp: bool = true
var t: float = 0

var main_high1_target: float = UNMUTE
var main_high1_old: float = UNMUTE
var main_high2_target: float = MUTE
var main_high2_old: float = MUTE
var main_high3_target: float = MUTE
var main_high3_old: float = MUTE


func _ready() -> void:
	intro.finished.connect(_start_loop)


func _process(delta: float) -> void:
	_hacking_music()
	_critical_music()
	_threat_level_music()

	t += delta * 1
	main_high1.volume_db = lerp(main_high1_old, main_high1_target, t)
	main_high2.volume_db = lerp(main_high2_old, main_high2_target, t)
	main_high3.volume_db = lerp(main_high3_old, main_high3_target, t)
	if t >= 1:
		t = 0
		main_high1_old = main_high1_target
		main_high2_old = main_high2_target
		main_high3_old = main_high3_target
		done_lerp = true


func _hacking_music() -> void:
	if Hacker.compute_power_usage[Hacker.PowerUses.HACKING] != 0:
		hacking.volume_db = UNMUTE
	else:
		hacking.volume_db = MUTE


func _critical_music() -> void:
	if Hacker.is_computer_power_critical():
		critical_ram.volume_db = UNMUTE
		main_low.volume_db = MUTE
	else:
		critical_ram.volume_db = MUTE
		main_low.volume_db = UNMUTE


func _threat_level_music() -> void:
	if enemy_manager.current_level >= high_threat_level_breakpoint:
		if done_lerp == true:
			t = 0
			main_high1_target = MUTE
			main_high2_target = MUTE
			main_high3_target = UNMUTE
			done_lerp = false
	elif enemy_manager.current_level >= mid_threat_level_breakpoint:
		if done_lerp == true:
			t = 0
			main_high1_target = MUTE
			main_high2_target = UNMUTE
			main_high3_target = MUTE
			done_lerp = false
	else:
		if done_lerp == true:
			t = 0
			main_high1_target = UNMUTE
			main_high2_target = MUTE
			main_high3_target = MUTE
			done_lerp = false


func _start_loop() -> void:
	main_high1.play()
	main_high2.play()
	main_high3.play()
	main_low.play()
	hacking.play()
	critical_ram.play()
