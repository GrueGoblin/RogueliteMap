extends HBoxContainer

var item : Resource setget set_item
signal state_changed(state,it)
signal value_changed(value,it)

func _ready():
	pass
	#set_input_type("Selector")

func set_item(it):
	item = it
	$Label.text = item.name

func _on_CheckBox_toggled(button_pressed):
	emit_signal("state_changed",button_pressed,item)

func check():
	$CheckBox.pressed = true


func _on_LineEdit_text_changed(new_text):
	pass # Replace with function body.


func _on_ValueSelector_item_selected(index):
	pass # Replace with function body.


func _on_ValueCheckBox_toggled(button_pressed):
	pass # Replace with function body.

func set_input_type(type : String):
	$ValueCheckBox.hide()
	$ValueLineEdit.hide()
	$ValueSelector.hide()
	get_node("Value" + type).show()
