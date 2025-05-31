class_name EnemyManager
extends Node3D

@export var level_duration: int = 5
@export var max_level: int = 0

var started: bool = false
var current_level: int = 0
@onready var level_timer: Timer = $LevelTimer as Timer


func initial_start() -> void:
	if started == false:
		started = true
		level_timer.start(level_duration)


func _on_timer_finish() -> void:
	current_level += 1
	if current_level >= max_level:
		return
	level_timer.start(level_duration)
