extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	AudioController.stop_bgm()
	AudioController.play_gameover()
	
	if Global.score > Global.highscore :
		$CanvasLayer/Control/PanelContainer4/newhslabel.visible = true
		Global.highscore = Global.score
	else :
		$CanvasLayer/Control/PanelContainer4/newhslabel.visible = false
		
	$CanvasLayer/Control/PanelContainer2/highscorelabel.text = "High Score: "+ str(Global.highscore)
	$CanvasLayer/Control/PanelContainer3/scorelabel.text = "Score: "+ str(Global.score)

func _on_button_pressed():
	Global.maxhp = 5
	Global.hp = 5 
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/fall3.tscn")

