extends Label


export var key := "A" setget set_key

export var fill_speed := 1

export var hold = true setget set_hold

onready var progress = $TextureProgress

var held = false

signal filled
# Called when the node enters the scene tree for the first time.
func _ready():
	progress.visible = hold
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hold:
		if Input.is_key_pressed(OS.find_scancode_from_string(key)) || held:
			progress.value += fill_speed
		else:
			progress.value -= fill_speed
	elif Input.is_key_pressed(OS.find_scancode_from_string(key)) || held:
		done()
		
func set_key(value):
	key = value
	text = key

func set_hold(value):
	hold = value
	if progress:
		progress.visible = hold

func done():
	emit_signal("filled")
	print("Done")

func _on_TextureProgress_value_changed(value):
	print(progress.value)
	print(progress.max_value)
	if progress.value == progress.max_value:
		done()


func _on_Button_button_down():
	held = true

func _on_Button_button_up():
	held = false
