extends Node2D

@onready var flash_rect := $CanvasLayer/Control/ColorRect
var flash_tween: Tween

@onready var questionlabel = $CanvasLayer/Control/questionlabel
@onready var hplabel = $hplabel
@onready var scorelabel = $CanvasLayer/Control/scorelabel

var fallboxscene: PackedScene = preload("res://scenes/box.tscn")
const box_width := 206 #untuk scale 0.7
var box_x 
var box_y = 425 #awal box jatuh
var gaps

var hp := 5
var score := 0

var arraynumber := []
var arrayorder := []

var nextshift := 1
var is_generating := false
var spawn_id := 0   # 🔑 wave/version ID

var correctanswer := 0
var correct_out_screen := false
var clicked_right = null




func _ready():
	var screen_width := get_viewport_rect().size.x
	gaps = (screen_width - 3 * box_width) / (3 + 1) #gaps untuk 3 boxes
	
	randomize()
	start_round()


func _process(delta):
	handle_result()
	handle_generation()
	update_ui()


# =========================
# ROUND CONTROL (IMMEDIATE)
# =========================
func start_round():
	spawn_id += 1               # ❗ invalidate old waves
	is_generating = false
	deleteparentboxes()
	
	

	generatequestion()
	generateorder()

	nextshift = 1
	clicked_right = null
	correct_out_screen = false


func handle_result():
	if clicked_right == null and not correct_out_screen:
		return

	if clicked_right == true:
		glow_screen_soft()
		score += 100
	else:
		shake()
		hp -= 1

	start_round()


# =========================
# GENERATION CONTROL
# =========================
func handle_generation():
	if is_generating:
		return

	if nextshift == 1 and $parentboxes.get_child_count() == 0:
		is_generating = true
		nextshift = 2
		generateboxes1(spawn_id)

	elif nextshift == 2 and $parentboxes.get_child_count() == 0:
		is_generating = true
		nextshift = 3
		generateboxes2(spawn_id)

	elif nextshift == 3 and $parentboxes.get_child_count() == 0:
		is_generating = true
		nextshift = 4
		generateboxes3(spawn_id)

# =========================
# ASYNC-SAFE SPAWNING
# =========================
func generateboxes1(id):
	if id != spawn_id:
		return

	generatebox(arrayorder[0], arraynumber[0])

	await get_tree().create_timer(randi_range(1, 3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[1], arraynumber[1])

	await get_tree().create_timer(randi_range(1, 3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[2], arraynumber[2])

	is_generating = false


func generateboxes2(id):
	if id != spawn_id:
		return

	generatebox(arrayorder[3], arraynumber[3])

	await get_tree().create_timer(randi_range(1, 3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[4], arraynumber[4])

	await get_tree().create_timer(randi_range(1, 3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[5], arraynumber[5])

	is_generating = false

func generateboxes3(id):
	if id != spawn_id:
		return

	generatebox(arrayorder[6], arraynumber[6])

	await get_tree().create_timer(randi_range(1, 3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[7], arraynumber[7])

	await get_tree().create_timer(randi_range(1, 3)).timeout
	if id != spawn_id:
		return

	generatebox(arrayorder[8], arraynumber[8])

	is_generating = false


# =========================
# QUESTION / DATA
# =========================
func get_wrong_numbers(erasednumber):
	var numbers = [0,1,2,3,4,5,6,7,8,9,10]
	numbers.erase(erasednumber)
	numbers.shuffle()
	return numbers


func generatequestion():
	var op = randi_range(1,2)
	if op == 1: #penjumlahan
		correctanswer = randi_range(0, 10)
		var a = randi_range(0, correctanswer)
		var b = correctanswer - a
		questionlabel.text = str(a) + " + " + str(b) + " = ?"
	elif op == 2:
		correctanswer = randi_range(0, 10)
		var b = randi_range(0, 10)
		var a = b + correctanswer
		questionlabel.text = str(a) + " - " + str(b) + " = ?"
		
	var numbers = get_wrong_numbers(correctanswer)
	
	arraynumber = numbers.slice(0,8)
	arraynumber.append(correctanswer)
	arraynumber.shuffle()


func generateorder():
	var a1 = ["left", "center", "right"]
	var a2 = ["left", "center", "right"]
	var a3 = ["left", "center", "right"]
	a1.shuffle()
	a2.shuffle()
	a3.shuffle()
	arrayorder = a1 + a2 + a3


# =========================
# BOX CREATION
# =========================
func generatebox(type, numberlabel):
	var box = fallboxscene.instantiate()
	box.spawn_id = spawn_id     # 🔑 attach wave ID
	$parentboxes.add_child(box)

	if type == "left":
		box_x = gaps + box_width / 2 + 0 * (box_width + gaps)
	elif type == "center":
		box_x = gaps + box_width / 2 + 1 * (box_width + gaps)
	else:
		box_x = gaps + box_width / 2 + 2 * (box_width + gaps)
	
	box.position = Vector2(box_x, box_y)


	box.set_label(numberlabel)
	box.set_speed(randi_range(150, 200))
	
	var index = str(numberlabel)[-1]
	#box.setup(COLORS[index])
	box.get_node("AnimatedSprite2D").play(index)
	
		
	box.connect("out_of_screen", box_out_of_screen)
	box.connect("button_pressed", box_pressed)


# =========================
# SIGNAL HANDLERS (SAFE)
# =========================
func box_out_of_screen(number, box_spawn_id):
	if box_spawn_id != spawn_id:
		return

	if number == correctanswer:
		correct_out_screen = true


func box_pressed(number, box_spawn_id):
	#if box_spawn_id != spawn_id:
	#	return

	if number == correctanswer:
		clicked_right = true
	else:
		clicked_right = false


func deleteparentboxes():
	for c in $parentboxes.get_children():
		c.queue_free()


func update_ui():
	hplabel.text = "HP: " + str(hp)
	scorelabel.text = "SCORE: " + str(score)

	if hp <= 0:
		print("gameover")
		hp = 5

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
