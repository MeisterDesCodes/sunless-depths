extends Node2D


@onready var player = get_node("Entities/Player")
@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var caveGenerator = get_node("NavigationRegion2D/CaveGenerator")
@onready var currentScene = get_node("CurrentScene")

var currentLocation: PackedScene


func _ready():
	currentLocation = preload("res://game/areas/a-past-forgotten.tscn")


func generateCave():
	caveGenerator.spawnPlayer.connect(spawnPlayer)
	removeCurrentScene()
	caveGenerator.generateCave()
	navigationRegion.bake_navigation_polygon()


func spawnPlayer(_position: Vector2):
	player.global_position = _position


func removeCurrentScene():
	for child in currentScene.get_children():
		currentScene.remove_child(child)
