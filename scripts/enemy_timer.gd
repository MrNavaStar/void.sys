class_name SmallEnemyTimer
extends Timer

var wait_time_min: float = 8
var wait_time_max: float = 15

var attack_time_min: float = 4
var attack_time_max: float = 7

@onready var attack_timer: Timer = Timer.new()


func _init() -> void:
	timeout.connect(_enemy_timer_timeout)


func _ready() -> void:
	attack_timer.timeout.connect(_on_attack_timer_end)
	attack_timer.one_shot = true
	add_child(attack_timer)
	start(randf_range(wait_time_min, wait_time_max))


func _enemy_timer_timeout() -> void:
	attack_timer.start(randf_range(attack_time_min, attack_time_max))
	(get_parent().get_parent() as EnemyManager).start_small_enemy_attack(self)
	start(randf_range(wait_time_min, wait_time_max))


func _on_attack_timer_end() -> void:
	(get_parent().get_parent() as EnemyManager).stop_small_enemy_attack(self)
