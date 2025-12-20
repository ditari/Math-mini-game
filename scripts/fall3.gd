extends Node2D

@onready var flash_rect := $CanvasLayer/Control/ColorRect
var flash_tween: Tween

@onready var questionlabel =$CanvasLayer/Control/PanelContainer/questionlabel
@onready var scorelabel = $CanvasLayer/Control/PanelContainer2/scorelabel

@onready var heart_bar := $CanvasLayer/heartbar
var heartscene: PackedScene = preload("res://scenes/heart.tscn")

var fallboxscene: PackedScene = preload("res://scenes/box.tscn")
const box_width := 206 #untuk scale 0.7
var box_x 
var box_y = 425 #awal box jatuh
var gaps

var maxhp := 5
var hp := 5
var score := 0

var arraynumber := []
var arrayorder := []

var nextshift = 1 #ga dipakai di fall3
var is_generating := false
var spawn_id := 0   # 🔑 wave/version ID

var correctanswer := 0
var correct_out_screen := false
var clicked_right = null

#var screen_size
#var gaps


func _ready():
	#screen_size = get_viewport_rect().size
	var screen_width := get_viewport_rect().size.x
	gaps = (screen_width - 3 * box_width) / (3 + 1) #gaps untuk 3 boxes
	AudioController.play_bgm()
	
	setup_hearts()
	randomize()
	start_round()
	


func _process(delta):
	handle_result()
	handle_generation()
	update_ui()

# =========================
# heart bar
# =========================
func setup_hearts():
	for child in heart_bar.get_children():
		child.queue_free()

	for i in range(maxhp):
		var heart = heartscene.instantiate()
		heart_bar.add_child(heart)

	update_hearts()

func update_hearts():
	for i in range(heart_bar.get_child_count()):
		var heart = heart_bar.get_child(i)
		heart.visible = i < hp

# =========================
# flash screen and shake
# =========================

func _stop_flash():
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()

func glow_screen_soft():
	_stop_flash()

	flash_rect.color = Color(0.9, 1, 0.9)
	flash_rect.modulate.a = 0.05

	flash_tween = create_tween()
	flash_tween.tween_property(flash_rect, "modulate:a", 0.1, 0.08)
	flash_tween.tween_property(flash_rect, "modulate:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
func shake(strength := 6.0, duration := 0.15):
	var original_pos := position

	var tween := create_tween()
	tween.tween_property(
		self,
		"position",
		original_pos + Vector2(strength, 0),
		0.04
	)
	tween.tween_property(
		self,
		"position",
		original_pos - Vector2(strength, 0),
		0.04
	)
	tween.tween_property(
		self,
		"position",
		original_pos,
		duration
	).set_ease(Tween.EASE_OUT)
	
# =========================
# SIGNALS
# =========================
func box_out_of_screen(number, box_spawn_id):
	if box_spawn_id != spawn_id:
		return

	if number == correctanswer:
		correct_out_screen = true


func box_pressed(number, box_spawn_id):
#	if box_spawn_id != spawn_id:
#		return

	if number == correctanswer:
		clicked_right = true
	else:
		clicked_right = false
		
# =========================
# other functions
# =========================		
	
		
func deleteparentboxes():
	for c in $parentboxes.get_children():
		c.queue_free()


func update_ui():
	#hplabel.text = "HP: " + str(hp)
	scorelabel.text = "SCORE: " + str(score)

	#harusnya updatehearts dulu baru gameover
	if hp <= 0:
		print("gameover")
		hp = 5
		
	update_hearts()

func get_wrong_numbers(erasednumber):
	var numbers = [0,1,2,3,4,5,6,7,8,9,10]
	numbers.erase(erasednumber)
	numbers.shuffle()
	return numbers

func handle_result():
	if clicked_right == null and not correct_out_screen:
		return

	if clicked_right == true:
		glow_screen_soft()
		AudioController.play_correct()
		score += 100
	else:
		shake()
		AudioController.play_wrong()
		hp -= 1


	start_round()

#====================================================dari sini isinya beda


# =========================
# ROUND CONTROL
# =========================
func start_round():
	spawn_id += 1           # invalidate old boxes
	is_generating = false
	deleteparentboxes()

	generatequestion()
	generateorder()

	clicked_right = null
	correct_out_screen = false





# =========================
# GENERATION (ONE WAVE)
# =========================
func handle_generation():
	if is_generating:
		return

	if $parentboxes.get_child_count() == 0:
		is_generating = true
		generate_boxes(spawn_id)


func generate_boxes(id):
	if id != spawn_id:
		return

	generatebox(arrayorder[0], arraynumber[0])

	await get_tree().create_timer(randi_range(1,3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[1], arraynumber[1])

	await get_tree().create_timer(randi_range(1,3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[2], arraynumber[2])

	is_generating = false


# =========================
# QUESTION / DATA
# =========================



func generatequestion():
	correctanswer = randi_range(0, 10)
	var a = randi_range(0, correctanswer)
	var b = correctanswer - a
	questionlabel.text = str(a) + " + " + str(b) + " = ?"

	var numbers = get_wrong_numbers(correctanswer)
	arraynumber = [
		correctanswer,
		numbers[0],
		numbers[1]
	]
	arraynumber.shuffle()


func generateorder():
	var a = ["left", "center", "right"]
	a.shuffle()
	arrayorder = a


# =========================
# BOX
# =========================
func generatebox(type, numberlabel):
	var box = fallboxscene.instantiate()
	box.spawn_id = spawn_id
	
	$parentboxes.add_child(box)

	if type == "left":
		box_x = gaps + box_width / 2 + 0 * (box_width + gaps)
	elif type == "center":
		box_x = gaps + box_width / 2 + 1 * (box_width + gaps)
	else:
		box_x = gaps + box_width / 2 + 2 * (box_width + gaps)
	
	box.position = Vector2(box_x, box_y)

	box.set_label(numberlabel)
	box.set_speed(randi_range(50, 100))
	
	var index = str(numberlabel)[-1]
	#box.setup(COLORS[index])
	box.get_node("AnimatedSprite2D").play(index)
	
	box.connect("out_of_screen", box_out_of_screen)
	box.connect("button_pressed", box_pressed)



