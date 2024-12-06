extends Node2D


@onready var blockage1 = get_node("NavigationRegion2D/EnvironmentalObjects/Decorations/Regular/Rubble/BlockageRemove1")
@onready var blockage2 = get_node("NavigationRegion2D/EnvironmentalObjects/Decorations/Regular/Rubble/BlockageRemove2")

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var enemies = get_node("Entities/Enemies")
@onready var exits = get_node("NavigationRegion2D/Tilemap").get_children()
@onready var transportNodes = get_node("NavigationRegion2D/EnvironmentalObjects/Interactions/TransportNodes")


func _ready():
	if LocationLoaderS.currentLocation in LocationLoaderS.exploredLocations:
		enemies.queue_free()
	
	for exit in exits:
		exit.get_child(0).exit.direction = exit.exits[0].direction
	
	if playerScene.atExit:
		for exit in exits:
			if exit.get_child(0).exit.direction == LocationLoaderS.currentToDirection:
				LocationLoaderS.spawnPlayer(exit.get_child(0).playerSpawner.global_position)
	
	if playerScene.atTransportNode:
		LocationLoaderS.spawnPlayer(transportNodes.get_child(0).playerSpawner.global_position)
		playerScene.atTransportNode = false
