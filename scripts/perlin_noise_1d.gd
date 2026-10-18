class_name PerlinNoise

static func noise_1d(x: float, rng_seed: int = 0) -> float:
	# --- Setup: build the slope for every grid point ---
	# The numbers 0..255, one per slot, in order.
	var unshuffled_grid = _get_unshuffled_grid()
	# Shuffle them with Fisher–Yates. The seed makes the shuffle repeatable:
	# same seed -> same order -> same terrain.
	var grid = FisherYates.shuffle(unshuffled_grid, rng_seed)
	# Turn each shuffled value (0..255) into a slope (-1..1) with (h / 255) * 2 - 1.
	# slopes[i] is now the slope of grid point i.
	var slopes = _get_slopes(grid)

	# --- Find where x sits on the grid ---
	# The grid point at or to the left of x (e.g. x = 2.3 -> 2).
	# floori rounds down, so negatives work too (x = -0.4 -> -1).
	var left: int = floori(x)
	# The next grid point to the right (e.g. 3).
	var right: int = left + 1
	# How far x is past the left point, from 0 to 1 (e.g. 2.3 -> 0.3).
	var distance = x - left

	# --- Each grid point's guess ---
	# Every grid point is a ramp that passes through height 0, tilted at its slope.
	# A guess is "how high would that ramp be at x?" = slope * distance from the point.
	#
	# `& 255` wraps the grid point into a valid slot (0..255), so any x works,
	# including negatives and x >= 256. The pattern repeats every 256 units.
	#
	# Left point: x is `distance` to its right, so the distance is positive.
	var left_guess = slopes[left & 255] * distance
	# Right point: x is (1 - distance) to its LEFT, so the distance is negative: (distance - 1).
	# At distance = 1 this is 0, which makes each segment end at height 0.
	var right_guess = slopes[right & 255] * (distance - 1)

	# --- Blend the two guesses ---
	# Fade curve 6t^5 - 15t^4 + 10t^3: an S-shaped weight that goes 0 -> 1.
	# It starts and ends flat, so there's no kink at grid points and each point
	# keeps exactly its chosen slope.
	var fade = 6 * pow(distance, 5) - 15 * pow(distance, 4) + 10 * pow(distance, 3)
	# Slide from the left guess to the right guess by `fade`:
	# fade = 0 -> all left guess, fade = 1 -> all right guess, 0.5 -> halfway.
	# The result stays roughly within -0.5..0.5; multiply by an amplitude for height.
	var noise = left_guess + fade * (right_guess - left_guess)

	return noise

static func _get_slopes(grid: PackedByteArray) -> PackedFloat32Array:
	var points = PackedFloat32Array()
	points.resize(grid.size())
	var max_value = 255
	for i in points.size():
		var n = grid[i]
		var safe_division = 0.0 if n == 0 else float(n) / max_value
		
		points[i] = safe_division * 2 - 1
	
	return points

static func _get_unshuffled_grid() -> PackedByteArray:
	var unshuffledGrid = PackedByteArray()
	unshuffledGrid.resize(256)
	
	for n in 256:
		unshuffledGrid[n] = n
	
	return unshuffledGrid
