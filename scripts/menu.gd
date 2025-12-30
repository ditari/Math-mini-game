extends Node2D

func _on_button_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()	
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/levelchoice.tscn")

func _on_button_3_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()	
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_button_2_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()	
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/highscore.tscn")
		

func _on_button_4_pressed():
	if Global.audio_settings["sounds"]:
		AudioController.play_button()	
	
	await get_tree().create_timer(0.3).timeout	
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
	
