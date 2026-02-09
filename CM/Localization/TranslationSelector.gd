extends HBoxContainer

var item_scene = load("res://CM/Localization/TranslationItem.tscn")

func _ready():
	for tl in TranslationServer.get_loaded_locales():
		var button = item_scene.instance() as Button
		button.text = tl
		add_child(button)
		button.connect("pressed",self,"select_translation",[tl])
	pass # Replace with function body.

func select_translation(tl):
	TranslationServer.set_locale(tl)
