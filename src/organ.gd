extends Node2D

signal attacked(organ)
signal harvested(type, emitter_id)

var organ_id: int
var position_in_map: Vector2i
var organ_type: String
var owner_id: int
var root_id: int
var organ_dir: String
var facing = null
var type: String = "organ"

func setup(_organ_id: int, _position: Vector2i, _organ_type: String, _owner_id: int, _root_id: int, _organ_dir: String) -> void:
	organ_id = _organ_id
	position_in_map = _position
	organ_type = _organ_type
	owner_id = _owner_id
	root_id = _root_id
	organ_dir = _organ_dir
	get_child(0).play(organ_type)

func action():
	match organ_type:
		"harvester":
			self.harvest()
		"tentacle":
			self.attack()
			 
func harvest():
	if (facing != null && facing.type == "protein"):
		harvested.emit(facing.protein_type, organ_id)
	
func attack():
	if (facing != null && facing.type == "organ" && facing.owner != owner):
		attacked.emit(facing)

func _on_facing_hitbox_area_entered(area: Area2D) -> void:
	facing = area.get_parent()

func _on_facing_hitbox_area_exited(_area: Area2D) -> void:
	facing = null
