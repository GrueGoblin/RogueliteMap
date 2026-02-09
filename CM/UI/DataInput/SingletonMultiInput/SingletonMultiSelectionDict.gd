extends HBoxContainer

var definition_item : Resource setget set_def_item
var resource_item : Dictionary setget set_res_item
var item_display = load("res://CM/UI/DataInput/SingletonDictionary/SingletonDictItem.tscn")
signal state_changed(collection)

func set_res_item(item : Dictionary):
	resource_item = item
	for child in $Items.get_children():
		var ref = child.get("item")
		#rework it to match items
		if ref && item.values().find(ref) !=-1:
			child.check()

func set_def_item(item):
	definition_item = item
	var type_name = definition_item.var_subtype
	var items = Content.get_all(type_name)
	for it in items:
		var new_item = item_display.instance()
		new_item.item = it
		new_item.connect("state_changed",self,"_on_SingletonItem_state_changed")
		$Items.add_child(new_item)

func _on_SingletonItem_state_changed(state : bool, it : Resource):	
	if state:
		if !resource_item[it]:
			resource_item[it] #=default value
			#resource_item.append(it)
			emit_signal("state_changed",resource_item)
	else:
		resource_item.erase(it)
		emit_signal("state_changed",resource_item)


func _on_Button_pressed():
	$Items.show()
	pass # Replace with function body.
