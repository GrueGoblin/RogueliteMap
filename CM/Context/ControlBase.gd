extends Control

# A parent of a context branch for certain item

export var item_type : String
var variable_node_map := Dictionary()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_node_for(var_name: String):
	# returns a node, if exists, that correspons conventional
	# naming "{type_name}-{var_name}" inside this context's branch
	pass
