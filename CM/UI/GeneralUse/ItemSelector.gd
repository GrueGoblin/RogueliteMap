extends OptionButton

export var item_type : String
export var include_null : bool

var item_list : Array

signal select_item
# Called when the node enters the scene tree for the first time.
func _ready():
	if include_null:
		add_item("None")
		add_separator()
	item_list = Content.get_all(item_type)
	for item in item_list:
		add_item(item.name)
		


func _on_OptionButton_item_selected(index):
	print(index)
	var item_index = index
	if include_null:
		item_index -= 2
	print(item_list[item_index])
	emit_signal("select_item",item_list[item_index])
