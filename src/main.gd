extends Node2D

var world_scene = load("res://src/world.tscn")
var world

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world = world_scene.instantiate()
	self.add_child(world)
	world.clicked.connect(_on_organ_clicked)
	world.loadMap("res://maps/test.map_data")
	world.addPlayers(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_organ_clicked(coords: Array, source_id: int, owner_id: int):
	pass
