@tool

extends MeshInstance3D

@export var width: int = 100:
	set(w):
		width = w
		update()

@export var height: int = 100:
	set(h):
		height = h
		update()

@export var rng_seed: int = 0:
	set(v):
		rng_seed = v
		update()
		
@export_tool_button("Update") var update_action = update

func update():
	if not is_node_ready():
		return   # setters fire during scene load, before children exist

	var plane = mesh as PlaneMesh
	var updated_size = Vector2(width, height)
	if plane.size != updated_size:
		plane.size = updated_size

	var img = Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	for y in height:
		for x in width:
			var noiseV = PerlinNoise2D.noise(x * 0.05, y  * 0.05, 0.0, rng_seed)
			img.set_pixel(x, y, Color.WHITE.lerp(Color.BLACK, noiseV))
	var texture = ImageTexture.create_from_image(img)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # show raw values, no lighting
	#mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material_override = mat
