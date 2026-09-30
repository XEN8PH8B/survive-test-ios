extends SceneTree

func _init():
	print("Generating procedural materials...")
	
	# 1. Stone Material
	var stone_mat = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.4, 0.4, 0.4)
	stone_mat.roughness = 0.8
	
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
	
	stone_mat.albedo_texture = stone_albedo
	stone_mat.normal_enabled = true
	stone_mat.normal_texture = stone_tex
	stone_mat.uv1_triplanar = true
	
	ResourceSaver.save(stone_mat, "res://StoneMaterial.tres")
	
	# 2. Player Material (Camo / Fabric)
	var player_mat = StandardMaterial3D.new()
	player_mat.albedo_color = Color(0.3, 0.4, 0.2) # Dark greenish base
	player_mat.roughness = 0.9
	
	var camo_noise = FastNoiseLite.new()
	camo_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	camo_noise.frequency = 0.01
	
	var camo_tex = NoiseTexture2D.new()
	camo_tex.noise = camo_noise
	camo_tex.seamless = true
	camo_tex.color_ramp = Gradient.new()
	camo_tex.color_ramp.add_point(0.0, Color(0.2, 0.3, 0.1)) # Dark green
	camo_tex.color_ramp.add_point(0.5, Color(0.4, 0.3, 0.2)) # Brown
	camo_tex.color_ramp.add_point(1.0, Color(0.1, 0.1, 0.1)) # Dark grey
	
	player_mat.albedo_texture = camo_tex
	player_mat.uv1_triplanar = true
	
	ResourceSaver.save(player_mat, "res://PlayerMaterial.tres")
	
	print("Materials saved successfully!")
	quit()
