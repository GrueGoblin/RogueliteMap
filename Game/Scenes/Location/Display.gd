
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
	# set scene values
	pass



func _on_SelectButton_pressed():
	location.emit_signal("check_connections")
	pass # Replace with function body.
