extends Resource

class_name ContentRelation

export var rel_resource_type : String
export var key_variable_name : String

func get_lines(own_type_name : String):
	var format_params := {	"by":"",
							"rel_resource_type" : rel_resource_type, 
							"key_variable_name" : key_variable_name, 
							"rel_res_type_snake" : Content.pluralize(Content.pascal_to_snake(rel_resource_type)) 
							}
	if custom_name(own_type_name):
		format_params["by"] = "_by_{key_variable_name}".format({"key_variable_name" : key_variable_name})
	
	return """
func get_{rel_res_type_snake}{by}(additional_filters := {}):
	var filter = {"{key_variable_name}" : self}
	for key in additional_filters:
		filter[key] = additional_filters[key]
	return Content.get_all_filtered("{rel_resource_type}",filter)
""".format(format_params)

func custom_name(own_type_name : String) -> bool:
	# checks if key_variable_name is not conventional
	# (only conventional kvn references will get function named get_[typename]s() for
	# the sake of uniqueness - other ones will generate get_[typename]s_by_[varname]()) 
	return Content.pascal_to_snake(own_type_name) != key_variable_name
