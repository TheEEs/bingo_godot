extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$"partner_id".text = str($"/root/Singleton".my_room) if $"/root/Singleton".my_room else ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_create_pressed():
	$"/root/Singleton".rpc("create_room")


func _on_join_pressed():
	var partner_id = int($"partner_id".text)
	if partner_id > 1 and partner_id in $"/root/Singleton".peer_ids:
		if $"/root/Singleton".peer_ids[partner_id]:
			$"error_label".text = "phòng đã đủ người"
			return
		$"/root/Singleton".rpc("join_room",int($"partner_id".text))
	else:
		$"error_label".text = "id phòng không tồn tại"


func _on_partner_id_focus_entered():
	if OS.get_name() == "HTML5":
		var room_id = JavaScript.eval("""
			window.prompt('ID phòng bạn muốn vào')
		""")
		$"partner_id".text = room_id if room_id else ""
