extends Node

onready var player = preload("res://Player.tscn")
onready var wall = preload("res://test_map.tscn")
func _ready():
	var p = player.instance()
	var w = wall.instance()
	add_child(p)
	add_child(w)