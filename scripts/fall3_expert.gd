extends Node2D

@onready var flash_rect := $CanvasLayer/Control/ColorRect
var flash_tween: Tween

@onready var questionlabel =$CanvasLayer/Control/PanelContainer/questionlabel
@onready var scorelabel = $CanvasLayer/Control/PanelContainer2/scorelabel
@onready var clicklabel = $CanvasLayer/Control/PanelContainer3/clicklabel
@onready var heart_bar := $CanvasLayer/heartbar
var heartscene: PackedScene = preload("res://scenes/heart.tscn")

var fallboxscene: PackedScene = preload("res://scenes/box.tscn")
const box_width := 200 
var box_x 
var box_y = 480 #awal box jatuh
var gaps

#kecepatan fall box
var speedmin = 50
var speedmax = 100

var maxhp = Global.maxhp[Global.difficulty]
var hp = Global.hp
var score = Global.score

var arraynumber := []
var arrayorder := []

var nextshift = 1 #ga dipakai di fall3
var is_generating := false
var spawn_id := 0   # 🔑 wave/version ID

var correctanswer := 0
var correct_out_screen := false
var clicked_right = null

var reward 
const reward1 = 50
const reward2 = 100
const reward3 = 150
const reward4 = 200 #dipakai di hard dan expert

#timer
var level_time = 0.0
const LEVEL_DURATION = 120.0 #seconds
var level_finished = false

var round_resolved = false

func _ready():
	print("fall3hard")
	var screen_width := get_viewport_rect().size.x
	gaps = (screen_width - 3 * box_width) / (3 + 1) #gaps untuk 3 boxes
	
	if Global.audio_settings["bgm"]:
		AudioController.play_bgm()
	
	setup_hearts() #heartbar
	randomize()
	start_round() 
	

func _process(delta):
	if level_finished:
		return

	level_time += delta	
	
	handle_result()
	handle_generation()
	update_ui()

# =========================
# Heart Bar
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
# Flash screen and shake
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

func shake(strength := 7.0, duration := 0.16):
	var original_pos := position
	var tween := create_tween()

	tween.tween_property(self, "position", original_pos + Vector2(strength, 1), 0.03)
	tween.tween_property(self, "position", original_pos - Vector2(strength * 0.8, 1), 0.03)
	tween.tween_property(self, "position", original_pos + Vector2(strength * 0.4, 0), 0.03)
	tween.tween_property(self, "position", original_pos, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	
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
		
		clicklabel.text = "+"+ str(reward)
		clicklabel.visible = true
		await get_tree().create_timer(0.2).timeout
		clicklabel.visible = false
		
		
	else:
		clicked_right = false	
		
func deleteparentboxes():
	for c in $parentboxes.get_children():
		c.queue_free()


func update_ui():
	scorelabel.text = "SCORE: " + str(score)
	update_hearts()
	
	if hp <= 0:
		Global.score = score
		get_tree().change_scene_to_file("res://scenes/gameover.tscn")	
		
# =========================
# ROUND CONTROL
# =========================
func start_round():
	# 🚨 stop before generating next question
	if level_time >= LEVEL_DURATION:
		#level_finished = true
		end_level()
		return	
	
	spawn_id += 1               # ❗ invalidate old waves
	is_generating = false
	deleteparentboxes()

	generatequestion()
	generateorder()

	nextshift = 1 #sebenarnya ga butuh buat fall3
	clicked_right = null
	correct_out_screen = false
	round_resolved = false   # 🔑 reset lock
	
func handle_result():
	if level_finished or round_resolved:
		return
	
	if clicked_right == null and not correct_out_screen:
		return
		
	round_resolved = true   # 🔒 LOCK

	if clicked_right == true:
		glow_screen_soft()
		if Global.audio_settings["sounds"]:
			AudioController.play_correct()
		score += reward
	else:
		shake()
		if Global.audio_settings["sounds"]:
			AudioController.play_wrong()
		hp -= 1

	start_round()	
	
# =========================
# Level end before next round started
# =========================	
	
func end_level():
	if level_finished:
		return

	level_finished = true
	
	spawn_id += 1 # invalidate async spawns
	Global.score = score
	Global.hp = hp
	await get_tree().create_timer(0.3).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/fall6_expert.tscn")
	
# =========================
# GENERATION (ONE WAVE)
# =========================
func handle_generation():
	if level_finished:
		return	
	
	if is_generating:
		return

	if $parentboxes.get_child_count() == 0:
		is_generating = true
		generate_boxes(spawn_id)
	
	
# =========================
# Async spawning
# =========================	

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
# Box creation
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
	box.set_speed(randi_range(speedmin, speedmax))
	
	var index = str(numberlabel)[-1]
	#box.setup(COLORS[index])
	box.get_node("AnimatedSprite2D").play(index)
	
	box.connect("out_of_screen", box_out_of_screen)
	box.connect("button_pressed", box_pressed)

# =========================
# QUESTION / DATA
# =========================

func generate_arraynumber(correctanswer) :
	
	var numbers
	if correctanswer < 7:
		numbers = range (0,7)
	elif correctanswer > 93:
		numbers = range (94,101)
	else:
		numbers = range(correctanswer-3, correctanswer+4)
	#numbers = 7 elements	
	
	numbers.erase(correctanswer)
	#numbers = 6 elements
	numbers.shuffle()

	var result := []

	#choose 2 out of 6
	for i in range(2):
		result.append(numbers[i])

	result.append(correctanswer)
	result.shuffle()

	return result
	
func generateorder():
	var a = ["left", "center", "right"]
	a.shuffle()
	arrayorder = a	
	
func generatequestion():
	var roll := randi() % 100  # 0–99

	if roll < 20:
		generatequestion1()
	elif roll < 40:
		generatequestion2()
	elif roll < 60:
		generatequestion3()
	elif roll < 80:
		generatequestion4()
	else :
		generatequestion5()

	arraynumber = generate_arraynumber(correctanswer)

#di expert no carry mulai dari 0 hingga 2 digit
#di normal dan hard no carry hanya 2 digit

func add_no_carry(max_val):
	reward = reward1
	for i in 100:
		var a = randi_range(1, max_val)
		var b = randi_range(1, max_val)

		if (a % 10) + (b % 10) >= 10:
			continue

		if a + b > max_val:
			continue

		correctanswer = a + b
		questionlabel.text = str(a) + " + " + str(b) + " = ?"
		return

	# fallback
	add_single_digit()
	
func add_with_carry(max_val):
	reward = reward3
	for i in 100:
		var a = randi_range(1, max_val)
		var b = randi_range(1, max_val)

		if (a % 10) + (b % 10) < 10:
			continue

		if a + b > max_val:
			continue

		correctanswer = a + b
		questionlabel.text = str(a) + " + " + str(b) + " = ?"
		return

	# fallback
	add_single_digit()	

func sub_no_borrow(max_val):
	reward = reward1
	for i in 100:
		var a = randi_range(1, max_val)
		var b = randi_range(1, a)

		if (a % 10) < (b % 10):
			continue

		correctanswer = a - b
		questionlabel.text = str(a) + " - " + str(b) + " = ?"
		return

	# fallback
	sub_single_digit()

func sub_with_borrow(max_val):
	reward = reward3
	for i in 100:
		var a = randi_range(1, max_val)
		var b = randi_range(1, a)

		if (a % 10) >= (b % 10):
			continue

		correctanswer = a - b
		questionlabel.text = str(a) + " - " + str(b) + " = ?"
		return

	# fallback
	sub_single_digit()

func add_single_digit():
	reward = reward1
	var a = randi_range(0, 9)
	var b = randi_range(0, 9)
	correctanswer = a + b
	questionlabel.text = str(a) + " + " + str(b) + " = ?"

func sub_single_digit():
	reward = reward1
	var a = randi_range(0, 9)
	var b = randi_range(0, a)
	correctanswer = a - b
	questionlabel.text = str(a) + " - " + str(b) + " = ?"

func generatequestion1(): #add sub no carry
	if (randi() & 1) == 0:
		add_no_carry(100) 
	else:
		sub_no_borrow(100)

func generatequestion2(): #multiply 1-10 x 1-10
	reward = reward2
	var a = randi_range(1,10)
	var b = randi_range(1,10)
	correctanswer = a * b
	questionlabel.text = str(a) + " x " + str(b) + " = ?"
	
func generatequestion3(): #add sub with carry
	if (randi() & 1) == 0:
		add_with_carry(100) 
	else:
		sub_with_borrow(100)
	
func generatequestion4(): #round division up to 100
	reward = reward3
	var b = randi_range(1, 100)
	var correctanswer = randi_range(1, 100 / b)
	var a = b * correctanswer
	questionlabel.text = str(a) + " / " + str(b) + " = ?"
	
func generatequestion5(): #multiply 11-20 x b <=100
	reward = reward4
	var a = randi_range(11,20)
	var b = randi_range(1, int(100 / a))
	correctanswer = a * b
	questionlabel.text = str(a) + " x " + str(b) + " = ?"

