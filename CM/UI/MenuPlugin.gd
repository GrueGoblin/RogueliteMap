extends Control
 
var model_item = preload("res://CM/UI/ContentTypeItem.tscn")
var model_resource = preload("res://CM/Resources/ContentType.gd")
var model_field_resource = preload("res://CM/Resources/ContentTypeField.gd")
var create_type_scene := preload("res://CM/UI/CreateType.tscn")
onready var model_list = $ScrollContainer/VBoxContainer/ModelList
const model_path = "res://Game/Models/"
const destruction_confirmation_text = "Are you sure you want to destroy the {content_type} scripts and clear all data?"
var content_to_destroy : String
var content

func _ready():
	content = load("res://CM/Content.gd").new() as Node
	content.connect("ready",self,"load_all")
	add_child(content)
	var label = Label.new()
	label.text = "ready"
	$ScrollContainer/VBoxContainer/ModelList.add_child(label)
	

func load_all():
	load_models()
	load_groups()
	default_properties()
	if content.selected_filter:
		select_group(content.selected_filter)
	var label = Label.new()
	label.text = "load_all"
	$ScrollContainer/VBoxContainer/ModelList.add_child(label)
	pass

func default_properties():
	ProjectSettings.set_setting("display/window/size/width",1920)
	ProjectSettings.set_setting("display/window/size/height",1200)
	ProjectSettings.set_setting("display/window/size/fullscreen",false)
	# this doesnt change setting on the fly!
	pass

func drop_models():
	for c in get_children():
		c.queue_free()

func load_models():
	for content in content.get_children():
		if !content.deleted:
			var new_item = model_item.instance()
			new_item.name = content.name
			new_item.connect("destroy_content_type",self,"destroy_content")
			new_item.connect("edit_content_type",self,"edit_content")
			new_item.connect("edit_content_data",self,"manage_data")
			new_item.connect("create_subtype",self,"create_subtype")
			model_list.add_child(new_item)

func load_groups():
	for group in content.groups:
		add_group_button(group)
		

func add_group_button(group):
	var button = Button.new()
	button.text = group.name
	button.name = group.name
	$ScrollContainer/VBoxContainer/GroupFilter/Groups.add_child(button)
	button.connect("pressed",self,"_on_Group_pressed",[group])

func destroy_content(content_name):	
	$DestructionDialog.dialog_text = destruction_confirmation_text.format({"content_type" : content_name})
	content_to_destroy = content_name
	$DestructionDialog.show()
	
func test():
	var mfr = model_field_resource.new()
	mfr.var_name = "test_field"
	mfr.var_type = "float"
	mfr.default_value = 10.1

func load_model_definition(content_name):
	return load(content.model_definitions_path+content_name+".tres")
	
func edit_content(content_name):
	var scene = create_type_scene.instance()
	content.model_to_edit = load_model_definition(content_name)
	get_tree().change_scene_to(create_type_scene)
	
func manage_data(content_name):
	content.data_to_edit = content_name
	get_tree().change_scene("res://CM/UI/DataInput/TypeData.tscn")
	
func create_subtype(content_name):
	content.subresource_of = content_name
	get_tree().change_scene("res://CM/UI/CreateType.tscn")

func _on_DestructionDialog_confirmed():
	content.destroy_content_type(content_to_destroy)
	$ScrollContainer/VBoxContainer/ModelList.get_node(content_to_destroy).queue_free()


func _on_AddButton_pressed():
	get_tree().change_scene("res://CM/UI/CreateType.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
	
func select_group(group_name):
	match group_name:
		"AllGroups":
			_on_AllGroups_pressed()
		"Ungrouped":
			_on_Ungrouped_pressed()
		_:
			for button in $ScrollContainer/VBoxContainer/GroupFilter/Groups.get_children():
				if button.name == group_name:
					button.emit_signal("pressed")

func _on_AllGroups_pressed():
	for child in $ScrollContainer/VBoxContainer/ModelList.get_children():
		child.show()
	content.selected_filter = "AllGroups"


func _on_Ungrouped_pressed():
	for child in $ScrollContainer/VBoxContainer/ModelList.get_children():
		if !child.definition.group:
			child.show()
		else:
			child.hide()
	content.selected_filter = "Ungrouped"

func _on_Group_pressed(group):
	for child in $ScrollContainer/VBoxContainer/ModelList.get_children():
		if child.definition.group == group:
			child.show()
		else:
			child.hide()
	content.selected_filter = group.name

func _on_AddGroup_pressed():
	$NewGroupDialogue.show()

func _on_NewGroupDialogue_confirmed():
	#print($NewGroupDialogue/NGContainer/NGContent/NewGroupName.text)
	var group_name = $NewGroupDialogue/NGContainer/NGContent/NewGroupName.text
	var group = content.create_group(group_name)
	add_group_button(group)


func _on_LocalizationButton_pressed():
	get_tree().change_scene("res://CM/Localization/LocalizationSetting.tscn")


func _on_ReGeneateButton_pressed():
	for content_name in content.get_all_content_names():
		var type_resource = content.load_definition(content_name)
		content.create_content_type(type_resource,false)
