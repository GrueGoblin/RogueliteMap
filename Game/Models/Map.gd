extends "res://Game/Models/Meta/Map.gd"

class_name Map

export (Array) var locations
export (Dictionary) var locations_per_level
export (Dictionary) var locations_by_position

export (Array) var connections
#export (Dictionary) var connections_per_level

export (Resource) var current_location

signal location_selected

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
			location.connect("current",self,"set_current_location", [location])
			if i == 0:
				location.starting = true
			
			add_location(location)
	make_starting_locations_selectable()

func check_connections(location : Location):
	for connection in connections:
		if connection.to == location:
			print(connection)

func set_current_location(location : Location):
	current_location = location
	for loc in locations:
		loc.selectible = false
		if loc != location:
			loc.current = false
	emit_signal("location_selected", location)

func current_level():
	return current_location.level

func add_location(location : Location):
	locations.append(location)
	locations_per_level[location.level].append(location)
	locations_by_position[location.position] = location
	pass

func outline_location(position : Vector2, inverse = false):
	if inverse:
		position.x = max_locations - (position.x + 1)
	#var position = Vector2(x_pos, y_pos)
	if locations_by_position.has(position):
		return locations_by_position[position]
	return null

func closest_location_to(position : Vector2, search_direction = 1):
	for dist in max_locations:
		for dir in [-search_direction, search_direction]:
			var pos = position + Vector2(dir * dist, 0)
			if locations_by_position.has(pos):
				return locations_by_position[pos]
	return null
		

func generate_location_connections():
	# generate location connections
	var locations_wo_followup = locations.duplicate() as Array
	var locations_wo_source = locations.duplicate() as Array
	# rules:
	# 1. connect outline paths
	for level in levels -1:
		for inverse in [false,true]:
			var source_location : Location
			var target_location : Location
			for i in max_locations:
				var source_position = Vector2(i, level)
				var target_position = Vector2(i, level+1)
				if !source_location:
					source_location = outline_location(source_position, inverse)
				if !target_location:
					target_location = outline_location(target_position, inverse)
			var connection = source_location.connect_to(target_location)
			connections.append(connection)
			locations_wo_followup.erase(source_location)
			locations_wo_source.erase(target_location)

	# 2. connect direct paths (same x position)/connect orphaned nodes
	for location in locations_wo_followup:
		location = location as Location
		if location.position.y < levels - 1:
			var target_location = closest_location_to(location.position + Vector2(0,1)) as Location
			print("target_location: " + str(target_location))
			var connection = location.connect_to(target_location) as MapConnection
			connections.append(connection)
			locations_wo_source.erase(target_location)
			
	for location in locations_wo_source:
		location = location as Location
		if location.position.y > 0:
			var source_location = closest_location_to(location.position + Vector2(0,-1)) as Location
			var connection = source_location.connect_to(location) as MapConnection
			connections.append(connection)
	
	# 3. add redundancies?
	
	
# locations per level, minimum 2 locations per level, maximum is determined by the map
func locations_count():
	return floor(rand_range(2, max_locations+0.99))

func make_starting_locations_selectable():
	for location in locations_per_level[0]:
		location.selectible = true
