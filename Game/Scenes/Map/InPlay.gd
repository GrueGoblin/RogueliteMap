
extends Node2D

var map : Map setget set_map

const mouse_sensitivity = 50

const edge_up = 300
const edge_down = 725

func _ready():
	var m = Map.new()
	m.levels = 10
	m.generate_locations()
	m.generate_location_connections()
	self.map = m
	print(map.locations_per_level)
	pass

func set_map(value : Map):
	if map:
		map.disconnect("changed",self,"actualize")
	map = value
	map.connect("changed",self,"actualize")	
	for location in map.locations:
		$Locations.add_child(location.instance_as("Display"))
	for connection in map.connections:
		$Connections.add_child(connection.instance_as("InMap"))
	actualize()
	
func actualize():
	# set scene values
	pass

func _physics_process(delta):
	if Input.is_action_just_released("wheel_down"):
		#$Camera2D.position.y+=mouse_sensitivity
		$Camera2D.position.y = min($Camera2D.position.y + mouse_sensitivity, edge_down)
		print("down")
		print($Camera2D.position.y)
	if Input.is_action_just_released("wheel_up"):
		$Camera2D.position.y = max($Camera2D.position.y - mouse_sensitivity, edge_up)
		print("up")
		print($Camera2D.position.y)
