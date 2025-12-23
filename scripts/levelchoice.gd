extends Node2D


# Called when the node enters the scene tree for the first time.

func _on_button_pressed():
	Global.difficulty = "easy"
	Global.hp = Global.maxhp[Global.difficulty]
	Global.score = 0
	
	get_tree().change_scene_to_file("res://scenes/fall3.tscn")
