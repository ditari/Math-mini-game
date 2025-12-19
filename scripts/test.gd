extends Node2D

@onready var heart_bar := $CanvasLayer/HeartBar
var max_hp := 3
var current_hp := 3
var heart_scene: PackedScene = preload("res://scenes/heart.tscn")

func _ready():
	setup_hearts()

func setup_hearts():
	for child in heart_bar.get_children():
		child.queue_free()

	for i in range(max_hp):
		var heart = heart_scene.instantiate()
		heart_bar.add_child(heart)

	update_hearts()

func update_hearts():
	for i in range(heart_bar.get_child_count()):
		var heart = heart_bar.get_child(i)
		heart.visible = i < current_hp
