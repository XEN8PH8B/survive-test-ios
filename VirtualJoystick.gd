extends Control

@onready var base = $Base
@onready var stick = $Base/Stick

var stick_center = Vector2.ZERO
var max_distance = 100.0
var output = Vector2.ZERO
var is_pressed = false
var touch_id = -1

func _ready():
	stick_center = stick.position
	# Hide joystick on PC if requested, but left visible for testing
	if OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linux"):
		pass # You can hide it by uncommenting: self.visible = false

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var rect = base.get_global_rect()
			if rect.has_point(event.position):
				is_pressed = true
				touch_id = event.index
				_update_joystick(event.position)
		else:
			if event.index == touch_id:
				is_pressed = false
				touch_id = -1
				stick.position = stick_center
				output = Vector2.ZERO
				
	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_id:
			_update_joystick(event.position)

func _update_joystick(touch_pos):
	var center = base.global_position + base.size / 2.0
	var offset = touch_pos - center
	if offset.length() > max_distance:
		offset = offset.normalized() * max_distance
	
	stick.position = stick_center + offset
	output = offset / max_distance
