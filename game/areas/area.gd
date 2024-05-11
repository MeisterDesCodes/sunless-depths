extends Node2D


@onready var blockage1 = get_node("NavigationRegion2D/EnvironmentalObjects/Decorations/Regular/Rubble/BlockageLargeRemove1")
@onready var blockage2 = get_node("NavigationRegion2D/EnvironmentalObjects/Decorations/Regular/Rubble/BlockageLargeRemove2")

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var exits = get_node("NavigationRegion2D/Tilemap").get_children()


func _ready():
	for exit in exits:
		if exit.exits[0].direction == LocationLoaderS.currentToDirection:
			LocationLoaderS.spawnPlayer(exit.get_child(0).get_child(2).global_position)
