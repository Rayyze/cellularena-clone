extends TileMapLayer

signal tile_clicked(tile_data, global_coords) # global coords are the coordinates of the center of the tile on the screen

# A precomputed dictionary mapping types to tile IDs
var type_to_tile: Dictionary = {
	"root": Vector2i(0, 0),
	"basic": Vector2i(0, 1)
}

var is_entity: Dictionary = {
	"root": true,
	"basic": true	
}

var dir_to_alternative: Dictionary = { "N": 0, "W": 1, "S": 2, "E": 3 }

var organ_atlas_id: int = 1

var entities: Dictionary
var next_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		var cell_data = get_cell_tile_data(local_to_map(to_local(event.position)))
		tile_clicked.emit(cell_data, map_to_local(to_global(cell_data.get_custom_data("position"))))

func add(coords: Vector2i, type: String, owner_id: int = -1, organ_dir: String = "", source_id: int = -1):
	var new_entity = Entity.new()
	if is_entity.has(type):
		new_entity.organ_id = next_id
		next_id += 1
		new_entity.organ_dir = organ_dir
		new_entity.owner = owner_id
		new_entity.position = coords
		new_entity.type = type
		if type != "root":
			new_entity.root_id
			placement_animation("spore", entities.get(source_id).position, coords)
		else:
			new_entity.root_id = new_entity.organ_id
			placement_animation("grow", entities.get(source_id).position, coords)
		entities.get_or_add(new_entity.organ_id, new_entity)
			
	set_cell(coords, organ_atlas_id, type_to_tile[type], dir_to_alternative[organ_dir])

func placement_animation(type: String, origin: Vector2i, position: Vector2i):
	pass
