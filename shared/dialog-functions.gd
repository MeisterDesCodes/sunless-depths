extends Node

class_name DialogFunctions

@onready var map = get_tree().get_root().get_node("Game").get_child(0).get_child(0)


func clearPath():
	map.blockage1.queue_free()
	map.blockage2.queue_free()
