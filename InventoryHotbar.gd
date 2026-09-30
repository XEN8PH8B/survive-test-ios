extends Control

signal slot_selected(index)

@onready var container = $HBoxContainer
var slots = []
var selected_index = 0

var normal_style = preload("res://SlotNormal.tres")
var selected_style = preload("res://SlotSelected.tres")

func _ready():
	for i in range(container.get_child_count()):
		var slot = container.get_child(i)
		slots.append(slot)
		slot.gui_input.connect(_on_slot_gui_input.bind(i))
	
	_update_selection_ui()

func _on_slot_gui_input(event: InputEvent, index: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_slot(index)

func select_slot(index: int):
	if index >= 0 and index < slots.size():
		selected_index = index
		_update_selection_ui()
		slot_selected.emit(index)

func _update_selection_ui():
	for i in range(slots.size()):
		if i == selected_index:
			slots[i].add_theme_stylebox_override("panel", selected_style)
		else:
			slots[i].add_theme_stylebox_override("panel", normal_style)

func set_slot_item(index: int, item_id: String):
	var slot = slots[index]
	for c in slot.get_children():
		c.queue_free()
	
	if item_id == "stone":
		var svc = SubViewportContainer.new()
		svc.set_anchors_preset(Control.PRESET_FULL_RECT)
		svc.stretch = true
		slot.add_child(svc)
		
		var vp = SubViewport.new()
		vp.transparent_bg = true
		vp.own_world_3d = true
		svc.add_child(vp)
		
		var cam = Camera3D.new()
		cam.position = Vector3(0, 0, 1.2)
		vp.add_child(cam)
		
		var light = DirectionalLight3D.new()
		light.position = Vector3(1, 1, 1)
		vp.add_child(light)
		
		var model = load("res://Stone.glb").instantiate()
		var script = GDScript.new()
		script.source_code = "extends Node3D\nfunc _process(delta):\n\trotate_y(delta)\n\trotate_x(delta * 0.5)"
		script.reload()
		model.set_script(script)
		model.set_process(true)
		MaterialHelper.apply_material(model, MaterialHelper.get_stone_material())
		
		vp.add_child(model)
