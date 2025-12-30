extends Node2D


#easy
func _on_button_pressed():
	Global.difficulty = "easy"
	Global.hp = Global.maxhp["easy"]
	Global.score = 0

	if Global.audio_settings["sounds"]:
		AudioController.play_button()	
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/fall3_easy.tscn")


func _on_button_2_pressed():
	Global.difficulty = "normal"
	Global.hp = Global.maxhp["normal"]
	Global.score = 0
	
	if Global.audio_settings["sounds"]:
		AudioController.play_button()
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/fall3_normal.tscn")
	


func _on_button_3_pressed():
	Global.difficulty = "hard"
	Global.hp = Global.maxhp["hard"]
	Global.score = 0
	
	if Global.audio_settings["sounds"]:
		AudioController.play_button()
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/fall3_hard.tscn")
	
func _on_button_4_pressed():
	Global.difficulty = "expert"
	Global.hp = Global.maxhp["expert"]
	Global.score = 0
	
	if Global.audio_settings["sounds"]:
		AudioController.play_button()
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/fall3_expert.tscn")


func _on_button_5_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()

	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

