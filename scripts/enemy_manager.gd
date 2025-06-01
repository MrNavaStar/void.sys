class_name EnemyManager
extends Node3D

@export var level_duration: int = 20
@export var max_level: int = 5

var started: bool = false
var current_level: int = 0
var small_attacks: Dictionary[SmallEnemyTimer, SmallAttack]

@onready var level_timer: Timer = $LevelTimer as Timer
@onready var timer_label: Label = get_node("../Control/EnemyTimer") as Label


func _process(_delta: float) -> void:
	timer_label.text = "level %d - %f" % [current_level, level_timer.time_left]


func initial_start() -> void:
	if started == false:
		started = true
		level_timer.start(level_duration)


func _on_timer_finish() -> void:
	current_level += 1
	create_enemy_timer()
	if current_level >= max_level:
		return
	level_timer.start(level_duration)


func create_enemy_timer() -> void:
	var new_timer: SmallEnemyTimer = SmallEnemyTimer.new()
	new_timer.one_shot = true
	level_timer.add_child(new_timer)


class SmallAttack:
	var target: SpaceNode

	func start(node: SpaceNode) -> void:
		target = node
		if Hacker.can_compute_action(Hacker.defense_cost):
			target.is_being_hacked = true
			Hacker.register_attack(target)
			target.show_enemy_hack_indicator()
			return
		# if not enough ram to start
		# immediately hack target
		hack()

	func stop() -> void:
		target.is_being_hacked = false
		Hacker.deregister_attack(target)
		target.hide_hack_indicators()

	func hack() -> void:
		target.is_hacked = false
		Hacker.deregister_attack(target)
		target._on_hack_finish()


func start_small_enemy_attack(enemy_timer: SmallEnemyTimer) -> void:
	var attack: SmallAttack = SmallAttack.new()
	var node: SpaceNode = _get_untargeted_node()
	if node == null:
		return
	attack.start(node)
	small_attacks[enemy_timer] = attack


func stop_small_enemy_attack(enemy_timer: SmallEnemyTimer) -> void:
	small_attacks[enemy_timer].stop()
	small_attacks.erase(enemy_timer)


func _get_untargeted_leaf_node() -> SpaceNode:
	var filtered_nodes := Hacker._hacked_nodes.filter(
		func(node: SpaceNode) -> bool:
			return node.connected_nodes.size() == 1 and not node.is_being_hacked
	)
	if filtered_nodes.size() == 0:
		return null
	return filtered_nodes[randi_range(0, filtered_nodes.size() - 1)]


func _get_untargeted_internal_node() -> SpaceNode:
	var filtered_nodes := Hacker._hacked_nodes.filter(
		func(node: SpaceNode) -> bool:
			return node.connected_nodes.size() > 1 and not node.is_being_hacked
	)
	if filtered_nodes.size() == 0:
		return null
	return filtered_nodes[randi_range(0, filtered_nodes.size() - 1)]


func _get_untargeted_node() -> SpaceNode:
	var filtered_nodes := Hacker._hacked_nodes.filter(
		func(node: SpaceNode) -> bool: return not node.is_being_hacked
	)
	if filtered_nodes.size() == 0:
		return null
	return filtered_nodes[randi_range(0, filtered_nodes.size() - 1)]
