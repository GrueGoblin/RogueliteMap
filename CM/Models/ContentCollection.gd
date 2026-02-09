extends "res://CM/Models/Meta/ContentCollection.gd"

class_name ContentCollection

func get_all():
	return items

func get_all_filtered(type, filters : Dictionary, sort_by := ""):
	# TODO use this function for reverse relation of sigleton reference
	var content := []
	for item in items:
		var add := true
		for property in filters:
			if item.get(property) != filters[property]:
				add = false
				continue
		if add:
			content.append(item)
#	if sort_by != "":
#		sorting_property = sort_by
#		content.sort_custom(self, "sort_by_property")
		
	#content.sort()
	return content
