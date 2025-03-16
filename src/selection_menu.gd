extends Panel

var ui_grid_option_scene = load("res://src/ui_grid_option.tscn")
var options: Array = []

func addOption(type: String):
	print("add option to menu : " + str(type))
	var new_option = ui_grid_option_scene.instantiate()
	options.push_back(new_option)
	new_option.pressed.connect(_on_option_clicked)
	new_option.texture_normal = load("res://assets/" + str(type) + ".png")
	$SelectionMenu/HFlowContainer.add_child(new_option)

func _on_option_clicked():
	pass
