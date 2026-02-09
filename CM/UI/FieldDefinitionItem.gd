extends HBoxContainer

var item : ContentTypeField#Resource #setget set_item
onready var field_res := preload("res://CM/Resources/ContentTypeField.gd")
var instance_options = []
var autoselect := false
var custom_name := false
var parental_field := false

#signal item_changed
signal delete_confirmed(item)
signal update_value_locked(field_name, val)


func _ready():
	for i in item.field_types:
		$FieldType.add_item(i)
		$SingletonDictionaryValueSpec/ValueType.add_item(i)
	$FieldType.add_separator()
	$SingletonDictionaryValueSpec/ValueType.add_separator()
	for i in item.abstract_field_types:
		$FieldType.add_item(i)
		$SingletonDictionaryValueSpec/ValueType.add_item(i)
	set_item(item)

func is_parent_field():
	$FieldName.hide()
	$FieldNameLabel.show()
	$FieldType.disabled = true
	$FieldSubType.disabled = true
	$DefaultValue.hide()
	$RemoveButton.hide()
	if item.var_type == "Singleton Reference":
		$SingletonReferenceValueLock.show()
		#$SingletonReferenceValueLock.disabled = false
	parental_field = true
	
func set_item(i):
	item = i
	$FieldName.text = item.var_name
	$FieldNameLabel.text = item.var_name
	if !item.can_rename:
		$FieldName.hide()
		$FieldNameLabel.show()
		$FieldType.disabled = true
		$DefaultValue.hide()
	if !item.can_remove:
		$RemoveButton.hide()
		hint_tooltip = "You can't remove this field."
		$FieldType.hint_tooltip = "You can't remove this field."
		$FieldNameLabel.hint_tooltip = "You can't remove this field."
	# Select the right type	
	$FieldType.select_by_name(item.var_type)
	if item.default_value:
		$DefaultValue.text = str(item.default_value)
	if item.var_type == "Singleton Reference":
		activate_subtype(Content.all_singleton_names())
		$FieldSubType.select_by_name(item.var_subtype)
		$DefaultValue.hide()
		$DefaultValueOptionButton.show()
		populate_default_options(item.var_subtype)
		$DefaultValueOptionButton.select_by_name(item.default_value)
	if item.var_type == "Named Resource":
		activate_subtype(item.named_resource_subtypes.keys())
		$FieldSubType.select_by_name(item.var_subtype)
	$EmitChangedCheckBox.pressed = item.emit_change
	#select default value for singleton reference	
	#activate option buttons for singleton reference

func find_item_index(option_button : OptionButton,var_name):
	for i in option_button.get_item_count():
		if option_button.get_item_text(i) == var_name:
			#print(i)
			return i
	return -1

func _on_FieldType_item_selected(index):
	item.var_type = $FieldType.get_item_text(index)
	$SingletonDictionaryValueSpec.hide()
	#print(index)
	if item.var_type == "Singleton Reference":
		activate_subtype(Content.all_singleton_names())
		switch_default_value("OptionButton")
		autoselect = true
		_on_FieldSubType_item_selected(0)
		autoselect = false
	elif item.var_type == "Singleton Reference(multi)":
		activate_subtype(Content.all_singleton_names())
	elif item.var_type == "Singleton Reference(Dictionary)":
		activate_subtype(Content.all_singleton_names())
		$SingletonDictionaryValueSpec.show()
	elif item.var_type == "Named Resource":
		activate_subtype(item.named_resource_subtypes.keys())
		autoselect = true
		_on_FieldSubType_item_selected(0)
		autoselect = false
		switch_default_value("Label")
	elif item.var_type == "Subresource":
		activate_subtype(Content.all_instanced_names())
		switch_default_value("Label")
		autoselect = true
		_on_FieldSubType_item_selected(0)
		autoselect = false
	elif item.var_type == "bool":
		deactivate_subtype()
		switch_default_value("CheckBox")
		item.default_value = var2str(false)
	elif item.var_type == "Color":
		deactivate_subtype()
		switch_default_value("Color")
	else:
		if item.subtypes.has(item.var_type):
			activate_subtype(item.subtypes[item.var_type])
		else:
			deactivate_subtype()
		switch_default_value("")

func _on_FieldSubType_item_selected(index):
	item.var_subtype = $FieldSubType.get_item_text(index)
	if item.var_type == "String" && item.var_subtype == "Translated":
		switch_default_value("Label")
		# change the default value to the constant format
	match item.var_type:
		"Singleton Reference":
			populate_default_options(item.var_subtype)
			set_name_if_empty(item.var_subtype)
		"Subresource":
			set_name_if_empty(item.var_subtype)
		"Named Resource":
			switch_default_value("Label")
			item.default_value = item.named_resource_subtypes[item.var_subtype]
			$DefaultValueLabel.text = item.default_value
			set_name_if_empty(item.var_subtype)
		_:
			clear_default_options()
		
func set_name_if_empty(suggestion : String, multi = false):
	if !autoselect && !custom_name:
		if multi:
			suggestion += "s"
		suggestion = Content.pascal_to_snake(suggestion)
		$FieldName.text = suggestion
		set_item_name(suggestion)

func switch_default_value(to : String):
	for tag in ["","Label","OptionButton","CheckBox","Color"]:
		find_node("DefaultValue"+tag).hide()
	find_node("DefaultValue"+to).show()
	
func switch_default_value_value(to : String):
	for tag in ["","Label","OptionButton","CheckBox","Color"]:
		print(tag)
		get_node("SingletonDictionaryValueSpec/DefaultValue"+tag).hide()
	get_node("SingletonDictionaryValueSpec/DefaultValue"+to).show()

func populate_option_button(button : OptionButton, options : Array, null_option := false):
	button.clear()
	if null_option:
		button.add_item("")
		button.add_separator()
	for opt in options:
		button.add_item(opt)

func populate_default_options(type):
	$DefaultValueOptionButton.disabled = false
	instance_options = Content.get_all(type, "name")#SingletonReferenceValueLock
	populate_option_button($DefaultValueOptionButton,instance_options,true)
	populate_option_button($SingletonReferenceValueLock,instance_options,true)
	
func populate_default_value_options(type):
	$SingletonDictionaryValueSpec/DefaultValueOptionButton.disabled = false
	instance_options = Content.get_all(type, "name")
	populate_option_button($SingletonDictionaryValueSpec/DefaultValueOptionButton,instance_options,true)
	
func clear_default_options():
	$DefaultValueOptionButton.disabled = true
	$DefaultValueOptionButton.clear()
	$SingletonReferenceValueLock.clear()
	instance_options = []

func activate_subtype(options : Array):
	if !parental_field:
		$FieldSubType.disabled = false
		populate_option_button($FieldSubType,options)
		
func activate_value_subtype(options : Array):
	if !parental_field:
		$SingletonDictionaryValueSpec/ValueSubtype.disabled = false
		populate_option_button($SingletonDictionaryValueSpec/ValueSubtype,options)

func deactivate_subtype():
	$FieldSubType.clear()
	$FieldSubType.disabled = true
	
func deactivate_value_subtype():
	$SingletonDictionaryValueSpec/ValueSubtype.clear()
	$SingletonDictionaryValueSpec/ValueSubtype.disabled = true

func _on_FieldName_text_changed(new_text):
	custom_name = true
	set_item_name(new_text)

func set_item_name(new_text):
	item.var_name = new_text

func _on_DefaultValue_text_changed(new_text):
	item.default_value = new_text
	#emit_signal("item_changed",item)


func _on_RemoveButton_pressed():
	$Node/DeletionConfirmationDialog.show()


func _on_DeletionConfirmationDialog_confirmed():
	emit_signal("delete_confirmed",item)
	print("deleted")
	queue_free()


func _on_DefaultValueOptionButton_item_selected(index):
	var actual_index = index-2
	if actual_index < 0:
		item.default_value = ""
	else:
		item.default_value = instance_options[actual_index]
	print(item.default_value)


func _on_DefaultValueCheckBox_toggled(button_pressed):
	item.default_value = var2str(button_pressed)

func _on_DefaultValueColor_color_changed(color):
	item.default_value = var2str(color)
	print(item.default_value)


func _on_EmitChangedCheckBox_toggled(button_pressed):
	item.emit_change = button_pressed


func _on_ValueType_item_selected(index):
	item.var_subvalue_type = $SingletonDictionaryValueSpec/ValueType.get_item_text(index)
	deactivate_value_subtype()
	match item.var_subvalue_type:
		"bool":
			switch_default_value_value("CheckBox")
		"String":
			switch_default_value_value("")
		"Subresource":
			activate_value_subtype(Content.all_instanced_names())
			switch_default_value_value("OptionButton")
		"Singleton Reference":
			activate_value_subtype(Content.all_singleton_names())
			switch_default_value_value("OptionButton")
		"Singleton Reference(multi)":
			activate_value_subtype(Content.all_singleton_names())
			switch_default_value_value("OptionButton")
		"Singleton Reference(Dictionary)":
			# perhaps don't use this one as value type
			activate_value_subtype(Content.all_singleton_names())
			switch_default_value_value("OptionButton")
		"Color":
			switch_default_value_value("Color")
		_:
			switch_default_value_value("")


func _on_ValueSubtype_item_selected(index):
	item.var_subvalue_subtype = $SingletonDictionaryValueSpec/ValueSubtype.get_item_text(index)
	# populate selection of default value with
	match item.var_subvalue_type:
		"Singleton Reference":
			populate_default_value_options(item.var_subvalue_subtype)


func _on_DefaultValue_subvalue_text_changed(new_text):
	item.default_subvalue_value = new_text#var2str(new_text)


func _on_DefaultValueOptionButton_subvalue_item_selected(index):
	item.default_subvalue_value = $SingletonDictionaryValueSpec/DefaultValueOptionButton.get_item_text(index)#var2str(index)


func _on_DefaultValueColor_subvalue_color_changed(color : Color):
	item.default_subvalue_value = var2str(color)


func _on_DefaultValueCheckBox_subvalue_toggled(button_pressed):
	item.default_subvalue_value = var2str(button_pressed)


func _on_SingletonReferenceValueLock_item_selected(index):
	var value_locked = Content.find(item.var_subtype,$SingletonReferenceValueLock.get_item_text(index))
	emit_signal("update_value_locked",item.var_name,value_locked)
	print(value_locked.name)
	pass # Replace with function body.


func _on_ForceSetterCheckBox_toggled(button_pressed):
	item.force_setter = button_pressed

func _on_ForceGetterCheckBox_toggled(button_pressed):
	item.force_getter = button_pressed
