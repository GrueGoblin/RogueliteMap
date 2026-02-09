extends Control

var localizer = load("res://CM/Localization/Localizer.gd").new()
var locale_scene = load("res://CM/Localization/LocaleItem.tscn")

var translation_scene = load("res://CM/Localization/TranslationScene.tscn")

const delete_confirmation_format = """Do you realy want to remove the {locale} and the
relevant file? This is a destructive operation."""

const delete_key_format = """Do you realy want to remove the {key} from all
translations? This is a destructive operation.
"""

var locale_to_delete = ""
var key_to_delete := ""

func _ready():
	var installed_locales = TranslationServer.get_loaded_locales()
	for locale in installed_locales:
		add_locale_scene(locale)
	
	refresh_translations()

func refresh_translations():
	for child in $Centerer/Content/GlobalTranslationsPanel/TranslationScroll/TranslationsContainer/Translations.get_children():
		child.queue_free()
	#for key in localizer.get_all_keys():
	for key in localizer.get_global_keys():
		add_translation_scene(key)

func add_translation_scene(key : String):
	var ts = translation_scene.instance()
	ts.key = key
	ts.values = localizer.load_all_messages_by_key(key)
	$Centerer/Content/GlobalTranslationsPanel/TranslationScroll/TranslationsContainer/Translations.add_child(ts)
	ts.connect("text_changed",self,"_on_Translation_text_changed",[key])
	ts.connect("delete_key",self,"_on_Translation_delete_key",[key])
	

func add_locale_scene(locale : String):
	var ls = locale_scene.instance()
	ls.locale = locale
	ls.name = locale
	ls.connect("delete",self,"_on_LocaleItem_delete",[locale])
	$Centerer/Content/LocalePanel/Container/LocalesContainer/Locales.add_child(ls)

func popup_errors(errors : Array):
	$Centerer/Content/LocalePanel/Container/ErrorMessage.text = PoolStringArray(errors).join("\n")
	$Centerer/Content/LocalePanel/Container/ErrorMessage.show()

func _on_LocaleItem_delete(locale):
	$LocaleDelete.dialog_text = delete_confirmation_format.format({"locale" : locale})
	$LocaleDelete.show()
	locale_to_delete = locale
	


func _on_CreateLocaleButton_pressed():
	$LocaleConfirm.show()

func _on_LocaleConfirm_confirmed():
	var locale = $LocaleConfirm/LocaleCode.text
	var errors = localizer.create_translation(locale)
	if errors.empty():
		add_locale_scene(locale)
		refresh_translations()
	else:
		popup_errors(errors)

func _on_LocaleDelete_confirmed():
	var errors = localizer.remove_translation(locale_to_delete) as Array
	if errors.empty():
		get_node("Centerer/Content/LocalePanel/Container/LocalesContainer/Locales/" + locale_to_delete).queue_free()
		refresh_translations()
	else:
		popup_errors(errors)


func _on_Translation_text_changed(locale, new_text, key):
	localizer.save_message(locale, key, new_text)


func _on_AddTranslationButton_pressed():
	$TranslationConfirm.show()


func _on_TranslationConfirm_confirmed():
	var key = $TranslationConfirm/TranslationCode.text
	localizer.touch_message(key)
	add_translation_scene(key)

func _on_Translation_delete_key(key):
	print(key+" delete")
	$TranslationKeyDelete.dialog_text = delete_key_format.format({"key" : key})
	$TranslationKeyDelete.show()
	key_to_delete = key


func _on_TranslationKeyDelete_confirmed():
	localizer.erase_key(key_to_delete)
