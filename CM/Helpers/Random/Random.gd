extends RandomNumberGenerator

func choose_by_percent():
	# Accepts list of weighted choices
	# key = item, value = weights
	# sum of values is supposed to be lesser than 100
	# if the roll is higher, returns null
	pass

func choose( choices : Dictionary, count = 1, repeated = false ):
	# Accepts list of weighted choices
	# key = item, value = weights
	# returns an array of chosen items if count > 1
	# otherwise returns a single item
	# repeated parameter determines whether duplicate items are allowed in result
	var result = Array()
	var total = 0
	for value in choices.values():
		total += value	
#	var fraction = 100.0/total
	while result.size() < count && choices.size() > 0:
		var roll = randi() % total
#		print("Rolled "+str(roll)+" from total "+str(total))
		
		var subtotal = 0
		for i in choices.values().size():
			subtotal += choices.values()[ i ]
			if roll < subtotal:
				var choice = choices.keys()[ i ]
				result.append(choice)
#				print(str(choice)+" was chosen from "+str(choices))
#				print("Chance was "+str(fraction * choices[choice])+"% Subtotal reached was "+str(subtotal))
				if !repeated:
					total -= choices[ choice ]
#					fraction = 100.0/total
					choices.erase(choice)
				break
	if count == 1:
		if result.empty():
			return null
		else:
			return result[ 0 ]
	return result
