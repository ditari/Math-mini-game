extends Node2D

@onready var easylabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/easylabel
@onready var normallabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer2/normallabel
@onready var hardlabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer3/hardlabel
@onready var expertlabel = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer4/expertlabel

# Called when the node enters the scene tree for the first time.
func _ready():
	easylabel.text = str (Global.highscore["easy"])
	normallabel.text = str (Global.highscore["normal"])
	hardlabel.text = str (Global.highscore["hard"])
	expertlabel.text = str (Global.highscore["expert"])


func _on_button_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()

	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

