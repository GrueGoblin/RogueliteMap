extends OptionButton

class_name ValueSelector

func find_item_index(var_name):
	for i in get_item_count():
		if get_item_text(i) == var_name:
			return i
	return -1
	
func select_by_name(selected_name : String):
	var index = find_item_index(selected_name)
	select(index)
	
func select_by_object_name(object : Object):
	var selected_name = "null"
	if object:
		selected_name = object.get(name)
	select_by_name(selected_name)
