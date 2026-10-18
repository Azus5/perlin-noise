class_name FisherYates

static func shuffle(unshuffled: PackedByteArray, rng_seed: int = 0) -> PackedByteArray:
	var shuffled = PackedByteArray(unshuffled)
	
	#	Fisher-Yates Shuffle
	var gridSize = shuffled.size()
	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	for i in gridSize - 1:
		var randomIndex = rng.randi_range(i, gridSize - 1)
		if randomIndex == i:
			continue
		
		var random = shuffled[randomIndex]
		var current = shuffled[i]

		shuffled[i] = random
		shuffled[randomIndex] = current
	
	return shuffled
