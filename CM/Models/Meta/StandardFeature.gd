extends Resource

export var field_name : String
export var field_type : String
export var field_subtype : String
export var description : String

func instance_as(context_name : String):
	var scene = load("res://CM/Scenes/StandardFeature/" + context_name + ".tscn" ).instance()
	scene.standard_feature = self
	return scene
