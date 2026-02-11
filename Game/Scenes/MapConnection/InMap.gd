
extends Node2D

var map_connection : MapConnection setget set_map_connection

func _ready():
	#self.map_connection = MapConnection.new()
	position = map_connection.from.actual_position
	$Line2D.points[1] = map_connection.relative_end_position()
	print("connection ready")
	print(position)
	pass

func set_map_connection(value : MapConnection):
	if map_connection:
		map_connection.disconnect("changed",self,"actualize")
	map_connection = value
	map_connection.connect("changed",self,"actualize")	
	actualize()
	
func actualize():
	# set scene values
	pass

