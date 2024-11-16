extends Node2D


@export var initialLocation: MapLocation

@onready var startingArea = preload("res://game/areas/a-past-forgotten.tscn")
@onready var playerScene = get_node("Entities/Player")
@onready var enemies = get_node("Entities/Enemies")
@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var currentLocation = get_node("CurrentLocation")
@onready var canvasModulate = get_node("CanvasModulate")
@onready var particles = get_node("Particles")
@onready var soundComponent = get_node("GameSoundComponent")


func _ready():
	canvasModulate.color = UtilsS.colorCanvasModulate
	loadGame()


func startNewGame():
	visible = false
	playerScene.setup()
	LocationLoaderS.removeCurrentLocation()
	LocationLoaderS.loadArea(startingArea, false)
	visible = true
	
	await get_tree().create_timer(2).timeout
	var location = preload("res://environment/curiosities/location.tscn").instantiate()
	location.title = "???"
	location.initialDialog = preload("res://dialogs/resources/spawn/D-initial.tres")
	var scene = UILoaderS.loadUIScene(preload("res://UI/dialog/dialog-menu-ui.tscn"))
	scene.setup(location)


func loadGame():
	visible = false
	PersistenceS.loadGame()
	LocationLoaderS.loadArea(LocationLoaderS.currentLocation, false)
	playerScene.setup()
	visible = true






