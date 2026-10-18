@tool

extends Line2D

@export var length: int = 500:
	set(l):
		length = l
		update()

@export var x_multiplier: int = 100:
	set(v):
		x_multiplier = v
		update()
		
@export var y_multiplier: int = 100:
	set(v):
		y_multiplier = v
		update()

@export var rng_seed: int = 0:
	set(v):
		rng_seed = v
		update()
		
@export_tool_button("Update") var update_action = update

func update():
	if not is_node_ready():
		return   # setters fire during scene load, before children exist
	if points.size() > 0:
		clear_points()

	for i in length:
		add_point(Vector2(i * x_multiplier, PerlinNoise.noise_1d(i * 0.05, rng_seed) * y_multiplier))
