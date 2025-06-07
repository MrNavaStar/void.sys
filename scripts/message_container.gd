extends VBoxContainer

@export var message_time: float = 5
@export var max_messages: int = 5

var messages: Array[Label] = []

@onready
var status_message_scene: PackedScene = load("res://scenes/status_message.tscn") as PackedScene


func _ready() -> void:
	Hacker.message.connect(_on_receive_message)


func _on_receive_message(text: String) -> void:
	if messages.size() >= max_messages:
		messages.pop_front()
	var message: Label = status_message_scene.instantiate() as Label
	message.text = text
	messages.append(message)
	add_child(message)
	var timer: Timer = Timer.new()
	timer.timeout.connect(
		func() -> void:
			messages.erase(message)
			message.queue_free()
	)
	timer.one_shot = true
	message.add_child(timer)
	timer.start(message_time)
