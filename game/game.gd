extends Node2D


@export var initialLocation: MapLocation

@onready var playerScene = get_node("Entities/Player")
@onready var navigationRegion = get_node("NavigationRegion2D")
@onready var currentLocation = get_node("CurrentLocation")
@onready var canvasModulate = get_node("CanvasModulate")


func _ready():
	canvasModulate.color = UtilsS.colorCanvasModulate
	
	visible = false
	LocationLoaderS.removeCurrentLocation()
	LocationLoaderS.loadArea(initialLocation.location)
	visible = true
