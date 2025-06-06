class_name SFXManager
extends AudioStreamPlayer

@onready var player: AudioStreamPlaybackPolyphonic = null

var rises: AudioStreamRandomizer
var boops: AudioStreamRandomizer

@onready var risea: AudioStream = AudioStreamWAV.load_from_file("res://assets/sfx/UI sfx rise a.wav")
@onready var riseb: AudioStream = AudioStreamWAV.load_from_file("res://assets/sfx/UI sfx rise b.wav")
@onready var risec: AudioStream = AudioStreamWAV.load_from_file("res://assets/sfx/UI sfx rise c.wav")

@onready var boop1: AudioStream = AudioStreamWAV.load_from_file("res://assets/sfx/UI sfx high.wav")
@onready var boop2: AudioStream = AudioStreamWAV.load_from_file("res://assets/sfx/UI sfx mid.wav")
@onready var boop3: AudioStream = AudioStreamWAV.load_from_file("res://assets/sfx/UI sfx low.wav")


func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	play()
	player = get_stream_playback()

	rises = AudioStreamRandomizer.new()
	rises.add_stream(-1, risea)
	rises.add_stream(-1, riseb)
	rises.add_stream(-1, risec)

	boops = AudioStreamRandomizer.new()
	boops.add_stream(-1, boop1)
	boops.add_stream(-1, boop2)
	boops.add_stream(-1, boop3)


## RISES
func play_random_rise() -> void:
	player.play_stream(rises, 0, 0)


func play_rise_a() -> void:
	player.play_stream(risea, 0, 0)


func play_rise_b() -> void:
	player.play_stream(riseb, 0, 0)


func play_rise_c() -> void:
	player.play_stream(risec, 0, 0)


## BOOPS
func play_random_boop() -> void:
	player.play_stream(boops, 0, 0)


func play_high_boop() -> void:
	player.play_stream(boop1, 0, 0)


func play_mid_boop() -> void:
	player.play_stream(boop2, 0, 0)


func play_low_boop() -> void:
	player.play_stream(boop3, 0, 0)
