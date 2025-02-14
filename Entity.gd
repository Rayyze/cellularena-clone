class_name Entity

extends Object  # Use Object as a base for lightweight classes

var organ_id: int
var position: Vector2i
var type: String
var owner: int
var root_id: int
var organ_dir: String

# Constructor
func _init(_organ_id: int = -1, _position: Vector2i = Vector2i(-1, -1), _type: String = "", _owner: int = -1, _root_id: int = -1, _organ_dir: String  = ""):
	organ_id = _organ_id
	position = _position
	type = _type
	owner = _owner
	root_id = _root_id
	organ_dir = _organ_dir
