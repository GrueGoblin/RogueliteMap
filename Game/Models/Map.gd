extends "res://Game/Models/Meta/Map.gd"

class_name Map

export (Array) var locations
export (Dictionary) var locations_per_level
export (Dictionary) var locations_by_position

export (Array) var connections
#export (Dictionary) var connections_per_level

func _init():
	pass
#	for i in levels:
#		locations_per_level[i] = []
		#connections_per_level[i] = []

func generate_locations():
	# generate locations on grid
	for level in levels:
		locations_per_level[level] = []
		var positions = range(max_locations)
		positions.shuffle()
		var count = locations_count()
		for i in count:
			var location = Location.new()
			location.position = Vector2(positions.pop_front(), level)
			location.location_type = Content.get_random("LocationType")
			location.level = level
			location.connect("check_connections", self, "check_connections",[location])
			if i == 0:
				location.starting = true
			
			locations.append(location)
			locations_per_level[level].append(location)
			locations_by_position[location.position] = location
	
	
	pass

func check_connections(location : Location):
	for connection in connections:
		if connection.to == location:
			print(connection)
	pass

func generate_location_connections():
	# generate location connections
	var locations_wo_followup = locations.duplicate()
	var locations_wo_source = locations.duplicate()
	
	#var connection = MapConnection.new()
#	connection.from = locations[0]
#	connection.to = locations[6]
#	connections.append(connection)
	# rules:
	# 1. every location needs to lead somewhere/ except final one?
	for location in locations:
		location = location as Location
		var level = location.level
		if level < levels && level > 0:
			# connect to random
			var next_level = locations_per_level[level -1]
			next_level.shuffle()
#			var connection = MapConnection.new()
			var connection = location.connect_to(next_level[0])
			connections.append(connection)
			pass
	# 2. every location needs to be connected to some previous one (excluding the starting ones)
	
	
	# 3. Connections go only one level up
	# 4. connections can't cross
	# 5. there is limited amount of connections per level
	pass

# locations per level, minimum 2 locations per level, maximum is determined by the map
func locations_count():
	return floor(rand_range(2, max_locations+0.99))
