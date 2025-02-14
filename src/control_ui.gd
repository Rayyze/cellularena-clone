extends Node2D

var selected_tile_position: Vector2i = Vector2i(-1, -1)
var owner_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func select_tile(tile_data, global_coords):
	if tile_data.owner == owner_id:
		selected_tile_position = tile_data.position
		push_warning("tile selected at : " + str(selected_tile_position))
		# TODO
