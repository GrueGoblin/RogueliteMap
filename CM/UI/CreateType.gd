extends Control

var type_name : String setget set_type_name
var type_resource : ContentType
var type_resource_backup : Resource

#onready var content_type_res := preload("res://CM/Resources/ContentType.gd") #content_type resource

onready var content_field = preload("res://CM/UI/FieldDefinitionItem.tscn") #store the content field scene here
onready var field_res := load("res://CM/Resources/ContentTypeField.gd") #content_field resource

onready var group_selection = $ScrollContainer/VBoxContainer/ModelGroup/GroupSelection

const name_not_unique = "Content type of this name already exists. Please use different name. Pascal case is recommended for clarity."
const name_required = "You must enter a name for this new type."
const field_name_unique = "Field names must be unique."
const field_name_not_empty = "Field name must not be empty."


# Called when the node enters the scene tree for the first time.
func _ready():
	if Content.model_to_edit:
		type_resource = Content.model_to_edit#.duplicate()
		Content.model_to_edit = null
		$ScrollContainer/VBoxContainer/Label.text = "Update Content Type {name}".format({"name":type_resource.name})
	if !type_resource:
		type_resource = ContentType.new()
		
	if Content.subresource_of != "":
		type_resource.inherits = Content.subresource_of
		Content.subresource_of = ""
		type_resource.remove_name_field()
		$ScrollContainer/VBoxContainer/InheritLabel.text = $ScrollContainer/VBoxContainer/InheritLabel.text.format({"model_name" : type_resource.inherits})
		$ScrollContainer/VBoxContainer/InheritLabel.show()
	$ScrollContainer/VBoxContainer/ModelNameCont/Singleton.pressed = type_resource.singleton
	$ScrollContainer/VBoxContainer/ModelNameCont/Subresource.pressed = type_resource.subresource_only
	$ScrollContainer/VBoxContainer/ModelNameCont/SaveEncrypted.pressed = type_resource.save_encrypted
	$ScrollContainer/VBoxContainer/ModelNameCont/Scaffolding.pressed = type_resource.type_scaffold 
	if !type_resource.new:
		$ScrollContainer/VBoxContainer/ModelNameCont/ModelNameInput.editable = false
		$ScrollContainer/VBoxContainer/ModelNameCont/Singleton.disabled = true
		$ScrollContainer/VBoxContainer/ModelNameCont/Subresource.disabled = true
		$ScrollContainer/VBoxContainer/ModelNameCont/Scaffolding.disabled = true
	$ScrollContainer/VBoxContainer/Description.text = type_resource.description
	
	type_resource_backup = type_resource.duplicate()
	
	plug_resource()
	clear_type_fields_ui()
	set_type_fields_ui()
	populate_group_selection()
	create_standard_feature_buttons()

func create_standard_feature_buttons():
	for feature in Content.load_all_files("res://CM/Data/Singleton/StandardFeature/"):
		feature = feature as StandardFeature 
		var button = feature.instance_as("Display")
		button.connect("pressed",self,"_on_AddStandardFeature",[feature])
		$ScrollContainer/VBoxContainer/AddStandardFeatures.add_child(button)

func populate_group_selection():
	#var group_selection = $ScrollContainer/VBoxContainer/ModelGroup/GroupSelection
	group_selection.add_item("null")
	group_selection.add_separator()
	for group in Content.groups:
		group_selection.add_item(group.name)

func set_type_name(value):
	type_name = value
	type_resource.name = value
	$ScrollContainer/VBoxContainer/HBoxContainer/ContextGenerate.context_type = type_name

func show_error_message(errs : PoolStringArray):
	$ScrollContainer/VBoxContainer/ErrorFlash.text = errs.join(";")
	$ScrollContainer/VBoxContainer/ErrorFlash/ErrorTimer.start()

func update_values_locked(var_name,value):
	if value:
		type_resource.values_locked[var_name] = value
	else:
		type_resource.values_locked.erase(var_name)

func set_type_fields_ui():
	#print(type_resource.fields)
	for field in type_resource.get_parental_fields():
		var new_field = content_field.instance()
		new_field.item = field
		new_field.is_parent_field()
		# connect the parent fields to update_values_locked function
		new_field.connect("update_value_locked",self,"update_values_locked")
		$ScrollContainer/VBoxContainer/BasicFieldsList.add_child(new_field)
	for field in type_resource.fields:
		var new_field = content_field.instance()
		new_field.item = field
		new_field.connect("delete_confirmed",self,"_on_FieldDefinitionItem_item_delete_confirmed")
		$ScrollContainer/VBoxContainer/BasicFieldsList.add_child(new_field)
		

func clear_type_fields_ui():
	for field in $ScrollContainer/VBoxContainer/BasicFieldsList.get_children():
		if field.name != "LabelsContainer":
			field.queue_free()

	
func plug_resource():
	$ScrollContainer/VBoxContainer/ModelNameCont/ModelNameInput.text = type_resource.name
	$ScrollContainer/VBoxContainer/HBoxContainer/ContextGenerate.context_type = type_resource.name
	$ScrollContainer/VBoxContainer/HBoxContainer/ContentTemplate.definition = type_resource

func _on_SaveButton_pressed():
	var errs = type_resource.perform_validations()
	if errs.empty():
		print("Save " + type_name) 
		var is_new = type_resource.new
		type_resource.new = false
		#print(type_resource.var_lines())
		if is_new && type_resource.subresource_only:
			type_resource.remove_name_field()
		Content.create_content_type(type_resource,is_new)
		get_tree().change_scene("res://CM/UI/Menu.tscn")
	else:
		show_error_message(errs)

func _on_AddStandardFeature(feature : StandardFeature):
	var new_field = content_field.instance()
	var new_field_res = field_res.new()
	new_field_res.var_name = feature.field_name
	new_field_res.var_type = feature.field_type
	new_field_res.var_subtype = feature.field_subtype
	if new_field_res.var_type == "Named Resource" && new_field_res.named_resource_subtypes.has(new_field_res.var_subtype):
		new_field_res.default_value = new_field_res.named_resource_subtypes[new_field_res.var_subtype]
	new_field.item = new_field_res	
	type_resource.fields.push_back(new_field_res)
	$ScrollContainer/VBoxContainer/BasicFieldsList.add_child(new_field)
	var btn = get_node("ScrollContainer/VBoxContainer/AddStandardFeatures/"+feature.field_name)
	if btn:
		btn.queue_free()
	

func _on_AddDataField_pressed():
	var new_field = content_field.instance()
	var new_field_res = field_res.new()
	new_field.item = new_field_res
	type_resource.fields.push_back(new_field_res)
	$ScrollContainer/VBoxContainer/BasicFieldsList.add_child(new_field)

func _on_FieldDefinitionItem_item_changed(item):
	print(item.var_name)
	print(item.var_type)

func _on_FieldDefinitionItem_item_delete_confirmed(field):
	type_resource.fields.erase(field)
	

func _on_Singleton_toggled(button_pressed):
	type_resource.singleton = button_pressed
	print(type_resource.singleton)
	pass # Replace with function body.
	if button_pressed:
		$ScrollContainer/VBoxContainer/ModelNameCont/Subresource.pressed = false
		type_resource.subresource_only = false
		$ScrollContainer/VBoxContainer/ModelNameCont/Subresource.disabled = true
	else:
		$ScrollContainer/VBoxContainer/ModelNameCont/Subresource.disabled = false


func _on_ErrorTimer_timeout():
	$ScrollContainer/VBoxContainer/ErrorFlash.text = ""


func _on_ExitToMenu_pressed():
	# To ensure the changes are discarded on Exit to Menu
	# Works OK so far
	type_resource_backup.take_over_path(type_resource.resource_path)
	get_tree().change_scene("res://CM/UI/Menu.tscn")


func _on_Subresource_toggled(button_pressed):
	type_resource.subresource_only = button_pressed
	if type_resource.new:
		if button_pressed:
			$ScrollContainer/VBoxContainer/BasicFieldsList.get_child(1).hide()
		else:
			$ScrollContainer/VBoxContainer/BasicFieldsList.get_child(1).show()


func _on_SaveEncrypted_toggled(button_pressed):
	type_resource.save_encrypted = button_pressed


func _on_Description_text_changed():
	type_resource.description = $ScrollContainer/VBoxContainer/Description.text


func _on_GroupSelection_item_selected(index):
	if index == 0:
		type_resource.group = null
	else:
		type_resource.group = Content.groups[index-2]


func _on_Scaffolding_toggled(button_pressed):
	type_resource.type_scaffold = button_pressed
	pass # Replace with function body.
