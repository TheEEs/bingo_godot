extends Node

signal new_player_joined

var listening_port = OS.get_environment("PORT").to_int() if  OS.get_environment("PORT")  else  7498

var my_room

var PlayScene = load("res://scenes/numbers.tscn")
const WelcomeScene = preload("res://scenes/welcome.tscn")

var timer = Timer.new()

var peer_ids = {}

var my_id 

var my_partner

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected",self,"_network_peer_connected")
	get_tree().connect("network_peer_disconnected",self,"_network_peer_disconnected")
	if OS.get_name() == "HTML5":
		_connect_to_server()
	else:
		_create_server()

func _create_server():
	print(listening_port)
	var peer = WebSocketServer.new()
	peer.listen(listening_port,PoolStringArray(),true)
	get_tree().network_peer = peer

func _connect_to_server():
	var peer = WebSocketClient.new()
	peer.connect_to_url("ws://trandatbingoserver.herokuapp.com",PoolStringArray(),true)
	get_tree().network_peer = peer
	add_child(timer)
	timer.autostart = true 
	timer.connect("timeout",self,"time_out")

func _network_peer_connected(id):
	pass

func time_out():
	rpc_id(1,"do_nothing")
	
	
remote func do_nothing():
	pass

func _network_peer_disconnected(id):
	peer_ids.erase(id)
	if id == my_partner:
		peer_ids.erase(my_room)
		#my_room = null
		my_partner = null
		get_tree().change_scene_to(WelcomeScene)
	

remotesync func create_room():
	var sender_id = get_tree().get_rpc_sender_id()
	self.peer_ids[sender_id] = null
	if get_tree().get_rpc_sender_id() and \
	get_tree().get_rpc_sender_id() == get_tree().get_network_unique_id():
		get_tree().change_scene_to(PlayScene)
		my_room = get_tree().get_network_unique_id()
		my_id = my_room
		#get_tree().paused = true


remotesync func join_room(partner_id):
	if not get_tree().is_network_server():
		self.peer_ids[partner_id] = get_tree().get_rpc_sender_id()
		#on target machine
		if partner_id == get_tree().get_network_unique_id():
			my_partner = self.peer_ids[partner_id]
			#get_tree().paused = false
			emit_signal("new_player_joined",self.peer_ids[partner_id])
		#on my machine
		elif get_tree().get_rpc_sender_id() == get_tree().get_network_unique_id():
			my_partner = partner_id
			my_room = my_partner
			my_id = get_tree().get_network_unique_id()
			get_tree().change_scene_to(PlayScene)
		


remotesync func quit(room_id):
	var player1_id = room_id 
	var player2_id = peer_ids[room_id]
	#var rpc_sender_id = get_tree().get_rpc_sender_id()
	var my_id = $"/root/Singleton".my_id
	if my_id == player1_id or my_id == player2_id:
		#self.my_room = null 
		self.my_partner = null
		#if rpc_sender_id == player1_id or rpc_sender_id == player2_id:
		get_tree().change_scene_to(WelcomeScene)
	if my_id == player1_id:
		self.my_room = null
	peer_ids.erase(player1_id)
	
		
