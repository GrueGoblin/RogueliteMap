extends "res://Game/Models/Meta/Map.gd"

class_name Map

export (Array) var locations
export (Dictionary) var locations_per_level

export (Array) var connections
#export (Dictionary) var connections_per_level

func _init():
	pass
#	for i in levels:
#		locations_per_level[i] = []
		#connections_per_level[i] = []

func generate_locations():
	# generate locations on grid
	# rules - minimum 2 locations per level, maximum is determined by the map
	for level in levels:
		locations_per_level[level] = []
		var positions = range(max_locations)
		positions.shuffle()
		var count = locations_count()
		for i in count:
			var location = Location.new()
			location.position = Vector2(positions.pop_front(), level)
			#location.position = Vector2(positions.pop_front() * 150 + 100, 900 - level * 90)
			location.location_type = Content.get_random("LocationType")
			
			if i == 0:
				location.starting = true
			
			locations.append(location)
			locations_per_level[level].append(location)
	
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
	return floor(rand_range(2, max_locations+0.99))
