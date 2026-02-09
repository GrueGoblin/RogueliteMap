extends HBoxContainer

signal value_changed(val)

var value := Vector2() setget set_value


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_XSpinBox_value_changed(value):
	actualize()
	
func set_value(val : Vector2):
	value = val
	$XSpinBox.value = value.x
	$YSpinBox.value = value.y


func _on_YSpinBox_value_changed(value):
	actualize()

func actualize():
	value = Vector2($XSpinBox.value,$YSpinBox.value)
	emit_signal("value_changed",value)
