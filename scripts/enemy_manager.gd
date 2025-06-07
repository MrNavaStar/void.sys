class_name EnemyManager
extends Node3D

@export var level_duration: int = 15

var started: bool = false
var current_level: int = 0
var small_attacks: Dictionary[SmallEnemyTimer, SmallAttack]
var t: float = 0
var lerp_target: Color = Color("#3e8c4b")
var old_color: Color = Color("#3e8c4b")
var done_lerp: bool = true

@onready var level_timer: Timer = $LevelTimer as Timer
@onready var timer_label: Label = get_node("../Control/ThreatBar/EnemyTimer") as Label
@onready var threat_level_label: Label = get_node("../Control/ThreatBar/EnemyLabel") as Label
@onready var grid_material: BaseMaterial3D = (
	(get_node("../Grid") as MeshInstance3D).get_surface_override_material(0) as BaseMaterial3D
)


func _process(delta: float) -> void:
	threat_level_label.text = "Threat Level: %d" % current_level
	timer_label.text = "Increases in %.1fs" % level_timer.time_left

	t += delta * 0.4
	grid_material.emission = lerp(old_color, lerp_target, t)
	if t >= 1:
		t = 0
		old_color = lerp_target
		done_lerp = true


func initial_start() -> void:
	if started == false:
		started = true
		level_timer.start(level_duration)


func _on_timer_finish() -> void:
	current_level += 1
	if current_level >= 10:
		if done_lerp == true:
			t = 0
			lerp_target = Color("#d13946")
			done_lerp = false
	elif current_level >= 5:
		if done_lerp == true:
			t = 0
			lerp_target = Color("#9d6f2b")
			done_lerp = false
	create_enemy_timer()
	level_timer.start(level_duration)


func create_enemy_timer() -> void:
	var new_timer: SmallEnemyTimer = SmallEnemyTimer.new()
	new_timer.one_shot = true
	level_timer.add_child(new_timer)


class SmallAttack:
	var target: SpaceNode
	var started: bool = false

	func start(node: SpaceNode, current_level: int) -> void:
		target = node
		started = false
		var hack_cost: float = Hacker.get_defense_cost(current_level)
		if Hacker.can_compute_action(hack_cost):
			target.is_being_hacked = true
			Hacker.register_attack(target, hack_cost)
			Hacker.update_ram_display()
			target.show_enemy_hack_indicator()
			started = true
			return
		# if not enough ram to start
		# immediately hack target
		hack()

	func stop() -> void:
		if started == false:
			return
		target.is_being_hacked = false
		Hacker.deregister_attack(target)
		Hacker.update_ram_display()
		target.hide_hack_indicators()

	func hack() -> void:
		target._on_hack_finish()


func start_small_enemy_attack(enemy_timer: SmallEnemyTimer) -> void:
	var attack: SmallAttack = SmallAttack.new()
	var node: SpaceNode = _get_untargeted_node()
	if node == null:
		return
	attack.start(node, current_level)
	small_attacks[enemy_timer] = attack
	(get_node("/root/World/Virtual Cursor") as VirtualCursor).update_closest_node(true)


func stop_small_enemy_attack(enemy_timer: SmallEnemyTimer) -> void:
	if small_attacks.has(enemy_timer):
		small_attacks[enemy_timer].stop()
		small_attacks.erase(enemy_timer)
	(get_node("/root/World/Virtual Cursor") as VirtualCursor).update_closest_node(true)


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
