extends Node2D

var type

func setType(_type: String):
	type = _type
	get_child(0).play("A")
