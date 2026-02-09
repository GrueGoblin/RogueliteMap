extends Node

## An autoload for managing and generating context scenes for content Resources

var cached_scene : PackedScene

const scenes_path = "res://{module}/Scenes/"
const editors_path = "res://{module}/Editors/"

const context_template = """
extends {BASE}

var {var_name} : {class_name} setget set_{var_name}

func _ready():
	#self.{var_name} = {class_name}.new()
	pass

func set_{var_name}(value : {class_name}):
	if {var_name}:
		{var_name}.disconnect("changed",self,"actualize")
	{var_name} = value
	{var_name}.connect("changed",self,"actualize")	
	actualize()
	
func actualize():
	# set scene values
	pass
"""
## Basic template for root of context scenes
# BASE is either Control or Node2D base context script

const secondary_context_template = """
var {var_name} : {class_name} setget set_{var_name}

func set_{var_name}(value : {class_name}):
	if {var_name}:
		{var_name}.disconnect("changed",self,"actualize_{var_name}")
	{var_name} = value
	{var_name}.connect("changed",self,"actualize_{var_name}")	
	actualize_{var_name}()
	
func actualize_{var_name}():
	# set scene values
	pass
"""
# ToDo make a single template that can be reused 
# for both main and secondary contexts

const singleton_selection_base = """
onready var {var_name}_selector = find_node("{var_subtype}Options")
onready var {var_name_pluralized} = Content.get_all("{var_subtype}")
"""

const singleton_selection_ready = """
	for {var_name} in {var_name_pluralized}:
		{var_name}_selector.add_item({var_name}.name)
		{var_name}_selector.connect("item_selected",self,"select_{var_name}")
"""

const singleton_selection_setter = """
func select_{var_name}(index):
	character.{var_name} = {var_name_pluralized}[index]
"""

func load_context(context_class : String, context_name : String, module := "Game"):
	var path = scenes_path.format({"module" : module})+context_class+"/"+context_name+".tscn"
	print(path)
	cached_scene = load(path)
	return cached_scene

func instance_context(context_class : String, context_name : String, module := "Game"):
	load_context(context_class, context_name,module)
	if cached_scene:
		return cached_scene.instance()
	else:
		return null

func generate_context(context_class : String, base : String, context_name : String, editor := false, module := "Game", secondaries := []):
	var base_path = scenes_path
	if editor:
		base_path = editors_path
	var path = base_path.format({"module":module}) + context_class + "/" #+ context_name + ".gd"
	Directory.new().make_dir_recursive(path)
	# generate script
	var file = File.new()
	var file_path = path + context_name + ".gd"
	file.open(file_path,File.WRITE)
	file.store_line(context_template.format({
		"BASE" : base,
		"var_name" : Content.pascal_to_snake(context_class),
		"class_name" : context_class
	}))
	
	for secondary in secondaries:
		file.store_line(secondary_context_template.format({
			"var_name" : Content.pascal_to_snake(secondary),
			"class_name" : secondary
		}))
	
	file.close()
	# generate packed scene
	var node = ClassDB.instance(base) as Node
	node.add_to_group(context_class+"Context",true)
	#var node = load(file_path).new() as Node
	var scene = PackedScene.new()
	node.set_script(load(file_path))
	scene.pack(node)
	ResourceSaver.save(path + context_name +".tscn", scene)
	pass

func path_for(context_class : String, base : String, context_name : String, module := "Game"):
	return scenes_path.format({"module":module}) + context_class + "/" + context_name + ".tscn"

func check_texture_placeholder(texture : Texture):
	return texture.resource_path.split("/")[-1] == "placeholder.png"


# Called when the node enters the scene tree for the first time.
func _ready():
	var item = Resource.new()
	
	# test_check_texture_placeholder()
	# test OK
	pass

func test_check_texture_placeholder():
	print("Checking function check_texture_placeholder()")
	var texture1 = load("res://Game/graphics/FacePattern/face_base/placeholder.png")
	print("Expecting true")
	print(check_texture_placeholder(texture1))
	var texture2 = load("res://Game/graphics/MagicalInvasion.png")
	print("Expecting false")
	print(check_texture_placeholder(texture2))
	
