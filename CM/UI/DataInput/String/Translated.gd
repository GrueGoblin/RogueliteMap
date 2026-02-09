extends TabContainer

signal value_changed(locale, new_text)

var item : Resource setget set_item
var var_name : String


func _ready():
	for locale in TranslationServer.get_loaded_locales():
		var locale_scene = TextEdit.new()
		locale_scene.name = locale
		locale_scene.wrap_enabled = true
		add_child(locale_scene)
		locale_scene.connect("text_changed",self,"_on_field_text_changed",[locale_scene,locale]) 
	#populate_texts()

func _on_field_text_changed(node,locale):
	emit_signal("value_changed",locale,node.text)
	Content.localizer.save_message(locale,get_tl_key(),node.text)

func populate_texts():
	for child in get_children():
		if child.name != "Timer":
			child.text = Content.localizer.load_message(child.name, get_tl_key())


func set_item(val):
	
	item = val
	# populate texts
	#populate_texts()
	
func get_tl_key():
	if item:
		return item.get(var_name)
	return ""
	


func _on_Timer_timeout():
	populate_texts()
