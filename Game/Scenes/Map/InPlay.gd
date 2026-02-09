
extends Node2D

var map : Map setget set_map

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

