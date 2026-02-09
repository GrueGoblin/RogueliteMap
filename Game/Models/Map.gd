extends "res://Game/Models/Meta/Map.gd"

class_name Map

export (Array) var locations
export (Dictionary) var locations_per_level

export (Array) var connections
export (Dictionary) var connections_per_level

func generate_locations():
	# generate locations on grid
	# rules - minimum 2 locations per level, maximum is determined by the map
	
	# generate location connections
	# rules:
	# 1. every location needs to be connected to some previous one (excluding the starting ones)
	# 2. every location needs to lead somewhere
	# 2. Connections go only one level up
	# 3. connections can't cross
	# 4. there is limited amount of connections per level
	pass
