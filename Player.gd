extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var joystick = $UI/VirtualJoystick

@onready var anim_player = $PlayerModel/AnimationPlayer
@onready var hotbar = $UI/InventoryHotbar
@onready var attack_btn = $UI/ActionButtons/AttackButton
@onready var throw_btn = $UI/ActionButtons/ThrowButton
@onready var throw_bar = $UI/ThrowProgressBar
@onready var crosshair = $UI/Crosshair
@onready var pause_btn = $UI/PauseButton
@onready var pause_menu = $UI/PauseMenu
@onready var resume_btn = $UI/PauseMenu/VBoxContainer/ResumeButton
@onready var pause_settings_btn = $UI/PauseMenu/VBoxContainer/SettingsButton
@onready var menu_btn = $UI/PauseMenu/VBoxContainer/MenuButton

var hand_attachment = null

var mouse_sensitivity = 0.002
var swipe_sensitivity = 0.005
var look_touch_id = -1

var inventory = []
var selected_slot = 0

var is_attacking = false
var is_charging_throw = false
var throw_charge = 0.0
var max_throw_charge = 1.0
var charge_speed = 1.5
var stone_scene = preload("res://StoneItem.tscn")

func _ready():
	if OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linux"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if anim_player:
		for anim_name in ["Walk", "Idle", "Hold_Walk", "Hold_Idle"]:
			if anim_player.has_animation(anim_name):
				anim_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
		anim_player.play("Idle")
		
	var skeleton = $PlayerModel.find_child("Skeleton3D", true, false)
	if skeleton:
		hand_attachment = BoneAttachment3D.new()
		hand_attachment.bone_name = "Forearm.R"
		skeleton.add_child(hand_attachment)
		
		var stone = load("res://Stone.glb").instantiate()
		stone.name = "Stone"
		stone.position = Vector3(0.0, 0.35, 0.05) 
		stone.scale = Vector3(0.6, 0.6, 0.6)
		stone.rotation = Vector3(0, PI/4, 0)
		stone.visible = false
		MaterialHelper.apply_material(stone, MaterialHelper.get_stone_material())
		hand_attachment.add_child(stone)
		
	for i in range(9):
		inventory.append("")
		
	if hotbar: hotbar.slot_selected.connect(_on_slot_selected)
	if attack_btn: attack_btn.pressed.connect(_on_attack_pressed)
	if throw_btn:
		throw_btn.button_down.connect(_on_throw_down)
		throw_btn.button_up.connect(_on_throw_up)
		
	if pause_btn: pause_btn.pressed.connect(_on_pause_pressed)
	if resume_btn: resume_btn.pressed.connect(_on_resume_pressed)
	if pause_settings_btn: pause_settings_btn.pressed.connect(_on_pause_settings_pressed)
	if menu_btn: menu_btn.pressed.connect(_on_menu_pressed)
		
	_update_hand_item()

func _process(_delta):
	if crosshair:
		crosshair.color = GlobalSettings.crosshair_color
	mouse_sensitivity = GlobalSettings.mouse_sensitivity
	swipe_sensitivity = GlobalSettings.swipe_sensitivity

func _on_pause_pressed():
	get_tree().paused = true
	if pause_menu: pause_menu.visible = true
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed():
	get_tree().paused = false
	if pause_menu: pause_menu.visible = false
	if OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linux"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_pause_settings_pressed():
	var settings = load("res://SettingsMenu.tscn").instantiate()
	pause_menu.add_child(settings)

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func add_item(item_id: String) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == "":
			inventory[i] = item_id
			if hotbar:
				hotbar.set_slot_item(i, item_id)
			if i == selected_slot:
				_update_hand_item()
			return true
	return false

func _on_slot_selected(index: int):
	selected_slot = index
	_update_hand_item()

func _update_hand_item():
	if not hand_attachment: return
	
	for c in hand_attachment.get_children():
		c.visible = false
		
	var item = inventory[selected_slot]
	if item == "stone":
		var stone = hand_attachment.get_node_or_null("Stone")
		if stone:
			stone.visible = true

func _on_attack_pressed():
	if is_attacking or is_charging_throw: return
	is_attacking = true
	var anim = "Attack1" if randf() > 0.5 else "Attack2"
	if anim_player and anim_player.has_animation(anim):
		anim_player.play(anim, 0.1)
		await get_tree().create_timer(anim_player.get_animation(anim).length).timeout
	is_attacking = false

func _on_throw_down():
	if is_attacking or is_charging_throw: return
	if inventory[selected_slot] == "": return
	is_charging_throw = true
	throw_charge = 0.0
	throw_bar.visible = true
	throw_bar.value = 0.0

func _on_throw_up():
	if not is_charging_throw: return
	is_charging_throw = false
	throw_bar.visible = false
	
	var item_id = inventory[selected_slot]
	inventory[selected_slot] = ""
	if hotbar: hotbar.set_slot_item(selected_slot, "")
	_update_hand_item()
	
	is_attacking = true
	var anim = "Drop"
	var impulse = throw_charge * 20.0
	if throw_charge > 0.2:
		anim = "Throw"
	
	if anim_player and anim_player.has_animation(anim):
		anim_player.play(anim, 0.1)
	
	var inst = stone_scene.instantiate()
	get_parent().add_child(inst)
	inst.global_position = camera.global_position - camera.global_transform.basis.z * 1.0
	
	var throw_dir = -camera.global_transform.basis.z + Vector3(0, 0.2, 0)
	inst.apply_central_impulse(throw_dir.normalized() * impulse)
	
	if anim_player and anim_player.has_animation(anim):
		await get_tree().create_timer(anim_player.get_animation(anim).length).timeout
	is_attacking = false

@onready var interact_ray = $Head/Camera3D/InteractRay

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if event.pressed:
				_on_throw_down()
			else:
				_on_throw_up()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var picked_up = false
			if interact_ray and interact_ray.is_colliding():
				var obj = interact_ray.get_collider()
				if obj and obj.has_method("pick_up"):
					obj.pick_up(self)
					picked_up = true
			if not picked_up:
				_on_attack_pressed()

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event is InputEventScreenTouch:
		# Attack/Throw handled by UI buttons
		if event.pressed:
			# Only rotate if touching right half and not touching buttons
			if event.position.x > get_viewport().size.x / 2.0:
				var is_on_btn = false
				if attack_btn and attack_btn.get_global_rect().has_point(event.position): is_on_btn = true
				if throw_btn and throw_btn.get_global_rect().has_point(event.position): is_on_btn = true
				if not is_on_btn:
					look_touch_id = event.index
		else:
			if event.index == look_touch_id:
				look_touch_id = -1
				
	if event is InputEventScreenDrag:
		if event.index == look_touch_id:
			rotate_y(-event.relative.x * swipe_sensitivity)
			camera.rotate_x(-event.relative.y * swipe_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
			
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if get_tree().paused:
				_on_resume_pressed()
			else:
				_on_pause_pressed()
		
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var idx = event.keycode - KEY_1
			if hotbar:
				hotbar.select_slot(idx)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if is_charging_throw:
		throw_charge += delta * charge_speed
		throw_charge = min(throw_charge, max_throw_charge)
		if throw_bar:
			throw_bar.value = throw_charge

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if joystick and joystick.output != Vector2.ZERO:
		input_dir = joystick.output

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var is_holding = inventory[selected_slot] != ""
	var walk_anim = "Hold_Walk" if is_holding else "Walk"
	var idle_anim = "Hold_Idle" if is_holding else "Idle"
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if not is_attacking and not is_charging_throw:
			if anim_player and anim_player.current_animation != walk_anim:
				anim_player.play(walk_anim, 0.2)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if not is_attacking and not is_charging_throw:
			if anim_player and anim_player.current_animation != idle_anim:
				anim_player.play(idle_anim, 0.2)

	move_and_slide()
