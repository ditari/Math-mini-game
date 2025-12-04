extends Node2D

var fallboxscene: PackedScene = load("res://scenes/fallbox.tscn")
var fallbox
var hp = 5
var score = 0

var arraynumber
var arrayorder

var nextshift = 0

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
	nextshift = 1

	$hplabel.text = str(hp)
	$scorelabel.text = str(score)

func _process(delta):
	if correct_out_screen == false:
		if clicked_right == true:
			score = score + 100
			deleteparentboxes()
			generatequestion()
			generateorder()
			
			nextshift = 1
			
		elif clicked_right == false:
			hp = hp-1 
			deleteparentboxes()
			generatequestion()
			generateorder()
			
			nextshift = 1
			
	else:
		hp = hp-1 
		deleteparentboxes()
		generatequestion()
		generateorder()
		
		nextshift = 1
		
	
	if nextshift == 1 and $parentboxes.get_child_count()==0:
		await get_tree().create_timer(0,5).timeout
		generateboxes1()
		nextshift = 2
		
	elif nextshift == 2 and $parentboxes.get_child_count()==0:
		await get_tree().create_timer(0,5).timeout
		generateboxes2()
		
		
		
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
	
	arraynumber = [correctanswer, numbers[0], numbers[1], numbers[2],numbers[3], numbers[4]]
	arraynumber.shuffle()
	
func generateorder():
	var array1 = ["left","center","right"]
	array1.shuffle()
	var array2 = ["left","center","right"]
	array2.shuffle()	
	
	arrayorder = array1 + array2

func generateboxes1():
	generatebox(arrayorder[0],arraynumber[0])
	#print("a")
	await get_tree().create_timer(randi_range(1,3)).timeout
	generatebox(arrayorder[1], arraynumber[1])
	#print("b")
	await get_tree().create_timer(randi_range(1,3)).timeout
	generatebox(arrayorder[2], arraynumber[2])
	#print("c")
	
func generateboxes2():
	generatebox(arrayorder[3],arraynumber[3])
	#print("a")
	await get_tree().create_timer(randi_range(1,3)).timeout
	generatebox(arrayorder[4], arraynumber[4])
	#print("b")
	await get_tree().create_timer(randi_range(1,3)).timeout
	generatebox(arrayorder[5], arraynumber[5])
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
		
	var s = randi_range(50, 100)
	
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
