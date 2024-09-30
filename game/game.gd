extends Node2D


@export var initialLocation: MapLocation

@onready var playerScene = get_node("Entities/Player")
@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var currentLocation = get_node("CurrentLocation")
@onready var canvasModulate = get_node("CanvasModulate")
@onready var particles = get_node("Particles")
@onready var gameSoundComponent = get_node("GameSoundComponent")


func _ready():
	canvasModulate.color = UtilsS.colorCanvasModulate
	
	visible = false
	PersistenceS.loadGame()
	playerScene.setup()
	visible = true

	#LocationLoaderS.removeCurrentLocation()
	#LocationLoaderS.loadArea(initialLocation.location)

