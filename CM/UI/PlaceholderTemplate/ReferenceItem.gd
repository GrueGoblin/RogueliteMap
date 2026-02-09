extends PanelContainer

var blacklisted := false 
var prefix := "" setget set_prefix
var field_definition : ContentTypeField setget set_definition


signal data_changed(blacklist,pref)

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/CheckBox.pressed = !blacklisted

func set_prefix(text):
	$VBoxContainer/PrefixUI/PrefixEdit.text = text

func _on_CheckBox_toggled(button_pressed):
	blacklisted = !button_pressed
	changed()

func set_definition(value):
	field_definition = value
	$VBoxContainer/HBoxContainer/ReferenceName.text = "{var_name} ({var_subtype})".format({
		"var_name" : field_definition.var_name,
		"var_subtype" : field_definition.var_subtype
	})

func _on_LineEdit_text_changed(new_text):
	prefix = new_text
	changed()

func _on_ClearButton_pressed():
	self.prefix = ""

func changed():
	emit_signal("data_changed", blacklisted, prefix)
