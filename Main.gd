extends Node

onready var player = preload("res://player/Player.tscn")
onready var wall = preload("res://world/test_map.tscn")
onready var hud = preload("res://ui/Hud.tscn")
func _ready():
	var p = player.instance()
	var w = wall.instance()
	var h = hud.instance()
	add_child(h)
	add_child(p)
	add_child(w)
	
