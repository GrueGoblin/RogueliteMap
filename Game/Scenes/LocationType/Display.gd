
extends Sprite

var location_type : LocationType setget set_location_type

func _ready():
	#self.location_type = LocationType.new()
	pass

func set_location_type(value : LocationType):
	if location_type:
		location_type.disconnect("changed",self,"actualize")
	location_type = value
	location_type.connect("changed",self,"actualize")	
	actualize()
	
func actualize():
	texture = location_type.icon
	# set scene values
	pass

