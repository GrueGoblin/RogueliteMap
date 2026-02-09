extends HBoxContainer

export var key : String setget set_key
var values : Dictionary

signal text_changed(locale,new_text)
signal delete_key

func _ready():
	$KeyLabel.set_message_translation(false)
	$KeyLabel.notification(NOTIFICATION_TRANSLATION_CHANGED)
	for locale in TranslationServer.get_loaded_locales():
		var text = TextEdit.new()
		text.name = locale
		$Values.add_child(text)
		text.text = values[locale]
		text.connect("text_changed",self,"text_change",[locale])
	
func set_key(value):
	key = value
	$KeyLabel.text = value

func text_change(locale):
	emit_signal("text_changed",locale,get_node("Values/"+locale).text)


func _on_DeleteButton_pressed():
	emit_signal("delete_key")
	
