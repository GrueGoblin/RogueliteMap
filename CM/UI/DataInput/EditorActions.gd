extends HBoxContainer


signal save
signal rename
signal delete


func _on_SaveButton_pressed():
	emit_signal("save")


func _on_RenameButton_pressed():
	emit_signal("rename")


func _on_DeleteButton_pressed():
	emit_signal("delete")

func activate_save(active = true):
	$SaveButton.disabled = !active
