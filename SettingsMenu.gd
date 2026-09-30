extends Control

@onready var color_picker = $VBoxContainer/HBoxContainer/ColorPickerButton
@onready var slider = $VBoxContainer/HBoxContainer2/HSlider
@onready var back_btn = $VBoxContainer/BackButton

func _ready():
	color_picker.color = GlobalSettings.crosshair_color
	slider.value = GlobalSettings.swipe_sensitivity
	
	color_picker.color_changed.connect(_on_color_changed)
	slider.value_changed.connect(_on_slider_changed)
	back_btn.pressed.connect(_on_back_pressed)

func _on_color_changed(color: Color):
	GlobalSettings.crosshair_color = color

func _on_slider_changed(val: float):
	GlobalSettings.swipe_sensitivity = val
	GlobalSettings.mouse_sensitivity = val / 2.0

func _on_back_pressed():
	queue_free()
