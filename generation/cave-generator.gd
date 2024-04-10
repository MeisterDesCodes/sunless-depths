@tool
extends Node2D


@export var generate: bool:
	set(value):
		generateCave()

var rooms = [preload("res://generation/room-1.tscn")]


func generateCave():
	print(rooms)
	var room = rooms.pick_random().instantiate()
	add_child(room)
