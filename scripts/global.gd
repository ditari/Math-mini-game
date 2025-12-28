extends Node

const SAVE_PATH := "user://save.json"

var hp = 5 #currenthp

var maxhp  = {
	"easy": 5,
	"normal": 4,
	"hard": 3,
	"expert" : 3
}

var difficulty = "easy"

var score = 0 #currentscore

var highscore = {
	"easy": 0,
	"normal": 0,
	"hard": 0,
	"expert" : 0
}

var audio_settings = {
	"bgm": true,    
	"sounds": true
}

func _ready():
	load_data()
	
# ======================
# SAVE / LOAD
# ======================
func save_data():
	
	var data := {
		"highscore": highscore,
		"audio_settings": audio_settings
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		save_data()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)

	if data == null:
		return

	if data.has("highscore"):
		highscore = data["highscore"]

	if data.has("audio_settings"):
		for key in data["audio_settings"]:
			audio_settings[key] = data["audio_settings"][key]

