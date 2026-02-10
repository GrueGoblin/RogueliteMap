extends "res://Game/Models/Meta/Location.gd"

class_name Location

signal current

const spread = 18

func set_current(value):
	current = value
	if current:
		self.visited = true
		emit_signal("current")
	emit_changed()

func calculate_position():
	actual_position = Vector2(position.x * 150 + 100, 900 - position.y * 90) + Vector2(rand_range(-spread,spread), rand_range(-spread,spread))

func set_position(value):
	position = value
	calculate_position()
	emit_changed()
