class_name MaterialHelper

static var _stone_mat = null
static var _player_mat = null

static func get_stone_material() -> StandardMaterial3D:
	if _stone_mat: return _stone_mat
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.4, 0.4)
	mat.roughness = 0.8
	
	var stone_noise = FastNoiseLite.new()
	stone_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	stone_noise.frequency = 0.05
	
	var stone_tex = NoiseTexture2D.new()
	stone_tex.noise = stone_noise
	stone_tex.seamless = true
	stone_tex.as_normal_map = true
	stone_tex.bump_strength = 2.0
	
	var stone_albedo = NoiseTexture2D.new()
	var albedo_noise = FastNoiseLite.new()
	albedo_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	albedo_noise.frequency = 0.02
	stone_albedo.noise = albedo_noise
	stone_albedo.seamless = true
	
	mat.albedo_texture = stone_albedo
	mat.normal_enabled = true
	mat.normal_texture = stone_tex
	mat.uv1_triplanar = true
	
	_stone_mat = mat
	return mat

static func get_player_material() -> StandardMaterial3D:
	if _player_mat: return _player_mat
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.4, 0.2)
	mat.roughness = 0.9
	
	var camo_noise = FastNoiseLite.new()
	camo_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	camo_noise.frequency = 0.01
	
	var camo_tex = NoiseTexture2D.new()
	camo_tex.noise = camo_noise
	camo_tex.seamless = true
	camo_tex.color_ramp = Gradient.new()
	camo_tex.color_ramp.add_point(0.0, Color(0.2, 0.3, 0.1))
	camo_tex.color_ramp.add_point(0.5, Color(0.4, 0.3, 0.2))
	camo_tex.color_ramp.add_point(1.0, Color(0.1, 0.1, 0.1))
	
	mat.albedo_texture = camo_tex
	mat.uv1_triplanar = true
	
	_player_mat = mat
	return mat

static func apply_material(node: Node, mat: Material):
	if node is MeshInstance3D:
		node.material_override = mat
	for child in node.get_children():
		apply_material(child, mat)
