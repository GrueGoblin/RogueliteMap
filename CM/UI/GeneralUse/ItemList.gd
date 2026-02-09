extends Control

export var vertical := true setget set_vertical
export var item_number_shown := 4
export var item_type : String
export var item_scene : PackedScene
export var item_list := Array()

var first_item_index := 0 setget set_first_item_index

onready var list_container := $VerticalList

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in Content.get_all(item_type):
		var new_item_scene = item_scene.instance()
		new_item_scene.set(Content.pascal_to_snake(item_type),item)
		list_container.get_node("List").add_child(new_item_scene)
	pass # Replace with function body.

func set_vertical(value):
	vertical = value
	if vertical:
		list_container = $VerticalList
		$VerticalList.show()
		$HorizontalList.hide()
	else:
		list_container =$HorizontalList
		$HorizontalList.show()
		$VerticalList.hide()

func set_first_item_index(value):
	first_item_index = value

func _on_PreviousButton_pressed():
	pass # Replace with function body.


func _on_NextButton_pressed():
	pass # Replace with function body.
