extends Node2D

var world_scene = load("res://src/world.tscn")
var ui_layer_scene = load("res://src/ui_layer.tscn")
var world
var ui_layer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world = world_scene.instantiate()
	self.add_child(world)
	world.loadMap("res://maps/test.map_data")
	world.addPlayers(2)
	ui_layer = ui_layer_scene.instantiate()
	self.add_child(ui_layer)
	ui_layer.left_mouse_clicked.connect(_on_world_clicked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_organ_clicked(coords: Array, source_id: int, owner_id: int):
	print("Organ " + str(source_id) + " from player " + str(owner_id))

func _on_world_clicked(coords: Vector2):
	var entity = world.clickedOrgan(world.globalToMap(coords))
	if entity and entity.type == "organ":
		var available_positions = world.availablePositions(entity)
		print("Organ " + str(entity.organ_id) + " from player " + str(entity.owner_id) + " at " + str(entity.position_in_map))
		ui_layer.clearElements()
		for pos in available_positions:
			ui_layer.addUIPlus(world.mapToGlobal(pos), pos, world.tile_size, world.scale[0])
