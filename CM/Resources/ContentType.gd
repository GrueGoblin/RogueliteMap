extends Resource

class_name ContentType

# This resource represents a content type definition
# It also aggregates the script for the content type

export var name : String

export var group : Resource

export (Array, Resource) var fields# := Array()
export (Dictionary) var relations
# key = related model name
# value array of ContentRelation objects


export (Resource) var placeholder_template = PlaceholderContentTemplate.new() 

export var singleton := false
export var subresource_only := false
export var type_scaffold := false
export var inherits := ""
export var save_encrypted := false

# for locked values in inherited fields 
export var values_locked := Dictionary()

# To serve for class documentation
export var description := ""

signal field_added
signal field_destroyed


export var new := true



const subresource_only_info = "This content type is not meant to be instantiated on its own and as such, doesn't need a name field."

const validations = {
	"name_not_unique" : "Content type of this name already exists. Please use different name. Pascal case is recommended for clarity.",
	"type_name_not_unique":"Cannot generate scaffold type for this item. {name}Type already exists. Either change the type name or connect the existing type manually.",
	"name_empty" : "You must enter a name for this new type.",
	"field_names_unique" : "Field names must be unique.",
	"field_names_presence" : "Field name must not be empty.",
	"blacklisted_field_name" : "Field name must not be 'value'."
}

func load_script():
	Content.load_script(name)

func save():
	ResourceSaver.save(resource_path,self)

func get_parents():
	var parents := []
	var parent_name = inherits
	while parent_name != "":
		var parent = Content.load_definition(parent_name)
		parents.push_front(parent)
		parent_name = parent.inherits
	return parents

func get_parental_fields():
	var parental_fields := Array()
	for parent in get_parents():
		parental_fields.append_array(parent.fields)
	return parental_fields

func get_all_fields():
	var all_fields := Array()
	all_fields.append_array(fields)
	all_fields.append_array(get_parental_fields())
	return all_fields
	
func fields_filtered(type = ""):
	var filtered_fields := Array()
	for field in get_all_fields():
		if field.var_type == type:
			filtered_fields.append(field)
	return filtered_fields

func get_singleton_ref_list():
	var list := Dictionary()
	for field in get_all_fields():
		if field.var_type == "Singleton Reference" && placeholder_template.references_blacklist.find(field.var_name) == -1:			
			list[field.var_name] = field.var_subtype
	return list
	
func get_singleton_ref_data():
	# ToDo return data including var_name
	var dict = Dictionary()
	var ref_list = get_singleton_ref_list()
	for ref in ref_list:
		var data := Dictionary()
		data["var_name"] = ref
		data["data"] = Content.get_all(ref_list[ref])
		data["prefix"] = placeholder_template.prefixes.get(ref)
		dict[ref] = data
	return dict

func get_prefixes_list():
	var prefixes := Array()
	for field in get_all_fields():
		if field.var_type == "Singleton Reference" && placeholder_template.references_blacklist.find(field.var_name) == -1:
			if placeholder_template.prefixes.has(field.var_name):
				prefixes.append(placeholder_template.prefixes[field.var_name])
			else:
				prefixes.append("")
	return prefixes

func remove_name_field():
	fields.remove(0)

func _init():
	fields = []
	var name_field = load("res://CM/Resources/ContentTypeField.gd").new()
	name_field.var_name = "name"
	name_field.can_rename = false
	name_field.can_remove = false
	fields.push_back(name_field)
	

func data_for_relations():
	var data := {}
	for field in fields:
		if field.var_type == "Singleton Reference":
			if data.has(field.var_subtype):
				data[field.var_subtype].push_back(field.var_name)
			else:
				data[field.var_subtype] = [field.var_name]
	return data

func perform_validations():
	var errors := PoolStringArray([])
	for validation in validations.keys():
		if !call("validate_"+validation):
			errors.push_back(validations[validation].format({"name":name}))
	return errors
	
func validate_name_not_unique():
	if new && Content.content_type_exists(name):
		return false
	return true
	
func validate_type_name_not_unique():
	if new && type_scaffold && Content.content_type_exists(name + "Type"):
		return false
	return true

func validate_name_empty():
	if name == "":
		return false
	return true
	
func validate_field_names_unique():
	var names := []
	for field in fields:
		if names.find(field.var_name) != -1:
			return false
		names.push_back(field.var_name)
	return true

func validate_field_names_presence():
	for field in fields:
		if !field.validate_field_name_presence():
			return false
	return true
	
func validate_blacklisted_field_name():
	for field in fields:
		if field.var_name == "value":
			return false
	return true

func var_lines() -> PoolStringArray:
	var lines = PoolStringArray([])
	
	#lines.append("### "+description)
	
	lines.append("### "+description.split("\n").join("\n###"))
		
	for field in fields:
		lines.append(field.var_line(name))
		
	# To string override
	lines.append("""
func _to_string():
	return "[{type_name}:{name}]".format({"name" : get("name")})
	""".format({"type_name" : name}))
	
	# instancing context
	lines.append("""
func instance_as(context_name : String, secondary_contexts = {}):
	var context_scene = load(Content.scenes_path + "{type_name}/" + context_name + ".tscn")
	if !context_scene:
		return .instance_as(context_name, secondary_contexts)
	var instance = context_scene.instance()
	instance.set("{var_name}", self)
	for secondary_context in secondary_contexts:
		instance.set(secondary_context, secondary_contexts[secondary_context])
	return instance
	""".format({"type_name" : name, "var_name" : Content.pascal_to_snake(name)}))
	
	for field in fields:
		lines.append_array(PoolStringArray(field.func_lines(name)))
	for related_type in relations:
		for relation in relations[related_type]:
			lines.append(relation.get_lines(name))
	for lv in values_locked:
		lines.append("""
func _init():
	{var_name} = load("{value_locked}")
		""".format({
			"var_name" : lv,
			"value_locked" : values_locked[lv].resource_path
		}))
	return lines

func generator_boilerplate():
	var body = """
func generate(params := {}):
	if params.has("method"):
		return call(params["method"], params)
	return {item}
	"""
	var item : String
	
	if subresource_only:
		item = "{name}.new()".format({"name" : name})
	else:
		item = "Content.get_random(\"{name}\")".format({"name" : name})
	
	return body.format({"item" : item})

func data_path():
	var path = Content.data_path
	if singleton:
		path += "Singleton/"
	else:
		path += "Instanced/"
	path += name + "/"
	return path

func path_for(item_name):
	return data_path() + item_name + ".tres"

func placeholder_example_name():
	var list = get_singleton_ref_list()
	var example_name = ""
	for item in list:
		if placeholder_template.prefixes.has(item):
			example_name += placeholder_template.prefixes[item]
		var ref_item = Content.generate(list[item])
		if ref_item:
			example_name += Content.generate(list[item]).name
		else:
			example_name += "[Example{type}]".format({"type" : list[item]})
	example_name += placeholder_template.sufix
	if placeholder_template.use_content_type_name:
		example_name += name
	if placeholder_template.copies > 1:
		example_name += str(randi() % placeholder_template.copies)
	return example_name
	
func generate_placeholder_content():
	# ToDo: make a method generating all names and utilize it both here and placeholder_example_name()
	#var definition = load_definition(type_name)
	var type_data = get_singleton_ref_data()
	var prefixes = get_prefixes_list()
	var scr = Content.load_script(name)
	var combined_data := []
	var file := File.new()
	for type in type_data:
		combined_data = Content.combine(combined_data,type_data[type]["data"])
	# ensures Numbered content is generated even without references
	if combined_data.empty() && placeholder_template.copies > 1:
		combined_data.push_back([])
	#print(combined_data)
	# ToDo implement prefixes + sufix
	for combination in combined_data:
		for num in placeholder_template.copies:
			var item_name = ""
			var i = 0
			for ref_item in combination:
				# order of prefixes should match order of combination
				item_name += prefixes[i]
				item_name += ref_item.name
				i += 1
			item_name += placeholder_template.sufix
			if placeholder_template.use_content_type_name:
				item_name += name
			if placeholder_template.copies > 1:
				item_name += str(num+1)
			#print(item_name)
			var item_path = data_path() + item_name + ".tres"
			if file.file_exists(item_path):
				# Don't rewrite existing resources
				continue
			var item = scr.new()
			item.name = item_name
			
			# SET ITEM REFERENCES
			var idx := 0
			for type in type_data:
				var var_name = type_data[type]["var_name"]
				item.set(var_name,combination[idx])
				idx+=1 
			
			# SAVE ITEM
			ResourceSaver.save(item_path,item)
	Content.reload_data_for(name)
	
func child_type_names():
	return Content.child_type_names(name)

func custom_editor():
	# Editor to replace default editor in data management
	return load("res://Game/Editors/{type}/Editor.tscn".format({"type":name}))

func custom_additional_editor():
	# Editor to append to default editor in data management
	return load("res://Game/Editors/{type}/AddEditor.tscn".format({"type":name}))
