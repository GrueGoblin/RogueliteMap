extends HBoxContainer

export var locale : String setget set_locale

signal delete

func set_locale(val):
	locale = val
	name = val
	$Code.text = val
	$Name.text = "({locale_name})".format({"locale_name" : TranslationServer.get_locale_name(val)})


func _on_DeleteButton_pressed():
	emit_signal("delete")
