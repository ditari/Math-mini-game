extends Node2D

@onready var new_hs_label = $CanvasLayer/Control/PanelContainer2/newhslabel
@onready var highscore_label = $CanvasLayer/Control/PanelContainer3/highscorelabel
@onready var score_label = $CanvasLayer/Control/PanelContainer4/scorelabel

@onready var panel = $CanvasLayer/Control/PanelContainer 
@onready var panel2 = $CanvasLayer/Control/PanelContainer2 
@onready var panel3 = $CanvasLayer/Control/PanelContainer3 
@onready var panel4 = $CanvasLayer/Control/PanelContainer4 
@onready var hbox =  $CanvasLayer/Control/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	#audio
	AudioController.stop_bgm()
	AudioController.play_gameover()

	#panel positioning
	panel.offset_top = get_viewport_rect().size.y * 0.1
	panel2.offset_top = get_viewport_rect().size.y * 0.3
	panel3.offset_top = get_viewport_rect().size.y * 0.45
	panel4.offset_top = (get_viewport_rect().size.y * 0.45) + 100
	hbox.offset_top = get_viewport_rect().size.y * 0.75
	
	#scores
	if Global.score > Global.highscore[Global.difficulty] :
		new_hs_label.visible = true
		Global.highscore[Global.difficulty] = Global.score
		#save
		Global.save_data()
	else :
		new_hs_label.visible = false
		
	highscore_label.text = "High Score: "+ str(Global.highscore[Global.difficulty])
	score_label.text = "Score: "+ str(Global.score)

func _on_button_pressed():
	Global.difficulty = "easy"
	Global.hp = Global.maxhp[Global.difficulty]
	Global.score = 0
	
	get_tree().change_scene_to_file("res://scenes/fall3.tscn")

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://scenes/levelchoice.tscn")
