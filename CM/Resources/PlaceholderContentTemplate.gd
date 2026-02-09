extends Resource

class_name PlaceholderContentTemplate

export var use_content_type_name := true
# whether to use Content type name in all generated items or not
export var references_blacklist := Array()
# Use all references by default
# Put them here to ignore them
export var prefixes := Dictionary()
# Key = variable name, value = prefix string
export var sufix := ""
# Sufix to placeholder content name
export var copies := 1
# How many numbered copies should be generated
# 1 means there is no need for enumeration
"""
references_used, prefix, copies
"""

func example_name(definition):
	
	pass
