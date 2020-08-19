extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func disable(value : bool):
	self.disabled = value
	$"Label".set("custom_colors/font_color",Color("#BAD9C8") if self.disabled else Color.white)
