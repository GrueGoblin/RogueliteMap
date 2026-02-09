extends Object

const translation_path = "res://Game/Translations/"
const translation_filename = "text.{locale}.translation"
const primary_locale = "en"
# primary locale is used to store all the translation keys even if the message is empty

func load_all_translations():
	for filename in Content.get_all_filenames(translation_path):
		TranslationServer.add_translation(load(filename))
		
	#TODO Create primary locale if it doesn't exist
func get_translation_path(locale):
	return translation_path+translation_filename.format({"locale":locale})

func get_translation(locale) -> Translation:
	return load(get_translation_path(locale)) as Translation

func create_translation(locale):
	var errors = []
	
	var dir = Directory.new()
	dir.make_dir_recursive(translation_path)
	
	if locale == "":
		errors.push_back("Locale string cannot be empty.")
	else:
		var tl = Translation.new()
		tl.locale = locale
		if tl.locale != locale:
			errors.push_back("Cannot save translation. Locale is invalid")
		else:
			var error = ResourceSaver.save(get_translation_path(locale),tl)
			if error != 0:
				errors.push_back("Couldn't save locale. Attempt exited with error "+str(error))
			else:
				TranslationServer.add_translation(tl)
	return errors

func remove_translation(locale):
	# destructive operation that removes the translation file
	var errors = []
	if locale == primary_locale:
		errors.push_back("You cannot erase default locale.")
	else:
		var dir = Directory.new()
		var path = get_translation_path(locale)
		var tl = get_translation(locale)
		if dir.file_exists(path):
			dir.remove(path)
			TranslationServer.remove_translation(tl)
			# note: ther should be probably an error check as with any file operation
		else:
			errors.push_back("The translation file doesn't exist.")
	return errors

func clear_translation(locale):
	var tl := get_translation(locale) as Translation
	#tl.messages
	# destructive operation that flushes all the keys for a given translation
	ResourceSaver.save(tl.resource_path,tl)

func save_message(locale, key, value):
	var tl := get_translation(locale)
	tl.add_message(key,value)
	ResourceSaver.save(tl.resource_path,tl)
	
func load_message(locale,key):
	var tl := get_translation(locale)
	return tl.get_message(key)

func load_all_messages_by_key(key):
	var messages := Dictionary()
	for locale in TranslationServer.get_loaded_locales():
		messages[locale] = str(load_message(locale,key))
	return messages

func touch_message(key):
	var tl := get_translation(primary_locale)
	tl.add_message(key,"")
	ResourceSaver.save(tl.resource_path,tl)

func get_all_keys():
	var tl := get_translation(primary_locale)
	if tl:
		return tl.get_message_list()
	return []

func key_content(key : String):
	var type_name = key.split("__")[0]
	return Content.check_type(type_name)

func erase_key(key : String):
	for locale in TranslationServer.get_loaded_locales():
		var tl := get_translation(locale) as Translation
		tl.erase_message(key)
		ResourceSaver.save(tl.resource_path,tl)
		

func get_global_keys():
	var keys = []
	for key in get_all_keys():
		if !key_content(key):
			keys.push_back(key)	
	return keys
 
