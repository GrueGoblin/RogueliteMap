extends HBoxContainer

var item : Resource setget set_item
signal state_changed(state,it)

func set_item(it):
	item = it
	$Label.text = item.name

func _on_CheckBox_toggled(button_pressed):
	emit_signal("state_changed",button_pressed,item)

func check():
	$CheckBox.pressed = true
