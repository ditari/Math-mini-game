extends Node2D

@onready var flash_rect := $CanvasLayer/Control/ColorRect
var flash_tween: Tween

@onready var questionlabel =$CanvasLayer/Control/PanelContainer/questionlabel
@onready var hplabel = $hplabel
@onready var scorelabel = $CanvasLayer/Control/PanelContainer2/scorelabel

var fallboxscene: PackedScene = load("res://scenes/box.tscn")

var hp := 5
var score := 0

var arraynumber := []
var arrayorder := []

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


func handle_result():
	if clicked_right == null and not correct_out_screen:
		return

	if clicked_right == true:
		#glow_screen(Color(0.8, 1, 0.8))
		glow_screen_soft()
		score += 100
	else:
		shake()
		#flash_screen(Color.RED)
		hp -= 1

	start_round()


# =========================
# GENERATION (ONE WAVE)
# =========================
func handle_generation():
	if is_generating:
		return

	if $parentboxes.get_child_count() == 0:
		is_generating = true
		generate_wave(spawn_id)


func generate_wave(id):
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
func get_wrong_numbers(erasednumber):
	var numbers = [0,1,2,3,4,5,6,7,8,9,10]
	numbers.erase(erasednumber)
	numbers.shuffle()
	return numbers


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
		box.position = Vector2(gaps + 80, 425)
	elif type == "center":
		box.position = Vector2(2 * gaps + 160 + 80, 425)
	else:
		box.position = Vector2(3 * gaps + 320 + 80, 425)

	box.set_label(numberlabel)
	box.set_speed(randi_range(50, 100))
	
	var index = str(numberlabel)[-1]
	#box.setup(COLORS[index])
	box.get_node("AnimatedSprite2D").play(index)
	box.scale = Vector2(0.7, 0.7)
	
	box.connect("out_of_screen", box_out_of_screen)
	box.connect("button_pressed", box_pressed)


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

#func flash_screen(color := Color(1, 0.3, 0.3), duration := 0.08):
#	_stop_flash()
#
#	flash_rect.color = color
#	flash_rect.modulate.a = 0.75
#
#	flash_tween = create_tween()
#	flash_tween.tween_property(
#		flash_rect,
#		"modulate:a",
#		0.0,
#		duration
#	).set_trans(Tween.TRANS_LINEAR)


#func glow_screen(color := Color(0.85, 1, 0.85), duration := 0.25, intensity := 0.15):
#	_stop_flash()
#
#	flash_rect.color = color
#	flash_rect.modulate.a = intensity
#
#	flash_tween = create_tween()
#	flash_tween.tween_interval(0.05) # small hold
#	flash_tween.tween_property(
#		flash_rect,
#		"modulate:a",
#		0.0,
#		duration
#	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

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
