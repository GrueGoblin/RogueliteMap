extends HBoxContainer

var definition : ContentType

func _ready():
	$Name.text = name
	definition = Content.load_definition(name)
	if definition.subresource_only:
		$DataButton.disabled = true
		$DataButton.hint_tooltip = definition.subresource_only_info
	if Content.generator_for(name):
		$CreateGenerator.hide()

signal destroy_content_type(content_name)
signal edit_content_type(content_name)
signal edit_content_data(content_name)
signal create_subtype(content_name)

func _on_DeleteButton_pressed():
	emit_signal("destroy_content_type",name)


func _on_EditButton_pressed():
	emit_signal("edit_content_type",name)


func _on_DataButton_pressed():
	emit_signal("edit_content_data",name)


func _on_AddSubtypeButton_pressed():
	emit_signal("create_subtype",name)


func _on_GenerateNRLists_pressed():
	Content.generate_todo_lists(name)
	pass # Replace with function body.


func _on_CreateGenerator_pressed():
	Content.create_generator(name)
	$CreateGenerator.hide()
	
