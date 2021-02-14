extends Control

signal opponent_lines_update

const UP = Vector2.UP
const DOWN=  Vector2.DOWN
const LEFT = Vector2.LEFT
const RIGHT = Vector2.RIGHT
const RIGHT_UP = UP + RIGHT
const RIGHT_DOWN = DOWN + RIGHT
const LEFT_UP = LEFT+ UP
const LEFT_DOWN = LEFT +  DOWN
const NumberScene = preload("res://scenes/number.tscn")

var number_matrix = {}
var numbers : Array
var me_playable : bool = false
var my_lines = 0
remote var opponent_lines = 0
remote var partner_playable : bool = false
remote var current_turn : int
remote var end_game 
onready var tween = $"Tween"
onready var fp_label = $"first_player_label"

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Singleton".connect("new_player_joined",self,"_new_player_joined")
	setup_information()
	randomize()
	self.numbers = range(1,26)
	numbers.shuffle()
	var x= 0
	var y = 0
	for i in range(25):
		var vector = Vector2(x,y)
		var new_number_scene = NumberScene.instance() 
		number_matrix[vector] = new_number_scene
		new_number_scene.text = str(numbers[y * 5 + x])
		new_number_scene.position = vector
		new_number_scene.number = numbers[y * 5 + x]
		new_number_scene.connect("selected",self,"_on_number_selected")
		self.add_child(new_number_scene)
		var position = vector * new_number_scene.rect_size.x
		new_number_scene.rect_position = position
		x += 1
		if x % 5 == 0:
			x = 0 
			y += 1


func _process(delta):
	pass#$"score".text = str(self.my_lines)

func ready_to_play():
	return self.me_playable and self.partner_playable

func shuffle():
	self.numbers.shuffle()
	var x= 0
	var y = 0
	for i in range(25):
		var vector = Vector2(x,y)
		number_matrix[vector].text = str(numbers[y * 5 + x])
		number_matrix[vector].number = numbers[y * 5 + x]
		#number_matrix[vector].connect("selected",self,"_on_number_selected")
		x += 1
		if x % 5 == 0:
			x = 0 
			y += 1
	print_debug(self.number_matrix.values()[0].number)

func setup_information():
	$"labels/my_id".text = str($"/root/Singleton".my_id) + "(Bạn)"
	if not get_tree().get_network_unique_id() in $"/root/Singleton".peer_ids:
		$"labels/opponent_id".text = str($"/root/Singleton".my_partner)
		$"buttons/play".disabled = false

func _on_quit():
	$"/root/Singleton".rpc("quit",$"/root/Singleton".my_room)

func _new_player_joined(player_id):
	$"labels/opponent_id".text = str(player_id)
	$"buttons/play".disabled = false
	var random_number = randi()
	var which_turn = $"/root/Singleton".my_id if random_number % 2 else $"/root/Singleton".my_partner
	self.current_turn = which_turn
	rset_id($"/root/Singleton".my_partner,"current_turn",which_turn)
	self.tell_me_if_I_am_on_the_first_turn(self.current_turn)
	rpc_id(player_id,"tell_me_if_I_am_on_the_first_turn",self.current_turn)

remote func tell_me_if_I_am_on_the_first_turn(turn : int):
	if turn == $"/root/Singleton".my_id:
		fp_label.text = "bạn đi trước"
	
remote func your_turn():
	$"your_turn/fader".play("fade_in")

func _on_number_selected(number,position):
	if self.ready_to_play() \
		and self.current_turn == $"/root/Singleton".my_id \
		and not self.end_game:
		fp_label.text = ""
		print_debug(number_matrix[position].number)
		if number_matrix[position].number:#rpc_id($"/root/Singleton".my_partner,"select",number,position)
			rpc_id(
				$"/root/Singleton".my_partner,
				"select",number,position
			)
			self.number_matrix[position].number = 0
			self.number_matrix[position].disabled = true
			var current_lines = my_lines
			my_lines += line_numbers(position)
			tween.interpolate_property($"progresses/progress_bar",
			"value",current_lines,my_lines,.4,Tween.TRANS_QUAD,Tween.EASE_IN)
			tween.start()
			rpc_id($"/root/Singleton".my_partner,"opponent_lines_update",my_lines)
			self.current_turn = $"/root/Singleton".my_partner
			rset_id($"/root/Singleton".my_partner,"current_turn",self.current_turn)
			rpc_id(self.current_turn,"your_turn")

remote func opponent_lines_update(lines : int):
	self.opponent_lines = lines
	if self.my_lines == 5 and self.opponent_lines == 5:
		$"your_turn/Label".text = "Hòa"
	elif self.my_lines == 5:
		$"your_turn/Label".text = "Bạn đã thắng"
	elif self.opponent_lines == 5:
		$"your_turn/Label".text = "Bạn đã thua"
	if self.my_lines == 5 or self.opponent_lines == 5:
		$"your_turn/fader".play("fade_in")
		self.end_game = true
	tween.interpolate_property($"progresses/progress_bar2",
		"value",self.opponent_lines,lines,.4,Tween.TRANS_QUAD,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	
func line_numbers(position : Vector2):
	var horizonal = 1 if check_line(position, RIGHT,LEFT) == 5 else 0
	var vertical = 1 if check_line(position, UP,DOWN) == 5 else 0
	var diagonal1 = 1 if check_line(position,LEFT_UP,RIGHT_DOWN) == 5 else 0
	var diagonal2 = 1 if check_line(position,LEFT_DOWN,RIGHT_UP) == 5 else 0
	return horizonal + vertical + diagonal1 + diagonal2


remote func select(number : int ,position : Vector2):
	var p = null
	for point in self.number_matrix:
		if number_matrix[point].number == number:
			p = point
			break
	if p is Vector2:
		self.number_matrix[p].disabled = true
		self.number_matrix[p].number = 0
		var current_lines = self.my_lines
		self.my_lines += line_numbers(p)
		tween.interpolate_property($"progresses/progress_bar",
		"value",current_lines,my_lines,.4,Tween.TRANS_QUAD,Tween.EASE_IN)
		tween.start()
		rpc_id($"/root/Singleton".my_partner,"opponent_lines_update",my_lines)
		

func check_line(position : Vector2, direction : Vector2, opposite_direction: Vector2): 
	var point = position
	var n = 1
	#check right-side points
	while number_matrix.get(point + direction):
		if not number_matrix[point + direction].number:
			n += 1
		else:
			break
		point += direction
	point = position
	while number_matrix.get(point + opposite_direction):
		if not number_matrix[point + opposite_direction].number:
			n += 1
		else:
			break
		point += opposite_direction
	return n


func play():
	$"buttons/shuffle".disabled= true
	self.me_playable = true
	rset_id($"/root/Singleton".my_partner,"partner_playable", true)
	
