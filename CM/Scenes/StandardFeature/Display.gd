extends Button

var standard_feature : StandardFeature setget set_standard_feature

func set_standard_feature(value):
	standard_feature = value
	text = standard_feature.field_name
	hint_tooltip = standard_feature.description
