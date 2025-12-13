extends Node2D

var fallboxscene: PackedScene = load("res://scenes/fallbox.tscn")

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

var screen_size
var gaps


func _ready():
	screen_size = get_viewport_rect().size
	gaps = ((screen_size.x - (160 * 3)) / 4)
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
		score += 100
	else:
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


# =========================
# QUESTION / DATA
# =========================
func get_wrong_numbers(erasednumber):
	var numbers = [0,1,2,3,4,5,6,7,8,9,10]
	numbers.erase(erasednumber)
	numbers.shuffle()
	return numbers


func generatequestion():
	correctanswer = randi_range(0, 10)
	var a = randi_range(0, correctanswer)
	var b = correctanswer - a
	$questionlabel.text = str(a) + " + " + str(b) + " = ?"

	var numbers = get_wrong_numbers(correctanswer)
	
	arraynumber = numbers.slice(0,5)
	arraynumber.append(correctanswer)
	arraynumber.shuffle()


func generateorder():
	var a1 = ["left", "center", "right"]
	var a2 = ["left", "center", "right"]
	a1.shuffle()
	a2.shuffle()
	arrayorder = a1 + a2


# =========================
# BOX CREATION
# =========================
func generatebox(type, numberlabel):
	var box = fallboxscene.instantiate()
	box.spawn_id = spawn_id     # 🔑 attach wave ID
	$parentboxes.add_child(box)

	if type == "left":
		box.position = Vector2(gaps + 80, 300)
	elif type == "center":
		box.position = Vector2(2 * gaps + 160 + 80, 300)
	else:
		box.position = Vector2(3 * gaps + 320 + 80, 300)

	box.set_label(numberlabel)
	box.set_speed(randi_range(50, 100))
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
#	if box_spawn_id != spawn_id:
#		return

	if number == correctanswer:
		clicked_right = true
	else:
		clicked_right = false


func deleteparentboxes():
	for c in $parentboxes.get_children():
		c.queue_free()


func update_ui():
	$hplabel.text = "HP: " + str(hp)
	$scorelabel.text = "SCORE: " + str(score)

	if hp <= 0:
		print("gameover")
		hp = 5
