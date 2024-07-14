extends Node


class_name DialogFunctions


func clearPath():
	var map = get_tree().get_root().get_node("Game").get_child(1).get_child(0)
	map.blockage1.queue_free()
	map.blockage2.queue_free()
