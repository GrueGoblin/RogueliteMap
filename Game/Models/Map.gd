extends "res://Game/Models/Meta/Map.gd"

class_name Map

export (Array) var locations
export (Dictionary) var locations_per_level

export (Array) var connections
#export (Dictionary) var connections_per_level

func _init():
	for i in levels:
		locations_per_level[i] = []
		#connections_per_level[i] = []

func generate_locations():
	# generate locations on grid
	# rules - minimum 2 locations per level, maximum is determined by the map
	for level in levels:
		var positions = range(max_locations)
		positions.shuffle()
		var count = locations_count()
		for i in count:
			var location = Location.new()
			location.position = Vector2(positions.pop_front() * 50 + 50, 900 - level * 50)
	
	# generate location connections
	# rules:
	# 1. every location needs to be connected to some previous one (excluding the starting ones)
	# 2. every location needs to lead somewhere
	# 2. Connections go only one level up
	# 3. connections can't cross
	# 4. there is limited amount of connections per level
	pass

# locations per level, minimum 2 locations per level, maximum is determined by the map
func locations_count():
	return floor(rand_range(2, max_locations-2+0.99))
