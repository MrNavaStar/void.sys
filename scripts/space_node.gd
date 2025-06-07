class_name SpaceNode
extends Node3D

@onready var info: Label3D = $Info
@onready var hack_timer: Timer = $"Hack Timer"
@onready var virtual_cursor: VirtualCursor = get_node("../../Virtual Cursor") as VirtualCursor
@onready var neighbours_hitbox: Area3D = $Object/NeighboursHitbox as Area3D
@onready var selectable_indicator: MeshInstance3D = $Object/SelectableIndicator as MeshInstance3D
@onready var overclock_indicator: MeshInstance3D = $Object/OverclockIndicator as MeshInstance3D
@onready var progress_viewport_scene: PackedScene = load("res://scenes/progress_bar_viewport.tscn")
@onready var menu_viewport_scene: PackedScene = load("res://scenes/menu_viewport.tscn")
@onready var sfx_manager: SFXManager = get_node("/root/World/SFXManager")

var connected_nodes: Dictionary[SpaceNode, Edge] = {}

var is_hacked: bool = false
var is_being_hacked: bool = false
var hack_cost: float = 0
var hack_time: float = 0
var ram_gain: float = 0
var closest_node: SpaceNode
var range_ring: MeshInstance3D
var menu: Node3D = null
var is_hack_protected: bool = false
var hack_protection_duration: float = 5


func _ready() -> void:
	hack_timer.timeout.connect(_on_hack_finish)
	generate_selectable_indicator_mesh()


#=== INITIALIZATION ===


func generate_selectable_indicator_mesh() -> void:
	var torus := TorusMesh.new()
	torus.material = load("res://assets/materials/emission_material.tres")
	torus.inner_radius = 1.5
	torus.outer_radius = 1.6
	selectable_indicator.mesh = torus


func make_root(scene: PackedScene) -> void:
	make_probe(scene)

	is_hacked = true
	Hacker.add_hacked_node(self)
	Hacker.update_ram_display()
	($Object/Grid as MeshInstance3D).set_surface_override_material(
		0, load("res://assets/materials/space_node_shadow_blue.tres") as Material
	)
	_update_label()


func make_planet(scene: PackedScene) -> void:
	var model: Node3D = scene.instantiate()
	model.rotation.x = randf_range(0, TAU)
	model.rotation.y = randf_range(0, TAU)
	model.rotation.z = randf_range(0, TAU)
	$Object.add_child(model)
	ram_gain = 60
	hack_cost = [16, 24, 32].pick_random()
	hack_time = randi_range(8, 16)
	_update_label()


func make_ship(scene: PackedScene) -> void:
	var model: Node3D = scene.instantiate()
	model.rotation.x = randf_range(0, TAU)
	model.rotation.y = randf_range(0, TAU)
	model.rotation.z = randf_range(0, TAU)
	$Object.add_child(model)
	hack_cost = [8, 16, 24].pick_random()
	hack_time = randi_range(4, 8)
	_update_label()


func make_probe(scene: PackedScene) -> void:
	var model: Node3D = scene.instantiate()
	model.rotation.x = randf_range(0, TAU)
	model.rotation.y = randf_range(0, TAU)
	model.rotation.z = randf_range(0, TAU)
	$Object.add_child(model)
	hack_cost = [6, 8, 16].pick_random()
	hack_time = randi_range(3, 5)
	_update_label()


func make_asteroid(scene: PackedScene) -> void:
	var model: Node3D = scene.instantiate()
	model.rotation.x = randf_range(0, TAU)
	model.rotation.y = randf_range(0, TAU)
	model.rotation.z = randf_range(0, TAU)
	$Object.add_child(model)
	hack_cost = [8, 16, 24].pick_random()
	hack_time = randi_range(6, 12)
	_update_label()


#=== LOGIC ===


func get_closest_hacked_node(selection_range: float = Hacker.selection_range) -> SpaceNode:
	var closest: SpaceNode = null
	var distance: float = INF
	for node_area: Area3D in neighbours_hitbox.get_overlapping_areas():
		var node: SpaceNode = node_area.get_parent().get_parent() as SpaceNode
		if node == self:
			continue
		if node.is_hacked and not node.is_being_hacked:
			var test_distance := position.distance_to(node.position)
			if test_distance < distance and test_distance < selection_range:
				distance = test_distance
				closest = node
	return closest


func hack() -> void:
	if is_being_hacked:
		return

	if Hacker.is_overclocked:
		closest_node = get_closest_hacked_node(Hacker.overclock_selection_range)
	else:
		closest_node = get_closest_hacked_node()
	if closest_node == null:
		return

	var can_compute: bool = Hacker.can_compute_action(hack_cost)
	if not can_compute:
		Hacker.send_message("NOT ENOUGH RAM")
		return
	if !is_hacked:
		Hacker.use_overclock()
		sfx_manager.play_high_boop()
		(get_node("../../EnemyManager") as EnemyManager).initial_start()
		show_friendly_hack_indicator()
		Hacker.register_hack(hack_cost, self)
		Hacker.update_ram_display()
		hack_timer.start(hack_time)
		is_being_hacked = true
		selectable_indicator.visible = false
		var progress_viewport: ProgressViewport = progress_viewport_scene.instantiate()
		progress_viewport.name = "progress_viewport"
		add_child(progress_viewport)
		progress_viewport.start_timer(hack_time)


func unhack() -> void:
	Hacker.remove_hacked_node(self)
	_unhack_cleanup()


func unhack_free() -> void:
	Hacker.remove_hacked_node_free(self)
	_unhack_cleanup()


func _unhack_cleanup() -> void:
	Hacker.update_ram_display()
	is_hacked = false
	hack_cost *= 2
	hack_time *= 2
	for neighbour: SpaceNode in connected_nodes:
		neighbour.connected_nodes[self].queue_free()
		neighbour.connected_nodes.erase(self)
	connected_nodes.clear()
	_update_label()
	($Object/Grid as MeshInstance3D).set_surface_override_material(
		0, load("res://assets/materials/space_node_shadow_green.tres") as Material
	)
	virtual_cursor.update_closest_node()


func instant_hack() -> void:
	if not Hacker.is_overclocked:
		return
	Hacker.use_overclock()
	hack_timer.stop()
	_on_hack_finish()


func instant_defend() -> void:
	if not Hacker.is_overclocked:
		return
	var enemy_manager: EnemyManager = get_node("/root/World/EnemyManager")
	for enemy_timer: SmallEnemyTimer in enemy_manager.small_attacks:
		var attack: EnemyManager.SmallAttack = enemy_manager.small_attacks[enemy_timer]
		if attack.target == self:
			enemy_manager.stop_small_enemy_attack(enemy_timer)
			Hacker.use_overclock()


func show_menu() -> void:
	hide_menu()
	menu = menu_viewport_scene.instantiate()
	add_child(menu)


func hide_menu() -> void:
	if menu != null:
		menu.queue_free()
	menu = null


func generate_ring(radius: float, difference: float) -> void:
	if range_ring != null:
		range_ring.queue_free()
	range_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.material = load("res://assets/materials/emission_material.tres")
	torus.inner_radius = radius
	torus.outer_radius = radius + difference
	range_ring.mesh = torus
	$Object.add_child(range_ring)


func delete_ring() -> void:
	range_ring.queue_free()
	range_ring = null


func highlight_nearby(hack_range: float) -> void:
	var nearby_nodes := _get_nearby_unhacked_nodes().filter(
		func(node: SpaceNode) -> bool: return position.distance_to(node.position) < hack_range
	)
	for node: SpaceNode in nearby_nodes:
		node.highlight_self()


func stop_highlight_nearby() -> void:
	var nearby_nodes := _get_nearby_unhacked_nodes()
	for node: SpaceNode in nearby_nodes:
		node.stop_highlight_self()


func _get_nearby_unhacked_nodes() -> Array[SpaceNode]:
	var nearby_areas := neighbours_hitbox.get_overlapping_areas()
	var nearby_nodes: Array[SpaceNode]
	nearby_nodes.assign(
		(
			nearby_areas
			. map(
				func(area: Area3D) -> SpaceNode: return area.get_parent().get_parent() as SpaceNode
			)
			. filter(func(node: SpaceNode) -> bool: return !node.is_hacked)
		)
	)
	return nearby_nodes as Array[SpaceNode]


func highlight_self() -> void:
	if not is_hacked and not is_being_hacked:
		selectable_indicator.visible = true


func stop_highlight_self() -> void:
	selectable_indicator.visible = false


func _update_label() -> void:
	if is_hacked:
		info.text = "Hacked"
	else:
		info.text = "Cost: %s Time: %s" % [hack_cost, hack_time]


func show_friendly_hack_indicator() -> void:
	($Object/EnemyHackIndicator as Node3D).visible = false
	($Object/FriendlyHackIndicator as Node3D).visible = true


func show_enemy_hack_indicator() -> void:
	($Object/FriendlyHackIndicator as Node3D).visible = false
	($Object/EnemyHackIndicator as Node3D).visible = true


func hide_hack_indicators() -> void:
	($Object/FriendlyHackIndicator as Node3D).visible = false
	($Object/EnemyHackIndicator as Node3D).visible = false
	overclock_indicator.visible = false


func start_hack_protection() -> void:
	is_hack_protected = true
	var timer: Timer = Timer.new()
	timer.timeout.connect(
		func() -> void:
			is_hack_protected = false
			timer.queue_free()
	)
	add_child(timer)
	timer.start(hack_protection_duration)


#=== CALLBACKS ===


func _on_hack_finish() -> void:
	is_being_hacked = false
	hide_menu()
	if !is_hacked:
		sfx_manager.play_rise_a()
		Hacker.deregister_hack(hack_cost, self)
		Hacker.add_hacked_node(self)
		Hacker.increase_ram_total(ram_gain)
		Hacker.update_ram_display()
		is_hacked = true

		if not closest_node.is_hacked:
			closest_node = get_closest_hacked_node(Hacker.overclock_selection_range)
		if closest_node != null:
			var edge: Edge = (get_node("../../Edges") as Edger).create_edge(self, closest_node)
			closest_node.connected_nodes[self] = edge
			connected_nodes[closest_node] = edge

		_update_label()
		virtual_cursor.update_closest_node()
		($Object/Grid as MeshInstance3D).set_surface_override_material(
			0, load("res://assets/materials/space_node_shadow_blue.tres") as Material
		)
		var progress_viewport: Node3D = get_node_or_null("progress_viewport")
		if progress_viewport != null:
			progress_viewport.queue_free()
	else:
		sfx_manager.play_rise_c()
		unhack()
	hide_hack_indicators()


func _on_area_3d_input_event(
	_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event.is_action_pressed("select"):
		if not is_hacked and not is_being_hacked:
			hack()
		elif not is_hacked and is_being_hacked:
			instant_hack()
		elif is_hacked and is_being_hacked:
			instant_defend()

	if event.is_action_pressed("secondary"):
		if is_hacked and not is_being_hacked:
			show_menu()


func _set_hover_color() -> void:
	if (not is_hacked and not is_being_hacked) or (is_being_hacked and Hacker.is_overclocked):
		sfx_manager.play_low_boop()
		selectable_indicator.mesh.surface_set_material(
			0, load("res://assets/materials/hover_emission_material.tres") as Material
		)
		overclock_indicator.mesh.surface_set_material(
			0, load("res://assets/materials/hover_emission_material.tres") as Material
		)


func _unset_hover_color() -> void:
	selectable_indicator.mesh.surface_set_material(
		0, load("res://assets/materials/emission_material.tres") as Material
	)
	overclock_indicator.mesh.surface_set_material(
		0, load("res://assets/materials/overclock_emission_material.tres") as Material
	)
