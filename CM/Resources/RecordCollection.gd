extends Reference

var items := Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func first():
	if items.size() > 0:
		return items[0]
	else:
		return null
		
func last():
	if items.size() > 0:
		return items[-1]
	else:
		return null
		
func all():
	return items
