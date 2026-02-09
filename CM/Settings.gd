extends Resource

class_name CMSettings

export var autogenerate_todos := {} setget , get_autogenerate_todos

func get_autogenerate_todos():
	if autogenerate_todos.empty():
		autogenerate_todos["on_save"] = true
		autogenerate_todos["on_exit"] = true
	return autogenerate_todos
	
