extends Node2D


@onready var blockage1 = get_node("Map/EnvironmentalObjects/Decorations/Regular/Rubble/BlockageRemove1")
@onready var blockage2 = get_node("Map/EnvironmentalObjects/Decorations/Regular/Rubble/BlockageRemove2")

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var game: Node2D = get_tree().get_root().get_node("GameController/Game")
@onready var enemies = get_node("Entities/Enemies")
@onready var exits = get_node("Map/Tilemap").get_children()
@onready var transportNodes = get_node("Map/EnvironmentalObjects/Interactions/TransportNodes")


func _ready():
	if LocationLoaderS.currentLocation in LocationLoaderS.exploredLocations:
		enemies.queue_free()
	else:
		for enemy in enemies.get_children():
			enemy.reparent(game.enemies)
	
	for exit in exits:
		exit.get_child(0).exit.direction = exit.exits[0].direction
	
	if playerScene.atExit:
		for exit in exits:
			if exit.get_child(0).exit.direction == LocationLoaderS.currentToDirection:
				LocationLoaderS.spawnPlayer(exit.get_child(0).playerSpawner.global_position)
	
	if playerScene.atTransportNode:
		LocationLoaderS.spawnPlayer(transportNodes.get_child(0).playerSpawner.global_position)
		playerScene.atTransportNode = false
