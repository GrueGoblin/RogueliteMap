extends Node
## Core Content autoload managing the game data


# ToDo: load existing generators on start
# Rework generate method to work with these instead of attempting to load them on call
var generators := {}

var content = preload("res://CM/ContentData.gd")
var script_writer := ScriptWriter.new()
var localizer = preload("res://CM/Localization/Localizer.gd").new()
var ct_resource = preload("res://CM/Resources/ContentType.gd")
var ct_field_resource = preload("res://CM/Resources/ContentTypeField.gd")
var resource_encryptor := load("res://CM/ResourceEncryptor.gd").new() as ResourceEncryptor
var model_to_edit : Resource
var selected_filter : String
# filter last selected for Content Management Menu
# perhaps move these helper variables, not needed for the content itself
# to an extra autoload object 
var data_to_edit : String
var subresource_of := ""
var rng = RandomNumberGenerator.new()
var groups := Array()

var sorting_property : String

const data_path = "res://Game/Data/"
const model_path = "res://Game/Models/"
const scenes_path = "res://Game/Scenes/"
const meta_model_path = "res://Game/Models/Meta/"
const model_definitions_path = "res://Game/Models/Definitions/"
const sub_model_path = "res://Game/Models/Sub/"
const palettes_path = "res://Game/Graphics/Palettes/"
const generator_path = "res://Game/Generators/"

const groups_path = "res://Game/Models/Groups/"

const content_types = ["Singleton","Instanced"]



func _ready():
	localizer.load_all_translations()
	randomize()
	rng.randomize()
	load_data()
	load_groups()
	
	preload_generators()
	
	test()

func preload_generators():
	var file := File.new() 
	for content_name in get_all_content_names():
		var path = generator_path+content_name+".gd"
		if file.file_exists(path):
			generators[content_name] = load(path)

func get_all_content_names():
	var names := Array()
	for c in get_children():
		names.push_back(c.name)
	return names

func test():
	pass


func generate_named_content(type_name : String):
	# generate non-exising items from named resources
	var definition = load_definition(type_name) as ContentType
	var existing_item_names = get_all(type_name,"name")
	var named_resources_names := Array()
	var type_script = load_script(type_name)
	var items := Array()
	print("Setup done")
	for field in definition.fields_filtered("Named Resource"):		
		field = field as ContentTypeField
		print("Iterating fields: "+field.var_name)
		var path = field.default_value.format({"type":type_name,"variable":field.var_name}).get_base_dir()
		var directory = Directory.new()
		var err = directory.open(path)
		if err == 0:
			directory.list_dir_begin(true)
			filename = directory.get_next()
			while filename != "":
				print(filename)
				#add new name from resource name
				var item_name = filename.split(".")[0]
				# skip ToDo
				if !named_resources_names.has(item_name) && !existing_item_names.has(item_name) && !["ToDo","placeholder"].has(item_name):
					named_resources_names.push_back(item_name)
				filename = directory.get_next()
			directory.list_dir_end()
	for item_name in named_resources_names:
		var new_item = type_script.new()
		new_item.name = item_name
		ResourceSaver.save(definition.data_path()+item_name+".tres",new_item)
		items.push_back(new_item)
	return items

func combine(array1 : Array, array2: Array):
	# combines elements between two arrays of arrays
	# if an empty array is passed as array1, it simply returns an array 
	# encapsuling array2 values
	var combinations := Array()
	if array1.empty():
		for item in array2:
			combinations.push_back([item])
	else:
		#var new_combinations := Array()
		for item in array2:
			for arr in array1:
				var new_combination = arr.duplicate()
				new_combination.append(item)
				combinations.push_back(new_combination)
	return combinations

func get_palette_names():
	var names = []
	var dir := Directory.new()
	# ToDo implement palettes at all
	return names

func recreate_meta_model(type_name : String):
	var definition = load_definition(type_name)
	create_content_type(definition,false)

func seek_and_destroy_all_relations_to(related_type : String):
	for c in get_children():
		var definition = load_definition(c.name)
		if definition.relations.erase(related_type):
			definition.save()	

func add_relations_to_definition(host_type_name : String, related_type_name : String, key_variable_names : Array):
	var definition = load_definition(host_type_name)
	definition.relations[related_type_name] = []
	for var_name in key_variable_names:
		var relation = ContentRelation.new()
		relation.rel_resource_type = related_type_name
		relation.key_variable_name = var_name
		definition.relations[related_type_name].push_back(relation)
	ResourceSaver.save(definition.resource_path,definition)
	recreate_meta_model(host_type_name)

func create_content_type(type_resource : ContentType, is_new : bool):
	# create model, metamodel and relations definitions
	var inherits := "res://CM/Resources/ActiveRecord.gd"#"Resource"
	if type_resource.inherits != "":
		inherits = type_resource.inherits
	script_writer.write_script(meta_model_path,type_resource.name+".gd",inherits,type_resource.var_lines())
	if is_new:
		script_writer.write_script(model_path,type_resource.name+".gd",'"'+meta_model_path+type_resource.name+'.gd"',PoolStringArray([]),true,type_resource.name)
		# create directory for content data
	var path = data_path
	if type_resource.singleton:
		path += "Singleton/"
	else:
		path += "Instanced/"
	script_writer.find_or_create_directory(path + type_resource.name)
	script_writer.find_or_create_directory(model_definitions_path)
	ResourceSaver.save(model_definitions_path+type_resource.name+".tres",type_resource)
	if is_new:
		append_type(type_resource.name,type_resource.singleton)
		connect_child_types()
	#create directories for named resources
	for f in type_resource.fields:
		if f.var_type == "Named Resource":
			script_writer.find_or_create_directory(f.named_path_formatted(type_resource.name).split("{")[0])
	
	# create relations on singletons referenced by "Singleton Reference"
	var data = type_resource.data_for_relations()
	for type_name in data:
		add_relations_to_definition(type_name,type_resource.name,data[type_name])
	
func connect_child_types():
	for c in get_children():
		c.child_types.clear()
	for c in get_children():
		var parent_name = c.definition.inherits
		while parent_name != "":
			var parent_node = get_node(parent_name)
			parent_node.child_types.append(c)
			parent_name = parent_node.definition.inherits

func append_type(type_name : String, singleton : bool):
	var c = content.new()
	c.name = type_name
	c.singleton = singleton
	c.definition = load_definition(type_name)
	add_child(c)
	
# Language functions
# ToDo: Make an extra autoload for these, which will be set automatically by Content
func pascal_to_snake(string : String) -> String:
	var regex := RegEx.new()
	regex.compile("([A-Z][a-z0-9]+)")
	var results := regex.search_all(string)
	#print(results)
	var parts := []
	for result in results:
		parts.push_back(result.strings[0].to_lower())
	return PoolStringArray(parts).join("_")

func humanize(string : String) -> String:
	var regex := RegEx.new()
	regex.compile("([A-Z][a-z0-9]+)")
	var results := regex.search_all(string)
	#print(results)
	var parts := []
	for result in results:
		parts.push_back(result.strings[0])
	return PoolStringArray(parts).join(" ")

func pluralize(string : String) -> String:
	for end in ["s","ss","z","x","ch","sh"]:
		if string.ends_with(end):
			return "{string}es".format({"string" : string})
	return "{string}s".format({"string" : string})

func content_type_exists(type_name : String):
	# check if content node exists
	if get_node(type_name):
		return true
	return false
	
func reload_data_for(content_type_name : String):
	get_node(content_type_name).load_data()

func find(type, name, include_children = true):
	if !content_type_exists(type):
		printerr("Content type "+type+" doesn't exist!")
		return null
	var c_data = get_node(type)
	return c_data.find(name,include_children)

func sort_by_property(a,b):
	return a.get(sorting_property) < b.get(sorting_property)

func get_all_filtered(type, filters : Dictionary, sort_by := ""):
	# TODO use this function for reverse relation of sigleton reference
	var content := []
	for item in get_all(type):
		var add := true
		for property in filters:
			if item.get(property) != filters[property]:
				add = false
				continue
		if add:
			content.append(item)
	if sort_by != "":
		sorting_property = sort_by
		content.sort_custom(self, "sort_by_property")
		
	#content.sort()
	return content

func find_by(type, filters : Dictionary):
	# similar to get all filtered
	# returns first item matching criteria,
	# or null iif no matches are found
	var results := get_all_filtered(type,filters) as Array
	if results.size() > 0:
		return results[0]
	else:
		return null
	
func destroy_content_type(type_name):
	var path = get_node(type_name).data_path()
	# destroy content data
	var dir := Directory.new()
	dir.open(path)
	dir.list_dir_begin(true)
	var filename = dir.get_next()
	while filename != "":
		dir.remove(filename)
		filename = dir.get_next()
	dir.list_dir_end()
	#print(dir.dir_exists(path))
	dir.remove(path)
	# destroy content model(s)
	dir.remove(model_path+type_name+".gd")
	dir.remove(meta_model_path+type_name+".gd")
	# destroy content submodels
	
	# destroy content type definitions
	dir.remove(ProjectSettings.globalize_path(model_definitions_path+type_name+".tres"))
	# Sreload_menu()
	get_node(type_name).queue_free()
	
	# destroy all relations in model definitions
	seek_and_destroy_all_relations_to(type_name)

func destroy_item(content_type: String, item_name: String):
	get_node(content_type).delete_item(item_name)
	
func rename_item(content_type: String, item_name: String, new_name: String):
	var definition = load_definition(content_type) as ContentType
	# find item
	var old_item := find(content_type,item_name) as Resource
	# duplicate item
	var new_item = old_item.duplicate()
	new_item.name = new_name
	# delete old file
	destroy_item(content_type,item_name)
	var dir := Directory.new()
	dir.remove(old_item.resource_path)
	
	# save new file
	var path = definition.data_path()
	ResourceSaver.save(path+new_name+".tres",new_item)

func transfer_item(type1 : String, type2 : String, item_name : String):
	# Use this to transfer content items to a subtype
	var definition1 = load_definition(type1) as ContentType
	var definition2 = load_definition(type2) as ContentType
	# OPT: check if type2 is subtype of type1
	# find the old item
	var old_item = find(type1, item_name) as Resource
	# create new item
	var new_item = load_script(type2).new() as Resource
	# copy all attributes from the old item to the new item
	for field in definition1.fields:
		field = field as ContentTypeField
		new_item.set(field.var_name, old_item.get(field.var_name))
	# destroy old item
	destroy_item(type1,item_name)
	# save new item to path by a new type definition
	var path = definition2.data_path()
	ResourceSaver.save(path+item_name+".tres",new_item)

func get_all(content_type: String, property := "", sort_by := "", include_children = true):
	var data = get_node(content_type).get_all(include_children)
	var content : Array
	if property == "":
		content = data.values()
	else:
		content = []
		for item in data.values():
			content.append(item.get(property))
			
	if sort_by != "":
		sorting_property = sort_by
		content.sort_custom(self, "sort_by_property")
		
	elif content.size() > 0 && typeof(content[0]) == TYPE_OBJECT && content[0].get("order") != null:
		sorting_property = "order"
		content.sort_custom(self, "sort_by_property")
	
	# if items are from instanced content, return array of duplicates
	var def := load_definition(content_type) as ContentType
	if !def.singleton && property == "":
		var all := Array()
		for item in content:
			all.push_back(item.duplicate())
			pass
		return all
	return content

func all_groups_names():
	var groups := Array()
	for c in get_children():
		if c.definition.group:
			pass
		
		pass
	pass

func all_type_names():
	var result = []
	for c in get_children():
		result.append(c.name)
	return result

func all_singleton_names():
	var result = []
	for c in get_children():
		if c.singleton:
			result.append(c.name)
	return result

func all_instanced_names():
	var result = []
	for c in get_children():
		if !c.singleton:
			result.append(c.name)
	return result

func generate(type : String, params:={}):
	# attempts to find custom generator in Game/Generators and generate the content type instance(s) by it
	#print(all_type_names())
	#print(generators)
	
	var gen = generator_for(type)
	if gen:
		var result = gen.new().generate(params)
		return result
	else:
		return get_random(type)

func get_random(type : String, weighted = true):
	var all := get_all(type) as Array
	if weighted && all.size() > 0 && all[0].get("weight"):
		print("returning random weighted item")
		var total := 0.0
		var counter := 0.0
		for item in all:
			total += item.weight
		var roll = rand_range(0,total)
		for item in all:
			counter += item.weight
			if counter >= roll:
				return item
	# singleton reference with no content throws error due placeholder example
	if all.size() > 0:
		all.shuffle()
		return all[0]
	return null

func generator_for(type : String):
	return generators.get(type)
	
func create_generator(type : String):
	var def = load_definition(type)
	script_writer.write_script(generator_path,type+".gd","Object",[def.generator_boilerplate()],true)

func load_definition(type_name : String):
	return load(model_definitions_path+type_name+".tres")

func path_for_item(type_name : String, item_name : String):
	var definition = load_definition(type_name) as ContentType
	return definition.path_for(item_name)
	
func load_script(type_name : String):
	return load(model_path+type_name+".gd")

func load_data():
	for child in get_children():
		child.deleted = true
		child.queue_free()
	
	var dict := Directory.new()
	if dict.dir_exists(model_definitions_path):
		dict.open(model_definitions_path)
		dict.list_dir_begin(true)
		var file_name = dict.get_next()
		
		while file_name != "":
			var definition := load(model_definitions_path+file_name) as ContentType
			append_type(definition.name,definition.singleton)
			file_name = dict.get_next()
	connect_child_types()
	print("DATA LOADED")

func reload_menu():
	get_tree().change_scene("res://CM/UI/Menu.tscn")

func generate_todo_lists(type_name : String):
	get_node(type_name).generate_todo_lists()
	
func create_group(group_name : String):
	var group = load("res://CM/Resources/Group.gd").new()
	group.name = group_name
	script_writer.find_or_create_directory(groups_path)
	ResourceSaver.save(groups_path+group_name+".tres",group)
	groups.append(group)
	return group
	
func load_groups():
	var dict := Directory.new()
	if dict.dir_exists(groups_path):
		dict.open(groups_path)
		dict.list_dir_begin(true)
		var file_name = dict.get_next()		
		while file_name != "":
			var group = load(groups_path+file_name)
			groups.append(group)
			file_name = dict.get_next()

func path_for(type : String):
	var definition = load_definition(type) as ContentType
	return definition.data_path()

func get_all_filenames(dir_path):
	var names := PoolStringArray()
	var dir := Directory.new()
	if dir.dir_exists(dir_path):
		dir.open(dir_path)
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			var filename = dir_path+file_name
			names.append(filename)
			file_name = dir.get_next()
	return names

func load_all_files(dir_path):
	var item_list := Array()
	for filename in get_all_filenames(dir_path):
		item_list.push_back(load(filename))
	return item_list

func check_type(type : String):
	if get_node(type):
		return true
	return false

func child_types(type : String):
	if check_type(type):
		return get_node(type).child_types #returns nodes, need names
	else:
		return null
		
func child_type_names(type : String):
	var result := Array()
	for child_type in child_types(type):
		result.append(child_type.name)
	return result
