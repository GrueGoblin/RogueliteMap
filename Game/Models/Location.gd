extends "res://Game/Models/Meta/Location.gd"

class_name Location

signal current

signal check_connections

const spread = 18

func set_current(value):
	current = value
	if current:
		self.visited = true
		emit_signal("current")
	emit_changed()

func calculate_position():
	actual_position = Vector2(position.x * 150 + 100, 1200 - position.y * 124) + Vector2(rand_range(-spread,spread), rand_range(-spread,spread))

func set_position(value):
	position = value
	calculate_position()
	emit_changed()

func connect_to(location : Location):
	var connection = load("res://Game/Models/MapConnection.gd").new()#MapConnection.new()
	connection.from = self
	connection.to = location
	return connection

func _to_string():
	return "[Location:{name}]".format({"name" : get("name")}) + str(position)
