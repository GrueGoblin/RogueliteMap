extends Resource

class_name ContentTypeField

# This resource represents a field definition for Content Type
# It's also responsible lines for the variable/relation it represents in Content TypeScript

const field_types = ["String", "Color", "int", "float", "bool","Vector2"]
#const abstract_field_types = ["Singleton Reference", "Singleton Reference (multi)", "Named Resource", "Subresource", "Subresource (multi)"]
const subtypes = {
	"String" : ["Plain","Translated","Long"],
	#"int" : ["Plain","Limited","Gauge"],
	#"Color" : ["Free","From Palette"] actually make a palette finder in Content
}
# TODO : "Subresource(multi)"
const abstract_field_types = ["Singleton Reference", "Singleton Reference(multi)", "Singleton Reference(Dictionary)",
 "Named Resource", "Subresource", "Subresource(multi)"]
const named_resource_subtypes = {
	"Texture" : "res://Game/Graphics/{type}/{variable}/{name}.png",
	"TileSet" : "res://Game/Graphics/Tiles/{type}/{variable}/{name}.tres",
	"Script" : "res://Game/Scripts/{type}/{variable}/{name}.gd",
	"PackedScene" : "res://Game/Scenes/{type}/{variable}/{name}.tscn",
	"ShaderMaterial" : "res://Game/ShaderMaterials/{type}/{variable}/{name}.tres",
#	"Resource" : "res://Game/Resources/{type}/{variable}/{name}.tres",
	"AudioStream" : "res://Game/Music/{type}/{variable}/{name}.mp3",
	"AudioStreamSample" : "res://Game/Sound/{type}/{variable}/{name}.wav",
	"Custom" : "res://Game/Custom/{type}/{variable}/{name}"
}

const translation_key = "{type_name}__{item_name}__{var_name}"

const basic_setter = """
func set_{var_name}(value):
	{var_name} = value
"""

const basic_getter = """
func get_{var_name}():
	return {var_name}
"""

export var var_name := ""
export var var_type := "String"
export var var_subtype : String
export var default_value : String
export var emit_change := true
export var value_locked : Resource

# These values will only be needed for a type "Singleton(Dictionary)" for now
export var var_subvalue_type := "String"
export var var_subvalue_subtype : String
export var default_subvalue_value : String

export var can_rename := true
export var can_remove := true

export var force_setter := false
export var force_getter := false

func named_path_formatted(content_type_name : String):
	return default_value.format({"type" : content_type_name,"variable": var_name})

func var_line(content_type_name : String):
	# ToDo refactor to match syntax, multiline strings with format
	var line := "export var "+var_name+" :"
	if var_type == "Singleton Reference(Dictionary)":
		line = "export (Dictionary) var {var_name} setget , get_{var_name}".format({"var_name" : var_name})
	elif var_type == "Singleton Reference":
		if default_value:
			line = "export (Resource) var "+var_name+' = load("'+Content.find(var_subtype,default_value).resource_path+'")'+" setget set_"+var_name
		else:
			line += " Resource setget set_"+var_name
	elif var_type == "Singleton Reference(multi)" || var_type == "Subresource(multi)":
		line = "export (Array, Resource) var "+var_name
	elif var_type == "Named Resource":
		# Todo Custom named resources
		if var_subtype == "Custom":
			pass
		else:
			# TODO 
			line = "const " + var_name + "_path = " + '"' + default_value.format({"type" : content_type_name,"variable": var_name}) + '"' + "\n"
			if emit_change || force_setter:
				line += "export (" + var_subtype + ") var " + var_name + " setget set_"+ var_name +", get_"+ var_name
			else:
				line += "export (" + var_subtype + ") var " + var_name + " setget , get_"+ var_name
	elif var_type == "String" && var_subtype == "Translated":
		line = "const " + var_name + "_key = " + '"' + translation_key.format({"type_name" : content_type_name,"var_name": var_name}) + '"' + "\n"
		if emit_change:
			line += "export var " + var_name + " : String setget set_"+ var_name +", get_"+ var_name
		else:
			line += "export var " + var_name + " : String setget , get_"+ var_name
	elif var_type == "Subresource":
		line = "export (Resource) var "+var_name+" = "+var_subtype+".new()"
	elif default_value:
		line += "= "
		
		if var_type == "String":
			line += '"'+default_value+'"'
			#line += default_value
		elif var_type == "Color":
			line += default_value
		else:
			if var_type == "float" && default_value.find(".") == -1:
				line += default_value + ".0"
			else:
				line += default_value
	else:
		line += " "+var_type
	if var_type != "Singleton Reference" && var_type != "Named Resource" && (emit_change || force_setter) && var_type != "Singleton Reference(Dictionary)" && !(var_type == "String" && var_subtype == "Translated"):
		line += " setget set_"+var_name
	if force_getter && var_type != "Named Resource" && (var_type != "String" || var_subtype != "Translated"):
		line += ", get_"+var_name
	# implement force getter and setter
	return line

func value_from_string(string : String):
	match var_type:
		"int":
			return int(string)
		"float":
			return float(string)
		"bool":
			return bool(string)
	return string

func func_lines(content_type_name : String):
	var lines = []
	if var_type == "String" && var_subtype == "Translated":
		lines.append("""
func get_{var_name}():
	return {var_name}_key.format({"item_name" : name})
	
		""".format({"var_name" : var_name}))
		pass
	match var_type:
		"Singleton Reference":
			lines.append("""
func set_{var_name}(value):
	if typeof(value) == TYPE_STRING:
		{var_name} = Content.find("{var_subtype}",value)
	else:
		{var_name} = value
""".format({"var_name" : var_name, "var_subtype" : var_subtype}))
			if emit_change:
				lines.append("	emit_changed()")
		"Named Resource":
			lines.append("""
func get_{var_name}():
	{var_name} = load({var_name}_path.format({"name": name}))
	if !{var_name}:
		{var_name} = load({var_name}_path.format({"name": "placeholder"}))
	return {var_name}
""".format({"var_name" : var_name}))
		"Singleton Reference(Dictionary)":
			lines.append("""
func get_{var_name}():
	if !{var_name}.has_all(Content.get_all("{var_subtype}")):
		for key in Content.get_all("{var_subtype}"):
			{not_string_tag}{var_name}[key] = {default_subvalue_value}
			{string_tag}{var_name}[key] = "{default_subvalue_value}"
			# problem getting quoted string value through "format" method
	return {var_name}
""".format({	"var_name" : var_name,
				"default_subvalue_value" : adjusted_value(default_subvalue_value, var_subvalue_type, var_subvalue_subtype), 
				"var_subtype" : var_subtype,
				"not_string_tag" : is_string_tag(var_subvalue_type,false),
				"string_tag" : is_string_tag(var_subvalue_type,true)}))
		
	if emit_change && var_type != "Singleton Reference":
		lines.append("func set_"+var_name+"(value):")
		lines.append("	"+var_name+" = value")
		lines.append("	emit_changed()")
		
	elif force_setter && var_type != "Singleton Reference":
		lines.append(basic_setter.format({"var_name" : var_name, "type_name" : var_type}))
		
	# force getter on all except translated string and named resource
	# these have it automatically implemented
	if force_getter && var_type != "Named Resource" && (var_type != "String" || var_subtype != "Translated"):
		lines.append(basic_getter.format({"var_name" : var_name}))
		
	return lines

func is_string_tag(type : String, positive := true):
	if type == "String":
		if positive:
			return ""
		else:
			return "#"
	else:
		if positive:
			return "#"
		else:
			return ""

func adjusted_value(value : String, type : String, subtype : String):
	if type == "String":
		var val = '"{value}"'.format({"value" : value})
		return val
	elif type == "Subresource":
		return "{subtype}.new()".format({"subtype" : subtype})
	elif type == "Singleton Reference":
		return "{subtype}.new()".format({"subtype" : subtype})
	# Options for singleton?
	# 1. use the same as for subresource as placeholder
	# 2. load default value 
	else:
		return value
	
func validate_field_name_presence():
	if var_name == "":
		return false
	return true
