extends Node2D

signal left_mouse_clicked(pos: Vector2)

var ui_plus_scene = load("res://src/ui_plus.tscn")
var selection_menu_scene = load("res://src/selection_menu.tscn")
var current_menu = null
var ui_plus_array: Array = []
var ui_plus_pos: Array = []
var possible_organs: Array = []
var move: Dictionary = {}

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		left_mouse_clicked.emit(event.global_position)

func updatePossibleOrgans(new_value: Array):
	possible_organs = new_value
	
func clearElements():
	for elt in ui_plus_array:
		elt.queue_free()
	if current_menu:
		current_menu.queue_free()
	current_menu = null
	possible_organs = []
	ui_plus_array = []
	ui_plus_pos = []
	move = {}

func addUIPlus(global_coords: Vector2, map_coords: Vector2i, size: int, scale: float):
	var new_button = ui_plus_scene.instantiate()
	ui_plus_array.push_back(new_button)
	add_child(new_button)
	new_button.set_global_position(global_coords)
	new_button.scale = Vector2(scale, scale)
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
	for type in possible_organs[i]:
		current_menu.addOption(type)
	current_menu.set_global_position(pressed_button.global_position)
	add_child(current_menu)
	print(move["coords"])
	pressed_button.disabled = true
