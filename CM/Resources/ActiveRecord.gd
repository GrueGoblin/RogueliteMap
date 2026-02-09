extends Resource

class_name ActiveRecord

signal freed

func save():
	_before_save()
	if resource_path:
		ResourceSaver.save(resource_path,self)

func destroy():
	Directory.new().remove(resource_path)

func humanized_name():
	return Content.humanize(str(get("name")))

func free():
	emit_signal("freed")
	
func _before_save():
	pass

func _connect_signals():
	# overwrite this method on the model to connect it with subresources
	pass
