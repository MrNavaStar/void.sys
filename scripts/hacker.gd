extends Node

enum PowerUses { IDLE_NODES, HACKING, DESTROYED, DEFENDING }

@export var idle_node_cost: float = 5
@export var destroyed_node_cost: float = 10
@export var base_defense_cost: float = 5
@export var scaling_defense_cost: float = 2
@export var selection_range: float = 8
@export var overclock_selection_range: float = 14
@export var overclock_cooldown: float = 20

const base_compute_power: float = 64

var total_compute_power: float = 64
var compute_power_usage: Dictionary[PowerUses, float] = {}
var _hacked_nodes: Array[SpaceNode]
var _being_hacked_nodes: Array[SpaceNode]
var is_overclocked: bool = false
var is_overclocked_coolingdown: bool = false
var sfx_manager: SFXManager

signal compute_power_updated(power: float)
signal message(text: String)
signal node_attack(node: SpaceNode)
signal node_defended(node: SpaceNode)
signal overclock_ready
signal overclock_used


func _ready() -> void:
	reset()


func reset() -> void:
	total_compute_power = base_compute_power
	compute_power_usage = {
		PowerUses.IDLE_NODES: 0,
		PowerUses.HACKING: 0,
		PowerUses.DESTROYED: 0,
		PowerUses.DEFENDING: 0,
	}
	_hacked_nodes.clear()
	_being_hacked_nodes.clear()
	is_overclocked = false
	is_overclocked_coolingdown = false
	sfx_manager = get_node("/root/World/SFXManager")


func get_compute_power_usage() -> float:
	var total_usage: float = 0
	for use: PowerUses in compute_power_usage:
		total_usage += compute_power_usage[use]
	return total_usage


func is_computer_power_critical() -> bool:
	return total_compute_power - get_compute_power_usage() <= 8


func can_compute_action(cost: float) -> bool:
	return total_compute_power >= get_compute_power_usage() + cost


func get_defense_cost(current_level: int) -> float:
	return base_defense_cost + scaling_defense_cost * current_level


func get_poweruse_as_string(use: PowerUses) -> String:
	match use:
		PowerUses.IDLE_NODES:
			return "[[ STORAGE: IDLE NODES ]]"
		PowerUses.HACKING:
			return "[[ PROCESS: HACKING ]]"
		PowerUses.DESTROYED:
			return "[[ ERROR: DESTROYED NODES ]]"
		PowerUses.DEFENDING:
			return "[[ PROCESS: FIREWALL ]]"
		_:
			printerr("Unknown poweruses enum string")
			return "error unknown power use"


func get_poweruse_as_color(use: PowerUses) -> Color:
	match use:
		PowerUses.IDLE_NODES:
			return Color("#A680FF")
		PowerUses.HACKING:
			return Color("#9DFF80")
		PowerUses.DESTROYED:
			return Color("#FF8080")
		PowerUses.DEFENDING:
			return Color("#FFC180")
		_:
			printerr("Unknown poweruses enum color")
			return Color("#000000")


func register_hack(cost: float, node: SpaceNode) -> void:
	compute_power_usage[PowerUses.HACKING] += cost
	_being_hacked_nodes.append(node)


func deregister_hack(cost: float, node: SpaceNode) -> void:
	compute_power_usage[PowerUses.HACKING] -= cost
	assert(compute_power_usage[PowerUses.HACKING] >= 0)
	_being_hacked_nodes.erase(node)


func add_hacked_node(node: SpaceNode) -> void:
	_hacked_nodes.append(node)
	compute_power_usage[PowerUses.IDLE_NODES] += idle_node_cost


func remove_hacked_node(node: SpaceNode) -> void:
	compute_power_usage[PowerUses.DESTROYED] += destroyed_node_cost
	remove_hacked_node_free(node)


func remove_hacked_node_free(node: SpaceNode) -> void:
	_hacked_nodes.erase(node)
	compute_power_usage[PowerUses.IDLE_NODES] -= idle_node_cost
	assert(compute_power_usage[PowerUses.IDLE_NODES] >= 0)
	message.emit("CONNECTION TO NODE LOST")
	if _hacked_nodes.size() == 0:
		game_over()


func game_over() -> void:
	get_tree().paused = true
	var score: int = calculate_score()
	print("GAME OVER")
	var game_over_node: GameOver = get_node("/root/World/GameOver")
	game_over_node.score = score
	game_over_node.run()


var attacks: Dictionary[SpaceNode, float] = {}


func register_attack(node: SpaceNode, cost: float) -> void:
	attacks[node] = cost
	compute_power_usage[PowerUses.DEFENDING] += attacks[node]
	_being_hacked_nodes.append(node)
	node_attack.emit(node)


func deregister_attack(node: SpaceNode) -> void:
	compute_power_usage[PowerUses.DEFENDING] -= attacks[node]
	assert(compute_power_usage[PowerUses.DEFENDING] >= 0)
	attacks.erase(node)
	_being_hacked_nodes.erase(node)
	node_defended.emit(node)


func increase_ram_total(amount: float) -> void:
	total_compute_power += amount


func decrease_ram_total(amount: float) -> void:
	total_compute_power -= amount


func update_ram_display() -> void:
	compute_power_updated.emit(compute_power_usage)


func send_message(text: String) -> void:
	message.emit(text)


func prime_overclock() -> void:
	if is_overclocked_coolingdown == false:
		is_overclocked = true
		(get_node("/root/World/Virtual Cursor") as VirtualCursor).update_closest_node(true)
		for node: SpaceNode in _being_hacked_nodes:
			node.overclock_indicator.visible = true


func unprime_overclock() -> void:
	if is_overclocked_coolingdown == false:
		is_overclocked = false
		(get_node("/root/World/Virtual Cursor") as VirtualCursor).update_closest_node(true)
		for node: SpaceNode in _being_hacked_nodes:
			node.overclock_indicator.visible = false


func use_overclock() -> void:
	if is_overclocked == true:
		message.emit("OVERCLOCKING")
		overclock_used.emit()
		is_overclocked = false
		is_overclocked_coolingdown = true
		(get_node("/root/World/Virtual Cursor") as VirtualCursor).update_closest_node(true)
		for node: SpaceNode in _being_hacked_nodes:
			node.overclock_indicator.visible = false
		var timer: Timer = Timer.new()
		timer.timeout.connect(
			func() -> void:
				is_overclocked_coolingdown = false
				message.emit("OVERCLOCK READY")
				overclock_ready.emit()
				sfx_manager.play_rise_a()
				timer.queue_free()
		)
		add_child(timer)
		timer.start(overclock_cooldown)


func calculate_score() -> int:
	var current_level: int = (get_node("/root/World/EnemyManager") as EnemyManager).current_level
	return int(current_level * (total_compute_power - base_compute_power))
