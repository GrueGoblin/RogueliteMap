extends "res://Game/Models/Meta/Location.gd"

class_name Location

signal current

func set_current(value):
	current = value
	if current:
		self.visited = true
		emit_signal("current")
	emit_changed()
