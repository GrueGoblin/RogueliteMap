extends VBoxContainer

var definition : ContentType setget set_definition
var item : Resource setget set_item

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_definition(value : ContentType):
	definition = value
	var custom_editor = definition.custom_editor() as PackedScene
	var editor = custom_editor.instance()
	editor.name = "Editor"
	add_child(editor)
	move_child(editor,1)
	editor.hide()
	
	
	
func set_item(value : Resource):
	item = value
	$Editor.set(Content.pascal_to_snake(definition.name),item)
	$Header/NameLabel.text = item.name
	item.connect("changed",self,"item_changed")
	

func _on_EditorActions_save():
	var path = definition.data_path() + item.name + ".tres"
	item.take_over_path(path)
	item.resource_path = path
	item.save()
	$EditorActions.activate_save(false)


func _on_EditorActions_rename():
	pass # Replace with function body.


func _on_EditorActions_delete():
	pass # Replace with function body.


func _on_ShowButton_pressed():
	$Header/ShowButton.hide()
	$Header/HideButton.show()
	$Editor.show()


func _on_HideButton_pressed():
	$Header/ShowButton.show()
	$Header/HideButton.hide()
	$Editor.hide()

func item_changed():
	$EditorActions.activate_save(true)

func activate_save(active = true):
	$EditorActions.activate_save(active)
