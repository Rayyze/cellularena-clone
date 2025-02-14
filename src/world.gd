extends Node2D

signal clicked(coords: Array, source_id: int, owner_id: int)

var map: Array = []
var spawn_locations: Array = []
var width: int = 0
var height: int = 0
var tile_size: int = 524
var types_costs: Dictionary = {"basic" : [1,0,0,0], "harvester": [0,0,1,1], "tentacle": [0,1,1,0], "sporer": [0,1,0,1], "root": [1,1,1,1]}
var organs: Array = []
var players_stocks: Array = []
var to_destroy: Array = []
var free_organs_flag = false

var organ_scene = load("res://src/organ.tscn")
var wall_scene = load("res://src/wall.tscn")
var protein_scene = load("res://src/protein.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if free_organs_flag:
		for i in range(organs.size()):
			if not is_instance_valid(organs[i]):
				organs[i] = null
				
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = to_local(event.global_position)
		var source_coords = Vector2i(int(local_pos.x/tile_size), int(local_pos.y/tile_size))
		if isWithinBounds(source_coords):
			var possible_positions: Array = []
			var directions: Array = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]
			for dir in directions:
				var temp_pos = dir + source_coords
				if isWithinBounds(temp_pos) and map[temp_pos.x][temp_pos.y] == null:
					possible_positions.append(temp_pos)
			var source_organ = map[source_coords.x][source_coords.y]
			if possible_positions.size() > 0 and source_organ != null and source_organ.get("organ_id"):
				clicked.emit(possible_positions, source_organ.organ_id, source_organ.owner_id)

func isWithinBounds(coords: Vector2i) -> bool:
	return coords.x < width and coords.x >= 0 and coords.y < height and coords.y >= 0

func loadMap(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Error: Could not open file at path:", path)
		return
	var content = file.get_csv_line()
	# load map info
	if content.size() >= 3 and (content.size()-3)%2 == 0:
		name = content[0]
		width = int(content[1])
		height = int(content[2])
		for i in range(3, content.size(), 2):
			if int(content[i]) >= 0 and int(content[i]) < width and int(content[i+1]) >= 0 and int(content[i+1]) < height:
				spawn_locations.append(Vector2i(int(content[i]), int(content[i+1])))
		for x in range(width):
			var col = Array()
			for y in range(height):
				col.append(null)
			map.append(col)
			
	# load map data
	content = file.get_csv_line()
	var y = 0
	while not file.eof_reached():
		for x in range(content.size()):
			if (width > x and height > y):
				if int(content[x]) == 1:
					map[x][y] = wall_scene.instantiate()
					self.add_child(map[x][y])
					map[x][y].position = Vector2(x * tile_size, y * tile_size)
				elif content[x] == "A" or content[x] == "B" or content[x] == "C" or content[x] == "D":
					map[x][y] = protein_scene.instantiate()
					self.add_child(map[x][y])
					map[x][y].setType(content[x])
					map[x][y].position = Vector2(x * tile_size, y * tile_size)
					
			else:
				push_error("Invalid map file")
				return
		y += 1
		content = file.get_csv_line()
	self.scale = Vector2(0.1, 0.1)

func addOrgan(coords: Vector2i, type: String, owner_id: int = -1, organ_dir: String = "", source_id: int = -1) -> void:
	if (coords[0] >= width or coords[1] >= height):
		push_error("Invalid coordinates")
		return
	if not types_costs.keys().has(type):
		push_error("Invalid type")
		return
	var cost = types_costs[type]
	if owner_id < 0 and owner_id >= players_stocks.size():
		push_error("Invalid player")
		return
	if not (cost[0] <= players_stocks[owner_id][0] and cost[1] <= players_stocks[owner_id][1] and cost[2] <= players_stocks[owner_id][2] and cost[3] <= players_stocks[owner_id][3]):
		push_error("Not enough protein")
		return
	if (source_id < 0 or source_id >= organs.size()) and type != "root":
		push_error("Invalid parent for organ")
		return
	if type != "root" and owner_id != organs[source_id].owner:
		push_error("Invalid parent for organ")
		return
	if type != "root" and (abs(organs[source_id].position_in_map - coords) > 1):
		push_error("Invalid coordinates for this parent")
		return
	
	if not (organ_dir=="N" or organ_dir=="S" or organ_dir=="E" or organ_dir=="W"):
		push_warning("Invalid direction")
		organ_dir = "N"
	var root_id = organs.size()
	var parent = self
	if type != "root":
		root_id = organs[source_id].root_id
	else:
		for organ in organs:
			if organ.organ_id == source_id:
				parent = organ
	for i in range(cost.size()):
		players_stocks[owner_id][i] -= cost[i]
	map[coords.x][coords.y] = organ_scene.instantiate()
	parent.add_child(map[coords.x][coords.y])
	map[coords.x][coords.y].attacked.connect(_on_organ_attack)
	map[coords.x][coords.y].harvested.connect(_on_organ_harvest)
	organs.append(map[coords.x][coords.y])
	map[coords.x][coords.y].setup(organs.size(), coords, type, owner_id, root_id, organ_dir)
	map[coords.x][coords.y].position = coords*tile_size

func addPlayers(player_count: int):
	for i in range(player_count):
		players_stocks.append([1,1,1,1])
		addOrgan(spawn_locations[i], "root", i, "N")

func resolveTurn():
	for organ in organs:
		organ.action()
	for target in to_destroy:
		target.queue_free()
		free_organs_flag = true

func _on_organ_attack(target):
	to_destroy.append(target)
	
func _on_organ_harvest(protein, emitter_id):
	var type_to_index: Dictionary = {"A": 0, "B": 1, "C": 2, "D": 3}
	players_stocks[emitter_id][type_to_index[protein]] += 1
