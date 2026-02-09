extends Resource

func load_named_resources():
	var props = get_property_list()
	# To decide:
	# 1:
	# ========
	# iterate through named properties
	# these are prepended "nam_"
	# last part of the name
	# 2: +++
	# ========
	# Have a dictionary of named resources defined in model
	# key = name of the named property
	# value = [ 0: formatted path to target resource dictionary,
	#			1: Resource type, (this can be possibly read from property??)
	#			2: Resource name suffix]
	# load the resource at the given path
	# ie. if formatted path is "Graphics/Content/Tower/Turrets/"
	# key is "turret"
	# resource type == Texture 
	# resource name suffix == "_tur"
	# And the name of this ContentItem is "Arrow"
	# Then it loads a resource at "res://Graphics/Content/Tower/Turrets/Arrow_tur.png",
	# storing it in instance variable turret 
	pass
