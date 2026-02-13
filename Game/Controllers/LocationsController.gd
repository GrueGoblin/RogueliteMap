extends Node2D

func enter_location(location : Location):
	$CanvasLayer.add_child(location.instance_as("Visiting"))
	pass
