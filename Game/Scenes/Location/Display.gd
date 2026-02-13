
extends Node2D

var location : Location setget set_location

func _ready():
	#self.location = Location.new()
	position = location.actual_position
	pass

func set_location(value : Location):
	if location:
		location.disconnect("changed",self,"actualize")
	location = value
	location.connect("changed",self,"actualize")	
	$LocationType.location_type = location.location_type
	actualize()
	
func actualize():
	$VisitedIndicator.visible = location.visited
	if location.selectible:
		$LocationType.highlight()
		$SelectButton.show()
	else:
		$LocationType.highlight_stop()
		$SelectButton.hide()



func _on_SelectButton_pressed():
	location.current = true
	LocationsController.enter_location(location)
	#location.emit_signal("check_connections")
	pass # Replace with function body.
