extends Node2D


@export var initialLocation: MapLocation

@onready var playerScene: CharacterBody2D = get_node("Entities/Player")
@onready var enemies = get_node("Entities/Enemies")
@onready var groundResources = get_node("GroundResources")
@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var currentLocation = get_node("NavigationRegion2D/CurrentLocation")
@onready var canvasModulate = get_node("CanvasModulate")
@onready var particles = get_node("Particles")
@onready var soundComponent = get_node("GameSoundComponent")

@onready var startingArea = preload("res://game/areas/a-past-forgotten.tscn")


func _ready():
	canvasModulate.color = UtilsS.colorCanvasModulate
	PersistenceS.setup()
	loadGame()


func startNewGame():
	visible = false
	playerScene.setup()
	LocationLoaderS.removeCurrentLocation()
	LocationLoaderS.loadArea(startingArea, false)
	visible = true
	
	await UtilsS.createTimer(2)
	UILoaderS.setupDialog(preload("res://dialogs/resources/spawn/D-initial.tres"), "???")


func loadGame():
	visible = false
	PersistenceS.loadGame()
	LocationLoaderS.loadArea(LocationLoaderS.currentLocation, false)
	playerScene.setup()
	visible = true


func resetGame():
	UtilsS.removeEntitiesFromScene(enemies)
	UtilsS.removeEntitiesFromScene(groundResources)
	
	playerScene.reset()
	loadGame()




