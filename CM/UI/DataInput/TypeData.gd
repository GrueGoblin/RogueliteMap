extends Control

var type_definition : ContentType setget set_definition
var type_script : Script
var type_name : String setget set_type_name
#onready var data_item_ui : 
const main_label = "Manage data for Type {type_name}"
var data_item_scene := load("res://CM/UI/DataInput/DataItem.tscn") as PackedScene
var custom_editor_container := load("res://CM/UI/DataInput/CustomEditorContainer.tscn") as PackedScene

func set_type_name(value):
	type_name = value
	$VBoxContainer/Label.text = main_label.format({"type_name" : value})
	self.type_definition = Content.load_definition(value) as ContentType
	
	type_script = Content.load_script(value)
	load_data()
	
	
func set_data():
	pass

func _ready():
	self.type_name = Content.data_to_edit
	_on_SaveAllButton_pressed()

func set_definition(value : ContentType):
	type_definition = value
	if type_definition.description == "":
		$VBoxContainer/DefinitionDescriptionContainer.hide()
	else:
		$VBoxContainer/DefinitionDescriptionContainer/DefinitionDescriptionLabel.text = type_definition.description
	$VBoxContainer/SingletonFilter.content_type = type_definition
	# todo move dependencies here

func _on_ValueSelector_item_selected(index, selected_name):
	pass # Replace with function body.

func load_data():
	var data = Content.get_all(type_name,"","",false)
	for item in data:
		add_item(item)
	
func add_item(item : Resource, new = false):
	var custom_editor = type_definition.custom_editor()
	var data_item
	if custom_editor:
		data_item = custom_editor_container.instance()
		data_item.definition = type_definition
		data_item.item = item
		if new:
			data_item.activate_save(true)
	else:
		data_item = data_item_scene.instance()
		data_item.type_definition = type_definition
		data_item.resource = item
		
		if new:
			data_item.activate_save()
			
	$VBoxContainer/ItemsScroll/Items.add_child(data_item)

func _on_AddItemButton_pressed():
	$NewItemDialogue.show()


func _on_NewItemConfirmButton_pressed():
	$NewItemDialogue.hide()
	var value = $NewItemDialogue/NewItemContent/Input.text
	var new_item = type_script.new()
	new_item.name = value
	add_item(new_item,true)

func _on_SaveAllButton_pressed():
	get_tree().call_group("data_item", "_on_SaveButton_pressed")


func _on_BackToMenu_pressed():
	Content.reload_data_for(type_definition.name)
	Content.generate_todo_lists(type_name)
	get_tree().change_scene("res://CM/UI/Menu.tscn")


func _on_GenerateContentButton_pressed():
	$GenerateDialogue.show()


func _on_GenerateConfirmButton_pressed():
	$GenerateDialogue.hide()
	type_definition.generate_placeholder_content()

func _on_DeleteAllConfirmButton_pressed():
	$DeleteAllDialogue.hide()
	for item in $VBoxContainer/ItemsScroll/Items.get_children():
		item._on_DeleteConfirm_confirmed()


func _on_DeleteAllButton_pressed():
	$DeleteAllDialogue.show()

func _on_GenerateNamedContent_pressed():
	$GenerateNamedDialogue.show()

func _on_GenerateNamedConfirmButton_pressed():
	$GenerateNamedDialogue.hide()
	var items = Content.generate_named_content(type_name)
	for new_item in items:
		add_item(new_item,true)

func _on_SingletonFilter_apply_filter(filter : Dictionary):
	print(filter)
	for item_scene in $VBoxContainer/ItemsScroll/Items.get_children():
		item_scene.show()
		for key in filter:
			if item_scene.resource.get(key) != filter[key]:
				item_scene.hide()


func _on_SingletonFilter_clear_filter():
	for item_scene in $VBoxContainer/ItemsScroll/Items.get_children():
		item_scene.show()
	pass # Replace with function body.
