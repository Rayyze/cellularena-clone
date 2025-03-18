extends Node2D

signal left_mouse_clicked(pos: Vector2)

var ui_plus_scene = load("res://src/ui_plus.tscn")
var selection_menu_scene = load("res://src/selection_menu.tscn")
var organ_scene = load("res://src/organ.tscn")
var current_organ = null
var choose_mode: bool = false
var current_menu = null
var ui_plus_array: Array = []
var ui_plus_pos: Array = []
var possible_organs: Array = []
var move: Dictionary = {}

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_menu:
			if not current_menu.get_global_rect().has_point(event.global_position):
				clearElements()
		else:
			left_mouse_clicked.emit(event.global_position)

func updatePossibleOrgans(new_value: Array):
	possible_organs = new_value
	
func clearElements():
	if current_organ:
		current_organ.queue_free()
	current_organ = null
	if current_menu:
		current_menu.queue_free()
	for elt in ui_plus_array:
		elt.queue_free()
	current_menu = null
	possible_organs = []
	ui_plus_array = []
	ui_plus_pos = []
	move = {}

func addUIPlus(global_coords: Vector2, map_coords: Vector2i, l_scale: float):
	var new_button = ui_plus_scene.instantiate()
	ui_plus_array.push_back(new_button)
	add_child(new_button)
	new_button.set_global_position(global_coords)
	new_button.scale = Vector2(l_scale, l_scale)
	new_button.pressed.connect(_on_ui_plus_pressed.bind(new_button))
	ui_plus_pos.push_back(map_coords)

func _on_ui_plus_pressed(pressed_button):
	if current_menu:
		current_menu.queue_free()
	current_menu = null
	for elt in ui_plus_array:
		elt.disabled = false
	var i = ui_plus_array.find(pressed_button)
	move["coords"] = ui_plus_pos[i]
	current_menu = selection_menu_scene.instantiate()
	current_menu.option_pressed.connect(_on_option_pressed.bind(pressed_button))
	for type in possible_organs[i]:
		current_menu.addOption(type)
	current_menu.set_global_position(pressed_button.global_position)
	add_child(current_menu)
	print(move["coords"])
	pressed_button.disabled = true

func _on_option_pressed(type, pressed_button):
	clearElements()
	choose_mode = true
	current_organ = organ_scene.instantiate()
	current_organ.set_scale(pressed_button.get_scale())
	current_organ.set_global_position(pressed_button.get_global_position())
	current_organ.setup(-1, Vector2i(-1,-1), type, -1, -1, "")
	add_child(current_organ)
