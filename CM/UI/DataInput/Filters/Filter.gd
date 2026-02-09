
extends HBoxContainer

var content_type : ContentType setget set_content_type
var fields := Array()
var selected_field : ContentTypeField
var value

signal apply_filter(filter) # Sends the filters to the parent handler 

signal clear_filter

func _ready():
	pass

func set_content_type(value : ContentType):
	if content_type:
		content_type.disconnect("changed",self,"actualize")
	content_type = value	
	if content_type:
		content_type.connect("changed",self,"actualize")
		fields = content_type.fields_filtered("Singleton Reference")
		populate_field_selector()
	actualize()
	
func actualize():
	# set scene values
	pass

func populate_field_selector():
	$FieldSelector.clear()
	$FieldSelector.add_item("null")
	$FieldSelector.add_separator()
	for field in fields:
		field = field as ContentTypeField
		$FieldSelector.add_item(field.var_name)
		pass
	pass

func populate_item_selector(type : String):
	print(type)
	$ItemSelector.clear()
	$ItemSelector.add_item("null")
	if type != "null":
		$ItemSelector.add_separator()
		for item in Content.get_all(type):
			$ItemSelector.add_item(item.name)

func _on_FieldSelector_item_selected(index):
	#print($FieldSelector.get_item_text(index))
	var field_name = $FieldSelector.get_item_text(index)
	if field_name == "null":
		selected_field = null
		$ItemSelector.select(0)
		$ItemSelector.disabled = true
		emit_signal("clear_filter")
	else:
		$ItemSelector.disabled = false
		$ItemSelector.select(0)
		for f in fields:
			f = f as ContentTypeField
			if f.var_name == field_name:
				selected_field = f
		populate_item_selector(selected_field.var_subtype)


func _on_ItemSelector_item_selected(index):
	var item_name = $ItemSelector.get_item_text(index)
	if item_name == "null":
		value = null
	else:
		value = Content.find(selected_field.var_subtype,item_name)
	$ApplyButton.disabled = false


func _on_ApplyButton_pressed():
	#print({selected_field.var_name : value})
	emit_signal("apply_filter",{selected_field.var_name : value})
	$ApplyButton.disabled = true
	pass # Replace with function body.
