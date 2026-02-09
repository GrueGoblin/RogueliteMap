extends HBoxContainer

func _ready():
	for button in $Suggestions.get_children():
		button.connect("pressed",self,"_on_SuggestionButton_pressed",[button.text])

func _on_SuggestionButton_pressed(new_text):
	$RootName.text = new_text
	$RootName.emit_signal("text_changed",new_text)
	pass # Replace with function body.

func show_default_suggestions():
	for child in $Suggestions.get_children():
		if suggestion_default(child):
			child.show()

func suggestion_default(suggestion : Button):
	return "Default" in suggestion.name

func clear_suggestions():
	for child in $Suggestions.get_children():
		if !suggestion_default(child):
			child.queue_free()
		else:
			child.hide()

func add_suggestion(term : String):
	var button = Button.new()
	button.text = term
	button.connect("pressed",self,"_on_SuggestionButton_pressed",[button.text])
	button.name = term
	$Suggestions.add_child(button)
	
