class_name PerlinNoise2D

static var _permutation: PackedByteArray
static var _last_seed: int = 0

static func noise(x: float, y: float = 0.0, z: float = 0.0, rng_seed: int = 0) -> float:
	if _permutation.size() == 0 or _last_seed != rng_seed:
		_permutation = _get_grid(rng_seed)
	
	# Which unit cube axis is in (0..255)
	var xi = floori(x) & 255
	var yi = floori(y) & 255
	var zi = floori(z) & 255
	
	# Unit cube distance to unit cube [0..1]
	var xf: float = x - xi
	var yf: float = y - yi
	var zf: float = z - zi
	
	# Smoothly fade the distance
	var u = _fade_distance(xf)
	var v = _fade_distance(yf)
	var w = _fade_distance(zf)
	
	# Hash all eight corners of the unit cube
	# Naming: a = lower coordinate, b = upper, in x-y-z order.
	var aaa = _hash_corner(xi, yi, zi)
	var aba = _hash_corner(xi, yi + 1, zi)
	var aab = _hash_corner(xi, yi, zi + 1)
	var abb = _hash_corner(xi, yi + 1, zi + 1)
	var baa = _hash_corner(xi + 1, yi, zi)
	var bba = _hash_corner(xi + 1, yi + 1, zi)
	var bab = _hash_corner(xi + 1, yi, zi + 1)
	var bbb = _hash_corner(xi + 1, yi + 1, zi + 1)
	
	# get the dot product of the corner's gradient with the
  	# vector from that corner to our point. Blend along x, then y, then z.
	var bottom_front_edge = _blend_edge(aaa, baa, Vector3(xf, yf, zf), Vector3(xf - 1, yf, zf), u)
	var top_front_edge = _blend_edge(aba, bba, Vector3(xf, yf - 1, zf), Vector3(xf - 1, yf - 1, zf), u)
	var front_face = _lerp(bottom_front_edge, top_front_edge, v)
	
	var bottom_back_edge = _blend_edge(aab, bab, Vector3(xf, yf, zf - 1), Vector3(xf - 1, yf, zf - 1), u)
	var top_back_edge = _blend_edge(abb, bbb, Vector3(xf, yf - 1, zf - 1), Vector3(xf - 1, yf - 1, zf - 1), u)
	var back_face = _lerp(bottom_back_edge, top_back_edge, u)

	var raw_noise = _lerp(front_face, back_face, w)

	# Raw range is about [-1, 1]; remap to [0, 1].
	return (raw_noise + 1) / 2
	
static func _gradient(hashed: int, x: float, y: float, z: float) -> float:
	match hashed & 0xF:
		0x0: return x + y # gradient ( 1, 1, 0)
		0x1: return x + y # gradient (-1, 1, 0)
		0x2: return x - y # gradient ( 1,-1, 0)
		0x3: return x - y # gradient (-1,-1, 0)
		0x4: return x + z # gradient ( 1, 0, 1)
		0x5: return x + z # gradient (-1, 0, 1)
		0x6: return x - z # gradient ( 1, 0,-1)
		0x7: return x - z # gradient (-1, 0,-1)
		0x8: return y + z # gradient ( 0, 1, 1)
		0x9: return y + z # gradient ( 0,-1, 1)
		0xA: return y - z # gradient ( 0, 1,-1)
		0xB: return y - z # gradient ( 0,-1,-1)
		0xC: return y + x # repeat of ( 1, 1, 0)
		0xD: return y + z # repeat of ( 0,-1, 1)
		0xE: return y - x # repeat of (-1, 1, 0)
		_: return -y - z  # 0xF, repeat of ( 0,-1,-1)

static func _blend_edge(corner_from: int, corner_to: int, from_cord: Vector3, to_cord: Vector3, t: float) -> float:
	var from_gradient = _gradient(corner_from, from_cord.x, from_cord.y, from_cord.z)
	var to_gradient = _gradient(corner_to, to_cord.x, to_cord.y, to_cord.z)
	
	return _lerp(from_gradient, to_gradient, t)

static func _hash_corner(x: int, y: int, z: int) -> int:
	return _permutation[_permutation[_permutation[x] + y] + z]

static func _lerp(from: float, to: float, t: float) -> float:
	#	Same as Godot's lerp
	return from + t * (to - from)

static func _fade_distance(t: float) -> float:
	# 6t^5 - 15t^4 + 10t^3, factored to save multiplications.
	# Eases t toward 0 near 0 and toward 1 near 1, smoothing the result.
	return t * t * t * (t * (t * 6 - 15) + 10)

static func _get_grid(rng_seed: int = 0) -> PackedByteArray:
	var unshuffledGrid = PackedByteArray()
	unshuffledGrid.resize(512)
	
	for n in 512:
		unshuffledGrid[n] = n & 255

	return FisherYates.shuffle(unshuffledGrid, rng_seed)
