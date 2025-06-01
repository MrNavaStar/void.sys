extends VBoxContainer

var messages: Dictionary[SpaceNode, Label] = {}

@onready
var attack_message_scene: PackedScene = load("res://scenes/attack_message.tscn") as PackedScene


func _ready() -> void:
	Hacker.node_attack.connect(_on_receive_message)
	Hacker.node_defended.connect(_on_delete_message)


func _on_receive_message(node: SpaceNode) -> void:
	var message: Label = attack_message_scene.instantiate() as Label
	message.text = "%s FIREWALL ACTIVATED" % node.name.to_upper()
	messages[node] = message
	add_child(message)


func _on_delete_message(node: SpaceNode) -> void:
	if not messages.has(node):
		return
	messages[node].queue_free()
	messages.erase(node)
