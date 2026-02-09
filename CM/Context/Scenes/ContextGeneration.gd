extends PanelContainer

var context_type : String setget set_context_type
var context_name : String
var root_node : String
var class_list : PoolStringArray

var editor := false

var secondary_contexts := Array()
# items that have variable setters
# and optionally "actualize_" + var_name methods

var search_cache := Dictionary()

var context_creator = load("res://CM/Context/Context.gd").new()


onready var secondary_context_type_selector = $TypeConfirmationDialog/VBoxContainer/TypeOptions as OptionButton
onready var secondary_contexts_list = $Content/SecondaryContexts as VBoxContainer

func set_context_type(value : String):
	context_type = value
	$Content/Label.text = "Generate context for {context_type}".format({"context_type" : context_type})

func _ready():
	class_list = ClassDB.get_inheriters_from_class("Node")
	for type in Content.get_all_content_names():
		$TypeConfirmationDialog/VBoxContainer/TypeOptions.add_item(type)
		pass


func _on_RootName_text_changed(new_text):
	root_node = new_text
	$Content/RootUI.clear_suggestions()
	if root_node == "":
		$Content/RootUI.show_default_suggestions()
	else:
		var results = get_results(new_text)
		for result in results:
			$Content/RootUI.add_suggestion(result)

func get_results(term : String, amount = 3):
	var results = Array()
	term = term.to_lower()
	if search_cache.has(term):
		return search_cache[term]
	else:
		search_cache[term] = []
	for c_name in class_list:
		if term in c_name.to_lower():
			search_cache[term].push_back(c_name)
			results.push_back(c_name)
			if results.size()==amount:
				return results
	return results

func show_error(message : String):
	$Content/ErrorLabel.show()
	$Content/ErrorLabel.text = message
	$Content/ErrorLabel/ErrorTimer.start()

func _on_ErrorTimer_timeout():
	$Content/ErrorLabel.hide()


func _on_LineEdit_text_changed(new_text):
	context_name = new_text


func _on_CreateContext_pressed():
	#print(context_creator.path_for(context_type,root_node,context_name))
	var errors := []
	if !context_name || context_name == "":
		errors.append("You have to specify the context name.")
	if !context_type:
		errors.append("You have to specify the context type.")
	if !root_node || Array(class_list).find(root_node) == -1:
		errors.append("You have to specify a valid Node for a scene parent.")
	if Directory.new().file_exists(context_creator.path_for(context_type,root_node,context_name)):
		errors.append("The context of specified name already exists for {context_type}.".format({"context_type" : context_type}))
	if errors.empty():
		context_creator.generate_context(context_type, root_node, context_name, editor, "Game", secondary_contexts)
	else:
		show_error(PoolStringArray(errors).join("\n"))


func _on_EditorCheckBox_toggled(button_pressed):
	editor = button_pressed


func _on_AddSecondaryContext_pressed():
	$TypeConfirmationDialog.popup()
	pass # Replace with function body.


func _on_TypeConfirmationDialog_confirmed():
	var type_name = secondary_context_type_selector.get_item_text(secondary_context_type_selector.selected)
	secondary_contexts.append(type_name)
	var new_label = Label.new()
	new_label.text = type_name
	secondary_contexts_list.add_child(new_label)
	print(secondary_contexts)
	pass # Replace with function body.


func _on_ClearSecondaryContextsButton_pressed():
	secondary_contexts.clear()
	for child in secondary_contexts_list.get_children():
		child.queue_free()
