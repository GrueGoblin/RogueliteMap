extends Control

var definition : ContentType setget set_definition
var template : PlaceholderContentTemplate

onready var ref_item_scene := preload("res://CM/UI/PlaceholderTemplate/ReferenceItem.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#self.definition = Content.load_definition("TestGenerateTemplate")
	pass # Replace with function body.

func set_definition(value):
	definition = value
	template = definition.placeholder_template
	for field in definition.fields_filtered("Singleton Reference"):
		var ref_scene = ref_item_scene.instance()
		ref_scene.field_definition = field
		# ToDo apply blacklist/existing prefixes
		ref_scene.blacklisted = template.references_blacklist.find(field.var_name) != -1
		if template.prefixes.has(field.var_name):
			ref_scene.prefix = template.prefixes[field.var_name]
		ref_scene.connect("data_changed",self,"refresh_data",[field])
		$ScrollContainer/Container/Content/ContentContainer/References.add_child(ref_scene)
	# set up reference fields
	
	actualize()

func actualize():
	$ScrollContainer/Container/Content/ContentContainer/Amount/AmountValue.value = template.copies
	$ScrollContainer/Container/Content/ContentContainer/Preview/Example.text = definition.placeholder_example_name()

func refresh_data(blacklisted, prefix, field):
	if blacklisted:
		template.references_blacklist.append(field.var_name)
	else:
		template.references_blacklist.erase(field.var_name)
	template.prefixes[field.var_name] = prefix
	#function to connect reference representations to....
	actualize()
	print(template.prefixes)

func _on_ToggleContent_pressed():
	if $ScrollContainer/Container/Content.visible:
		$ScrollContainer/Container/Content.hide()
		$ScrollContainer/Container/Header/HBoxContainer/ToggleContent.text = "+"
	else:
		$ScrollContainer/Container/Content.show()
		$ScrollContainer/Container/Header/HBoxContainer/ToggleContent.text = "-"


func _on_AmountValue_value_changed(value):
	template.copies = value
	actualize()


func _on_SufixLineEdit_text_changed(new_text):
	template.sufix = new_text
	actualize()


func _on_UseContentTypeNameCheckBox_toggled(button_pressed):
	template.use_content_type_name = button_pressed
	actualize()
