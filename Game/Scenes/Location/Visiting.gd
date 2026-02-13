
extends PanelContainer

var location : Location setget set_location

func _ready():
	#self.location = Location.new()
	pass

func set_location(value : Location):
	if location:
		location.disconnect("changed",self,"actualize")
	location = value
	location.connect("changed",self,"actualize")	
	actualize()
	
func actualize():
	$VBoxContainer/Label.text = location.location_type.humanized_name()
	$VBoxContainer/TextureRect.texture = location.location_type.icon
	# set scene values
	pass



func _on_Button_pressed():
	pass # Replace with function body.
