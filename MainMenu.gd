extends Control

@onready var title = $Title
@onready var button_container = $VBoxContainer
@onready var play_button = $VBoxContainer/PlayButton
@onready var settings_button = $VBoxContainer/SettingsButton

func _ready():
	# Connect buttons
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)

	# Store original positions set in the editor via layout
	var title_target_pos = title.position
	var buttons_target_pos = button_container.position
	
	# Set initial positions to be off-screen
	var viewport_size = get_viewport_rect().size
	
	# Move title above screen
	title.position.y = -title.size.y - 200
	title.position.x = title_target_pos.x
	
	# Move buttons below screen
	button_container.position.y = viewport_size.y + 200
	button_container.position.x = buttons_target_pos.x
	
	# Animate using Tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Use TRANS_BACK for a nice bouncy slide-in effect
	tween.tween_property(title, "position", title_target_pos, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button_container, "position", buttons_target_pos, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://LoadingScreen.tscn")

func _on_settings_button_pressed():
	var settings = load("res://SettingsMenu.tscn").instantiate()
	add_child(settings)
