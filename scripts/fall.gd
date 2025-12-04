extends Node2D

var fallboxscene: PackedScene = load("res://scenes/fallbox.tscn")
var fallbox
var hp = 5
var score = 0

var leftnumber
var centernumber
var rightnumber

var correctanswer = 0

var correct_out_screen = false
var clicked_right

var screen_size
var gaps


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	gaps = ((screen_size.x - (160*3))/4) #1kotak width nya 160		
	
	randomize()
	generatequestion()
	$hplabel.text = str(hp)
	$scorelabel.text = str(score)

func _process(delta):
	if correct_out_screen == false:
		if clicked_right == true:
			score = score + 100
			deletearrayboxes()
			generatequestion()
		elif clicked_right == false:
			hp = hp-1 
			deletearrayboxes()
			generatequestion()
	else:
		hp = hp-1 
		deletearrayboxes()
		generatequestion()
		
	$hplabel.text = str(hp)
	$scorelabel.text = str(score)		
		
	if hp <= 0:
		print("gameover")

func get_unique_numbers(erasednumber):
	var numbers = [0,1,2,3,4,5,6,7,8,9,10]
	# Remove forbidden number
	numbers.erase(erasednumber)
	# Randomize the order
	numbers.shuffle()
	return numbers


func generatequestion():
	clicked_right = null
	correct_out_screen = false
	
	var a = randi_range(0, 5)
	var b = randi_range(0, 5)
	correctanswer = a + b
	$questionlabel.text = str(a) + " + " + str(b) + " = ?"
	
	var numbers = get_unique_numbers(correctanswer)
	var wronganswer1 = numbers[1]
	var wronganswer2 = numbers[2]	
	
	var r = randi_range(1, 3)
	
	if r == 1 :
		leftnumber = correctanswer
		centernumber = wronganswer1
		rightnumber = wronganswer2
	elif r == 2 :
		leftnumber = wronganswer1
		centernumber = correctanswer
		rightnumber = wronganswer2
	else : 
		leftnumber = wronganswer1
		centernumber = wronganswer2
		rightnumber = correctanswer
	generateorder()
	
func generateorder():
	var r = randi_range(1, 6)
	if r == 1 :
		generateboxes ("left","center", "right")
	elif r == 2:
		generateboxes ("left","right", "center")
	elif r == 3:
		generateboxes ("center","left", "right")
	elif r == 4:
		generateboxes ("center","right", "left")
	elif r == 5:
		generateboxes ("right","left", "center")
	else :
		generateboxes ("right","center", "left")
		

func generateboxes(a,b,c):
	generatebox(a)
	await get_tree().create_timer(1).timeout
	generatebox(b)
	await get_tree().create_timer(1).timeout
	generatebox(c)

func generatebox(type):
	var screen_size = get_viewport_rect().size
	var gaps = ((screen_size.x - (160*3))/4) #1kotak width nya 160	
	
	fallbox = fallboxscene.instantiate()
		
	$arrayboxes.add_child(fallbox)
	
	if type == "left" :
		fallbox.position = Vector2(gaps+80,300)
		fallbox.set_label(leftnumber)
	elif type == "center" :
		fallbox.position = Vector2(2*gaps+160+80,300)
		fallbox.set_label(centernumber)
	else :
		fallbox.position = Vector2(3*gaps+320+80,300)
		fallbox.set_label(rightnumber)
	
	var s = randi_range(50, 150)
	
	fallbox.set_speed(s)
	fallbox.connect("out_of_screen", box_out_of_screen)
	fallbox.connect("button_pressed", box_pressed)
	
func deletearrayboxes():
	for child in $arrayboxes.get_children():
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
