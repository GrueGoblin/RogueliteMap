extends HBoxContainer

var type_definition : ContentType
var field_resource : ContentTypeField setget set_field_resource
var item_resource : Resource setget set_item_resource

var data_item_scene := load("res://CM/UI/DataInput/DataItem.tscn") as PackedScene

signal value_changed

func set_field_resource(resource : ContentTypeField):
	field_resource = resource
	$VarName.text = field_resource.var_name
	$VarType.text = field_resource.var_type
	$VarSubtype.text = field_resource.var_subtype
	if field_resource.var_type == "Singleton Reference":
		$ValueSelector.add_item("null")
		$ValueSelector.add_separator()
		$ValueSelector.show()
		# Populate $ValueSelector
		# print(field_resource.var_subtype)
		for value in Content.get_all(field_resource.var_subtype,"name"):
			$ValueSelector.add_item(value)
		$VarValue.hide()
	elif field_resource.var_type == "Singleton Reference(multi)":
		$VarValue.hide()
		$SingletonMulti.show()
		$SingletonMulti.definition_item = resource
	elif field_resource.var_type == "Named Resource":
		if field_resource.var_subtype == "Texture":
			$VarValue.hide()
			$TextureValue.show()
	elif field_resource.var_type == "Subresource":
		$VarValue.hide()
		var def = Content.load_definition(field_resource.var_subtype)
		var res_scene
		if def.custom_editor():
			res_scene = def.custom_editor().instance()
			#res_scene.set(field_resource.var_name)
			res_scene.name = field_resource.var_name
		else:
			res_scene = data_item_scene.instance()
			res_scene.remove_from_group("data_item")
			res_scene.type_definition = def
			res_scene.name = field_resource.var_name
			res_scene.subresource = true
		add_child(res_scene)
	elif field_resource.var_type == "Subresource(multi)":
		$VarValue.hide()
		$SubresourceMultiValue.show()
	elif field_resource.var_type == "bool":
		$VarValue.hide()
		$ValueCheckBox.show()
	elif field_resource.var_type == "Color":
		$VarValue.hide()
		$ValueColor.show()
	elif field_resource.var_type == "String" && field_resource.var_subtype == "Long":
		$VarValue.hide()
		$VarValueLong.show()
	elif field_resource.var_type == "String" && field_resource.var_subtype == "Translated":
		$VarValue.hide()
		$Translated.show()
	elif field_resource.var_type == "Vector2":
		$VarValue.hide()
		$Vector2Value.show()

func set_item_resource(item : Resource):
	item_resource = item
	if field_resource.var_type == "Color":
		$ValueColor.color = item_resource.get(field_resource.var_name)
	elif field_resource.var_type == "String" && field_resource.var_subtype == "Translated":
		$Translated.var_name = field_resource.var_name
		$Translated.item = item
		print($Translated.get_tl_key())
	elif field_resource.var_type == "Singleton Reference":
		var object = item_resource.get(field_resource.var_name)
		if object:
			$ValueSelector.select_by_name(object.name)
		else:
			$ValueSelector.select_by_name("null")
		if field_resource.var_name in type_definition.values_locked:
			$ValueSelector.disabled = true
			$ValueSelector.hint_tooltip = "This value is locked by type's definition."
	elif field_resource.var_type == "Singleton Reference(multi)":
		var collection = item_resource.get(field_resource.var_name)
		if !collection:
			collection = Array()
		$SingletonMulti.resource_item = collection
	elif field_resource.var_type == "Subresource":
		get_node(field_resource.var_name).set("resource",item_resource.get(field_resource.var_name))
		get_node(field_resource.var_name).set(field_resource.var_name,item_resource.get(field_resource.var_name))
		print(item_resource.get(field_resource.var_name))
		#get_node(field_resource.var_name).resource = item_resource.get(field_resource.var_name)
		#find_node(field_resource.var_name).resource = item_resource.get(field_resource.var_name)
	elif field_resource.var_type == "Named Resource":
		if field_resource.var_subtype == "Texture":
			$TextureValue.texture = item_resource.get(field_resource.var_name)
	elif field_resource.var_type == "bool":
		# print(item_resource.get(field_resource.var_name))
		$ValueCheckBox.pressed = item_resource.get(field_resource.var_name)
	elif field_resource.var_type == "Vector2":
		$Vector2Value.value = item_resource.get(field_resource.var_name)
	else:
		$VarValue.text = str(item_resource.get(field_resource.var_name))
		$VarValueLong.text = str(item_resource.get(field_resource.var_name))
	$ValueDisplay.text = str(item_resource.get(field_resource.var_name))
	if field_resource.var_name == "name":
		$VarValue.hide()
		$ValueDisplay.show()


func value_changed(index):
	pass # Replace with function body.


func _on_ValueSelector_item_selected(index):
	var text = $ValueSelector.get_item_text(index)
	if text == "null":
		item_resource.set(field_resource.var_name,null)
	else:
		item_resource.set(field_resource.var_name,$ValueSelector.get_item_text(index))
		# print(item_resource.get(field_resource.var_name).name)
	emit_signal("value_changed")


func _on_VarValue_text_changed(new_text):
	var value = new_text
	if field_resource.var_type == "int":
		value = new_text.to_int()
	if field_resource.var_type == "float":
		value = new_text.to_float()#float(new_text)
	item_resource.set(field_resource.var_name,value)
	print(item_resource.get(field_resource.var_name))
	emit_signal("value_changed")


func _on_ValueCheckBox_toggled(button_pressed):
	item_resource.set(field_resource.var_name,button_pressed)
	emit_signal("value_changed")


func _on_ValueColor_color_changed(color):
	item_resource.set(field_resource.var_name,color)
	emit_signal("value_changed")


func _on_SingletonMulti_state_changed(collection):
	item_resource.set(field_resource.var_name,collection)
	emit_signal("value_changed")


func _on_SubMultiAddButton_pressed():
	#create new subresource item and add it to the array
	pass # Replace with function body.


func _on_VarValueLong_text_changed():
	var new_text = $VarValueLong.text
	item_resource.set(field_resource.var_name,new_text)
	emit_signal("value_changed")


func _on_Vector2Value_value_changed(val):
	item_resource.set(field_resource.var_name,val)
	emit_signal("value_changed")


func _on_Translated_value_changed(locale, new_text):
	pass # Replace with function body.
