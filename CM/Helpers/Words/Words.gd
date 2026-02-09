extends Node

func pascal_to_snake(string : String) -> String:
	var regex := RegEx.new()
	regex.compile("([A-Z][a-z0-9]+)")
	var results := regex.search_all(string)
	#print(results)
	var parts := []
	for result in results:
		parts.push_back(result.strings[0].to_lower())
	return PoolStringArray(parts).join("_")
	
func humanize(string : String) -> String:
	var regex := RegEx.new()
	regex.compile("([A-Z][a-z0-9]+)")
	var results := regex.search_all(string)
	#print(results)
	var parts := []
	for result in results:
		parts.push_back(result.strings[0])
	return PoolStringArray(parts).join(" ")

func pluralize(string : String) -> String:
	for end in ["s","ss","z","x","ch","sh"]:
		if string.ends_with(end):
			return "{string}es".format({"string" : string})
	if string.ends_with("y"):
		return "{string}ies".format({"string" : string.substr(0,string.length()-1)})
	return "{string}s".format({"string" : string})
	
func sentencize(string : String, ending := "."):
	# turns a string into a sentence with preferred ending
	
	return string[0].capitalize() + string.substr(1) + ending
	pass
