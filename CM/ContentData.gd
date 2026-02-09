extends Node

#const model_definitions_path = "res://Game/Models/Definitions/"

var singleton := false
var user_content := false #whether the content is stored in usr:// (otherwise it is in res://)
var data :=  {}
var deleted := false
var definition : ContentType

var child_types := []

func _ready():
	load_data()
	
func delete_item(item_name : String):
	data.erase(item_name)

func data_path():
	var path : String
	if user_content:
		path = "usr://"
	else:
		path = "res://"
	path += "Game/Data/"
	if singleton:
		path += "Singleton/"
	else:
		path += "Instanced/"
	path += name
	return path

func load_data():
	var dir := Directory.new()
	var path = data_path()
	var err = dir.open(path)
	if err == 0:
		dir.list_dir_begin(true)
		var filename = dir.get_next()
		while filename != "":
			var item
			if definition.save_encrypted:
				item = ResourceEncryptor.new().load_encrypted(path+"/"+filename)
			else:
				item = load(path+"/"+filename)
				if !item:
					print("item {item} not loaded!".format({"item":filename}))
				
			#var item = load(path+"/"+filename)
			# ToDo: Fetch named resources and singleton references
			data[filename.split(".")[0]] = item
			filename = dir.get_next()

func get_all(include_children = true):
	var all := data.duplicate()
	if include_children:
		for child_type in child_types:
			for key in child_type.data:
				all[key] = child_type.data[key]
	return all

func find(inst_name, include_children = true):
	var child_type_result := false
	# singleton resources are referenced
	# instanced ones are duplicated
	#var inst = data[inst_name]
	var inst = data.get(inst_name)
	if !inst && include_children:
		# if data are not found here, an attempt to search in children is made
		child_type_result = true
		for child_type in child_types:
			inst = child_type.find(inst_name)
			if inst:
				break
	if singleton || child_type_result:
		# child type results are already duplicated
		return inst
	else:
		if inst:
			return inst.duplicate()
		else:
			return null
			
func generate_todo_lists():
	print("generating todos")
	var inst_names = Content.get_all(name,"name")
	print(inst_names)
	inst_names.push_front("placeholder")
	var directory = Directory.new()
	for field in definition.fields:
		if field.var_type == "Named Resource":
			var file := File.new()
			var filename_arr = field.default_value.split(".")
			print(field.default_value)
			filename_arr[-1] = "txt"
			var filename = filename_arr.join(".")
			var filepath = filename.format({"type" : name,"variable" : field.var_name, "name" : "ToDo"})
			print(file.open(filepath, File.WRITE))
			for inst_name in inst_names:
				var path = field.default_value.format({"type" : name,"variable" : field.var_name,"name" : inst_name})
				if !directory.file_exists(path):
					file.store_line(path.split("/")[-1]+"\r")
					print(path.split("/")[-1]+"\r")
			file.close()
			
