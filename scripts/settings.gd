extends Node2D

@onready var check_btn = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/CheckButton
@onready var check_btn2 = $CanvasLayer/Control/MarginContainer/VBoxContainer/HBoxContainer2/CheckButton2
# Called when the node enters the scene tree for the first time.

var bgm = Global.audio_settings["bgm"]
var sounds = Global.audio_settings["sounds"]

func _ready():
	
	if bgm :
		check_btn.button_pressed = true
		check_btn.text = "ON"
	else :
		check_btn.button_pressed = false
		check_btn.text = "OFF"

	if sounds :
		check_btn2.button_pressed = true
		check_btn2.text = "ON"
	else :
		check_btn2.button_pressed = false
		check_btn2.text = "OFF"


func _on_check_button_toggled(button_pressed):
	if button_pressed:
		check_btn.text = "ON"
		bgm = true
	else:
		check_btn.text = "OFF"
		bgm = false

func _on_check_button_2_toggled(button_pressed):
	if button_pressed:
		check_btn2.text = "ON"
		sounds = true
	else:
		check_btn2.text = "OFF"
		sounds = false

func _on_button_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()

	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_button_2_pressed():
		
	if bgm :
		Global.audio_settings["bgm"] = true
	else :
		Global.audio_settings["bgm"] = false
		
	if sounds:
		Global.audio_settings["sounds"] = true
	else :
		Global.audio_settings["sounds"] = false
			
	if Global.audio_settings["sounds"]:
		AudioController.play_button()				
			
	Global.save_data()
