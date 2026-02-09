extends VBoxContainer

var resource : Resource setget set_resource
var type_definition : ContentType setget set_definition
#onready var field_scene = preload("res://CM/UI/DataInput/FieldItem.tscn")
var data_item_scene := load("res://CM/UI/DataInput/DataItem.tscn") as PackedScene
var field_item_scene := load("res://CM/UI/DataInput/FieldItem.tscn") as PackedScene
var subresource := false
var custom_editor := false

var child_type_names : Array
var transfer_index := -1

onready var fields = $ItemFields

func _ready():
	#if !resource:
	#	subresource = true
	#	self.resource = get_parent().item_resource.get(name)
	var custom_add_editor = type_definition.custom_additional_editor()
	if custom_add_editor:
			# TODO move this logic into data item scene
			var new_custom_add_editor = custom_add_editor.instance()
			new_custom_add_editor.set(Content.pascal_to_snake(type_definition.name),resource)
			fields.add_child(new_custom_add_editor)
	pass

func _on_ExpandButton_pressed():
	if !fields.visible:
		$Header/ExpandButton.text = "-"
		fields.show()
	else:
		$Header/ExpandButton.text = "+"
		fields.hide()

func activate_save():
	$Header/SaveButton.disabled = false

func _on_SaveButton_pressed():
	var path = type_definition.data_path() + resource.name + ".tres"
	resource.take_over_path(path)
	if type_definition.save_encrypted:
		ResourceEncryptor.new().save_encrypted(path,resource)
	else:
		resource.save()
		#ResourceSaver.save(path,resource)
	$Header/SaveButton.disabled = true

func set_resource(value):
	resource = value
	if subresource:
		$Header/ItemName.text = get_parent().field_resource.var_subtype
		$Header/SaveButton.hide()
		$Header/DeleteButton.hide()
	else:
		$Header/ItemName.text = resource.name
		$Node/DeleteConfirm.dialog_text = $Node/DeleteConfirm.dialog_text.format({"name" : resource.name})
	for item in $ItemFields.get_children():
		item.set("item_resource", resource)
	#$Node/DeleteConfirm.dialog_text = $Node/DeleteConfirm.dialog_text.format({"name" : resource.name})
	
func set_definition(value):
	type_definition = value
	for field in type_definition.get_parental_fields():
		var new_field = field_item_scene.instance()
		new_field.type_definition = type_definition
		new_field.name = field.var_name
		new_field.field_resource = field
		new_field.connect("value_changed",self,"value_changed")
		$ItemFields.add_child(new_field)
	for field in type_definition.fields:
		var new_field = field_item_scene.instance()
		new_field.type_definition = type_definition
		new_field.name = field.var_name
		new_field.field_resource = field
		new_field.connect("value_changed",self,"value_changed")
		$ItemFields.add_child(new_field)
	child_type_names = type_definition.child_type_names() as Array
	if child_type_names.size() > 0:
		$Header/TransferButton.show()
		#populate popup menu
		for child_type_name in child_type_names:
			$Header/TransferButton/TransferPopupMenu.add_item(child_type_name)
			pass

func _on_DeleteButton_pressed():
	$Node/DeleteConfirm.show()


func value_changed():
	if subresource:
		get_parent().emit_signal("value_changed")
		#print("value changed")
	else:
		$Header/SaveButton.disabled = false


func _on_DeleteConfirm_confirmed():
	Directory.new().remove(resource.resource_path)
	Content.destroy_item(type_definition.name,resource.name)
	queue_free()


func _on_RenameButton_pressed():
	$Node/RenameConfirm.show()


func _on_RenameConfirm_confirmed():
	var new_name = $Node/RenameConfirm/NewName.text
	Content.rename_item(type_definition.name,resource.name,new_name)
	# renaming doesn't delete the old item
	Content.reload_data_for(type_definition.name)
	get_tree().change_scene("res://CM/UI/DataInput/TypeData.tscn")


func _on_TransferButton_pressed():
	print(type_definition.child_type_names())
	$Header/TransferButton/TransferPopupMenu.show()
	pass # Replace with function body.


func _on_TransferPopupMenu_index_pressed(index):
	#print(index)
	#print(child_type_names[index])
	transfer_index = index
	$Header/TransferButton/TransferConfirmationDialog.dialog_text = "Dou you really want to transfer {name} under type {type}?".format({
		"name" : resource.name,
		"type" : child_type_names[transfer_index]
	})
	$Header/TransferButton/TransferConfirmationDialog.show()
	


func _on_TransferConfirmationDialog_confirmed():
	print("call")
	print(ClassDB.can_instance(child_type_names[transfer_index]))
	Content.transfer_item(type_definition.name, child_type_names[transfer_index], resource.name)
	queue_free()
