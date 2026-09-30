extends RigidBody3D

var is_highlighted = false
var player = null
var mesh_instance = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	# Find the actual MeshInstance3D inside the imported GLB
	for child in $Stone.get_children():
		if child is MeshInstance3D:
			mesh_instance = child
			break
			
	MaterialHelper.apply_material($Stone, MaterialHelper.get_stone_material())

func _process(_delta):
	if player:
		# Calculate distance to player (using global_position)
		var dist = global_position.distance_to(player.global_position)
		if dist <= 3.0:
			set_highlight(true)
		else:
			set_highlight(false)

func set_highlight(active):
	if is_highlighted == active: return
	is_highlighted = active
	
	if mesh_instance:
		if active:
			# Create a glowing outline/overlay
			var highlight_mat = StandardMaterial3D.new()
			highlight_mat.albedo_color = Color(1, 1, 0, 0.2)
			highlight_mat.emission_enabled = true
			highlight_mat.emission = Color(1, 1, 0.5)
			highlight_mat.emission_energy = 0.8
			highlight_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.material_overlay = highlight_mat
		else:
			mesh_instance.material_overlay = null

func _input_event(camera, event, position, normal, shape_idx):
	# Handled dynamically by RayCast on PC, or by touch on Mobile
	var is_touch = (event is InputEventScreenTouch and event.pressed)
	if is_touch:
		pick_up(player)

func pick_up(by_player):
	if is_highlighted and by_player:
		var success = by_player.add_item("stone")
		if success:
			queue_free()
