extends "res://Game/Models/Meta/MapConnection.gd"

class_name MapConnection

func relative_end_position():
	return to.actual_position - from.actual_position

func _to_string():
	return "[MapConnection:{name}]".format({"name" : get("name")}) + str(from) + ":" + str(to)
