
extends Node2D

var map : Map setget set_map

const mouse_sensitivity = 50

const edge_up = 300
const edge_down = 725

func _ready():
	#self.map = Map.new()
	pass

func set_map(value : Map):
	if map:
		map.disconnect("changed",self,"actualize")
	map = value
	map.connect("changed",self,"actualize")	
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
