extends Node2D

var fallboxscene: PackedScene = load("res://scenes/fallbox.tscn")
var fallbox
var hp = 5
var score = 0

var arraynumber
var arrayorder

var correctanswer = 0

var correct_out_screen = false
var clicked_right = null

var screen_size
var gaps


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	gaps = ((screen_size.x - (160*3))/4) #1kotak width nya 160		
	
	randomize()
	
	generatequestion()
	generateorder()
	await get_tree().create_timer(1).timeout
	generateboxes()
	$hplabel.text = str(hp)
	$scorelabel.text = str(score)

func _process(delta):
	if correct_out_screen == false:
		if clicked_right == true:
			score = score + 100
			deleteparentboxes()
			generatequestion()
			generateorder()
			await get_tree().create_timer(0.5).timeout
			generateboxes()
		elif clicked_right == false:
			hp = hp-1 
			deleteparentboxes()
			generatequestion()
			generateorder()
			await get_tree().create_timer(0.5).timeout
			generateboxes()
	else:
		hp = hp-1 
		deleteparentboxes()
		generatequestion()
		generateorder()
		await get_tree().create_timer(0,5).timeout
		generateboxes()
		
	$hplabel.text = str(hp)
	$scorelabel.text = str(score)		
		
	if hp <= 0:
		print("gameover")
		hp=5

func get_wrong_numbers(erasednumber):
	var numbers = [0,1,2,3,4,5,6,7,8,9,10]
	# Remove forbidden number
	numbers.erase(erasednumber)
	# Randomize the order
	numbers.shuffle()
	return numbers


func generatequestion():
	clicked_right = null
	correct_out_screen = false
	
	correctanswer = randi_range(0, 10)
	var a = randi_range(0, correctanswer)
	var b = correctanswer - a
	
	$questionlabel.text = str(a) + " + " + str(b) + " = ?"
	
	var numbers = get_wrong_numbers(correctanswer)
	var wronganswer1 = numbers[0]
	var wronganswer2 = numbers[1]	
	
	arraynumber = [correctanswer, wronganswer1,wronganswer2]
	arraynumber.shuffle()
	
func generateorder():
	arrayorder = ["left","center","right"]
	arrayorder.shuffle()

func generateboxes():
	generatebox(arrayorder[0],arraynumber[0])
	#print("a")
	await get_tree().create_timer(1).timeout
	generatebox(arrayorder[1], arraynumber[1])
	#print("b")
	await get_tree().create_timer(1).timeout
	generatebox(arrayorder[2], arraynumber[2])
	#print("c")

func generatebox(type, numberlabel):
	var screen_size = get_viewport_rect().size
	var gaps = ((screen_size.x - (160*3))/4) #1kotak width nya 160	
	
	fallbox = fallboxscene.instantiate()
		
	$parentboxes.add_child(fallbox)
	
	if type == "left" :
		fallbox.position = Vector2(gaps+80,300)
	elif type == "center" :
		fallbox.position = Vector2(2*gaps+160+80,300)
	else :
		fallbox.position = Vector2(3*gaps+320+80,300)
		
	
	var s = randi_range(50, 150)
	
	fallbox.set_label(numberlabel)
	fallbox.set_speed(s)
	fallbox.connect("out_of_screen", box_out_of_screen)
	fallbox.connect("button_pressed", box_pressed)
	
func deleteparentboxes():
	for child in $parentboxes.get_children():
		child.queue_free()

func box_out_of_screen(number):
	if number == correctanswer:
		correct_out_screen = true
	
func box_pressed(number):
	if number == correctanswer:
		clicked_right = true
	else:
		clicked_right = false
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
